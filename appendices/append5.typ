== Pruebas llevadas a cabo (Anexo V) <pruebas-llevadas-a-cabo>

En este anexo se indican las pruebas adicionales realizadas y los resultados que estas mismas han mostrado.
Todas estas pruebas, junto con sus iteraciones o fases se han realizado en ramas independientes, por lo tanto los resultados se podrán comparar de forma independiente dentro del repositorio de GitHub. La distribución de las ramas se puede ver en el #link(<dist-ramas-y-notebooks>)[*Anexo VI*]. 

Cabe tener en cuenta que el ajuste de hiperparámetros de cada modelo no se contabiliza como una prueba independiente al escogerse siempre la combinación que presente el mayor $R²$ de validación, no es un experimento con un resultado abierto del que se pueda llevar a una discusión, sino un paso rutinario de optimización.

=== Prueba de eliminación de variables <prueba-1>

El objetivo de esta primera prueba es evaluar si todas las variables escogidas, un total de 34 dentro de `FEATURES_AUTORIZADAS`, aportan capacidad predictiva real o si existen variables redundantes o de bajo peso cuya eliminación simplifica el modelos sin perjudicar, o incluso mejorando, su rendimiento. 

Esto se hace evaluando las 21 variables objetivo, no solo sobre los targets de referencia (`earthworm_shannon` y `earthworm_richness`).

=== Prueba de sensibilidad al random state <prueba-2>

=== Prueba de barrido de random_state <prueba-3>

=== Prueba de ensamblado de predicciones <prueba-4>