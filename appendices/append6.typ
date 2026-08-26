== Distribución de ramas y notebooks <dist-ramas-y-notebooks>

Como se indica en #link(<lenguaje-de-programacion-control-de-versiones-y-librerias>
)[*Lenguajes de programación, control de versiones y librerías*], este TFG ha empleado git como sistema de control de versiones, alojado en un repositorio de GitHub.

Para proporcionar una mayor visibilidad e interpretabilidad al trabajo realizado, se ha decidido aplicar las siguientes medidas:
+ Alojar cada prueba/modificación realizada dentro de ramas independientes para tener una mejor forma de comparar los resultados entre varias ramas 
+ Establecer una nomenclatura común para las ramas que formen parte de una misma prueba
+ Todas las ramas relacionadas con los modelos irán precedidas por el prefijo model-prep
+ Ramas auxiliares o con funciones específicas deberán seguir una nomenclatura similar.
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
      table.cell(align: center)[*Preparación de \ datos*], 
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
      table.cell(align: center, rowspan: 2)[*Sensibilidad de \ random_state*], 
        table.cell(align: center, rowspan: 2)[2],
        table.cell(align: left)[model-prep-rs],
        table.cell(align: left)[model-prep-rs-1],
      table.cell(align: center, rowspan: 2)[*Barrido de \ random_state*], 
        table.cell(align: center, rowspan: 2)[2],
        table.cell(align: left)[model-prep-rs-group], 
        table.cell(align: left)[model-prep-rs-group-1], 
      table.cell(align: center, rowspan: 2)[*Ensamblado de \ predicciones*], 
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

Además de la distribución de todas las ramas, en la siguiente tabla se muestran todas las ramas con su correspondiente objetivo, explicado de una forma más concisa. Como se puede observar, la rama master no figura en la tabla debido a que no tiene un objetivo funcional, sino su único objetivo es mostrar de un vistazo los elementos principales de este TFG.

Esta distribución de ramas, a lo largo de la realización de todas las pruebas, ha permitido lo siguiente:
- Iterar sobre configuraciones experimentales concretas de forma aislada sin que esta afectara, combinado con la estrategia empleada en la elaboración de los modelos, al resto de modelos ni a los resultados de los modelos base o los modelos del resto de las pruebas realizadas.
- Facilitar la comparación en cualquier momento el código y los resultados de dos o varias ramas distintas, independientemente de que dicha revisión se amnaual o automatizada.

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