== _Scripts_ y notebooks auxiliares (Anexo IV) <elementos-auxiliares>

En este anexo se muestra el código de todos los _scripts_ y _notebooks_ auxiliares empleados para la facilitación de las tareas de ejecución y comparación de resultados.

=== _Script_ de automatización de _notebooks_ <autom-notebooks>

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

El objetivo princial de este _script_ es el de automatizar la ejecución de todos los _notebooks_ (o los que se indiquen) localizados dentro de una misma rama, permitiendo así no tener que ejecutarlos uno a uno.

#colbreak()

El _script_ también cuenta con las siguentes capacidades:
+ Capacidad de hacer _commits_ en local al terminar de ejecutar correctamente cada _notebook_.
+ Al final de la ejecución de cada _notebook_ genera un archivo de texto en el que se muestra si en alguno de los _notebooks_ hubo algún error o no.
+ En caso de que ocurra un error en uno de los _notebooks_, se registra para añadirlo en el reporte final (archivo de texto) y se sigue con el siguiente _notebook_, es decir, la ejecución de los _notebooks_ no se para en el caso de que uno de los _notebooks_ a ejecutar devuelve un error.
+ Si hay un _notebook_ que no exista dentro de la rama en la que se ejecuta, el _script_ lo omite y ejecuta los que se haya indicado y encontrado.

=== _Script_ de automatización general <autom-general>

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

Este _script_ permite la automatización de la ejecución de todos los _notebooks_ o de los _notebooks_ indicados dentro de distintas ramas.

El _script_ cuenta con las siguentes capacidades:
+ Capacidad de realizar _commits_ en local y subirlos a remoto cuando se completa la ejecución de una rama completa. Esto es si se ejecuta dentro de un IDE con el plugin de GitHub instalado, en caso contrario subir a remoto va a ser imposible.
+ Capacidad de saltar entre ramas del mismo repositorio y actualizarlas en el caso de que haya _commits_ previos.

#rect[
  *Nota:* Si se crean conflictos a partir de la recuperación de _commits_ en remoto, el _script_ no podrá hacer nada.\ El _script_ no tiene la capacidad de resolver conflictos ni hacer _merges_ a las ramas remotas debido a que es una tarea que debería de ser realizada por un humano, no un _script_.
]

=== _Notebooks_ para la comparación de modelos <model-comp>

==== Comparador de regresión <reg-comp>

===== Fundamentos y configuración

Este es el _notebook_ central de la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*] desde el punto de vista numérico. 

Carga los `.pkl` de los ocho modelos ya entrenados y produce, además de la comparación de `R²/RMSE/MAE` ya vista en el #link(<modelos-empleados>)[*Anexo II*], un score compuesto que combina el rendimiento de regresión con una discretización de las predicciones en tres niveles ordinales.

===== Metodología

Para cada uno de los 21 _targets_, se calculan los umbrales del percentil 33 y 66 sobre la unión de `train.csv + eval.csv`, y se discretiza tanto la predicción como el valor real en tres niveles (Bajo/Medio/Alto). Sobre esa discretización se calculan precision, recall y f1-score para cada modelo. El score compuesto de cada modelo se define como:

$ "Score" = frac(max(0, R^2) + "Precisión" + "Recall" + "F1"_"macro", 4) $

El R² se recorta a 0 en caso de ser negativo (max(0, R²)) para evitar que los _targets_ con peor ajuste distorsionen la escala 0-1 compartida con el resto de métricas, todas ellas ya acotadas entre 0 y 1 por construcción.

===== Resultados

En la #ref(<tab-36>) se pueden ver los resultados obtenidos por modelo tras la ejecución del comparador por regresión, dichos resultados se pueden ver de forma más gráfica con la #ref(<fig-18>).

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto, auto), 
            align: (center, center, center, center, center, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header([*Puesto*], [*Modelo*], [*Score compuesto*], [*R²*], [*Precisión*], [*Recall*]), 
                [*1*], [*XGBoost multisalida*],  [0.3549], [0.0835],  [0.4664], [0.4598], 
                [*2*], [*RegressorChain*],       [0.3263], [0.0809],  [0.4433], [0.4246], 
                [*3*], [*MLP Custom*],           [0.3248], [-0.1316], [0.4911], [0.4292], 
                [*4*], [*RF Individual*],        [0.3169], [0.0904],  [0.4125], [0.4203], 
                [*5*], [*XGBoost*],              [0.3044], [0.0670],  [0.3894], [0.4198], 
                [*6*], [*MLP multisalida*],      [0.3017], [-0.0380], [0.4213], [0.4253], 
                [*7*], [*RF multisalida*],       [0.2968], [0.0964],  [0.3834], [0.4073], 
                [*8*], [*Ridge*],                [0.2706], [-0.0164], [0.3839], [0.3952], )
    ],
    caption: [Ranking final del comparador de modelos de regresión.],
    kind: table
)<tab-36>

#figure(
    align(center)[
        #image("../media/box-plot-1.png", height: 27.5%)
    ],
    caption: [Resultados gráficos del comparador de modelos de regresión.],
    kind: image
)<fig-18>

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

===== Fundamentos y configuración

Complementa al _notebook_ anterior desde el punto de vista puramente ordinal: en vez de un score compuesto que mezcla regresión y clasificación, aquí se reportan directamente las métricas de clasificación estándar descritas en la #link(<capa-evaluacion>)[*Capa de evaluación de modelos*] y explicadas en #link(<metricas-clasificacion>)[*Métricas de clasificación*] (Accuracy, Kappa de Cohen y F1-macro) sobre la misma discretización en tres niveles (Bajo/Medio/Alto) usada por `comparador_modelos`.

===== Metodología

Idéntica discretización por terciles (percentiles 33/66 sobre train+eval) que en `comparador_modelos`, pero aquí las métricas se calculan y reportan de forma independiente, sin combinarlas en un único score, y además se desglosan por cada uno de los 21 _targets_ (no solo a nivel global), lo que permite identificar en qué grupos taxonómicos concretos destaca o falla cada modelo.

===== Resultados

En la #ref(<tab-37>) se pueden ver los resultados obtenidos tras la ejecución del comparador de clasificación.

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto, auto), 
            align: (center, center, center, center, center, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header([*Puesto (por R²)*], [*Modelo*], [*R²*], [*Accuracy*], [*Kappa*], [*F1*]), 
                [*1*], [*RF Multisalida*],      [0.0964],  [0.3824], [0.1331], [0.3002], 
                [*2*], [*RF Individual*],       [0.0904],  [0.3971], [0.1644], [0.3443], 
                [*3*], [*XGBoost Multisalida*], [0.0835],  [0.4403], [0.2341], [0.4101], 
                [*4*], [*RegressorChain*],      [0.0809],  [0.4022], [0.1827], [0.3564], 
                [*5*], [*XGBoost Individual*],  [0.0670],  [0.3978], [0.1576], [0.3413], 
                [*6*], [*Ridge*],               [-0.0164], [0.3744], [0.1124], [0.3034], 
                [*7*], [*MLP Estándar*],        [-0.0380], [0.4037], [0.1726], [0.3603], 
                [*8*], [*MLP Custom*],          [-0.1316], [0.4103], [0.1864], [0.3789] 
        )
    ],
    caption: [Ranking final del comparador de modelos de clasificación.],
    kind: table
)<tab-37>

El propio _notebook_ resume el resultado de forma explícita: 
- *Mejor modelo por R²:* RF Multisalida. 
- *Mejor modelo por Kappa:* XGBoost Multisalida.
- *Mejor modelo por F1-macro:* XGBoost Multisalida. 

XGBoost multisalida no tiene el mejor R² medio, pero sí el mejor Kappa (0.234, el único por encima de 0.2, el resto se mueven entre 0.11 y 0.19, un nivel de acuerdo "leve" según la escala habitual de interpretación de Kappa) y el mejor F1-macro con una diferencia notable sobre el resto (0.410 frente a 0.36 del segundo mejor).

#colbreak()

Sobre el desglose por _target_ destaca que, incluso para el _target_ más problemático de todo el trabajo (`coll_species_richness_z`, con R² negativo en los ocho modelos), varios modelos logran un Kappa positivo pequeño, lo que indica que, aunque ningún modelo predice bien el valor continuo exacto de este _target_, algunos sí consiguen distinguir con un acuerdo por encima del azar entre sus niveles Bajo/Medio/Alto.

En la #ref(<fig-19>) se pueden ver las matrices de confusión de los modelos entrenados, permitiendo ver a simple vista que el modelo XGBoost multisalida es el que mejor se comporta dentro de problemas de clasificación.

#figure(
    align(center)[
        #image("../media/box-conf-1.png")
    ],
    caption: [Matrices de confusión.],
    kind: image
)<fig-19>

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

==== Fundamentos y configuración

A diferencia del resto de _notebooks_ de este anexo, `extractor_resultados` no es un análisis en sí mismo sino una herramienta reutilizable que automatiza la extracción de métricas (`R²`, `RMSE`, `MAE`, `random_state`, `número de variables activas`) directamente desde el contenido de los _notebooks_ tal y como están guardados en una rama concreta de git, sin necesidad de hacer checkout de esa rama ni de reejecutar ningún _notebook_. Se apoya en git show <rama>:<archivo> para leer el JSON de cada `.ipynb` de forma aislada.

==== Metodología

Dado un `GIT_REPO_PATH` y una lista de ramas a comparar (`BRANCHES` para la prueba de eliminación de variables, `BRANCHES_BARRIDO` para la de barrido de `random_state`), el _notebook_, para cada combinación de rama y _notebook_ de modelo:

+ Localiza el bloque de texto que sigue al marcador "Evaluacion final sobre eval.csv" dentro de las celdas de salida, y extrae mediante expresiones regulares el `R²`, `RMSE` y `MAE` de cada uno de los 21 _targets_.
+ Extrae la lista de variables activas de `FEATURES_AUTORIZADAS` (distinguiendo las comentadas, es decir, excluidas, de las activas), para verificar que el número de columnas de `X_train` es coherente con lo esperado en cada prueba.
+ Extrae el `random_state` empleado, buscando primero una constante `RANDOM_STATE = N` y, si no existe, la primera aparición de `random_state=N` en el código.
+ Ejecuta el siguiente conjunto de validaciones automáticas: 
    + El número de variables no cambia entre ramas cuando la prueba en cuestión no debería eliminar ninguna. 
    + Las celdas se ejecutaron en orden (`execution_count` creciente, para detectar resultados obsoletos de una reejecución parcial).
    + Todos los _notebooks_ de una misma rama comparten el mismo `random_state`.
    + El `random_state` coincide con el que sugiere el propio nombre de la rama (por ejemplo, que model-prep-rs-group-1 no use por error el mismo `random_state` que model-prep-rs-group). Esto a la hora de comparar las ramas de las variables da _warning_, pero las comparaciones se realizan correctamente.
    + El R² de los _targets_ prioritarios no sean idénticos entre dos ramas que deberían ser distintas (señal de que una rama no se reejecutó realmente).

==== Resultados

*Validaciones automáticas:* La única salvedad es que el aviso de "el nombre de la rama sugiere `random_state = N` "produce *falsos positivos sistemáticos* sobre las 7 ramas de eliminación de variables que terminan en dígito (`model-prep-var-1`, `-2`, `-1-2`...): la expresión regular que extrae ese dígito del nombre de la rama se diseñó pensando en las ramas de barrido (`model-prep-rs-group-1`), y al aplicarse también a las de eliminación de variables interpreta el sufijo como si fuera un `random_state` esperado, cuando en realidad identifica qué variable se elimina. 

El resto de validaciones no señalan ningún aviso real: los 8 notebooks se leyeron correctamente en las 8 ramas, y el `random_state` es consistente (42) en las 8 ramas y los 8 notebooks.

*Coherencia de variables:* El criterio detectado automáticamente para las 8 ramas de eliminación de variables es `n_vars`, con la cascada esperada: 34 variables en la rama base, 33 al eliminar una sola variable (`var-1`, `var-2`, `var-3`), 32 al eliminar dos (`var-1-2`, `var-1-3`, `var-2-3`) y 31 al eliminar las tres (`var-1-2-3`), confirmando que la prueba de eliminación de variables se ejecutó correctamente en las 8 ramas.

#colbreak()

*Ranking global (8 ramas de eliminación de variables):*

#figure(
    align(center)[
        #table(
          columns: (auto, auto, auto),
          align: (left, center, center),
          fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") },
          table.header(
            table.cell(align:center)[*Modelo*], 
            [*Ranking medio (8 ramas)*], [*Desviación*]),
          [*RF multisalida*],      [*1.25*], [0.46],
          [*RF individual*],       [1.75], [0.46],
          [*XGBoost multisalida*], [3.31], [0.46],
          [*RegressorChain*],      [3.69], [0.46],
          [*XGBoost*],             [5.00], [0.00],
          [*MLP multisalida*],     [6.38], [0.52],
          [*Ridge*],               [6.62], [0.52],
          [*MLP _custom loss_*],   [8.00], [0.00],
        )
    ], 
    caption: [Resultados del extractor de resultados en las ramas de la #link(<prueba-1>)[*prueba de eliminación de vairables*].],
    kind: table
)<tab-38>

Como se puede ver en la #ref(<tab-38>), el ranking por R² medio global (21 targets) es *estable en las 8 ramas de eliminación de variables*: _Random Forest_ multisalida y _Random Forest_ quedan siempre en 1ª/2ª posición (desviación 0.46, es decir, como mucho intercambian el puesto entre sí de una rama a otra) y MLP _custom loss_ queda siempre último (desviación 0.00, sin ninguna excepción en las 8 ramas). 

Ningún modelo cambia de mitad de la tabla (`top-4` frente a `bottom-4`) al eliminar `cu_z`, `ni_z` y/o `mo_z`, lo que indica que la prueba de eliminación de variables no altera el ranking de modelos, solo su rendimiento absoluto.

*Barrido de `random_state` (ranking global, 21 targets):* 

A diferencia de `comparador_barrido_rs`, que solo consideraba el R² medio de los dos targets prioritarios, aquí se calcula también el ranking medio sobre el *R² medio de los 21 targets*, y sobre un barrido ampliado: la rama `model-prep-rs-group-1` pasó de 101 a *491 semillas* evaluadas.

#figure(
    align(center)[
        #table(
          columns: (auto, auto, auto, auto, auto),
          align: (left, center, center, center, center),
          fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") },
          table.header(
            table.cell(align: center)[*Modelo*], 
            [*Ranking medio \ (101 semillas)*], 
            [*Ranking medio \ (491 semillas)*], 
            [*R² medio global \ (491 semillas)*], 
            [*Desv. R² global*]
            ),
          [*RF multisalida*],      [*1.11*], [*1.12*], [0.0953],  [0.0033],
          [*RF individual*],       [1.96],   [1.95],   [0.0892],  [0.0042],
          [*XGBoost multisalida*], [3.04],   [3.08],   [0.0786],  [0.0049],
          [*RegressorChain*],      [3.90],   [3.85],   [0.0643],  [0.0116],
          [*Ridge*],               [5.48],   [5.25],   [-0.0164], [0.0000],
          [*MLP _custom loss_*],   [6.87],   [6.77],   [-0.0588], [0.0348],
          [*MLP multisalida*],     [6.02],   [6.92],   [-0.0678], [0.0516],
          [*XGBoost*],             [7.62],   [7.06],   [-0.0636], [0.0000],
        )
    ],
    caption : [Resultados del extractor de resultados en las ramas de la #link(<prueba-3>)[*prueba de barrido de `random_state`*].],
    kind: table
)<tab-43>

Como se puede ver en la #ref(<tab-43>), ampliar el barrido de 101 a 491 semillas *no cambia el ranking medio de forma apreciable*. 

La mayor variación es la de XGBoost, que pasa del puesto 7.62 al 7.06, sin llegar a adelantar a ningún otro modelo, lo que confirma que 101 semillas ya eran suficientes para una estimación estable. 

Este resultado, centrado en el R² medio de los *21 targets*, es coherente con el de `comparador_barrido_rs`: *_Random Forest_ multisalida* domina de forma robusta el ranking global (los 21 targets a la vez), mientras que *XGBoost multisalida* domina de forma igualmente robusta el ranking restringido a los dos targets prioritarios, hecho ya visto en múltiples ocasiones.


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

===== Fundamentos y configuración

Cada notebook de modelado dentro de la primera prueba (véase #link(<prueba-1>)[*Eliminación de variables*]) exporta, como parte de su análisis de explicabilidad, un archivo `variables_menos_relevantes_<modelo>.csv` con las 10 variables que ese modelo concreto considera menos influyentes (el "bottom-10"). 

Este notebook carga los ocho archivos, uno por modelo, y calcula un consenso sobre qué variables aparecen recurrentemente como poco relevantes independientemente del modelo empleado, con el objetivo de fundamentar la selección de variables a eliminar en la #link(<prueba-1>)[*Eliminación de variables*].

===== Metodología

Para cada variable que aparece en al menos un `bottom-10`, se calcula su frecuencia (en cuántos de los 8 modelos aparece) y su posición media dentro del `bottom-10` (1 = la variable considerada menos relevante de todas, 10 = la décima menos relevante). 

El ranking final se ordena primero por frecuencia (descendente) y, en caso de empate, por posición media (ascendente, priorizando las que son consistentemente de las peores). Se establece como "candidata fuerte a eliminar" cualquier variable que aparezca en al menos la mitad de los modelos utilizables $("umbral" max(2, ("n_modelos"+1)div 2)$, es decir, 4 de 8 en este caso).

===== Resultados

En la tabla #ref(<tab-39>) se puede ver el ranking de consenso resultante tras realizar la comparación con los 8 modelos base.

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto), 
            align: (left+horizon, center+horizon, center+horizon, left), 
            fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
            table.header(
                table.cell(align: center)[*Variable*], 
                [*Frecuencia*], [*Posición media*], 
                table.cell(align: center)[*Modelos*]), 
                [*cu_z*],                   [8/8], [4.9], [Todos], 
                [*ni_z*],                   [7/8], [4.4], [Todos salvo RegressorChain], 
                [*dem_orientacion_deg_z*],  [6/8], [6.8], [MLP Custom, RF Multi, RF, RegressorChain, Ridge, XGBoost], 
                [*mo_z*],                   [5/8], [5.0], [MLP Multi, RF Multi, RF, RegressorChain, Ridge], 
                [*eu_sand_content_z*],      [5/8], [5.6], [MLP Multi, MLP Custom, Ridge, XGB Multi, XGBoost], 
                [*plot_total_organic_c_z*], [5/8], [5.6], [MLP Multi, MLP Custom, RF Multi, Ridge, XGBoost], 
                [*total_plant_cover_z*],    [4/8], [3.0], [RF Multi, RF, RegressorChain, XGB Multi], 
                [*as_z*],                   [4/8], [5.0], [MLP Multi, MLP Custom, RF, Ridge], 
                [*dem_pendiente_deg_z*],    [4/8], [6.0], [RF Multi, RF, RegressorChain, XGBoost], )
    ],
    caption: [Ranking de variables menos relevantes.],
    kind: table
)<tab-39>

*`cu_z`* (cobre) aparece en el bottom-10 de los 8/8 modelos, y `ni_z` (níquel) en 7/8, siendo las dos candidatas más consistentes de todo el ranking. Ambas coinciden, además, con dos de las tres variables efectivamente probadas en el #link(<prueba-1>)[*Eliminación de variables*] (`cu_z`, `ni_z`, `mo_z`). 

La tercera variable de esa prueba, `mo_z`, aparece también entre las candidatas fuertes (5/8, posición media 5.0), aunque por detrás de `dem_orientacion_deg_z` (6/8), que no llegó a probarse pese a tener mayor consenso, esto fue para comprobar como afectaría la eliminación de una variable algo más relevante a los modelos. 

#colbreak()

En la #ref(<fig-20>) se pueden ver varias gráficas que muestran de diferentes formas la frecuencia de aparición que tienen las diferentes variables dentro del `bottom-10`.

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    image("../media/barras-frec.png"), image("../media/heat-frec.png"),
  ),
  caption: [Gráfico de barras y _heatmap_ de la frecuencia de los modelos relevantes.],
  kind: image,
) <fig-20>


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

=== _Notebook_ para la comparación de barrido de rs (Prueba III) <notebook-p3>

==== Fundamentos y configuración

Todas las comparativas anteriores se basan en una única semilla de entrenamiento (`random_state=42`). Este _notebook_ responde a la pregunta de si el ranking de modelos se mantiene estable al cambiar la semilla, cargando los resultados de la #link(<prueba-3>)[*Barrido de random_state*]: un barrido de 101 semillas (`random_state` de 0 a 100) para cada uno de los 8 modelos, calculado sobre los dos _targets_ prioritarios.

#rect[
    *Nota:*\
    El _notebook_ exportado forma parte de la primera iteración de la #link(<prueba-3>)[*Prueba de barrido de random_state*], la segunda iteración genera más modelos.
]

==== Metodología

Para cada semilla y modelo se calcula `r2_medio_prioritarios`, la media del R² sobre `earthworm_shannon_z` y `earthworm_richness_z`. Con las $101 times 8 = 808$ combinaciones resultantes se construye, para cada semilla, un ranking de los 8 modelos (posición 1 = mejor R² medio de esa semilla), y se agregan estadísticos de estabilidad: media, desviación estándar, mínimo, máximo y el porcentaje de semillas en las que cada modelo queda dentro del `top-1`, `top-2`, `top-3` y `top-5`.

==== Resultados

En la #ref(<tab-40>) se pueden ver los resultados obtenidos tras ejecutar el _notebook_ comparador creado para la prueba de barrido de rs (véase #link(<prueba-3>)[*Prueba de barrido de `random_state`*])

#figure(
    align(center)[
        #table( 
            columns: (auto, auto, auto, auto, auto), 
            align: (left, center, center, center, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header(
                table.cell(align: center)[*Modelo*], 
                [*R² medio (101 semillas)*], [*Desv. estándar*], [*% en top-1*], [*% en top-3*]), 
                [*XGBoost Multisalida*],      [0.5605], [0.0076], [100.0%], [100.0%], 
                [*RF Individual*],            [0.5316], [0.0074], [0.0%],   [100.0%], 
                [*RegressorChain*],           [0.5030], [0.0111], [0.0%],   [100.0%], 
                [*RandomForest Multisalida*], [0.4317], [0.0086], [0.0%],   [0.0%], 
                [*XGBoost Individual*],       [0.4397], [0.0000], [0.0%],   [0.0%], 
                [*MLP Estándar*],             [0.3903], [0.0330], [0.0%],   [0.0%], 
                [*MLP Pérdida Custom*],       [0.3677], [0.0422], [0.0%],   [0.0%], 
                [*Regresión Individual*],     [0.2592], [0.0000], [0.0%],   [0.0%]
            )
    ],
    caption: [Resultados de la ejecución del comparador de la prueba de barrido.],
    kind: table,
)<tab-40>

Este es, de todos los análisis de este anexo, el que ofrece la evidencia más contundente: *XGBoost multisalida* queda en primera posición en las 101 de 101 semillas evaluadas (100%), sobre el R² medio de los dos _targets_ prioritarios. 

Le siguen, siempre dentro del top-3 (aunque nunca del top-1), _Random Forest_ individual y RegressorChain. 

La desviación estándar de XGBoost multisalida (0.0076) es además una de las más bajas del conjunto, lo que indica que su ventaja no solo es consistente en _ranking_ sino también estable en magnitud, sin depender de haber tenido "suerte" con la semilla 42 usada en el resto de anexos.

Nótese que Ridge y XGBoost Individual muestran una desviación estándar de 0.0000: al ser modelos deterministas frente a la semilla de partición de datos en esta prueba concreta (la búsqueda de hiperparámetros no se repite por semilla en el barrido), su R² no varía entre iteraciones.

#colbreak()

En la #ref(<fig-21>) se pueden ver las gráficas de porcentaje de veces en la que los modelos han estado dentro de los tops 1, 2, 3 y 5 respectivamente.

#figure(
  grid(
    columns: 2,
    rows: 2,
    column-gutter: 1em,
    row-gutter: 1em,
    image("../media/top1.png"), image("../media/top2.png"),
    image("../media/top3.png"), image("../media/top5.png"),
  ),
  caption: [Gráficas de top 1, 2, 3 y 5 en base al porcentaje de veces que un modelos se encuentra dentro de ese top.],
  kind: image,
) <fig-21>


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

==== _Notebook_ de ensamblado de predicciones sin meta-modelos (Prueba IV.I) <notebook-p4-1>

===== Fundamentos y configuración

Este _notebook_ explora si combinar las predicciones de los ocho modelos base, mediante métodos de combinación fijos y predefinidos (sin entrenar ningún modelo adicional sobre ellas), mejora el resultado obtenido por el mejor modelo individual. Corresponde a la rama `model-prep-mixin` (véase #link(<dist-ramas-y-notebooks>)[*Anexo VI*]).

===== Metodología

Sobre las 65 filas de `eval.csv`, se reserva un subconjunto de calibración (`meta-train`, 45 filas) para calcular los pesos de las combinaciones que los necesitan, y un subconjunto de _holdout_ (20 filas) sobre el que se evalúa el resultado final, evitando así que la propia combinación se beneficie de haber "visto" los datos con los que se evalúa. 

Se prueban cinco métodos de combinación, por cada uno de los 21 _targets_:

+ *Media simple:* Promedio aritmético de las predicciones de los 8 modelos.
+ *Media ponderada por R²:* Cada modelo pesa en proporción a su R² en `meta-train` (recortado a 0 si es negativo).
+ *Top-k:* Promedio simple de únicamente los k modelos con mejor R² en `meta-train`.
+ *Mediana:* Mediana de las 8 predicciones, más robusta frente a un modelo con una predicción muy desviada.
+ *Stacking convexo:* Pesos $ w_i >= 0 "con" "sumw"_i = 1$ que minimizan el MSE en `meta-train`, obtenidos mediante optimización numérica (`scipy.optimize.minimize`, método SLSQP).

===== Resultados

En la #ref(<tab-41>) se puede ver un resumen de los resultados obtenidos tras ejecutar la primera parte de la #link(<prueba-4>)[*Prueba de ensamblado de predicciones*].

#figure(
    align(center)[
        #table( 
            columns: (auto, auto), 
            align: (left, center), 
            fill: (col, row) => if row == 0 or col == 0 { rgb("d6e3da") }, 
            table.header(
                table.cell(align: center)[*Métrica*], [*Valor*]), 
                [*_Targets_ evaluados*],                                                  [21], 
                [*_Targets_ donde alguna combinación supera al mejor modelo individual*], [4/21 (19%)], 
                [*_Targets_ con señal predictiva real (mejor R² > 0)*],                   [15/21 (71%)], 
                [*_Targets_ sin señal predictiva en ningún método*],                      [6/21] 
        )
    ],
    caption: [Resultados de la prueba de ensamblado de predicciones sin meta-modelos.],
    kind: table
)<tab-41>

El resultado es mayoritariamente negativo para este enfoque: en 4 de cada 5 _targets_, ninguno de los cinco métodos de combinación fijos mejora sobre el mejor modelo individual disponible para ese _target_ concreto. 

Esto sugiere que, con el tamaño de _holdout_ disponible (20 filas), los pesos calculados en `meta-train` no generalizan lo suficientemente bien como para superar de forma consistente a simplemente elegir el mejor modelo individual, un resultado que motiva directamente la variante explorada en el siguiente _notebook_, que sustituye estos métodos fijos por `meta-modelos` entrenados.

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

==== _Notebook_ de ensamblado de predicciones con meta-modelos (Prueba IV.II) <notebook-p4-2>

===== Fundamentos y configuración

Extiende la idea del _notebook_ anterior sustituyendo los métodos de combinación fijos por `meta-modelos` entrenados: en vez de calcular unos pesos con una fórmula cerrada, se entrena un modelo de regresión adicional cuya entrada son las predicciones de los 8 modelos base, y cuya salida es la predicción combinada final. 

Corresponde a la `rama model-prep-mixin-1` (véase #link(<dist-ramas-y-notebooks>)[*Anexo VI*]), en la que, a diferencia de `model-prep-mixin`, se prueba con la totalidad de los 21 _targets_.

===== Metodología

Se emplea la misma partición `meta-train` (45 filas) / _holdout_ (20 filas) que en el _notebook_ anterior. Sobre `meta-train` se entrenan cinco `meta-modelos` candidatos por cada _target_: *Ridge, Lasso, ElasticNet, Regresión Lineal y _Random Forest_*, todos ellos de `scikit-learn` con su configuración por defecto salvo la regularización. 

Antes de evaluar cada `meta-modelo` sobre el _holdout_, se ejecuta una comprobación automática (_smoke\_test_) que descarta cualquier predicción con valores _NaN_ o infinitos.

===== Resultados

En la #ref(<tab-42>) se puede ver un resumen de los resultados obtenidos tras ejecutar la segunda parte de la #link(<prueba-4>)[*Prueba de ensamblado de predicciones*].

#figure(
    align(center)[
        #table( 
            columns: (auto, auto), 
            align: (left, center), 
            fill: (col, row) => if row == 0 or col == 0{ rgb("d6e3da") }, 
            table.header(
                table.cell(align: center)[*Métrica*], 
                [*Valor*]
                ), 
                [*_Targets_ evaluados*], [21], 
                [*_Targets_ donde algún `meta-modelo`/ensamblado supera al mejor individual*], [9/21 (43%)], 
                [*_Targets_ con señal predictiva real (mejor R² > 0)*], [18/21 (86%)], 
                [*_Targets_ sin señal predictiva en ningún método*], [3/21] 
        )
    ],
    caption: [Resultados de la prueba de ensamblado de predicciones con meta-modelos.],
    kind: table
)<tab-42>

A diferencia de los métodos de combinación fijos del _notebook_ anterior (19% de mejora), entrenar un `meta-modelo` mejora sobre el mejor individual en más del doble de _targets_ (43%), lo que sugiere que, aunque el _holdout_ es pequeño, un `meta-modelo` simple (Ridge, Lasso...) consigue capturar patrones de complementariedad entre los modelos base que un método de combinación fijo no puede aprovechar. 

El caso más llamativo es `coll_species_richness_z`, el _target_ con peor R² individual de todo este trabajo (-0.069 incluso para su mejor modelo individual, _Random Forest_ multisalida), donde un `meta-modelo` _Random Forest_ alcanza un *R²=0.523* sobre el _holdout_, la mejora más drástica de todo el análisis. 

También destaca `earthworm_richness_z`, uno de los _targets_ prioritarios, donde un `meta-modelo` Ridge (R²=0.523) supera ligeramente al mejor modelo individual, XGBoost multisalida (R²=0.509).

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