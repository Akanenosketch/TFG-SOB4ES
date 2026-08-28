== Guía de configuración y reproducibilidad \ (Anexo VI)<reproducibilidad-y-configuracion>

Este anexo recoge las instrucciones necesarias para reproducir de principio a fin el pipeline descrito en la #link(<arquitectura>)[*Arquitectura general*]: desde la configuración del entorno y las credenciales de los servicios externos, hasta la ejecución de los notebooks de ingesta, procesamiento, modelado y evaluación. 

El objetivo es que cualquier persona con acceso a los datos originales pueda replicar los resultados de este TFG sin tener que reconstruir el proceso a partir de la memoria o realizar procesamientos similares a los realizados.

#rect[
  *Nota importante sobre los datos:* \  Los datos de campo del proyecto europeo SOB4ES (mediciones de las más de 400 parcelas, carpetas como `EARTHWORMS_RAW/` y el resto de ficheros base descritos en la sección 4) *no se distribuyen junto con el repositorio* ni son de acceso público, al pertenecer a un grupo de investigación propio dentro del marco del proyecto SOB4ES. \ \ Para poder ejecutar este pipeline es imprescindible *solicitar dichos datos directamente al tutor o co-tutor de este TFG*, quien indicará el procedimiento de acceso y las condiciones de uso aplicables.\ \ Sin estos datos, únicamente pueden reproducirse las fases que dependen de fuentes públicas (GEE, Copernicus, ESDAC, CORINE), pero no el pipeline completo.
]

=== Requisitos previos <requisitos-previos>

Antes de clonar el repositorio, es necesario disponer de lo siguiente:

- *Python* `3.14.x`, con `pip` disponible.
- *Git*, para clonar el repositorio y poder cambiar entre las ramas descritas en el #link(<dist-ramas-y-notebooks>)[*Anexo V*].
- *Jupyter* y *nbconvert*, necesarios para ejecutar y automatizar los notebooks (véase #link(<elementos-auxiliares>)[*Anexo III*]).
- Una cuenta de *Google Earth Engine* habilitada para uso no comercial/investigación, necesaria para hacer uso de `earthengine-api`.
- Una cuenta en el *Copernicus Climate Data Store* con un token de acceso personal, necesaria para hacer uso de `cdsapi`.
- Opcionalmente, una *GPU* compatible con PyTorch/CUDA si se quiere reproducir el entrenamiento con CUDA de los modelos compatibles con dicha tecnología (véase #link(<hardware-recomendado>)[*Hardware recomendado*]).

=== Clonar el repositorio <clonar-repo>

```bash
git clone https://github.com/Akanenosketch/TFG-SOB4ES.git
cd TFG-SOB4ES
```

El repositorio sigue la distribución de ramas documentada en el #link(<dist-ramas-y-notebooks>)[*Anexo V*]. Por defecto, tras clonar, se estará situado en la rama principal (`master`), pensada únicamente para tener una vista general del proyecto. 

Para reproducir un experimento concreto, cambia a la rama correspondiente, por ejemplo:

```bash
# Modelos base
git switch model-prep

# Prueba de eliminación de variables (cu_z, ni_z y mo_z a la vez)
git switch model-prep-var-1-2-3

# Prueba de barrido de random_state (primera iteración)
git switch model-prep-rs-group
```

=== Configuración del entorno Python <configuracion-entorno>

Existen dos formas equivalentes de crear el entorno, ahora se van a indicar las dos formas más comunes de hacerlo.

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
uv venv --python [COMPLETAR: versión exacta, p. ej. 3.11]
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

=== Configuración de credenciales de servicios externos <credenciales-externas>

==== Google Earth Engine (GEE)

La forma recomendada de autenticarse es la misma que se usa dentro de los propios notebooks de ingesta, ejecutando estas dos líneas en una celda de Python:

```python
import ee

# abre el navegador para vincular la cuenta de Google (solo hace falta la primera vez)
ee.Authenticate()  

ee.Initialize(project="<id-del-proyecto-en-GCloud>")
```

*`ee.Authenticate()`* guarda un token de credenciales localmente (en `~/.config/earthengine/credentials` en Linux/macOS), de forma que en próximas ejecuciones, incluidas las de los propios notebooks del pipeline, basta con llamar a *`ee.Initialize(project=...)`*, sin repetir *`ee.Authenticate()`*. 

Es *necesario disponer de un proyecto de Google Cloud asociado* (gratuito para investigación no comercial) y su identificador es el que hay que indicar en *`project=`*.

Como alternativa por terminal (equivalente, pero fuera del notebook) existe también el comando `earthengine authenticate`, aunque para este pipeline se recomienda el flujo anterior por ser el mismo que ya usan los notebooks de la #link(<capa-ingesta>)[*Capa de ingesta*].

*Documentación oficial:*
- *Autenticación:* https://developers.google.com/earth-engine/guides/auth
- *Instalación y primeros pasos con la API de Python:* https://developers.google.com/earth-engine/guides/python_install

==== Copernicus Climate Data Store (CDS)

Tras registrarse en el #link("https://cds.climate.copernicus.eu/")[*CDS*] y obtener el *Personal Access Token* desde el perfil creado (https://cds.climate.copernicus.eu/profile), se debe de crear el fichero `~/.cdsapirc` (en Windows, `C:\Users\<usuario>\.cdsapirc`) con el siguiente contenido:

```
url: https://cds.climate.copernicus.eu/api
key: <Personal-Access-Token>
```

La librería `cdsapi` lee este fichero automáticamente al ejecutar cualquier solicitud de descarga, independientemente de que se ejecute desde un notebook o desde un script.

*Documentación oficial:*
- https://cds.climate.copernicus.eu/how-to-api

==== Copernicus DEM (vía AWS S3)

*No requiere autenticación ni registro:* el bucket público de AWS S3 que aloja el DEM (GLO-30) es accesible directamente mediante `rasterio` indicando la URL correspondiente, tal como se describe en la #link(<capa-ingesta>)[*Capa de ingesta de datos*].

*Documentación oficial del dataset:* 
- https://registry.opendata.aws/copernicus-dem/

#colbreak()

=== Obtención y ubicación de los datos base <datos-base>

Una vez recibidos los datos del proyecto SOB4ES por parte del tutor (véase el aviso al inicio de este anexo), colócalos en la estructura de carpetas que esperan los notebooks de ingesta:

```
TFG-SOB4ES/
├── data/
│   ├── raw/
│   │   ├── EARTHWORMS_RAW/
│   │   └── [COMPLETAR: resto de carpetas/ficheros base del proyecto SOB4ES]
│   └── external/
│       └── [COMPLETAR: capas ESDAC/CORINE si se distribuyen aparte]
├── notebooks/
└── ...
```

#rect[
  *Nota:* la estructura exacta de carpetas debe verificarse contra el `.gitignore` del repositorio y contra el primer notebook de la [*Capa de ingesta de datos*](#5.5.1.--capa-de-ingesta-de-datos), ya que las rutas de lectura pueden haberse fijado como rutas relativas concretas durante el desarrollo. `[COMPLETAR: confirmar y ajustar este árbol de carpetas contra el repositorio real antes de la entrega final]`.
]

=== VII.6.- Orden de ejecución del pipeline <orden-ejecucion>

Los notebooks deben ejecutarse siguiendo el mismo orden que las capas descritas en la [*Arquitectura general*](#5.5.--arquitectura-general):

#table(
  columns: (auto, 1fr),
  align: (center + horizon, left),
  stroke: 0.5pt,
  table.header([*Orden*], [*Fase*]),
  [1], [Ingesta de datos locales y remotos (GEE, CDS, DEM) — genera los datasets intermedios de la Capa de ingesta.],
  [2], [Procesamiento y armonización de datos — genera `clean.csv`, `imputation_flags.csv`, `scaler.pkl`, `label_encoders.pkl`.],
  [3], [Partición de datos — genera `train.csv`, `test.csv`, `eval.csv` (sección 5.5.3).],
  [4], [Desarrollo y entrenamiento de los modelos (Anexo III) — genera los ficheros `.pkl` con cada modelo entrenado.],
  [5], [Evaluación de modelos — notebooks `comparador_modelos` y `comparador_clasificacion` (Anexo IV).],
)

Para automatizar la ejecución de varios notebooks de una misma rama sin tener que lanzarlos uno a uno, puede emplearse el #link(<autom-notebooks>)[*Script de automatización de notebooks*] localizado en el #link(<elementos-auxiliares>)[*Anexo III*] o en los archivos de código proporcionados junto a esta memoria:

```bash
# Ejecuta todos los notebooks del directorio actual, en orden alfabético
python ejecutar_pruebas.py

# Ejecuta solo los notebooks indicados, en el orden dado
python ejecutar_pruebas.py 01_ingesta.ipynb 02_procesamiento.ipynb 03_particion.ipynb
```

Para reproducir varias ramas de forma encadenada (por ejemplo, todas las pruebas de eliminación de variables del #link(<pruebas-llevadas-a-cabo>)[*Anexo IV*]), puede adaptarse el #link(<autom-general>)[*Script de automatización general*], sustituyendo el contenido del array `ramas` por las ramas que se quieran reproducir.

=== Hardware recomendado <hardware-recomendado>

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
)

=== Verificación de la instalación <verificacion-instalacion>

Antes de lanzar el pipeline completo, conviene comprobar que el entorno está correctamente configurado:

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

Si alguno de estos comandos falla, revisa primero la sección correspondiente de este anexo (#link(<configuracion-entorno>)[*Configuración del entorno Python*] para librerías, #link(<credenciales-externas>)[*Configuración de credenciales de servicios externos*] para credenciales) antes de continuar con la ejecución de los notebooks.

=== Limitaciones de la reproducibilidad <limitaciones-reproducibilidad>

- *Los datos de SOB4ES son de acceso restringido* (véase la nota al inicio de este anexo). Sin ellos, solo puede reproducirse la parte del pipeline que depende de fuentes públicas.
  - En caso de querer comprobar la completa reproducibilidad con los datos, estos se deben de solicitar al *tutor de este TFG* (`Javier Rodeiro Iglesias`).
- Las capas remotas de GEE y Copernicus pueden actualizarse o reprocesarse con el tiempo (nuevas versiones de los productos Sentinel-2, revisiones del reanálisis ERA5, etc.), por lo que una nueva extracción en una fecha distinta a la original podría no devolver exactamente los mismos valores, aunque se usen las mismas coordenadas y el mismo rango temporal.
