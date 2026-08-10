= Vías de trabajo futuro <vias-de-trabajo-futuro>

A partir del trabajo realizado, se han identificado las siguientes líneas de continuación:
+ *Ampliar la cobertura geográfica y temporal del conjunto de datos* mediante la incorporación de nuevas campañas de muestreo dentro del proyecto SOB4ES a medida que estén disponibles, para reducir la dependencia del modelo de un conjunto de datos reducido.
+ *Extender la comparación a otros grupos de biodiversidad del suelo* más allá de los ya integrados en los diferentes modelos creados para este trabajo, replicando el mismo pipeline y metodología.
+ *Explorar posibles arquitecturas de aprendizaje profundo adicionales* como, por ejemplo, los modelos basados en embeddings de imágenes satelitales descritos previamente en Antecedentes y contexto,  una vez que se dispongan de un mayor volumen de datos que permita mitigar de forma más eficiente el riesgo de sobreajuste ya existente a causa de la falta de datos.
+ *Automatizar el reentrenamiento periódico de los modelos*, cerrando de esta forma la fase de “Monitoreo y mantenimiento” de CRISP-ML(Q), la cual se encuentra descrita en @resumen-de-la-solucion-propuesta, de forma que el sistema pueda incorporar nuevas mediciones sin tener que repetir todo el proceso de forma manual.
+ *Exponer los modelos finales a través de un servicio API* que permita obtener una predicción de biodiversidad para un nuevo punto geográfico a partir de sus variables ambientales, facilitando así el uso por parte de terceros ajenos al desarrollo de este TFG.
