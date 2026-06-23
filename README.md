# SOB4ES - Modelado Predictivo de Biodiversidad
### CRISP-ML(Q) - Fase 3 y 4: Desarrollo y evaluacion de los modelos

Este repositorio contiene los pipelines completos para el entrenamiento, evaluacion y puesta en produccion de los modelos predictivos del proyecto SOB4ES. El objetivo principal del sistema es predecir indices de diversidad biologica (como el indice de Shannon H') a partir de variables edafologicas, climaticas y espaciales.

## Objetivos de la Rama

1. **Desarrollo de Modelos Estructurados:** Implementar algoritmos de aprendizaje automatico (Regresion Lineal Regularizada, Random Forest y XGBoost) para establecer tanto lineas base interpretables como modelos avanzados de alto rendimiento.
2. **Optimizacion y Validacion:** Ejecutar busquedas exhaustivas de hiperparametros (Tuning) y validar la robustez y capacidad de generalizacion de los modelos mediante validacion cruzada repetida.
3. **Interpretabilidad:** Integrar tecnicas de explicabilidad, como valores SHAP (Shapley Additive exPlanations) y permutation importance, para comprender el impacto de cada variable ambiental en las predicciones.
4. **Puesta en Produccion:** Exportar los modelos optimizados en formato serializado (`.pkl`) y establecer pruebas de humo (Sanity Checks) para garantizar la integridad matematica y de software del flujo de inferencia.


## Contenidos de la Rama

La rama se estructura principalmente alrededor de tres cuadernos de Jupyter, cada uno dedicado al ciclo de vida completo de una familia algoritmica concreta:

* **`reg-model.ipynb`:** Modelo de Regresion Lineal Regularizada (Ridge). Utilizado como modelo base, estabilizando los coeficientes mediante penalizacion L2 frente a la colinealidad de las variables.
* **`rf-model.ipynb`:** Modelo Random Forest. Implementa un ensamble de arboles de decision para capturar relaciones no lineales complejas, generando multiples estimadores para reducir la varianza.
* **`xgboost-model.ipynb`:** Modelo Avanzado (XGBoost). Utiliza la arquitectura de Gradient Boosting para maximizar el rendimiento predictivo, empaquetado en una solucion de ensamble por expertos.

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