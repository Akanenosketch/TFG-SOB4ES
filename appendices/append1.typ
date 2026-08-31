== Informe EDA (Anexo I) <informe-eda>

En este anexo se presenta el análisis exploratorio de datos (EDA, *_Exploratory Data Analysis_*) realizado sobre el _dataset_ final obtenido tras la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*], previo al desarrollo de los modelos predictivos descritos en la #link(<capa-modelado>)[*Capa de modelado predictivo*].

El objetivo de este análisis es triple:
+ caracterizar la calidad y la estructura de los datos disponibles (valores faltantes, distribución de las variables, escalas),
+ documentar de forma exhaustiva qué significa cada una de las 84 columnas del _dataset_ limpio, y
+ justificar empíricamente algunas de las decisiones metodológicas tomadas en la sección #link(<marco-teorico-o-practico>)[*Marco teórico y práctico*], en particular la normalización de las variables predictoras (véase #link(<regresion-ridge>)[*Regresión Ridge*]) y el uso de modelos robustos frente a la colinealidad (véase #link(<seleccion-de-variables>)[*Selección de variables*]).

Antes de entrenar un modelo predictivo conviene entender qué hay realmente en los datos: cuántas observaciones hay, qué significa cada variable, cómo se distribuyen entre países y usos de suelo, si faltan valores, si hay variables que se mueven juntas (colinealidad), si existen valores atípicos y si las relaciones entre variables predictoras y variables objetivo son lineales o no. Estas preguntas requieren calcular estadísticos y visualizar los datos directamente, que es lo que se hace en este anexo.

Las conclusiones aquí obtenidas condicionan decisiones concretas del cuerpo principal del TFG, como qué modelos emplear, qué algoritmo de regularización usar (véase #link(<regresion-ridge>)[*Regresión Ridge*]), si tiene sentido un enfoque de modelado multisalida o qué limitaciones de generalización hay que declarar en las conclusiones.

El anexo se organiza en los siguientes bloques:
+ Descripción general del _dataset_.
+ Distribución geográfica.
+ Catálogo completo de variables.
+ Variables descartadas de la selección.
+ Valores faltantes e imputación.
  + Indicador de calidad `outlier_flag`.
+ Análisis univariante variable a variable.
+ Variables por uso de suelo.
+ Valores atípicos.
+ Análisis bivariante y multivariante de correlaciones y consistencia externa.
+ Conclusiones del informe EDA.

#colbreak()

=== Descripción general del _dataset_ <desc-dataset>

El análisis se ha realizado sobre `sob4es_final_clean.csv`, la versión armonizada y sin escalar del _dataset_ (equivalente a `clean.csv` en la nomenclatura de la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*]), de forma que las cifras conserven su interpretación agronómica y ecológica directa antes de la normalización aplicada en la #link(<capa-modelado>)[*Capa de modelado predictivo*].

En la #ref(<tab-10>) se pueden ver las estadísticas generales sobre el _dataset_.

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
      table.cell(align: center)[*Nº de variables \ en el _dataset_ limpio*],
        table.cell()[84],
      table.cell(align: center)[*Nº de variables predictoras \ finales seleccionadas*],
        table.cell()[34 \ (véase #link(<seleccion-de-variables>)[*Selección de variables*])],
      table.cell(align: center)[*Valores nulos detectados en el _dataset_ limpio*],
        table.cell()[0],
      table.cell(align: center)[*Filas con site_id duplicado*],
        table.cell()[0],
    )
  ],
  caption: [Descripción general del _dataset_.]
)<tab-10>

Comparando directamente el dataset limpio (84 columnas) con el dataset escalado usado en el modelado (71 columnas), los cambios principales que hay entre uno y otro son los siguientes:

- *13 columnas se eliminan por completo al pasar a la versión escalada, por ser identificadores o metadatos categóricos no normalizables:* `country`, `pedoclimatic_region`, `site_locality`, `sampling_date`, `soil_type`, `land_use_type`, `land_use_intensity`, `dominant_vegetation`, `eu_soil_texture_class`, `eu_env_zone`, `eu_land_cover`, `eu_soil_type_wrb`, `eu_uso_suelo_nombre`.
- *4 columnas se conservan sin escalar:* `site_id`, `latitude`, `longitude`, `outlier_flag`.
- *67 columnas numéricas se conservan normalizadas con sufijo `_z`:* variables físico-químicas, tróficas y de biodiversidad, más covariables ambientales `gee_*/dem_*` y capas de referencia `eu_*`.

Es decir, *84 = 13 (descartadas) + 4 (sin escalar) + 67 (normalizadas `_z`)*.

El conjunto de 67 variables numéricas normalizadas es el universo real desde el que se seleccionan, en una fase posterior de la #link(<seleccion-de-variables>)[*Selección de variables*], las 34 predictoras y 21 _targets_ finales. La diferencia entre 67 y 55 corresponde a variables numéricas descartadas por el proceso de selección de variables (colinealidad, varianza casi nula, etc.), no a identificadores.

De acuerdo con la partición final descrita en la #link(<capa-modelado>)[*Fase de partición de datos*], el conjunto se divide en 299 observaciones de entrenamiento (70%), 64 de test (15%) y 65 de evaluación (15%), sobre el total de 428 parcelas.

#colbreak()

El *resultado* de la selección de predictoras y _targets_ queda fijado de forma explícita y reproducible en todos los modelos entrenados (véase #link(<modelos-empleados>)[*Anexo II*]), mediante las constantes `FEATURES_AUTORIZADAS` y `TARGETS`.

```py
TARGETS = [
    # Shannon
    'nematode_shannon_z',    'macro_shannon_z',
    'earthworm_shannon_z',   'orib_shannon_z',
    'meso_shannon_z',        'coll_shannon_z',
    'bac_shannon_z',         'fun_shannon_z',
    'euk_shannon_z',         'oomy_shannon_z',
    'cerc_shannon_z',
    # Richness
    'macro_order_richness_z',   'earthworm_richness_z',
    'orib_species_richness_z',  'meso_species_richness_z',
    'coll_species_richness_z',  'bac_asv_richness_z',
    'fun_asv_richness_z',       'euk_asv_richness_z',
    'oomy_asv_richness_z',      'cerc_asv_richness_z'
]

FEATURES_AUTORIZADAS = [
    'total_plant_cover_z',        'clay_content_z',
    'silt_content_z',             'sand_content_z',
    'aggregate_stability_z',      'bulk_density_z',
    'soil_moisture_z',            'as_z',
    'cu_z',                       'k_z',
    'mo_z',                       'ni_z',
    'p_z',                        'pb_z',
    'zn_z',                       'soil_ph_z',
    'plot_total_organic_c_z',     'plot_total_n_z',
    'gee_temp_media_C_z',         'gee_humedad_rel_pct_z',
    'gee_ndvi_verano_z',          'dem_elevacion_m_z',
    'dem_pendiente_deg_z',        'dem_orientacion_deg_z',
    'eu_clay_content_z',          'eu_sand_content_z',
    'eu_silt_content_z',          'eu_water_holding_capacity_z',
    'eu_cn_ratio_z',              'eu_p_z',
    'eu_ph_z',                    'eu_as_z',
    'eu_organic_carbon_octop_z',  'eu_zn_z'
]
```

Las *variables predictoras* (34) son las covariables edáficas, ambientales y de fuentes satelitales y estaciones climáticas (pH, textura, elementos traza, temperatura media, NDVI, elevación, etc.) que el modelo recibe como entrada para hacer una predicción.

Las *variables objetivo* o _*targets*_ (21) son, en su mayoría, los índices de biodiversidad edáfica (Shannon, abundancias, riquezas) que el modelo intenta predecir a partir de esas covariables.

Esta distinción es la que justifica por qué identificadores como `site_id` o `country` no entran en ninguno de los dos grupos: no aportan información edáfica ni son el fenómeno biológico que se quiere predecir, solo sirven para trazabilidad o para particionar los datos de forma estratificada (véase #link(<dist-geo>)[*Distribución geográfica de las muestras*]).

Dividir los datos en tres subconjuntos (`train/test/eval`), y no en los dos habituales (`train/test`), permite separar dos usos distintos de los datos no vistos por el modelo durante el entrenamiento:
- El *conjunto de test* (`test.csv`) se puede usar repetidamente mientras se ajustan hiperparámetros o se comparan arquitecturas en los diferentes modelos desarrollados.
- El *conjunto de evaluación* (`eval.csv`) se reserva y se consulta una única vez, al final, para dar una estimación honesta del rendimiento del modelo ya elegido.

Si solo se usara `train/test` y el conjunto de test se consultara muchas veces durante la selección de modelo, existe el riesgo de que las decisiones de diseño se ajusten indirectamente a ese conjunto de test, inflando artificialmente el rendimiento reportado.

#colbreak()

=== Distribución geográfica de las muestras <dist-geo>

La distribución de parcelas por país es la siguiente (de mayor a menor), verificada directamente contra `sob4es_final_clean.csv`:

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

Como se puede ver en la #ref(<fig-4>) y en la #ref(<tab-11>) mostradas previamente, la distribución de datos está desbalanceada, destacando el caso de Italia, que solo tiene datos de *2 parcelas*.

#colbreak()

En la #ref(<fig-5>) se puede ver la repartición existente de los diferentes tipos de terreno y los usos que tienen en la actualidad.

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

=== Catálogo de variables <var-cat>

Esta sección documenta las 84 columnas de `sob4es_final_clean.csv`, agrupadas por familia. Para cada variable se indica su descripción, unidad y estatus en el modelado final: 
- *Predictora:* Una de las 34 variables almacenadas en `FEATURES_AUTORIZADAS`. 
- *Target:* Una de las 21 variables almacenadas en `TARGETS`.
- *No seleccionada:* Existe como columna `_z` en `sob4es_final_model_ready.csv`, pero no se usa ni como predictora ni como target (véase #link(<var-descartadas>)[*Variables descartadas*]).
- *Descartada:* Columna categórica o de metadatos que no se conserva en absoluto en la versión escalada.
- *Sin escalar:* Se conserva en `sob4es_final_model_ready.csv` sin transformar. Son variables del tipo identificador, coordenadas o indicador de calidad.

==== Identificación, ubicación y metadatos del sitio (13 variables)

En la #ref(<tab-51>) se pueden ver las variables relacionadas con identificadores, ubicaciones y metadatos, como también su situación en el dataset limpio.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad/Valores*],
        [*Estatus*],
      ),
      [*`site_id`*],              [Identificador único del sitio de muestreo\ ( prefijo de dos letras = país).],    [Texto],                        [Sin escalar],
      [*`country`*],              [Código de país de dos letras\ (BE, CH, DE, ES, FR, IE, IL, IT, NL, RO, SE, SI).],[Categórica\ (12 clases)],      [Descartada ],
      [*`pedoclimatic_region`*],  [Región pedoclimática de origen\ (ej. ATC = Atlantic Central).],                  [Categórica\ (9 clases)],       [Descartada ],
      [*`site_locality`*],        [Localidad o topónimo del sitio de muestreo.],                                    [Texto\ (181 valores)],         [Descartada ],
      [*`latitude`*],             [Latitud del sitio (WGS84).],                                                     [Grados decimales],             [Sin escalar],
      [*`longitude`*],            [Longitud del sitio (WGS84).],                                                    [Grados decimales],             [Sin escalar],
      [*`sampling_date`*],        [Fecha de muestreo en campo.],                                                    [Fecha],                        [Descartada ],
      [*`soil_type`*],            [Tipo de suelo según clasificación WRB determinada en campo.],                    [Categórica\ (22 clases)],      [Descartada ],
      [*`land_use_type`*],        [Uso de suelo (Forest, Grassland, Arable, Orchard, Wetland, Urban).],             [Categórica\ (6 clases)],       [Descartada ],
      [*`land_use_intensity`*],   [Intensidad de manejo del uso de suelo.],                                         [Categórica\ (Low, Mid, High) ],[Descartada ],
      [*`dominant_vegetation`*],  [Vegetación dominante observada en campo.],                                       [Categórica\ (36 clases)],      [Descartada ],
      [*`total_plant_cover`*],    [Cobertura vegetal total de la parcela.],                                         [%],                            [Predictora ],
      [*`outlier_flag`*],         [Indicador de calidad/atipicidad de la fila.],                                    [Booleano\ (True, False)],      [Sin escalar],
    )
  ],
  caption: [Tabla de variables de identificación, ubicación y metadatos del sitio.],
  kind: table
) <tab-51>

==== Propiedades físicas del suelo, _in situ_ (6 variables)

En la #ref(<tab-52>) se pueden ver las variables relacionadas con propiedades físicas del suelo, como también su situación en el dataset limpio.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad/Valores*],
        [*Estatus*],
      ),
      [*`clay_content`*],        [Contenido de arcilla (partículas < 0.002 mm).],                                      [%],               [Predictora],
      [*`silt_content`*],        [Contenido de limo (0.002-0.05 mm).],                                                 [%],               [Predictora],
      [*`sand_content`*],        [Contenido de arena (0.05-2 mm).],                                                    [%],               [Predictora],
      [*`aggregate_stability`*], [Estabilidad de los agregados del suelo frente a la erosión.],                        [Índice \ (0 -1)], [Predictora],
      [*`bulk_density`*],        [Densidad aparente: masa de suelo por unidad de volumen, indicador de compactación.], [g/cm³],           [Predictora],
      [*`soil_moisture`*],       [Humedad del suelo en el momento del muestreo.],                                      [Fracción],        [Predictora],
    )
  ],
  caption: [Tabla de variables de propiedades físicas del suelo.],
  kind: table
) <tab-52>

==== Propiedades químicas del suelo, _in situ_ (9 variables)

En la #ref(<tab-53>) se pueden ver las variables relacionadas con propiedades químicas del suelo, como también su situación en el dataset limpio.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad/Valores*],
        [*Estatus*],
      ),
      [*`as`*],       [Concentración de arsénico total.],   [mg/kg],            [Predictora],
      [*`cu`*],       [Concentración de cobre total.],      [mg/kg],            [Predictora],
      [*`k`*],        [Concentración de potasio. ],         [mg/kg],            [Predictora],
      [*`mo`*],       [Concentración de molibdeno. ],       [mg/kg],            [Predictora],
      [*`ni`*],       [Concentración de níquel. ],          [mg/kg],            [Predictora],
      [*`p`*],        [Concentración de fósforo. ],         [mg/kg],            [Predictora],
      [*`pb`*],       [Concentración de plomo. ],           [mg/kg],            [Predictora],
      [*`zn`*],       [Concentración de zinc. ],            [mg/kg],            [Predictora],
      [*`soil_ph`*],  [pH del suelo (acidez/alcalinidad).], [Escala\ (0 - 14)], [Predictora],
    )
  ],
  caption: [Tabla de variables de propiedades químicas del suelo.],
  kind: table
) <tab-53>

==== Carbono y nitrógeno a nivel de parcela (3 variables)

En la #ref(<tab-54>) se muestran las variables de carbono y nitrógeno a nivel de parcela.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad*],
        [*Estatus*],
      ),
      [*`plot_total_c`*],         [Carbono total del suelo.],           [%],   [No seleccionada],
      [*`plot_total_organic_c`*], [Carbono orgánico total del suelo.],  [%],   [Predictora],
      [*`plot_total_n`*],         [Nitrógeno total del suelo.],         [%],   [Predictora],
    )
  ],
  caption: [Tabla de variables de carbono y nitrógeno a nivel de parcela.],
  kind: table
) <tab-54>

#colbreak()

==== Biodiversidad edáfica, por grupo taxonómico (32 variables)

Todos los índices de riqueza y Shannon de la #ref(<tab-55>) son targets del modelo (21 en total). 

Las variables de abundancia/lecturas totales no se usan ni como predictoras ni como targets (11 variables no seleccionadas), salvo `nematode_shannon`, único indicador disponible para ese grupo. Los índices Shannon se explican con detalle en la sección de biodiversidad edáfica del análisis univariante.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Grupo taxonómico*],
        [*Abundancia \ / lecturas totales*],
        [*Riqueza*],
        [*Shannon*],
      ),
      [*Nematodos*],                 [*(no disponible en el _dataset_)*],         [*(no disponible)* ],                 [`nematode_shannon`\ *Target*],
      [*Macrofauna*],                [`macro_total_abundance`\ No seleccionada],  [`macro_order_richness`\ *Target*],   [`macro_shannon`\ *Target*],
      [*Lombrices\ (earthworms)*],   [`earthworm_abundance`\ No seleccionada],    [`earthworm_richness`\ *Target*],     [`earthworm_shannon`\ *Target*],
      [*Oribátidos*],                [`orib_total_abundance`\ No seleccionada],   [`orib_species_richness`\ *Target*],  [`orib_shannon`\ *Target*],
      [*Mesofauna\ (Mesostigmata)*], [`meso_total_abundance`\ No seleccionada],   [`meso_species_richness`\ *Target*],  [`meso_shannon`\ *Target*],
      [*Colémbolos*],                [`coll_total_abundance`\ No seleccionada\ `coll_nymphs_abundance`\ No seleccionada],                                                              [`coll_species_richness`\ *Target*],  [`coll_shannon`\ *Target*],
      [*Bacterias\ (16S)*],          [`bac_total_reads`\ No seleccionada],        [`bac_asv_richness`\ *Target*],       [`bac_shannon`\ *Target*],
      [*Hongos\ (ITS)*],             [`fun_total_reads`\ No seleccionada],        [`fun_asv_richness`\ *Target*],       [`fun_shannon`\ *Target*],
      [*Eucariotas\ (18S)*],         [`euk_total_reads`\ No seleccionada],        [`euk_asv_richness`\ *Target*],       [`euk_shannon`\ *Target*],
      [*Oomicetos*],                 [`oomy_total_reads`\ No seleccionada],       [`oomy_asv_richness`\ *Target*],      [`oomy_shannon`\ *Target*],
      [*Cercozoos*],                 [`cerc_total_reads`\ No seleccionada],       [`cerc_asv_richness`\ *Target*],      [`cerc_shannon`\ *Target*],
    )
  ],
  caption: [Tabla de variables de biodiversidad edáfica, por grupo taxonómico.],
  kind: table
) <tab-55>

#colbreak()

==== Teledetección y topografía - GEE y DEM (6 variables)

En la #ref(<tab-56>) se muestran las variables de teledetección y topografía, todas de ellas son variables predictoras.

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad*],
        [*Fuente*],
      ),
      [*`gee_temp_media_C`*],     [Temperatura media anual en el punto del sitio.],                                                         [°C],   [ERA5-Land (GEE) ],
      [*`gee_humedad_rel_pct`*],  [Humedad relativa media anual, calculada a partir de temperatura y punto de rocío (fórmula de Magnus).],  [% ],   [ERA5-Land (GEE)],
      [*`gee_ndvi_verano`*],      [NDVI medio de verano (proxy de vigor/cobertura vegetal).],                                               [Índice\ (-1 a 1)],                                                                                                                                          [Sentinel-2 (GEE)],
      [*`dem_elevacion_m`*],      [Elevación sobre el nivel del mar.],                                                                      [m ],   [Copernicus DEM 30m ],
      [*`dem_pendiente_deg`*],    [Pendiente del terreno, derivada del DEM (método de diferencias centrales de Horn).],                     [° ],   [Copernicus DEM 30m ],
      [*`dem_orientacion_deg`*],  [Orientación de la pendiente (N=0°), derivada del DEM.],                                                  [° ],   [Copernicus DEM 30m ],
    )
  ],
  caption: [Tabla de variables de teledetección y topografía.],
  kind: table
) <tab-56>

#colbreak()

==== Capas de referencia europeas - ESDAC / CORINE (14 variables)

Extraídas por coordenadas sobre rásters de referencia continental (véase discusión de su consistencia con las mediciones _in situ_ en la sección de análisis bivariante y multivariante).

En la #ref(<tab-57>) se pueden ver las variables de capas de referencia europeas (ESDAC/CORINE).

#figure(
  align(center)[
    #table(
      columns: 4,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],
        [*Descripción*],
        [*Unidad/Valores*],
        [*Estatus*],
      ),
      [*`eu_clay_content`*],            [Contenido de arcilla,capa de referencia ESDAC.],                         [%],                            [Predictora],
      [*`eu_sand_content`*],            [Contenido de arena, capa de referencia ESDAC.],                          [%],                            [Predictora],
      [*`eu_silt_content`*],            [Contenido de limo, capa de referencia ESDAC.],                           [%],                            [Predictora],
      [*`eu_water_holding_capacity`*],  [Capacidad de retención hídrica, capa ESDAC.],                            [Fracción de volumen],          [Predictora],
      [*`eu_cn_ratio`*],                [Relación carbono/nitrógeno, capa ESDAC.],                                [Ratio],                        [Predictora],
      [*`eu_p`*],                       [Fósforo, capa ESDAC.],                                                   [mg/kg],                        [Predictora],
      [*`eu_ph`*],                      [pH, capa ESDAC.],                                                        [Escala\ (0-14)],               [Predictora],
      [*`eu_as`*],                      [Arsénico, capa ESDAC (LUCAS).],                                          [%],                            [Predictora],
      [*`eu_organic_carbon_octop`*],    [Carbono orgánico del horizonte superior (OCTOP).],                       [%],                            [Predictora],
      [*`eu_zn`*],                      [Zinc, capa ESDAC/LUCAS 2009.],                                           [mg/kg],                        [Predictora],
      [*`eu_soil_texture_class`*],      [Clase de textura USDA (código 1-12), capa ESDAC.],                       [Categórica\ (12 clases)],      [Descartada],
      [*`eu_env_zone`*],                [Zona ambiental europea (código 1-14), EEA 2018.],                        [Categórica\ (14 clases)],      [Descartada],
      [*`eu_land_cover`*],              [Uso del suelo CORINE (código de 3 dígitos), 2018.],                      [Categórica\ (código 111-523)], [Descartada],
      [*`eu_soil_type_wrb`*],           [Tipo de suelo WRB (código 1-30), ESDAC 2006.],                           [Categórica\ (30 clases)],      [Descartada],
      [*`eu_uso_suelo_nombre`*],        [Etiqueta textual de `eu_land_cover` (ej. "Non-irrigated arable land").], [Texto],                        [Descartada],
    )
  ],
  caption: [Tabla de variables de de capas de referencia europeas (ESDAC/CORINE)],
  kind: table
) <tab-57>

#rect[
  *Nota:* \
  Esta subsección lista 15 filas porque incluye `eu_uso_suelo_nombre` (la etiqueta de texto de `eu_land_cover`) junto a las 14 columnas numéricas/código propiamente dichas. De ahí que el recuento de variables `eu_*` categóricas descartadas en la sección de variables descartadas sea 5, no 4.
]

#colbreak()

=== Variables descartadas durante la selección <var-descartadas>

A partir del catálogo completo de la sección anterior y de la comparación directa entre `sob4es_final_clean.csv` y `sob4es_final_model_ready.csv` (véase #link(<desc-dataset>)[*Descripción general del dataset*]), las variables que no se usan directamente como predictoras (34) ni como targets (21) se dividen en dos grupos de naturaleza distinta: 13 columnas categóricas o de metadatos que se eliminan por completo antes de escalar, y 12 columnas numéricas que sí se escalan (existen como `_z` en `sob4es_final_model_ready.csv`) pero no se seleccionan para el modelo.

*Grupo 1 - Categóricas/metadatos, eliminadas por completo (13 columnas):*

En la #ref(<tab-12>) se pueden ver las variables categóricas o de metadatos eliminadas y los motivos para su correspondiente eliminación.

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

*Grupo 2 - Numéricas, escaladas, no seleccionadas (12 columnas):*

#figure(
  align(center)[
    #table(
      columns: 3,
      align: horizon,
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
      table.header(
        [*Variable*],[*Familia*],[*Motivo probable de exclusión*],
      ),
      [*`plot_total_c`*],         [Carbono/nitrógeno\ de parcela],[Redundante con `plot_total_organic_c` (r = 0.976).\ Mantener ambas introduciría colinealidad severa.],
      [*`macro_total_abundance`*],[Macrofauna],                  [Abundancia total. Se prioriza `macro_order_richness` y `macro_shannon` como medidas de biodiversidad, no de abundancia bruta.],
      [*`earthworm_abundance`*],  [Lombrices],                   [Ídem: se prioriza\ `earthworm_richness`/`earthworm_shannon`.],
      [*`orib_total_abundance`*], [Oribátidos],                  [Ídem.],
      [*`meso_total_abundance`*], [Mesofauna],                   [Ídem.],
      [*`coll_total_abundance`*], [Colémbolos],                  [Ídem.],
      [*`coll_nymphs_abundance`*],[Colémbolos],                  [Ninfas sin resolución de especie.\ No aporta información de biodiversidad taxonómica.],
      [*`bac_total_reads`*],      [Bacterias],                   [Profundidad de secuenciación, no biodiversidad.\ Correlaciona con el esfuerzo de secuenciación, no con la comunidad microbiana en sí.],
      [*`fun_total_reads`*],      [Hongos],                      [Ídem.],
      [*`euk_total_reads`*],      [Eucariotas],                  [Ídem.],
      [*`oomy_total_reads`*],     [Oomicetos],                   [Ídem.],
      [*`cerc_total_reads`*],     [Cercozoos],                   [Ídem.],
    )
  ], 
  caption: [Variables numéricas y escaladas no seleccionadas.],
  kind: table
)<tab-58>

El patrón del Grupo 2 es consistente y se puede ver reflejado en la #ref(<tab-58>): en 10 de los 11 grupos taxonómicos con datos de abundancia/lecturas, esa variable se descarta a favor de las métricas de riqueza y Shannon, más directamente interpretables como "biodiversidad". 

=== Valores faltantes e imputación <missing-vals>

El _dataset_ limpio no presenta valores nulos tras el proceso de imputación: la ausencia original de datos queda registrada aparte en el archivo de flags, con una columna binaria `[variable]_was_missing` por cada variable imputable. 

El método de imputación, no es media/mediana agrupada por país o uso de suelo, ni KNN, ni interpolación espacial. El procedimiento real, aplicado en este orden, es el siguiente:

+ Se eliminan las filas sin coordenadas (`latitude`/`longitude`).
+ Los recuentos ecológicos con prefijo `ew_`, `macro_`, `orib_`, `meso_`, `coll_`, `nuid_`, `uvigo_` se imputan a *0* cuando faltan, bajo el supuesto de que la ausencia de dato equivale a ausencia real de la especie/taxón en el muestreo, no a un valor perdido en sentido estadístico.
+ Para el resto de variables numéricas: las que tienen *menos del 5%* de valores perdidos se imputan con la *mediana global* de la columna, sin añadir indicador.
+ Las que tienen *entre el 5% y el 50%* de valores perdidos se imputan también con la mediana global, pero además se añade una columna binaria `[variable]_was_missing`.
+ Las variables con *más del 50%* de valores perdidos se eliminarían del _dataset_ antes de este paso.
+ Las variables categóricas se imputan con la *moda*.

Es decir, la imputación es una *mediana global simple* (no condicionada por país ni por uso de suelo), acompañada de indicadores de "dato perdido" únicamente para el rango 5-50%. Esto tiene una implicación directa sobre las correlaciones calculadas en la sección de análisis bivariante y multivariante: al no preservar la estructura de covarianza entre variables (a diferencia de un método KNN), la imputación por mediana global puede atenuar ligeramente algunas correlaciones reales, lo cual debería mencionarse como limitación metodológica al citar los coeficientes de Pearson de este anexo.

#colbreak()

==== El indicador de calidad `outlier_flag` <outlier>

`outlier_flag` presenta la siguiente distribución en el _dataset_: 347 parcelas marcadas como `True` frente a 81 como `False` (81.1% / 18.9%).

#figure(
  align(center)[
    #image("../media/eda/13_outlierflag_pais.png", height: 35%)
  ],
  caption: [Gráfica de `outlier_flag` por país.],
  kind: image
)<fig-6>

El patrón de `outlier_flag` por país (#ref(<tab-13>) y #ref(<fig-6>), calculada directamente sobre el dataset limpio) indica su uso como un control de calidad que varía sistemáticamente según el origen de los datos.

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
        [*IT*],[0], [2], [0.0%],
    )
  ],
  caption:[Tabla de distribución de `outlier_flag` por país.],
  kind: table
)<tab-13>

Cuatro países (Suiza, Israel, Eslovenia e Italia, el 45% de las parcelas del _dataset_) no presentan ni un solo caso `False`, mientras que Rumanía tiene una proporción casi equilibrada (51% `False`). Esta discrepancia tan marcada entre países es evidencia empírica directa de que `outlier_flag` no debe usarse como filtro de outliers estadístico genérico sin condicionar por país u origen de los datos: para los cuatro países sin ningún `False`, la columna no aporta ninguna capacidad discriminativa fila a fila.

#colbreak()

*`outlier_flag` no se construye con Isolation Forest ni Z-score*, pese a que así lo describen el diccionario de datos y una revisión anterior de este mismo informe EDA. El código real (`data-prep.ipynb`, sección 11.3, "Detección de Outliers") es el siguiente:

```python
def iqr_outlier_mask(series, factor=3.0):
    Q1, Q3 = series.quantile(0.25), series.quantile(0.75)
    IQR = Q3 - Q1
    return (series < Q1 - factor * IQR) | (series > Q3 + factor * IQR)

df_clean['outlier_flag'] = False
for col in df_clean.select_dtypes(include=np.number).columns:
    df_clean['outlier_flag'] |= iqr_outlier_mask(df_clean[col])
```

Es decir, `outlier_flag` se construye con el *mismo método IQR de Tukey* descrito en la sección de valores atípicos de este anexo (no con Isolation Forest ni Z-score), pero con dos diferencias importantes respecto al criterio "estándar" de esa sección:

+ *Factor ampliado (3.0 en lugar de 1.5).* El multiplicador habitual de Tukey es 1.5; aquí se usa 3.0, un criterio más laxo columna a columna.
+ *Evaluación conjunta sobre prácticamente todas las columnas numéricas del _dataset_ limpio en ese punto del pipeline (113 columnas)*, incluyendo las 36 columnas indicador `_was_missing` añadidas en el paso de imputación, mediante un operador lógico *OR* fila a fila: una parcela se marca `outlier_flag = True` si es atípica, según el criterio IQR ampliado, en *al menos una* de esas 113 columnas.

Esta segunda diferencia explica dos cosas a la vez: *(a)* por qué el porcentaje global de `True` es tan alto (81.1%) pese a que el factor 3.0 es más estricto que el 1.5 habitual — al combinarse 113 pruebas independientes con un OR, basta con ser atípico en una sola variable de las 113 para quedar marcado; y *(b)* por qué el patrón por país es tan heterogéneo — si un país completo presenta un valor sistemáticamente distinto en aunque sea una única covariable (por ejemplo, una capa `eu_*`, `gee_*` o `dem_*` extraída por coordenadas, con cobertura o resolución distinta por región), es muy probable que todas o casi todas sus parcelas queden marcadas como atípicas en esa columna, y por tanto `True` en `outlier_flag`, sin que ello implique nada anómalo sobre la biodiversidad o las propiedades del suelo en sí.

El propio informe de outliers de `data-prep.ipynb` muestra además que las columnas con más recuentos de "atípicos" son, precisamente, columnas indicador binarias: `eu_as_was_missing` (103 filas, 24.1%), `eu_zn_was_missing` (102, 23.8%), `earthworm_shannon_was_missing` / `earthworm_abundance_was_missing` / `earthworm_richness_was_missing` (101 cada una, 23.6%), entre otras. Es decir, el sesgo de aplicar IQR directamente sobre flags binarios muy desbalanceados —que el diccionario de datos presentaba como el problema que Isolation Forest + Z-score evitaría— *ocurre de facto*: una parte no despreciable de las parcelas marcadas `outlier_flag = True` lo están porque tenían un dato imputado en alguna variable con ~24% de imputación (donde el valor "1", minoritario, se comporta como atípico bajo el criterio IQR), no porque sus valores biológicos o edáficos fueran extremos.

Se recomienda corregir la descripción de `outlier_flag` en el cuerpo principal y en el diccionario de datos, sustituyendo la referencia a Isolation Forest + Z-score por la descripción precisa del filtro IQR con factor 3.0 y agregación OR sobre 113 columnas. Se mantienen a continuación las definiciones conceptuales de Isolation Forest y Z-score porque son relevantes como referencia de un enfoque alternativo válido para trabajo futuro, no porque describan el método realmente usado.

El *Isolation Forest* es un algoritmo de detección de anomalías no supervisado que construye múltiples árboles de decisión aleatorios y mide cuántas particiones hacen falta para aislar cada observación del resto: los puntos atípicos, al ser diferentes de la mayoría, tienden a aislarse con muy pocas particiones, mientras que los puntos típicos necesitan muchas más particiones para separarse del grueso de los datos. A diferencia del método IQR, que evalúa cada variable de forma aislada, el Isolation Forest puede considerar varias variables a la vez, detectando combinaciones inusuales de valores que individualmente no serían atípicos — una propiedad que, de hecho, habría evitado el problema de agregación por OR descrito arriba, y que podría explorarse como mejora en trabajo futuro para sustituir la construcción actual de `outlier_flag`. El umbral de tipo *Z-score* mide a cuántas desviaciones estándar se encuentra un valor respecto a la media de su variable (Z = (x menos la media) dividido entre la desviación estándar); un Z-score alto en valor absoluto (típicamente por encima de 3) se interpreta como indicio de valor atípico, pero no es el criterio realmente aplicado en este pipeline.

#colbreak()

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

Cuando una variable tiene una distribución muy asimétrica (con una cola larga de valores altos, como suele ocurrir con metales pesados o contaminantes), representarla en escala lineal hace que la mayoría de las parcelas (con valores bajos, cercanos entre sí) queden aplastadas visualmente contra el eje, mientras unas pocas parcelas extremas dominan el rango del gráfico. Aplicar una transformación logarítmica comprime los valores altos y expande los valores bajos, permitiendo comparar de un vistazo la forma de la distribución de `As`, `Cu`, `K`, `Mo`, `Ni`, `P`, `Pb` y `Zn` en un mismo gráfico, algo que sería ilegible en escala lineal dado que algunos metales (por ejemplo K) tienen concentraciones órdenes de magnitud mayores que otros (por ejemplo As).

De cara al modelado, algunos algoritmos (en particular la Regresión Ridge, que asume relaciones lineales) se benefician de trabajar con variables cuya distribución se aproxime más a la normal, por lo que aplicar una transformación logarítmica de tipo `log1p` a estas variables antes de entrenar es una opción a considerar, más allá de la visualización de este EDA. Esta recomendación es además coherente con lo observado en la sección del indicador `outlier_flag`: si el filtro se recalculara tras una transformación `log1p` de estas variables asimétricas, es previsible que el número de columnas que contribuyen "falsos" atípicos por asimetría natural (no por error de medición) se reduzca.

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
  caption: [Gráfica de carbono y nitrógeno.],
  kind: image
)<fig-10>

#colbreak()

==== Biodiversidad edáfica <biodiversidad-edafica>

Los 11 índices de Shannon presentes en el _dataset_ (uno por grupo taxonómico: nematodos, macrofauna, lombrices, oribátidos, mesofauna, colémbolos, bacterias, hongos, eucariotas, oomicetos y cercozoos) son la medida de biodiversidad más habitual en ecología y constituyen la mayoría de los targets del modelo.

Se calculan como *H' = menos la suma de pᵢ por el logaritmo natural de pᵢ*, donde *pᵢ* es la proporción de individuos (o de lecturas genéticas, en el caso de los grupos microbianos) que pertenecen a la especie o taxón i dentro de la comunidad muestreada en una parcela.

Un valor de Shannon bajo indica una comunidad dominada por pocas especies (baja diversidad); un valor alto indica una comunidad más equitativa entre muchas especies (alta diversidad). A diferencia de un simple recuento de especies (riqueza), el índice de Shannon también penaliza la dominancia de unas pocas especies sobre las demás, por lo que dos parcelas con el mismo número de especies pueden tener índices de Shannon muy distintos si en una de ellas una sola especie domina abrumadoramente.

La siguiente gráfica compara la distribución de estos 11 índices entre sí:

#figure(
  align(center)[
    #image("../media/eda/07_shannon.png", height: 30%)
  ],
  caption: [Gráfica de Shannon por grupo taxonómico.],
  kind: image
)<fig-11>

Se observa que los distintos grupos taxonómicos ocupan rangos de Shannon bastante diferentes entre sí (por ejemplo, los grupos microbianos, bacterias y hongos, tienden a mostrar valores más altos y menos dispersos que la fauna macroscópica), lo cual es coherente con la altísima riqueza de especies típica de las comunidades microbianas del suelo frente a grupos de fauna con menos taxones potenciales por parcela. Esta heterogeneidad entre grupos es uno de los argumentos a favor de modelar cada índice por separado en lugar de asumir que se comportan de forma equivalente; véase la discusión sobre correlación entre targets en la sección #link(<correlacion-shannon>)[*Correlación entre targets (índices Shannon)*].

Junto a los 11 índices Shannon, los 10 targets de riqueza/ASV restantes son: `macro_order_richness_z`, `earthworm_richness_z`, `orib_species_richness_z`, `meso_species_richness_z`, `coll_species_richness_z`, `bac_asv_richness_z`, `fun_asv_richness_z`, `euk_asv_richness_z`, `oomy_asv_richness_z` y `cerc_asv_richness_z`, completando así los 21 targets del modelo (constante `TARGETS`; véase también el catálogo de la sección #link(<var-cat>)[*Catálogo de variables*]).

#colbreak()

=== Variables por uso de suelo <var-uso-suelo>

Medianas recalculadas tras normalizar el espacio en blanco de `land_use_type` (véase la sección #link(<var-descartadas>)[*Variables excluidas de la selección final*]).

*Mediana de pH por uso de suelo:*

En la #ref(<tab-14>) se muestra la mediana de pH por uso de suelo.

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

En la #ref(<tab-15>) se muestra la mediana de carbono orgánico por uso de modelo.

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

En la #ref(<fig-12>) se puede ver de forma gráfica los datos de las tablas anteriores.

#figure(
  align(center)[
    #image("../media/eda/08_uso_suelo_ph_c.png", height: 30%)
  ],
  caption: [pH y carbono orgánico por uso de suelo.],
  kind: image
)<fig-12>

Estas diferencias claras por `land_use_type` (Wetland más que duplica el carbono orgánico mediano de Arable) refuerzan la duda señalada en la sección de variables descartadas: si `land_use_type` no se está incluyendo como predictor, ni siquiera codificado, podría estar dejándose fuera una variable con señal real.

Los suelos de *`Forest`* presentan el pH mediano más bajo (4.33, moderadamente ácido) porque la descomposición de hojarasca y acículas libera ácidos orgánicos y porque no reciben encalado agrícola; en el otro extremo, *`Urban`* (6.89) y *`Wetland`* (6.55) tienden a valores más neutros, en el caso urbano por la influencia de materiales de construcción alcalinos en el entorno edáfico, y en el caso de los humedales por procesos de acumulación de bases en condiciones de saturación hídrica.

En cuanto al carbono orgánico, que *`Wetland`* (10.23) más que duplique al resto de usos es un patrón clásico en ciencia del suelo: la saturación de agua limita la disponibilidad de oxígeno, ralentizando drásticamente la descomposición microbiana de la materia orgánica y provocando su acumulación a largo plazo, el mismo proceso que da lugar a las turberas. Por contraste, `Arable` presenta el carbono orgánico más bajo (2.51) porque el laboreo agrícola repetido airea el suelo, acelera la descomposición de la materia orgánica y habitualmente exporta biomasa (cosechas) que no vuelve al sistema. Este contraste, tan marcado y ecológicamente bien fundamentado, es el argumento más fuerte para reconsiderar la exclusión de `land_use_type` como predictor del modelo.

=== Valores atípicos (outliers, método IQR) <outliers-iqr>

El rango *intercuartílico (IQR)* es una medida de dispersión robusta frente a valores extremos, definida como $"IQR" = "Q3" minus "Q1"$, donde Q1 y Q3 son el primer y tercer cuartil (percentiles 25 y 75) de la variable. El *criterio estándar de Tukey* marca como atípico cualquier valor por debajo de Q1 menos 1.5 veces el IQR o por encima de Q3 más 1.5 veces el IQR: el multiplicador 1.5 es una convención (no un umbral estadístico con una probabilidad asociada) que, para una distribución aproximadamente normal, marcaría como atípico en torno al 0.7% de los datos, pero que puede marcar un porcentaje mucho mayor en variables muy asimétricas como los metales o las abundancias biológicas de este _dataset_. De ahí la recomendación de valorar una transformación logarítmica antes de aplicar este criterio.

La tabla siguiente usa el criterio *estándar* de Tukey (factor 1.5), distinto del filtro con factor 3.0 usado para construir la columna `outlier_flag` (véase sección del indicador `outlier_flag`): esta tabla ilustra qué variables individuales son más problemáticas bajo el criterio académico estándar, mientras que dicha sección documenta el criterio realmente implementado en el pipeline para esa columna del _dataset_.

*Variables continuas con más outliers detectados mediante el método IQR estándar* (excluyendo códigos categóricos numéricos):

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
        [*eu_water_holding_capacity*],  [49],
        [*orib_total_abundance*],       [48],
    )
  ],
  caption: [Variables con mayor cantidad de outliers.],
  kind: table
)<tab-16>

Las variables de concentración de metales y de abundancia biológica, como se puede ver en #ref(<tab-16>) suelen estar sesgadas de forma natural.

#colbreak()

=== Análisis bivariante y multivariante <analisis-bivariante-multivariante>

==== Correlaciones entre propiedades físico-químicas <fisico-quimicas>

El *coeficiente de correlación de Pearson (r)* mide la fuerza y dirección de la relación lineal entre dos variables continuas, y varía entre -1 (relación lineal negativa perfecta) y +1 (relación lineal positiva perfecta), con 0 indicando ausencia de relación lineal, aunque podría existir una relación no lineal no capturada por este coeficiente. Cuando dos o más variables predictoras están altamente correlacionadas entre sí (colinealidad), un modelo de regresión lineal como Ridge tiene dificultades para atribuir el efecto sobre el target a una u otra variable de forma estable: pequeños cambios en los datos de entrenamiento pueden hacer que los coeficientes estimados oscilen mucho, aunque la predicción global del modelo siga siendo razonable. La regularización Ridge reparte el peso entre variables correlacionadas en lugar de concentrarlo arbitrariamente en una sola, lo que estabiliza la estimación a costa de introducir un sesgo controlado.

En la #ref(<tab-17>) se pueden ver los pares de variables con mayor correlación (valor absoluto) y en la #ref(<fig-13>) se pueden ver los niveles de correlación entre las diferentes variables físico-químicas.

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

#colbreak()

Estas correlaciones muy altas (0.95 a 0.98 entre las tres variables de carbono/nitrógeno del plot) son la evidencia empírica directa que justifica el uso de Ridge y la necesidad de regularización mencionada en la sección #link(<regresion-ridge>)[*Regresión Ridge*]; también explican, junto al patrón sistemático de la sección de variables descartadas, por qué `plot_total_c` es precisamente una de las 12 variables no seleccionadas: al estar casi perfectamente correlacionada con `plot_total_organic_c` (r=0.976), aporta poca información adicional como predictora.

Esta justificación queda reforzada, además, por los propios valores de `alpha` que selecciona el ajuste de hiperparámetros de Ridge para los 21 modelos de producción: valores muy alejados de 0 (entre ≈106 y ≈720, según el target), lo que indica empíricamente que una regularización sustancial es necesaria para mantener el hueco train-CV por debajo del umbral de estabilidad fijado (0.10), coherente con la colinealidad detectada en esta sección. 

La matriz de correlación completa (véase #ref(<fig-13>)) muestra además que `sand_content` correlaciona negativamente y con fuerza tanto con `silt_content` como con `clay_content`, una relación mecánica esperable ya que las tres fracciones granulométricas suman aproximadamente el 100%, lo que añade un tercer bloque de colinealidad relevante más allá de C/N y Mo/Ni.

#colbreak()

==== Correlación entre _targets_ (índices Shannon) <correlacion-shannon>

Un modelo multisalida predice varios _targets_ a la vez compartiendo una representación interna común, en lugar de entrenar un modelo independiente por cada target. 

La justificación teórica habitual para preferir el enfoque multisalida es que, *si los _targets_ están correlacionados entre sí, aprender a predecir uno aporta información útil para predecir los demás*, reduciendo la varianza del modelo con el mismo número de datos de entrenamiento. Esta es la lógica que motivaba la hipótesis de partida del TFG. El análisis que sigue pone a prueba esa hipótesis midiendo empíricamente cuán correlacionados están realmente los 21 _targets_ entre sí.

En la #ref(<tab-18>) se muestran los _targets_ se muestran un mayor nivel de correlación absoluta, junto con la gráfica de correlaciones de todos los _targets_, mostrado en la #ref(<fig-18>).

#figure(
  align(center)[
    #table(
      columns: (auto,25%),
      align:(left+horizon, center+horizon),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da")},
      table.header(
        table.cell(align: center)[*Par de _targets_*],
        table.cell(align: center)[*Correlación (abs)*],
      ),
        [*orib_shannon / meso_shannon*],       [0.383],
        [*meso_shannon / coll_shannon*],       [0.312],
        [*macro_shannon / nematode_shannon*],  [0.227],
        [*cerc_shannon / oomy_shannon*],       [0.208],
    )
  ],
  caption: [_Targets_ con mayor nivel de correlación absoluto.],
  kind: table
)<tab-18>

#figure(
  align(center)[
    #image("../media/eda/10_corr_shannon.png", height: 40%)
  ],
  caption: [Gráfica de correlación de los índices Shannon.],
  kind: image
)<fig-14>

Este es probablemente el resultado más relevante de todo el EDA para la discusión del TFG: las correlaciones entre _targets_ son modestas (máximo 0.38), no altas. 

La matriz completa (véase #ref(<fig-18>)) confirma que este patrón se extiende al resto de pares: ningún par de los 11 índices Shannon supera r=0.4, y la mayoría se sitúan por debajo de 0.2. Esto matiza la hipótesis de partida sobre las ventajas esperables del modelado multisalida: si los _targets_ no están fuertemente correlacionados entre sí. 

#colbreak()

==== Relación suelo-biodiversidad <relacion-suelo-bio>

#figure(
  align(center)[
    #image("../media/eda/11_suelo_vs_biodiv.png")
  ],
  caption: [Gráfica de suelo vs. biodiversidad.],
  kind: image
)<fig-15>

En la #ref(<fig-15>) muestra la relación entre cuatro variables edáficas representativas (`pH`, `carbono orgánico`, `contenido en arcilla` y `estabilidad de agregados`) y cuatro índices de biodiversidad de distintos grupos taxonómicos (`oribátidos`, `macrofauna`, `bacterias` y `nematodos`), con el coeficiente de correlación de Pearson indicado en cada panel. 

En línea con lo observado en la sección anterior para los _targets_ entre sí, las relaciones directas entre variables edáficas individuales y los índices de biodiversidad son en general débiles, con la mayoría de los coeficientes por debajo de 0.3 en valor absoluto, sin que ningún par destaque con una relación claramente fuerte. Esto es coherente con la naturaleza ecológica del problema: la biodiversidad edáfica rara vez responde de forma lineal a una única covariable, sino a combinaciones de factores (textura, pH, disponibilidad de nutrientes, uso del suelo, clima), lo que refuerza la necesidad de modelos no lineales y multivariantes, como los árboles de decisión y ensembles ya empleados en la #link(<capa-modelado>)[*Capa de modelado predictivo*], frente a un enfoque de regresión lineal simple variable a variable.

#colbreak()

==== Consistencia entre mediciones propias y capas de referencia externas (SOB4ES vs. capas EU) <refs-externas>

ESDAC (European Soil Data Centre) y CORINE (Coordination of Information on the Environment) son bases de datos europeas de referencia que ofrecen mapas de variables edáficas y de cobertura del suelo a escala continental, generados a partir de modelos estadísticos que interpolan un número limitado de puntos de muestreo real sobre una malla regular. Su ventaja es la cobertura espacial completa y homogénea de toda Europa sin necesidad de muestrear cada punto; su limitación inherente es que, al ser un valor interpolado y no una medición directa, no capturan la variabilidad edáfica real a escala de parcela, que puede ser muy alta especialmente en variables con patrones de distribución muy localizados como los micronutrientes o los contaminantes.

En la #ref(<tab-19>), se muestra la correlación entre la medición propia (_in situ_, SOB4ES) y la capa de referencia externa equivalente (ESDAC/CORINE), por variable, verificada sobre los datos reales. Además, en la #ref(<fig-16>) se pueden ver las correspondientes gráficas de consistencia.

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
    #image("../media/eda/12_consistencia_eu.png")
  ],
  caption: [Gráficas de consistencia con capas externas.],
  kind: image
)<fig-16>

Estas correlaciones son, en el mejor de los casos, moderadas (arena, arcilla) y en el peor débiles (fósforo, arsénico). 

Este es un resultado con conexión directa a los #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*] del TFG: apoya empíricamente, con datos propios, la conclusión de Phillips et al.#sub([@phillipsEarthwormDiversity]) de que los datos _in situ_ de alta calidad aportan información que las capas globales derivadas no capturan.

La #ref(<fig-16>) confirma además que, para fósforo y arsénico en particular, la nube de puntos se aleja considerablemente de la diagonal 1:1, lo que indica que la capa externa tiene menor resolución y precisión que la medición directa y debe tratarse como covariable de contexto y no como validación independiente de la medición _in situ_. 

La cobertura real de estas capas, verificada en el _dataset_ limpio, también es relevante aquí: `eu_p`, `eu_ph`, `eu_cn_ratio`, `eu_k` y `eu_n` solo cubren un 72.9% de las 428 parcelas antes de imputar (116 valores perdidos cada una), y `eu_as`, `eu_cu`, `eu_ni`, `eu_pb`, `eu_zn` entre el 75.9% y el 76.4%. Esta cobertura incompleta, combinada con la imputación por mediana global de la sección de valores faltantes, añade una fuente adicional de ruido a las correlaciones de esta tabla que debería mencionarse junto a la limitación de resolución espacial ya señalada.

#colbreak()

=== Conclusiones del EDA <conclusiones-EDA>

- El catálogo completo de las 84 variables del _dataset_ (véase #link(<var-cat>)[*Catálogo de variables*]) confirma que las 34 predictoras y 21 _targets_ finales (55 en total) se seleccionan de forma manual, no automatizada, a partir de las 67 variables numéricas normalizadas.
- El _dataset_ limpio no presenta valores nulos remanentes. El método es imputación por mediana global (no por grupo, no KNN, no espacial), con indicador `_was_missing` solo para variables con 5-50% de valores perdidos, y relleno a 0 para recuentos ecológicos ausentes.
- La distribución geográfica está desbalanceada por país (Italia con solo 2 parcelas frente a las 45-51 de otros países).
- Existe colinealidad fuerte y confirmada entre variables de carbono/nitrógeno (r > 0.95), entre fracciones granulométricas (r > 0.8, con relación mecánica esperable entre arena, limo y arcilla) y entre Mo y Ni (r = 0.77), lo que justifica empíricamente el uso de regularización (Ridge) y la tolerancia a colinealidad exigida a los modelos de árboles.
- La correlación entre los índices Shannon es, en general, baja (máximo 0.38 entre oribátidos y mesofauna, la mayoría por debajo de 0.2), lo que matiza, sin invalidar necesariamente, la hipótesis de partida sobre las ventajas del modelado multisalida. Las relaciones bivariadas suelo-biodiversidad son igualmente débiles, lo que refuerza la necesidad de modelos no lineales y multivariantes, y es coherente con el bajo rendimiento en algunos de los modelos sobre `eval.csv`.
- La consistencia entre mediciones _in situ_ y capas de referencia europeas es de moderada a baja según la variable (0.19-0.61), aportando evidencia propia a favor de la ventaja informativa de los datos _in situ_ ya discutida en #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*]. Esta consistencia limitada coincide además con una cobertura incompleta de las capas EU (72.9%-76.4% antes de imputar).
- `outlier_flag` (347 `True` / 81 `False`) no se genera mediante Isolation Forest ni Z-score, sino mediante un filtro IQR con factor ampliado (3.0) aplicado a 113 columnas numéricas (incluidas las 36 columnas indicador `_was_missing`) y agregado mediante un OR fila a fila. Esto explica tanto el porcentaje global tan alto de `True` (81.1%) como la fuerte heterogeneidad por país: Suiza, Israel, Eslovenia e Italia no presentan ningún caso `False`, mientras que Rumanía tiene una proporción casi equilibrada (51% `False`). *No debe usarse como filtro de outliers*.
- De las 84 columnas del _dataset_ limpio, 13 son identificadores/metadatos categóricos descartados, 4 se conservan sin escalar (`site_id`, `latitude`, `longitude`, `outlier_flag`) y 67 son variables numéricas normalizadas (`_z`) en el _dataset_ escalado. El subconjunto final de 34 predictoras + 21 _targets_ (55 variables) se selecciona a partir de estas 67, no directamente de las 84.
