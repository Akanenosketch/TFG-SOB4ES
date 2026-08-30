= Conclusiones <conclusiones>

A partir de la realización del siguiente trabajo se obtuvieron las siguientes conclusiones:

- La combinación de los datos _in situ_ del proyecto SOB4ES con fuentes remotas de menor resolución ha resultado viable y de utilidad dentro del pipeline desarrollado, en línea con lo señalado en los #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*] sobre la ventaja de los datos _in situ_ de alta calidad frente a los derivados exclusivamente de fuentes remotas.

- Tras realizar las comparaciones entre los diferentes modelos, tanto a partir de los modelos base como los modelos resultantes de las pruebas 2 y 3 (véase #link(<pruebas-llevadas-a-cabo>)[*Pruebas llevadas a cabo*]), tras ejecutar los _notebooks_ encargados de las comparaciones (`comparador_modelos` y `comparador_clasificador`), *XGBoost multisalida* obtuvo a nivel general el mejor resultado de todos, siendo _*Random Forest*_ en su variante multisalida la segunda mejor opción global tanto a nivel de regresión como de clasificación. 
  
  Esto prueba una vez más la *ventaja de los modelos basados en árboles de decisión sobre los modelos basados en redes neuronales* cuando se trata de entrenar y trabajar sobre un set de datos reducido.

- La Prueba 3 (véase #link(<prueba-3>)[*Prueba de barrido de `random_state` (Anexo V)*]), consistente en un barrido de 101 semillas distintas (`random_state` de 0 a 100) sobre los 8 modelos y una segunda iteración de 491 semillas, descartó que la superioridad de *XGBoost multisalida* observada con `random_state=42` fuese un artefacto de una única ejecución: para los dos targets prioritarios del proyecto (`earthworm_shannon_z`, `earthworm_richness_z`), este modelo se mantuvo en primera posición en el 100% de las 101 semillas evaluadas, con una desviación típica del $R^2$ muy baja. 
  
  Al desglosar el barrido por los 21 targets, sin embargo, no se encontró un modelo "ganador universal": el modelo más prominente varía según el grupo taxonómico, por lo que se concluyó que la estrategia más adecuada es recomendar un modelo distinto según el grupo de targets en lugar de imponer un único modelo para los 21, si bien para los dos targets prioritarios la elección de *XGBoost multisalida* queda respaldada de forma robusta por este barrido.

- En cuanto a la *eliminación de variables* (véase #link(<prueba-1>)[*Prueba de eliminación de vairables (Anexo V)*]), las pruebas realizadas retirando entre 1 y 3 predictoras del conjunto original de 34 variables autorizadas mostraron variaciones de $R^2$ global muy reducidas para todos los modelos, generalmente dentro de un margen de $plus.minus$0.01-0.02, sin que la eliminación de ninguna combinación concreta de variables provocase una caída brusca de rendimiento. 

  Esto indica que el conjunto de predictoras empleado (edáficas, de teledetección y topográficas) no depende de forma crítica de ninguna variable aislada, y que el pipeline es razonablemente robusto frente a una reducción moderada del espacio de variables. 
  
  En consecuencia, no se encontró justificación empírica para reducir de forma permanente el conjunto de 34 variables, ya que ninguna combinación de eliminación probada supuso una mejora consistente frente a la configuración base, y sí se detectaron pequeños empeoramientos puntuales en varios modelos y targets.

- La Prueba 4.1 (véase #link(<prueba-4>)[*Prueba de ensamblado de predicciones (Anexo V)*]), en la que se evaluaron cinco formas de combinar las predicciones de los 8 modelos base (`media simple`, `media ponderada por $R^2$`, `top-k`, `mediana` y `stacking convexo`), no encontró ninguna combinación capaz de superar de forma consistente al mejor modelo individual por target: de los 21 targets, alguna combinación solo "ganó" en 4 (19%), y en los cuatro casos se trataba de targets sin señal predictiva real, por lo que más que una mejora suponía un empate entre modelos igualmente poco útiles. 

  Para los dos targets prioritarios, el mejor modelo individual (*RegressorChain* y *XGBoost multisalida*, respectivamente) superó a la mejor combinación disponible en ambos casos. Se observó además que el `stacking convexo` tendía a concentrar la práctica totalidad del peso en un único modelo base (casi siempre *XGBoost multisalida*), por lo que en la práctica seleccionaba un modelo en vez de combinarlos.

#colbreak()

- La Prueba 4.2 (véase (véase #link(<prueba-4>)[*Prueba de ensamblado de predicciones (Anexo V)*]) repitió el experimento anterior sustituyendo la combinación simple por un stacking con `meta-modelo` (`Ridge`, `Lasso`, `ElasticNet`, `regresión lineal` y `_*Random Forest*_`, entrenados sobre las predicciones de los 8 modelos base). 
  
  Esta variante mejoró la tasa de victorias frente al mejor individual (9 de 21 targets, 43%), pero de los dos targets prioritarios solo `earthworm_richness_z` se benefició, con una mejora modesta (+0.014 de $R^2$ con un `meta-modelo` Ridge). 
  
  Además, varias de las mejoras más llamativas, obtenidas con _*Random Forest*_ como `meta-modelo` en targets sin señal predictiva previa, mostraron un patrón compatible con sobreajuste, dado el reducido tamaño de la partición de calibración utilizada. Por este motivo, se concluye que ni el ensamblado simple ni el stacking con `meta-modelo` aportan una mejora suficientemente robusta y validada como para sustituir al mejor modelo individual por target en la versión actual del pipeline.

A nivel personal, la realización de este TFG me ha proporcionado muchos conocimientos de los que no disponía tras realizar la carrera, como también ha reforzado conocimientos que sí fueron impartidos durante la misma. Asimismo, este trabajo despertó en mí un notable interés por profundizar en el funcionamiento interno de la inteligencia artificial, así como por continuar aprendiendo e investigando en este campo.

En particular, al haber estado "familiarizada" hasta ahora casi exclusivamente con la IA generativa, hacia la cual aún hoy en día sigo presentando una opinión neutral respecto a su uso en general, este TFG me ha permitido descubrir y comprender una nueva perspectiva distinta del campo, centrada en el aprendizaje automático aplicado a problemas de diferentes tipos sobre datos estructurados. 

Este nuevo punto de vista ha ampliado de forma considerable mi comprensión de la disciplina y ha reforzado mi motivación para seguir formándome en ella.