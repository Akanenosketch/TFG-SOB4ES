== Notebooks de preparación de datos (Anexo III) <preparacion-de-datos>

=== _Notebook_ de ingesta de datos en ficheros <ficheros-locales>

==== Fundamento y configuración
 
Es el primer _notebook_ de la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*]: integra las 428 muestras del proyecto SOB4ES (12 países europeos) a partir de más de una decena de ficheros Excel independientes los cuales contienen, entre otros, metadatos de sitio, propiedades físicas y químicas del suelo, comunidades biológicas de 10 grupos taxonómicos distintos (nemátodos, macrofauna, lombrices, oribátidos, mesostigmátidos, colémbolos, bacterias, hongos, eucariotas, oomycetes y cercozoa) y una capa de variables raster europeas (`eu_*`) ya extraídas. 
 
==== Metodología
 
El proceso sigue cuatro fases: 

+ *Normalización de nombres:* Una función `_to_snake()` convierte todos los nombres de columna (incluyendo casos con acrónimos como `pH` o `CN`) a `snake_case` de forma consistente entre las 15 fuentes. 
+ *Cálculo de índices de diversidad alfa:* Se calculan los índices de la abundancia total, la riqueza de especies y el índice de Shannon $H' = -sum_i p_i ln(p_i)$  calculados de forma independiente para cada grupo taxonómico a partir de su matriz de abundancias por especie. 
+ *Fusión de fuentes:* de las 15 fuentes sobre la tabla de metadatos de sitio mediante `left join` mediante `site_id`, verificando en todo momento que no se pierden ni duplican filas;
+ *Limpieza de los datos:*, que cubre valores perdidos, valores fuera de rango físico y duplicados.
 
Para uno de los _targets_ prioritarios, `earthworm_shannon_z`, el _notebook_ realiza un tratamiento especialmente cuidadoso: los datos de abundancia de lombrices provienen de *dos institutos distintos* (`NUID/UCD` y UVIGO, cada uno responsable de un subconjunto de países), que se procesan por separado y se combinan al final. Antes de aceptar el resultado, se ejecuta además una *verificación cruzada* frente al archivo oficial combinado (`DD2.2.7_EARTHWORMS_COM.xlsx`) que el propio proyecto SOB4ES distribuye.
 
Para los valores perdidos se sigue una estrategia diferenciada: los conteos ecológicos (prefijos `ew_`, `macro_`, `orib_`, `meso_`, `coll_`) se rellenan con 0, las variables continuas con menos de un 5% de `NaN` se imputan con la mediana sin más y las que tienen entre un 5% y un 50% de `NaN` se imputan con la mediana pero además generan una columna indicadora `_was_missing` (0/1), de forma que el modelo pueda aprender que la propia ausencia del dato ya es informativa. 

Los valores fuera de los límites físicos plausibles (por ejemplo, un pH fuera de \[0, 14\] o un porcentaje de textura fuera de \[0, 100\]) se recortan (`clip`) a su límite válido más cercano.
 
==== Resultados
 
*Hallazgo de calidad de datos:* la verificación cruzada de lombrices detectó que el archivo oficial combinado (`DD2.2.7`) estaba *inflado o mal calculado en 268 de los 298 sitios comparables (90%)*, con desfases de hasta +3.227 individuos en un mismo sitio (`ES_013`). 

Ante esta discrepancia, se optó por *descartar el archivo oficial combinado* y quedarse con la matriz de abundancias reconstruida directamente desde los ficheros crudos de `NUID` (218 sitios) y `UVIGO` (162 sitios), consolidados en 380 sitios únicos tras eliminar duplicados. 

En la #ref(<tab-32>) se pueden ver de forma resumida los resultados obtenidos tras la ejecución de este _notebook_ de preparación de datos.

#colbreak()

#figure(
  align(center)[
    #table(
      columns: (auto, auto),
      align: (left, center),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },
      table.header(
        table.cell(align: center)[*Etapa*], [*Resultado*]),
        [*Fuentes integradas*], [15 (13 locales + 2 combinaciones agregadas)],
        [*Forma tras la fusión*], [428 filas × 103 columnas],
        [*Columnas eliminadas (redundantes / artefactos / EU con \<80% cobertura / taxa individuales)*], [29],
        [*Forma tras limpieza de columnas*], [428 filas × 74 columnas],
        [*Filas eliminadas por falta de coordenadas*], [0],
        [*Indicadores `_was_missing` añadidos*], [32],
        [*NaN restantes tras imputación*], [0],
        [*Valores fuera de rango truncados*], [`aggregate_stability`: 36 valores],
        [*Filas con suma de texturas fuera de \[95, 105\]%*], [40 (renormalizadas al 100%)],
        [*Filas marcadas como outlier (IQR, factor 3)*], [341 (79.7%)],
        [*Variables escaladas (`_z`)*], [61],
    )
  ],
  caption: [Resultados de la preparación de datos en ficheros.],
  kind: table
)<tab-32>
 
La exportación final produce tres ficheros: 
+ `sob4es_clean_vx.csv` ($428 times 75$, escala original, para inspección), 
+ `sob4es_model_ready_vx.csv` ($428 times 65$, solo variables `_z` + `outlier_flag`, para el modelado) y 
+ `sob4es_imputation_flags_vx.csv` ($428 times 33$, los indicadores `_was_missing` por separado). 

#rect[*Nota:*\ La *x* en `nombre_archivo_vx` hace referencia al *número de versión del archivo*, al haber probado con varias iteraciones del procesamiento antes de proceder a la siguiente fase de la preparación de datos.]

El elevado porcentaje de filas marcadas como outlier (79.7%) no implica que se descarten. Se conserva como una columna informativa (`outlier_flag`) para que los propios modelos, o un análisis posterior, puedan tenerlo en cuenta, en vez de eliminar automáticamente cuatro de cada cinco muestras de un dataset ya de por sí reducido.

#let file = "../media/anexos/data-prep.pdf"
#let total_pages = 19 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}


=== _Notebook_ de ingesta de datos de fuentes remotas <ficheros-remotos>

==== Fundamento y configuración
 
Complementa a `data-prep` con variables que no forman parte de los ficheros locales del proyecto SOB4ES, obtenidas en el momento de la ejecución desde tres servicios remotos descritos en la #link(<capa-ingesta>)[*Capa de ingesta de datos*]: *Google Earth Engine* (clima y vegetación), *Copernicus Climate Data Store* (precipitación) y *Copernicus DEM* (elevación y topografía, vía tiles públicos en AWS, sin autenticación).
 
Cada fuente se define de forma declarativa mediante un diccionario de registro (`GEE_LAYERS`, `CDS_LAYERS`, `DEM_LAYERS`) que especifica, por variable: la colección o dataset de origen, las bandas necesarias, la unidad y el rango físico válido, de forma que añadir una nueva variable remota en el futuro solo requiera añadir una entrada al diccionario correspondiente, sin tocar el resto del código de extracción.
 
==== Metodología
 
De *Google Earth Engine* se extraen 3 variables sobre los 428 puntos de muestreo: *temperatura media anual* y *humedad relativa media anual* (ambas de `ECMWF/ERA5_LAND/DAILY_AGGR`, periodo 2015-2020), y el *NDVI medio de verano* (de `COPERNICUS/S2_SR_HARMONIZED`, filtrando imágenes Sentinel-2 con menos de un 20% de nubosidad). 

De *Copernicus DEM* se extraen *elevación*, *pendiente* y *orientación*, leyendo directamente el tile COG correspondiente a cada punto vía `/vsicurl/` (sin descarga previa) y calculando pendiente/orientación mediante el método de diferencias centrales de Horn (1981) sobre una ventana $3 times 3$ alrededor del punto. 

De *Copernicus CDS* se intenta extraer la precipitación mensual media (`reanalysis-era5-land-monthly-means`, 2015-2020).
 
==== Resultados

#figure(
  align(center)[
    #table(
      columns: (auto, auto, auto),
      align: (left, center, center),
      fill: (col, row) => if row == 0 { rgb("d6e3da") },
      table.header(
        table.cell(align: center)[*Variable*], 
        [*Fuente*], 
        [*Cobertura*]),
      [*`gee_temp_media_C`*],    [GEE / ERA5-Land],  [99.8% (427/428)],
      [*`gee_humedad_rel_pct`*], [GEE / ERA5-Land],  [99.8% (427/428)],
      [*`gee_ndvi_verano`*],     [GEE / Sentinel-2], [97.9% (419/428)],
      [*`dem_elevacion_m`*],     [Copernicus DEM],   [99.1% (424/428)],
      [*`dem_pendiente_deg`*],   [Copernicus DEM],   [99.1% (424/428)],
      [*`dem_orientacion_deg`*], [Copernicus DEM],   [99.1% (424/428)],
      [*`cds_precip_mm_mes`*],   [Copernicus CDS],   [*0.0% (0/428)*],
    )
  ],
  caption: [Porcentaje de cobertura de los datos objetivos por fuentes remotas.],
  kind:table
) <tab-33>
 
Como de puede ver en la #ref(<tab-33>), variable de precipitación (`cds_precip_mm_mes`) obtuvo una cobertura del 0% sobre los 428 sitios, por lo que el propio proceso de limpieza (`_drop_empty_cols`) la descarta antes de exportar: no llega a incorporarse al dataset final ni a `FEATURES_AUTORIZADAS`, de ahí que ninguno de los modelos entrenados use ninguna variable con prefijo `cds_`. 

El resto de variables _online_ (GEE y DEM) sí superaron ampliamente el umbral del 80% de cobertura. El archivo exportado, `online_features_vx.csv`, contiene finalmente 428 filas × 7 columnas (`site_id` + 3 GEE + 3 DEM).

#let file = "../media/anexos/data-prep-online.pdf"
#let total_pages = 9 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== _Notebook_ de integración de fuentes <mixin-de-datos>

==== Fundamento y configuración
 
Cierra la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*] combinando la salida de `data-prep` (datos locales limpios) con la de `data-prep-online` (variables remotas), y reorganiza el resultado en un orden lógico por bloques temáticos antes de producir los dos ficheros finales que consume el resto del proyecto.
 
==== Metodología
 
Tras verificar la integridad de las claves `site_id` en los tres ficheros de entrada (`sob4es_clean_vx.csv`, `sob4es_model_ready_vx.csv`, `online_features_vx.csv`) y comprobar que no quedan nombres de columna con patrones de fusión rotos, se realiza un `left join` de `clean` con `online` por `site_id`. 

Las variables _online_ numéricas siguen la misma política de imputación por tramos ya usada en `data-prep` (indicador `_was_missing` para 5-50% de NaN, mediana para el resto) y se escalan con un `StandardScaler` *independiente* del usado para las variables locales (`scaler_online.pkl`, separado de `scaler.pkl`), antes de reordenar todas las columnas en bloques lógicos (geografía → descripción del sitio → abiótico → diversidad alfa → fauna → microbioma → teledetección/DEM → rasters EU → metadatos).
 
==== Resultados

En la #ref(<tab-34>) se pueden ver los datasets resultantes tras ejecutar el _notebook_.
 
#figure(
  align(center)[
    #table(
      columns: (auto, auto),
      align: (left, center),
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") },
      table.header(
        table.cell(align: center)[*Fichero de salida*], 
        [*Tamaño*]
        ),
      [*`sob4es_final_clean.csv`*], [428 filas × 84 columnas],
      [*`sob4es_final_model_ready.csv`*], [428 filas × 71 columnas (67 `_z`)],
    )
  ],
  caption: [Resultados de la ejecución del _notebook_ de combinación de datos.],
  kind: table
)<tab-34> 

La imputación de las variables _online_ no necesitó generar ningún indicador `_was_missing` nuevo (0 columnas), al quedar todas las variables restantes (una vez descartada `cds_precip_mm_mes`) por debajo del umbral del 5% de valores perdidos. 

El NaN total en ambos ficheros de salida es 0. 

El desglose final por fuente confirma la composición del dataset que efectivamente llega a los notebooks de modelado: 
- 15 columnas de rasters EU. 
- 12 de metadatos de sitio. 
- 9 abióticas químicas. 
- 6 abióticas físicas.  
- Entre 3 y 4 columnas por cada uno de los 10 grupos taxonómicos.
- 6 variables _online_ (3 GEE + 3 DEM).  

Este `sob4es_final_model_ready.csv` es, precisamente, el fichero del que parte el _notebook_ `data-prep-div` (véase #link(<data-div-notebook>)[*_Notebook_ de división de datos*]) para generar `train.csv`, `test.csv` y `eval.csv`.

#let file = "../media/anexos/data-prep-combination.pdf"
#let total_pages = 5 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== _Notebook_ de división de datos <data-div-notebook>

==== Fundamento y configuración

Una vez `data-prep`, `data-prep-online` y `data-prep-combination` (véase #link(<notebooks-empleados>)[*Anexo III*]) generan el dataset final armonizado (`sob4es_final_model_ready.csv`), este _notebook_ es responsable de dividirlo en los tres subconjuntos empleados por el resto del proyecto: *entrenamiento, test y evaluación*. Es, por tanto, el último eslabón de la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*] antes de entrar en la #link(<capa-modelado>)[*Capa de modelado predictivo*].

El dataset de entrada contiene 428 filas y 71 columnas, sin ningún valor nulo. La partición se configura con `TEST_SIZE=0.30` (fracción reservada para test+eval conjuntamente), `EVAL_FRAC=0.50` (mitad de esa reserva para eval, mitad para test) y `RANDOM_SEED=42`.

==== Metodología

La partición se realiza en dos pasos sucesivos con `train_test_split` de `scikit-learn`, estratificando por país de origen de la muestra (extraído del prefijo de `site_id`, por ejemplo BE, IL, RO) para asegurar que los tres subconjuntos mantengan una representación proporcional de cada país. 

Italia (IT), con solo 2 filas en todo el dataset, se agrupa con Alemania (DE) únicamente a efectos de estratificación, al no ser posible estratificar un país con menos de 2 muestras por split.

Las particiones resultantes son las siguientes:
- *Primera partición:* train (70%) frente a un conjunto temporal (temp, 30%).
- *Segunda partición:* temp se divide a su vez al 50% entre test y eval.

Tras la partición se verifica que la proporción de `outlier_flag` (una bandera de calidad de dato ya calculada en fases anteriores) se mantiene similar entre los tres subconjuntos, como comprobación adicional de que la partición no ha introducido un sesgo de calidad entre splits.

#colbreak()

==== Resultados

En la #ref(<tab-35>) y en la #ref(<fig-17>) se pueden ver los subconjuntos resultantes tras ejecutar el _notebook_ de división de datos, como también la estratificación de estos por país.

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto), 
            align: (center, center, center), 
            fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
            table.header([*Subconjunto*], [*Filas*], [*% del total*]), 
                [*`train.csv`*], [299], [69.9%],
                [*`test.csv`*],  [64],  [15.0%], 
                [*`eval.csv`*],  [65],  [15.2%] 
        )
    ],
    caption: [Subconjuntos resultantes de la división del dataset original.]
)<tab-35>

#figure(
    align(center)[
        #image("../media/pie-chart-data.png")
    ],
    caption: [División de los datos, estratificado por país.],
    kind: image
)<fig-17>

La distribución de `outlier_flag` se mantiene prácticamente idéntica entre subconjuntos, confirmando que la estratificación por país no ha desequilibrado esta variable de calidad. De igual forma, la proporción de muestras por país se mantiene estable en los tres splits, con la única excepción esperable de Italia, cuyas 2 únicas muestras se reparten una a test y otra a eval, sin ninguna en train.

#let file = "../media/anexos/data-prep-div.pdf"
#let total_pages = 3 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}
