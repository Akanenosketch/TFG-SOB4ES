= Antecedentes y contexto <antecedentes-y-contexto>

El proyecto europeo SOB4ES, en cuyo marco se desarrolla este TFG, surge como respuesta a la necesidad de la Unión Europea de contar con indicadores fiables y de bajo coste sobre la biodiversidad del suelo, en contexto de la Estrategia de Suelos de la UE (_EU Soil Strategy_) #sub([@sob4es2023]). Tradicionalmente, la evaluación de la biodiversidad edáfica se ha basado en muestreos de campo y análisis de laboratorio, que si bien son precisos, presentan las limitaciones ya descritas en la Introducción: coste elevado, falta de estandarización metodológica entre grupos y especies, y dificultad para escalar todo a nivel continental o internacional.

Ante estas limitaciones, en los últimos años se ha extendido el uso de modelos de aprendizaje automático supervisado para estimar indicaciones ambientales y de biodiversidad a partir de variables predictoras de obtención más económica (datos climáticos, satelitales y edafológicos), reduciendo así la dependencia de mediciones directas exhaustivas sobre el terreno.

En un plano más general, la revisión de Wadoux#sub([@wadoux2025]) sitúa este tipo de aplicaciones dentro de un marco disciplinar más amplio: propone una taxonomía de la inteligencia artificial en ciencia del suelo, construida a partir de una clasificación previa de la Comisión Europea y refinada mediante revisión de literatura y consulta a personas expertas, que distingue tres grandes dominios: percepción e interacción, razonamiento y toma de decisiones, y aprendizaje y predicción. Los modelos de aprendizaje supervisado empleados en este TFG se enmarcan dentro de este último dominio, señalado por la propia revisión como el más consolidado entre las aplicaciones actuales de IA a la ciencia del suelo, lo que sitúa este trabajo dentro de una tendencia disciplinar más amplia y no como un caso aislado.

Varios trabajos han abordado directamente el modelado de biodiversidad del suelo haciendo uso del aprendizaje automático, con resultados que nos pueden servir de referencia para contrastar con los resultados obtenidos en este TFG (véase Conclusiones):

+ Salako _et al._#sub([@salakoEarthworms]) emplearon *Random Forest* para modelar la distribución espacial de la riqueza y densidad (ind./m²) de tres grupos ecológicos de lombrices (epigeas, endogeas y anécicas) en Alemania, usando como predictores variables de suelo y clima sobre distintos usos del terreno. 
  
  Encontraron que cada grupo ecológico responde a predictores distintos: las especies epigeas están mayoritariamente condicionadas por el clima en zonas forestales, mientras que las endogeas, el grupo más diverso, dependen sobre todo de la textura del suelo (contenido de arcilla y limo).

+ Phillips et al. #sub([@phillipsEarthwormDiversity]) compilaron el conjunto de datos de revisado de mayor escala sobre lombrices de tierra (6928 puntos de muestreo en 57 países) para predecir riqueza de especies, abundancia y biomasa mediante tres modelos lineales mixtos generalizados (GLMM), uno por cada métrica, a partir de 12 variables ambientales agrupadas en seis temas (suelo, precipitación, temperatura, retención de agua, cobertura del hábitat y otras). 
  
  - A diferencia del resto de estudios de esta lista, no emplean aprendizaje automático en sentido estricto, sino un *modelo estadístico clásico* validado mediante _10-fold cross-validation_. 
  
  - Se incluye en estos antecedentes por ser, con diferencia, el estudio de mayor escala sobre biodiversidad de lombrices de tierra revisado, y porque se compara explícitamente el error de un modelo que combina propiedades de suelo medidas en campo con variables de SoilGrids frente a un modelo que usa únicamente SoilGrids (una capa global derivada, no medida _in situ_). 
  
  - La comparación _in situ_ + remoto vs. solo remoto es la más directamente equiparable, dentro de la literatura revisada, a la que plantea este TFG (SOB4ES + Google Earth Engine/Copernicus). 

  - Encuentran que las variables climáticas resultan más determinantes que las edáficas o la cobertura del hábitat, y que la riqueza y abundancia locales tienden a ser mayores en latitudes altas, lo cual es un patrón inverso al de la biodiversidad aérea. 

+ Un estudio de modelado conjunto multiespecie #sub([@diggingDeeperEarthworms]) entrenó una *red neuronal profunda multi-tarea* para predecir la distribución de 77 especies de lombrices en Francia a partir de variables climáticas, edáficas y de cobertura del terreno, empleando SHAP para identificar los principales factores ambientales. El modelo conjunto alcanzó un TSS $>= 0.7$ y mejoró notablemente las predicciones para especies raras frente a los modelos tradicionales de distribución de especies (basados en una sola especie).

  #colbreak()

+ Un estudio sobre biodiversidad multi-trófica del suelo mediante metabarcoding de ADN ambiental #sub([@limitsPromisesEOFoundationModels]) comparó sistemáticamente *_LightGBM_, _Random Forest_ y una red neuronal (ANN)* para predecir la abundancia relativa de 51 grupos tróficos (bacterias, hongos, protistas, oligoquetos, insectos, colémbolos y otros metazoos), usando cuatro configuraciones de variables predictoras: datos ambientales de baja resolución, datos _in situ_ de alta calidad, _embeddings_ de imágenes satelitales, y una combinación de ambos. 

  _Random Forest_ obtuvo consistentemente el mejor rendimiento, ligeramente por encima de _LightGBM_, y los datos _in situ_ de alta calidad superaron sistemáticamente tanto a los datos de baja resolución como a los derivados de imágenes satelitales. Un resultado directamente relevante para este TFG, que también combina variables _in situ_ (SOB4ES) con variables remotas de menor resolución (Google Earth Engine, Copernicus).

+ Un estudio de predicción del microbioma del suelo #sub([@soilMicrobiomePrediction]) comparó seis modelos de aprendizaje automático clásico (incluyendo _Random Forest_ y _Gradient Boosting_) frente a un modelo de aprendizaje profundo para predecir la frecuencia relativa de comunidades bacterianas y fúngicas a partir de factores ambientales. 

  _Gradient Boosting_ obtuvo el mejor resultado a nivel de filo ($R^2 = 0.57$), y _Random Forest_ y _Gradient Boosting_ empataron como mejores modelos a nivel de grupo funcional ($R^2 = 0.45$); las arquitecturas más sofisticadas de aprendizaje profundo (CNN, _transformers_) obtuvieron resultados peores, atribuido explícitamente al tamaño reducido de los datos de entrenamiento disponibles. Esto es una conclusión especialmente relevante para este TFG, cuyo conjunto de datos (400 muestras) es de un orden de magnitud similar.

En conjunto, estos antecedentes apuntan de forma consistente a que los modelos basados en árboles, como _Random Forest_, _Gradient Boosting_ y _XGBoost_, pueden igualar o hasta superar a los modelos basados en redes neuronales cuando el conjunto de datos es reducido (como suele ocurrir en los datos relacionados con la biodiversidad). Asimismo, apuntan a que los datos _in situ_ de alta calidad siguen siendo, por ahora, más informativos que los derivados exclusivamente de fuentes remotas con resoluciones bajas, conclusión a la que también apunta, desde un modelo estadístico distinto y a una escala mucho mayor, Phillips et al. #sub([@phillipsEarthwormDiversity]). Estas dos hipótesis pueden ser contrastadas empíricamente con los resultados de este TFG.

Este enfoque indirecto no es exclusivo de la biodiversidad del suelo. El uso de variables climáticas, satelitales y edáficas como predictoras de propiedades del ecosistema está ya consolidado en ámbitos afines, de los cuales se resaltan los siguientes:

- *Estimación del carbono orgánico en el suelo:* Tian et al. #sub([@tianSpatiotemporalSOC]) emplean _Random Forest_ y _quantile regression forests_ sobre 45616 observaciones de suelo y variables de teledetección para mapear la densidad de carbono orgánico en toda la Unión Europea a 30 metros de resolución y cuatro intervalos de profundidad, obteniendo un $R^2$ de 0.63 en validación independiente.

- *Clasificación de usos del terreno:* Rodríguez-Galiano et al. #sub([@rodriguezRandomForest]) muestran que _Random Forest_, aplicado sobre imágenes Landsat y un modelo digital del terreno en el sur de España, clasifica 14 categorías de cobertura del suelo con una precisión del 92% y supera de forma significativa a un único árbol de decisión. Esto da un resultado que anticipa, en otro dominio, la ventaja del _bagging_ frente a un modelo individual, que también es un elemento que se discute dentro de este TFG.

- *Predicción del rendimiento agrícola a partir de series temporales de NDVI:* La revisión de Shawon et al. #sub([@shawonCropYield]) sobre 97 estudios publicados entre 2017 y 2024, encuentra que _Random Forest_ y _Gradient Boosting Trees_ están entre los algoritmos más empleados para predecir el rendimiento de los cultivos combinando temperatura, tipo de suelo e índices de vegetación como NDVI. Esta es la misma combinación de datos y la misma familia de algoritmos empleados en este TFG, pero usados para resolver un problema de predicción distinto.

La disponibilidad reciente de catálogos satelitales abiertos de alta resolución y de reanálisis climáticos globales ha reducido significativamente la barrera de entrada para poder aplicar estas técnicas a nuevos problemas ecológicos, entre los cuales se encuentra el que aborda este TFG.

#colbreak()

Frente a estos antecedentes, la aportación diferencial que puede proporcionar este TFG es doble: 

+ Por un lado, la integración de múltiples fuentes de orígenes heterogéneos en un mismo _pipeline_ reproducible y versionado.
+ Por otro lado, la comparación de múltiples algoritmos de aprendizaje supervisado bajo un mismo marco de validación, en lugar de limitarse a un único modelo, lo que permite discutir con evidencia empírica cuál generaliza mejor ante un conjunto de datos comparativamente reducido. 

A esto se suma el hecho de que ni trabajos como el de Phillips et al. #sub([@phillipsEarthwormDiversity]) ni el estudio multitrófico #sub([@limitsPromisesEOFoundationModels]) emplean fuentes de acceso de uso extendido como Google Earth Engine o Copernicus, ni combinan múltiples grupos biológicos del suelo de forma simultánea, como se hace en este TFG, al utilizar los datos del *proyecto SOB4ES* #sub([@sob4es2023]).

Este TFG se sitúa bajo el contexto siguiente: comienza a partir de los datos previamente recolectados por el proyecto SOB4ES en más de 400 puntos geográficos europeos, y los complementa con fuentes de datos remotas de acceso abierto, con el objetivo de evaluar hasta qué punto los modelos de aprendizaje automático supervisado pueden aproximar la biodiversidad del suelo a partir de variables indirectas, relativamente más baratas y escalables que las obtenidas mediante el muestreo directo.