= Marco teórico o práctico

En esta sección se describe el marco teórico y práctico en el que se apoya y fundamenta nuestras conclusiones: la arquitectura del pipeline de datos y modelado, las tecnologías y herramientas de tercero empleadas, como también los fundamentos teóricos que nos permite crear, desarrollar, entender e interpretar los resultados que nos proporcionan los diferentes modelos seleccionados.

== Fundamentos del aprendizaje automático <fundamentos-del-aprendizaje-automatico>

El término de aprendizaje automático, también conocido como Machine Learning (ML) fue acuñado por primera vez por el informático Arthur Samuel[32][31] en 1959, conocido por su trabajo en la implementación de un ajedrez que aprendiera de forma autónoma y por dar soporte y colaborar en lo que hoy se conoce como LaTEX[34]. 

Él acuñó el término de ML por primera vez en el artículo “Some Studies in Machine Learning Using the Game of Checkers” publicado en el IBM Journal of research and development[33], definiéndolo de la siguiente forma: 

 “Machine Learning es el campo de estudio que permite le otorga a las computadoras la capacidad de aprender sin explícitamente programarlo.”

Otro personaje relevante dentro del campo de la inteligencia artificial es Tom Mitchell[35][31], creador del ordenador que es capaz de “leer la mente humana” a partir de imágenes del cerebro humano[36]. Él lo define de una forma más técnica, siendo esta una de las definiciones más citadas dentro de la literatura académica[37], la cual es la siguiente:

“Se dice que un programa de ordenador aprende de una experiencia E con respecto a una tarea T y una media de rendimiento P, si su rendimiento en T, medido por P, mejore con la experiencia E”

Esta definición es la adoptada como referencia en este trabajo, al descomponer con claridad los tres elementos presentes del proyecto:
- *Tarea (T):* predecir los indicadores de biodiversidad del suelo a partir de las diferentes variables ambientales.
- *Experiencia (E):* El conjunto de datos de campo del proyecto SOB4ES, combinado con variables climáticas y geoespaciales de fuentes remotas.
- *Medida de rendimiento (P):* las métricas descritas en [poner zona], la cual se encuentra un poco más adelante en este documento.

Estas dos definiciones se pueden resumir de la siguiente forma:

“El Machine Learning es una rama o subconjunto de la Inteligencia Artificial que se centra en dotar a los algoritmos la capacidad de “aprender”. Este aprendizaje es a partir de la detección de patrones en los datos de entrenamiento para, posteriormente, hacer predicciones o inferencias sobre nuevos datos.”[40]

Esta capacidad de aprender, permite a los modelos de ML realizar predicciones, tomar decisiones y hacer acciones variadas sin que lo tengan estrictamente indicado dentro de su código. También lo permite diferenciarse de los sistemas expertos tradicionales, en los que el conocimiento se codifica explícitamente, y lo acerca a la estadística de la que toma buena parte de su base matemática.

  #colbreak()

=== Tipos de aprendizaje automático <tipos-de-aprendizaje-automatico>

Dentro del aprendizaje automático, existen muchos algoritmos y múltiples formas de aprendizaje en base al tipo de datos o experiencias de las que aprenden. 

Dichas formas de aprendizaje se clasifican en cuatro tipos generales, los cuales se explican a continuación.


==== Aprendizaje supervisado <aprendizaje-supervisado>



==== Aprendizaje no supervisado <aprendizaje-no-supervisado>

==== Aprendizaje semi-supervisado <aprendizaje-semi-supervisado>

==== Aprendizaje por refuerzo <aprendizaje-por-refuerzo>

== Herramientas empleadas <herramientas-empleadas>

=== Lenguaje de programación, control de versiones y librerías <lenguaje-de-programacion-control-de-versiones-y-librerias>

=== Servicios de obtención de datos remotos <servicios-de-obtencion-de-datos-remotos>

=== Programas de redacción y documentación <programas-de-redaccion-y-documentacion>

=== Programas de desarrollo de código <programas-de-desarrollo-de-codigo>

=== Programas de creación de diagramas e ilustraciones <programas-de-creacion-de-diagramas-e-ilustraciones>

  #colbreak()

== Arquitectura general <arquitectura>
Para proporcionar una respuesta a los objetivos planteados y permitir la predicción de la biodiversidad del suelo a partir de variables ambientales, se ha diseñado una arquitectura de software basada en un flujo de datos modular y desacoplado, permitiendo de esta forma que cualquier cambio en alguna de las capas no provoque tener que realizar cambios en el resto de las capas.

El uso de este enfoque garantiza la reproducibilidad del sistema ante la posibilidad de incluir nuevas fuentes de datos o nuevos algoritmos de aprendizaje automático.

La arquitectura explicada previamente se compone de cuatro capas, las cuales transforman los datos brutos en uno o varios modelos predictivos para su futura evaluación y comprobación. Dicha estructura de capas se puede ver en el siguiente diagrama.

#figure(
  image("../diagramas/arquitectura.png"), 
  caption:[Arquitectura de software del proyecto],
  kind: auto
)

  #colbreak()

=== Capa de ingesta de datos <capa-ingesta>

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

=== Capa de procesamiento de datos <capa-procesamiento>

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

=== Capa de modelado predictivo <capa-modelado>

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

- *XGBoost:* Librería que implementa algoritmos de ML bajo el framework de Gradient Boosting[]. Su aprendizaje se basa en árboles de decisión potenciados por el framework mencionado previamente.\
  Además de hacer uso de la propia librería destacamos el siguiente submódulo o función:
  - *XGBRegressor:* Implementa el algoritmo de gradient boosting sobre los árboles de decisión. Además, de que permite trabajar con múltiples salidas haciendo uso del argumento `multi_strategy=multi_output_tree`.
  #colbreak()

- *PyTorch:* Librería que se emplea principalmente para actividades de ML, y para la creación de redes neuronales. Actualmente es una de las más empleadas dentro del entorno académico e investigador.\ 
  De esta librería destacamos los siguientes elementos:

  #figure(
    align(center)[
      #table(columns: (30%,70%), align: (center,center), 
      table.header(
        table.cell(align: center)[*Submódulo/Módulo*], [*Descripción*]),  
      table.cell(align: center)[*torch*], 
        table.cell(align: left)[Librería principal de PyTorch, proporcionando los tensores, el cálculo de gradientes (autograd) y el optimizador Adam usado para entrenar a las redes neuronales.],
      table.cell(align: center)[*torch.nn*], 
        table.cell(align: left)[Módulo de torch encargado de la definición y construcción de redes neuronales. En términos de definición se pueden definir las capas, el modo de activación, la regularización y la función de pérdida, entre otros elementos.],
      table.cell(align: center)[*torch.utils.data.\ DataLoader*], 
        table.cell(align: left, rowspan: 2)[Se encargan de gestionar la división del conjunto de entrenamiento en lotes de trabajo (batches) y su iteración aleatoria durante cada período de entrenamiento.],
      table.cell(align: center)[*torch.utils.data.\ TensorDataset*], 
      )],
      caption: [Tabla de submódulos empleados de la librería PyTorch],
      kind: table,
  )

- *joblib:* Librería que permite la serialización de las funciones como también la computación paralela. Esto es de gran utilidad a la hora de entrenar y trabajar con los diferentes modelos, especialmente para manejar la concurrencia y la persistencia de los modelos creados haciendo uso de scikit-learn y XGBoost.

  #colbreak()
=== Capa de evaluación de modelos <capa-evaluacion>

El objetivo principal de esta capa final es evaluar los diferentes modelos desarrollados en la Capa de modelado predictivo y a partir de las evaluaciones realizadas, hacer las siguientes acciones:\
+ Escoger los modelos que presentan una mayor utilidad y funcionalidad para el proyecto.
+ Mejorar los modelos escogidos en múltiples iteraciones.
Una vez más, de forma similar a las capas anteriores, esta capa se divide en las siguientes fases:
+ *Fase de validación individual:* Durante el desarrollo de los modelos, en cada notebook se han integrado varias celdas que tienen como objetivo realizar la validación cruzada para cada modelo antes de generar todos los modelos resultantes.\
  Esto se realiza para comprobar ya en la construcción de los modelos si los parámetros escogidos son los más efectivos o si estos, por otro lado, están provocando un sobreajuste en el modelo. También permite prevenir la fuga de datos originado por un entrenamiento deficiente o mal preparado.

  De esta fase se obtienen datos que figuran en los outputs de los notebooks de cada uno de los modelos diseñados, además de los modelos resultantes que serán usados en la siguiente fase.

+ *Fase de validación en conjunto de los modelos generados:* Para el correcto desarrollo de esta fase se van a crear dos notebooks más que se van a encargar de realizar la evaluación y validación de los modelos con dos puntos de vista distinto, los cuales son los siguientes:
  + *Punto de vista numérico:* En este notebook nos centramos en cargar todos los modelos desarrollados y evaluar el rendimiento de cada uno de los modelos contra el dataset creado para las pruebas.\
    Dentro de este punto de vista nos centramos en las siguientes métricas, cuyas definiciones se pueden encontrar en el [INSERTAR ANEXO]:
    - *R2 global.*
    - *R2 por target.*
    - *RMSE.*
    - *MAE.*
    A partir de la ejecución del notebook se podrán ver los resultados de las pruebas tanto en las celdas de salida del notebook, como en los archivos de resultado que se exportan en la última fase de ejecución. Estos archivos contienen los resultados de la comparación entre modelos y el R2 por cada target de todos los modelos probados.
  + *Punto de vista discreto:* En este notebook sigue una metodología similar de realización de pruebas en comparación con el notebook anterior, pero para este se realiza una clasificación para poder ver los resultados, no tanto como números, sino como aciertos y fallos.\ 
    Dentro de este punto de vista nos podemos centrar en otras métricas, cuyas definiciones también se pueden encontrar en el [INSERTAR ANEXO]:
      - *Matrices de confusión.*
      - *Kappa de Cohen.*
      - *F1-macro.*
+ *Análisis de resultados y aplicación de mejoras:* El objetivo principal de esta fase es analizar los resultados obtenidos en la fase anterior, en la primera vuelta escoger los modelos que presentan el mejor funcionamiento y, a partir de la segunda vuelta, aplicar mejoras para intentar mejorar aún más el rendimiento.
  
  Esta fase no requiere de desarrollo de código, es únicamente ver los resultados obtenidos, analizarlos y mejorarlos en la medida de lo posible en base a las capacidades y limitaciones que se tienen.

A lo largo del desarrollo de esta capa, se hacen uso de las siguientes librerías:
- *scikit-learn:* véase definición anterior. Para esta capa hacemos uso de los siguientes submódulos de scikit-learn:

  #figure(
    align(center)[
      #table(columns: (30%,70%), align: (center,center), 
      table.header(
        table.cell(align: center)[*Submódulo*], [*Descripción*]),  
      table.cell(align: center)[*metrics.r2_score*], 
        table.cell(align: left)[Calcula el coeficiente de determinación R2, la métrica principal para medir qué proporción de la varianza real da explicado el modelo.],
      table.cell(align: center)[*metrics.\ mean_squared_error*], 
        table.cell(align: left)[Calcula el error cuadrático medio, empleado para medir el error de predicción penalizando más de esa forma los errores grandes.],
      table.cell(align: center)[*metric.\ mean_absolute_error*], 
        table.cell(align: left)[Calcula el error absoluto medio (MAE).],
      table.cell(align: center)[*inspection.\ permuttion_importance*], 
        table.cell(align: left)[Mide la importancia de cada variable predictora mediante el barajeo de sus valores y observando en cuánto cae el rendimiento del modelo. Se emplea en los modelos los cuales presentan compatibilidad son SHAP (modelos que no son de árbol) y también para complementar a SHAP.],
      table.cell(align: center)[*base.BaseEstimator*], 
        table.cell(align: left, rowspan: 2)[Clases empleadas para envolver un modelo creado con PyTorch en una interfaz compatible con scikit-learn. Es necesario para poder hacer uso de permutation_importance sobre redes neuronales (son incompatibles de base).],
      table.cell(align: center)[*base.RegressorMixin*], 
      )],
      caption: [Tabla de submódulos empleados de la librería scikit-learn (para evaluación)],
      kind: table,
  )

  También se hacen uso de los submódulos RepeatedKFold y cross_validate, los cuales ya se han explicado en la parte de librerías empleadas de la Capa de modelado predictivo.

- *SHAP:* Librería que calcula los valores shapley haciendo uso de TreeExplainer para determinar la contribución exacta de cada variable a cada predicción realizada. Esto nos permite ver de forma gráfica cómo funciona el modelo y también ver cuánto impacto tiene cada una de las variables en los diferentes targets establecidos.
- *matplotlib:* Librería creada para la generación de visualizaciones de diferentes tipos en Python, permitiendo mostrar datos de forma gráfica y crear ilustraciones gráficas complejas de forma intuitiva y sencilla. También funciona como motor subyacente para otras librerías como shap y seaborn.
- *seaborn:* Librería basada en matplotlib, permitiendo la creación de gráficas de datos con una interfaz de mayor nivel en comparación con matplotlib y está integrado de forma más cercana con otras librerías empleadas en este trabajo como pandas. 

== Modelos de aprendizaje automático empleados <modelos-de-aprendizaje-automatico-empleados>

=== Regresión Ridge <regresion-ridge>

=== Random Forest <random-forest>

==== Random Forest multisalida <random-forest-multisalida>

=== XGBoost <xgboost>

==== XGBoost multisalida <xgboost-multisalida>

=== Redes neuronales <redes-neuronales>

==== MLP multisalida <mlp-multisalida>

==== MLP con función de pérdida personalizada <mlp-con-funcion-de-perdida-personalizada>

=== Comparativa de modelos <comparativa-de-modelos>

== Selección de variables <seleccion-de-variables>

=== Métodos de filtrado <metodos-de-filtrado>

=== Métodos de envoltura <metodos-de-envoltura>

=== Métodos de embebido <metodos-de-embebido>