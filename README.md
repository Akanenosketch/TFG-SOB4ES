# TFG-SOB4ES

Predicción de indicadores de biodiversidad del suelo mediante aprendizaje automático, dentro del proyecto europeo **SOB4ES** (*Integrating SOil Biodiversity to Ecosystem Services*).

Este repositorio recoge el código, los _notebooks_ y los resultados de este Trabajo de Fin de Grado, desarrollado sobre los datos del proyecto SOB4ES. La memoria completa (con todo el detalle metodológico, los resultados y los anexos) está en la rama de documentación de este repositorio.


## Descripción del proyecto

El suelo alberga aproximadamente el 59% de la biodiversidad del planeta, pero medirla de forma directa es costoso, lento y metodológicamente distinto según el grupo de especies que se estudie. 

Este TFG explora hasta qué punto los modelos de aprendizaje automático supervisado pueden aproximar indicadores de biodiversidad del suelo (índices de Shannon y riqueza de especies) a partir de variables ambientales más baratas y fáciles de escalar: 
- Propiedades físico-químicas del suelo medidas en campo.
- Variables climáticas y de teledetección (Google Earth Engine, Copernicus).
- Capas de referencia europeas (ESDAC/CORINE).

Se parte de las mediciones de campo del proyecto SOB4ES sobre más de 400 puntos geográficos europeos y se combina con fuentes remotas de acceso abierto, para evaluar si los datos _in situ_ de alta calidad siguen aportando ventaja frente a los derivados únicamente de fuentes satelitales y de reanálisis.

### Objetivo general

Desarrollar, entrenar y evaluar modelos de aprendizaje automático capaces de aproximar valores de biodiversidad del suelo para nuevos puntos geográficos, a partir de sus propiedades físicas, químicas y ambientales.

### Objetivos específicos

1. Integrar los datos del proyecto SOB4ES con fuentes climáticas, satelitales y edafológicas externas (Google Earth Engine, Copernicus).
2. Preparar y armonizar los datos mediante un proceso reproducible de limpieza y normalización.
3. Seleccionar y justificar metodológicamente las técnicas de análisis y ML más adecuadas al problema (tamaño muestral reducido, _targets_ correlacionados, fuentes heterogéneas).
4. Entrenar, comparar y evaluar distintos algoritmos supervisados para aislar la solución más precisa, robusta y generalizable.
5. Garantizar el rigor metodológico y la reproducibilidad mediante CRISP-ML(Q).


## Metodología

Se ha seguido **CRISP-ML(Q)** (*Cross-Industry Standard Process for Machine Learning with Quality Assurance*), combinada con un enfoque del paradigma de **desarrollo iterativo incremental**: se dividió el trabajo en iteraciones cortas con un resultado evaluable (un modelo entrenado + sus métricas) en lugar de dejar cualquier entrega tangible para el final del proyecto.

Las seis fases de CRISP-ML(Q) que se aplican son:

1. Comprensión del negocio y de los datos
2. Preparación de los datos
3. Ingeniería del modelo
4. Evaluación del modelo
5. Despliegue
6. Monitoreo y mantenimiento


## Arquitectura

Se organizó el _pipeline_ en cuatro capas desacopladas:

| Capa | Función |
|---|---|
| **Ingesta de datos** | Carga de ficheros locales del proyecto SOB4ES y de fuentes europeas, más ingesta remota vía APIs (Google Earth Engine, Copernicus CDS, Copernicus DEM). |
| **Procesamiento de datos** | Limpieza, normalización, armonización y combinación de las fuentes locales y remotas en un _dataset_ final consistente. |
| **Modelado predictivo** | Partición de datos (train/test/eval), investigación de modelos candidatos, y entrenamiento de los 8 modelos del _pipeline_. |
| **Evaluación de modelos** | Validación individual y en conjunto (numérica y de clasificación), explicabilidad (SHAP) y aplicación de mejoras. |

### Datasets resultantes

| Fichero | Filas | % del total |
|---|---|---|
| `train.csv` | 299 | 69.9% |
| `test.csv` | 64 | 15.0% |
| `eval.csv` | 65 | 15.2% |

- **34 variables predictoras** (`FEATURES_AUTORIZADAS`): cobertura y estructura del suelo, química y metales, clima/teledetección (GEE), topografía (DEM) y capas europeas de referencia (EU).
- **21 _targets_** (`TARGETS`): índices de Shannon y de riqueza de especies para 11 grupos taxonómicos del suelo (nematodos, macrofauna, lombrices, oribátidos, mesofauna, colémbolos, bacterias, hongos, eucariotas, oomicetos y cercozoos).
- **_Targets_ prioritarios**: `earthworm_shannon_z` y `earthworm_richness_z` (lombrices de tierra).


## Modelos entrenados

Se entrenaron y compararon 8 modelos bajo un mismo marco de validación cruzada repetida:

| Modelo | Tipo |
|---|---|
| Ridge | Lineal regularizado (_baseline_) |
| Random Forest | Ensamblado de árboles, salida única |
| Random Forest multisalida | Ensamblado de árboles, salida múltiple nativa |
| XGBoost | _Gradient boosting_, salida única |
| XGBoost multisalida | _Gradient boosting_, `multi_output_tree` |
| RegressorChain | Cadena de modelos base (_Random Forest_), _Ensemble of Chains_ |
| MLP multisalida | Red neuronal (PyTorch), pérdida MSE estándar |
| MLP con pérdida personalizada | Red neuronal con penalización de coherencia de correlaciones entre _targets_ |

### Resultado principal

- **XGBoost multisalida** es el que mejor resultado da sobre los dos _targets_ prioritarios (lombrices), algo que confirmo en varias pruebas adicionales (barrido de 491 semillas, eliminación de variables).
- **Random Forest multisalida** es el que mejor $R^2$ agregado obtiene sobre el conjunto completo de 21 _targets_.
- Los **modelos basados en árboles** igualan o superan de forma consistente a las redes neuronales (MLP), en línea con lo que apunta la literatura revisada para conjuntos de datos reducidos.
- El factor que más limita el rendimiento no es el modelo ni las variables, sino la **heterogeneidad de los 21 _targets_** (_negative transfer_): el rendimiento agregado sobre los 21 indicadores es sustancialmente peor que sobre los dos _targets_ prioritarios, en todos los modelos.

Todos los resultados detallados por modelo y por _target_, así como las pruebas adicionales (eliminación de variables, sensibilidad y barrido de `random_state`, ensamblado de predicciones), están documentados en los anexos de la memoria.


## Estructura de ramas

Se hace uso de un esquema de ramas independientes por prueba/modelo, en lugar de acumular todo sobre una única rama principal, por el carácter exploratorio del trabajo:

- **`documentation`**: Documentación completa del TFG (Typst).
- **`data-prep`**: Ingesta y procesamiento de datos.
- **`model-prep`**: Versión base de los modelos.
- **`model-prep-var*`**: Prueba de eliminación de variables (`cu_z`, `ni_z`, `mo_z` y combinaciones).
- **`model-prep-rs*`**: Prueba de sensibilidad al `random_state`.
- **`model-prep-rs-group*`**: Barrido amplio de `random_state` (101 y 491 semillas).
- **`model-prep-mixin*`**: Prueba de ensamblado de predicciones.

La rama `master` (esta rama) es solo una vista general del proyecto, no tiene un objetivo experimental propio.


## Tecnologías empleadas

- **Lenguaje:** Python, sobre Jupyter Notebook.
- **ML / datos:** scikit-learn, XGBoost, PyTorch, pandas, numpy, joblib.
- **Geoespacial:** rasterio, xarray, dbfread, netCDF4.
- **APIs remotas:** `earthengine-api` (Google Earth Engine), `cdsapi` (Copernicus Climate Data Store), Copernicus DEM (AWS S3).
- **Explicabilidad:** SHAP, permutation importance.
- **Visualización:** matplotlib, seaborn.
- **Documentación:** Typst, Google Docs (borrador).
- **Control de versiones:** Git / GitHub.


## Puesta en marcha rápida

```bash
git clone https://github.com/Akanenosketch/TFG-SOB4ES.git
cd TFG-SOB4ES

# Entorno (opción con uv, recomendado por la instalación de librerías pesadas)
uv venv --python 3.14
source .venv/bin/activate
uv pip install -r requirements.txt
```

Nota: los datos de campo del proyecto SOB4ES no se distribuyen en este repositorio, son de acceso restringido. Para reproducir el _pipeline_ completo hace falta solicitarlos al tutor de este TFG. Sin ellos, solo se pueden reproducir las fases que dependen de fuentes públicas (GEE, Copernicus, ESDAC, CORINE).

La guía completa de configuración, credenciales (GEE/CDS) y orden de ejecución del _pipeline_ está en el anexo de reproducibilidad de la memoria.


## Documentación

La memoria completa del TFG incluye, entre otras cosas:

- Marco teórico de los modelos empleados y de las métricas de evaluación.
- Arquitectura de software detallada por capas.
- Informe EDA completo (Anexo I).
- Ficha de cada modelo con hiperparámetros y resultados por _target_ (Anexo II).
- _Notebooks_ de preparación de datos (Anexo III).
- _Scripts_ y _notebooks_ auxiliares de automatización y comparación (Anexo IV).
- Pruebas adicionales: eliminación de variables, sensibilidad/barrido de semilla, ensamblado de predicciones (Anexo V).
- Distribución de ramas y _notebooks_ (Anexo VI).
- Guía de configuración y reproducibilidad (Anexo VII).


## Autoría

TFG desarrollado en el marco del proyecto europeo SOB4ES, bajo la tutela de Javier Rodeiro Iglesias.