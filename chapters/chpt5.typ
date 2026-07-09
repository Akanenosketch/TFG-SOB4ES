= Arquitectura <arquitectura>
Para proporcionar una respuesta a los objetivos planteados y permitir la predicción de la biodiversidad del suelo a partir de variables ambientales, se ha diseñado una arquitectura de software basada en un flujo de datos modular y desacoplado, permitiendo de esta forma que cualquier cambio en alguna de las capas no provoque tener que realizar cambios en el resto de las capas.

El uso de este enfoque garantiza la reproducibilidad del sistema ante la posibilidad de incluir nuevas fuentes de datos o nuevos algoritmos de aprendizaje automático.

La arquitectura explicada previamente se compone de cuatro capas, las cuales transforman los datos brutos en uno o varios modelos predictivos para su futura evaluación y comprobación. Dicha estructura de capas se puede ver en el siguiente diagrama.

#figure(
  image("../diagramas/arquitectura.png"), 
  caption:[Arquitectura de software del proyecto],
  kind: auto
)

  #colbreak()

== Capa de ingesta de datos <capa-ingesta>

Esta capa se encarga de la adquisición de datos con las diferentes APIs a emplear, como también cargar los diferentes archivos de los datasets que se tengan en local. \
La adquisición de datos se realiza en dos fases, las cuales están basadas en el origen de los datos que se van a recolectar:
+ *Ingesta de datos locales:*
  - Se hace la lectura de los datos locales recolectados por el grupo europeo SOB4ES, como otras fuentes de datos Europeas almacenados en local, los cuales contienen las capas raster de la ESDAC, CORINE Land Cover, entre otras fuentes de datos que nos proporcionan información fisicoquímica de las zonas en las que se hicieron las diferentes pruebas.
+ *Ingesta de datos remotos (APIs):*
  - Se implementa mediante el uso de APIs para obtener otros datos no recogidos dentro de los datos locales como viene siendo datos climatológicos y otros de interés como la inclinación del terreno.
  - Para ello se hacen uso de los siguientes servicios:
    + *Google Earth Engine (GEE):* A través del módulo earthengine-api de python, para la extracción automatizada de datos como las imágenes satelitales de Sentinel-2 usadas para el cálculo de índices de vegetación y medias de temperatura y humedad.[4]
    + *Copernicus Climate Data Store (CDS):* Mediante el módulo cdsapi de python para la descarga de datos de reanálisis climático, en los que se incluyen datos sobre las precipitaciones mensuales acumuladas.[5]
    + *Copernicus DEM (vía AWS):* Descarga del DEM (Digital Elevation Model), empleado para la obtención de altitudes, pendientes y orientaciones del terreno.[]
Además de las fases de la adquisición de datos, destacamos las siguientes librerías empleadas para ello:
- *pandas:* Librería empleada para la manipulación e ingeniería de datos tabulares. Permite la lectura y la escritura de archivos .csv y .xlsx (excel). También puede gestionar uniones, filtrados y operaciones vectorizadas sobre múltiples filas de forma no muy compleja y eficaz.
- *earthengine-api:* Librería de desarrollo oficial de Google que permite la conexión remota, la autenticación y la orquestación de scripts de procesamiento geoespacial sobre la API de Google Earth Engine.
- *cdsapi:* Librería que habilita un enlace directo y oficial a la API de CCDS, para el envío de solicitudes de extracción de datos parametrizadas y para la descarga automática de los datos meteorológicos solicitados.

Al final de todo el procesamiento de esta capa se crea un archivo requirements.txt cuyo objetivo es almacenar todas las librerías necesarias para que lo realizado pueda ser reproducible.

*Nota:* A la hora de realizar la ingesta de datos remotos, tomamos como referencia las coordenadas obtenidas a través de la ingesta de datos locales. Esto permite la obtención de los datos necesarios de forma eficiente y evitar obtener datos innecesarios o crear muchos más datos faltantes.

  #colbreak()

== Capa de procesamiento de datos <capa-procesamiento>

Esta capa tiene como objetivo unificar las diferentes fuentes de datos bajo un marco de coordenadas común y resolver las diferentes discrepancias entre los datos, estandarizándolos y armonizándolos para poder emplearlos en futuras capas.\
Este proceso se hace dividiéndolo en tres subprocesos o fases:
+ *Procesado de datos de ficheros:* En este subproceso nos centramos en los datos que se tienen ya tanto del proyecto SOB4ES, como de otros datasets ya existentes, tanto a nivel UVIGO, como a nivel europeo.\ 
  Este procesamiento de datos da como resultado varios elementos, que será usado en el tercer subproceso. Dichos elementos son los siguientes:
  + *Datasets:*
      - *model_ready.csv:* Dataset optimizado ya para su uso e introducción en los diferentes modelos que se desarrollen a futuro.
      - *clean.csv:* Dataset intermedio con todos los datos limpios, empleado en las siguientes fases del procesamiento de datos como referencia y para la armonización de sus datos con los datos obtenidos por consultas remotas a bases de datos en la red.
      - *imputation_flags.csv:* Dataset que contiene únicamente flags que indican en qué celdas faltan datos de cada tipo de dato introducido en clean.csv.
  + *scaler.pkl:* Archivo pickle que guarda la media y la desviación estándar calculadas en la preparación de los datos y usadas para la normalización de cualquier otro dato nuevo de forma idéntica a como se normalizaron los datos originales.
  + *label_encoders.pkl:* Archivo pickle que guarda el mapeo de categorías a números aprendido durante la preparación de datos, para codificar de la misma forma cualquier otro dato nuevo.
+ *Procesado de datos de consultas remotas a bases de datos:* En este subproceso nos centramos en los datos obtenidos a partir de la realización de solicitudes en remoto para obtener datasets o datos provenientes de los diferentes servicios web que se emplean dentro de este trabajo.\ 
  Como consecuencia, este procesamiento de datos da como resultado un segundo dataset y un scaler.pkl intermedios con todos los datos relevantes obtenidos de datasets online, que será usado en el tercer subproceso.
+ *Combinación y armonización de ambas fuentes:* En este último subproceso, hacemos uso de los datasets intermedios comentados previamente para combinarlos y armonizar sus datos.\
  Como resultado de este último subproceso, obtendremos un dataset final con todos los datos preparados para ser usados en los diferentes modelos que se desarrollen en la siguiente capa.
Además de los subprocesos, a lo largo de procesamiento de esta datos se hace uso de las siguientes librerías:
- *pandas:* véase el punto anterior.
- *numpy:* Librería especializada en computación numérica que es generalmente empleada para el manejo de datos numéricos complejos, así como para dar soporte matemático a otras librerías como pandas.
- *rasterio:* Herramienta geoespacial destinada a la lectura de archivos matriciales con formato GeoTIFF, procedentes de las diferentes fuentes de datos europeas. También sirven para la realización de consultas directamente a las URLs correspondientes al DEM de Copernicus.
- *xarray:* Librería diseñada para la manipulación de conjuntos de datos multidimensionales, los cuales se encuentran distribuidos en múltiples archivos .nc (NetCDF). 
- *dbfread:* Librería ligera de bajo nivel capaz de leer de forma nativa y eficiente archivos con formato .bdf, facilitando la extracción de la información tabular contenida en ciertos conjuntos de datos vectoriales del catálogo europeo.
- *netCDF4:* Librería que permite la lectura, escritura y manipulación de archivos con formatos netCDF y HDF5. 

== Capa de modelado predictivo <capa-modelado>

El objetivo principal de esta capa es el desarrollo de los diferentes modelos predictivos como también la preparación de los sets de aprendizaje y pruebas y su consecuente entrenamiento.\
Antes de comenzar a trabajar en esta capa es recomendable tener el dataset con los datos finales preparado y armonizado para que el proceso pueda, de esta forma, ser mucho más lineal y sencillo de seguir. 

Esta capa y la siguiente, van a estar comunicadas entre sí debido a que el feedback que se reciba de la *Capa de evaluación de modelos* va a ser usada para mejorar los modelos que se desarrollen en esta capa. De esta forma se pueden obtener múltiples modelos predictivos de mayor calidad, el cual es el quinto sub objetivo de este trabajo de fin de grado.

De la misma forma que las capas anteriores, esta capa va a estar dividida en varias fases o subprocesos:
+ *Fase de partición de datos:* Esta fase consiste en coger el dataset final con los datos ya normalizados y armonizarlos y dividirlos en tres sets de menor tamaño para emplearlos cada uno para una de las siguientes funciones.
  + *Set de Entrenamiento:* Conjunto inicial, el cual será empleado para que los modelos que se desarrollen aprendan los patrones que haya ocultos entre los datos mediante el ajuste de los parámetros de los modelos.
  + *Set de Validación:* Conjunto usado para el ajuste de los hiperparámetros de los modelos y seleccionar cuáles funcionan mejor de forma objetiva sin contaminar en proceso. En esta parte también se hará uso del feedback obtenido de la Capa de evaluación de modelos.
  + *Set para la evaluación:* Conjunto de datos no empleados en ninguno de los sets mencionados previamente, su uso es para evaluar la eficacia del modelo en condiciones reales y con datos con los cuales nunca ha trabajo.
  La división de los datos se ha hecho teniendo en cuenta el origen de las muestras tomadas y a partir de la realización de esta fase obtenemos los datasets indicados en la siguiente tabla:

  #figure(
    align(center)[
      #table(columns: (3), align: (center,center,center), 
      table.header(
        table.cell(align: center)[*Nombre CSV*], [*Porcentaje de datos*], [*Nº de entradas*]),  
      table.cell(align: center)[*train.csv*], 
        table.cell(align: center)[70%],
        table.cell(align: center)[299], 
      table.cell(align: center)[*test.csv*], 
        table.cell(align: center)[15%],
        table.cell(align: center)[64], 
      table.cell(align: center)[*eval.csv*], 
        table.cell(align: center)[15%],
        table.cell(align: center)[65], 
      )],
      caption: [Tabla de los datasets resultantes de la fase 1],
      kind: table,
  )

+ *Fase de investigación de posibles modelos predictivos:* El objetivo de esta fase es tener una lista de modelos predictivos que se puedan desarrollar y emplear teniendo en cuenta los requisitos de este trabajo, como también condicionantes como el formato de datos y el número de estos mismos.\
  También en esta fase, además del listado de modelos predictivos a desarrollar, se elaborará un listado de parámetros a utilizar como variables para que el modelo tenga ya cierta calidad a la hora de hacer el primer aprendizaje y evaluación.
+ *Fase de configuración del entorno:* El objetivo de esta fase es tener el entorno con las librerías y todos los componentes necesarios para poder ejecutar sin problemas los diferentes modelos que se desarrollen a lo largo de la siguiente fase.\ 
  El resultado de esta fase es una versión actualizada del archivo requirements.txt con todas las librerías empleadas en esta capa.
  #colbreak()
+ *Fase de desarrollo de modelos:* El objetivo de esta fase es tener un par de modelos desarrollados y contenidos dentro de múltiples jupyter notebooks para poder así, de esa forma, se pueden efectuar dentro de un entorno cerrado y seguro, además de poder ser subidos y ejecutados online en plataformas como Google Collab.\
  El resultado de esta fase son múltiples notebooks con cada uno de los modelos desarrollados para su futuro entrenamiento.
+ *Fase de entrenamiento de los modelos:* El objetivo de esta fase es una vez creados los diferentes modelos a emplear, estos serán ejecutados uno a uno y serán entrenados para, posteriormente evaluarlos y realizar las correcciones correspondientes.\
  El resultado de la fase es múltiples archivos *.pkl* con todos los modelos entrenados para su futuro uso.
A lo largo del desarrollo de esta capa, se hacen uso de las siguientes librerías:
- *sklearn/scikit-learn:* Librería principalmente creada para machine learning y para análisis de datos. Dentro de la propia librería hacemos uso de las funciones/submódulos que se muestran en la siguiente tabla:

  #figure(
    align(center)[
      #table(columns: (30%,70%), align: (center,center), 
      table.header(
        table.cell(align: center)[*Submódulo*], [*Descripción*]),  
      table.cell(align: center)[*linear_model.Ridge*], 
        table.cell(align: left)[Implementa la regresión lineal con regularización L2, siendo este el algoritmo base para Ridge Regression.],
      table.cell(align: center)[*ensemble.RandonForest*], 
        table.cell(align: left)[Implementación del algoritmo de Random Forest para regresión.],
      table.cell(align: center)[*multioutput. RegressorChain*], 
        table.cell(align: left)[Permite envolver un modelo base (en nuestro caso Random Forest) para, durante el entrenamiento, replicar el modelo base una vez por cada target. De esta forma se pueden encadenar las predicciones de los targets anteriores como entrada adicional para poder predecir los siguientes valores.],
      table.cell(align: center)[*model_selection.\ RandomizedSearchCV*], 
        table.cell(align: left)[Realiza la búsqueda de hiperparámetros, probando todas las posibles combinaciones del grid de parámetros establecido por el usuario/desarrollador. Se escoge el mejor set de hiperparámetros haciendo uso de la validación cruzada (CV).],
      table.cell(align: center)[*model_selection.\ cross_validate*], 
        table.cell(align: left)[Ejecuta la validación cruzada repetida para medir la robustez del modelo y poder detectar sobreajustes.],
      table.cell(align: center)[*model_selection.\ RepeatKFold*], 
        table.cell(align: left)[Permite aplicar la estrategia de partición en pliegues para la validación, obteniendo así lo siguiente:\
          *_x pliegues \* y repeticiones = xy evaluaciones_*
      ],
      table.cell(align: center)[*model_selection.KFold*], 
        table.cell(align: left)[Variante simple de *RepeatKFold*.],
      )],
      caption: [Tabla de submódulos empleados de la librería scikit-learn],
      kind: table,
  )

  #colbreak()

== Capa de evaluación de modelos <capa-evaluacion>