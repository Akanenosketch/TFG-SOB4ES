== Informe EDA (Anexo I) <informe-eda>

En este anexo se presenta el análisis exploratorio de datos (EDA, *Exploratory Data Analysis*) realizado sobre el dataset final obtenido tras la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*], previo al desarrollo de los modelos predictivos descritos en la #link(<capa-modelado>)[*Capa de modelado predictivo*]. 

El objetivo de este análisis es doble: por un lado, caracterizar la calidad y la estructura de los datos disponibles (valores faltantes, distribución de las variables, escalas)y, por otro, justificar empíricamente algunas de las decisiones metodológicas tomadas en la sección de #link(<marco-teorico-o-practico>)[*Marco teórico y práctico*], en particular la normalización de las variables predictoras (véase #link(<regresion-ridge>)[*Regresión Ridge*]) y el uso de modelos robustos frente a la colinealidad (véase #link(<seleccion-de-variables>)[*Selección de variables*]).

Antes de entrenar un modelo predictivo conviene entender qué hay realmente en los datos: cuántas observaciones hay, cómo se distribuyen entre países y usos de suelo, si faltan valores, si hay variables que presentan colinealidad (se mueven juntas), si existen valores atípicos y si las relaciones entre variables predictoras y variables objetivo son lineales o no. 

Estas preguntas requieren calcular estadísticos y visualizar los datos directamente, que es lo que se hace en este anexo. Las conclusiones aquí obtenidas condicionan decisiones concretas del cuerpo principal del TFG, como qué algoritmo de regularización usar (véase #link(<regresion-ridge>)[*Regresión Ridge*]), si tiene sentido un enfoque de modelado multisalida o qué limitaciones de generalización hay que declarar en las conclusiones.

El anexo se organiza en nueve bloques: 
+ Descripción general del dataset. 
+ Distribución geográfica.
+ Variables descartadas de la selección.
+ Valores faltantes e imputación.
  + El indicador de calidad `outlier_flag`. 
+ Análisis univariante variable a variable.
+ Variables por uso de suelo.
+ Valores atípicos.
+ Análisis bivariante y multivariante de correlaciones y consistencia externa. 
+ Conclusiones.

#colbreak()

=== Descripción general del dataset <desc-dataset>

El análisis se ha realizado sobre clean.csv, la versión armonizada y sin escalar del dataset obtenido tras la Capa de procesamiento de datos, de forma que las cifras conserven su interpretación agronómica y ecológica directa antes de la normalización aplicada en la Capa de modelado predictivo.

#figure(
  align(center)[
    #table(
      columns: (35%, 35%),
      align: (left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Característica*],
        table.cell(align: center)[*Valor*],
      ),
      table.cell(align: center)[*Nº total de observaciones \ (parcelas)*],
        table.cell()[428],
      table.cell(align: center)[*Nº de países representados*],
        table.cell()[12],
      table.cell(align: center)[*Nº de variables en el dataset limpio*],
        table.cell()[84],
      table.cell(align: center)[*Nº de variables predictoras finales seleccionads*],
        table.cell()[34 \ (véase #link(<seleccion-de-variables>)[*Selección de variables*])],
      table.cell(align: center)[*Valores nulos detectados en el dataset limpio*],
        table.cell()[0],
      table.cell(align: center)[*Filas con site_id duplicado*],
        table.cell()[0],
    )
  ],
  caption: [Descripción general del dataset.]
)<tab-10>

Comparando directamente el dataset limpio (84 columnas) con el dataset escalado usado en el modelado (71 columnas), los cambios principales que hay entre uno y otro son los siguientes:

- *13 columnas se eliminan por completo al pasar a la versión escalada, por ser identificadores o metadatos categóricos no normalizables:* `country`, `pedoclimatic_region`, `site_locality`, `sampling_date`, `soil_type`, `land_use_type`, `land_use_intensity`, `dominant_vegetation`, `eu_soil_texture_class`, `eu_env_zone`, `eu_land_cover`, `eu_soil_type_wrb`, `eu_uso_suelo_nombre`.
- *4 columnas se conservan sin escalar:* `site_id`, `latitude`, `longitude`, `outlier_flag`.
- *67 columnas numéricas se conservan normalizadas con sufijo `_z`:* variables físico-químicas, tróficas y de biodiversidad, más covariables ambientales `gee_*/dem_*` y capas de referencia `eu_*`.

Es decir, *84 = 13 (descartadas) + 4 (sin escalar) + 67 (normalizadas `_z`)*. 

El conjunto de 67 variables numéricas normalizadas es el universo real desde el que se seleccionan, en una fase posterior de la #link(<seleccion-de-variables>)[*Selección de variables*], las 34 predictoras y 21 targets finales. La diferencia entre 67 y 55 corresponde a variables numéricas descartadas por el proceso de selección de variables (colinealidad, varianza casi nula, etc.), no a identificadores.

De acuerdo con la partición final descrita en la #link(<capa-modelado>)[*Fase de partición de datos*], el conjunto se divide en 299 observaciones de entrenamiento (70%), 64 de test (15%) y 65 de evaluación (15%), sobre el total de 428 parcelas.

Las *variables predictoras* (34) son las *covariables edáficas, ambientales y de teledetección* (pH, textura, elementos traza, temperatura media, NDVI, elevación, etc.) que el modelo recibe como entrada para hacer una predicción. 

Las *variables objetivo* o _*targets*_ (21) son, en su mayoría, los *índices de biodiversidad edáfica* (Shannon, abundancias, riquezas) que el modelo intenta predecir a partir de esas covariables. 

Esta distinción es la que justifica por qué identificadores como `site_id` o `country` no entran en ninguno de los dos grupos: no aportan información edáfica ni son el fenómeno biológico que se quiere predecir, solo sirven para trazabilidad o para particionar los datos de forma estratificada (ver #link(<dist-geo>)[*Distribución geográfica de las muestras*]).

#colbreak()

Dividir los datos en tres subconjuntos (`train/test/eval`), y no en los dos habituales (`train/test`), permite separar dos usos distintos de los datos no vistos por el modelo durante el entrenamiento: 
- El *conjunto de test* (`test.csv`) se puede usar repetidamente mientras se ajustan hiperparámetros o se comparan arquitecturas en los diferentes modelos desarrollados. 
- El *conjunto de evaluación* (`eval.csv`) se reserva y se consulta una única vez, al final, para dar una estimación honesta del rendimiento del modelo ya elegido. 

Si solo se usara `train/test` y el conjunto de test se consultara muchas veces durante la selección de modelo, existe el riesgo de que las decisiones de diseño se ajusten indirectamente a ese conjunto de test, inflando artificialmente el rendimiento reportado.

=== Distribución geográfica de las muestras <dist-geo>

La distribución de parcelas por país es la siguiente (de mayor a menor):

#figure(
  align(center)[
    #table(
      columns: (33%, 33%),
      align: (left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*País*],
        table.cell(align: center)[*Nº parcelas*],
      ),
        [*Israel (IL)*],      [51],
        [*Rumanía (RO)*],     [51],
        [*Suiza (CH)*],       [50],
        [*Irlanda (IE)*],     [45],
        [*Eslovenia (SI)*],   [45],
        [*Bélgica (BE)*],     [36],
        [*España (ES)*],      [36],
        [*Países Bajos (NL)*],[33],
        [*Francia (FR)*],     [29],
        [*Suecia (SE)*],      [27],
        [*Alemania (DE)*],    [23],
        [*Italia (IT)*],      [2],
      )
  ],
  caption: [Distribución de datos entre países.],
  kind: table
)<tab-11>

#figure(
  align(center)[
    #image("../media/eda/01_paises.png", height: 35%)
  ],
  caption: [Gráfica de distribución de datos entre países.],
  kind: image
)<fig-4>

Como se puede ver en la primera imagen y en la tabla mostrada previamente, la distribución de datos está desbalanceada, destacando el caso de Italia, que solo tiene datos de *2 parcelas*. 

#figure(
  align(center)[
    #image("../media/eda/02_usos_tipos.png", height: 35%)
  ],
  caption: [Gráfica de usos y tipos de suelo.],
  kind: image
)<fig-5>


Esto es relevante para las #link(<vias-de-trabajo-futuro>)[*Vías de trabajo futuro*], en la cual figura la recolección de más datos como una de las posibles vías de trabajo futuro, ya que la falta de datos es una limitación grande cuando se trata de entrenar modelos de aprendizaje automático.

Con solo 2 parcelas italianas sobre 428 (0.5% del dataset), el modelo apenas tiene información para aprender las particularidades edafoclimáticas de Italia, y cualquier métrica de error agregada (calculada sobre todo el conjunto de test) estará dominada por los países mejor representados (Israel, Rumanía, Suiza), enmascarando un posible mal desempeño en los países minoritarios. 

#colbreak()

=== Variables descartadas durante la selección <var-descartadas>

A partir de la comparación directa entre el dataset limpio y el dataset escalado (véase #link(<desc-dataset>)[*Descripción general del dataset*]), las variables que no se usan directamente como predictoras (34) ni como targets (21) corresponden a las siguientes familias:

#figure(
  align(center)[
    #table(
      columns: (auto, auto),
      align: (left+horizon, left+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Variable(s)*],
        table.cell(align: center)[*Motivo de exclusión como predictora*]
      ),
        [*`site_id`*],[Identificador único, sin valor predictivo.],
        [*`country` \ `pedoclimatic_region` \ `site_locality`*],[Identificadores geográficos categóricos. Se usan para estratificación/validación cruzada, no como predictoras directas del modelo final.],
        [*`latitude` \ `longitude` \ `sampling_date`*],[Usadas para la extracción de variables remotas (GEE, DEM) y para el control de estacionalidad, no como predictoras directas.],
        [*`soil_type` \ `land_use_type` \ `land_use_intensity` \ `dominant_vegetation` \ `eu_soil_texture_class` \ `eu_env_zone` \ `eu_land_cover` \ `eu_soil_type_wrb` \ `eu_uso_suelo_nombre`*],[Variables categóricas de tipo/uso de suelo. Ninguna se conserva en el dataset escalado. No aparecen en la tabla de predictoras de #link(<seleccion-de-variables>)[*Selección de variables*], dado que el propio EDA muestra diferencias claras de pH y carbono orgánico según `land_use_type`.],
        [*`outlier_flag`*],[Variable de control de calidad, no un predictor ecológico. Se usa como posible filtro de filas, no de columnas.],
    )
  ],
  caption: [Variables excluidas.],
  kind: table
)<tab-12>

=== Valores faltantes e imputación <missing-vals>

El dataset limpio *no presenta valores nulos* tras el proceso de imputación: la ausencia original de datos queda registrada aparte en un archivo de flags (`imputation_flags.csv`), con una columna binaria `[variable]_was_missing` por cada variable imputable.

El procedimiento real, aplicado en este orden, es:

+ Se eliminan las filas sin coordenadas (`latitude/longitude`).
+ Los recuentos ecológicos con prefijo `ew_`, `macro_`, `orib_`, `meso_`, `coll_`, `nuid_`, `uvigo_` se imputan a 0 cuando faltan, bajo el supuesto de que la ausencia de dato equivale a ausencia real de la especie/taxón en el muestreo, no a un valor perdido en sentido estadístico.
+ Para el resto de variables numéricas: las que tienen menos del 5% de valores perdidos se imputan con la mediana global de la columna, sin añadir indicador.
+ Las que tienen entre el 5% y el 50% de valores perdidos se imputan también con la mediana global, pero además se añade una columna binaria `[variable]_was_missing`.
+ Las variables con más del 50% de valores perdidos se eliminarían del dataset antes de este paso. 
+ Las variables categóricas se imputan con la moda.

Es decir, la imputación es una *mediana global simple* (no condicionada por país ni por uso de suelo), acompañada de indicadores de "dato perdido" únicamente para el rango 5-50%. Esto tiene una implicación directa sobre las correlaciones calculadas en la sección II.8: al no preservar la estructura de covarianza entre variables (a diferencia de un método KNN), la imputación por mediana global puede atenuar ligeramente algunas correlaciones reales, lo cual debería mencionarse como limitación metodológica al citar los coeficientes de Pearson de este anexo.


==== El indicador outlier_flag <outlier>

`outlier_flag` presenta la siguiente distribución en el dataset: 347 parcelas marcadas como True frente a 81 como False.

#figure(
  align(center)[
    #image("../media/eda/13_outlierflag_pais.png", height: 35%)
  ],
  caption: [Gráfica de distribución de datos entre países.],
  kind: image
)<fig-6>

El patrón de `outlier_flag` por país (tabla siguiente) confirma que no es un indicador de outlier estadístico fila a fila homogéneo, sino un control de calidad que varía sistemáticamente según el origen de los datos:

#figure(
  align(center)[
    #table(
      columns: (auto, auto, auto, auto),
      align: (center+horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*País*],[*False*],[*True*],[*% False*]
      ),
        [*RO*],[26],[25],[51.0%],
        [*IE*],[16],[29],[35.6%],
        [*BE*],[10],[26],[27.8%],
        [*ES*],[9], [27],[25.0%],
        [*NL*],[6], [27],[18.2%],
        [*SE*],[7], [20],[25.9%],
        [*DE*],[5], [18],[21.7%],
        [*FR*],[2], [27],[6.9%],
        [*CH*],[0], [50],[0.0%],
        [*IL*],[0], [51],[0.0%],
        [*SI*],[0], [45],[0.0%],
        [*IT*],[0], [0], [0.0%],
    )
  ],
  caption:[Tabla de distribución de los `outlier_flag`],
  kind: table  
)<tab-13>

Cuatro países (Suiza, Israel, Eslovenia e Italia, el 45% de las parcelas del dataset) no presentan ni un solo caso False, mientras que Rumanía tiene una proporción casi equilibrada (51% False). Esta discrepancia tan marcada entre países es evidencia empírica directa de que `outlier_flag` no debe usarse como filtro de outliers estadístico genérico sin condicionar por país u origen de los datos: para los cuatro países sin ningún False, la columna no aporta ninguna capacidad discriminativa fila a fila.

#colbreak()

`outlier_flag` se genera, según el diccionario de datos, combinando un criterio de Isolation Forest con umbrales de tipo Z-score, precisamente para evitar el sesgo que produciría un filtro IQR simple aplicado directamente sobre columnas binarias muy desbalanceadas como los propios flags de imputación (donde el valor "1" es un evento raro y el IQR lo marcaría erróneamente como atípico).

El Isolation Forest es un algoritmo de detección de anomalías no supervisado que construye múltiples árboles de decisión aleatorios y mide cuántas particiones hacen falta para aislar cada observación del resto: los puntos atípicos, al ser diferentes de la mayoría, tienden a aislarse con muy pocas particiones, mientras que los puntos típicos necesitan muchas más particiones para separarse del grueso de los datos. A diferencia del método IQR (sección II.7), que evalúa cada variable de forma aislada, el Isolation Forest puede considerar varias variables a la vez, detectando combinaciones inusuales de valores que individualmente no serían atípicos. El umbral de tipo Z-score mide a cuántas desviaciones estándar se encuentra un valor respecto a la media de su variable (Z = (x menos la media) dividido entre la desviación estándar); un Z-score alto en valor absoluto (típicamente por encima de 3) se interpreta como indicio de valor atípico. Combinar ambos criterios permite capturar tanto anomalías multivariantes como anomalías univariantes extremas.

=== Análisis univariante <analisis-univariante>

==== Propiedades físicas del suelo <prop-del-suelo>

La textura del suelo se describe habitualmente mediante *tres fracciones granulométricas* que, por definición, suman aproximadamente el 100% de la masa mineral de una muestra: 
+ *Arena:* partículas de mayor tamaño, 0.05 a 2 mm. 
+ *Limo:* partículas intermedias, 0.002 a 0.05 mm.
+ *Arcilla:* partículas más finas, menores de 0.002 mm. 

Esta composición condiciona propiedades agronómicas clave como la *capacidad de retención de agua* (mayor en suelos arcillosos), el *drenaje* (mayor en suelos arenosos) y la *aireación*, todas ellas relevantes para explicar la biodiversidad edáfica que se modela en este TFG. 

El siguiente gráfico resume la dispersión de las tres fracciones en el conjunto de 428 parcelas:

#figure(
  align(center)[
    #image("../media/eda/03_textura.png", height: 30%)
  ],
  caption: [Gráfica de la textura del suelo.],
  kind: image
)<fig-7>

La segunda figura de esta sección resume la distribución univariante de seis variables físico-químicas centrales: pH (acidez/alcalinidad del suelo, escala 0 a 14), estabilidad de agregados (cohesión de las partículas del suelo, relevante frente a la erosión), densidad aparente (masa de suelo por unidad de volumen, indicador de compactación), humedad del suelo, y carbono/nitrógeno total del plot (indicadores de fertilidad y actividad biológica):

#figure(
  align(center)[
    #image("../media/eda/04_fisicoquimicas.png")
  ],
  caption: [Gráfica de los datos físico-químicos.],
  kind: image
)<fig-8>

==== Elementos traza y nutrientes <elementos-traza>

Las concentraciones de elementos traza (`As`, `Cu`, `K`, `Mo`, `Ni`, `P`, `Pb`, `Zn`) presentan distribuciones muy asimétricas, con una minoría de parcelas concentrando valores muy superiores al resto, comportamiento esperable en variables de contaminación/toxicidad de suelo. Se visualizan en escala logarítmica para poder compararlas en un mismo gráfico.

Cuando una variable tiene una distribución muy asimétrica (con una cola larga de valores altos, como suele ocurrir con metales pesados o contaminantes), representarla en escala lineal hace que la mayoría de las parcelas (con valores bajos, cercanos entre sí) queden aplastadas visualmente contra el eje, mientras unas pocas parcelas extremas dominan el rango del gráfico. 

Aplicar una transformación logarítmica comprime los valores altos y expande los valores bajos, permitiendo comparar de un vistazo la forma de la distribución de `As`, `Cu`, `K`, `Mo`, `Ni`, `P`, `Pb` y `Zn` en un mismo gráfico, algo que sería ilegible en escala lineal dado que algunos metales tienen concentraciones órdenes de magnitud mayores que otros. 

De cara al modelado, algunos algoritmos (en particular la Regresión Ridge, que asume relaciones lineales) se benefician de trabajar con variables cuya distribución se aproxime más a la normal, por lo que aplicar una transformación logarítmica de tipo $log_1(p)$ a estas variables antes de entrenar es una opción a considerar, más allá de la visualización de este EDA.

#figure(
  align(center)[
    #image("../media/eda/05_metales.png", height: 27.5%)
  ],
  caption: [Gráfica de los datos de metales.],
  kind: image
)<fig-9>

La siguiente figura muestra las distribuciones univariantes de las tres variables de carbono/nitrógeno del plot (`plot_total_c`, `plot_total_organic_c`, `plot_total_n`), cuya fuerte correlación mutua se analiza en detalle en la sección #link(<analisis-bivariante-multivariante>)[*Análisis bivariante y multivariante*]:

#figure(
  align(center)[
    #image("../media/eda/06_c_n.png", height: 27.5%)
  ],
  caption: [Gráfica de los datos físico-químicos.],
  kind: image
)<fig-10>

#colbreak()

==== Biodiversidad edáfica <biodiversidad-edafica>

Los 11 índices de Shannon presentes en el dataset (`nematodos`, `macrofauna`, `lombrices`, `oribátidos`, `mesofauna`, `colémbolos`, `bacterias`, `hongos`, `eucariotas`, `oomicetos` y `cercozoos`) son la medida de biodiversidad más habitual en ecología y constituyen la mayoría de los targets del modelo. 

Se calculan como *H' = menos la suma de pᵢ por el logaritmo natural de pᵢ*, donde *pᵢ* es la proporción de individuos que pertenecen a la especie o taxón i dentro de la comunidad muestreada en una parcela. 

Un valor de Shannon bajo indica una comunidad dominada por pocas especies (baja diversidad), mientras que un valor alto indica una comunidad más equitativa entre muchas especies (alta diversidad). A diferencia de un simple recuento de especies (riqueza), el índice de Shannon también penaliza la dominancia de unas pocas especies sobre las demás, por lo que dos parcelas con el mismo número de especies pueden tener índices de Shannon muy distintos si en una de ellas una sola especie domina abrumadoramente. 

La siguiente gráfica compara la distribución de estos 11 índices entre sí:

#figure(
  align(center)[
    #image("../media/eda/07_shannon.png", height: 30%)
  ],
  caption: [Gráfica de Shannon por grupo taxonómico.],
  kind: image
)<fig-11>

Se observa que los distintos grupos taxonómicos ocupan rangos de Shannon bastante diferentes entre sí, lo cual es coherente con la altísima riqueza de especies típica de las comunidades microbianas del suelo frente a grupos de fauna con menos taxones potenciales por parcela. 

Esta heterogeneidad entre grupos es uno de los argumentos a favor de modelar cada índice por separado en lugar de asumir que se comportan de forma equivalente (véase la discusión sobre correlación entre targets en la #link(<correlacion-shannon>)[*Correlaciones entre targets (índice Shannon)*]).

#colbreak()

=== Variables por uso de suelo <var-uso-suelo>

Medianas recalculadas tras normalizar el espacio en blanco de `land_use_type` (véase la sección #link(<var-descartadas>)[*Variables descartadas durante la selección*]):

*Mediana de pH por uso de suelo:*

#figure(
  align(center)[
    #table(
      columns: (25%,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Uso del suelo*],
        table.cell(align: center)[*pH mediana*],
      ),
        [*Forest*],   [4.33],
        [*Grassland*],[5.80],
        [*Orchard*],  [6.24],
        [*Arable*],   [6.34],
        [*Wetland*],  [6.55],
        [*Urban*],    [6.89],
    )
  ],
  caption: [Mediana de pH por uso de suelo.],
  kind: table
)<tab-14>

*Mediana de carbono orgánico por uso de suelo:*

#figure(
  align(center)[
    #table(
      columns: (25%,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Uso del suelo*],
        table.cell(align: center)[*Carbono orgánico*],
      ),
        [*Arable*],   [2.51],
        [*Orchard*],  [3.25],
        [*Urban*],    [3.93],
        [*Grassland*],[4.23],
        [*Forest*],   [4.49],
        [*Wetland*],  [10.23],
    )
  ],
  caption: [Mediana de carbono orgánico por uso de suelo.],
  kind: table
)<tab-15>

#figure(
  align(center)[
    #image("../media/eda/08_uso_suelo_ph_c.png", height: 30%)
  ],
  caption: [pH y carbono orgánico por uso de suelo.],
  kind: image
)<fig-12>

Los suelos de *`Forest`* presentan el pH mediano más bajo (4.33, moderadamente ácido) porque la descomposición de hojarasca y acículas libera ácidos orgánicos y porque no reciben encalado agrícola. Mientras que, en el otro extremo, *`Urban`* (6.89) y *`Wetland`* (6.55) tienden a valores más neutros, en el caso urbano por la influencia de materiales de construcción alcalinos en el entorno edáfico, y en el caso de los humedales por procesos de acumulación de bases en condiciones de saturación hídrica. 

En cuanto al carbono orgánico, que *`Wetland`* (10.23) más que duplique al resto de usos es un patrón clásico en ciencia del suelo: la saturación de agua limita la disponibilidad de oxígeno, ralentizando drásticamente la descomposición microbiana de la materia orgánica y provocando su acumulación a largo plazo, el mismo proceso que da lugar a las turberas. Por contraste, Arable presenta el carbono orgánico más bajo (2.51) porque el laboreo agrícola repetido airea el suelo, acelera la descomposición de la materia orgánica y habitualmente exporta biomasa (cosechas) que no vuelve al sistema. 

=== Valores atípicos (outliers, método IQR) <outliers-iqr>

El rango *intercuartílico (IQR)* es una medida de dispersión robusta frente a valores extremos, definida como $"IQR" = "Q3" minus "Q1"$, donde Q1 y Q3 son el primer y tercer cuartil (percentiles 25 y 75) de la variable. 

El *criterio estándar de Tukey* marca como atípico cualquier valor por debajo de Q1 menos 1.5 veces el IQR o por encima de Q3 más 1.5 veces el IQR: el multiplicador 1.5 es una convención (no un umbral estadístico con una probabilidad asociada) que, para una distribución aproximadamente normal, marcaría como atípico en torno al 0.7% de los datos, pero que puede marcar un porcentaje mucho mayor en variables muy asimétricas como los metales o las abundancias biológicas de este dataset (sección II.5.2). De ahí la recomendación de valorar una transformación logarítmica antes de aplicar este criterio.

*Variables continuas con más outliers detectados mediante el método IQR estándar:*

#figure(
  align(center)[
    #table(
      columns: (30%,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Variable*],
        table.cell(align: center)[*Outliers*],
      ),
        [*gee_temp_media_C*],           [63],
        [*coll_nymphs_abundance*],      [62],
        [*total_plant_cover*],          [61],
        [*aggregate_stability*],        [58],
        [*latitude*],                   [51],
        [*eu_organic_carbon_octop*],    [50],
        [*au_water_holding_capacity*],  [49],
        [*orib_total_abundance*],       [48],
    )
  ],
  caption: [Variables con mayor cantidad de outliers.],
  kind: table
)<tab-16>

Las variables de concentración de metales y de abundancia biológica suelen estar sesgadas de forma natural, se recomienda evaluar una transformación logarítmica antes de tratar estos valores como errores de medición. 

Se confirma que eu_organic_carbon_octop (sin sufijo `_z`) es efectivamente el nombre de la variable en `sob4es_final_clean.csv`. 

El sufijo `_z` solo aparece en la versión escalada `sob4es_final_model_ready.csv` (`eu_organic_carbon_octop_z`), por lo que no se trata de un error de transcripción sino de las dos versiones de la misma variable.

=== Análisis bivariante y multivariante <analisis-bivariante-multivariante>

==== Correlaciones entre propiedades físico-químicas <fisico-quimicas>

El *coeficiente de correlación de Pearson (r)* mide la fuerza y dirección de la relación lineal entre dos variables continuas, y varía entre -1 (relación lineal negativa perfecta) y +1 (relación lineal positiva perfecta), con 0 indicando ausencia de relación lineal, aunque podría existir una relación no lineal no capturada por este coeficiente. 

Cuando dos o más variables predictoras están altamente correlacionadas entre sí, un modelo de regresión lineal como Ridge tiene dificultades para atribuir el efecto sobre el target a una u otra variable de forma estable: pequeños cambios en los datos de entrenamiento pueden hacer que los coeficientes estimados oscilen mucho, aunque la predicción global del modelo siga siendo razonable. 

La regularización Ridge reparte el peso entre variables correlacionadas en lugar de concentrarlo arbitrariamente en una sola, lo que estabiliza la estimación a costa de introducir un sesgo controlado.

Pares de variables con mayor correlación (valor absoluto):

#figure(
  align(center)[
    #table(
      columns: (auto,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Par de variables*],
        table.cell(align: center)[*Correlación (abs)*],
      ),
        [*plot_total_c / plot_total_organic_c*],  [0.976],
        [*plot_total_n / plot_total_c*],          [0.954],
        [*plot_total_n / plot_total_organic_c*],  [0.952],
        [*sand_content / silt_content*],          [0.841],
        [*sand_content / clay_content*],          [0.810],
        [*mo / ni*],                              [0.770],
    )
  ],
  caption: [Variables fisico-químicas con mayor nivel de correlación absoluto.],
  kind: table
)<tab-17>

#figure(
  align(center)[
    #image("../media/eda/09_corr_physchem.png", height: 40%)
  ],
  caption: [Gráfica de correlación físico-química.],
  kind: image
)<fig-13>

Estas correlaciones muy altas (0.95 a 0.98 entre las tres variables de carbono/nitrógeno del plot) son la evidencia empírica directa que justifica el uso de Ridge y la necesidad de regularización mencionada en la sección Regresión Ridge. 

Esta justificación queda reforzada, además, por el propio resultado del tuning de Ridge documentado en #link(<ridge-model>)[*Regresión Ridge*]: los 21 modelos de producción seleccionan valores de alpha muy alejados de 0 (entre ≈106 y ≈720, según el target), lo que indica empíricamente que una regularización sustancial es necesaria para mantener el hueco train-CV por debajo del umbral de estabilidad fijado (0.10), coherente con la colinealidad detectada en esta sección. 

La matriz de correlación completa muestra además que `sand_content` correlaciona negativamente y con fuerza tanto con `silt_content` como con `clay_content`, una relación mecánica esperable ya que las tres fracciones granulométricas suman aproximadamente el 100%, lo que añade un tercer bloque de colinealidad relevante más allá de `C/N` y `Mo/Ni`.
#colbreak()

==== Correlación entre targets (índices Shannon) <correlacion-shannon>

Un modelo multisalida predice varios targets a la vez compartiendo una representación interna común, en lugar de entrenar un modelo independiente por cada target. La justificación teórica habitual para preferir el enfoque multisalida es que, *si los targets están correlacionados entre sí, aprender a predecir uno aporta información útil para predecir los demás*, reduciendo la varianza del modelo con el mismo número de datos de entrenamiento. 

Esta es la lógica que motivaba la hipótesis de partida del TFG. El análisis que sigue pone a prueba esa hipótesis midiendo empíricamente cuán correlacionados están realmente los 21 targets entre sí.

#figure(
  align(center)[
    #table(
      columns: (auto,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Par de targets*],
        table.cell(align: center)[*Correlación (abs)*],
      ),
        [*orib_shannon / meso_shannon*],       [0.383],
        [*meso_shannon / coll_shannon*],       [0.312],
        [*macro_shannon / nematode_shannon*],  [0.227],
        [*cerc_shannon / oomy_shannon*],       [0.208],
    )
  ],
  caption: [Targets con mayor nivel de correlación absoluto.],
  kind: table
)<tab-18>

#figure(
  align(center)[
    #image("../media/eda/10_corr_shannon.png", height: 40%)
  ],
  caption: [Gráfica de correlación de los índices Shannon.],
  kind: image
)<fig-14>

#colbreak()

==== Relación suelo-biodiversidad <relacion-suelo-bio>

#figure(
  align(center)[
    #image("../media/eda/11_suelo_vs_biodiv.png")
  ],
  caption: [Gráfica de suelo vs. diversidad.],
  kind: image
)<fig-15>

Se muestra la relación entre cuatro variables edáficas representativas (pH, carbono orgánico, contenido en arcilla y estabilidad de agregados) y cuatro índices de biodiversidad de distintos grupos taxonómicos (oribátidos, macrofauna, bacterias y nematodos), con el coeficiente de correlación de Pearson indicado en cada panel. 


#colbreak()

==== Consistencia entre mediciones propias y capas de referencia externas <refs-externas>

ESDAC (European Soil Data Centre) y CORINE (Coordination of Information on the Environment) son bases de datos europeas de referencia que ofrecen mapas de variables edáficas y de cobertura del suelo a escala continental, generados a partir de modelos estadísticos que interpolan un número limitado de puntos de muestreo real sobre una malla regular. Su ventaja es la cobertura espacial completa y homogénea de toda Europa sin necesidad de muestrear cada punto; su limitación inherente es que, al ser un valor interpolado y no una medición directa, no capturan la variabilidad edáfica real a escala de parcela, que puede ser muy alta especialmente en variables con patrones de distribución muy localizados como los micronutrientes o los contaminantes.

Correlación entre la medición propia (_in situ_) y la capa de referencia externa equivalente (ESDAC/CORINE), por variable:

#figure(
  align(center)[
    #table(
      columns: (auto,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Variable*],
        table.cell(align: center)[*Correlación (r)*],
      ),
        [*pH*],       [0.53],
        [*Fósforo*],  [0.19],
        [*Arsénico*], [0.22],
        [*Zinc*],     [0.36],
        [*Arcilla*],  [0.55],
        [*Arena*],    [0.61],
    )
  ],
  caption: [Correlaciones entre variables del proyecto SOB4ES \ con las correspondientes variables ESDAC/CORINE.],
  kind: table
)<tab-19>

#figure(
  align(center)[
    #image("../media/eda/12_consistencia_eu.png", )
  ],
  caption: [Gráficas de consistencia con capas externas.],
  kind: image
)<fig-16>

Estas correlaciones son, en el mejor de los casos, moderadas (arena, arcilla) y en el peor claramente débiles (fósforo, arsénico). Este es un resultado con conexión directa a los #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*] del TFG: apoya empíricamente, con datos propios, la conclusión de Phillips et al.#sub([@phillipsEarthwormDiversity]) de que los datos _in situ_ de alta calidad aportan información que las capas globales derivadas no capturan.

La figura de dispersión confirma además que, para fósforo y arsénico en particular, la nube de puntos se aleja considerablemente de la diagonal 1:1, lo que indica que la capa externa tiene menor resolución y precisión que la medición directa y debe tratarse como covariable de contexto y no como validación independiente de la medición _in situ_.

=== Conclusiones del EDA <conclusiones-EDA>

- El dataset limpio no presenta valores nulos remanentes.
- La distribución geográfica está desbalanceada por país, lo que condiciona la interpretación de la capacidad de generalización del modelo y debería mencionarse como limitación.
- Existe colinealidad fuerte y confirmada entre variables de carbono/nitrógeno, entre fracciones granulométricas y entre Mo y Ni, lo que justifica empíricamente el uso de regularización (Ridge) y la tolerancia a colinealidad exigida a los modelos de árboles.
- La correlación entre los índices Shannon es, en general, baja, lo que matiza, sin invalidar necesariamente, la hipótesis de partida sobre las ventajas del modelado multisalida. Las relaciones bivariadas suelo-biodiversidad son igualmente débiles, lo que refuerza la necesidad de modelos no lineales y multivariantes.
- La consistencia entre mediciones _in situ_ y capas de referencia europeas es de moderada a baja según la variable, aportando evidencia propia a favor de la ventaja informativa de los datos _in situ_ ya discutida en #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*].
- *`outlier_flag`* se confirma empíricamente como un indicador no homogéneo entre países: Suiza, Israel, Eslovenia e Italia no presentan ningún caso False, mientras que Rumanía tiene una proporción casi equilibrada de ellos. No debe usarse como filtro de _outliers_ sin condicionar por país. 
- De las 84 columnas del dataset limpio, 13 son identificadores/metadatos categóricos descartados, 4 se conservan sin escalar (`site_id`, `latitude`, `longitude`, `outlier_flag`) y 67 son variables numéricas normalizadas (`_z`) en el dataset escalado. El subconjunto final de 34 predictoras + 21 targets (55 variables) se selecciona a partir de estas 67, no directamente de las 84.
