== Pruebas llevadas a cabo (Anexo V) <pruebas-llevadas-a-cabo>

En este anexo se indican las pruebas adicionales realizadas y los resultados que estas mismas han mostrado.
Todas estas pruebas, junto con sus iteraciones o fases se han realizado en ramas independientes, por lo tanto los resultados se podrán comparar de forma independiente dentro del repositorio de GitHub. La distribución de las ramas se puede ver en el #link(<dist-ramas-y-notebooks>)[*Anexo VI*]. 

Cabe tener en cuenta que el ajuste de hiperparámetros de cada modelo no se contabiliza como una prueba independiente al escogerse siempre la combinación que presente el mayor $R²$ de validación, no es un experimento con un resultado abierto del que se pueda llevar a una discusión, sino un paso rutinario de optimización.

=== Prueba de eliminación de variables <prueba-1>

El objetivo de esta primera prueba es evaluar si todas las variables escogidas, un total de 34 dentro de `FEATURES_AUTORIZADAS`, aportan capacidad predictiva real o si existen variables redundantes o de bajo peso cuya eliminación simplifica el modelo sin perjudicar, o incluso mejorando, su rendimiento.

Esto se hace evaluando las 21 variables objetivo, no solo sobre los _targets_ de referencia (`earthworm_shannon` y `earthworm_richness`).

Para decidir qué variables son candidatas a eliminarse se parte de los criterios de importancia ya calculados en los propios _notebooks_ de modelado: el coeficiente de _Ridge_ (`|coef_|`, por _target_ y agregado en media global) y, para _Random Forest_/RegressorChain, la importancia MDI y SHAP (`TreeExplainer`) sobre el primer modelo de la cadena. Se descartan las variables que aparecen de forma consistente en el _bottom-10_ de ambos criterios.

Sobre el conjunto base de 34 variables se prueban varios pasos, reentrenando los 8 modelos del _pipeline_ en cada uno (mismo `random_state=42` e hiperparámetros ya optimizados para la configuración base, sin re-tunear, para aislar el efecto de las variables) y evaluando sobre los 21 _targets_. Las tres candidatas de baja importancia identificadas como _bottom-10_ en el cruce de criterios (`cu_z`, `ni_z` y `mo_z`) se eliminan tanto de forma individual como en combinación (`cu_z`+`ni_z`, `cu_z`+`mo_z`, `mo_z`+`ni_z` y las tres a la vez).

Como se puede ver en la #ref(<tab-59>) y en la #ref(<fig-23>), se muestran los resultados de la eliminación de variables en todas sus iteraciones.

#figure(
  table(
    columns: 9,
    align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*_Baseline_*], [*sin cu_z*], [*sin ni_z*], [*sin cu_z\ +ni_z*], [*sin mo_z*], [*sin cu_z\ +mo_z*], [*sin mo_z\ +ni_z*], [*sin cu_z\ +mo_z\ +ni_z*],
    ),
    [*_Ridge_*],               [-0.016], [-0.016], [-0.013], [-0.013], [-0.024], [-0.027], [-0.021], [-0.026],
    [*_Random Forest_*],     [0.090],  [0.089],  [0.094],  [0.087],  [0.096],  [0.087],  [0.092],  [0.091],
    [*RF multisalida*],      [0.096],  [0.090],  [0.091],  [0.097],  [0.091],  [0.098],  [0.096],  [0.098],
    [*XGBoost*],             [0.067],  [0.069],  [0.068],  [0.067],  [0.072],  [0.068],  [0.067],  [0.068],
    [*XGBoost multisalida*], [0.084],  [0.078],  [0.083],  [0.080],  [0.088],  [0.081],  [0.079],  [0.080],
    [*RegressorChain*],      [0.081],  [0.078],  [0.080],  [0.076],  [0.081],  [0.078],  [0.079],  [0.083],
    [*MLP multisalida*],     [0.002],  [-0.009], [-0.080], [-0.010], [-0.029], [0.047],  [-0.063], [0.055],
    [*MLP _custom loss_*],     [-0.098], [-0.021], [-0.080], [-0.020], [-0.036], [-0.081], [-0.105], [-0.043],
  ),
  caption: [Resultados agregados de $R²$ (media sobre los 21 _targets_) por modelo y variante de eliminación de variables.],
  kind: table
)<tab-59>

#figure(
  image("../media/heatmap_var_elimination.png"),
  caption: [Heatmap $R²$ por modelo y variante de eliminación de variables, con el Δ respecto al _baseline_ de cada celda.],
  kind: image
)<fig-23>

En los dos _targets_ prioritarios los resultados apenas cambian respecto al _baseline_, dichos resultados se pueden ver en la #ref(<tab-60>):

#figure(
  table(
    columns: 5,
    align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*R² Shannon\ (_Baseline_)*], [*R² Shannon\ (sin cu_z + mo_z + ni_z)*], [*R² Richness\ (_Baseline_)*], [*R² Richness\ (sin cu_z + mo_z + ni_z)*],
    ),
    [*_Ridge_*],               [0.2395], [0.2430], [0.2789], [0.2775],
    [*_Random Forest_*],     [0.5041], [0.5081], [0.5722], [0.5620],
    [*RF multisalida*],      [0.4160], [0.4178], [0.4509], [0.4581],
    [*XGBoost*],             [0.4946], [0.5012], [0.5171], [0.5124],
    [*XGBoost\ multisalida*], [0.5375], [0.5482], [0.5893], [0.5960],
    [*RegressorChain*],      [0.4876], [0.4742], [0.5359], [0.5242],
    [*MLP multisalida*],     [0.3583], [0.4029], [0.4539], [0.4809],
    [*MLP _custom loss_*],     [0.3438], [0.3776], [0.4543], [0.4551],
  ),
  caption: [$R²$ en los dos _targets_ prioritarios (`earthworm_shannon_z`, `earthworm_richness_z`) para el _baseline_ y la variante sin `cu_z+mo_z+ni_z`.],
  kind: table
)<tab-60>

Los *modelos basados en árboles* (_Random Forest_, XGBoost, RegressorChain, en ambas variantes) mantienen un $R²$ agregado estable entre 0.07 y 0.10 con independencia de qué variables de baja importancia se eliminen, por lo que la elección entre `cu_z`, `ni_z` y `mo_z` (o sus combinaciones) apenas les afecta. 

_Ridge_ se mantiene siempre en valores bajos o negativos, coherente con su incapacidad de capturar relaciones no lineales sobre la mayoría de los 21 _targets_. Los dos MLP son los más sensibles, fluctuando entre -0.10 y +0.06 sin un patrón claro, lo que apunta más a inestabilidad de entrenamiento que a un efecto real de las variables eliminadas.

#colbreak()

El hallazgo más relevante de esta prueba, sin embargo, no es sobre las variables sino sobre los _targets_: el $R²$ medio sobre los 21 _targets_ es sustancialmente más bajo que el $R²$ sobre los dos _targets_ prioritarios de lombrices (p. ej. RF multisalida: ~0.09-0.10 agregado frente a ~0.42-0.46 en Shannon/Richness), y esto no cambia con ninguna variante de variables probada. 

Es una confirmación empírica del riesgo de _negative transfer_ planteado de forma teórica en el apartado 1.2: al forzar una representación compartida entre 21 indicadores muy heterogéneos, el modelo optimiza bien para los _targets_ dominantes a costa de rendir mal en el resto. Esto lleva a matizar que XGBoost (en ambas variantes) es el modelo que mejor generaliza sobre los dos _targets_ prioritarios, mientras que RF multisalida es el que mejor generaliza al conjunto completo de 21 _targets_.

Como conclusión, se mantienen las 34 variables originales como configuración definitiva del TFG: ninguna variante probada mejora de forma clara y generalizada todos los modelos a la vez, y la ganancia en simplicidad del _pipeline_ de ingesta sería mínima.

#colbreak()

=== Prueba de sensibilidad al random state <prueba-2>

El objetivo de esta prueba es evaluar cuánto varía el rendimiento de cada modelo al cambiar únicamente la semilla aleatoria (`random_state`), manteniendo el resto de la configuración fija (hiperparámetros, variables, partición de datos), para estimar cuánto del rendimiento observado se debe al modelo/variables y cuánto a la inicialización aleatoria. 

Es una pregunta directamente relevante dado que, salvo _Ridge_, todos los modelos de este TFG se entregan en producción como un ensamble de varias semillas.

Se reentrenan los 8 modelos con tres semillas concretas (`random_state` = 27, 42 y 128), manteniendo fijos hiperparámetros, variables y partición de datos, y se evalúa el $R²$ sobre los 21 _targets_. Los resultados de esta prueba se pueden ver en la #ref(<tab-61>) y de forma gráfica en la #ref(<fig-24>).

#figure(
  table(
    columns: 6,
    align: (left, center, center, center, center, center),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*rs=27*], [*rs=42*], [*rs=128*], [*Media*], [*Desv. típica*],
    ),
    [*_Ridge_*], [-0.0164], [-0.0164], [-0.0164], [-0.0164], [0.0000],
    [*_Random Forest_*], [0.0890], [0.0904], [0.0933], [0.0909], [0.0022],
    [*RF multisalida*], [0.1205], [0.0964], [0.1175], [0.1115], [0.0132],
    [*XGBoost*], [0.0591], [0.0670], [0.0680], [0.0647], [0.0049],
    [*XGBoost multisalida*], [0.0872], [0.0835], [0.0874], [0.0861], [0.0022],
    [*RegressorChain*], [0.0549], [0.0809], [0.0769], [0.0709], [0.0140],
    [*MLP multisalida*], [-0.0235], [-0.0380], [-0.0400], [-0.0339], [0.0090],
    [*MLP _custom loss_*], [-0.0978], [-0.1316], [-0.0023], [-0.0773], [0.0670],
  ),
  caption: [$R²$ agregado (media sobre los 21 _targets_) por modelo y semilla (`random_state` = 27, 42, 128).],
  kind: table
)<tab-61>

#figure(
  image("../media/heatmap_sensibilidad_rs.png", height: 45% ),
  caption: [Heatmap $R²$ por modelo y random_state.],
  kind:image
)<fig-24>

#colbreak()

En la #ref(<tab-62>) se puede ver el _ranking_ calculado agregado con `comparador_sensibilidad_rs.py` sobre los 21 _targets_ × 3 semillas (63 evaluaciones por modelo, _rank_ 1 = mejor $R²$ en esa combinación _target_/semilla):

#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*_Rank_ medio*], [*Desv. típica del _rank_*], [*% de veces 1º*],
    ),
    [*RF multisalida*],      [2.86], [1.71], [30.2%],
    [*_Random Forest_*],     [3.33], [1.51], [9.5%],
    [*RegressorChain*],      [3.48], [1.57], [6.3%],
    [*XGBoost multisalida*], [3.90], [2.47], [30.2%],
    [*XGBoost*],             [4.52], [1.66], [3.2%],
    [*MLP multisalida*],     [5.48], [2.33], [11.1%],
    [*_Ridge_*],               [6.14], [2.27], [7.9%],
    [*MLP _custom loss_*],   [6.27], [1.76], [1.6%],
  ),
  caption: [_Ranking_ agregado por modelo sobre los 21 _targets_ × 3 semillas (63 evaluaciones por modelo).],
  kind:table
)<tab-62>

En la #ref(<tab-63>) se pueden ver los resultados, pero enfocándolo a los dos _targets_ prioritarios:

#figure(
  table(
    columns: 7,
    align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},    
    table.header(
      [*Modelo*], [*Shannon (rs=27)*], [*Shannon (rs=42)*], [*Shannon (rs=128)*], [*Richness (rs=27)*], [*Richness (rs=42)*], [*Richness (rs=128)*],
    ),
    [*_Ridge_*],               [0.2395], [0.2395], [0.2395], [0.2789], [0.2789], [0.2789],
    [*_Random Forest_*],     [0.5068], [0.5041], [0.5067], [0.5636], [0.5722], [0.5672],
    [*RF\ multisalida*],      [0.4709], [0.4160], [0.4900], [0.5195], [0.4509], [0.5318],
    [*XGBoost*],             [0.4722], [0.4946], [0.4992], [0.4923], [0.5171], [0.5219],
    [*XGBoost multisalida*], [0.5433], [0.5375], [0.5395], [0.5947], [0.5893], [0.5977],
    [*RegressorChain*],      [0.4940], [0.4876], [0.4988], [0.5440], [0.5359], [0.5401],
    [*MLP\ multisalida*],     [0.3039], [0.4264], [0.3852], [0.4111], [0.5176], [0.4910],
    [*MLP\ _custom loss_*],   [0.3438], [0.3750], [0.3804], [0.4543], [0.4671], [0.4899],
  ),
  caption: [$R²$ en los dos _targets_ prioritarios por semilla (`random_state` = 27, 42, 128).],
  kind: table
)<tab-63>

_Ridge_ da exactamente el mismo $R²$ en las tres semillas, lo cual tiene sentido: `GridSearchCV` con `alpha` fijo y una solución cerrada no introduce ninguna aleatoriedad real en el ajuste, siendo el único modelo perfectamente reproducible entre semillas. MLP _custom loss_ es, con diferencia, el más sensible, con un $R²$ agregado que varía entre -0.132 y -0.002 (más de 5 veces la desviación típica de _Random Forest_ o XGBoost multisalida). Esto confirma empíricamente que el MLP, al depender de una inicialización de pesos aleatoria y de un orden de lotes aleatorio, es estructuralmente más sensible a la semilla que los modelos basados en árboles, y justifica que se ensamblen 5 redes en producción en vez de confiar en una sola.

En cuanto al _ranking_, RF multisalida y XGBoost multisalida empatan como los modelos que más veces quedan 1º (30.2% cada uno), pero RF multisalida tiene mejor _rank_ medio (2.86 vs. 3.90) y menor desviación típica de _rank_, es decir, es más consistentemente bueno sin ser tan extremo en ninguna dirección. _Ridge_ y MLP _custom loss_ ocupan de forma consistente las dos últimas posiciones.

Como conclusión, `random_state=42` no es ni la mejor ni la peor semilla para ningún modelo de forma sistemática, está dentro del rango normal de variación observado.

#colbreak()

=== Prueba de barrido de random_state <prueba-3>

Esta prueba automatiza la anterior sobre un rango amplio de semillas para caracterizar la distribución completa del rendimiento, no solo un puñado de valores puntuales, con el objetivo de justificar con datos el tamaño de ensamble elegido para cada modelo en producción (5 semillas para _Random Forest_, XGBoost y MLP. 10 cadenas para RegressorChain).

Se reentrenan los 8 modelos sobre dos barridos independientes de `random_state`: uno de 101 semillas (rama `model-prep-rs-group`) y otro de 491 semillas (rama `model-prep-rs-group-1`), evaluando en cada caso el $R²$ sobre los 21 _targets_ (agregado como "GLOBAL") y, por separado, sobre los dos _targets_ prioritarios. 

Los dos barridos se mantienen como ramas independientes en vez de fusionarse, lo que además permite usar el segundo como comprobación de estabilidad del primero.

En la #ref(<tab-64>) se pueden ver los resultados de ambas iteraciones a nivel global, mientras que en la #ref(<tab-65>) se pueden ver los resultados a nivel de los _targets_ prioritarios. Estos resultados se pueden ver de forma más gráfica en la #ref(<fig-25>).

#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*Media (101 semillas)*], [*Desv. típica*], [*Media (491 semillas)*], [*Desv. típica*],
    ),
    [*RF multisalida*],      [0.0953],  [0.0030], [0.0953],  [0.0033],
    [*_Random Forest_*],     [0.0890],  [0.0040], [0.0892],  [0.0042],
    [*XGBoost multisalida*], [0.0780],  [0.0055], [0.0786],  [0.0049],
    [*XGBoost*],             [0.0650],  [0.0043], [0.0655],  [0.0044],
    [*RegressorChain*],      [0.0635],  [0.0104], [0.0643],  [0.0116],
    [*_Ridge_*],             [-0.0164], [0.0000], [-0.0164], [0.0000],
    [*MLP multisalida*],     [-0.0271], [0.0342], [-0.0678], [0.0516],
    [*MLP _custom loss_*],   [-0.0495], [0.0312], [-0.0588], [0.0348],
  ),
  caption: [Media y desviación típica de $R²$ GLOBAL (21 _targets_) en los barridos de 101 y 491 semillas.],
)<tab-64>

#figure(
  table(
    columns: 5,
    align: (left+horizon, center+horizon, center+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*Shannon (101 s.)*], [*Shannon (491 s.)*], [*Richness (101 s.)*], [*Richness (491 s.)*],
    ),
    [*XGBoost\ multisalida*], [0.5343], [0.5330], [0.5866], [0.5867],
    [*_Random Forest_*],      [0.4990], [0.5018], [0.5643], [0.5635],
    [*XGBoost*],              [0.4921], [0.4914], [0.5140], [0.5135],
    [*RegressorChain*],       [0.4789], [0.4792], [0.5270], [0.5279],
    [*RF multisalida*],       [0.4140], [0.4142], [0.4493], [0.4494],
    [*MLP multisalida*],      [0.3452], [0.3653], [0.4354], [0.4592],
    [*MLP _custom loss_*],    [0.3169], [0.3464], [0.4185], [0.4491],
    [*_Ridge_*],              [0.2395], [0.2395], [0.2789], [0.2789],
  ),
  caption: [Media de $R²$ en los dos _targets_ prioritarios sobre los barridos de 101 y 491 semillas.],
)<tab-65>


#figure(
  image("../media/heatmap_barrido_rs.png"),
  caption: [Boxplot de $R²$ sobre el barrido de random_state (3 paneles: GLOBAL y los dos _targets_ prioritarios, comparando las dos ramas del barrido).],
  kind: image
)<fig-25>


#figure(
  table(
    columns: 5,
    align: (left, center, center, center, center),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      [*Modelo*], [*_Rank_ medio (101 s.)*], [*Desv. típica*], [*_Rank_ medio (491 s.)*], [*Desv. típica*],
    ),
    [*RF multisalida*],      [1.11], [0.34], [1.12], [0.34],
    [*_Random Forest_*],     [1.96], [0.37], [1.95], [0.42],
    [*XGBoost multisalida*], [3.09], [0.45], [3.10], [0.45],
    [*XGBoost*],             [4.38], [0.56], [4.44], [0.55],
    [*RegressorChain*],      [4.48], [0.74], [4.38], [0.76],
    [*_Ridge_*],             [6.48], [0.63], [6.25], [0.51],
    [*MLP multisalida*],     [6.90], [0.79], [7.42], [0.72],
    [*MLP _custom loss_*],   [7.61], [0.60], [7.33], [0.61],
  ),
  caption: [_Ranking_ medio por modelo a lo largo de las semillas, en cada uno de los dos barridos.],
  kind: table
)<tab-66>

_Ridge_ es el único modelo con desviación típica exactamente 0.0000 en ambos barridos, es decir, completamente determinista frente a `random_state`, comportamiento ya confirmado en la @prueba-2 y esperado por tratarse de una solución cerrada. En una primera ejecución de este barrido, XGBoost (variante _single-target_) mostró el mismo patrón (desviación 0.0000), lo cual resultaba anómalo dado que su configuración de `subsample` y `colsample_bytree` sí debería introducir variabilidad entre semillas. Tras repetir el experimento, la desviación observada para XGBoost _single-target_ es de 0.0043-0.0044, en línea con el resto de modelos basados en árboles (véanse las tablas anteriores), no se ha podido aislar con certeza qué causó el determinismo de la primera ejecución, por lo que los valores considerados válidos para esta memoria son los de la segunda.

El _ranking_, como se puede ver en la #ref(<tab-66>), es prácticamente idéntico entre los dos barridos pese a que uno tiene casi 5 veces más semillas que el otro, lo que es una fuerte evidencia de que 101 semillas ya son suficientes para estimar el _ranking_ de forma estable. RF multisalida es, con diferencia, el modelo más estable y con mejor _rank_ medio en ambos barridos, sin bajar nunca de la 2ª posición. Esto contrasta con la #link(<prueba-1>)[*Prueba de eliminación de variables*], donde XGBoost destacaba sobre los _targets_ prioritarios: en $R²$ global sobre los 21 _targets_ gana RF multisalida, en $R²$ sobre los dos _targets_ prioritarios gana XGBoost multisalida, son conclusiones distintas según qué métrica se priorice, no contradictorias.

Como conclusión, el barrido confirma que 5 semillas es un tamaño de ensamble razonable para _Random Forest_, XGBoost (ambas variantes) y RegressorChain, pero probablemente insuficiente para MLP dada su desviación típica varias veces mayor que el resto. Se recomienda considerar un ensamble mayor (p. ej. 10-15 redes) para las dos variantes de MLP, o al menos reportar esta limitación en las conclusiones finales.

=== Prueba de ensamblado de predicciones <prueba-4>

El objetivo de esta prueba es evaluar si combinar las predicciones de varios modelos base mejora el error frente al mejor modelo individual para el mismo _target_, probando dos enfoques distintos: combinación no supervisada (media y variantes) y combinación aprendida (`meta-modelo` de _stacking_).

Se cargan los 8 modelos de producción (cada uno como ensamblado interno de sus miembros: _Ridge_ sin ensamblado, el resto con 5 miembros salvo RegressorChain con 10) y se ejecuta el _smoke test_ habitual sobre la totalidad de `eval.csv` (65 filas), evaluando sobre los 21 _targets_ completos para tener una imagen comparable a las pruebas anteriores. Para evitar que las variantes que calibran algo con datos (pesos, _ranking_, coeficientes) se beneficien de ver la respuesta de antemano, `eval.csv` se separa en `meta-train` (70%, 45 filas) y _holdout_ (30%, 20 filas, `random_state=42`); todas las variantes se evalúan sobre el mismo _holdout_.

==== Combinación no supervisada de modelos base

Se prueban cinco formas de combinar los 8 modelos base: media simple, media ponderada por $R²$ (peso proporcional a max($R²$, 0) en `meta-train`), `top-k` (k=4, los mejores en `meta-train`), `mediana`, y `_stacking_ convexo` (pesos $w gt.eq 0$, $sum_i w_i = 1$, optimizados por SLSQP en `meta-train`).

Solo en 4 de 21 _targets_ (19%) alguna combinación supera al mejor modelo individual, y 15 de 21 (71%) muestran señal predictiva real. Cuando la mejor combinación no gana al individual, la mediana es la variante que más veces queda como mejor combinación (8/21), seguida del _stacking_ convexo (7/21), top-4 (4/21), media ponderada (1/21) y media simple (1/21). Estos resultados se pueden ver reflejados en la #ref(<tab-67>).

#figure(
  table(
    columns:(auto, auto, auto, auto, auto, auto),
    align: (left+horizon, left+horizon, center+horizon, left+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},
    table.header(
      table.cell(align:center)[*_Target_*], 
      table.cell(align: center)[*Mejor\ individual*], 
      [*R²\ individual*], [*Mejor\ combinación*], [*R² \ combinación*], [*¿Gana?*],
    ),
    [*macro_order_richness_z*],  [XGBoost\ multisalida], [0.5090],  [Top-4],                 [0.4580],  [No],
    [*earthworm_richness_z*],    [XGBoost\ multisalida], [0.5087],  [Stacking\ convexo],     [0.4970],  [No],
    [*cerc_asv_richness_z*],     [XGBoost\ multisalida], [0.4049],  [Mediana],               [0.3275],  [No],
    [*macro_shannon_z*],         [RegressorChain],       [0.4041],  [Top-4],                 [0.3749],  [No],
    [*earthworm_shannon_z*],     [RegressorChain],       [0.3750],  [Top-4],                 [0.3537],  [No],
    [*oomy_asv_richness_z*],     [RegressorChain],       [0.3043],  [Stacking\ convexo],     [0.3026],  [No],
    [*nematode_shannon_z*],      [XGBoost\ multisalida], [0.2808],  [Stacking\ convexo],     [0.2382],  [No],
    [*euk_asv_richness_z*],      [_Random\ Forest_],     [0.2195],  [Mediana],               [0.2165],  [No],
    [*cerc_shannon_z*],          [RF\ multisalida],      [0.1216],  [Mediana],               [0.0720],  [No],
    [*oomy_shannon_z*],          [MLP\ multisalida],     [0.1099],  [Stacking\ convexo],     [0.0850],  [No],
    [*euk_shannon_z*],           [RF\ multisalida],      [0.1038],  [Mediana],               [0.0569],  [No],
    [*meso_species_richness_z*], [_Random Forest_],      [0.0531],  [Mediana],               [0.0439],  [No],
    [*coll_shannon_z*],          [RF\ multisalida],      [-0.0590], [Mediana],               [0.0325],  [*Sí*],
    [*orib_shannon_z*],          [MLP\ _custom loss_],   [-0.0014], [Media\ ponderada (R²)], [0.0107],  [*Sí*],
    [*meso_shannon_z*],          [RegressorChain],       [0.0069],  [Mediana],               [-0.0618], [No],
    [*coll_species_richness_z*], [RF\ multisalida],      [-0.0691], [Stacking\ convexo],     [-0.0148], [*Sí*],
    [*fun_shannon_z*],           [_Ridge_],                [-0.0454], [Media simple],          [-0.0976], [No],
    [*orib_species_richness_z*], [RegressorChain],       [-0.0544], [Mediana],               [-0.0677], [No],
    [*fun_asv_richness_z*],      [_Ridge_],                [-0.0873], [Stacking\ convexo],     [-0.0863], [*Sí*],
    [*bac_asv_richness_z*],      [XGBoost\ multisalida], [-0.0890], [Stacking\ convexo],     [-0.1089], [No],
    [*bac_shannon_z*],           [RegressorChain],       [-0.1355], [Top-4],                 [-0.2458], [No],
  ),
  caption: [Comparación entre el mejor modelo individual y la mejor combinación no supervisada, por _target_.],
  kind: table
)<tab-67>

Los 4 casos en los que "gana" la combinación son, sin excepción, _targets_ donde el mejor modelo individual ya tenía $R²$ negativo o casi nulo, es decir, la combinación no mejora una señal fuerte, sino que suaviza el ruido cuando no hay señal real que explotar. 

En los _targets_ con señal fuerte ($R²$ > 0.2) el mejor modelo individual gana siempre, y por márgenes que no son pequeños, lo cual es coherente con la intuición de que promediar un modelo fuerte con modelos más débiles diluye la señal en vez de reforzarla.

#colbreak()

==== _Stacking_ con `meta-modelo`

En vez de combinar a mano, se entrena un `meta-modelo` por _target_ que aprende, a partir de las predicciones de los 8 modelos base sobre el meta-train, cómo combinarlas para acertar el valor real. 

Se prueban 5 candidatos en paralelo, sobre el mismo _holdout_ de 20 filas: 
- _Ridge_.
- Lasso ($alpha = 0.1$).
- ElasticNet ($alpha = 0.1$, `l1_ratio=0.5`)
- Regresión lineal sin regularizar. 
- _Random Forest_ (`n_estimators=200`, `max_depth=3`).

Como se puede ver en la #ref(<tab-68>), 9 de 21 _targets_ (43%), más del doble que con las combinaciones no supervisadas, tienen un `meta-modelo` (o el ensamblado simple por media) que supera al mejor modelo individual, y 18 de 21 (86%) muestran señal predictiva real frente al 71% anterior: el propio proceso de _stacking_ añade señal en _targets_ donde antes no la había. 

El reparto de victorias entre los "no individuales" está repartido sin un ganador claramente dominante: `ensamblado por media` (5/21), `meta-modelo _Random Forest_` (4/21), `_Ridge_` (3/21), `Linear` (3/21), `ElasticNet` (3/21), `Lasso` (3/21).

#figure(
  table(
    columns: 6,
    align: (left+horizon, left+horizon, center+horizon, left+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},    
    table.header(
      table.cell(align: center)[*_Target_*], 
      table.cell(align: center)[*Mejor\ individual*], [*R²\ individual*], 
      table.cell(align: center)[*Mejor\ no-individual*], [*R²\ no-individual*], [*¿Gana?*],
    ),
    [*earthworm_richness_z*],    [XGBoost\ multisalida],  [0.5087],  [Meta-modelo\  (_Ridge_)],           [0.5299],  [*Sí*],
    [*coll_species_richness_z*], [RF\ multisalida],       [-0.0691], [Meta-modelo\  (_Random Forest_)], [0.5264],  [*Sí*],
    [*macro_order_richness_z*],  [XGBoost\ multisalida],  [0.5090],  [Ensamblado \ (media)],            [0.4026],  [No],
    [*cerc_asv_richness_z*],     [XGBoost\ multisalida],  [0.4049],  [Meta-modelo\  (_Random Forest_)], [0.4742],  [*Sí*],
    [*macro_shannon_z*],         [Regressor\ Chain],      [0.4041],  [Ensamblado \ (media)],            [0.3036],  [No],
    [*coll_shannon_z*],          [RF\ multisalida],       [-0.0590], [Meta-modelo\  (Linear)],          [0.3928],  [*Sí*],
    [*earthworm_shannon_z*],     [Regressor\ Chain],      [0.3750],  [Meta-modelo\  (_Random Forest_)], [0.3411],  [No],
    [*oomy_asv_richness_z*],     [Regressor\ Chain],      [0.3043],  [Meta-modelo\  (_Ridge_)],           [0.2664],  [No],
    [*nematode_shannon_z*],      [XGBoost\ multisalida],  [0.2808],  [Meta-modelo\  (_Ridge_)],           [0.2550],  [No],
    [*euk_asv_richness_z*],      [_Random\ Forest_],      [0.2195],  [Meta-modelo\  (ElasticNet)],      [0.2099],  [No],
    [*cerc_shannon_z*],          [RF\ multisalida],       [0.1216],  [Ensamblado \ (media)],            [0.0665],  [No],
    [*oomy_shannon_z*],          [MLP\ multisalida],      [0.1099],  [Meta-modelo\  (_Random Forest_)], [0.0507],  [No],
    [*euk_shannon_z*],           [RF\ multisalida],       [0.1038],  [Meta-modelo\  (Lasso)],           [0.0788],  [No],
    [*meso_species_richness_z*], [_Random\ Forest_],      [0.0531],  [Ensamblado \ (media)],            [-0.0027], [No],
    [*fun_shannon_z*],           [_Ridge_],                 [-0.0454], [Meta-modelo\  (Linear)],          [0.0301],  [*Sí*],
    [*bac_asv_richness_z*],      [XGBoost\ multisalida],  [-0.0890], [Meta-modelo\  (ElasticNet)],      [0.0269],  [*Sí*],
    [*orib_shannon_z*],          [MLP\ _custom loss_],    [-0.0014], [Meta-modelo\  (Lasso)],           [0.0146],  [*Sí*],
    [*meso_shannon_z*],          [Regressor\ Chain],      [0.0069],  [Meta-modelo\  (Linear)],          [-0.0665], [No],
    [*fun_asv_richness_z*],      [_Ridge_],                 [-0.0873], [Meta-modelo\  (Lasso)],           [-0.0189], [*Sí*],
    [*bac_shannon_z*],           [Regressor\ Chain],      [-0.1355], [Meta-modelo\  (ElasticNet)],      [-0.0500], [*Sí*],
    [*orib_species_richness_z*], [Regressor\ Chain],      [-0.0544], [Ensamblado \ (media)],            [-0.0775], [No],
  ),
  caption: [Comparación entre el mejor modelo individual y el mejor meta-modelo o ensamblado, por _target_ (_holdout_ de 20 filas).],
  kind: table
)<tab-68>

En la #ref(<tab-69>) se pueden ver los resultados pero centrados en los dos _targets_ prioritarios:

#figure(
  table(
    columns: 3,
    align: (left+horizon, center+horizon, center+horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da")},    
    table.header(
      table.cell(align: center)[*Modelo*], [*Shannon*], [*Richness*],
    ),
    [*_Ridge_*],                           [-0.1160],  [-0.1531],
    [*_Random Forest_*],                 [0.3653],   [0.5028],
    [*XGBoost*],                         [0.3157],   [0.4989],
    [*RF multisalida*],                  [0.3560],   [0.4353],
    [*XGBoost multisalida*],             [0.3227],   [0.5087],
    [*RegressorChain*],                  [*0.3750*], [0.4934],
    [*MLP multisalida*],                 [-0.0194],  [0.1671],
    [*MLP _custom loss_*],               [0.0703],   [0.2336],
    [*`Meta-modelo` (_Ridge_)*],           [0.2975],   [*0.5299*],
    [*`Meta-modelo` (Lasso)*],           [0.3263],   [0.5175],
    [*`Meta-modelo` (ElasticNet)*],      [0.3281],   [0.4762],
    [*`Meta-modelo` (Linear)*],          [0.0092],   [0.5087],
    [*`Meta-modelo` (_Random Forest_)*], [0.3411],   [0.1920],
  ),
  caption: [$R²$ de todos los candidatos (modelos base y `meta-modelos`) en los dos _targets_ prioritarios (_holdout_).],
  kind: table
)<tab-69>

El _stacking_ aprendido bate claramente a las combinaciones no supervisadas (43% vs. 19% de _targets_ donde gana al mejor individual), lo cual tiene sentido: un `meta-modelo` puede aprender a ignorar a los modelos débiles en vez de darles peso fijo por su $R²$. 

El caso más llamativo es `coll_species_richness_z`, donde ningún modelo individual tenía señal útil (mejor $R² = -0.069$) y el `meta-modelo` _Random Forest_ alcanza 0.526. Sin embargo, en los dos _targets_ prioritarios los resultados son mixtos: en Richness el `meta-modelo` _Ridge_ gana por un margen modesto (0.530 vs. 0.509), pero en Shannon ningún `meta-modelo` supera a RegressorChain (0.375), y la regresión lineal sin regularizar colapsa a $R² approx 0.01$, señal de sobreajuste al `meta-train` con solo 45 filas de entrenamiento.

#colbreak()

Como conclusión, ninguna de las dos familias de ensamblado justifica sustituir el _pipeline_ de 8 modelos independientes por un único combinador en producción: la ganancia es real pero concentrada en _targets_ que de partida no tenían señal predictiva, y en los _targets_ con señal fuerte, incluidos los dos prioritarios, el mejor modelo individual sigue siendo, en general, más fiable. 

El _stacking_ con `meta-modelo` es la variante más prometedora si en el futuro se quisiera explorar esta vía más a fondo, pero con un `meta-train` de solo 45 filas el riesgo de sobreajuste recomienda tratarlo como línea de trabajo futura y no como alternativa lista para producción.

=== Discusión general <discusion-general>

Esta sección enlaza los hallazgos de las cuatro pruebas anteriores con la hipótesis de partida planteada en las principales aportaciones del TFG: que, con un _dataset_ reducido, los modelos basados en árboles igualan o superan al MLP.

La hipótesis se confirma, aunque con matices sobre cuál es "el" modelo ganador. En las pruebas de este anexo, los modelos basados en árboles (_Random Forest_, XGBoost, RegressorChain, y sus variantes multisalida) ocupan de forma consistente las primeras posiciones, tanto en $R²$ agregado sobre los 21 _targets_ (#link(<prueba-1>)[*Prueba de eliminación de variables*], #link(<prueba-3>)[*Prueba de barrido de `random_state`*]) como en el _ranking_ por semilla (#link(<prueba-2>)[*Prueba de sensibilidad de `random_state`*], #link(<prueba-3>)[*Prueba de barrido de `random_state`*]). 

Los dos MLP y _Ridge_ quedan sistemáticamente en las últimas posiciones. Sin embargo, "ganador" no es una etiqueta única: RF multisalida es el modelo con mejor $R²$ agregado sobre los 21 _targets_, confirmado en la #link(<prueba-1>)[*Prueba de eliminación de variables*] (0.096 _baseline_) y en la #link(<prueba-3>)[*Prueba de barrido de `random_state`*] (_rank_ medio 1.11--1.12 en 101 y 491 semillas), mientras que XGBoost multisalida es el modelo con mejor $R²$ sobre los dos _targets_ prioritarios de lombrices, también confirmado en ambas pruebas (#link(<prueba-1>)[*Prueba de eliminación de variables*]: 0.5375/0.5893; #link(<prueba-3>)[*Prueba de barrido de `random_state`*]: 0.5330,0.5343/0.5866,0.5867). 

No es una contradicción entre pruebas, sino una diferencia real de comportamiento según qué métrica se priorice.

El hallazgo más importante no es de modelo, sino de _target_: se trata de _negative transfer_. La #link(<prueba-1>)[*Prueba de eliminación de variables*] muestra que el $R²$ agregado sobre los 21 _targets_ es sustancialmente más bajo, en todos los modelos, que el $R²$ sobre los dos _targets_ prioritarios, no solo en los multisalida, sino también en los modelos _single-target_ evaluados sobre el mismo conjunto de 21 _targets_. 

Esto confirma que el problema no es exclusivo de compartir representación entre salidas, sino que refleja la heterogeneidad real de los 21 _targets_ como problema de predicción. La variante multisalida añade además el riesgo teórico de _negative transfer_ (optimizar bien los _targets_ dominantes a costa del resto), pero el patrón de fondo es independiente de la arquitectura.

Ni ensamblar variables ni ensamblar modelos cambia sustancialmente el panorama. La #link(<prueba-1>)[*Prueba de eliminación de variables*] confirma que ninguna variante de eliminación de variables mejora de forma clara y generalizada el conjunto de 8 modelos. La #link(<prueba-4>)[*prueba de ensamblado de predicciones*] confirma, de forma independiente, que combinar las predicciones de los 8 modelos, ya sea por `media`/`mediana`/`top-k`/`stacking convexo` o por un `meta-modelo` aprendido, solo supera al mejor modelo individual en _targets_ donde de partida no había señal predictiva real. 

En los _targets_ con señal fuerte, incluidos los dos prioritarios, el mejor modelo individual sigue ganando en la gran mayoría de los casos. La combinación de ambos hallazgos sugiere que el techo de rendimiento actual (~0.50/0.59 en los _targets_ prioritarios, ~0.08/0.10 en el agregado) está limitado más por la relación real entre las 34 variables autorizadas y los 21 _targets_ que por la elección de modelo, arquitectura o combinador.

La inestabilidad del MLP es el segundo hallazgo transversal más relevante. Las pruebas 2 y 3 muestran que los dos MLP tienen una desviación típica entre semillas varias veces superior a la de los modelos de árboles (hasta 0.052 en $R²$ global para MLP multisalida en el barrido de 491 semillas, frente a 0.003/0.005 en _Random Forest_/XGBoost multisalida). Esto refuerza la recomendación ya avanzada en la #link(<prueba-3>)[*Prueba de barrido de `random_state`*] de ampliar el ensamble de producción para los MLP más allá de las 5 redes actuales, o de reportar explícitamente un rango de rendimiento en vez de un valor puntual para estos dos modelos en las conclusiones finales.

#colbreak()

Por último, cabe destacar el determinismo de _Ridge_ frente a `random_state`, confirmado en las pruebas 2 y 3 y esperado por tratarse de una solución cerrada. XGBoost (variante _single-target_) mostró este mismo comportamiento en una primera ejecución de la @prueba-3, un hallazgo inesperado dado que su configuración de hiperparámetros sí incluye `subsample` y `colsample_bytree` por debajo de 1. Al repetir el experimento, la desviación típica de XGBoost _single-target_ resultó ser de 0.0043-0.0044, coherente con el resto de modelos basados en árboles, por lo que el ensamble de 5 semillas en producción sí aporta la diversidad esperada, no obstante, no se ha podido determinar con certeza la causa del determinismo observado en la primera ejecución, por lo que se documenta como una incidencia resuelta pero no explicada. 

En síntesis, los resultados respaldan la hipótesis de partida, los modelos basados en árboles igualan o superan al MLP en este _dataset_ reducido, pero matizan qué significa "el mejor modelo": depende de si se prioriza el rendimiento agregado sobre los 21 _targets_ (RF multisalida) o el rendimiento sobre los dos _targets_ prioritarios de lombrices (XGBoost multisalida). El factor que más limita el rendimiento global no es la elección de modelo, variables o método de combinación, sino la heterogeneidad intrínseca de los 21 _targets_.
