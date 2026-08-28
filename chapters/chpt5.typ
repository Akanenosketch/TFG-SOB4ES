//Config

#set rect(
  inset: 8pt,
  fill: rgb("#d6e3da"),
  width: 100%,
)

= Marco teórico y práctico <marco-teorico-o-practico>

En esta sección se describe el marco teórico y práctico en el que se apoya y fundamenta nuestras conclusiones: la arquitectura del pipeline de datos y modelado, las tecnologías y herramientas de tercero empleadas, como también los fundamentos teóricos que nos permite crear, desarrollar, entender e interpretar los resultados que nos proporcionan los diferentes modelos seleccionados.

== Fundamentos del aprendizaje automático <fundamentos-del-aprendizaje-automatico>

El término de aprendizaje automático, también conocido como *_Machine Learning_* (ML) fue acuñado por primera vez por el informático *Arthur Samuel*#sub([@arthurSamuelWikipedia,@geronHandsOnML]) en 1959, conocido por su trabajo en la implementación de un damas que aprendiera de forma autónoma y por dar soporte y colaborar en lo que hoy se conoce como LaTEX#sub([@latexProject]). 

Él acuñó el término de ML por primera vez en el artículo “_Some Studies in Machine Learning Using the Game of Checkers_” publicado en el IBM Journal of research and development#sub([@samuelCheckers]), definiéndolo de la siguiente forma: 

#rect[ “Machine Learning es el campo de estudio que permite le otorga a las computadoras la capacidad de aprender sin explícitamente programarlo.”]

Otro personaje relevante dentro del campo de la inteligencia artificial es *Tom Mitchell*#sub([@geronHandsOnML, @tomMitchellWikipedia]), creador del ordenador que es capaz de “leer la mente humana” a partir de imágenes del cerebro humano#sub([@reutersMindImages]). Él lo define de una forma más técnica, siendo esta una de las definiciones más citadas dentro de la literatura académica#sub([@mitchellMachineLearning]), la cual es la siguiente:

#rect[“Se dice que un programa de ordenador aprende de una experiencia E con respecto a una tarea T y una media de rendimiento P, si su rendimiento en T, medido por P, mejore con la experiencia E”]

Esta definición es la adoptada como referencia en este trabajo, al descomponer con claridad los tres elementos presentes del proyecto:

- *Tarea (T):* predecir los indicadores de biodiversidad del suelo a partir de las diferentes variables ambientales.
- *Experiencia (E):* El conjunto de datos de campo del proyecto SOB4ES, combinado con variables climáticas y geoespaciales de fuentes remotas.
- *Medida de rendimiento (P):* las métricas descritas en la @metricas-de-evaluacion-y-validacion, la cual se encuentra un poco más adelante en este documento.

Estas dos definiciones se pueden resumir de la siguiente forma #sub([@bergmannMachineLearningIBM]):

#rect[“El Machine Learning es una rama o subconjunto de la Inteligencia Artificial que se centra en dotar a los algoritmos la capacidad de “aprender”. Este aprendizaje es a partir de la detección de patrones en los datos de entrenamiento para, posteriormente, hacer predicciones o inferencias sobre nuevos datos.”]

Esta capacidad de aprender, permite a los modelos de ML realizar predicciones, tomar decisiones y hacer acciones variadas sin que lo tengan estrictamente indicado dentro de su código. También lo permite diferenciarse de los sistemas expertos tradicionales, en los que el conocimiento se codifica explícitamente, y lo acerca a la estadística de la que toma buena parte de su base matemática.

#colbreak()

=== Tipos de aprendizaje automático <tipos-de-aprendizaje-automatico>

Dentro del aprendizaje automático, existen muchos algoritmos y múltiples formas de aprendizaje en base al tipo de datos o experiencias de las que aprenden. 

Dichas formas de aprendizaje se clasifican en cuatro tipos generales, los cuales se explican a continuación.

==== Aprendizaje supervisado <aprendizaje-supervisado>

Dentro del *aprendizaje supervisado*, el algoritmo aprende a partir de un conjunto de datos en el que cada observación de entrada (las variables predictoras) tiene asociada una salida conocida (la variable a predecir, o _target_). Este tipo de modelos se entrenan haciendo uso de un conjunto de datos etiquetado#sub([@mitchellMachineLearning, @geronHandsOnML]), es decir, un conjunto de pares entrada-salida $(x_i, y_i)$ donde $y_i$ es el valor real que se desea predecir.

El objetivo del algoritmo de aprendizaje es encontrar una función $f$ tal que $f(x_i) approx y_i$, para las muestras de entrenamiento, y que generalice razonablemente las muestras nuevas no vistas durante el entrenamiento:

$ hat(f) = "arg min"_(f in cal(H)) 1/n sum_(i=1)^n L(y_i, f(x_i)) + Omega(f) $

donde:

- *$cal(H)$* es el espacio de funciones que el algoritmo puede representar (Hipótesis).
- *$L$* es la función de pérdida que mide el error de predicción.
- *$Omega(f)$* es un término de regularización opcional que penaliza la complejidad de $f$ para evitar el sobreajuste.

Dentro del aprendizaje supervisado se distinguen dos subtipos según la naturaleza de la salida ($y$):

- *Regresión*: La salida es una variable numérica continua, como lo puede ser, por ejemplo, un índice de biodiversidad expresado como un número real.
- *Clasificación*: La salida es una categoría discreta, como podría ser los índices de biodiversidad pero, en vez de usar el valor real, usando un criterio de clasificación como "bajo/medio/alto".

Como se menciona previamente, el aprendizaje supervisado necesita, casi por definición, un conjunto de datos ya etiquetado, lo que suele implicar un coste de recolección considerable. En este caso, el muestreo de campo y el análisis de laboratorio descritos en la #link(<introducción>)[*Introducción*] de este TFG.

A cambio, es el paradigma que permite una evaluación más objetiva del modelo, al poder comparar directamente la predicción con un valor real conocido, algo que no es posible, o no de forma tan directa, en los otros tres paradigmas.

Algunos algoritmos representativos de este paradigma son la regresión lineal, los árboles de decisión, los métodos de ensamblado (Random Forest, XGBoost) y las redes neuronales entrenadas con ejemplos etiquetados, varios de los cuales se emplean en este propio trabajo (véase #link(<modelos-de-aprendizaje-automatico-empleados>)[*Modelos empleados*]).

===== Minimización del riesgo empírico y capacidad del modelo <riesgo-y-capacidad>

La expresión anterior es un caso particular del *principio de minimización del riesgo empírico* (_Empirical Risk Minimization_, ERM)#sub([@mitchellMachineLearning]): como no se conoce la distribución real que generan los datos se aproxima el riesgo empírico.

Esta aproximación introduce un problema central dentro del aprendizaje automático: la minimización del riesgo empírico sin ningún control sobre la complejidad de $cal(H)$ puede producir una función que memorice el ruido específico del conjunto de entrenamiento en lugar de aprender el patrón subyacente; este es el fenómeno de *sobreajuste* o *_overfitting_*.

El término *$Omega(f)$* existe precisamente para mitigar el riesgo de sobreajuste, y es la razón teórica que justifica, por ejemplo, la penalización $alpha norm(w)^2$ de Ridge o el término

$ Omega(h_m) = gamma T + 1/2 lambda sum_(j=1)^T w_j^2 $

de XGBoost (véase #link(<regresion-ridge>)[*Regresión Ridge*] y #link(<xgboost>)[*XGBoost*]).

*Compromiso sesgo-varianza:* El error de generalización de un modelo puede descomponerse, para un punto $x$ cualquiera, en tres términos:

$ EE[(y-hat(f)(x))^2] = (EE[hat(f)(x)] - f(x))^2 + "Var"[hat(f)(x)] + sigma^2 $

siendo:

- *$(EE[hat(f)(x)] - f(x))^2$* el sesgo al cuadrado.
- *$"Var"[hat(f)(x)]$* la varianza.
- *$sigma_epsilon^2$* el ruido irreducible del error/punto.

Esto implica las siguientes deducciones/afirmaciones:

- Un modelo de *poca capacidad* tiende generalmente a presentar un *sesgo elevado y baja varianza*, haciéndolo incapaz de capturar relaciones reales entre los datos a pesar de ser estable dentro de las diferentes muestras de entrenamiento. A este fenómeno se lo denomina *_underfitting_*.
- Un modelo de *alta capacidad* tiende a justamente lo contrario: *bajo sesgo, elevada varianza*; esto se debe a que cualquier cambio pequeño en los datos de entrenamiento provoca que se generen modelos muy distintos entre sí, provocando *_overfitting_*.

*Capacidad y dimensión Vapnik-Chervonenkis (VC)*: De forma más formal, la teoría del aprendizaje estadístico acota el riesgo teórico en función del riesgo empírico y de la capacidad del espacio de hipótesis $cal(H)$: a mayor capacidad, mayor es la diferencia potencial entre el error de entrenamiento y el error real, y por tanto mayor es el número de muestras necesario para que el error empírico sea un estimador fiable del error real.

Parte de las decisiones tomadas dentro de este TFG en relación con el control de capacidad y el control de sesgo-varianza, radican en las nociones teóricas dispuestas dentro de este apartado.

===== Caso particular: regresión de salida múltiple <caso-particular-salida-multiple>

Un elemento importante de este TFG, el cual se hace uso, es hacer que $y$ no sea un único valor, sino que sea un *vector* de varios indicadores de biodiversidad de forma simultánea:

$ y = (y_1, y_2, ..., y_K) $

Esto sitúa el problema dentro del subcampo de la *regresión multisalida*, en el que caben, a grandes rasgos, tres estrategias principales:

- *Modelo por target*: Consiste en entrenar $K$ modelos de regresión de salida única, una por cada $y_k$, ignorando cualquier relación entre los diferentes targets.
- *Multisalida simétrica o nativa*: Consiste en entrenar un único modelo que predice el vector completo $y$ a la vez, compartiendo parámetros o estructura interna entre todos los targets.
- *Multisalida encadenada o direccional*: Consiste en entrenar una secuencia de modelos donde cada uno usa las predicciones de los modelos anteriores como variables adicionales a las ya existentes como variables predictoras o _features_.

Desde la perspectiva del compromiso sesgo-varianza, comentado en el apartado anterior, compartir parámetros entre los targets (estrategias 2 y 3) puede ser visto como una forma adicional de regularización: si los $K$ targets están correlacionados entre sí, forzar al modelo a explicarlos con una representación compartida reduce la varianza efectiva del conjunto de modelos, a costa de introducir un sesgo si algún target concreto se comporta de forma distinta al resto.

Estas tres estrategias, junto con la comparación empírica entre ellas, son precisamente el objeto de estudio de la _Comparación entre los modelos empleados_ (véase) y los resultados que se obtuvieron en las diferentes pruebas adicionales, las cuales se pueden ver en el _Anexo V_.

#colbreak()

==== Aprendizaje no supervisado <aprendizaje-no-supervisado>

Dentro del *aprendizaje no supervisado*, el algoritmo recibe únicamente datos de entrada, sin ninguna salida asociada, y su objetivo es encontrar estructura o patrones en los propios datos.

Los datos que se proporcionan en este tipo de aprendizajes son datos no etiquetados #sub([@geronHandsOnML, @bergmannMachineLearningIBM]). Solo se dispone de las entradas $x_i$, sin ningún valor $y_i$ asociado.

Al no existir una variable objetivo, no hay una noción o una idea directa de lo que puede ser considerado un "error de predicción" que minimizar; por lo tanto, en su lugar, cada familia de métodos define su propio criterio de qué constituye una buena estructura descubierta.

Dentro de este paradigma destacan las siguientes familias de métodos:

+ *Clustering o agrupamiento*: Se agrupan las observaciones que se determinan como similares entre sí, aunque no exista una categoría predefinida. Esto es común de algoritmos como k-means o el clustering jerárquico.
+ *Reducción de la dimensionalidad*: Busca representar los datos originales con el menor número de variables posibles, conservando la mayor parte posible de la información o varianza original. Esto es común del Análisis de Componentes Principales o PCA.
+ *Estimación de densidad y detección de anomalías*: Modelos de distribución de probabilidad $p(x)$ subyacente a los datos, de forma que las muestras con baja probabilidad bajo el modelo aprendido puedan señalarse como atípicas o anómalas.
+ *Modelado generativo*: Aprender a generar nuevas muestras sintéticas que sigan la misma distribución que los datos de entrenamiento, elemento base, entre otras cosas, de los modelos de fundación, los cuales se mencionan en el apartado siguiente. Común de los autoencoders o de los modelos de difusión.

No se ha empleado en este trabajo como técnica de modelado principal, ya que se dispone en todo momento de mediciones reales de biodiversidad que actúan como salida conocida; no obstante, algunas de sus ideas, como la *reducción de variables correlacionadas (reducción de la dimensionalidad)*, están relacionadas con la selección de variables descritas en la *@seleccion-de-variables*.

===== Formalización mediante una función objetivo interna <formalizado-no-supervisado>

A diferencia del aprendizaje supervisado, donde el objetivo $L(y_i, f(x_i))$ se define por comparación directa con una etiqueta externa $y_i$, dentro del aprendizaje no supervisado se sustituye la señal producida por $y_i$ por un criterio interno, definido únicamente en función de los propios datos de $x_i$, que cada familia de métodos formaliza de maneras distintas:

*Clustering (K-Means)*: dado un número de grupos $k$, se buscan centroides $mu_1, ..., mu_k$ que minimicen la suma de distancias al cuadrado dentro de cada grupo (inercia):

$ hat(mu) = "arg min"_(mu_1,...,mu_k) sum_(j=1)^k sum_(x_i in C_j) norm(x_i - mu_j)^2 $

*Reducción de dimensionalidad (PCA)*: se buscan las direcciones $w_1, ..., w_d$, con $d$ menor a la dimensión original, que maximizan la varianza de los datos proyectados, lo que equivale a resolver un problema de autovalores sobre la matriz de covarianza $Sigma$ de los datos:

$ hat(w) = "arg max"_(norm(w)=1) w^T Sigma w  arrow Sigma w = lambda w $  

*Estimación de densidad*: se busca la distribución de probabilidad $p_theta (x)$, dentro de una familia paramétrica, que maximiza la verosimilitud de los datos observados, para los cuales las muestras con $p_theta (x)$ muy baja se señalan como anómalas.

$ hat(theta) = "arg max"_theta Sigma_i log p_theta (x_i) $

En los tres casos, la ausencia de una variable $y$ externa obliga a sustituir la noción de "error de predicción" por una noción de "calidad de la estructura descubierta", lo cual implica que no existe una forma tan directa como en el aprendizaje supervisado de validar el resultado frente a un conjunto de test independiente.

==== Aprendizaje semi-supervisado <aprendizaje-semi-supervisado>

El *aprendizaje semi-supervisado*#sub([@geronHandsOnML]) es un punto intermedio entre los dos anteriores: se dispone de una pequeña cantidad de datos etiquetados (con salida conocida) y una cantidad mucho mayor de datos sin etiquetar, y el algoritmo aprovecha ambos para mejorar el modelo, por ejemplo mediante técnicas de *_self-training_*, en las que el propio modelo etiqueta provisionalmente los datos no etiquetados y los incorpora al entrenamiento si su confianza es suficientemente alta.

Es habitual en dominios donde etiquetar datos es costoso, pero recolectar datos sin etiquetar es barato, como ocurre por ejemplo en visión por ordenador.

Los modelos semi-supervisados no funcionan de forma automática por el mero hecho de añadir datos sin etiquetar: su validez depende de que se cumpla alguno de estos supuestos sobre la estructura de los datos#sub([@geronHandsOnML]):

- *Supuesto de suavidad*: Dos puntos cercanos en el espacio de entrada tienden a tener la misma etiqueta o un valor similar, en regresión.
- *Supuesto de agrupamiento*: Los puntos tienden a formar agrupaciones naturales, y los puntos dentro de un mismo cluster comparten etiqueta.
- *Supuesto de variedad*: Los datos de alta dimensión se concentran en realidad sobre una variedad de dimensión mucho menor, y es sobre esa variedad donde tiene sentido medir la similitud entre puntos.

Dentro de este paradigma destacan las siguientes familias de métodos:

- *_Self-training_*: Un modelo se entrena con los datos etiquetados, etiqueta con sus propias predicciones más confiables los datos sin etiquetar, y se reentrena incluyéndolos.
- *_Co-training_*: Dos modelos entrenados sobre vistas distintas de los datos se etiquetan mutuamente los ejemplos sin etiquetar.
- *Métodos basados en grafos*: Propagan las etiquetas conocidas a través de un grafo de similitud construido sobre todos los puntos, independientemente de que estén etiquetados o sin etiquetar.

No se ha empleado en este trabajo, dado que el conjunto de datos del proyecto SOB4ES está íntegramente etiquetado: no existe un excedente de observaciones sin medición de biodiversidad que pudiera aprovecharse de esta forma.

===== Formalización del objetivo combinado <semi-supervisado-formalizacion>

De forma general, el aprendizaje semi-supervisado optimiza una función objetivo que combina un término supervisado, calculado sólo sobre las $n_l$ muestras etiquetadas, con un término no supervisado o de regularización, calculado sobre las $n_u$ muestras sin etiquetar:

$ hat(f) = "arg min"_f 1/n_l sum_(i=1)^(n_l) L(y_i, f(x_i)) + lambda 1/n_u sum_(j=1)^(n_u) R(f, x_j) $

donde:

- *$1/n_l sum_(i=1)^(n_l) L(y_i, f(x_i))$* es el término supervisado.
- *$1/n_u sum_(j=1)^(n_u) R(f, x_j)$* es el término no supervisado.
- *$lambda$* controla el peso relativo del término no supervisado.
- *$R$* es la instancia de alguno de los siguientes supuestos:
  - *Regularización por consistencia*: penaliza cuando el modelo hace cambios en las predicciones ante pequeñas perturbaciones de una entrada sin etiquetas, formalizando, en consecuencia, el principio de suavidad.
  - *Minimización de entropía*: empuja al modelo a hacer predicciones más seguras sobre los datos sin etiquetar, cuando se trabaja con modelos de clasificación, formalizando el principio de agrupamiento.

==== Aprendizaje por refuerzo <aprendizaje-por-refuerzo>

En el aprendizaje por refuerzo#sub([@suttonReinforcementLearning, @russellNorvigAIMA]), el algoritmo/agente aprende interactuando con un entorno, recibiendo una recompensa o penalización según las acciones que toma, con el objetivo de maximizar la recompensa acumulada a lo largo del tiempo.

Formalmente se suele modelar como un Proceso de Decisión de Markov (MDP), y entre sus algoritmos más conocidos están Q-learning y sus variantes basadas en redes neuronales profundas (_Deep Reinforcement Learning_), popularizadas por sistemas como AlphaGo.

El MDP se define como una tupla de la siguiente forma:

$ (S, A, P, R, gamma) $

Donde:

- *$S$* es un conjunto de estados.
- *$A$* es un conjunto de acciones.
- *$P(s'|s,a)$* es una función de transición que da la probabilidad de pasar al estado $s'$ tras ejecutar la acción $a$ en estado $s$.
- *$R(s,a)$* es una función de recompensa.
- *$gamma in [0,1)$* es un factor de descuento que pondera las recompensas futuras frente a las inmediatas.

El agente busca una política $pi(a|s)$ que maximice el retorno esperado:

$ pi^* = "arg max"_pi EE[sum_(t=0)^infinity gamma^t R(s_t, a_t)] $

A diferencia del aprendizaje supervisado, no existe un conjunto fijo de pares entrada-salida que sean totalmente correctos proporcionado de antemano; es decir, el propio agente genera su experiencia de entrenamiento a través de la interacción con el entorno, y debe resolver el llamado *dilema exploración-explotación*.

Dicho dilema consiste en decidir en cada paso entre explotar la acción que, según lo aprendido hasta el momento, parece mejor, o explorar acciones distintas que podrían resultar en mejores recompensas a largo plazo pero cuyo valor aún no se conoce con certeza.

Algoritmos como Q-learning aprenden directamente una función de valor *$Q(s,a)$* que estima el retorno esperado de tomar la acción $a$ en el estado $s$ y seguir después la política óptima, sin necesidad de conocer explícitamente $P$ ni $R$.

Es el paradigma más cercano al programa original de Samuel de 1959 que dio nombre al campo#sub([@russellNorvigAIMA]). No se ha empleado en este trabajo, ya que no existe un entorno con el que el modelo interactúe de forma secuencial ni una noción de recompensa: se trata de un problema de predicción sobre datos ya recogidos, no de una secuencia de decisiones.

#colbreak()

===== Formalización mediante una función objetivo interna <aprendizaje-refuerzo-formalizacion>

En lugar de optimizar la política directamente, muchos algoritmos de aprendizaje por refuerzo aprenden primero una *función de valor*, que estima el retorno esperado desde un estado (o un par estado-acción) siguiendo una política dada.

La función de valor de un estado bajo la política $pi$ se define como:

$ V^pi (s) = EE[ sum_(t=0)^infinity gamma^t R(s_t, a_t) | s_0 = s ] $

y satisface la *ecuación de Bellman*, que expresa el valor de un estado de forma recursiva en función del valor de sus posibles estados siguientes:

$ V^pi (s) = sum_a pi(a|s) sum_(s') P(s'|s,a) [ R(s,a) + gamma V^pi (s') ] $

Esta recursividad es la base de los algoritmos _value-based_ como Q-learning, que aprenden iterativamente $Q(s,a)$ sin necesidad de conocer $P$ ni $R$ de antemano, actualizando las estimaciones a partir de la experiencia observada.

Existe una familia alternativa de algoritmos, los métodos _policy-based_, que en lugar de aprender una función de valor y derivar la política a partir de ella, parametrizan y optimizan la política $pi(a|s)$ directamente mediante ascenso de gradiente sobre el retorno esperado (teorema del gradiente de la política).

La distinción _value-based_ frente a _policy-based_, dentro del aprendizaje por refuerzo, es un paralelismo lejano de la distinción entre modelos discriminativos y modelos con una función objetivo optimizada de forma directa.

// 5.2.- Selección de variables

#colbreak()

== Selección de variables <seleccion-de-variables>

Antes de entrenar los modelos descritos en la sección anterior, es habitual reducir el conjunto de variables predictoras candidatas a un subconjunto más manejable y menos redundante. Esto no solo simplifica el modelo, sino que en modelos como Ridge resulta prácticamente necesario cuando existe colinealidad severa (véase #link(<regresion-ridge>)[*Regresión Ridge*]). 

En la literatura de aprendizaje automático, los métodos de selección de variables se agrupan tradicionalmente en tres familias, según su relación con el modelo predictivo final.

=== Métodos de filtrado <metodos-de-filtrado>

Los *métodos de filtrado o métodos de filtro* evalúan la relevancia de cada variable, o de cada par de ellas, de forma independiente del modelo que se vaya a entrenar después, basándose únicamente en las propiedades estadísticas de los datos. Son computacionalmente baratos y suelen aplicarse como primer paso, antes de cualquier tipo de entrenamiento.

Entre los métodos de filtro se incluyen, entre otros, los siguientes:
- *Correlación entre pares de variables predictoras:* permite detectar redundancia directa entre dos variables y descartar una de cada par altamente correlacionado. Dependiendo del tipo de relación se usa Pearson para las correlaciones lineales y Spearman para las relaciones monótonas lineales o no lineales.
- *Factor de Inflación de la Varianza (VIF):* a diferencia de la correlación por pares, detecta colinealidad multivariante, esto es que una variable puede no estar muy correlacionada con ninguna otra individualmente, pero esta misma puede ser una combinación lineal aproximada de varias de ellas al mismo tiempo. 
- *Correlación entre cada variable predictora y el target:* permite descartar variables con relación prácticamente nula con lo que se quiere predecir con independencia de su relación con el resto de variables predictoras.
- *Varianza mínima:* permite descartar variables casi constantes, que aportan poca o nula información discriminativa.

La principal limitación de estos métodos de filtrado es que, al ignorar el modelo final, pueden descartar una variable individualmente poco informativa pero que resulte útil en combinación con otras , o conservar variables redundantes desde el punto de vista de un modelo concreto aunque no lo sean estadísticamente en general.

=== Métodos de envoltura <metodos-de-envoltura>

A diferencia de los métodos de filtro, los *métodos de envoltura* evalúan subconjuntos de variables entrenando y validando el modelo real con cada subconjunto candidato, y usando el rendimiento obtenido como criterio de selección.

Son más costosos computacionalmente que los métodos de filtro, pero tienen en cuenta las interacciones entre variables y son específicos del modelo empleado.

Algunos de los métodos de envoltura son los siguientes:
- *Eliminación recursiva de variables (RFE):* entrena el modelo con todas las variables, elimina la menos importante según algún criterio y se repite el proceso hasta llegar al número deseado de variables.
- *Selección secuencial hacia adelante/atrás:* parte de un conjunto vacío o completo de variables y va añadiendo/eliminando una variable en cada paso en función de cuál mejora más o empeora menos el rendimiento del modelo.

#colbreak()

=== Métodos de embebido <metodos-de-embebido>

En los *métodos embebidos* la selección de variables ocurre como parte del propio proceso de entrenamiento, sin necesitar de una fase separada antes o después. Son los más eficientes computacionalmente de los tres tipos de métodos que se han mencionado, porque no requieren entrenar el modelos repetidamente con distintos subconjuntos de variables.

Los tipos de modelos embebidos más relevantes son los siguientes:

- *Regularización L1 (Lasso):* a diferencia de la penalización L2 de Ridge (véase #link(<regresion-ridge>)[*Regresión Ridge*]), la penalización L1 puede llevar coeficientes exactamente a cero, realizando así una selección de variables implícita durante el propio ajuste del modelo lineal. 

  Este tipo de regularización se hace uso en una de las pruebas realizadas con los modelos, las cuales se pueden ver en el Anexo V.

- *Importancia de variables de modelos basados en árboles:* Random Forest y XGBoost proporcionan de forma nativa una medida de importancia (impureza media/MDI, o por permutation importance) que, aunque se calcula típicamente después de entrenar el modelo completo, puede usarse de forma iterativa como criterio embebido de selección. Véase #link(<random-forest>)[*Random Forest*] y #link(<xgboost>)[*XGBoost*].

=== Variables empleadas <variables>

A lo largo de la elaboración de los diferentes modelos, los cuales se pueden ver en el repositorio de GitHub#sub([@githubTFGRepo]) y también se pueden ver en el Anexo III. 

Dentro de todas las posibles variables dentro del dataset final, las variables seleccionadas como variables predictoras han sido las siguientes, las cuales se pueden ver en la siguiente tabla, el resto de las variables existentes dentro del dataset empleado en la *@capa-modelado* se encuentran indicadas en el Anexo II.

#figure(
  align(center)[
    #table(
        columns: (25%, 75%), 
        align: (center + horizon),
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },  
    table.header(
      table.cell(align: center)[*Categoría*],
      table.cell(align: center)[*Variables*],
    ),  
    table.cell(align: center)[*Cobertura y \ estructura del suelo*], 
      grid(
        columns: (1fr, 1fr),
        align: left,
        [
          total_plant_cover_z\
          clay_content_z\
          silt_content_z\
          sand_content_z\
        ],
        [        
          aggregate_stability_z\
          bulk_density_z\
          soil_moisture_z\
        ]
      ),
    table.cell(align: center)[*Química y metales del suelo*], 
      grid(
        columns: (1fr, 1fr),
        align: left,
        [
          as_z\
          cu_z\
          k_z\
          mo_z\
          ni_z\ 
        ],
        [        
          p_z\
          pb_z\
          zn_z\
          soil_ph_z\
          plot_total_organic_c_z\
          plot_total_n_z\ 
        ]
      ),
    table.cell(align: center)[*Clima y teledetección (de Google Earth Engine)*], 
      grid(
        columns: (1fr, 1fr),
        align: left,
        [
          gee_temp_media_C_z\
          gee_humedad_rel_pct_z\
        ],
        [        
          gee_nvdi_verano_z\ 
        ]
      ),
    table.cell(align: center)[*Topografía (de DEM)*], 
      grid(
        columns: (1fr, 1fr),
        align: left,
        [
          dem_elevacion_m_z\
          dem_pendiente_deg_z\
        ],
        [        
          dem_orientacion_deg_z\
        ]
      ),
    table.cell(align: center)[*Variables europeas de referencia (capas EU)*], 
      grid(
        columns: (1fr, 1fr),
        align: left,
        [
          eu_clay_content_z\
          eu_sand_content_z\
          eu_silt_content_z\
          eu_water_holding_capacity_z\
          eu_cn_ratio_z\
        ],
        [        
          eu_p_z\
          eu_ph_z\
          eu_as_z\
          eu_organic_carbon_octop_z\
          eu_zn_z\
        ]
      ),
    )],
     caption: [Variables predictoras empleadas],
     kind: table,
)

Además de la tabla de variables predictoras, en la siguiente tabla se muestran las variables seleccionadas como variables objetivo (_targets_) a predecir en los modelos desarrollados.

#colbreak()

#figure(
  align(center)[
    #table(
      columns: (30%, 70%), 
      align: (center + horizon),
      fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header(
      table.cell(align: center)[*Categoría*],
      table.cell(align: center)[*Variables*],
    ),  
    table.cell(align: center)[*nematode_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de nematodos del suelo.], 
    table.cell(align: center)[*macro_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de la macrofauna del suelo.], 
    table.cell(align: center)[*earthworm_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de lombrices de tierra.], 
    table.cell(align: center)[*orib_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de ácaros oribáticos.],
    table.cell(align: center)[*meso_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de la mesofauna del suelo.], 
    table.cell(align: center)[*coll_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de colémbolos.], 
    table.cell(align: center)[*bac_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de la comunidad bacteriana.], 
    table.cell(align: center)[*fun_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de la comunidad fúngica.], 
    table.cell(align: center)[*euk_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de la comunidad eucariota.],
    table.cell(align: center)[*oomy_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de oomicetes (Oomycota).], 
    table.cell(align: center)[*cerc_shannon_z*], 
      table.cell(align: left)[Índice de biodiversidad de Shannon de cercozoos (Cercozoa,protistas).],
    table.cell(align: center)[*macro_order_richness_z*], 
      table.cell(align: left)[Riqueza de órdenes de macrofauna del suelo.], 
    table.cell(align: center)[*earthworm_richness_z*], 
      table.cell(align: left)[Riqueza de especies de lombrices de tierra.], 
    table.cell(align: center)[*orib_species_richness_z*], 
      table.cell(align: left)[Riqueza de especies de mesofauna del suelo.],
    table.cell(align: center)[*meso_species_richness_z*], 
      table.cell(align: left)[Riqueza de especies de colémbolos.], 
    table.cell(align: center)[*coll_species_richness_z*], 
      table.cell(align: left)[Riqueza de especies de colémbolos.], 
    table.cell(align: center)[*bac_asv_richness_z*], 
      table.cell(align: left)[Riqueza de ASV bacterianos.], 
    table.cell(align: center)[*fun_asv_richness_z*], 
      table.cell(align: left)[Riqueza de ASV fúngicos.], 
    table.cell(align: center)[*euk_asv_richness_z*], 
      table.cell(align: left)[Riqueza de ASV de eucariotas del suelo.],
    table.cell(align: center)[*oomy_asv_richness_z*], 
      table.cell(align: left)[Riqueza de ASV de oomicetos.], 
    table.cell(align: center)[*cerc_asv_richness_z*], 
      table.cell(align: left)[Riqueza de ASV de cercozoos.],   
    )],
     caption: [Variables objetivo empleadas],
     kind: table,
)

#colbreak()
// 5.3.- Modelos empelados

== Modelos de aprendizaje automático empleados <modelos-de-aprendizaje-automatico-empleados>

En las secciones de #link(<herramientas>)[*Herramientas empleadas*] y #link(<arquitectura>)[*Arquitectura general*], un poco más adelante en este documento, se describirán, tanto a nivel teórico como práctico, las tecnologías y herramientas empleadas a lo largo de todo este trabajo, tanto para el desarrollo de los modelos, como también para su evaluación y realización de pruebas y actividades, las cuales se pueden ver en los correspondientes anexos.

En esta sección se va a complementar la información, ya proporcionada por las secciones ya mencionadas previamente, con los fundamentos teóricos de cada modelo con el que se ha probado, de forma general, su funcionamiento base y la correspondiente justificación sobre por qué se han considerado estos modelos y no otros para este trabajo en concreto.

También se hablará de las variantes empleadas en caso de haberse usado variantes de los modelos base.

Además, en el [Anexo III], se podrá ver el código base de todos los modelos empleados.

=== Regresión Ridge <regresion-ridge>

Los modelos de regresión ridge, es una variante de los modelos de regresión base, pero que cuenta con regularización para corregir el sobreajuste de los datos de entrenamiento cuando se están desarrollando modelos de aprendizaje automático o machine learning.

Esta variante de modelo fue propuesta originalmente por Hoerl y Kennard en 1970#sub([@hoerlRidgeRegression])como respuesta a los problemas relacionados con la inestabilidad que aparecían cuando las variables predictoras presentaban niveles elevados de colinealidad#sub([@ridgeRegressionIBM]).

Mientras que la regresión lineal ordinaria busca los coeficientes $w$ que minimizan únicamente el error cuadrático:

$ hat(w) = op("arg min")_w quad parallel y - X w parallel^2 $

Ridge añade una penalización proporcional al cuadrado de la magnitud de los coeficientes, controlada por el hiperparámetro 0:

$ hat(w)_"ridge" = op("arg min")_w quad parallel y - X w parallel^2 + alpha parallel w parallel^2 $

Cuando =0, Ridge se reduce a la regresión lineal ordinaria, pero a medida que $alpha$ aumenta, los coeficientes se “encogen” hacia cero sin llegar nunca a anularse por completo en comparación con Lasso, reduciendo la varianza del modelo a costa de introducir un pequeño sesgo.

A diferencia de la regresión lineal ordinaria, que no tiene una solución estable cuando existe colinealidad perfecta o casi perfecta entre variables, Ridge sí tiene siempre una solución cerrada única, la cual es la siguiente:

$ hat(w) = (X^T X + alpha I)^(-1) X^T y $

#rect[*Nota:* La colinealidad entre variables en Ridge, lo que provoca es que la matriz $X^T X$ deja de ser invertible o queda mal condicionada.]

Esto permite que al sumar $alpha I$ a $X^T X$ se garantice que la matriz sea invertible independientemente del grado de colinealidad entre las diferentes variables predictoras, propiedad relevante para este TFG, donde varias de las variables edáficas y climáticas están correlacionadas entre sí debido a que proceden de fuentes relacionadas entre sí (véase Anexo II).

#colbreak()

*Grafos de libertad efectivos y elección de $alpha$:* Una forma útil de entender el efecto de la regularización es a través de los llamados grafos de libertad efectivos del modelo:

$ "df"(alpha) = sum_(j=1)^p d_j^2 / (d_j^2 + alpha) $

donde *$d_j$* son los valores singulares de $X$.

Cuando $alpha = 0$, df($alpha$) = p, es decir, se usan todos los grados de libertad del modelos lineal completo. A medida que crece $alpha$, df($alpha$) disminuye, reflejando que el modelo efectivamente emplea menos parámetros libres.

*Requisito de estandarización:*
- La interpretación de los coeficientes de Ridge en términos de importancia relativa sólo es válida si las variables predictoras están en la misma escala, ya que la penalización ∥w||2 trata todos los coeficientes por igual independientemente de la escala original de la variable a la que multiplican.
  
   Por este motivo, todas las variables predictoras de este TFG se han normalizado (media 0, varianza 1) antes del entrenamiento.

Los motivos de su uso en este TFG como uno de los 8 modelos a desarrollar y probar son los siguientes:

+ Los coeficientes son directamente interpretables en términos de la dirección y magnitud del efecto o relevancia que tiene cada variable predictora sobre el índice de diversidad de Shannon H’ o la riqueza de los diferentes grupos biológicos, siempre que dichas variables se encuentren normalizadas, el cual es el caso en este trabajo.
+ Al ser un modelo sencillo y computacionalmente barato sirve como línea base para comparar modelos que requieren de más recursos computacionales y son más complejos, pudiendo probar de esta forma si los datos se predicen bien con modelos sencillos en vez de recurrir a modelos más complejos.

=== Random Forest <random-forest>

Random Forest, propuesto por Breiman en 2001#sub([@breimanRandomForests]), es un método de ensamblado de modelos basado en árboles de decisión que combina las predicciones de múltiples árboles entrenados de forma independiente para obtener una predicción más robusta que la de un único árbol. Se apoya en dos fuentes de aleatoriedad, de las que toma su nombre de Random Forest:

- _*Bagging (bootstrap aggregating):*_ cada árbol se entrena sobre una muestra aleatoria con reemplazo del conjunto de entrenamiento original, de forma que cada árbol ve una versión ligeramente distinta de los datos.
- *Selección aleatoria de variables:* En cada división de cada árbol, sólo se considera un subconjunto aleatorio de las variables predictoras disponibles, en lugar de todas.

Para una tarea de regresión como la de este TFG, la predicción final es la media de las predicciones individuales de los N árboles del bosque:

$ hat(y) = 1/N sum_(i=1)^N hat(y)_i $

Al promediar los árboles que comenten errores distintos entre sí, gracias a la doble aleatoriedad que se introdujo, la varianza del conjunto se reduce sin apenas aumentar el sesgo, lo que hace Random Forest especialmente robusto frente al sobreajuste en comparación con un árbol de decisión individual.

#colbreak()

*Reducción de varianza y correlación entre árboles:* Si cada árbol individual tiene varianza $sigma^2$ y los árboles del bosque están correlacionados entre sí con coeficiente medio $rho$, la varianza del promedio de N árboles es:

$ "Var"(hat(y)) = rho sigma^2 + frac(1 - rho, N) sigma^2 $

Esta expresión es clave para entender por qué Random Forest introduce la selección aleatoria de variables además del *_bagging_*: el _bagging_ por sí solo ya reduce el segundo término (el que decrece con $N$), pero los árboles resultantes tienden a estar muy correlacionados entre sí (comparten las variables más predictivas en los primeros splits); al forzar que cada división considere sólo un subconjunto aleatorio de variables, se reduce $rho$, y por tanto el primer término, que es el que no desaparece por mucho que se aumente $N$.

*Importancia de variables:* Random Forest, en su implementación de scikit-learn#sub([@scikitLearn]) proporciona de forma nativa dos formas de estimar la importancia de cada variable predictora: la *importancia por impureza media (MDI)*, calculada como la reducción media de varianza (en regresión) que aporta cada variable en los nodos donde se ha usado para dividir, ponderada por la proporción de muestras que llegan a cada nodo; y la *importancia por permutación (_permutation importance_)*, que mide la caída de rendimiento del modelo al barajar aleatoriamente los valores de una variable en el conjunto de validación, manteniendo el resto intactas. La segunda es más robusta frente a variables con muchos niveles o alta cardinalidad, aunque computacionalmente más costosa.

Ambas medidas se han empleado en este TFG como complemento a SHAP#sub([@shapDocs]) (véase /*#link(<evaluacion-de-modelos>)[Capa de evaluación de modelos]*/).

Se ha considerado este modelo, junto con su variante multisalida, por su buen comportamiento con conjuntos de datos de tamaño reducido como el de este TFG, su tolerancia a variables predictoras correlacionadas entre sí, y por proporcionar de forma nativa una medida de importancia de variables, complementando a SHAP (véase la /*#link(<capa-de-evaluacion-de-modelos>)[Capa de evaluación de modelos]*/).

==== Random Forest multisalida <random-forest-multisalida>

El módulo `RandomForestRegressor` de scikit-learn, permite de forma nativa una matriz y de salida múltiple permitiendo entrenar todos los árboles para que sean capaces de predecir múltiples indicadores a la vez y a partir del criterio de división de cada nodo se calcule de forma conjunta sobre todas las salidas.

Esto significa que, a diferencia de entrenar un único modelos independiente por indicador/target, la variante multisalida permite que un mismo árbol capture patrones de división que sean simultáneamente informativos para varios targets correlacionados entre sí sin necesidad de un mecanismo explícito de encadenamiento como es RegressorChain, el cual se explica con más detalle en las siguientes secciones.

La predicción para el target k-ésimo en la variante multisalida sigue siendo el promedio de las predicciones de los N árboles del bosque para ese target concreto:

$ hat(y)_k = 1/N sum_(i=1)^N hat(y)_(i,k) $

pero, a diferencia de entrenar $K$ bosques independientes (uno por target), aquí los $N$ árboles son compartidos entre todos los targets, lo que reduce el coste computacional total y permite comparar directamente si el aprendizaje conjunto aporta ventaja frente a la variante independiente (véase /*#link(<sec-anexo-v-pruebas-llevadas-a-cabo>)[Anexo V]*/ ).

#colbreak()

=== XGBoost <xgboost>

En *XGBoost* o también conocido como _*Gradient Boosting*_, lo que hace es crear y construir los árboles de forma secuencial (a diferencia de Random Forest que los entrena y construye de forma independiente y en paralelo) para que cada árbol nuevo sea entrenado para corregir los errores o residuos cometidos por su conjunto de árboles predecesor ya entrenados.

La predicción tras añadir el árbol m-ésimo se define de forma aditiva:

$ F_m (x) = F_(m-1)(x) + eta h_m (x) $

donde:

- *$F_(m-1)(x)$* es la predicción acumulada de los árboles anteriores.
- *$h_m(x)$* es el nuevo árbol entrenado para aproximar el gradiente negativo de la función de pérdida.
- *$η$* es la tasa de aprendizaje o _learning rate_, que controla cuánto contribuye cada nuevo árbol a la predicción final.

Este enfoque secuencial permite habitualmente alcanzar un rendimiento superior al de Random Forest con menos árboles, pero también lo hace más sensible al sobreajuste si el número de árboles o la tasa de aprendizaje no se ajustan correctamente.

*Objetivo regularizado:* A diferencia del gradient boosting clásico, XGBoost optimiza en cada iteración una aproximación de segundo orden (expansión de Taylor) de la función de pérdida, e incluye un término de regularización explícito sobre la complejidad del árbol añadido#sub([@chenXGBoost]):

$ L^((m)) approx sum_(i=1)^n [ g_i h_m (x_i) + 1/2 l_i h_m (x_i)^2 ] + Omega(h_m), quad Omega(h_m) = gamma T + 1/2 lambda sum_(j=1)^T w_j^2 $

donde:
- *$g_i$* es la primera derivada de la función de pérdida respecto a la predicción actual.
- *$l_i$* es la segunda derivada de la función de pérdida respecto a la predicción actual.
- *$T$* es el número de hojas del árbol hm.
- *$w_j$* es el valor de predicción de la hoja j.
- *$lambda, gamma$* son hiperparámetros que penalizan a los árboles con demasiadas hojas o con pesos demasiado grandes.

Esta regularización explícita, junto con el subsampling de filas y columnas (parámetros `subsample` y `colsample_bytree`), es lo que hace a XGBoost más resistente al sobreajuste que una implementación básica de _gradient boosting_, aun siendo más sensible que Random Forest al número de árboles y a la tasa de aprendizaje si no se ajustan mediante validación cruzada.

Se ha considerado este modelo, junto con su variante multisalida, por ser uno de los modelos que presenta mejor rendimiento en general en base a los resultados reportados por la literatura revisada en contexto a los problemas de biodiversidad del suelo con conjunto de datos reducidos (véase #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*]).

Este hecho se prueba una vez más con la variante multisalida como se podrá ver más adelante en la sección de #link(<conclusiones>)[*Conclusiones*].

#colbreak()

==== XGBoost multisalida <xgboost-multisalida>

XGBoost no soporta la salida múltiple de forma nativa en todas las versiones de su librería. Para ello es necesario indicar explícitamente parámetro multi_strategy del módulo XGBRegressor, que admite las siguientes estrategias:

+ *`one_output_per_tree`:* Opción por defecto, se entrena un conjunto de árboles independiente por cada target, de forma equivalente a entrenar K modelos XGBoost por separado, aunque compartiendo la misma llamada de entrenamiento.
+ *`multi_output_tree`:* Cada árbol se entrena para predecir todos los targets a la vez de forma similar a cómo lo realiza Random Forest en su variante multisalida de forma nativa, permitiendo que las divisiones del árbol capturen relaciones compartidas entre targets correlacionados.

En este TFG se ha empleado la estrategia *`multi_output_tree`*, precisamente para poder comparar, en igualdad de condiciones con la variante multisalida de Random Forest, si el aprendizaje conjunto de los distintos indicadores de biodiversidad aporta una ventaja real frente al modelado independiente (véase /*#link(<sec-anexo-v-pruebas-llevadas-a-cabo>)[Pruebas llevadas a cabo]*/), comparación que en las Conclusiones de este TFG resulta favorable a XGBoost multisalida frente al resto de modelos.

#colbreak()

=== RegressorChain <regressorchain>

Los modelos anteriores, en su forma multisalida, tratan todos los targets de forma simétrica dentro del mismo árbol o coeficientes. *RegressorChain*#sub([@scikitLearn]) basado en el concepto de cadena de clasificadores propuesto por Read et al.#sub([@readClassifierChains]) aborda la regresión multi-salida de una forma distinta: encadenando un modelo base por cada target, de forma que cada modelo de la cadena recibe como entrada las variables predictoras originales más las predicciones ya generadas por los modelos anteriores de la cadena:

$ hat(y)_k = f_k (X, hat(y)_1, hat(y)2, dots, hat(y)_(k-1)) $

De esta forma, si los indicadores de biodiversidad están relacionados entre sí, el modelo puede aprovechar esa relación de forma explícita y direccional para mejorar la predicción de los targets posteriores de la cadena.

Dentro de este TFG se hace uso de *Random Forest* como modelo base del *RegressorChain* y los hiperparámetros se ajustan una única vez dentro del modelo base, no se calculan por target ni por posición, sino sobre el conjunto de entrenamiento completo.

El orden en el que se recorren los targets y las cadenas anteriores es un detalle que determina la salida final del modelo, es decir, el orden de las cadenas tienen un impacto directo sobre el resultado final. Esto se debe a que un target situado al principio de la cadena nunca recibe como entrada las predicciones de los demás, mientras que uno situado al final se beneficia de todos los anteriores.

Para decidir el orden de las cadenas, existen diferentes formas de hacerlo:

- *Manual:* Consiste en escoger un criterio, como puede ser la varianza de cada target, y ordenar a partir de ese criterio. Es la opción más interpretable, ya que el orden tiene un significado defendible de antemano, pero depende de que el motivo y el conocimiento previo sean correctos.
- *Basado en los propios datos:* Consiste en calcular algún estadístico de asociación entre targets y el encadenando primero los targets más relacionados entre sí. Dentro de la literatura revisada (véase Referencias) esta estrategia se considera como una estrategia de segundo orden, por modelar relaciones entre targets, frente a las estrategia de primer orden y las de nivel superior, que intentan capturar relaciones conjuntas entre dos o más targets a la vez#sub([@readPfahringerReview2021]).
- *Como problema de búsqueda:* Consiste en hacer uso de técnicas como beam search, métodos de Monte Carlo#sub([@readMartino2020]) o algoritmos genéticos#sub([@readPfahringerReview2021])dado que evaluar todas las posibles combinaciones de un set de targets puede volverse intratable. Estos métodos suelen mejorar el resultado de un orden manual o de uno que sea puramente aleatorio, pero exige entrenar y evaluar la cadena completa muchas veces antes de llegar al orden final, con el consecuente coste computacional.
- *A partir de un modelo probabilístico de dependencia:* Consiste en hacer uso de algún modelo probabilístico, como por ejemplo, las redes bayesianas#sub([@sucarBayesianChains])aprendido sobre los propios targets. Los targets sin otro del que dependan irán de primeros en la cadena y los que dependan de más targets irán más tarde.

Cabe indicar que, ninguna de estas estrategias garantizan encontrar un orden verdaderamente óptimo, y todas comparten el mismo riesgo común: que el orden elegido perjudique de forma considerable a los targets que queden peor posicionados en la cadena.

#colbreak()

=== Redes neuronales <redes-neuronales>

Como alternativa de aprendizaje profundo a los modelos anteriores, se ha entrenado también un *perceptrón multicapa* (Multi-Layer Perceptron, MLP), implementado con PyTorch#sub([@pytorchDocs]). Un MLP está formado por una capa de entrada, una o varias capas ocultas y una capa de salida, donde cada capa transforma la salida de la anterior:

$ a^((l)) = f(W^((l)) a^((l-1)) + b^((l))) $

siendo $a^(l)$ la salida de la capa $l$, $W^(l)$ y $b^(l)$ los pesos y sesgos aprendidos de esa capa, y f una función de activación no lineal, que permite al modelo aprender relaciones no lineales entre las variables ambientales y la biodiversidad del suelo.

Dentro de los modelos MLP, se han desarrollado dos variantes, las cuales se van a explicar a continuación en las siguientes subsecciones, pero a nivel común, ambos modelos, dentro de la capa oculta se apila un bloque con la siguiente estructura, la cual termina en una capa lineal de salida con tantas neuronas como targets se tienen seleccionados, sin función de activación:

$ a^((l)) = "Dropout"("ReLU"(W^((l)) a^((l-1)) + b^((l)))), quad hat(y) = W^((L)) a^((L-1)) + b^((L)) $

El entrenamiento, haciendo uso de la función *ReLU*, que introduce la no-linealidad, ajusta los pesos de la red minimizando una función de pérdida mediante retropropagación del gradiente (_backpropagation_)#sub([@rumelhartBackprop]) y el algoritmo de optimización Adam#sub([@kingmaAdam]) que combina momento y una tasa de aprendizaje adaptativa por parámetro para acelerar y estabilizar la convergencia frente al descenso de gradiente estocástico estándar.

A pesar de que la literatura revisada en #link(<antecedentes-y-contexto>)[*Antecedentes y contexto*] indica y sugiere que los modelos basados en redes neuronales por regla general no superan a los modelos basados en árboles cuando se trata de entrenar con conjuntos de datos reducidos, se ha incluido este modelo para probar y contrastar esa hipótesis de forma empírica.

==== MLP multisalida <mlp-multisalida>

En esta variante, la capa de salida de la red tiene tantas neuronas como targets a predecir, y la red se entrena minimizando el *error cuadrático medio (MSE) estándar*, calculado y promediado conjuntamente sobre todos los targets a la vez:

$ L(y, hat(y)) = 1/K sum_(k=1)^K (y_k - hat(y)_k)^2 $

Al compartir las capas ocultas entre todos los targets, esta arquitectura fuerza a la red a aprender una representación interna común de las variables ambientales que sea útil para predecir todos los indicadores de biodiversidad simultáneamente, un enfoque de _multi-task learning_ que puede mejorar la generalización, si los targets comparten estructura, pero que también puede perjudicar a un target concreto si sus patrones difieren mucho de los del resto (efecto conocido como _negative transfer_).

#colbreak()

==== MLP con función de pérdida personalizada <mlp-con-funcion-de-perdida-personalizada>

En esta segunda variante, en vez de hacer las relaciones de forma implícita, se hacen de forma explícita, incorporando en esa misma relación una función de pérdida que se minimiza durante el entrenamiento.

La función de pérdida implementada para este caso combina MSE estándar con un término que penaliza que la matriz de correlación entre los 21 targets predichos se aleje de la matriz de correlación entre los targets reales del lote:

$ L(y, hat(y)) = "MSE"(y, hat(y)) + lambda_"corr" parallel "Corr"(y) - "Corr"(hat(y)) parallel_F $

donde:
- *$"Corr"(x)$* es la matriz de correlación de Pearson entre los 21 targets calculada sobre el lote.
- *$parallel x parallel_F$* es la norma de Frobenius.
- *$lambda_"corr"$* controla el peso de la penalización, si es igual a 0, el modelo se comportará como la variante multisalida.

El objetivo de esta función de pérdida es el de forzar a la red a preservar, además de la precisión punto a punto, la estructura de covariación entre los distintos indicadores de biodiversidad, es decir, que si dos índices tienden a subir o bajar juntos en datos reales, el modelos no rompa esa relación en sus predicciones, aunque prediga cada valor individual con cierto margen de error.

=== Comparativa <comparativa-modelos>

En la siguiente tabla se muestra una comparativa rápida de los modelos descritos en las secciones anteriores.

#figure(
  table( 
    columns: (auto, auto, auto, auto, auto, auto),
    align: horizon, 
    fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
    table.header([Criterio], [Ridge], [Random Forest], [XGBoost], [Regressor Chain], [MLP]), 
      [Relaciones no lineales], [No], [Sí], [Sí], [Sí (según modelo base)], [Sí], 
      [Interpretabilidad nativa], [Alta], [Media], [Media], [Media (heredada del modelo base)], [Baja], 
      [Robustez a colinealidad], [Requiere regularización], [Alta], [Alta], [Alta (según modelo base)], [Media], 
      [Relaciona los targets entre sí], [No], [Sí (simétrico)], [Sí (simétrico)], [Sí (direccional)], [Sí (representación compartida)], 
      [Sensibilidad a hiperparámetros], [Baja], [Baja-media], [Media-alta], [Media (según modelo base)], [Alta], 
      [Riesgo de sobreajuste], [Bajo], [Bajo], [Medio], [Medio (según modelo base)], [Alto], 
    ),
    caption: [Comparativa de modelos base],
    kind: table
)

#colbreak()
// 5.4.- Métricas empleadas

== Métricas de evaluación y validación <metricas-de-evaluacion-y-validacion>

Evaluar un modelo de aprendizaje automático consiste en resumir, mediante una o varias cantidades numéricas, en qué medida sus predicciones se aproximan a los valores reales sobre datos que el modelo no ha visto durante el entrenamiento.

Este apartado organiza las métricas relevantes según el tipo de problema al que estos responden. Estos se pueden clasificar en dos categorías generales, las cuales se explican a continuación en las siguientes secciones:
+ Métricas de regresión.
+ Métricas de clasificación.

=== Métricas de regresión <metricas-regresion>

Las *métricas de regresión* evalúan la distancia entre un valor real y un valor predicho, ambos continuos, sin necesidad de traducirlos previamente a categorías, como se hace en las métricas de clasificación.

Son el tipo de métrica natural cuando el objetivo de los modelos es aproximarse con la mayor fidelidad posible de una magnitud numérica.

==== Coeficiente de determinación <coeficiente-determinacion>

El coeficiente de determinación mide con qué proporción de la varianza de la variable objetivo es explicada por el modelo, en relación con un modelos de referencia trivial que siempre predice la media:

$ R^2 = 1 - frac(sum_(i=1)^n (y_i - hat(y)i)^2, sum(i=1)^n (y_i - overline(y))^2) = 1 - frac("SS""res", "SS""tot") $

donde:
- *$"SS"_"res"$* es la suma de cuadrados residual, es decir, el error del modelo.
- *$"SS"_"tot"$* es la suma de cuadrados total, es decir, la varianza de los datos respecto a su propia media.

El valor de $R^2$ oscila entre 1 y 0, pero puede llegar a números negativos, indicando que predice pero que el modelo trivial de referencia que sería predecir la media. Si el valor es 0 es que predice la media, mientras que si el valor de $R^2$ es un o muy cerca de él eso implica que el modelo predice mucho mejor que haciendo simplemente medias.

Su limitación principal, es el hecho de que no puede distinguir si su modelo mejora el rendimiento estando dentro del rango central o en los casos extremos y puede ser engañoso en casos en los que se entrena con un dataset reducido, a pesar de eso, es de gran utilidad, debido al ser una métrica relativa, nos permite ver un rendimiento a nivel general de modelos y nos facilita la comparación entre los diferentes modelos desarrollados para este TFG.

==== Raíz del error cuadrático medio <raiz-error-cuadratico>

$ "RMSE" = sqrt(1/n sum_(i=1)^n (y_i - hat(y)_i)^2) $

A diferencia del R2, el RMSE se expresa en las mismas unidades en las que se representan a las variables objetivo que se empleen, los que facilita su interpretación directa como “magnitud típica del error”. Al elevar al cuadrado cada residuo antes de promediar, el RMSE suele acabar penalizando de forma desproporcionada los errores grandes frente a los errores pequeños.

Esto quiere decir que un único punto predicho de una forma nefasta puede provocar que el valor de RMSE sea mucho más grande que lo que vendría siendo otras métricas más relativas, pudiendo dificultar la justificación. Esto hace que el RMSE sea muy sensible a los valores atípico, lo cual puede ser relevante para los valores de biodiversidad.

==== Error absoluto medio <error-absoluto-medio>

$ "MAE" = 1/n sum_(i=1)^n abs(y_i - hat(y)_i) $

El MAE también se expresa en las unidades originales de la variable objetivo, pero, al no elevar al cuadrado los errores, trata todos los correos de forma proporcional a su magnitud, sin tener la penalización extra que presenta el RMSE sobre los errores grandes.

Esto lo hace más robusto ante los valores atípicos, pero también lo hace menos sensible a errores grandes que pueden ser relevantes para la fiabilidad práctica del modelo.

Generalmente si se comparan MAE con RMSE, se puede obtener una vista informativa de con cuánta frecuencia hay errores grandes puntuales en base a la diferencia que hay entre ambos valores. Si se mantienen más o menos iguales que que los errores suelen ser pequeños y homogéneos, en caso contrario, eso implica que hay muchos errores grandes dentro de las predicciones. Por lo tanto, reportar ambas métricas juntas suele dar más información que reportándose por separado.

=== Métricas de clasificación <metricas-clasificacion>

Las *métricas de clasificación* evalúan la correspondencia entre una etiqueta real y una etiqueta predicha, ambas categóricas y pertenecientes a un conjunto finito de clases.

Cuando el problema original es de regresión, se puede optar a hacer una discretización a posteriori para poder aplicar este tipo de métricas y tener métricas también desde un punto de vista categórico, además del numérico.

==== Exactitud (_Accuracy_) <accuracy>

La exactitud o el accuracy mide la proporción de muestras cuya clase predicha coincide con la clase real:

$ "Acc" = 1/n sum_(i=1)^n bb(1)(hat(y)_i^"cls" = y_i^"cls") $

donde:
- *1 ( · )* es la función indicadora#sub([@scikitLearn]).

La principal limitación de la misma, es que se vuelve engañosa cuando las clases están muy desbalanceadas, ya que un modelo trivial que siempre prediga la clase mayoritaria puede obtener una exactitud alta sin haber aprendido nada, lo que hace que quede en una buena medida mitigada por el propio diseño de la discretización que se emplee en cada uso.

Aún así, la exactitud no distingue el tipo de error cometido, por lo tanto se suele recurrir al #link(<kappa-de-cohen>)[*Coeficiente de Kappa de Cohen*].

==== Precisión, recall y F1 <F1>

Dentro de un problema multiclase, la *precisión* y el _*recall*_ se definen primero por clase, tratando cada clase c como un problema binario:

$ "Precisión"_c = frac("TP"_c, "TP"_c + "FP"_c) quad quad "Recall"_c = frac("TP"_c, "TP"_c + "FN"_c) $

donde TPc, FPc y FNc son, respectivamente, los verdaderos positivos, los falsos positivos y los falsos negativos de la clase c#sub([@scikitLearn]). La precisión responde a “de las muestras que el modelo etiquetó como c, cuántas lo eran realmente”, mientras que el recall responde a “de las muestras que realmente eran c, cuántos detectó el modelo”.

#colbreak()

El *F1* combina ambas en su media armónica, la cual penaliza con más fuerza que una media aritmética en el caso de que en una de las dos sea muy baja, aunque la otra sea alta.

$ "F1"_c = 2 dot frac("Precisión"_c dot "Recall"_c, "Precisión"_c + "Recall"_c) $

==== Coeficiente de Kappa de Cohen <kappa-de-cohen>

El coeficiente de Kappa de Cohen#sub([@cohenKappa]) corrige la limitación que presenta el #link(<accuracy>)[*_Accuracy_*] comparando el acuerdo observado con el acuerdo esperado por el azar:

$ kappa = frac(p_0 - p_e, 1 - p_e) $

Un $k = 1$ indica un acuerdo perfecto, mientras que un $k = 0$ indica que el acuerdo es peor que uno escogido al azar. En este TFG al tratarse de clases con un orden natural (Bajo, Medio y Alto) y no meras etiquetas nominales sin relación aparente entre sí, resulta más útil e informativo hacer uso de la variante ponderada del Coeficiente de Kappa, la cual fue propuesta por Cohen#sub([@cohenWeightedKappa])que penaliza el descuento de forma proporcional a la distancia entre las clases implicadas, es decir, confundir Bajo con Alto, por ejemplo, penalizará más que si se confunde Bajo por Medio, indicando así, de forma cualitativa, que el primer error es mucho más grave que el segundo.

$ kappa_w = 1 - frac(sum_(i,j) w_(i,j) O_(i,j), sum_(i,j) w_(i,j) E_(i,j)) $

donde:
- *$O_("ij")$* es la matriz de acuerdo observado entre la clase real $i$ y la predicha $j$.
- *$E_("ij")$* es la matriz de acuerdo esperado por azar entre la clase real $i$ y la predicha $j$.
- *$w_("ij")$* son los pesos de penalización, en su variante lineal, de forma que la diagonal principal $(i = j)$ no penaliza y la penalización crece linealmente con la distancia ordinal entre clases.
El Kappa ponderado ofrece una lectura más adecuada al carácter ordinal de la discretización que la exactitud simple, es decir, dos modelos pueden presentar la misma exactitud, pero pueden presentar coeficientes de Kappa ponderados distintos, dependiendo de cómo se concentren los errores.

==== Matrices de confusión <matrices-de-confusion>

La matriz de confusión#sub([@scikitLearn]) no es en sí una métrica escalar, sino una tabla de contingencia que desglosa, para cada combinación de clase real y clase predicha, el número de muestras correspondiente. A diferencia de la exactitud, el F1 o el Kappa, que resumen el rendimiento del clasificador derivado en un único número, la matriz de confusión permite identificar el patrón de los errores, es decir, permite ver de forma gráfica las tendencias de confusión que puede presentar un modelo.

Normalizada por filas, la matriz de confusión se puede leer directamente como una tasa de aciertos y de tipos de error por clase, lo que facilita la comparación entre targets con distinto número de muestras y entre modelos con distinta exactitud global.

// 5.5.- Arquitectura empleadda

  #colbreak()

== Arquitectura general <arquitectura>
Para proporcionar una respuesta a los objetivos planteados y permitir la predicción de la biodiversidad del suelo a partir de variables ambientales, se ha diseñado una arquitectura de software basada en un flujo de datos modular y desacoplado, permitiendo de esta forma que cualquier cambio en alguna de las capas no provoque tener que realizar cambios en el resto de las capas.

El uso de este enfoque garantiza la reproducibilidad del sistema ante la posibilidad de incluir nuevas fuentes de datos o nuevos algoritmos de aprendizaje automático.

La arquitectura explicada previamente se compone de cuatro capas, las cuales transforman los datos brutos en uno o varios modelos predictivos para su futura evaluación y comprobación. Dicha estructura de capas se puede ver en el siguiente diagrama.

#figure(
  image("../diagramas/arquitectura.png"), 
  caption:[Arquitectura de software del proyecto],
  kind: auto
)

  #colbreak()

=== Capa de ingesta de datos <capa-ingesta>

Esta capa se encarga de la adquisición de datos con las diferentes APIs a emplear, como también cargar los diferentes archivos de los datasets que se tengan en local. \
La adquisición de datos se realiza en dos fases, las cuales están basadas en el origen de los datos que se van a recolectar:
+ *Ingesta de datos locales:*
  - Se hace la lectura de los datos locales recolectados por el grupo europeo SOB4ES, como otras fuentes de datos Europeas almacenados en local, los cuales contienen las capas raster de la ESDAC, CORINE Land Cover, entre otras fuentes de datos que nos proporcionan información fisicoquímica de las zonas en las que se hicieron las diferentes pruebas.
+ *Ingesta de datos remotos (APIs):*
  - Se implementa mediante el uso de APIs para obtener otros datos no recogidos dentro de los datos locales como viene siendo datos climatológicos y otros de interés como la inclinación del terreno.
  - Para ello se hacen uso de los siguientes servicios:
    + *Google Earth Engine (GEE)#sub([@googleEarthEngine]):* A través del módulo earthengine-api de python, para la extracción automatizada de datos como las imágenes satelitales de Sentinel-2 usadas para el cálculo de índices de vegetación y medias de temperatura y humedad.
    + *Copernicus Climate Data Store (CDS)#sub([@copernicusHomepage, @soilMicrobiomePrediction]):* Mediante el módulo cdsapi de python para la descarga de datos de reanálisis climático, en los que se incluyen datos sobre las precipitaciones mensuales acumuladas.
    + *Copernicus DEM (vía AWS)#sub([@copernicusDEM]):* Descarga del DEM (_Digital Elevation Model_), empleado para la obtención de altitudes, pendientes y orientaciones del terreno.
Además de las fases de la adquisición de datos, destacamos las siguientes librerías empleadas para ello:
- *pandas#sub([@pandas]):* Librería empleada para la manipulación e ingeniería de datos tabulares. Permite la lectura y la escritura de archivos .csv y .xlsx (excel). También puede gestionar uniones, filtrados y operaciones vectorizadas sobre múltiples filas de forma no muy compleja y eficaz.
- *earthengine-api#sub([@googleEarthEngine]):* Librería de desarrollo oficial de Google que permite la conexión remota, la autenticación y la orquestación de scripts de procesamiento geoespacial sobre la API de Google Earth Engine.
- *cdsapi#sub([@copernicusHomepage]):* Librería que habilita un enlace directo y oficial a la API de CCDS, para el envío de solicitudes de extracción de datos parametrizadas y para la descarga automática de los datos meteorológicos solicitados.

Al final de todo el procesamiento de esta capa se crea un archivo requirements.txt cuyo objetivo es almacenar todas las librerías necesarias para que lo realizado pueda ser reproducible.

#rect[
  *Nota:* A la hora de realizar la ingesta de datos remotos, tomamos como referencia las coordenadas obtenidas a través de la ingesta de datos locales. Esto permite la obtención de los datos necesarios de forma eficiente y evitar obtener datos innecesarios o crear muchos más datos faltantes.
]
  
#colbreak()

=== Capa de procesamiento de datos <capa-procesamiento>

Esta capa tiene como objetivo unificar las diferentes fuentes de datos bajo un marco de coordenadas común y resolver las diferentes discrepancias entre los datos, estandarizándolos y armonizándolos para poder emplearlos en futuras capas.\
Este proceso se hace dividiéndolo en tres subprocesos o fases:
+ *Procesado de datos de ficheros:* En este subproceso nos centramos en los datos que se tienen ya tanto del proyecto SOB4ES, como de otros datasets ya existentes, tanto a nivel UVIGO, como a nivel europeo.\ 
  Este procesamiento de datos da como resultado varios elementos, que será usado en el tercer subproceso. Dichos elementos son los siguientes:
  + *Datasets:*
      - *model_ready.csv:* Dataset optimizado ya para su uso e introducción en los diferentes modelos que se desarrollen a futuro.
      - *clean.csv:* Dataset intermedio con todos los datos limpios, empleado en las siguientes fases del procesamiento de datos como referencia y para la armonización de sus datos con los datos obtenidos por consultas remotas a bases de datos en la red.
      - *imputation_flags.csv:* Dataset que contiene únicamente flags que indican en qué celdas faltan datos de cada tipo de dato introducido en clean.csv.
  + *scaler.pkl:* Archivo pickle que guarda la media y la desviación estándar calculadas en la preparación de los datos y usadas para la normalización de cualquier otro dato nuevo de forma idéntica a como se normalizaron los datos originales.
  + *label_encoders.pkl:* Archivo pickle que guarda el mapeo de categorías a números aprendido durante la preparación de datos, para codificar de la misma forma cualquier otro dato nuevo.
+ *Procesado de datos de consultas remotas a bases de datos:* En este subproceso nos centramos en los datos obtenidos a partir de la realización de solicitudes en remoto para obtener datasets o datos provenientes de los diferentes servicios web que se emplean dentro de este trabajo.\ 
  Como consecuencia, este procesamiento de datos da como resultado un segundo dataset y un scaler.pkl intermedios con todos los datos relevantes obtenidos de datasets online, que será usado en el tercer subproceso.
+ *Combinación y armonización de ambas fuentes:* En este último subproceso, hacemos uso de los datasets intermedios comentados previamente para combinarlos y armonizar sus datos.\
  Como resultado de este último subproceso, obtendremos un dataset final con todos los datos preparados para ser usados en los diferentes modelos que se desarrollen en la siguiente capa.
Además de los subprocesos, a lo largo de procesamiento de esta datos se hace uso de las siguientes librerías:
- *pandas#sub([@pandas]):* #link(<capa-ingesta>)[véase el punto anterior].
- *numpy#sub([@numpy]):* Librería especializada en computación numérica que es generalmente empleada para el manejo de datos numéricos complejos, así como para dar soporte matemático a otras librerías como pandas.
- *rasterio#sub([@rasterio]):* Herramienta geoespacial destinada a la lectura de archivos matriciales con formato GeoTIFF, procedentes de las diferentes fuentes de datos europeas. También sirven para la realización de consultas directamente a las URLs correspondientes al DEM de Copernicus.
- *xarray#sub([@xarrayDocs]):* Librería diseñada para la manipulación de conjuntos de datos multidimensionales, los cuales se encuentran distribuidos en múltiples archivos .nc (NetCDF).
- *dbfread#sub([@dbfread]):* Librería ligera de bajo nivel capaz de leer de forma nativa y eficiente archivos con formato .bdf, facilitando la extracción de la información tabular contenida en ciertos conjuntos de datos vectoriales del catálogo europeo.
- *netCDF4#sub([@netcdf4]):* Librería que permite la lectura, escritura y manipulación de archivos con formatos netCDF y HDF5.

#colbreak()

=== Capa de modelado predictivo <capa-modelado>

El objetivo principal de esta capa es el desarrollo de los diferentes modelos predictivos como también la preparación de los sets de aprendizaje y pruebas y su consecuente entrenamiento.\
Antes de comenzar a trabajar en esta capa es recomendable tener el dataset con los datos finales preparado y armonizado para que el proceso pueda, de esta forma, ser mucho más lineal y sencillo de seguir. 

Esta capa y la siguiente, van a estar comunicadas entre sí debido a que el feedback que se reciba de la *Capa de evaluación de modelos* va a ser usada para mejorar los modelos que se desarrollen en esta capa. De esta forma se pueden obtener múltiples modelos predictivos de mayor calidad, el cual es el quinto sub objetivo de este trabajo de fin de grado.

De la misma forma que las capas anteriores, esta capa va a estar dividida en varias fases o subprocesos:
+ *Fase de partición de datos:* Esta fase consiste en coger el dataset final con los datos ya normalizados y armonizarlos y dividirlos en tres sets de menor tamaño para emplearlos cada uno para una de las siguientes funciones#sub([@setsEntrenamiento1, @setsEntrenamiento2]).
  + *Set de Entrenamiento:* Conjunto inicial, el cual será empleado para que los modelos que se desarrollen aprendan los patrones que haya ocultos entre los datos mediante el ajuste de los parámetros de los modelos.
  + *Set de Validación:* Conjunto usado para el ajuste de los hiperparámetros de los modelos y seleccionar cuáles funcionan mejor de forma objetiva sin contaminar en proceso. En esta parte también se hará uso del feedback obtenido de la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*].
  + *Set para la evaluación:* Conjunto de datos no empleados en ninguno de los sets mencionados previamente, su uso es para evaluar la eficacia del modelo en condiciones reales y con datos con los cuales nunca ha trabajo.
  La división de los datos se ha hecho teniendo en cuenta el origen de las muestras tomadas y a partir de la realización de esta fase obtenemos los datasets indicados en la siguiente tabla:

  #figure(
    align(center)[
      #table(
          columns: (3), 
          align: (center,center,center),
          fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },  
      table.header(
        table.cell(align: center)[*Nombre CSV*], [*Porcentaje de datos*], [*Nº de entradas*]),  
      table.cell(align: center)[*train.csv*], 
        table.cell(align: center)[70%],
        table.cell(align: center)[299], 
      table.cell(align: center)[*test.csv*], 
        table.cell(align: center)[15%],
        table.cell(align: center)[64], 
      table.cell(align: center)[*eval.csv*], 
        table.cell(align: center)[15%],
        table.cell(align: center)[65], 
      )],
      caption: [Tabla de los datasets resultantes de la fase 1],
      kind: table,
  )

+ *Fase de investigación de posibles modelos predictivos:* El objetivo de esta fase es tener una lista de modelos predictivos que se puedan desarrollar y emplear teniendo en cuenta los requisitos de este trabajo, como también condicionantes como el formato de datos y el número de estos mismos.\
  También en esta fase, además del listado de modelos predictivos a desarrollar, se elaborará un listado de parámetros a utilizar como variables para que el modelo tenga ya cierta calidad a la hora de hacer el primer aprendizaje y evaluación.
+ *Fase de configuración del entorno:* El objetivo de esta fase es tener el entorno con las librerías y todos los componentes necesarios para poder ejecutar sin problemas los diferentes modelos que se desarrollen a lo largo de la siguiente fase.

  El resultado de esta fase es una versión actualizada del archivo requirements.txt con todas las librerías empleadas en esta capa.
  #colbreak()
+ *Fase de desarrollo de modelos:* El objetivo de esta fase es tener un par de modelos desarrollados y contenidos dentro de múltiples jupyter notebooks para poder así, de esa forma, se pueden efectuar dentro de un entorno cerrado y seguro.

  El resultado de esta fase son múltiples notebooks con cada uno de los modelos desarrollados para su futuro entrenamiento.
+ *Fase de entrenamiento de los modelos:* El objetivo de esta fase es una vez creados los diferentes modelos a emplear, estos serán ejecutados uno a uno y serán entrenados para, posteriormente evaluarlos y realizar las correcciones correspondientes.

  El resultado de la fase es múltiples archivos *.pkl* con todos los modelos entrenados para su futuro uso.

A lo largo del desarrollo de esta capa, se hacen uso de las siguientes librerías:
- *sklearn/scikit-learn#sub([@scikitLearn]):* Librería principalmente creada para machine learning y para análisis de datos. Dentro de la propia librería hacemos uso de las funciones/submódulos que se muestran en la siguiente tabla:

  #figure(
    align(center)[
      #table(
        columns: (30%,70%), 
        align: (horizon),
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },  
      table.header(
        table.cell(align: center)[*Submódulo*], [*Descripción*]),  
      table.cell(align: center)[*linear_model.Ridge*], 
        table.cell(align: left)[Implementa la regresión lineal con regularización L2, siendo este el algoritmo base para Ridge Regression.],
      table.cell(align: center)[*ensemble.RandonForest*], 
        table.cell(align: left)[Implementación del algoritmo de Random Forest para regresión.],
      table.cell(align: center)[*multioutput. RegressorChain*], 
        table.cell(align: left)[Permite envolver un modelo base (en nuestro caso Random Forest) para, durante el entrenamiento, replicar el modelo base una vez por cada target. De esta forma se pueden encadenar las predicciones de los targets anteriores como entrada adicional para poder predecir los siguientes valores.],
      table.cell(align: center)[*model_selection.\ RandomizedSearchCV*], 
        table.cell(align: left)[Realiza la búsqueda de hiperparámetros, probando todas las posibles combinaciones del grid de parámetros establecido por el usuario/desarrollador. Se escoge el mejor set de hiperparámetros haciendo uso de la validación cruzada (CV).],
      table.cell(align: center)[*model_selection.\ cross_validate*], 
        table.cell(align: left)[Ejecuta la validación cruzada repetida para medir la robustez del modelo y poder detectar sobreajustes.],
      table.cell(align: center)[*model_selection.\ RepeatKFold*], 
        table.cell(align: left)[Permite aplicar la estrategia de partición en pliegues para la validación, obteniendo así lo siguiente:\
          *_$ x "pliegues" \* y "repeticiones" = "xy" "evaluaciones" $_*
      ],
      table.cell(align: center)[*model_selection.KFold*], 
        table.cell(align: left)[Variante simple de *RepeatKFold*.],
      )],
      caption: [Tabla de submódulos empleados de la librería scikit-learn],
      kind: table,
  )

- *XGBoost#sub([@xgboostDocs, @xgboostIBM]):* Librería que implementa algoritmos de ML bajo el framework de _Gradient Boosting_. Su aprendizaje se basa en árboles de decisión potenciados por el framework mencionado previamente.\
  Además de hacer uso de la propia librería destacamos el siguiente submódulo o función:
  - *XGBRegressor:* Implementa el algoritmo de gradient boosting sobre los árboles de decisión. Además, de que permite trabajar con múltiples salidas haciendo uso del argumento `multi_strategy=multi_output_tree`.
  #colbreak()

- *PyTorch#sub([@pytorchDocs]):* Librería que se emplea principalmente para actividades de ML, y para la creación de redes neuronales. Actualmente es una de las más empleadas dentro del entorno académico e investigador.\ 
  De esta librería destacamos los siguientes elementos:

  #figure(
    align(center)[
      #table(
        columns: (30%,70%), 
        align: (center,center),
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },  
      table.header(
        table.cell(align: center)[*Submódulo/Módulo*], [*Descripción*]),  
      table.cell(align: center)[*torch*], 
        table.cell(align: left)[Librería principal de PyTorch, proporcionando los tensores, el cálculo de gradientes (autograd) y el optimizador Adam usado para entrenar a las redes neuronales.],
      table.cell(align: center)[*torch.nn*], 
        table.cell(align: left)[Módulo de torch encargado de la definición y construcción de redes neuronales. En términos de definición se pueden definir las capas, el modo de activación, la regularización y la función de pérdida, entre otros elementos.],
      table.cell(align: center)[*torch.utils.data.\ DataLoader*], 
        table.cell(align: left, rowspan: 2)[Se encargan de gestionar la división del conjunto de entrenamiento en lotes de trabajo (batches) y su iteración aleatoria durante cada período de entrenamiento.],
      table.cell(align: center)[*torch.utils.data.\ TensorDataset*], 
      )],
      caption: [Tabla de submódulos empleados de la librería PyTorch],
      kind: table,
  )

- *joblib#sub([@joblib]):* Librería que permite la serialización de las funciones como también la computación paralela. Esto es de gran utilidad a la hora de entrenar y trabajar con los diferentes modelos, especialmente para manejar la concurrencia y la persistencia de los modelos creados haciendo uso de scikit-learn y XGBoost.

#colbreak()

=== Capa de evaluación de modelos <capa-evaluacion>

El objetivo principal de esta capa final es evaluar los diferentes modelos desarrollados en la #link(<capa-modelado>)[*Capa de modelado predictivo*] y a partir de las evaluaciones realizadas, hacer las siguientes acciones:\
+ Escoger los modelos que presentan una mayor utilidad y funcionalidad para el proyecto.
+ Mejorar los modelos escogidos en múltiples iteraciones.
Una vez más, de forma similar a las capas anteriores, esta capa se divide en las siguientes fases:
+ *Fase de validación individual:* Durante el desarrollo de los modelos, en cada notebook se han integrado varias celdas que tienen como objetivo realizar la validación cruzada para cada modelo antes de generar todos los modelos resultantes.\
  Esto se realiza para comprobar ya en la construcción de los modelos si los parámetros escogidos son los más efectivos o si estos, por otro lado, están provocando un sobreajuste en el modelo. También permite prevenir la fuga de datos originado por un entrenamiento deficiente o mal preparado.

  De esta fase se obtienen datos que figuran en los outputs de los notebooks de cada uno de los modelos diseñados, además de los modelos resultantes que serán usados en la siguiente fase.

+ *Fase de validación en conjunto de los modelos generados:* Para el correcto desarrollo de esta fase se van a crear dos notebooks más que se van a encargar de realizar la evaluación y validación de los modelos con dos puntos de vista distinto, los cuales son los siguientes:
  - *Punto de vista numérico:* En este notebook nos centramos en cargar todos los modelos desarrollados y evaluar el rendimiento de cada uno de los modelos contra el dataset creado para las pruebas.\
    Dentro de este punto de vista nos centramos en las siguientes métricas, cuyas definiciones se pueden encontrar en #link(<metricas-de-evaluacion-y-validacion>)[*Métricas de evaluación y validación*]:
    - *R2 global.*
    - *R2 por target.*
    - *RMSE.*
    - *MAE.*
    A partir de la ejecución del notebook se podrán ver los resultados de las pruebas tanto en las celdas de salida del notebook, como en los archivos de resultado que se exportan en la última fase de ejecución. Estos archivos contienen los resultados de la comparación entre modelos y el R2 por cada target de todos los modelos probados.
  - *Punto de vista discreto:* En este notebook sigue una metodología similar de realización de pruebas en comparación con el notebook anterior, pero para este se realiza una clasificación para poder ver los resultados, no tanto como números, sino como aciertos y fallos.\ 
    Dentro de este punto de vista nos podemos centrar en otras métricas, cuyas definiciones también se pueden encontrar en #link(<metricas-de-evaluacion-y-validacion>)[*Métricas de evaluación y validación*]:
      - *Matrices de confusión.*
      - *Kappa de Cohen.*
      - *F1.*
+ *Análisis de resultados y aplicación de mejoras:* El objetivo principal de esta fase es analizar los resultados obtenidos en la fase anterior, en la primera vuelta escoger los modelos que presentan el mejor funcionamiento y, a partir de la segunda vuelta, aplicar mejoras para intentar mejorar aún más el rendimiento.
  
  Esta fase no requiere de desarrollo de código, es únicamente ver los resultados obtenidos, analizarlos y mejorarlos en la medida de lo posible en base a las capacidades y limitaciones que se tienen.

#colbreak()  

A lo largo del desarrollo de esta capa, se hacen uso de las siguientes librerías:
- *scikit-learn:* véase definición anterior. Para esta capa hacemos uso de los siguientes submódulos de scikit-learn:

  #figure(
    align(center)[
      #table(
        columns: (30%,70%), 
        align: (horizon),      
        fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
      table.header(
        table.cell(align: center)[*Submódulo*], [*Descripción*]),  
      table.cell(align: center)[*metrics.r2_score*], 
        table.cell(align: left)[Calcula el coeficiente de determinación R2, la métrica principal para medir qué proporción de la varianza real da explicado el modelo.],
      table.cell(align: center)[*metrics.\ mean_squared_error*], 
        table.cell(align: left)[Calcula el error cuadrático medio, empleado para medir el error de predicción penalizando más de esa forma los errores grandes.],
      table.cell(align: center)[*metric.\ mean_absolute_error*], 
        table.cell(align: left)[Calcula el error absoluto medio (MAE).],
      table.cell(align: center)[*inspection.\ permuttion_importance*], 
        table.cell(align: left)[Mide la importancia de cada variable predictora mediante el barajeo de sus valores y observando en cuánto cae el rendimiento del modelo. Se emplea en los modelos los cuales presentan compatibilidad son SHAP (modelos que no son de árbol) y también para complementar a SHAP.],
      table.cell(align: center)[*base.BaseEstimator*], 
        table.cell(align: left, rowspan: 2)[Clases empleadas para envolver un modelo creado con PyTorch en una interfaz compatible con scikit-learn. Es necesario para poder hacer uso de permutation_importance sobre redes neuronales (son incompatibles de base).],
      table.cell(align: center)[*base.RegressorMixin*], 
      )],
      caption: [Tabla de submódulos empleados de la librería scikit-learn (para evaluación)],
      kind: table,
  )

  También se hacen uso de los submódulos *RepeatedKFold* y *cross_validate*, los cuales ya se han explicado en la parte de librerías empleadas de la #link(<capa-modelado>)[*Capa de modelado predictivo*].

- *SHAP#sub([@shapDocs]):* Librería que calcula los valores shapley haciendo uso de TreeExplainer para determinar la contribución exacta de cada variable a cada predicción realizada. Esto nos permite ver de forma gráfica cómo funciona el modelo y también ver cuánto impacto tiene cada una de las variables en los diferentes targets establecidos.
- *matplotlib#sub([@matplotlib]):* Librería creada para la generación de visualizaciones de diferentes tipos en Python, permitiendo mostrar datos de forma gráfica y crear ilustraciones gráficas complejas de forma intuitiva y sencilla. También funciona como motor subyacente para otras librerías como shap y seaborn.
- *seaborn#sub([@seabornDocs, @waskomSeaborn]):* Librería basada en matplotlib, permitiendo la creación de gráficas de datos con una interfaz de mayor nivel en comparación con matplotlib y está integrado de forma más cercana con otras librerías empleadas en este trabajo como pandas.

#colbreak()

//5.6.- Herramientas empleadas
== Herramientas empleadas <herramientas>

En esta sección se justifican las herramientas, servicios y programas de terceros empleados a lo largo de este trabajo. Parte de estos elementos se encuentran mencionados de nuevo en la sección de #link(<arquitectura>)[*Arquitectura general*] más adelante en el documento, donde se describe cómo se integran dentro del flujo de datos.

Aquí se explica, para cada uno, por qué se ha elegido frente a las alternativas disponibles.

=== Lenguaje de programación, control de versiones y librerías <lenguaje-de-programacion-control-de-versiones-y-librerias>

*Lenguaje de programación:*

- Como lenguaje principal de desarrollo de los modelos se ha empleado *Python*#sub([@pythonOrg]). Su elección se justifica por su amplia adopción dentro de los campos de la ciencia de datos y del aprendizaje automático, así como por la disponibilidad de un ecosistemas maduro y consolidado de librerías específicas y especializadas en estas tareas, lo que la ha permitido cubrir todas las necesidades del proyecto sin recurrir a herramientas externas al lenguaje.

  Dentro de este mismo lenguaje, el desarrollo de todos los modelos y los distintos notebooks de pruebas se han realizado principalmente sobre *Jupyter Notebook*#sub([@projectJupyter]), dado que formato que estos proporcionan (celdas ejecutables de forma independiente con salida , persistente de tablas y gráficas) encaja de forma natural con el flujo de trabajo experimental e iterativo descrito en #link(<resumen-de-la-solucion-propuesta>)[*Resumen de la solución propuesta*]. El entrenamiento, incluido el de los modelos que se benefician y pueden hacer uso de aceleración por GPU, se ha realizado en local, en un equipo con GPU dedicado facilitado por el tutor de este trabajo.

*Control de versiones:*

- Para el control de versiones, como también el almacenamiento de todo el trabajo, se ha hecho uso de *Git#sub([@git])* y de *GitHub#sub([@github])*. Esta elección permite mantener un historial completo de cambios, poder trabajar de forma aislada en cada prueba mediante ramas independientes (véase Anexo algo), y facilitar la trazabilidad entre el código y los resultados obtenidos en cada iteración del trabajo.

  Estas herramientas son de especial utilidad dado el enfoque exploratorio de este TFG, en el que distintas configuraciones de un mismo modelo se han probado en paralelo y pueden proporcionar resultados variados.

*Librerías:*

- Todas las librerías empleadas, junto a los correspondientes módulos/funciones empleadas se encuentran todas mencionadas en la sección anterior, cada una de ellas dentro de la capa de arquitectura en la que se usara.

=== Servicios de obtención de datos remotos <servicios-de-obtencion-de-datos-remotos>

A pesar de existir una gran cantidad de fuentes de datos abiertas disponibles, se han escogido las siguientes por su mayor facilidad de integración con Python y por estar centradas a nivel europeo, coherente con el ámbito del proyecto SOB4ES:
- *Google Earth Engine (GEE)#sub([@googleEarthEngine]):* elegido como fuente de imágenes satelitales (Sentinel-2) frente a otras alternativas por los siguientes motivos:
  - Su acceso es gratuito para actividades de investigación y uso no comercial.
  - Presenta un catálogo de más de 900 datasets públicos, entre ellos Sentinel-2 ya en formato Level-2A (reflectancia de superficie, con corrección atmosférica aplicada), listo para el análisis sin necesidad de descargar los archivos ni de realizar preprocesamiento en local.
  - Tiene integración con la API oficial de Python a través de la librería earthengine-api, que permite ejecutar el procesamiento geoespacial directamente sobre la infraestructura de Google en vez de tener que hacerlo en local.
  
  #colbreak()

- *Copernicus Climate Data Store (CDS)#sub([@climateDataStore]):* elegido como fuente de datos de reanálisis climático (ERA5) por los siguientes motivos:
  - Su cobertura europea es consistente con el ámbito del proyecto SOB4ES.
  - Dispone de un cliente oficial en Python mediante la librería cdsapi, que se configura con un token de acceso personal y permite la automatización de las descargas directamente desde los scripts de Python.
  - Es un servicio gratuito tras el registro en la plataforma y proporciona los datos en formatos estándar (NetCDF/GRIB), que cuentan con librerías maduras para procesarlos con facilidad dentro de Python.
- *Copernicus DEM#sub([@copernicusDEM]):* elegido para la obtención del modelo de elevación digital por los siguientes motivos:  
  - Ofrece resolución de 30 metros a escala global (GLO-30), distribuida como _Cloud Optimized GeoTIFF_ y disponible de forma gratuita al público general.
  - Conexión mediante un bucket público de AWS S3, sin necesidad de autenticación ni registro previo.
  - La estructura del servidor de AWS S3 simplifica notablemente la integración en el flujo de trabajo, en comparación con otras fuentes de DEM que exigen credenciales o portales de descarga manual.

=== Programas de redacción y documentación <programas-de-redaccion-y-documentacion>

Para la redacción de la memoria y la gestión de las referencias bibliográficas de este TFG se han empleado las siguientes herramientas:
- *Google Docs#sub([@googleDocsWikipedia]):* programa de redacción de documentos de texto online, empleado para redactar una versión preliminar (borrador) de la memoria. Se eligió por facilitar el trabajo colaborativo y las revisiones del borrador en las reuniones con los tutores (véase #link(<seguimiento>)[*Seguimiento*]): la herramienta de comentarios permite señalar directamente sobre el texto qué partes corregir y en qué aspectos mejorar.
- *Typst#sub([@typstHomepage]):* herramienta de redacción de documentos técnicos, similar y compatible con LaTeX. Existe tanto en versión web como mediante un plugin de compilación local, empleado en este trabajo para la maquetación de la versión final del documento a partir del borrador redactado en Google Docs.
- *Scribbr#sub([@scribbrCitationGenerator]):* empleado para la generación del formato de citas y referencias bibliográficas siguiendo el estándar IEEE. Se eligió por su facilidad de uso, al disponer de un generador de citas accesible desde el navegador que agiliza la organización de las fuentes consultadas mientras se redacta el borrador de la memoria.

=== Programas de desarrollo de código <programas-de-desarrollo-de-codigo>

Para el desarrollo de los notebooks, como también de script de automatización para la ejecución de los mismos (véase ) se ha trabajado alternando entre *Visual Studio Code (VSCode)#sub([@vscode])* y *OpenCode#sub([@vscodeOSS])* según la máquina empleada.

Esta alternancia responde a haber trabajo desde distintos equipos a lo largo del desarrollo del TFG, para lo cual ambos IDEs ofrecen una experiencia equivalente y compatible con el resto del entorno (python, terminal y git), permitiendo continuar el trabajo indistintamente desde cualquiera de las máquinas empleadas.

#colbreak()

=== Programas de creación de diagramas e ilustraciones <programas-de-creacion-de-diagramas-e-ilustraciones>

*Diagramas de Gantt:*
- *gantt-web#sub([@ganttWeb]):* Herramienta ligera disponible en GitHub, desarrollada específicamente para la creación del diagramas de Gantt, se optó por el desarrollo de una herramienta externa a emplear las ya existentes al no ajustarse a los estilos y diseños deseados para la representación de la planificación de este TFG.

El resto de diagramas/gráficas se han hecho con las siguientes herramientas:
- *draw.io#sub([@drawio]):* Herramienta de acceso gratuito y online de creación de diagramas. Ofrece soporte nativo para la exportación de imágenes y fue seleccionado por su facilidad de acceso e intuitividad a la hora de crear todos los diagramas de este TFG.
- Las gráficas de carácter analítico se han generado de forma programática con *Matplotlib#sub([@matplotlib])* y *seaborn#sub([@seabornDocs, @waskomSeaborn])*las mismas librerías empleadas dentro de la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*]. Frente a una gráfica de creación de diagramas manuales, el uso de estas librerías permite generar gráficas directamente a partir de los resultados numéricos que se obtienen en los modelos, garantizando la reproducibilidad y evitando errores de transcripción al representarlos.
