#heading(outlined: false, bookmarked: false)[Glosario de Términos]

En este glosario se incluyen definiciones que puedan ser de utilidad y aclaraciones sobre las diferentes abreviaturas empleadas a lo largo de esta memoria.

#figure(
  align(center)[
#table(
    columns: (auto, 1fr),
    align: (center + horizon, left + horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },   
  table.header([*Sigla*], [*Significado*]),
    [*API*], [Interfaz de Programación de Aplicaciones (_Application Programming Interface_).],
    [*ASV*], [Variante de Secuencia de Amplicón (_Amplicon Sequence Variant_). Unidad taxonómica empleada en los targets de biodiversidad microbiana/molecular (bacterias, hongos, eucariotas, oomicetos, cercozoos) obtenidos por metabarcoding.],
    [*CDS*], [Copernicus Climate Data Store.],
    [*CRISP-ML(Q)*], [_Cross-Industry Standard Process for Machine Learning with Quality Assurance_.],
    [*DEM*], [Modelo de Elevación Digital.],
    [*ECC*], [_Ensembles of Chains_ (Ensamblados de Cadenas), variante de RegressorChain empleada en este TFG.],
    [*GEE*], [Google Earth Engine.],
    [*MAE*], [Error Absoluto Medio.],
    [*MDI*], [_Mean Decrease Impurity_ (Reducción Media de Impureza), medida nativa de importancia de variables en modelos de árboles.],
    [*MDP*], [Proceso de Decisión de Markov (_Markov Decision Process_).],
    [*ML*], [_Machine Learning_ (Aprendizaje Automático).],
    [*MSE*], [Error Cuadrático Medio (_Mean Squared Error_).],
    [*NetCDF*], [Formato empleado por los archivos con extensión .nc, generalmente asociado a los datos descargados desde el CDS.],
    [*QA*], [_Quality Assurance_ (Aseguramiento de la Calidad).],
    [*R2*], [Coeficiente de determinación.],
    [*RFE*], [_Recursive Feature Elimination_ (Eliminación Recursiva de Variables).],
    [*RMSE*], [Raíz del Error Cuadrático Medio.],
    [*SHAP*], [_SHapley Additive exPlanations_.],
    [*SOB4ES*], [_Integrating SOil Biodiversity to Ecosystem Services_, proyecto europeo en cuyo marco se desarrolla este TFG.],
    [*TSS*], [_True Skill Statistic_, métrica de rendimiento habitual en modelos de distribución de especies.],
    [*VC*], [Dimensión Vapnik-Chervonenkis, medida de la capacidad de un espacio de hipótesis.],
    [*VIF*], [Factor de Inflación de la Varianza (_Variance Inflation Factor_).],
  )],
    caption: [Glosario de abreviaturas.],
    kind: table,
)

#colbreak()

#figure(
  align(center)[
  #table(
    columns: (auto, 1fr),
    align: (center + horizon, left + horizon),
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header([*Término*], [*Definición*]),
    [*Accuracy*], [Proporción de predicciones correctas sobre el total, calculada tras la discretización de la predicción numérica en niveles ordinales de biodiversidad.],
    [*Bagging*], [_Bootstrap aggregating_. Técnica de ensamblado que entrena cada modelo base sobre una muestra aleatoria con reemplazo del conjunto de entrenamiento original, reduciendo la varianza del conjunto sin apenas aumentar el sesgo.],
    [*Cross-Validation* \ (Validación cruzada)], [Técnica de evaluación que divide el conjunto de datos en varios pliegues, entrenando y evaluando el modelo de forma repetida sobre distintas particiones, para obtener una estimación más robusta del rendimiento real que con una única partición.],
    [*F1-score*], [Media armónica entre Precisión y Recall, que penaliza con más fuerza que una media aritmética cuando una de las dos es baja aunque la otra sea alta.],
    [*Gradient Boosting*], [Técnica de ensamblado que construye modelos de forma secuencial, donde cada nuevo modelo corrige los errores cometidos por los anteriores. XGBoost es una implementación de esta técnica.],
    [*Kappa de Cohen*], [Métrica de concordancia entre la predicción y el valor real que corrige el nivel de acierto esperable por azar. Más robusta y fiable que el Accuracy, especialmente cuando las clases están desbalanceadas.],
    [*Matriz de confusión*], [Tabla que contrasta las clases predichas frente a las clases reales, permitiendo identificar en qué niveles de biodiversidad concreta se equivoca más el modelo.],
    [*Minimización del riesgo empírico* \ (ERM)], [Principio que aproxima el riesgo teórico, desconocido, de un modelo mediante el error medio calculado sobre el conjunto de entrenamiento disponible.],
    [*Overfitting*\ (Sobreajuste)], [Fenómeno por el cual un modelo aprende patrones específicos del conjunto de entrenamiento, incluido su ruido, en lugar de la relación subyacente, perjudicando su capacidad de generalización a datos nuevos.],
    [*Precisión*], [Proporción de muestras etiquetadas por el modelo como pertenecientes a una clase que realmente lo eran.],
    [*Recall*], [Proporción de casos realmente pertenecientes a una clase que el modelo logra detectar correctamente. Especialmente informativo cuando las clases están desbalanceadas.],
    [*Regularización*], [Método estadístico empleado para reducir los errores causados por el sobreajuste de los datos de entrenamiento, penalizando la complejidad del modelo (p. ej. L2 en Ridge, L1 en Lasso).],
    [*Underfitting*], [Fenómeno opuesto al sobreajuste: el modelo carece de capacidad suficiente para capturar las relaciones reales presentes en los datos, presentando un rendimiento pobre incluso sobre el propio conjunto de entrenamiento.],
  )],
     caption: [Glosario de términos.],
     kind: table,
)