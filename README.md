# SOB4ES - Modelado Predictivo de Biodiversidad
### CRISP-ML(Q) - Fase 3 y 4: Desarrollo y evaluacion de los modelos

Este repositorio contiene los pipelines completos para el entrenamiento, evaluacion y puesta en produccion de los modelos predictivos del proyecto SOB4ES. El objetivo principal del sistema es predecir indices de diversidad biologica (como el indice de Shannon H') a partir de variables edafologicas, climaticas y espaciales.

## Objetivos de la Rama

Esta rama tiene como objetivo probar si se puede mejorar los outputs proporcionados por los modelos de las dos siguientes formas:

1. Combinando los outputs de los modelos individuales de una de las siguientes formas:
    
    - **Media simple:** media aritmética de las 8 predicciones, mismo peso para todas. Línea base.
    - **Media ponderada (R2):** pesos proporcionales al R² de cada modelo en meta-train (negativos recortados a 0), normalizados a sumar 1.
    - **Top-k (k=4):** media simple, pero solo entre los 4 modelos con mejor R² en meta-train; descarta los débiles en vez de darles poco peso.
    - **Mediana:** valor central de las 8 predicciones en vez de la media. Más robusta a un modelo atípico, sin calibrar nada.
    - **Stacking convexo:** pesos `w ≥ 0`, `Σw = 1`, optimizados para minimizar el error en meta-train (`scipy.optimize`, SLSQP). Como una media ponderada pero óptima en vez de basada solo en R² individual.

2. Entrenando varios meta-modelos con los outputs de los valores como valores de entrada y teniendo parte de los valores de **`eval.csv`** como entrenamiento/referencia. Los meta-modelos entrenados son los siguentes:

    - **Ridge (L2):** regresión lineal con regularización L2; permite pesos negativos, penaliza coeficientes grandes.
    - **Lasso (L1):** regularización L1; puede llevar coeficientes de modelos irrelevantes exactamente a 0.
    - **ElasticNet (L1+L2):** combina L1 + L2, punto intermedio entre Ridge y Lasso.
    - **Lineal (s/regularización):** regresión lineal sin regularizar. Sin red de seguridad frente al sobreajuste con poco meta-train.
    - **RandomForest:** único candidato no lineal; poca profundidad para frenar el sobreajuste, pero el más inestable entre targets. Se usa una profundidad máxima de 3.

En esta iteración se prueba con solamente 8 de los 21 targets.

## Contenidos de la Rama

La rama se estructura principalmente alrededor de ocho cuadernos de Jupyter, cada uno dedicado al ciclo de vida completo de una familia algoritmica concreta:

* **`reg_model.ipynb`:** Modelo de Regresion Lineal Regularizada (Ridge).
* **`rf_model.ipynb`:** Modelo Random Forest.
* **`rf_multisalida.ipynb`:** Modelo Random Forest con multisalida.
* **`regressorchain.ipynb`:** Modelo de Random Forest con RegressorChain.
* **`xgboost-model.ipynb`:** Modelo Avanzado (XGBoost). Utiliza la arquitectura de Gradient Boosting para maximizar el rendimiento predictivo, empaquetado en una solucion de ensamble por expertos.
* **`xgb_multisalida.ipynb`:** Modelo XGBoost con multisalida.
* **`mlp_multisalida.ipynb`:** Modelo basado en redes neuronales multicapa con multisalida.
* **`mlp_custom_loss.ipynb`:** Modelo basado en redes neuronales multicapa con pérdida personalizable.`

A partir de ahí se incluyen los diferentes elementos adicionales:
* **`comparador_modelos.ipynb`:** Carga todos los modelos y comprueba cuál de ellos es mejor dentro de un ranking en base a métricas numéricas (R2, RMSE, MAE).
* **`comparador_clasificacion.ipynb`:** Carga todos los modelos y comprueba cuál de ellos es mejor dentro de un ranking en base a métricas discretas (Kappa, F1, Matrices de confusión).
* **`prueba_ensamblado_con_modelos.ipynb`:** Carga todos los modelos y comprueba si la diferencia de los outputs de los meta-modelos son menores en comparación con los outputs originales teniendo de referencia el valor real.
* **`prueba_ensamblado.ipynb`:** Carga todos los modelos y comprueba si la diferencia de los outputs de los outputs combinador son menores en comparación con los outputs originales teniendo de referencia el valor real. 
* **`executor.py`:** Script para facilitar la ejecución automática de todos los notebooks.

### Conjuntos de Datos Requeridos
Los flujos de trabajo asumen la existencia de tres divisiones de datos pre-procesados, estratificados espacialmente por pais de origen:
* `train.csv` (70%): Destinado de forma exclusiva al ajuste de los algoritmos.
* `test.csv` (15%): Utilizado para la busqueda de hiperparametros y la validacion cruzada.
* `eval.csv` (15%): Conjunto ciego retenido, utilizado unicamente en la seccion final de cada notebook para obtener estimaciones de error imparciales.


## Estructura Estandarizada del Flujo de Trabajo

Todos los notebooks operan bajo una estructura homogenea basada en las fases de la metodologia CRISP-ML(Q):

1. **Configuracion y Carga de Datos:** Importacion de librerias, carga de conjuntos `.csv` y definicion estricta de las variables autorizadas (`FEATURES_AUTORIZADAS`).
2. **Tuning de Hiperparametros:** Busqueda iterativa mediante `RandomizedSearchCV`.
3. **Validacion Cruzada:** Evaluacion de metricas operativas (R2, RMSE, MAE) mediante `RepeatedKFold` para la deteccion de sobreajuste.
4. **Explicabilidad del Modelo:** Generacion de graficos diagnosticos.
5. **Entrenamiento de Produccion:** Entrenamiento sobre la totalidad del conjunto de entrenamiento y persistencia de los modelos en la carpeta local `/models`.
6. **Evaluacion Final e Inferencia:** Medicion contra el subconjunto `eval.csv` y ejecucion de Smoke Tests automatizados para certificar la estabilidad del pipeline predictivo con datos nuevos.


## Despliegue y Ejecucion

Para replicar o ejecutar los cuadernos en esta rama, es imprescindible el uso de un entorno virtual (`venv`) aislado.

1. Crear y activar el entorno virtual en la raiz del proyecto.
2. Instalar el arbol de dependencias mediante `pip install -r requirements.txt`.
3. Para la correcta renderizacion de los graficos SHAP, registrar el entorno como Kernel local de Jupyter.
4. (Opcional) Configurar la variable de entorno `PYTHONWARNINGS="ignore"` si se experimenta redundancia de salidas durante la ejecucion de hilos paralelos (`n_jobs=-1`).