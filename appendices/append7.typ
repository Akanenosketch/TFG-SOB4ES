== Guía de configuración y reproducibilidad \ (Anexo VII) <reproducibilidad-y-configuracion>

Este anexo funciona como *manual de usuario* para reproducir de principio a fin el _pipeline_ descrito en la #link(<arquitectura>)[*Arquitectura general*]: desde la configuración del entorno y las credenciales de los servicios externos, hasta la ejecución de los notebooks de ingesta, procesamiento, modelado y evaluación.

El objetivo es que cualquier persona con acceso a los datos originales pueda replicar los resultados de este TFG siguiendo los pasos indicados a continuación, sin tener que reconstruir el proceso a partir de la memoria ni realizar procesamientos similares a los ya realizados.

#rect[
  *Nota importante sobre los datos:* \  Los datos de campo del proyecto europeo SOB4ES (mediciones de las más de 400 parcelas, carpetas como `EARTHWORMS_RAW/` y el resto de ficheros base descritos en la sección 4) *no se distribuyen junto con el repositorio* ni son de acceso público, al pertenecer a un grupo de investigación propio dentro del marco del proyecto SOB4ES. \ \ Para poder ejecutar este _pipeline_ es imprescindible *solicitar dichos datos directamente al tutor o co-tutor de este TFG*, quien indicará el procedimiento de acceso y las condiciones de uso aplicables.\ \ Sin estos datos, únicamente pueden reproducirse las fases que dependen de fuentes públicas (GEE, Copernicus, ESDAC, CORINE), pero no el _pipeline_ completo.
]

=== Antes de empezar: requisitos previos <requisitos-previos>

Antes de clonar el repositorio, comprueba que dispones de lo siguiente:

- *Python* `3.14.x`, con `pip` disponible.
- *Git*, para clonar el repositorio y poder cambiar entre las ramas descritas en el #link(<dist-ramas-y-notebooks>)[*Anexo VI*].
- *Jupyter* y *nbconvert*, necesarios para ejecutar y automatizar los notebooks (véase #link(<elementos-auxiliares>)[*Anexo IV*]).
- Una cuenta de *Google Earth Engine* habilitada para uso no comercial/investigación, necesaria para hacer uso de `earthengine-api`.
- Una cuenta en el *Copernicus Climate Data Store* con un token de acceso personal, necesaria para hacer uso de `cdsapi`.
- Opcionalmente, una *GPU* compatible con PyTorch/CUDA si se quiere reproducir el entrenamiento con CUDA de los modelos compatibles con dicha tecnología (véase #link(<hardware-recomendado>)[*Hardware recomendado*]).

=== Clonación el repositorio <clonar-repo>

```bash
git clone https://github.com/Akanenosketch/TFG-SOB4ES.git
cd TFG-SOB4ES
```

El repositorio sigue la distribución de ramas documentada en el #link(<dist-ramas-y-notebooks>)[*Anexo VI*]. Por defecto, tras clonar, se estará situado en la rama principal (`master`), pensada únicamente para tener una vista general del proyecto.

Para reproducir un experimento concreto, cambia a la rama correspondiente, por ejemplo:

```bash
# Modelos base
git switch model-prep

# Prueba de eliminación de variables (cu_z, ni_z y mo_z a la vez)
git switch model-prep-var-1-2-3

# Prueba de barrido de random_state (primera iteración)
git switch model-prep-rs-group
```

=== Configuración el entorno Python <configuracion-entorno>

Existen dos formas equivalentes de crear el entorno; a continuación se describen las dos más comunes.

*Opción A: `venv` + `pip`*

```bash
python -m venv .venv
source .venv/bin/activate   # En Windows: .venv\Scripts\activate

pip install --upgrade pip
pip install -r requirements.txt
```

*Opción B: `uv`*

*uv*#sub([@uv-docs]) es un gestor de paquetes y entornos de Python, compatible con `pip`/`requirements.txt`, pero significativamente más rápido gracias a su resolutor de dependencias escrito en Rust y a su caché global de paquetes.

Es especialmente útil aquí porque este TFG instala librerías pesadas (PyTorch, XGBoost, rasterio) que con `pip` pueden tardar bastante en resolverse.

Para instalar `uv` en el dispositivo:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh   # Linux/macOS

# En Windows (PowerShell):

powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

Crear el entorno e instalar las dependencias:

```bash
uv venv --python 3.14
source .venv/bin/activate   # En Windows: .venv\Scripts\activate

uv pip install -r requirements.txt
```

Para una reproducción más estricta (instala exactamente lo que hay en `requirements.txt`, eliminando cualquier paquete adicional que hubiera en el entorno), puede usarse en su lugar:

```bash
uv pip sync requirements.txt
```

También es posible ejecutar comandos puntuales sin activar el entorno manualmente, anteponiendo `uv run`, por ejemplo:

```bash
uv run jupyter nbconvert --to notebook --execute --inplace notebook.ipynb
```

#rect[
  *Nota:* \   Si se va a reproducir el entrenamiento de los modelos MLP (`torch`), instala la variante de PyTorch adecuada a tu hardware (CPU o CUDA) siguiendo las instrucciones oficiales de *pytorch.org#sub([@pytorchDocs])* antes de instalar el resto de `requirements.txt` (con `pip install` o con `uv pip install`, según la opción elegida), ya que la versión genérica instalada por defecto puede no aprovechar la GPU disponible.
]

#colbreak()

=== Configuración las credenciales de los servicios externos <credenciales-externas>

==== Google Earth Engine (GEE)

La forma recomendada de autenticarse es la misma que se usa dentro de los propios notebooks de ingesta, ejecutando estas dos líneas en una celda de Python:

```python
import ee

# abre el navegador para vincular la cuenta de Google (solo hace falta la primera vez)
ee.Authenticate()

ee.Initialize(project="<id-del-proyecto-en-GCloud>")
```

*`ee.Authenticate()`* guarda un token de credenciales localmente (en `~/.config/earthengine/credentials` en Linux/macOS), de forma que en próximas ejecuciones, incluidas las de los propios notebooks del _pipeline_, basta con llamar a *`ee.Initialize(project=...)`*, sin repetir *`ee.Authenticate()`*.

Es *necesario disponer de un proyecto de Google Cloud asociado* (gratuito para investigación no comercial) y su identificador es el que hay que indicar en *`project=`*.

#rect[
  *Problema conocido: bloqueo de la autenticación de GEE* \ \
  Cuando el _pipeline_ se lanza, la llamada a `ee.Authenticate()` abre un navegador y levantar un servidor local para recibir la respuesta de OAuth. 
  
  Una vez autenticado correctamente, todo el proceso ed directamente es bloqueado por los propios sistemas de seguridad de Google, que interpretan la petición automática como sospechosa (en la práctica, la infraestructura de Google acaba bloqueando la propia autenticación contra Google). \ \
  *Solución:* autenticar la cuenta manualmente *una sola vez*, antes de lanzar cualquier ejecución automatizada, usando el modo de autenticación por CLI orientado a notebooks:

  ```bash
  earthengine authenticate --auth_mode=notebook
  ```

  Este modo genera una URL que se abre manualmente en cualquier navegador, tras lo cual se pega el código de verificación en la terminal. El token resultante se guarda en `~/.config/earthengine/credentials`, igual que con `ee.Authenticate()`, por lo que las ejecuciones posteriores solo necesitan llamar a `ee.Initialize(project=...)` y no vuelven a disparar el flujo de navegador que provoca el bloqueo.
]

Como alternativa por terminal (equivalente, pero fuera del notebook) existe también el comando `earthengine authenticate` sin argumentos, aunque para este _pipeline_ se recomienda el flujo anterior (`--auth_mode=notebook`) precisamente para evitar el problema descrito arriba, especialmente si se van a usar los scripts de automatización del #link(<elementos-auxiliares>)[*Anexo IV*].

*Documentación oficial:*
- *Autenticación:* https://developers.google.com/earth-engine/guides/auth
- *Instalación y primeros pasos con la API de Python:* https://developers.google.com/earth-engine/guides/python_install

#colbreak()

==== Copernicus Climate Data Store (CDS)

Tras registrarse en el #link("https://cds.climate.copernicus.eu/")[*CDS*] y obtener el *Personal Access Token* desde el perfil creado (https://cds.climate.copernicus.eu/profile), se debe de crear el fichero `~/.cdsapirc` (en Windows, `C:\Users\<usuario>\.cdsapirc`) con el siguiente contenido:

```
url: https://cds.climate.copernicus.eu/api
key: <Personal-Access-Token>
```

La librería `cdsapi` lee este fichero automáticamente al ejecutar cualquier solicitud de descarga, independientemente de que se ejecute desde un notebook o desde un script.

*Documentación oficial:* https://cds.climate.copernicus.eu/how-to-api

==== Copernicus DEM (vía AWS S3)

*No requiere autenticación ni registro:* el bucket público de AWS S3 que aloja el DEM (GLO-30) es accesible directamente mediante `rasterio` indicando la URL correspondiente, tal como se describe en la #link(<capa-ingesta>)[*Capa de ingesta de datos*].

*Documentación oficial del _dataset_:* https://registry.opendata.aws/copernicus-dem/

#colbreak()

=== Obtenención y ubicación los datos base <datos-base>

Una vez recibidos los datos del proyecto SOB4ES por parte del tutor (véase el aviso al inicio de este anexo), colócalos en la estructura de carpetas que esperan los notebooks de ingesta:

```
TFG-SOB4ES/
├── data/
│   ├── raw/
│   │   ├── EARTHWORMS_RAW/
│   │   └── resto de carpetas/ficheros base del proyecto SOB4ES
│   └── external/
│       └── capas ESDAC/CORINE si se distribuyen aparte
├── notebooks/
└── ...
```

#rect[
  *Nota:* la estructura exacta de carpetas debe verificarse contra el `.gitignore` del repositorio y contra el primer notebook de la #link(<capa-ingesta>)[*Capa de ingesta de datos*], ya que las rutas de lectura pueden haberse fijado como rutas relativas concretas durante el desarrollo..
]

=== Ejecución del _pipeline_ <orden-ejecucion>

Los _notebooks_ deben ejecutarse siguiendo el mismo orden que las capas descritas en la #link(<arquitectura>)[*Arquitectura general*]. 

En la tabla #ref(<tab-48>) se indica el orden de ejecución.

#figure(
  align(center)[
    #table(
      columns: (auto, 1fr),
      align: (center + horizon, left),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header([*Orden*], 
        table.cell(align: center)[*Fase*]),
      [*1*], [Ingesta de datos locales y remotos (GEE, CDS, DEM).\ Genera los _datasets_ intermedios de la #link(<capa-ingesta>)[*Capa de ingesta*] (véase #link(<preparacion-de-datos>)[*Anexo III*]).],
      [*2*], [Procesamiento y armonización de datos.\ Genera `clean.csv`, `imputation_flags.csv`, `scaler.pkl`, `label_encoders.pkl`.],
      [*3*], [Partición de datos.\ Genera `train.csv`, `test.csv`, `eval.csv` #link(<capa-modelado>)[*Capa de modelado predictivo*].],
      [*4*], [Desarrollo y entrenamiento de los modelos (véase #link(<modelos-empleados>)[*Anexo II*]).\ Genera los ficheros `.pkl` con cada modelo entrenado.],
      [*5*], [Evaluación de modelos, _notebooks_ `comparador_modelos` y `comparador_clasificacion` (véase #link(<elementos-auxiliares>)[*Anexo IV*]).],
    )
  ],
  caption: [Orden de ejecución del _pipeline_ principal.]
)<tab-48>


Para automatizar la ejecución de varios _notebooks_ de una misma rama sin tener que lanzarlos uno a uno, puede emplearse el #link(<autom-notebooks>)[*Script de automatización de _notebooks_*] localizado en el #link(<elementos-auxiliares>)[*Anexo IV*] o en los archivos de código proporcionados junto a esta memoria.

```bash
# Ejecuta todos los notebooks del directorio actual, en orden alfabético
python ejecutar_pruebas.py

# Ejecuta solo los notebooks indicados, en el orden dado
python ejecutar_pruebas.py 01_ingesta.ipynb 02_procesamiento.ipynb 03_particion.ipynb
```

#rect[
  *Recordatorio:* antes de lanzar `ejecutar_pruebas.py` (o cualquier automatización que ejecute los notebooks de la Capa de ingesta), autentica GEE manualmente con `earthengine authenticate --auth_mode=notebook` siguiendo lo indicado en el #link(<credenciales-externas>)[*Google Earth Engine (GEE)*]. De lo contrario, la ejecución automática puede quedarse bloqueada o fallar al intentar abrir el navegador.
]

Para reproducir varias ramas de forma encadenada (por ejemplo, todas las pruebas de eliminación de variables del #link(<pruebas-llevadas-a-cabo>)[*Anexo V*]), puede adaptarse el #link(<autom-general>)[*Script de automatización general*], sustituyendo el contenido del array `ramas` por las ramas que se quieran reproducir.

=== Verificación de la instalación <verificacion-instalacion>

Antes de lanzar el _pipeline_ completo, conviene comprobar que el entorno está correctamente configurado:

```bash
python -c "import pandas, numpy, sklearn, xgboost, torch, shap; print('Librerías OK')"
python -c "import cdsapi; cdsapi.Client(); print('CDS OK')"
```

Para GEE, la comprobación debe hacerse desde una celda de notebook (o desde una sesión interactiva de Python), no con `python -c` en una sola línea, ya que `ee.Authenticate()` necesita abrir el navegador de forma interactiva la primera vez:

```python
import ee

ee.Authenticate()  # solo la primera vez. Si ya se autenticó antes, se puede omitir esta línea
ee.Initialize(project="<id-del-proyecto-en-GCloud>")
print(ee.String("GEE OK").getInfo())
```

=== Solución de problemas <solucion-problemas>

Si alguno de los pasos anteriores falla, revisa primero la sección correspondiente de este anexo antes de continuar con la ejecución de los notebooks. 

En la #ref(<tab-49>) se muestran los errores más comunes y en qué sección se tiene que consultar para resolverlo.

#figure(
  align(center)[
    #table(
      columns: (auto, 1fr),
      align: (left + horizon, left+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header([*Síntoma*], [*Dónde revisar*]),
      [*Fallo al importar librerías \ (`pandas`, `torch`, `xgboost`...)*], [#link(<configuracion-entorno>)[*Configuración del entorno Python*]],
      [*Fallo de `cdsapi.Client()` o\ error de credenciales de CDS.*], [#link(<credenciales-externas>)[*Copernicus CDS*]],
      [*`ee.Authenticate()` no abre el\ navegador o se queda colgado al\ ejecutarse.*], [#link(<credenciales-externas>)[*Google Earth Engine*], apartado "Problema conocido: bloqueo de la autenticación de GEE".  Solución rápida: `earthengine authenticate --auth_mode=notebook` una sola vez, antes de automatizar.],
      [*Rutas de datos no encontradas al\ ejecutar los notebooks de ingesta*], [#link(<datos-base>)[*Obtención y ubicación de los datos base*]],
    )
  ],
  caption: [Errores comunes y zona de consulta.],
  kind: table 
)<tab-49>

#colbreak()

=== Hardware recomendado <hardware-recomendado>

En la #ref(<tab-50>) se muestran las recomendaciones de hardware a tener en cuenta dependiendo de los modelos que se vayan a ejecutar.

#figure(
  align(center)[
    #table(
      columns: (auto, 1fr),
      align: (center + horizon, left+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Modelo*],
        table.cell(align: center)[*Requisito*]),
        [*Ridge \ Random Forest\ RegressorChain*], [CPU estándar, no requieren GPU, al no tener soporte para CUDA en la librería de `scikit-learn`.],
        [*XGBoost \ MLP (multisalida y custom loss)*], [Se recomienda GPU con soporte CUDA para acelerar el entrenamiento. \ En caso de no tener GPU dedicada se pueden ejecutar con CPU estándar, tardando más tiempo.],
    )
  ],
  caption:[Hardware recomendado.],
  kind: table
)<tab-50>

=== Limitaciones de la reproducibilidad <limitaciones-reproducibilidad>

- *Los datos de SOB4ES son de acceso restringido* (véase la nota al inicio de este anexo). Sin ellos, solo puede reproducirse la parte del _pipeline_ que depende de fuentes públicas.
  - En caso de querer comprobar la completa reproducibilidad con los datos, estos se deben de solicitar al *tutor de este TFG* (`Javier Rodeiro Iglesias`).
- Las capas remotas de GEE y Copernicus pueden actualizarse o reprocesarse con el tiempo (nuevas versiones de los productos Sentinel-2, revisiones del reanálisis ERA5, etc.), por lo que una nueva extracción en una fecha distinta a la original podría no devolver exactamente los mismos valores, aunque se usen las mismas coordenadas y el mismo rango temporal.
