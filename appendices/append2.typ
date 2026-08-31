== Modelos empleados (Anexo II) <modelos-empleados>

En esta sección de los anexos se detalla, para cada uno de los ocho modelos desarrollados en este TFG, su configuración concreta y los resultados numéricos obtenidos sobre `eval.csv`, el subconjunto de evaluación final que ningún modelo ha visto durante el _tuning_ ni durante la validación cruzada (véase #link(<capa-modelado>)[*Capa de modelado predictivo*]).

Los 21 _targets_ predichos corresponden a los índices de biodiversidad (Shannon) y de riqueza de especies de 11 grupos taxonómicos distintos, los cuales se encuentran mencionados en el #link(<informe-eda>)[*Anexo I*] y en #link(<variables>)[*Variables empleadas*], todos ellos normalizados a la *escala z* antes del entrenamiento. Por ello un $R²$ de 0 no implica que no prediga nada, sino que su rendimiento es equivalente al de predecir siempre la media del conjunto de entrenamiento, mientras que un valor negativo indica que el modelo predice peor que dicha media.

A lo largo de todos los modelos, `earthworm_shannon_z` y `earthworm_richness_z` se tratan como los dos _targets_ prioritaios, por lo que en los siguientes subapartados se hará referencia explicita a los rendimientos obtenidos a la hora de predecir dichos _targets_.

También a lo largo de los siguientes subapartados, se tendrá una explicación de los modelos y de los resultados obtenidos, como también el _notebook_ base de dcho modelo exportado.

=== Modelo de Regresión Ridge <ridge-model>

==== Fundamentos y configuración

Ridge (véase #link(<regresion-ridge>)[*Modelo de Regresión Ridge*]) se emplea como modelo _baseline_ del trabajo: al ser un modelo lineal, permite establecer un suelo mínimo de rendimiento frente al que comparar el resto de modelos, más complejos y con mayor capacidad de capturar relaciones no lineales.

Al tratarse de un modelo determinista (no depende de una semilla aleatoria de entrenamiento), se entrena un único modelo por _target_, sin necesidad de recurrir a un ensamblado de varias semillas para reducir la varianza.

La búsqueda de hiperparámetros se realiza mediante `GridSearchCV (validación cruzada de 5 pliegues, scoring='r2')` sobre `X_train`, para cada uno de los 21 _targets_ de forma independiente, explorando:
- *`alpha`:* 120 valores en escala logarítmica entre $10^(-1)$ y $10^8$, para cubrir desde una regularización casi nula hasta una regularización extrema (necesaria para los _targets_ con menor señal predictiva, donde el modelo tiende a sobreajustar si `alpha` es bajo).
- *`fit_intercept`:* True / False.
- *`solver`:* auto, cholesky, lsqr.

Para evitar seleccionar una combinación que sobreajuste, se aplica además un filtro de estabilidad: de entre todas las combinaciones evaluadas, solo se consideran válidas aquellas cuya diferencia entre el R² de entrenamiento y el R² de validación cruzada (gap) sea igual o inferior a 0.10; si ninguna combinación cumple ese criterio para un _target_ concreto, se selecciona la de menor gap con seguridad. El alpha óptimo encontrado varía considerablemente entre _targets_ (de 105.98 a 719.69), lo que confirma que la señal predictiva disponible es distinta para cada grupo taxonómico y que un único valor de regularización global no sería adecuado.

==== Entrenamiento

Al tratarse de un modelo determinista, no se recurre a un ensamblado de semillas: se entrena un único modelo por _target_ con los hiperparámetros seleccionados en el _tuning_.

La validación cruzada repetida `(RepeatedKFold, 5 pliegues × 3 repeticiones = 15 evaluaciones)` sobre `X_train` no mostró señales relevantes de sobreajuste: de los 21 _targets_, únicamente `bac_shannon_z` superó el umbral de aviso (diferencia Train-CV > 0.15, concretamente 0.161). 

El resto se mantuvo en un rango de diferencia razonable (entre 0.054 y 0.161), coherente con la baja capacidad de un modelo lineal para memorizar el conjunto de entrenamiento.

#colbreak()

==== Explicabilidad y variables más relevantes

A partir del valor absoluto de los coeficientes del modelo (interpretables directamente al estar las variables normalizadas), las variables más relevantes a nivel global fueron, por este orden: `soil_ph_z`, `gee_temp_media_C_z`, `eu_p_z`, `dem_elevacion_m_z`, `zn_z`, `gee_humedad_rel_pct_z`, `clay_content_z`, `eu_ph_z`, `pb_z` y `soil_moisture_z`. 

El pH del suelo y la temperatura media (variable climática remota de GEE) destacan de forma consistente como los predictores más influyentes del conjunto.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Importancia de variables*.

==== Resultados sobre eval.csv

El R² medio sobre los 21 _targets_ es de *-0.016*, es decir, en promedio Ridge se comporta ligeramente peor que predecir la media del conjunto de entrenamiento.

Sobre los dos _targets_ prioritarios obtiene *R²=0.2395* (`earthworm_shannon_z`) y *R²=0.2789* (`earthworm_richness_z`), sus dos mejores resultados junto con `macro_shannon_z` (0.1257). 

En el extremo opuesto, `coll_species_richness_z` (-0.7341) y `meso_shannon_z` (-0.2499) muestran el peor ajuste, indicando que la relación lineal simple no captura la variabilidad de estos grupos. Los resultados sobre todos los _targets_ se pueden ver en la #ref(<tab-20>).

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto, auto, auto), 
      align: (left, left, center, center, center), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*], 
        [*RMSE*], 
        [*MAE*]), 
      [*Shannon nemátodos*],       [nematode_shannon_z],      [0.0112],  [0.9821], [0.7929], 
      [*Shannon macrofauna*],      [macro_shannon_z],         [0.1257],  [0.9391], [0.8177], 
      [*Shannon lombrices*],       [earthworm_shannon_z],     [0.2395],  [0.8704], [0.7094], 
      [*Shannon oribátidos*],      [orib_shannon_z],          [0.1137],  [1.0766], [0.9075], 
      [*Shannon mesostigmátidos*], [meso_shannon_z],          [-0.2499], [1.0918], [0.9023], 
      [*Shannon colémbolos*],      [coll_shannon_z],          [-0.4998], [0.7758], [0.6426], 
      [*Shannon bacterias*],       [bac_shannon_z],           [-0.0812], [1.0413], [0.7158], 
      [*Shannon hongos*],          [fun_shannon_z],           [-0.0161], [1.1533], [0.9503], 
      [*Shannon eucariotas*],      [euk_shannon_z],           [0.0407],  [0.9499], [0.7011], 
      [*Shannon oomicetos*],       [oomy_shannon_z],          [0.0857],  [0.9996], [0.7418], 
      [*Shannon cercozoos*],       [cerc_shannon_z],          [0.0155],  [0.8886], [0.6332], 
      [*Riqueza macrofauna*],      [macro_order_richness_z],  [0.1521],  [0.8433], [0.7105], 
      [*Riqueza lombrices*],       [earthworm_richness_z],    [0.2789],  [0.7754], [0.6143], 
      [*Riqueza oribátidos*],      [orib_species_richness_z], [0.0921],  [1.1400], [0.7670], 
      [*Riqueza mesostigmátidos*], [meso_species_richness_z], [-0.0959], [1.0097], [0.7693], 
      [*Riqueza colémbolos*],      [coll_species_richness_z], [-0.7341], [0.6780], [0.5409], 
      [*Riqueza bacterias (ASV)*], [bac_asv_richness_z],      [-0.0761], [1.1398], [0.8335], 
      [*Riqueza hongos (ASV)*],    [fun_asv_richness_z],      [0.0087],  [1.0731], [0.8114], 
      [*Riqueza eucariotas (ASV)*],[euk_asv_richness_z],      [0.0400],  [0.7955], [0.5775], 
      [*Riqueza oomicetos (ASV)*], [oomy_asv_richness_z],     [0.1035],  [0.9510], [0.7711], 
      [*Riqueza cercozoos (ASV)*], [cerc_asv_richness_z],     [0.1019],  [0.9350], [0.7211], 
      )
    ], 
      caption: [Resultados de Ridge sobre eval.csv, por _target_.], 
      kind: table, 
    )<tab-20>

#let file = "../media/anexos/reg_model.pdf"
#let total_pages = 10 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelo _Random Forest_ <rf-model>

==== Fundamentos y configuración

_Random Forest_ (véase #link(<random-forest>)[*Modelo _Random Forest_*]) se entrena, en esta primera variante, en su forma de salida única: un conjunto de árboles independiente por cada uno de los 21 _targets_, cada uno con su propia búsqueda de hiperparámetros.

La búsqueda se realiza mediante `RandomizedSearchCV (50 combinaciones, validación cruzada de 5 pliegues)` sobre `X_train`, explorando:
- *n_estimators:* 100, 150, 200.
- *max_depth:* 3, 4, 5, 10, 15, 20.
- *min_samples_leaf:* 2, 4, 8, 12, 16.
- *min_samples_split:* 15, 20, 25.
- *max_features:* sqrt, 0.2, 0.3.
- *ccp_alpha:* 0.005, 0.01, 0.02.
- *bootstrap:* True.

Algunos de dichos parámetros se han capado a un mínimo o máximo específico por los siguientes motivos:
+ *max_depth:* Limitado a un máximo de 20 para reducir el riesgo de sobreajuste a causa del tamaño reducido de los datos.
+ *min_samples_leaf:* Limitado a un mínimo de 2 hojas para evitar la creación de hojas triviales.

==== Entrenamiento

La validación cruzada repetida sobre `X_train` muestra señales de sobreajuste (diferencia `Train-CV > 0.15`) en la práctica totalidad de los 21 _targets_, algo esperable dada la combinación de un modelo con alta capacidad (`max_depth` hasta 20) y un conjunto de entrenamiento reducido (~300 muestras).

Este comportamiento es muy distinto al observado en Ridge, y es coherente con la mayor capacidad de un ensamblado de árboles para memorizar el conjunto de entrenamiento frente a un modelo lineal.

Además, a diferencia de Ridge, _Random Forest_ sí depende de la semilla aleatoria (tanto en el _bootstrap_ de las muestras como en la selección aleatoria de variables en cada división). 
Para reducir la varianza de las predicciones finales, se entrena un ensamblado de 5 modelos por _target_ (semillas `RANDOM_STATE, RANDOM_STATE+1, ..., RANDOM_STATE+4`), cuyas predicciones se promedian en el momento de la inferencia. 

En total se generan y almacenan *$21 times 5 = 105$ modelos `.pkl`*.

==== Explicabilidad y variables más relevantes

Se calculan valores *SHAP* sobre `X_train` para todos los _targets_ conjuntamente.

El top-10 de variables más relevantes a nivel global por importancia SHAP media es: `soil_ph_z`, `gee_temp_media_C_z`, `eu_ph_z`, `eu_as_z`, `eu_cn_ratio_z`, `gee_humedad_rel_pct_z`, `eu_p_z`, `eu_clay_content_z`, `silt_content_z` y `eu_silt_content_z`. 

Este resultado es consistente con el obtenido por los coeficientes de Ridge (soil_ph_z y gee_temp_media_C_z en primer y segundo lugar en ambos casos), lo que refuerza la fiabilidad de ambas variables como predictores robustos, independientemente del tipo de modelo empleado.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Explicabilidad del modelo (SHAP)*.

#colbreak()

==== Resultados sobre eval.csv

El R² medio sobre los 21 _targets_ es de *0.090*, una mejora sustancial frente al -0.016 de Ridge. 

_Random Forest_ es, de hecho, el modelo de salida única con mejor rendimiento global de todo el trabajo. 

Sobre los _targets_ prioritarios: *R²=0.5041* (`earthworm_shannon_z`) y *R²=0.5722* (`earthworm_richness_z`), los mejores resultados obtenidos para ambos _targets_ entre todos los modelos de salida única evaluados. 

Por otro lado, `coll_species_richness_z` (-0.5484) vuelve a ser, como en Ridge, el _target_ con peor ajuste.

En la #ref(<tab-21>) se pueden ver los resultados por cada _target_ de forma más detallada.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto, auto, auto), 
      align: (left, left, center) , 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*], [*RSME*], [*MAE*]), 
      [*Shannon nemátodos*],        [nematode_shannon_z],      [0.1693],  [0.9001], [0.7070], 
      [*Shannon macrofauna*],       [macro_shannon_z],         [0.3199],  [0.8283], [0.6935], 
      [*Shannon lombrices*],        [earthworm_shannon_z],     [0.5041],  [0.7029], [0.5055], 
      [*Shannon oribátidos*],       [orib_shannon_z],          [0.1794],  [1.0359], [0.8803], 
      [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.1731], [1.0577], [0.8816], 
      [*Shannon colémbolos*],       [coll_shannon_z],          [-0.3489], [0.7358], [0.6129], 
      [*Shannon bacterias*],        [bac_shannon_z],           [0.0077],  [0.9975], [0.6701], 
      [*Shannon hongos*],           [fun_shannon_z],           [-0.0455], [1.1698], [0.9399], 
      [*Shannon eucariotas*],       [euk_shannon_z],           [0.1683],  [0.8844], [0.6227], 
      [*Shannon oomicetos*],        [oomy_shannon_z],          [0.0832],  [1.0010], [0.7279], 
      [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.0318], [0.9096], [0.6274], 
      [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.3417],  [0.7431], [0.6316], 
      [*Riqueza lombrices*],        [earthworm_richness_z],    [0.5722],  [0.5973], [0.4324], 
      [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2034],  [1.0679], [0.7166], 
      [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.0438], [0.9854], [0.7472], 
      [*Riqueza colémbolos*],       [coll_species_richness_z], [-0.5484], [0.6407], [0.5033], 
      [*Riqueza bacterias (ASV*)],  [bac_asv_richness_z],      [0.0042],  [1.0965], [0.8126], 
      [*Riqueza hongos (ASV*)],     [fun_asv_richness_z],      [-0.0256], [1.0915], [0.8189], 
      [*Riqueza eucariotas (ASV*)], [euk_asv_richness_z],      [0.2520],  [0.7022], [0.5142], 
      [*Riqueza oomicetos (ASV*)],  [oomy_asv_richness_z],     [0.1843],  [0.9071], [0.7446], 
      [*Riqueza cercozoos (ASV*)],  [cerc_asv_richness_z],     [0.1250],  [0.9229], [0.7550], 
      )], 
      caption: [Resultados de _Random Forest_ (salida única) sobre eval.csv, por _target_.], 
      kind: table 
    )<tab-21>

#let file = "../media/anexos/rf_model.pdf"
#let total_pages = 10 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelo _Random Forest_ Multisalida <rf-multi-model>

==== Fundamentos y configuración

Esta variante entrena un único `RandomForestRegressor` que predice los 21 _targets_ de forma simultánea, aprovechando el soporte nativo de `scikit-learn` para `y` multivariante: cada división de cada árbol se decide considerando conjuntamente los 21 _targets_, lo que permite capturar correlaciones entre grupos biológicos directamente en la estructura del árbol, sin necesidad de un mecanismo explícito de encadenamiento.

Al no poder tener hiperparámetros distintos por _target_ (un único bosque sirve a los 21 a la vez), la búsqueda de hiperparámetros se realiza igualmente por _target_ mediante `RandomizedSearchCV`, pero el resultado final se resuelve mediante un consenso ponderado por R²: cada _target_ "vota" su combinación óptima con un peso proporcional a su propio R² de validación cruzada, esto implica que los _targets_ con mayor R² influirán más que los que tenga un valor más pequeño.  

El consenso resultante se puede ver en la #ref(<tab-22>):

#figure(
  align(center)[
    #table( 
      columns: (auto, auto), 
      align: (left, center), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header( [*Hiperparámetro*], [*Valor de consenso*]), 
      [*n_estimators*],      [292], 
      [*max_depth*],         [6], 
      [*min_samples_split*], [14], 
      [*min_samples_leaf*],  [5], 
      [*max_features*],      [log2], 
      [*ccp_alpha*],         [≈ 0.00125], )
  ],
  caption: [Consenso de hiperparámetros en _Random Forest_ multisalida.],
  kind: table
)<tab-22>

Resulta interesante que el consenso limite la profundidad a solo 6 niveles (frente al máximo de 20 permitido en la búsqueda), lo que sugiere que, al tener que servir a los 21 _targets_ simultáneamente, el modelo prioriza una estructura de árbol menos profunda y más generalista, en vez de sobreajustar a las particularidades de un _target_ concreto.

Cabe destacar que la matriz de parámetros empleado para realizar la búsqueda de hiperparámetros es idéntico al empleado en #link(<rf-model>)[*_Random Forest_*].

==== Entrenamiento

Al igual que _Random Forest_ de salida única, esta variante depende de la semilla aleatoria del _bootstrap_ y de la selección de variables en cada división. Se entrena un ensamblado de 5 modelos con semillas `RANDOM_STATE` a `RANDOM_STATE+4`, cuyas predicciones se promedian en la inferencia. Al tratarse de un único bosque multisalida por semilla (no uno por _target_), el ensamblado completo requiere solo 5 modelos `.pkl`, frente a los 105 de la variante de salida única.

La validación cruzada repetida sobre `X_train`, evaluada de forma global sobre los 21 _targets_ conjuntamente, muestra una diferencia Train-CV de 0.166 (R² train 0.307 frente a R² CV 0.142), por encima del umbral de aviso de 0.15. 

A diferencia de _Random Forest_ de salida única, donde prácticamente todos los _targets_ mostraban aviso individual, aquí el consenso de hiperparámetros (con una profundidad más conservadora) modera algo el sobreajuste, aunque no lo elimina del todo.

#colbreak()

==== Explicabilidad y variables más relevantes

Se calculan valores *SHAP* sobre `X_train`, promediando el valor absoluto sobre los 21 _targets_. El top-10 de variables más relevantes es: `soil_ph_z`, `gee_temp_media_C_z`, `eu_as_z`, `eu_ph_z`, `p_z`, `gee_humedad_rel_pct_z`, `eu_cn_ratio_z`, `eu_p_z`, `eu_clay_content_z` y `dem_elevacion_m_z`. 

Este ranking es prácticamente idéntico al obtenido por _Random Forest_ de salida única, con las dos mismas variables en primer y segundo lugar, lo que confirma que la relevancia de `soil_ph_z` y `gee_temp_media_C_z` es una propiedad del conjunto de datos y no un artefacto de una configuración de modelo concreta.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Explicabilidad del modelo (SHAP)*.

==== Resultados sobre eval.csv

Con un R² medio de *0.0964*, _Random Forest_ multisalida es, de los ocho modelos evaluados en este trabajo, el que obtiene el *mejor promedio global* de R² sobre `eval.csv`, ligeramente por encima incluso de su propia variante de salida única (0.090). Sobre los _targets_ prioritarios obtiene *R²=0.4160* (`earthworm_shannon_z`) y *R²=0.4509* (`earthworm_richness_z`), algo por debajo de lo logrado por _Random Forest_ de salida única para estos dos _targets_ concretos. 

Esto sugiere que, si bien compartir la estructura del árbol entre los 21 _targets_ mejora el promedio global, probablemente porque ayuda a los _targets_ con menos señal individual, puede hacerlo a costa de una ligera pérdida de precisión específica en los dos _targets_ con más señal predictiva propia del conjunto de datos.

En la #ref(<tab-23>) se pueden ver los resultados por _target_ tras el entrenamiento del modelo.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto), 
      align: (left, left, center) , 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*]), 
      [*Shannon nemátodos*],        [nematode_shannon_z],      [0.1545], 
      [*Shannon macrofauna*],       [macro_shannon_z],         [0.2000], 
      [*Shannon lombrices*],        [earthworm_shannon_z],     [0.4160], 
      [*Shannon oribátidos*],       [orib_shannon_z],          [0.1693], 
      [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.1178], 
      [*Shannon colémbolos*],       [coll_shannon_z],          [-0.1953], 
      [*Shannon bacterias*],        [bac_shannon_z],           [0.0290], 
      [*Shannon hongos*],           [fun_shannon_z],           [-0.0127], 
      [*Shannon eucariotas*],       [euk_shannon_z],           [0.1378], 
      [*Shannon oomicetos*],        [oomy_shannon_z],          [0.1252], 
      [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.0041], 
      [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.2532], 
      [*Riqueza lombrices*],        [earthworm_richness_z],    [0.4509], 
      [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2386], 
      [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.0255], 
      [*Riqueza colémbolos*],       [coll_species_richness_z], [-0.2920], 
      [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [0.0044], 
      [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [-0.0068], 
      [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.1903], 
      [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [0.1917], 
      [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [0.1171], 
      )], 
      caption: [R² de _Random Forest_ multisalida sobre eval.csv, por _target_.], 
      kind: table 
  )<tab-23>

#let file = "../media/anexos/rf_multisalida.pdf"
#let total_pages = 9
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelo RegressorChain con _Random Forest_ <reg-chain-model>

==== Fundamentos y configuración

RegressorChain (véase #link(<regressorchain>)[*RegressorChain*]) encadena las predicciones de los 21 _targets_: el modelo predice primero un _target_, y usa esa predicción, junto con las variables originales, como entrada adicional para predecir el siguiente, y así sucesivamente. 

A diferencia de _Random Forest_ multisalida, donde la relación entre _targets_ se aprende de forma implícita dentro de la estructura del árbol, aquí la correlación entre _targets_ se introduce de forma explícita, como una variable de entrada más para los _targets_ posteriores de la cadena.

El modelo base de cada eslabón de la cadena es un `RandomForestRegressor`. Sus hiperparámetros se afinan una única vez mediante RandomizedSearchCV, empleando como métrica el R² promedio de los 21 _targets_ simultáneamente. 

El mejor R² promedio de validación cruzada obtenido en esta búsqueda fue de 0.1521, con los siguientes hiperparámetros que se pueden ver en la #ref(<tab-24>).

#figure(
  align(center)[
    #table( 
      columns: (auto, auto), 
      align: (left, center), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header([*Hiperparámetro*], [*Valor*]), 
      [*n_estimators*],      [200], 
      [*min_samples_split*], [15], 
      [*min_samples_leaf*],  [4], 
      [*max_samples*],       [0.7], 
      [*max_features*],      [0.2], )
  ],
  caption: [Consenso de hiperparámetros en RegressorChain.],
  kind: table
)<tab-24>

==== Ensemble of Chains (ECC)

El principal problema del encadenamiento simple es que los _targets_ al principio de la cadena disponen de menos información (solo las variables originales) que los del final, los que además cuentan con las predicciones de todos los _targets_ anteriores, por lo que el orden elegido condiciona el rendimiento de cada _target_ concreto. 

Para compensar este efecto, se entrena un ensamble de 10 cadenas `(N_CHAINS=10)`, cada una con un orden aleatorio distinto de los 21 _targets_ (permutación generada con semilla `RANDOM_STATE + chain_id`) y su propio modelo base con semilla también distinta. Las predicciones finales se obtienen promediando las 10 cadenas, de forma que los efectos de orden favorables y desfavorables para cada _target_ tienden a cancelarse entre sí.

==== Entrenamiento

La validación cruzada del modelo base muestra avisos de sobreajuste (diferencia `Train-CV > 0.15`) en varios de los _targets_ situados en la segunda mitad de la cadena por defecto, por ejemplo, `coll_species_richness_z` (0.416), `cerc_asv_richness_z` (0.433) u `oomy_asv_richness_z` (0.421), un patrón distinto al de _Random Forest_ de salida única, donde los avisos aparecían de forma más homogénea en casi todos los _targets_.

En una cadena de referencia con orden por defecto, el R² de entrenamiento del primer _target_ de la cadena (nematode_shannon_z, 0.5475) es notablemente inferior al de un _target_ situado en una posición más avanzada como earthworm_richness_z en la posición 13 (0.7338).

#colbreak()

==== Explicabilidad y variables más relevantes

Se calcula la importancia de variables (SHAP y MDI) del modelo base únicamente para el primer _target_ de la cadena, al ser la posición de mayor dificultad. El top-10 por MDI para esta posición es: `sand_content_z`, `silt_content_z`, `soil_ph_z`, `gee_humedad_rel_pct_z`, `gee_temp_media_C_z`, `aggregate_stability_z`, `pb_z`, `eu_water_holding_capacity_z`, `k_z` y `ni_z`. 

A diferencia del resto de modelos, aquí `sand_content_z` (contenido de arena) desplaza a `soil_ph_z` al tercer puesto, lo que resulta coherente con la ausencia de cualquier información de _targets_ relacionados en esta posición de la cadena: el modelo depende en mayor medida de las variables edáficas más básicas.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Análisis de la cadena*.

==== Resultados sobre eval.csv

Con un R² medio de *0.0809*, RegressorChain queda por debajo de _Random Forest_ multisalida (0.0964) pero, en cambio, obtiene los mejores resultados de todo el trabajo sobre los dos _targets_ prioritarios: *R²=0.4876* (`earthworm_shannon_z`) y *R²=0.5359* (`earthworm_richness_z`), superando incluso a _Random Forest_ de salida única. 

Esto es coherente con la hipótesis de partida del modelo: al encadenar explícitamente las predicciones, los _targets_ con mayor señal individual (como los de lombrices) pueden beneficiarse de la información aportada por _targets_ relacionados situados antes en la cadena, algo que _Random Forest_ multisalida solo captura de forma indirecta. Esto se ve reflejado en las #link(<conclusiones>)[*Conclusiones*]. En la #ref(<tab-25>) se pueden ver los resultados por _target_ obtenidos tras entrenar el modelo.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto), 
      align: (left, left, center), 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*]), 
      [*Shannon nemátodos*],        [nematode_shannon_z],      [0.1467], 
      [*Shannon macrofauna*],       [macro_shannon_z],         [0.2804], 
      [*Shannon lombrices*],        [earthworm_shannon_z],     [0.4876], 
      [*Shannon oribátidos*],       [orib_shannon_z],          [0.2069], 
      [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.1640], 
      [*Shannon colémbolos*],       [coll_shannon_z],          [-0.6087], 
      [*Shannon bacterias*],        [bac_shannon_z],           [0.0288], 
      [*Shannon hongos*],           [fun_shannon_z],           [-0.0219], 
      [*Shannon eucariotas*],       [euk_shannon_z],           [0.1624], 
      [*Shannon oomicetos*],        [oomy_shannon_z],          [0.0913], 
      [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.0006], 
      [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.4069], 
      [*Riqueza lombrices*],        [earthworm_richness_z],    [0.5359], 
      [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2026], 
      [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.0400], 
      [*Riqueza colémbolos*],       [coll_species_richness_z], [-0.5799], 
      [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [-0.0052], 
      [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [-0.0186], 
      [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.2690], 
      [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [0.2019], 
      [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [0.1171], 
    )], 
    caption: [R² de RegressorChain (ensamble de 10 cadenas) sobre eval.csv, por _target_.], 
    kind: table, 
  )<tab-25>

#let file = "../media/anexos/regressorchain.pdf"
#let total_pages = 10 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelo XGBoost <xgboost-model>

==== Fundamentos y configuración

XGBoost (véase #link(<xgboost>)[*Modelo XGBoost*]) se entrena, igual que en el caso de _Random Forest_, en su variante de salida única: un modelo independiente por _target_, cada uno con su propia búsqueda de hiperparámetros mediante `RandomizedSearchCV` sobre `X_train`.

El _notebook_ incorpora una celda de detección automática de *GPU/CUDA*: si el sistema dispone de una GPU NVIDIA con drivers CUDA, XGBoost se configura para usar *`tree_method='hist'`* junto con *`device='cuda'`*. En caso contrario, se utiliza *`tree_method='hist'`* sobre *CPU*. 

La versión del _notebook_ exportado se puede ver que se detectó CUDA sin problemas.

El espacio de búsqueda de hiperparámetros se restringe deliberadamente hacia modelos conservadores, dado el tamaño reducido del _dataset_:

- *n_estimators:* 50, 100, 150.
- *max_depth:* 2, 3.
- *learning_rate:* 0.01, 0.05.
- *subsample / colsample_bytree:* 0.4-0.6 / 0.3-0.5.
- *gamma:* 1.0, 5.0, 10.0.
- *min_child_weight:* 10, 20, 30.
- *reg_alpha / reg_lambda:* regularización L1 y L2, con valores 5-20 y 10-50 respectivamente.
- *grow_policy:* depthwise.

Esta combinación de árboles poco profundos, submuestreo agresivo y regularización fuerte responde directamente a la limitación de tener solo 300 muestras de entrenamiento: sin estas restricciones, XGBoost tiende a sobreajustar con rapidez.

==== Entrenamiento 

Al igual que _Random Forest_, XGBoost depende de la semilla aleatoria, por lo que se entrena un ensamblado de 5 modelos por _target_ `(NUM_EXPERTOS=5)`, variando únicamente la semilla, y promediando sus predicciones en la inferencia.

La validación cruzada repetida sobre `X_train` muestra avisos de sobreajuste en 19 de los 21 _targets_, un patrón similar al de _Random Forest_ de salida única aunque con diferencias `Train-CV` algo menores en varios _targets_, lo que sugiere que la regularización fuerte aplicada en el espacio de búsqueda modera ligeramente el sobreajuste sin llegar a eliminarlo.

==== Explicabilidad y variables más relevantes

A diferencia de _Random Forest_, en este _notebook_ SHAP se calcula únicamente sobre los dos _targets_ prioritarios (`earthworm_shannon_z` y `earthworm_richness_z`), en vez de sobre el conjunto completo de 21 _targets_, por lo que no se dispone de un ranking de variables a nivel global comparable al del resto de modelos.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Explicabilidad del modelo (SHAP)*.

#colbreak()

==== Resultados sobre eval.csv

El R² medio sobre los 21 _targets_ es de *0.067*, ligeramente por debajo de _Random Forest_ de salida única (0.090) pero muy por encima de Ridge. 

Sobre los _targets_ prioritarios: *R²=0.4946* (`earthworm_shannon_z`) y *R²=0.5171* (`earthworm_richness_z`).

En la #ref(<tab-26>) se pueden ver los resultador por _target_ obtenidos tras entrenar el modelo.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto, auto, auto), 
      align: (left, left, center, center, center), 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*], [*RMSE*], [*MAE*]), 
      [*Shannon nemátodos*],        [nematode_shannon_z],      [0.1637],  [0.9032], [0.7152], 
      [*Shannon macrofauna*],       [macro_shannon_z],         [0.2601],  [0.8639], [0.7383], 
      [*Shannon lombrices*],        [earthworm_shannon_z],     [0.4946],  [0.7096], [0.5336], 
      [*Shannon oribátidos*],       [orib_shannon_z],          [0.1147],  [1.0760], [0.9105], 
      [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.1868], [1.0639], [0.8782], 
      [*Shannon colémbolos*],       [coll_shannon_z],          [-0.3312], [0.7309], [0.5941], 
      [*Shannon bacterias*],        [bac_shannon_z],           [0.0092],  [0.9968], [0.6707], 
      [*Shannon hongos*],           [fun_shannon_z],           [-0.0206], [1.1559], [0.9385], 
      [*Shannon eucariotas*],       [euk_shannon_z],           [0.0912],  [0.9245], [0.6622], 
      [*Shannon oomicetos*],        [oomy_shannon_z],          [0.0965],  [0.9937], [0.7411], 
      [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.0414], [0.9138], [0.6353], 
      [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.3082],  [0.7617], [0.6447], 
      [*Riqueza lombrices*],        [earthworm_richness_z],    [0.5171],  [0.6346], [0.4842], 
      [*Riqueza oribátidos*],       [orib_species_richness_z], [0.1259],  [1.1186], [0.7501], 
      [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.0592], [0.9927], [0.7503], 
      [*Riqueza colémbolos*],       [coll_species_richness_z], [-0.5803], [0.6472], [0.5071], 
      [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [0.0014],  [1.0980], [0.8196], 
      [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [-0.0242], [1.0907], [0.8221], 
      [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.1671],  [0.7409], [0.5285], 
      [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [0.1776],  [0.9108], [0.7459], 
      [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [0.1227],  [0.9241], [0.7506], 
      )], 
      caption: [Resultados de XGBoost (salida única, ensamble de 5 modelos) sobre eval.csv, por _target_.], 
      kind: table     
  )<tab-26>

#let file = "../media/anexos/xgboost_model.pdf"
#let total_pages = 9
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelos XGBoost multisalida <xgb-multi-model>

==== Fundamentos y configuración

Disponible desde la versión 1.7 de XGBoost mediante el parámetro `multi_strategy='multi_output_tree'`, esta variante construye, en cada iteración del _boosting_, un único árbol que predice los 21 _targets_ a la vez, en lugar del comportamiento por defecto de XGBoost. Al igual que en _Random Forest_ multisalida, esto permite que las divisiones del árbol capturen relaciones compartidas entre _targets_ directamente en su estructura.

Comparte la misma celda de detección de GPU/CUDA que la variante de salida única, y al no poder tener un espacio de hiperparámetros distinto por _target_, sigue la misma estrategia de consenso descrita para _Random Forest_ multisalida: búsqueda por _target_ seguida de una combinación ponderada por R².

Al igual que en las variantes de salida única, se entrena un ensamblado de varios modelos (5 expertos) para reducir la varianza de las predicciones.

==== Entrenamiento

La validación cruzada global sobre `X_train` muestra una diferencia Train-CV de 0.5423, muy por encima del umbral de aviso de 0.15 y notablemente mayor que la obtenida por _Random Forest_ multisalida (0.166) para el mismo tipo de evaluación global. 

Esto indica que, a pesar de la regularización aplicada en el espacio de búsqueda, el mecanismo de boosting de XGBoost combinado con la estrategia `multi_output_tree` tiende a memorizar con más facilidad el conjunto de entrenamiento cuando debe servir a los 21 _targets_ a la vez, en comparación con un bosque de _Random Forest_ equivalente.

==== Explicabilidad y variables más relevantes

A diferencia de la variante de salida única, donde SHAP solo se calculaba sobre los dos _targets_ prioritarios, aquí sí se dispone de un ranking de importancia global. 

El top-10 por importancia de permutación es: `soil_ph_z`, `p_z`, `gee_temp_media_C_z`, `dem_elevacion_m_z`, `soil_moisture_z`, `eu_as_z`, `eu_p_z`, `k_z`, `gee_humedad_rel_pct_z` y `dem_orientacion_deg_z`. 

El ranking por ganancia intrínseca de XGBoost (XGBoost gain) coincide en gran medida con el de permutación para las primeras posiciones, situando también a `soil_ph_z` en primer lugar, lo que refuerza, junto con el resto de modelos de este anexo, la robustez de esta variable como el predictor individual más influyente de todo el trabajo.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Importancia de variables (SHAP)*.

#colbreak()

==== Resultados sobre eval.csv

Con un R² medio de *0.0835*, XGBoost multisalida queda en segunda posición del ranking global de R² medio de este trabajo, por detrás de _Random Forest_ multisalida (0.0964) pero por delante de RegressorChain (0.0809) y de XGBoost de salida única (0.067).

Sobre los _targets_ prioritarios obtiene sus mejores resultados dentro de la familia XGBoost: *R²=0.5375* (`earthworm_shannon_z`) y *R²=0.5893* (`earthworm_richness_z`), este último el segundo mejor resultado de todo el trabajo para `earthworm_richness_z`, solo por detrás de RegressorChain (0.5359).

En la #ref(<tab-27>) se pueden ver los resultados por _target_ del modelo entrenado.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto, auto, auto), 
      align: (left, left, center, center, center), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*], [*RMSE*], [*MAE*]), 
        [*Shannon nemátodos*],        [nematode_shannon_z],      [0.2228],  [0.8707], [0.6737], 
        [*Shannon macrofauna*],       [macro_shannon_z],         [0.3771],  [0.7927], [0.6529], 
        [*Shannon lombrices*],        [earthworm_shannon_z],     [0.5375],  [0.6788], [0.4725], 
        [*Shannon oribátidos*],       [orib_shannon_z],          [0.2275],  [1.0051], [0.8385], 
        [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.2861], [1.1075], [0.8883], 
        [*Shannon colémbolos*],       [coll_shannon_z],          [-0.3229], [0.7286], [0.5647], 
        [*Shannon bacterias*],        [bac_shannon_z],           [-0.0151], [1.0089], [0.6857], 
        [*Shannon hongos*],           [fun_shannon_z],           [-0.0502], [1.1725], [0.9306], 
        [*Shannon eucariotas*],       [euk_shannon_z],           [0.0886],  [0.9259], [0.6549], 
        [*Shannon oomicetos*],        [oomy_shannon_z],          [0.0620],  [1.0124], [0.7385], 
        [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.0330], [0.9101], [0.6371], 
        [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.4013],  [0.7086], [0.5880], 
        [*Riqueza lombrices*],        [earthworm_richness_z],    [0.5893],  [0.5852], [0.4240], 
        [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2800],  [1.0152], [0.6813], 
        [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.1146], [1.0183], [0.7689], 
        [*Riqueza colémbolos*],       [coll_species_richness_z], [-0.6465], [0.6606], [0.4997], 
        [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [0.0155],  [1.0902], [0.8042], 
        [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [-0.0662], [1.1129], [0.8448], 
        [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.2233],  [0.7155], [0.5091], 
        [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [0.1650],  [0.9178], [0.7293], 
        [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [0.0983],  [0.9369], [0.7733], )], 
    caption: [Resultados de XGBoost multisalida (ensamble) sobre eval.csv, por _target_.], 
    kind: table 
  )<tab-27>

#let file = "../media/anexos/xgb_multisalida.pdf"
#let total_pages = 11 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelos MLP mutlisalida <mlp-multi>

==== Fundamentos y configuración

El perceptrón multicapa (véase #link(<redes-neuronales>)[*Redes neuronales*]), implementado sobre PyTorch, representa el único enfoque de aprendizaje profundo de este trabajo. 

La arquitectura (*MLPMultiSalida*) es una red densa totalmente conectada: cada capa oculta combina una transformación lineal, una activación no lineal y una capa de Dropout para regularización. La capa de salida es lineal y tiene 21 neuronas, una por _target_, compartiendo todas ellas las mismas capas ocultas. 

Se entrena con el *optimizador Adam* y la *función de pérdida MSE estándar*, calculada conjuntamente sobre los 21 _targets_.

A diferencia de los modelos basados en árboles, aquí el _tuning_ no busca solo hiperparámetros de entrenamiento sino también la propia arquitectura de la red.

Se evaluaron 6 configuraciones distintas, variando el tamaño de las capas ocultas (de [32, 16] a [64, 16, 8]), la tasa de dropout (0.2-0.4), la tasa de aprendizaje, el número de épocas y el weight_decay (regularización L2 del propio optimizador Adam). 

La mejor configuración obtenida se puede ver en la #ref(<tab-28>).

#figure(
  align(center)[
    #table( 
      columns: (20%, 20%), 
      align: (left, center), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Hiperparámetro*], 
        [*Valor*]), 
          [*Capas ocultas*], [[128, 32]], 
          [*dropout*],       [0.3], 
          [*lr*],            [0.0005], 
          [*epochs*],        [250], 
          [*batch_size*],    [16], 
          [*weight_decay*],  [0.001], 
    )
  ],
  caption: [Consenso de hiperparámetros en MLP Multisalida.],
  kind: table
)<tab-28>

==== Entrenamiento

A diferencia de los modelos basados en árboles, este _notebook_ no aplica una validación cruzada explícita tipo `RepeatedKFold`: dado el coste computacional de reentrenar una red neuronal por cada pliegue y cada una de las 6 configuraciones evaluadas, la selección de la arquitectura se apoya en la partición fija de `train.csv/test.csv`, monitorizando la curva de pérdida (entrenamiento frente a validación) por época para detectar sobreajuste. 

Al ser un modelo determinista una vez fijada la semilla de inicialización de pesos, no se entrena un ensamblado de varias semillas como en _Random Forest_ o XGBoost, sino un único modelo con la configuración ganadora.

==== Explicabilidad y variables más relevantes

Al no disponer las redes neuronales de una medida de importancia intrínseca como los árboles, se recurre a permutation importance sobre un modelo de referencia entrenado sobre todo `X_train`. 

El top-10 resultante es el siguiente: `soil_ph_z`, `gee_temp_media_C_z`, `dem_elevacion_m_z`, `eu_p_z`, `eu_ph_z`, `gee_humedad_rel_pct_z`, `gee_ndvi_verano_z`, `silt_content_z`, `bulk_density_z`, `clay_content_z`. 

Vuelve a situar a `soil_ph_z` y `gee_temp_media_C_z` en primer y segundo lugar, exactamente igual que en Ridge y en _Random Forest_, lo que refuerza aún más la robustez de ambas variables como predictores del problema, con independencia del tipo de modelo empleado.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Importancia de variables*.

==== Resultados sobre eval.csv

Con un R² medio de *-0.038*, el MLP multisalida se sitúa por debajo de los tres modelos basados en árboles y también por debajo del modelo Ridge. 

Sobre los _targets_ prioritarios obtiene *R²=0.4264* (`earthworm_shannon_z`) y *R²=0.5176* (`earthworm_richness_z`), resultados razonables a pesar de que el rendimiento global se ve penalizado por un desempeño muy negativo en varios _targets_ minoritarios, en particular `coll_species_richness_z` (R²=-1.4628), con diferencia el peor resultado individual obtenido por ningún modelo sobre ningún _target_ en todo este trabajo. 

Este comportamiento es coherente con la limitación señalada en la introducción del propio _notebook_: las redes neuronales necesitan, en general, más datos de entrenamiento para generalizar bien, especialmente en los _targets_ con menos señal predictiva.

En la #ref(<tab-29>) se pueden ver los resultados por _target_ obtenidos tras entrenar el modelo.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto), 
      align: (left, left, center) , 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*]),  
        [*Shannon nemátodos*],        [nematode_shannon_z],      [0.1180], 
        [*Shannon macrofauna*],       [macro_shannon_z],         [0.2571], 
        [*Shannon lombrices*],        [earthworm_shannon_z],     [0.4264], 
        [*Shannon oribátidos*],       [orib_shannon_z],          [0.2356], 
        [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.4898], 
        [*Shannon colémbolos*],       [coll_shannon_z],          [-0.8227], 
        [*Shannon bacterias*],        [bac_shannon_z],           [-0.0854], 
        [*Shannon hongos*],           [fun_shannon_z],           [-0.0757], 
        [*Shannon eucariotas*],       [euk_shannon_z],           [0.1453],  
        [*Shannon oomicetos*],        [oomy_shannon_z],          [0.1534], 
        [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.1361], 
        [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.3525], 
        [*Riqueza lombrices*],        [earthworm_richness_z],    [0.5176], 
        [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2596], 
        [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.2753], 
        [*Riqueza colémbolos*],       [coll_species_richness_z], [-1.4628], 
        [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [-0.1464], 
        [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [0.0145], 
        [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.2164], 
        [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [0.0113], 
        [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [-0.0120], 
        )], 
    caption: [R² del MLP multisalida sobre eval.csv, por _target_.], 
    kind: table 
  )<tab-29>

#let file = "../media/anexos/mlp_multisalida.pdf"
#let total_pages = 8 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Modelos MLP con función de pérdida personalizada <mlp-custom-loss>

==== Fundamentos y configuración

Esta variante extiende el MLP multisalida anterior con una función de pérdida personalizada (`CorrelationAwareLoss`) que combina dos componentes:

$ L(y,hat(y)) = "MSE"(y,hat(y)) + lambda_"corr" parallel "Corr"(y) - "Corr"(hat(y)) parallel_F $

El primer término es el *MSE estándar*, que minimiza el error de predicción de cada _target_ por separado. El segundo penaliza la diferencia (*norma de Frobenius*) entre la matriz de correlación de las predicciones del lote actual y la matriz de correlación de los valores reales del mismo lote: si el modelo predice, por ejemplo, una diversidad alta de lombrices junto con una diversidad muy baja de colémbolos cuando ambas normalmente co-varían en los datos reales, este término penaliza esa incoherencia, aunque el error individual (MSE) de cada _target_ por separado sea bajo. 

El parámetro `lambda_corr` controla el peso relativo de esta penalización frente al MSE (`lambda_corr=0` equivale a MSE puro).

El _tuning_ explora 10 configuraciones que combinan arquitectura, hiperparámetros de entrenamiento y distintos valores de `lambda_corr` (de 0.0 a 0.5). El resultado del _tuning_ es, en sí mismo, uno de los hallazgos más relevantes de este _notebook_.

En la #ref(<tab-30>) se puede ver los diferentes conjuntos de hiperparámetros probados y los resultados de cada uno, sienod el $R²$ en negrita, el mejor valor de todos.

#figure(
  align(center)[
    #table( 
      columns: (auto, auto, auto, auto), 
      align: (center, center, center, center), 
      fill: (col, row) => if row == 0 { rgb("d6e3da") }, 
      table.header([*Capas ocultas*], [*lambda_corr*], [*weight_decay*], [*R² validación*]), 
        [[32, 16]],      [0.0],  [0.01],  [0.1151], 
        [[64, 32]],      [0.0],  [0.01],  [*0.1495*], 
        [[64, 32]],      [0.05], [0.005], [0.1202], 
        [[64, 32]],      [0.1],  [0.005], [0.1321], 
        [[128, 64]],     [0.05], [0.002], [0.1375], 
        [[128, 64]],     [0.2],  [0.002], [0.1185], 
        [[128, 32]],     [0.1],  [0.001], [0.1419], 
        [[128, 32]],     [0.3],  [0.002], [0.1092], 
        [[64, 16, 8]],   [0.1],  [0.001], [0.1186], 
        [[64, 16, 8]],   [0.5],  [0.005], [0.0071], 
        [[128, 64, 32]], [0.2],  [0.005], [0.0304], )
  ],
  caption: [Combinaciones de arquitecturas para MLP _Custom Loss_],
  kind: table
)<tab-30>

La configuración ganadora del _tuning_ fue `hidden=[64, 32]` con `lambda_corr=0.0`, es decir: de entre todas las combinaciones probadas, la que mejor R² de validación obtuvo fue la que equivale a MSE puro, sin ninguna penalización de correlación activa. 

Esto indica que, con el tamaño de _dataset_ disponible en este trabajo, el término adicional de coherencia de correlaciones no aportó una mejora medible frente al MSE estándar e incluso empeoró el resultado en la mayoría de las configuraciones donde se activó.

#colbreak()

==== Entrenamiento

Al igual que en el MLP multisalida estándar, no se aplica una validación cruzada explícita: la arquitectura se selecciona mediante la comparación directa de las 10 configuraciones del _tuning_ sobre la partición fija de entrenamiento/validación, y se entrena un único modelo final con la configuración ganadora (sin ensamblado de semillas).

Además de las métricas de error habituales, este _notebook_ calcula la diferencia media entre la matriz de correlación real y la matriz de correlación predicha como indicador directo de si la función de pérdida personalizada está cumpliendo su objetivo. Sobre `X_train`, esta diferencia media es de *0.1131*.

==== Explicabilidad y variables más relevantes

Al igual que en el MLP multisalida estándar, se recurre a permutation importance sobre `X_train`, esta vez calculada de forma global sobre los 21 _targets_. 

El top-10 resultante es: `soil_ph_z`, `gee_humedad_rel_pct_z`, `eu_ph_z`, `dem_elevacion_m_z`, `eu_p_z`, `gee_ndvi_verano_z`, `gee_temp_media_C_z`, `eu_cn_ratio_z`, `eu_zn_z` y `silt_content_z`. 

`soil_ph_z` mantiene su primer puesto respecto al MLP multisalida estándar, aunque con una importancia relativa considerablemente mayor (0.165 frente a 0.135), lo que sugiere que, al reforzar la coherencia entre _targets_, el modelo termina apoyándose todavía más en la variable individual con mayor poder predictivo del conjunto.

La gráfica que muestra las variables más importantes se puede ver más adelante en el _notebook_ exportado en la sección *5.- Importancia de variables*.

==== Resultados sobre eval.csv

Con un R² medio de *-0.1316*, este es el modelo con *peor rendimiento global* de los ocho evaluados en este trabajo, por debajo incluso del MLP multisalida estándar (-0.038) del que parte. 

Esto es consistente con el resultado del propio _tuning_: al haberse seleccionado `lambda_corr=0.0` como configuración óptima, el modelo final es, en la práctica, equivalente a un MLP multisalida con una arquitectura ligeramente distinta ([64,32] en vez de [128,32]) y menos épocas de entrenamiento (150 en vez de 250), sin que la penalización de correlación llegue a aplicarse de forma efectiva. 

Sobre los _targets_ prioritarios obtiene *R²=0.3750* (`earthworm_shannon_z`) y *R²=0.4671* (`earthworm_richness_z`), ambos por debajo de los conseguidos por el MLP multisalida estándar. El _target_ `coll_species_richness_z` vuelve a ser el más problemático, con un *R²=-2.2411*, el peor resultado individual de todo este trabajo.

#colbreak()

En la #ref(<tab-31>) se pueden ver los resultados obtenidos por _target_ tras el entrenamiento del modelo.

#figure( 
  align(center)[ 
    #table( 
      columns: (auto, auto, auto), 
      align: (left, left, center) , 
      fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Variable*], 
        table.cell(align: center)[*_Target_*], 
        [*$R^2$*]), 
        [*Shannon nemátodos*],        [nematode_shannon_z],      [0.0903], 
        [*Shannon macrofauna*],       [macro_shannon_z],         [0.2676], 
        [*Shannon lombrices*],        [earthworm_shannon_z],     [0.3750], 
        [*Shannon oribátidos*],       [orib_shannon_z],          [0.2216], 
        [*Shannon mesostigmátidos*],  [meso_shannon_z],          [-0.6189], 
        [*Shannon colémbolos*],       [coll_shannon_z],          [-1.3439], 
        [*Shannon bacterias*],        [bac_shannon_z],           [-0.1004], 
        [*Shannon hongos*],           [fun_shannon_z],           [-0.0842], 
        [*Shannon eucariotas*],       [euk_shannon_z],           [0.0868], 
        [*Shannon oomicetos*],        [oomy_shannon_z],          [0.0588], 
        [*Shannon cercozoos*],        [cerc_shannon_z],          [-0.1194], 
        [*Riqueza macrofauna*],       [macro_order_richness_z],  [0.3759], 
        [*Riqueza lombrices*],        [earthworm_richness_z],    [0.4671], 
        [*Riqueza oribátidos*],       [orib_species_richness_z], [0.2542], 
        [*Riqueza mesostigmátidos*],  [meso_species_richness_z], [-0.3462], 
        [*Riqueza colémbolos*],       [coll_species_richness_z], [-2.2411], 
        [*Riqueza bacterias (ASV)*],  [bac_asv_richness_z],      [-0.1680], 
        [*Riqueza hongos (ASV)*],     [fun_asv_richness_z],      [0.0027], 
        [*Riqueza eucariotas (ASV)*], [euk_asv_richness_z],      [0.1902], 
        [*Riqueza oomicetos (ASV)*],  [oomy_asv_richness_z],     [-0.0546], 
        [*Riqueza cercozoos (ASV)*],  [cerc_asv_richness_z],     [-0.0770], 
      )], 
    caption: [R² del MLP con pérdida personalizada sobre eval.csv, por _target_.], 
    kind: table 
  )<tab-31>

#let file = "../media/anexos/mlp_custom_loss.pdf"
#let total_pages = 9
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}