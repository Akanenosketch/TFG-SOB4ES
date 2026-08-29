= Planificación y seguimiento <planificacion-y-seguimiento>
== Planificación <planificacion>

La planificación de este trabajo se inició en mayo de 2026, momento en el que se formaliza el plan de desarrollo tal y como se indica en la #ref(<tab-8>):

#figure(
  align(center)[
    #table(
      columns: (4), 
      align: (horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header(
      table.cell(align: center)[*Período*],
      table.cell(align: center)[*Fase CRISP-ML(Q)*],
      table.cell(align: center)[*Actividades Planificadas*],
      table.cell(align: center)[*Hitos*]),  
    table.cell(align: center)[*Mayo*], 
      table.cell(align: left)[Comprensión y preparación inicial de los datos.], 
      table.cell(align: left )[Ingesta, limpieza, armonización e integración de los datos (ficheros y fuentes remotas).], 
      table.cell(align: left)[Datasets intermedios de los datos en ficheros como de los datos de solicitudes remotas.], 
    table.cell(align: center)[*1 jun - 15 jun*], 
      table.cell(align: left)[Cierre de la preparación de los datos.], 
      table.cell(align: left)[Correcciones de los notebooks de ingesta y procesamiento de datos. Búsquedas iniciales sobre modelos predictivos.], 
      table.cell(align: left)[Datasets de datos finales. Lista de posibles modelos predictivos a probar.], 
    table.cell(align: center)[*16 jun - 1 jul*], 
      table.cell(align: left)[Desarrollo y entrenamiento de modelos], 
      table.cell(align: left)[Preparación de los modelos para entrenarlos y experimentar con las diferentes variables posibles.], 
      table.cell(align: left)[Modelos entrenados. Documentación aparte sobre los diferentes modelos desarrollados.],
    table.cell(align: center)[*2 jul -15 ago*], 
      table.cell(align: left)[Evaluación de modelos y mejoras],
      table.cell(align: left)[Evaluar los modelos teniendo en cuenta las métricas resultantes de todas las pruebas. Mejorar los diferentes modelos en base a los resultados obtenidos en las pruebas.], 
      table.cell(align: left)[Informes sobre las pruebas realizadas en los diferentes modelos y sus correspondientes resultados. Modelos predictivos mejorados (múltiples iteraciones de ellos) en base a lo obtenido en las pruebas anteriores.],
    table.cell(align: center)[*16 ago - sept*], 
      table.cell(align: left)[Documentación final, revisión y entrega],
      table.cell(align: left)[Completar la limpieza y el refinamiento de la documentación final. Comprobar que todo lo elaborado funciona correctamente. Preparar el material de soporte necesario para la defensa.], 
      table.cell(align: left)[Documentación revisada y pulida. Materiales de apoyo para la defensa (i.e. presentación, documentación adicional). Todos los archivos requeridos para la entrega.],
    )],
     caption: [Planificación del TFG.],
     kind: table,
)<tab-8>

Dentro de la planificación no se detallan los elementos relacionados con la documentación, debido a que este es un elemento que se ha planificado realizar a lo largo de toda la duración de este trabajo de fin de grado. Esto permite tener todos los datos y progresos realizados ya redactados para facilitar las actividades de pulido y mejora de la documentación de la memoria del TFG. 

También, como se puede ver en la planificación (véase #ref(<tab-8>)), la aplicación de CRISP-ML(Q) se ha adaptado a las necesidades de este trabajo, motivo por el cual los nombres de las fases no coinciden completamente con lo indicado en la correspondiente documentación sobre la metodología de desarrollo.     

#colbreak()

En el siguiente Diagrama de Gantt, podemos ver de forma más gráfica la planificación que se ha realizado para la elaboración de este trabajo.         

#figure(
  image("../media/diagrama-gantt.png"),
  caption: [Diagrama de Gantt con la planificación del TFG.],
)<fig-3>

Además del diagrama de Gantt mostrado en la #ref(<fig-3>), en la #ref(<tab-9>) se muestra la distribución de horas y porcentaje de esfuerzo estimado para cada una de las correspondientes fases de desarrollo de este trabajo.

#figure(
  align(center)[
    #table(
      columns: (3), 
      align: (horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },        
    table.header(
      table.cell(align: center)[*Fase CRISP-ML(Q)*],
      table.cell(align: center)[*Duración estimada \ (en horas)*],
      table.cell(align: center)[*Porcentaje de esfuerzo \ estimado (%)*],),  
    table.cell(align: left)[*Comprensión y preparación inicial de los datos*], 
      table.cell(align: center)[50], 
      table.cell(align: center)[18.3%], 
    table.cell(align: left)[*Cierre de la preparación de los datos*], 
      table.cell(align: center)[40], 
      table.cell(align: center)[13.3%], 
    table.cell(align: left)[*Modelado de los modelos*], 
      table.cell(align: center)[70], 
      table.cell(align: center)[23.3%], 
    table.cell(align: left)[*Evaluación de modelos y mejoras*], 
      table.cell(align: center)[110], 
      table.cell(align: center)[36.7%], 
    table.cell(align: left)[*Documentación final, revisión y entrega*], 
      table.cell(align: center)[30], 
      table.cell(align: center)[10%], 
    table.cell(align: left)[*Total*], 
      table.cell(align: center)[300], 
      table.cell(align: center)[100%],
    )],
     caption: [Distribución de horas y porcentajes de esfuerzo estimados.],
     kind: table,
)<tab-9>


== Puntos críticos <puntos-criticos>

Dentro de un proyecto, especialmente dentro del ciclo de vida del mismo, los *puntos críticos* se definen como aquellos componentes, fases o tareas, que debido a la complejidad técnica o al desconocimiento inicial al empezar el proyecto, presentan un riesgo más elevado de poder provocar desviaciones en el cronograma establecido inicialmente. También pueden afectar en mayor o menor medida a la calidad del producto final.

Dentro del marco de este TFG, los principales puntos críticos se concentran en el desarrollo de modelos y la evaluación formal de los mismos. A continuación, se describirán los diferentes puntos críticos y sus riesgos de forma más detallada y las estrategias de mitigación aplicadas.

#colbreak()

=== Desarrollo y parametrización de los modelos predictivos

El desarrollo y parametrización de los modelos predictivos se considera como un punto crítico debido a que el rendimiento final del sistema va a depender de las decisiones tomadas al inicio del desarrollo. Entre esas decisiones se destacan las siguientes:
+ Número y tipo de modelos a entrenar y desarrollar.
+ Selección del espacio y  tiempo de búsqueda/cómputo disponible.

La selección de modelos debe de contar con el hecho de que se dispone de un set reducido de datos. Si se seleccionan modelos, los cuales no operan bien con pocos datos, entonces como consecuencia los rendimientos van a ser mucho peores de lo esperable. 

Además, aún escogiendo modelos capaces de operar con pocos datos, siempre va a haber cierta cantidad de modelos que presenten sobreajuste ya por defecto. Esto mismo se podrá ver a lo largo del desarrollo de la memoria y en el *Anexo III*.

Un ajuste deficiente de hiperparámetros o una mala elección del espacio de búsqueda inicial puede provocar un sobreajuste mucho mayor al ya predispuesto por la falta de datos.

=== Evaluación de modelos y control de calidad (QA)

La evaluación formal de los modelos es muy importante, porque de ella depende la selección final de los algoritmos a emplear. Un error en esta fase podría invalidar todas las conclusiones de este trabajo.

Además, la calidad de los datos de entrada, condiciona directamente a la fiabilidad de cualquier métrica obtenida, por lo que un fallo no detectado en las capas inferiores del flujo de trabajo puede propagarse silenciosamente hasta la evaluación final.

=== Estrategias de mitigación

Para reducir, en la medida de lo posible, los riesgos provenientes de los puntos anteriores se han aplicado las siguientes medidas de mitigación:
- Uso sistemático de validación cruzada repetida en todos los modelos desarrollados, en lugar de hacer uso de una única partición de validación, para obtener estimaciones más robustas y precisas sobre el rendimiento real.
- Separación estricta del _dataset_ original en tres subconjuntos (entrenamiento, validación y evaluación) desde la fase inicial de modelos de modelos. Esto permite evitar que el set de evaluación se use en ningún momento en otros procesos para los cuales no fue creado, como puede ser la búsqueda de hiperparámetros.
- Registro de los campos sin datos de los datasets originales mediante un archivo de banderas de imputación. Esto permite tener un mayor conocimiento y control sobre los datos que se poseen o que siguen carentes en todo momento, además, permite la determinación sobre qué datos son mediciones reales y cuáles son estimaciones. 
- Revisiones periódicas del proceso de desarrollo en forma de reuniones semanales (véase #link(<seguimiento>)[*Seguimiento*]), permitiendo así detectar errores o desviaciones en el desarrollo y parametrización de los modelos antes de que afecten a fases posteriores.
- Realización de pruebas complementarias para la simplificación y mejor selección de los modelos finales (véase #link(<pruebas-llevadas-a-cabo>)[*Anexo V*]). Dichas pruebas también sirven para medir la robustez actual de los modelos.

#colbreak()

== Seguimiento <seguimiento>

El seguimiento del progreso del presente TFG se realiza mediante la celebración de reuniones periódicas, generalmente semanales, entre el alumnado, el tutor y el co-tutor del proyecto. Estas reuniones constituyen el mecanismo principal de control y coordinación a lo largo de todo el desarrollo del trabajo.

Estas reuniones tienen los siguientes objetivos:

+ *Comunicación de avances:* Exponer el trabajo realizado durante el período transcurrido desde la anterior reunión, incluyendo los resultados obtenidos así como las dificultades o problemas encontrados.

+ *Resolución de dudas:* Plantear y aclarar todas las cuestiones técnicas, metodológicas o de alcance que hayan surgido durante el desarrollo de las tareas.

+ *Definición de próximos pasos:* Establecer y acordar las tareas a abordar durante el siguiente intervalo temporal, ajustando la planificación en función del estado real del proyecto.

Este esquema de seguimiento continuo permite mantener una supervisión constante sobre la evolución del proyecto, facilitando la detección temprana de desviaciones respecto a la planificación inicial y posibilitando la adopción de medidas correctoras cuando resulta necesario. Asimismo, la periodicidad semanal proporciona un marco de trabajo estructurado que favorece la organización del esfuerzo en tiempos cortos y bien definidos, contribuyendo a un desarrollo incremental y controlado del trabajo.

En casos en los que las circunstancias del proyecto lo requiera, por ejemplo, antes hitos relevantes o la necesidad de abordar decisiones de mayor importancia, la frecuencia de las reuniones puede ajustarse, intensificando o espaciando su frecuencia en función de las necesidades puntuales del desarrollo.

== Justificación de desviaciones <justificacion-de-desviaciones>

A fecha de 25/08/2026, no existen diferencias con la planificación creada.