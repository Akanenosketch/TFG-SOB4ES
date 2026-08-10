= Resumen de la solución propuesta <resumen-de-la-solucion-propuesta>

La solución propuesta se basa en un enfoque integral de ciencia de datos, diseñado para abarcar desde la recopilación de múltiples fuentes de información hasta la evaluación de modelos predictivos.

Para estructurar este proceso, se ha adoptado la metodología de desarrollo CRISP-ML(Q)[3], que permitirá definir y realizar el trabajo de manera estructurada. Además de la metodología CRISP-ML(Q), a lo largo del desarrollo de este trabajo se aplicará en conjunto una metodología de desarrollo iterativa incremental [4].

CRISP-ML(Q) (Cross-Industry Standard Process of Machine Learning with Quality Assurance) es el estándar de facto para la gestión del ciclo de vida en proyectos de aprendizaje automático. A diferencia de la ingeniería de software tradicional o la minería de datos clásica (CRISP-DM[23]), el desarrollo de modelos predictivos exige una aproximación principalmente experimental, no lineal e iterativa, además de ser un proyecto en el cual el rendimiento de los modelos puede verse degradado con el tiempo.

Para dotar a este proceso de un marco de ingeniería robusto y estricto, CRISP-ML(Q) organiza el flujo de trabajo en seis fases cíclicas interconectada entre sí, integrando así, de forma transversal, los diversos controles de QA (Quality Assurance) en cada una de las transiciones. 

[Diagrama con las diferentes fases de CRISP-ML(Q)]

En el diagrama anterior, podemos distinguir las siguientes fases:
+ *Comprensión del negocio y de los datos:* Definición del problema predictivo y auditoría inicial de la viabilidad de las fuentes proporcionadas.
+ *Preparación de los datos:* Fase de ingeniería de característica y de datos, limpia, unificación y estandarización de los datos de las fuentes base. Junto también con la obtención de datos externos.
+ *Ingeniería del modelo:* Selección de algoritmos/tipos de modelo, entrenamiento formal, ajuste de hiperparámetros y su consecuente desarrollo de los modelos necesarios.
+ *Evaluación del modelo:* Validación metrológica, es decir con los correspondientes parámetros de evaluación, del rendimiento estadístico frente a datos de control ciegos (nunca empleados en entrenamiento ni en otras pruebas anteriores a la evaluación). 
+ *Despliegue:* Entrega o integración del modelo o pipeline reproducible en el entorno operativo.
+ *Monitoreo y mantenimiento:* Control continuo para mitigar la degradación de las predicciones en el tiempo y aplicar las correspondientes medidas de mantenimiento.

Además, tal como se indica anteriormente con CRISP-ML(Q), al ser incremental, también se aplican técnicas de desarrollo iterativo incremental. 

El *desarrollo iterativo incremental* se basa en la capacidad de poder dividir un proyecto en diversos bloques reducidos y asignarlos a bloques temporales generalmente fijos, los cuales pueden ser adaptados a futuro. Estos bloques reducidos se denominan como *iteraciones*.

De forma más específica las iteraciones se pueden definir como miniproyecto o como un set de tareas en las cuales “*_en todas ellas se repite un proceso de trabajo similar para proporcionar un resultado completo sobre el producto final[9]_*”. Cada iteración tiene como resultado una parte del producto final funcional, el cual se va integrando a lo largo de las iteraciones hasta crear el producto final.

Todos los detalles relacionados con las fases, hitos y los tiempos de realización de todo el proyecto se pueden encontrar en la siguiente sección.

La aplicación de ambas metodologías nos permite lo siguiente:
*1. Adquisición e Integración de Datos:* 
Para alimentar los modelos, no solo se utilizarán los datos propios del proyecto SOB4ES (disponibles en archivos y carpetas como EARTHWORMS_RAW/) , sino que se complementarán y completarán con bases de datos y mapas europeos de resolución variable. 

Las fuentes externas empleadas son las siguientes:

- Bases de datos geoespaciales como la _European Soil Database_ (ESDAC) y _CORINE Land Cover_ para clasificar el tipo de suelo, uso de la tierra, propiedades físicas (arena, arcilla, densidad) y propiedades químicas (pH, metales pesados, carbono orgánico) de las parcelas.
- Uso de APIs como _Google Earth Engine_ (earthengine-api) para extraer medias de temperatura diaria, humedad relativa e índices de vegetación (NDVI).
- Uso de _Copernicus Climate Data Store_ (cdsapi) para registrar precipitaciones mensuales acumuladas y modelos de elevación digital (DEM).

*2. Procesamiento de la Información:* 

El tratamiento masivo de estos datos ambientales se realizará utilizando diversas bibliotecas de Python. 

Se utilizarán pandas, numpy y múltiples otras librerías para la limpieza, manipulación eficiente de variables tabulares y escritura de archivos CSV/XLSX. Para el manejo de datos geoespaciales y archivos multidimensionales provistos por Copernicus y bases europeas, se implementarán herramientas específicas como rasterio, xarray y dbfread.

*3. Modelado y Evaluación: *

Una vez consolidado el conjunto de datos definitivo, la solución final consistirá en el diseño, entrenamiento e implementación de diferentes algoritmos de aprendizaje automático, aplicando en cada uno de los diferentes modelos la metodología explicada previamente y cuyas fases/etapas se encuentran en las secciones de [Planificacion y seguimiento] y Arquitectura.

Estos algoritmos mapearán las complejas relaciones entre las variables ambientales y la biodiversidad del suelo. 

Finalmente, los modelos serán evaluados y comparados métricamente para aislar la solución algorítmica más robusta y generalizable para futuras predicciones geográficas, siguiendo el ciclo de evaluación-mejora descrito en la fase de *Ingeniería del modelo* y *Evaluación del modelo* de CRISP-ML(Q).


