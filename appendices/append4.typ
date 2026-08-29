== Scripts y notebooks auxiliares (Anexo IV) <elementos-auxiliares>

En este anexo se muestra el código de todos los scripts y notebooks auxiliares empleados para la facilitación de las tareas de ejecución y comparación de resultados.

=== Script de automatización de notebooks <autom-notebooks>

#show raw.where(block: true): set text(size: 7.5pt)

```python
"""
Ejecuta de principio a fin varios notebooks (todos los .ipynb de una carpeta, o los
que le indiques) y deja constancia de si cada uno termino bien o fallo.

Que hace por cada notebook:
  1. Ejecuta todas las celdas en orden (jupyter nbconvert --execute --inplace), sin
     limite de tiempo por celda.
  2. Guarda el resultado sobre el propio notebook (con las tablas/graficas ya
     generadas dentro).
  3. Si un notebook falla (una celda lanza una excepcion), no interrumpe el resto:
     sigue con el siguiente y lo apunta en el resumen final (output/report/resumen_ejecucion.txt).
  4. Si termino bien, hace commit del notebook con git automaticamente.
     Usa --no-git para desactivar esto.

Uso:
    python ejecutar_pruebas.py
        -> ejecuta TODOS los .ipynb del directorio actual (no busca en subcarpetas)

    python ejecutar_pruebas.py --recursive
        -> ejecuta TODOS los .ipynb del directorio actual y sus subcarpetas

    python ejecutar_pruebas.py prueba4_ensamblado_corregido.ipynb prueba5_ensamblado_stacking.ipynb
        -> ejecuta solo los notebooks que le pases (ignora --pattern/--recursive)

    python ejecutar_pruebas.py --pattern "prueba*.ipynb"
        -> vuelve al comportamiento anterior: solo los que empiecen por "prueba"

Requisitos: jupyter y nbconvert instalados (pip install jupyter nbconvert ipykernel),
y el kernel de Python que usan los notebooks disponible (el que se ve en
"kernelspec" -> "name" dentro del .ipynb; por defecto "python3").

AVISO: al ejecutar in-place, el notebook original se sobreescribe con los resultados
de la ejecucion. Si quieres conservar el original sin ejecutar, haz una copia antes.
"""

import argparse
import subprocess
import sys
import time
from pathlib import Path

def buscar_notebooks(directorio: Path, pattern: str, recursive: bool) -> list:
    """Busca notebooks segun el patron."""
    buscador = directorio.rglob(pattern) if recursive else directorio.glob(pattern)
    return sorted(buscador)


def ejecutar_notebook(nb_path: Path) -> dict:
    """Ejecuta un notebook de principio a fin, sobreescribiendolo con el resultado,
    y devuelve un resumen. No aplica timeout: cada celda puede tardar lo que
    necesite."""
    inicio = time.time()
    cmd = [
        sys.executable, "-m", "jupyter", "nbconvert",
        "--to", "notebook",
        "--execute",
        "--inplace",
        "--ExecutePreprocessor.timeout=-1",
        str(nb_path),
    ]
    resultado = subprocess.run(cmd, capture_output=True, text=True)
    duracion = time.time() - inicio

    ok = resultado.returncode == 0

    return {
        "notebook": nb_path.name,
        "ok": ok,
        "duracion_s": round(duracion, 1),
        "error": None if ok else _extraer_error(resultado.stderr),
    }

def _extraer_error(stderr: str) -> str:
    """Se queda con las ultimas lineas del stderr, que suelen tener el traceback util
    (el principio de la salida de nbconvert suele ser solo progreso, no el error)."""
    lineas = [l for l in stderr.strip().split("\n") if l.strip()]
    return "\n".join(lineas[-15:]) if lineas else "Error desconocido (nbconvert no genero stderr)."

def git_commit(paths: list, mensaje: str) -> bool:
    """Hace 'git add' de los paths indicados y un commit con el mensaje dado.
    Devuelve True si el commit se creo, False si fallo o no habia nada que commitear
    (por ejemplo, si el notebook ya estaba igual que en el ultimo commit)."""
    paths_str = [str(p) for p in paths if p is not None]
    if not paths_str:
        return False

    add = subprocess.run(["git", "add", *paths_str], capture_output=True, text=True)
    if add.returncode != 0:
        print(f"      [git] fallo 'git add': {add.stderr.strip()}")
        return False

    commit = subprocess.run(
        ["git", "commit", "-m", mensaje], capture_output=True, text=True
    )
    if commit.returncode != 0:
        # Suele ser porque no hay cambios que commitear; no es un error grave.
        if "nothing to commit" in commit.stdout.lower():
            return False
        print(f"      [git] fallo 'git commit': {commit.stdout.strip()} {commit.stderr.strip()}")
        return False

    return True

def main():
    parser = argparse.ArgumentParser(
        description="Ejecuta notebooks Jupyter de principio a fin, uno detras de otro."
    )
    parser.add_argument(
        "notebooks", nargs="*",
        help="Notebooks a ejecutar. Si no se indica ninguno, se buscan con --pattern.",
    )
    parser.add_argument(
        "--pattern", default="*.ipynb",
        help="Patron para buscar notebooks si no se pasan explicitamente (default: *.ipynb, es decir, todos)",
    )
    parser.add_argument(
        "--recursive", action="store_true",
        help="Busca tambien en subcarpetas (por defecto solo mira el directorio actual)",
    )
    parser.add_argument(
        "--no-git", action="store_true",
        help="No hace commit automatico tras cada notebook (por defecto SI se commitea)",
    )
    args = parser.parse_args()

    if args.notebooks:
        notebooks = [Path(n) for n in args.notebooks]
        notebooks_existentes = [nb for nb in notebooks if nb.exists()]
        notebooks_faltantes = [nb for nb in notebooks if not nb.exists()]
        for nb in notebooks_faltantes:
            print(f"[AVISO] No existe: {nb} (se omite)")
    else:
        notebooks_existentes = buscar_notebooks(Path("."), args.pattern, args.recursive)

    if not notebooks_existentes:
        print(f"No se encontro ningun notebook (patron: {args.pattern}, recursive={args.recursive}). "
              f"Nada que ejecutar.")
        sys.exit(1)

    print(f"Ejecutando {len(notebooks_existentes)} notebook(s) in-place, sin timeout...\n")

    resultados = []
    for nb_path in notebooks_existentes:
        print(f"-> {nb_path.name} ...", end=" ", flush=True)
        r = ejecutar_notebook(nb_path)
        resultados.append(r)
        if r["ok"]:
            print(f"OK ({r['duracion_s']}s)")
            if not args.no_git:
                mensaje = f"[executor.py] Executed {nb_path.name} without issues. Elapsed time ({r['duracion_s']}s...)"
                if git_commit([nb_path], mensaje):
                    print(f"      [git] commit: {mensaje}")
                else:
                    print("      [git] sin cambios que commitear")
        else:
            print(f"FALLO ({r['duracion_s']}s)")

    print("\n" + "=" * 70)
    print("RESUMEN")
    print("=" * 70)
    for r in resultados:
        estado = "OK   " if r["ok"] else "FALLO"
        print(f"{estado} | {r['notebook']:45s} | {r['duracion_s']:6.1f}s")
        if not r["ok"]:
            print("      " + r["error"].replace("\n", "\n      "))

    resumen_dir = Path("output") / "report"
    resumen_dir.mkdir(parents=True, exist_ok=True)
    resumen_path = resumen_dir / "resumen_ejecucion.txt"
    with open(resumen_path, "w", encoding="utf-8") as f:
        for r in resultados:
            estado = "OK" if r["ok"] else "FALLO"
            f.write(f"{estado} | {r['notebook']} | {r['duracion_s']}s\n")
            if not r["ok"]:
                f.write(r["error"] + "\n")
            f.write("-" * 70 + "\n")
    print(f"\nResumen guardado en {resumen_path}")

    n_fallos = sum(1 for r in resultados if not r["ok"])
    if n_fallos:
        print(f"\n{n_fallos} de {len(resultados)} notebook(s) fallaron.")
    sys.exit(1 if n_fallos else 0)

if __name__ == "__main__":
    main()

```

El objetivo princial de este script es el de automatizar la ejecución de todos los notebooks (o los que se indiquen) localizados dentro de una misma rama, permitiendo así no tener que ejecutarlos uno a uno.

#colbreak()

El script también cuenta con las siguentes capacidades:
+ Capacidad de hacer commits en local al terminar de ejecutar correctamente cada notebook.
+ Al final de la ejecución de cada notebook genera un archivo de texto en el que se muestra si en alguno de los notebooks hubo algún error o no.
+ En caso de que ocurra un error en uno de los notebooks, se registra para añadirlo en el reporte final (archivo de texto) y se sigue con el siguiente notebook, es decir, la ejecución de los notebooks no se para en el caso de que uno de los notebooks a ejecutar devuelve un error.
+ Si hay un notebook que no exista dentro de la rama en la que se ejecuta, el script lo omite y ejecuta los que se haya indicado.

=== Script de automatización general <autom-general>

```bash
echo "AUTOMATED WORK STARTED DO NOT TOUCH"

# O nombre de la carpeta/repositorio (se ejecuta desde la carpeta anterior al repositorio)
cd TFG-SOB4ES

# Creamos un array con las ramas, aqui se ponen las ramas que se quieren ejecutar
ramas = ("model-prep" "model-prep-var" "model-prep-var-1" "model-prep-var-2" "model-prep-var-3" "model-prep-var-1-2" "model-prep-var-1-3" "model-prep-var-2-3" "model-prep-var-1-2-3" "model-prep-rs" "model-prep-rs-1" "model-prep-rs-group" "model-prep-rs-group-1" "model-prep-mixin" "model-prep-mixin-1")

# Recorrer el array
for rama in "${ramas[@]}"; do
    echo "In branch $rama ..."
    git stash
    git fetch
    git pull

    # Se ponen los nombres de los notebooks a ejecutar
    python executor.py reg_model.ipynb rf_model.ipynb #... y así sucesivamente
    
    # cuando se terminan de ejecutar los notebooks se les hace el commit y se suben a remoto
    git add *
    git commit -m "[exec.sh] Executed all models from $rama ..."
    # Esto solo funciona si se ejecuta dentro de una IDE con las credenciales de GitHub cargadas
    git push
done

git switch model-prep # o la rama en la que se quiera dejar post ejecución

echo "Trabajo terminado..."
```

Este script permite la automatización de la ejecución de todos los notebooks o de los notebooks indicados dentro de distintas ramas.

El script cuenta con las siguentes capacidades:
+ Capacidad de realizar commits en local y subirlos a remoto cuando se completa la ejecución de una rama completa. Esto es si se ejecuta dentro de un IDE con el plugin de GitHub instalado, en caso contrario subir a remoto va a ser imposible.
+ Capacidad de saltar entre ramas del mismo repositorio y actualizarlas en el caso de que haya commits previos.

#rect[
  *Nota:* Si se crean conflictos a partir de la recuperación de commits en remoto, el script no podrá hacer nada.\ El script no tiene la capacidad de resolver conflictos ni hacer merges a las branches remotas debido a que es una tarea que debería de ser realizada por un humano no un script.
]

=== Notebook de división de datos <data-div-notebook>

==== Fundamento y configuración

Una vez `data-prep`, `data-prep-online` y `data-prep-combination` (véase #link(<notebooks-empleados>)[*Anexo III*]) generan el dataset final armonizado (`sob4es_final_model_ready.csv`), este notebook es responsable de dividirlo en los tres subconjuntos empleados por el resto del proyecto: *entrenamiento, test y evaluación*. Es, por tanto, el último eslabón de la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*] antes de entrar en la #link(<capa-modelado>)[*Capa de modelado predictivo*].

El dataset de entrada contiene 428 filas y 71 columnas, sin ningún valor nulo. La partición se configura con `TEST_SIZE=0.30` (fracción reservada para test+eval conjuntamente), `EVAL_FRAC=0.50` (mitad de esa reserva para eval, mitad para test) y `RANDOM_SEED=42`.

==== Metodología

La partición se realiza en dos pasos sucesivos con `train_test_split` de `scikit-learn`, estratificando por país de origen de la muestra (extraído del prefijo de `site_id`, por ejemplo BE, IL, RO) para asegurar que los tres subconjuntos mantengan una representación proporcional de cada país. 

Italia (IT), con solo 2 filas en todo el dataset, se agrupa con Alemania (DE) únicamente a efectos de estratificación, al no ser posible estratificar un país con menos de 2 muestras por split.

Las particiones resultantes son las siguientes:
- *Primera partición:* train (70%) frente a un conjunto temporal (temp, 30%).
- *Segunda partición:* temp se divide a su vez al 50% entre test y eval.

Tras la partición se verifica que la proporción de `outlier_flag` (una bandera de calidad de dato ya calculada en fases anteriores) se mantiene similar entre los tres subconjuntos, como comprobación adicional de que la partición no ha introducido un sesgo de calidad entre splits.

==== Resultados

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto), 
            align: (center, center, center), 
            fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
            table.header([*Subconjunto*], [*Filas*], [*% del total*]), 
                [*`train.csv`*], [299], [69.9%],
                [*`test.csv`*],  [64],  [15.0%], 
                [*`eval.csv`*],  [65],  [15.2%] 
        )
    ],
    caption: [Subconjuntos resultantes de la división del dataset original.]
)

La distribución de `outlier_flag` se mantiene prácticamente idéntica entre subconjuntos, confirmando que la estratificación por país no ha desequilibrado esta variable de calidad. De igual forma, la proporción de muestras por país se mantiene estable en los tres splits, con la única excepción esperable de Italia, cuyas 2 únicas muestras se reparten una a test y otra a eval, sin ninguna en train.

#figure(
    align(center)[
        #image("../media/pie-chart-data.png", height: 20%)
    ],
    caption: [División de los datos, estratificado por país.],
    kind: image
)

#let file = "../media/anexos/data-prep-div.pdf"
#let total_pages = 3 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebooks para la comparación de modelos <model-comp>

==== Comparador de regresión <reg-comp>

===== Fundamento y configuración

Este es el notebook central de la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*] desde el punto de vista numérico. 

Carga los `.pkl` de los ocho modelos ya entrenados y produce, además de la comparación de `R²/RMSE/MAE` ya vista en el #link(<modelos-empleados>)[*Anexo II*], un score compuesto que combina el rendimiento de regresión con una discretización de las predicciones en tres niveles ordinales.

===== Metodología

Para cada uno de los 21 targets, se calculan los umbrales del percentil 33 y 66 sobre la unión de `train.csv + eval.csv`, y se discretiza tanto la predicción como el valor real en tres niveles (Bajo/Medio/Alto). Sobre esa discretización se calculan precision, recall y f1-score para cada modelo. El score compuesto de cada modelo se define como:

$ "Score" = frac(max(0, R^2) + "Precisión" + "Recall" + "F1"_"macro", 4) $

El R² se recorta a 0 en caso de ser negativo (max(0, R²)) para evitar que los targets con peor ajuste distorsionen la escala 0-1 compartida con el resto de métricas, todas ellas ya acotadas entre 0 y 1 por construcción.

===== Resultados

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto, auto), 
            align: (center, center, center, center, center, center), 
            fill: (col, row) => if row == 0 { rgb("d6e3da") }, 
            table.header([*Puesto*], [*Modelo*], [*Score compuesto*], [*R²*], [*Precisión*], [*Recall*]), 
                [*1*], [*XGBoost multisalida*], [0.3549], [0.0835], [0.4664], [0.4598], 
                [*2*], [*RegressorChain*], [0.3263], [0.0809], [0.4433], [0.4246], 
                [*3*], [*MLP pérdida personalizada*], [0.3248], [-0.1316], [0.4911], [0.4292], 
                [*4*], [*Random Forest*], [0.3169], [0.0904], [0.4125], [0.4203], 
                [*5*], [*XGBoost*], [0.3044], [0.0670], [0.3894], [0.4198], 
                [*6*], [*MLP multisalida*], [0.3017], [-0.0380], [0.4213], [0.4253], 
                [*7*], [*Random Forest multisalida*], [0.2968], [0.0964], [0.3834], [0.4073], 
                [*8*], [*Ridge*], [0.2706], [-0.0164], [0.3839], [0.3952], )
    ],
    caption: [Ranking final del comparador de modelos de regresión.],
    kind: table
)

#figure(
    align(center)[
        #image("../media/box-plot-1.png", height: 27.5%)
    ],
    caption: [Resultados gráficos del comparador de modelos de regresión.],
    kind: image
)

#let file = "../media/anexos/comparador_modelos.pdf"
#let total_pages = 14 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

==== Comparador de clasificación <clas-comp>

===== Fundamento y configuración

Complementa al notebook anterior desde el punto de vista puramente ordinal: en vez de un score compuesto que mezcla regresión y clasificación, aquí se reportan directamente las métricas de clasificación estándar descritas en la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*] y explicadas en #link(<metricas-clasificacion>)[*Métricas de clasificación*] (Accuracy, Kappa de Cohen y F1-macro) sobre la misma discretización en tres niveles (Bajo/Medio/Alto) usada por `comparador_modelos`.

===== Metodología

Idéntica discretización por terciles (percentiles 33/66 sobre train+eval) que en `comparador_modelos`, pero aquí las métricas se calculan y reportan de forma independiente, sin combinarlas en un único score, y además se desglosan por cada uno de los 21 targets (no solo a nivel global), lo que permite identificar en qué grupos taxonómicos concretos destaca o falla cada modelo.

===== Resultados

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto, auto), 
            align: (center, center, center, center, center, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header([*Puesto (por R²)*], [*Modelo*], [*R²*], [*Accuracy*], [*Kappa*], [*F1*]), 
                [*1*], [*RF Multisalida*], [0.0964], [0.3824], [0.1331], [0.3002], 
                [*2*], [*RF Individual*], [0.0904], [0.3971], [0.1644], [0.3443], 
                [*3*], [*XGBoost Multisalida*], [0.0835], [0.4403], [0.2341], [0.4101], 
                [*4*], [*RegressorChain*], [0.0809], [0.4022], [0.1827], [0.3564], 
                [*5*], [*XGBoost Individual*], [0.0670], [0.3978], [0.1576], [0.3413], 
                [*6*], [*Ridge*], [-0.0164], [0.3744], [0.1124], [0.3034], 
                [*7*], [*MLP Estándar*], [-0.0380], [0.4037], [0.1726], [0.3603], 
                [*8*], [*MLP Custom*], [-0.1316], [0.4103], [0.1864], [0.3789] 
        )
    ],
    caption: [Ranking final del comparador de modelos de clasificación.],
    kind: table
)

El propio notebook resume el resultado de forma explícita: 
- *Mejor modelo por R²:* RF Multisalida. 
- *Mejor modelo por Kappa:* XGBoost Multisalida.
- *Mejor modelo por F1-macro:* XGBoost Multisalida. 

XGBoost multisalida no tiene el mejor R² medio, pero sí el mejor Kappa (0.234, el único por encima de 0.2, el resto se mueven entre 0.11 y 0.19, un nivel de acuerdo "leve" según la escala habitual de interpretación de Kappa) y el mejor F1-macro con una diferencia notable sobre el resto (0.410 frente a 0.36 del segundo mejor).

#colbreak()

Sobre el desglose por target destaca que, incluso para el target más problemático de todo el trabajo (`coll_species_richness_z`, con R² negativo en los ocho modelos), varios modelos logran un Kappa positivo pequeño, lo que indica que, aunque ningún modelo predice bien el valor continuo exacto de este target, algunos sí consiguen distinguir con un acuerdo por encima del azar entre sus niveles Bajo/Medio/Alto.

#figure(
    align(center)[
        #image("../media/box-conf-1.png")
    ],
    caption: [Matrices de confusión.],
    kind: image
)

#let file = "../media/anexos/comparador_clasificacion.pdf"
#let total_pages = 10 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

==== Comparador entre ramas <branch-comp>

==== Fundamento y configuración

A diferencia del resto de notebooks de este anexo, `extractor_resultados` no es un análisis en sí mismo sino una herramienta reutilizable que automatiza la extracción de métricas (`R²`, `RMSE`, `MAE`, `random_state`, `número de variables activas`) directamente desde el contenido de los notebooks tal y como están guardados en una rama concreta de git, sin necesidad de hacer checkout de esa rama ni de reejecutar ningún notebook. Se apoya en git show <rama>:<archivo> para leer el JSON de cada `.ipynb` de forma aislada.

==== Metodología

Dado un `GIT_REPO_PATH` y una lista de ramas a comparar (`BRANCHES` para la prueba de eliminación de variables, `BRANCHES_BARRIDO` para la de barrido de random_state), el notebook, para cada combinación de rama y notebook de modelo:

+ Localiza el bloque de texto que sigue al marcador "Evaluacion final sobre eval.csv" dentro de las celdas de salida, y extrae mediante expresiones regulares el `R²`, `RMSE` y `MAE` de cada uno de los 21 targets.
+ Extrae la lista de variables activas de `FEATURES_AUTORIZADAS` (distinguiendo las comentadas, es decir, excluidas, de las activas), para verificar que el número de columnas de `X_train` es coherente con lo esperado en cada prueba.
+ Extrae el random_state empleado, buscando primero una constante `RANDOM_STATE = N` y, si no existe, la primera aparición de `random_state=N` en el código.
+ Ejecuta un conjunto de validaciones automáticas: 
    + Comprueba que el número de variables no cambia entre ramas cuando la prueba en cuestión no debería eliminar ninguna. 
    + que las celdas se ejecutaron en orden (execution_count creciente, para detectar resultados obsoletos de una reejecución parcial)
    + que todos los notebooks de una misma rama comparten el mismo random_state
    + que el random_state coincide con el que sugiere el propio nombre de la rama (por ejemplo, que model-prep-rs-group-1 no use por error el mismo random_state que model-prep-rs-group)
    + y que el R² de los targets prioritarios no sea sospechosamente idéntico entre dos ramas que deberían ser distintas (señal de que una rama no se reejecutó realmente).

// TODO: acabar de corregir la redacción

==== Resultados

Al tratarse de una herramienta y no de un análisis con una conclusión propia, sus "resultados" son las propias comprobaciones de calidad que realiza sobre el resto de pruebas del proyecto. En la ejecución registrada en este notebook (limitada a la rama model-prep-var), ninguna validación automática señaló avisos: los 8 notebooks de modelos se leyeron correctamente vía git, el random_state fue consistente (42) en los 8, y las métricas extraídas coinciden exactamente con las reportadas de forma individual en cada notebook de entrenamiento (por ejemplo, rf_model.ipynb: R² global 0.0904, R² earthworm_shannon_z 0.5041 -- idénticas a las del Anexo III), lo que sirve como verificación cruzada independiente de que los resultados reportados en este documento no se han alterado entre la ejecución original del notebook y su lectura posterior vía git.

// TODO: ejecutar y documentar aquí el resultado de extractor_resultados sobre las ramas completas de la prueba de eliminación de variables (model-prep-var-1 a model-prep-var-1-2-3) y de barrido de random_state, que es para lo que la herramienta está realmente pensada.

#let file = "../media/anexos/extractor_resultados.pdf"
#let total_pages = 15
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebook para la comparación de variables (Prueba I) <notebook-p1>

===== Fundamento y configuración

Cada notebook de modelado dentro de la primera prueba (véase #link(<prueba-1>)[*Eliminación de variables*]) exporta, como parte de su análisis de explicabilidad, un archivo `variables_menos_relevantes_<modelo>.csv` con las 10 variables que ese modelo concreto considera menos influyentes (el "bottom-10"). 

Este notebook carga los ocho archivos, uno por modelo, y calcula un consenso sobre qué variables aparecen recurrentemente como poco relevantes independientemente del modelo empleado, con el objetivo de fundamentar la selección de variables a eliminar en la #link(<prueba-1>)[*Eliminación de variables*].

===== Metodología

Para cada variable que aparece en al menos un `bottom-10`, se calcula su frecuencia (en cuántos de los 8 modelos aparece) y su posición media dentro del `bottom-10` (1 = la variable considerada menos relevante de todas, 10 = la décima menos relevante). 

El ranking final se ordena primero por frecuencia (descendente) y, en caso de empate, por posición media (ascendente, priorizando las que son consistentemente de las peores). Se establece como "candidata fuerte a eliminar" cualquier variable que aparezca en al menos la mitad de los modelos utilizables $("umbral" max(2, ("n_modelos"+1)div 2)$, es decir, 4 de 8 en este caso).

===== Resultados

Los 8 archivos de variables (uno por modelo) se cargaron correctamente, sin ningún archivo no utilizable. El ranking de consenso resultante fue:

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto), 
            align: (left+horizon, center+horizon, center+horizon, left), 
            fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
            table.header([*Variable*], [*Frecuencia*], [*Posición media*], [*Modelos*]), 
                [*cu_z*], [8/8], [4.9], [Todos], 
                [*ni_z*], [7/8], [4.4], [Todos salvo RegressorChain], 
                [*dem_orientacion_deg_z*], [6/8], [6.8], [MLP Custom, RF Multi, RF, RegressorChain, Ridge, XGBoost], 
                [*mo_z*], [5/8], [5.0], [MLP Multi, RF Multi, RF, RegressorChain, Ridge], 
                [*eu_sand_content_z*], [5/8], [5.6], [MLP Multi, MLP Custom, Ridge, XGB Multi, XGBoost], 
                [*plot_total_organic_c_z*], [5/8], [5.6], [MLP Multi, MLP Custom, RF Multi, Ridge, XGBoost], 
                [*total_plant_cover_z*], [4/8], [3.0], [RF Multi, RF, RegressorChain, XGB Multi], 
                [*as_z*], [4/8], [5.0], [MLP Multi, MLP Custom, RF, Ridge], 
                [*dem_pendiente_deg_z*], [4/8], [6.0], [RF Multi, RF, RegressorChain, XGBoost], )
    ],
    caption: [Ranking de variables menos relevantes.],
    kind: table
)

*`cu_z`* (cobre) aparece en el bottom-10 de los 8/8 modelos, y `ni_z` (níquel) en 7/8, siendo las dos candidatas más consistentes de todo el ranking; ambas coinciden, además, con dos de las tres variables efectivamente probadas en el #link(<prueba-1>)[*Eliminación de variables*] (`cu_z`, `ni_z`, `mo_z`). 

La tercera variable de esa prueba, `mo_z`, aparece también entre las candidatas fuertes (5/8, posición media 5.0), aunque por detrás de `dem_orientacion_deg_z` (6/8), que no llegó a probarse pese a tener mayor consenso.

#figure(
    align(center)[
        #image("../media/barras-frec.png", height: 40%)
    ],
    caption: [Gráfico de barras de la frecuencia de los modelos menos relevantes.],
    kind: image
)

#figure(
    align(center)[
        #image("../media/heat-frec.png", height: 40%)
    ],
    caption: [_Heatmap_ de la frecuencia de los modelos menos relevantes.],
    kind: image
)

#let file = "../media/anexos/comparador_variables.pdf"
#let total_pages = 6 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebook para la comparación de barrido de rs (Prueba III) <notebook-p3>

==== Fundamento y configuración

Todas las comparativas anteriores se basan en una única semilla de entrenamiento (random_state=42). Este notebook responde a la pregunta de si el ranking de modelos se mantiene estable al cambiar la semilla, cargando los resultados de la #link(<prueba-3>)[*Barrido de random_state*]: un barrido de 101 semillas (random_state de 0 a 100) para cada uno de los 8 modelos, calculado sobre los dos targets prioritarios.

#rect[
    *Nota:*\
    El notebook exportado forma parte de la primera iteración de la #link(<prueba-3>)[*Prueba de barrido de random_state*], la segunda iteración genera más modelos.
]

==== Metodología

Para cada semilla y modelo se calcula `r2_medio_prioritarios`, la media del R² sobre `earthworm_shannon_z` y `earthworm_richness_z`. Con las $101 times 8 = 808$ combinaciones resultantes se construye, para cada semilla, un ranking de los 8 modelos (posición 1 = mejor R² medio de esa semilla), y se agregan estadísticos de estabilidad: media, desviación estándar, mínimo, máximo y el porcentaje de semillas en las que cada modelo queda dentro del top-1, top-2, top-3 y top-5.

==== Resultados

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto), 
            align: (left, center, center, center, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header([*Modelo*], [*R² medio (101 semillas)*], [*Desv. estándar*], [*% en top-1*], [*% en top-3*]), 
                [*XGBoost Multisalida*], [0.5605], [0.0076], [100.0%], [100.0%], 
                [*RF Individual*], [0.5316], [0.0074], [0.0%], [100.0%], 
                [*RegressorChain*], [0.5030], [0.0111], [0.0%], [100.0%], 
                [*RandomForest Multisalida*], [0.4317], [0.0086], [0.0%], [0.0%], 
                [*XGBoost Individual*], [0.4397], [0.0000], [0.0%], [0.0%], 
                [*MLP Estándar*], [0.3903], [0.0330], [0.0%], [0.0%], 
                [*MLP Pérdida Custom*], [0.3677], [0.0422], [0.0%], [0.0%], 
                [*Regresión Individual*], [0.2592], [0.0000], [0.0%], [0.0%]
            )
    ]
)

Este es, de todos los análisis de este anexo, el que ofrece la evidencia más contundente: XGBoost multisalida queda en primera posición en las 101 de 101 semillas evaluadas (100%), sobre el R² medio de los dos targets prioritarios. 

Le siguen, siempre dentro del top-3 (aunque nunca del top-1), Random Forest individual y RegressorChain. 

La desviación estándar de XGBoost multisalida (0.0076) es además una de las más bajas del conjunto, lo que indica que su ventaja no solo es consistente en ranking sino también estable en magnitud, sin depender de haber tenido "suerte" con la semilla 42 usada en el resto de anexos.

Nótese que Ridge y XGBoost Individual muestran una desviación estándar de 0.0000: al ser modelos deterministas frente a la semilla de partición de datos en esta prueba concreta (la búsqueda de hiperparámetros no se repite por semilla en el barrido), su R² no varía entre iteraciones.

// TODO: insertar aquí los 4 gráficos (boxplot de dispersión y barras de frecuencia top-1/2/3/5) generados en comparador_barrido_rs.ipynb

#let file = "../media/anexos/comparador_barrido_rs.pdf"
#let total_pages = 6 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebooks para la prueba de ensamblado (Prueba IV) <notebooks-p4>

==== Notebook de ensamblado de predicciones sin meta-modelos (Prueba IV.I) <notebook-p4-1>

==== Fundamento y configuración

Este notebook explora si combinar las predicciones de los ocho modelos base, mediante métodos de combinación fijos y predefinidos (sin entrenar ningún modelo adicional sobre ellas), mejora el resultado obtenido por el mejor modelo individual. Corresponde a la rama model-prep-mixin (véase Anexo VI).

==== Metodología

Sobre las 65 filas de eval.csv, se reserva un subconjunto de calibración (meta-train, 45 filas) para calcular los pesos de las combinaciones que los necesitan, y un subconjunto de holdout (20 filas) sobre el que se evalúa el resultado final, evitando así que la propia combinación se beneficie de haber "visto" los datos con los que se evalúa. Se prueban cinco métodos de combinación, por cada uno de los 21 targets:

Media simple: promedio aritmético de las predicciones de los 8 modelos.
Media ponderada por R²: cada modelo pesa en proporción a su R² en meta-train (recortado a 0 si es negativo).
Top-k: promedio simple de únicamente los k modelos con mejor R² en meta-train.
Mediana: mediana de las 8 predicciones, más robusta frente a un modelo con una predicción muy desviada.
Stacking convexo: pesos 
wi>=0
w
i
	​

>=0 con 
sumwi=1
sumw
i
	​

=1 que minimizan el MSE en meta-train, obtenidos mediante optimización numérica (scipy.optimize.minimize, método SLSQP).

==== Resultados

#table( columns: (auto, auto), align: (left, center), fill: (col, row) => if row == 0 { rgb("d6e3da") }, table.header([Métrica], [Valor]), [Targets evaluados], [21], [Targets donde alguna combinación supera al mejor modelo individual], [4/21 (19%)], [Targets con señal predictiva real (mejor R² > 0)], [15/21 (71%)], [Targets sin señal predictiva en ningún método], [6/21], )

El resultado es mayoritariamente negativo para este enfoque: en 4 de cada 5 targets, ninguno de los cinco métodos de combinación fijos mejora sobre el mejor modelo individual disponible para ese target concreto. Esto sugiere que, con el tamaño de holdout disponible (20 filas), los pesos calculados en meta-train no generalizan lo suficientemente bien como para superar de forma consistente a simplemente elegir el mejor modelo individual -- un resultado que motiva directamente la variante explorada en el siguiente notebook, que sustituye estos métodos fijos por meta-modelos entrenados.

#let file = "../media/anexos/prueba_ensamblado.pdf"
#let total_pages = 15 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

==== Notebook de ensamblado de predicciones con meta-modelos (Prueba IV.II) <notebook-p4-2>

==== Fundamento y configuración

Extiende la idea del notebook anterior sustituyendo los métodos de combinación fijos por meta-modelos entrenados: en vez de calcular unos pesos con una fórmula cerrada, se entrena un modelo de regresión adicional cuya entrada son las predicciones de los 8 modelos base, y cuya salida es la predicción combinada final. Corresponde a la rama model-prep-mixin-1 (véase Anexo VI), en la que -- a diferencia de model-prep-mixin -- se prueba con la totalidad de los 21 targets.

==== Metodología

Se emplea la misma partición meta-train (45 filas) / holdout (20 filas) que en el notebook anterior. Sobre meta-train se entrenan cinco meta-modelos candidatos por cada target: Ridge, Lasso, ElasticNet, Regresión Lineal y Random Forest, todos ellos de scikit-learn con su configuración por defecto salvo la regularización. Antes de evaluar cada meta-modelo sobre el holdout, se ejecuta una comprobación automática ("smoke test") que descarta cualquier predicción con valores NaN o infinitos.

==== Resultados

#table( columns: (auto, auto), align: (left, center), fill: (col, row) => if row == 0 { rgb("d6e3da") }, table.header([Métrica], [Valor]), [Targets evaluados], [21], [Targets donde algún meta-modelo/ensamblado supera al mejor individual], [9/21 (43%)], [Targets con señal predictiva real (mejor R² > 0)], [18/21 (86%)], [Targets sin señal predictiva en ningún método], [3/21], )

A diferencia de los métodos de combinación fijos del notebook anterior (19% de mejora), entrenar un meta-modelo mejora sobre el mejor individual en más del doble de targets (43%), lo que sugiere que, aunque el holdout es pequeño, un meta-modelo simple (Ridge, Lasso...) consigue capturar patrones de complementariedad entre los modelos base que un método de combinación fijo no puede aprovechar. El caso más llamativo es coll_species_richness_z -- el target con peor R² individual de todo este trabajo (-0.069 incluso para su mejor modelo individual, RF multisalida) -- donde un meta-modelo Random Forest alcanza un R²=0.523 sobre el holdout, la mejora más drástica de todo el análisis. También destaca earthworm_richness_z, uno de los targets prioritarios, donde un meta-modelo Ridge (R²=0.523) supera ligeramente al mejor modelo individual, XGBoost multisalida (R²=0.509).

// TODO: cotejar si esta mejora en targets concretos se sostiene con un holdout mayor; con solo 20 filas de evaluación, conviene tratar estos resultados como indicativos y no como una validación definitiva de la ganancia del stacking.

#let file = "../media/anexos/prueba_ensamblado_con_modelos.pdf"
#let total_pages = 16 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}