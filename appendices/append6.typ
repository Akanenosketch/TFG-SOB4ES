== Distribución de ramas y notebooks <dist-ramas-y-notebooks>

Como se indica en #link(<lenguaje-de-programacion-control-de-versiones-y-librerias>
)[*Lenguajes de programación, control de versiones y librerías*], este TFG ha empleado git como sistema de control de versiones, alojado en un repositorio de GitHub#sub([@githubTFGRepo]).

A diferencia de un flujo de trabajo con una única rama principal, en el que cada modelo y cada prueba adicionale se acumularían de forma secuencial sobre el mimso historial, se optó por un esquema de ramas independientes por prueba. Esto responde al cáracter exploratorio de este TFG.

A lo largo del trabajo se han entrenado múltiples variantes de un mismo modelo, en específico las variantes multisalida (véase @xgb-multi-model, @xgboost-multisalida para la variante de XGBoost y @rf-multi-model, @random-forest-multisalida para la variante de Random Forest) y las variantes elaboradas para las pruebas de #link(<prueba-1>)[*Eliminación de variables*], #link(<prueba-1>)[*Sensibilidad de random_state*] y #link(<prueba-3>)[*Barrido de random_states*]. Esto ha sido necesario para poder comparas los resultados de las diferentes variables entre sí, independientemente de que se haya hecho de forma manual o automatizada, sin que los cambios realizados sobrescribiesen los resultados de las demás.

Para proporcionar una mayor visibilidad e interpretabilidad al trabajo realizado, se ha decidido aplicar las siguientes medidas:
+ Alojar cada prueba/modificación realizada dentro de ramas independientes para tener una mejor forma de comparar los resultados entre varias ramas. 
+ Establecer una nomenclatura común para las ramas que formen parte de una misma prueba, de forma que el propio nombre de la rama sea autoexplicativo sobre los orígenes de su prueba o objetivo.
+ Todas las ramas relacionadas con los modelos irán precedidas por el prefijo `model-prep`.
+ Ramas auxiliares o con funciones específicas deberán seguir una nomenclatura similar, describiendo brevemente su propósito (por ejemplo, `documentation` y `data-prep`).

Esta nomenclatura jerárquica permite, además, identificar de un vistazo qué ramas están relacionadas entre sí, es decir todas las variantes o iteraciones de una prueba comparten el mismo prefijo (por ejemplo, `model-prep-var`) y se diferencian haciendo uso de un sufijo numérico que indica la iteración o número de variante de cada pueba.
A partir de estas medidas y una vez realizadas todas las pruebas, las cuales se pueden ver dentro del #link(<pruebas-llevadas-a-cabo>)[*Anexo V*], el repositorio en su estado final presenta la siguiente distribución de ramas en base al objetivo o funcionalidad de las misma, la cual se puede ver en la siguiente tabla:

  #figure(
    align(center)[
      #table(
        columns: (33%,33%,33%), 
        align: (horizon),      
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Objetivo/Prueba*], [*Número de ramas*], [*Nombre de las ramas*]),  
      table.cell(align: center)[*Documentación*], 
        table.cell(align: center)[1],
        table.cell(align: left)[documentation], 
      table.cell(align: center)[*Preparación de datos*], 
        table.cell(align: center)[1],
        table.cell(align: left)[data-prep], 
      table.cell(align: center, rowspan: 8)[*Eliminación de \ variables*], 
        table.cell(align: center, rowspan: 8)[8],
        table.cell(align: left)[model-prep-var], 
        table.cell(align: left)[model-prep-var-1],
        table.cell(align: left)[model-prep-var-2], 
        table.cell(align: left)[model-prep-var-3],
        table.cell(align: left)[model-prep-var-1-2], 
        table.cell(align: left)[model-prep-var-1-3],
        table.cell(align: left)[model-prep-var-2-3], 
        table.cell(align: left)[model-prep-var-1-2-3],
      table.cell(align: center, rowspan: 2)[*Sensibilidad de random_state*], 
        table.cell(align: center, rowspan: 2)[2],
        table.cell(align: left)[model-prep-rs],
        table.cell(align: left)[model-prep-rs-1],
      table.cell(align: center, rowspan: 2)[*Barrido de random_state*], 
        table.cell(align: center, rowspan: 2)[2],
        table.cell(align: left)[model-prep-rs-group], 
        table.cell(align: left)[model-prep-rs-group-1], 
      table.cell(align: center, rowspan: 2)[*Ensamblado de  predicciones*], 
        table.cell(align: center, rowspan: 2)[2],
        table.cell(align: left)[model-prep-mixin], 
        table.cell(align: left)[model-prep-mixin-1], 
      )],
      caption: [Distribución de ramas por objetivo/prueba],
      kind: table,
  )

#colbreak()

  Además de la tabla de distribución de ramas, en el siguiente diagrama se puede ver de una forma más gráfica la distribución de las ramas de todo el repositorio.

  #figure(
    align(center)[
      #image("../media/diagrama ramas.drawio.png", height: 30%)
    ],
    caption: [Diagrama de distribución de ramas],
    kind: image
  )

Además de la distribución de todas las ramas, en la siguiente tabla se muestran todas las ramas con su correspondiente objetivo, explicado de una forma más concisa. Como se puede observar, la rama `master` no figura en la tabla debido a que no tiene un objetivo funcional, sino su único objetivo es mostrar de un vistazo los elementos principales de este TFG.

Esta distribución de ramas, a lo largo de la realización de todas las pruebas, ha permitido lo siguiente:
- Iterar sobre configuraciones experimentales concretas de forma aislada sin que esta afectara, combinado con la estrategia empleada en la elaboración de los modelos, al resto de modelos ni a los resultados de los modelos base o los modelos del resto de las pruebas realizadas.
- Facilitar la comparación en cualquier momento el código y los resultados de dos o varias ramas distintas, independientemente de que dicha revisión sea manual o automatizada.
- Preservar un historial completo y trabajble de cada decisión experimental: si una prueba concreta produce resultados inesperadosm es posible volver a la rama correspondiente y revisar exactamente qué parámetros o variables se empleadon en ella, sin depender de la memorial del investigador nu de anotaciones externar al propio repositorio.
- Facilitar la reproducibilidad de cualquier resultado concreto de la memoria: cada figura, cada tabla o métrica reportada puede rastrearse hasta la rama y el notebook exactos que la generaron.

#colbreak()

  #figure(
    align(center)[
      #table(
        columns: (30%, 70%), 
        align: (center + horizon, left + horizon),      
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Objetivo/Prueba*], 
        table.cell(align: center)[*Número de ramas*]),  
      table.cell(align: center)[*documentation*], 
        table.cell(align: center)[Rama en la que se encuentra toda la documentación realizada para este TFG, en formato Typst.],
      table.cell(align: center)[*data-prep*], 
        table.cell(align: center)[Rama en la que se encuentra todo lo relacionado a las primeras dos capas de la arquitectura (ingesta y procesamiento de los datos).],
      table.cell()[*model-prep*], 
        table.cell()[Rama en la que se encuentran las primeras versiones de los modelos desarrollados, a lo largo de las iteraciones se han ido realizando cambios, algunos de dichos cambios se han pasado a los modelos de esta rama.],
      table.cell()[*model-prep-var*], 
        table.cell()[Rama en la que se hacen las pruebas iniciales para la prueba de eliminación de variables.],
      table.cell()[*model-prep-var-1*], 
        table.cell()[Rama en la que se elimina la variable `cu_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-2*], 
        table.cell()[Rama en la que se elimina la variable `ni_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-3*], 
        table.cell()[Rama en la que se elimina la variable `mo_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-1-2*], 
        table.cell()[Rama en la que se eliminan las variables `cu_z` y `ni_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-1-3*], 
        table.cell()[Rama en la que se eliminan las variables `cu_z` y `mo_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-2-3*], 
        table.cell()[Rama en la que se eliminan las variables `ni_z` y `mo_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-var-1-2-3*], 
        table.cell()[Rama en la que se eliminan las variables `cu_z`, `ni_z` y `mo_z` para comprobar cómo se comportan los modelos entrenados.],
      table.cell()[*model-prep-rs*], 
        table.cell()[Rama en la que se hace la primera iteración de la prueba de sensibilidad de random_state. El valor de random_state de esta iteración es de 27.],
      table.cell()[*model-prep-rs-1*], 
        table.cell()[Rama en la que se hace la segunda iteración de la prueba de sensibilidad de random_state. El valor de random_state de esta iteración es de 128.],
      table.cell()[*model-prep-rs-group*], 
        table.cell()[Rama en la que se hace la primera iteración de la prueba de barrido de random_state. El rango de valores de esta iteración de es 0 a 100 (inclusive). ],
      table.cell()[*model-prep-rs-group-1*], 
        table.cell()[Rama en la que se hace la segunda iteración de la prueba de barrido de random_state. El rango de valores de esta iteración de es 0 a 100 (inclusive).],
      table.cell()[*model-prep-mixin*], 
        table.cell()[Rama en la que se hace la primera iteración de la prueba de ensamblado de predicciones, en esta se prueba con 8 de los 21 targets.],
      table.cell()[*model-prep-mixin-1*], 
        table.cell()[Rama en la que se hace la primera iteración de la prueba de ensamblado de predicciones, en esta se prueba con todos los targets.],
      )],
      caption: [Resumen de las ramas creadas.],
      kind: table,
  )

#colbreak()

=== Notebooks empleados <notebooks-empleados>

Además de la distribución en ramas, cada modelo desarrollados, como también cada prueba adicional realizada, se corresponde con uno o varios notebooks de Jupyter independientes. Esta separación permite ejecutar, depurar y reentrenar cada modelo o prueba de forma aislada sin afectar al resto y facilita de forma aislada sin afecta al resto, y facilita además la ejecución automatizda mediante los scripts auxiliares descritos en #link(<elementos-auxiliares>)[*Anexo IV*].

Todos los notebooks de modelado comparten una misma estructura interna, dividida en las siguientes celdas o bloques, con el objetivo de mantener una experiencia de desarrollo homogénea entre modelos y facilitar así tanto la comparación entre ellos como la incorporación de nuevos modelos en un futuro:

- *Carga de datos y configuración:* lectura de `train.csv`, `test.csv` y `eval.csv`, junto con la carga del `scaler.pkl` correspondiente y la definición de las semillas (`random_state`) y demás parámetros de configuración del notebook.
- *Búsqueda de hiperparámetros:* ejecución de `RandomizedSearchCV` sobre el conjunto de entrenamiento y validación cruzada, con el grid de parámetros específico del modelo.
- *Validación cruzada del modelo final:* ejecución de `cross_validate` con `RepeatedKFold` sobre el mejor conjunto de hiperparámetros encontrado, para comprobar la estabilidad del modelo antes de entrenarlo de forma definitiva.
-* Entrenamiento final:* ajuste del modelo sobre la totalidad del conjunto de entrenamiento con los hiperparámetros seleccionados.
- *Evaluación preliminar:* cálculo de las métricas de regresión (R², RMSE, MAE) sobre el conjunto de evaluación, junto con una primera aproximación a la importancia de variables.
- *Persistencia:* guardado del modelo entrenado en un archivo `.pkl` mediante `joblib`, para su uso posterior en la Capa de evaluación de modelos.

Sobre esta estructura común, cada notebook incorpora las particularidades propias de su modelo (por ejemplo, las celdas de detección de GPU en los notebooks de XGBoost, o la definición de la arquitectura de capas en los notebooks de MLP). 

La siguiente tabla resume los notebooks principales empleados a lo largo de este TFG:

#figure( 
  align(center)[ 
    #table( 
      columns: (30%, 70%), 
      align: (center + horizon, left + horizon), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header( 
      table.cell(align: center)[*Notebook*], 
      table.cell(align: center)[*Responsabilidad*]), 
    table.cell()[*reg_model*], 
      table.cell()[Entrenamiento del modelo de Regresión Ridge. \ Al tratarse del modelo base con menor coste computacional del proyecto, se emplea además como referencia mínima de rendimiento (baseline) frente a la que se comparan el resto de modelos.], 
    table.cell()[*rf_model*], 
      table.cell()[Entrenamiento del modelo Random Forest base (salida simple): un modelo independiente por target. \ Incluye el cálculo de la importancia de variables por impureza media (MDI) y por permutación, ambas empleadas posteriormente como complemento a SHAP.], 
    table.cell()[*rf_multisalida*], 
      table.cell()[Entrenamiento del modelo Random Forest con salida múltiple: un mismo conjunto de árboles predice simultáneamente los 21 targets. \ Reutiliza la mayor parte de la estructura de rf_model, adaptando la preparación de los datos para que y sea una matriz en vez de un vector.], 
    table.cell()[*regressorchain*], 
      table.cell()[Entrenamiento del modelo Random Forest pero envuelto en RegressorChain para que devuelva cadenas de predicciones. \ Implementa la estrategia de Ensembles of Chains (ECC), entrenando varias cadenas con orden aleatorio de targets y semilla distinta por iteración, y promediando sus predicciones finales.], 
    table.cell()[*xgboost_model*], 
      table.cell()[Entrenamiento del modelo XGBoost base (salida simple). \ Incorpora una celda de detección de GPU/CUDA para configurar automáticamente los parámetros de dispositivo según el equipo en el que se ejecute el notebook.], 
    table.cell()[*xgb_multisalida*], 
      table.cell()[Entrenamiento del modelo XGBoost con múltiples salidas y con soporte de predicción multi-target, empleando el parámetro `multi_strategy="multi_output_tree"` para que las divisiones del árbol capturen relaciones compartidas entre targets. \ Comparte la misma lógica de detección de GPU que xgboost_model.], 
    table.cell()[*mlp_multisalida*], 
      table.cell()[Entrenamiento de una red neuronal con salida múltiple, con la función de pérdida MSE estándar calculada conjuntamente sobre los 21 targets. \ Implementado sobre PyTorch, incluye la definición de la arquitectura de capas, el bucle de entrenamiento con el optimizador Adam y las celdas de seguimiento de la curva de pérdida por época.], 
    table.cell()[*mlp_custom_loss*], 
     table.cell()[Entrenamiento de una red neuronal con pérdida modificable, que combina el MSE estándar con un término configurable que penaliza la divergencia entre la matriz de correlación de las predicciones y la matriz de correlación real de los targets del lote. \ Reutiliza la arquitectura definida en mlp_multisalida, sustituyendo únicamente la función de pérdida empleada durante el entrenamiento.], )], 
    caption: [Notebooks de entrenamiento de modelos.], 
    kind: table, )

Todos estos notebooks comparten una misma estructura interna (carga de datos y configuración, búsqueda de hiperparámetros, validación cruzada del modelo final, entrenamiento final, evaluación preliminar y persistencia del modelo en .pkl mediante joblib), con el objetivo de mantener una experiencia de desarrollo homogénea entre modelos y facilitar así tanto la comparación entre ellos como la incorporación de nuevos modelos en un futuro. Sobre esta estructura común, cada notebook incorpora las particularidades propias de su modelo, como las ya mencionadas en la tabla anterior.

==== Comparación de resultados

Una vez entrenados todos los modelos anteriores, los siguientes notebooks se encargan de cargarlos (o los datos exportados por los mismos) y compararlos entre sí, cada uno desde uno de los dos puntos de vista descritos en la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*]:

#figure( align(center)[ 
  #table( 
    columns: (30%, 70%), 
    align: (center + horizon, left + horizon), 
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
  table.header( 
    table.cell(align: center)[*Notebook*], 
    table.cell(align: center)[*Responsabilidad*]), 
  table.cell()[*comparador_modelos*], 
    table.cell()[Carga de todos los modelos entrenados (`.pkl`) y generación de métricas comparativas desde el punto de vista numérico, las cuales se han descrito ya en la Capa de evaluación de modelos.], 
  table.cell()[*comparador_clasificación*], 
    table.cell()[Carga de todos los modelos entrenados (`.pkl`) y generación de métricas comparativas desde el punto de vista ordinal (clasificación), las cuales se han descrito ya en la Capa de evaluación de modelos.], 
  table.cell()[*comparador_variables*], 
    table.cell()[Carga todos los archivos de variables menos relevantes (.csv) y genera a partir de los datos el ranking de variables a eliminar para la #link(<prueba-1>)[*Prueba de eliminación de variables*]]
  )], 
  caption: [Notebooks de comparación de resultados.], 
  kind: table 
)

#colbreak()

==== Pruebas de ensamblado

Vinculados a las ramas *`model-prep-mixin`* y *`model-prep-mixin-1`* (véase la tabla de distribución de ramas anterior), estos dos notebooks exploran si combinar las predicciones de varios modelos base mejora el resultado obtenido por cualquiera de ellos por separado:

#figure( 
  align(center)[ 
    #table( 
      columns: (30%, 70%), 
      align: (center + horizon, left + horizon), 
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header( 
      table.cell(align: center)[*Notebook*], 
      table.cell(align: center)[*Responsabilidad*]), 
    table.cell()[*prueba_ensamblado\_ \ con_modelos*], 
      table.cell()[Carga de todos los modelos entrenados previamente y entrena un conjunto de meta-modelos adicionales con las siguientes características: las entradas del meta-modelo son las salidas de los modelos base; el meta-modelo se entrena con una parte de los valores de eval.csv; y se comprueba si la diferencia entre las predicciones de los meta-modelos y el valor real es menor que la diferencia obtenida con los modelos independientes.], 
    table.cell()[*prueba_ensamblado*], 
      table.cell()[Carga de todos los modelos entrenados y realiza comparaciones a partir de las siguientes condiciones: comprueba si la diferencia de la predicción combinada con el valor real es menor que la diferencia de las predicciones individuales con el valor real. Dichas comprobaciones se hacen de forma independiente con cada uno de los métodos de combinación empleados.], 
    )], 
      caption: [Notebooks de pruebas de ensamblado.], 
      kind: table, 
    )

La diferencia entre ambos enfoques es la siguiente: 
- *prueba_ensamblado_con_modelos* aprende una combinación mediante un meta-modelo entrenado sobre parte del conjunto de evaluación (stacking), 
- *prueba_ensamblado* prueba distintos métodos de combinación fijos y predefinidos (por ejemplo, un promedio simple o ponderado de las predicciones), sin entrenar ningún modelo adicional sobre ellas.

Los detalles sobre esta prueba y sus resultados se pueden ver en el #link(<prueba-4>)[*Anexo IV*].

Los notebooks correspondientes al resto de las pruebas adicionales (eliminación de variables, sensibilidad y barrido de random_state) reutilizan la misma estructura y el mismo código base que los notebooks de entrenamiento de modelos descritos anteriormente, variando únicamente los parámetros o las variables de entrada propias de cada prueba (por ejemplo, eliminando cu_z, ni_z y/o mo_z del conjunto de variables predictoras, o cambiando el valor de random_state). Esta reutilización deliberada del mismo código, en vez de crear notebooks nuevos y no relacionados por cada prueba, es la que permite que las diferencias observadas entre ramas se deban únicamente al cambio introducido en cada prueba, y no a diferencias accidentales en la implementación.

Cada notebook, una vez ejecutado, deja constancia de sus resultados de dos formas complementarias: por un lado, las propias celdas de salida del notebook quedan guardadas junto con el código tras la ejecución (véase el script de automatización del #link(<elementos-auxiliares>)[*Anexo IV*], que realiza esta ejecución modificando los propios notebooks). 

Por otro, los archivos `.pkl` de los modelos entrenados y los archivos de resultados exportados por los notebooks de comparación quedan disponibles para su análisis posterior sin necesidad de reejecutar ningún notebook.