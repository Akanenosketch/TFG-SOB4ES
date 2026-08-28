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

Una vez data-prep, data-prep-online y data-prep-combination (véase #link(<notebooks-empleados>)[*Anexo III*]) generan el dataset final armonizado (sob4es_final_model_ready.csv), este notebook es responsable de dividirlo en los tres subconjuntos empleados por el resto del proyecto: entrenamiento, test y evaluación. Es, por tanto, el último eslabón de la #link(<capa-procesamiento>)[*Capa de procesamiento de datos*] antes de entrar en la Capa de modelado predictivo.

El dataset de entrada contiene 428 filas y 71 columnas, sin ningún valor nulo. La partición se configura con TEST_SIZE=0.30 (fracción reservada para test+eval conjuntamente), EVAL_FRAC=0.50 (mitad de esa reserva para eval, mitad para test) y RANDOM_SEED=42.

==== Metodología

La partición se realiza en dos pasos sucesivos con train_test_split de scikit-learn, estratificando por país de origen de la muestra (extraído del prefijo de site_id, por ejemplo BE, IL, RO) para asegurar que los tres subconjuntos mantengan una representación proporcional de cada país. Italia (IT), con solo 2 filas en todo el dataset, se agrupa con Alemania (DE) únicamente a efectos de estratificación, al no ser posible estratificar un país con menos de 2 muestras por split.

Primera partición: train (70%) frente a un conjunto temporal (temp, 30%).
Segunda partición: temp se divide a su vez al 50% entre test y eval.

Tras la partición se verifica que la proporción de outlier_flag (una bandera de calidad de dato ya calculada en fases anteriores) se mantiene similar entre los tres subconjuntos, como comprobación adicional de que la partición no ha introducido un sesgo de calidad entre splits.

==== Resultados

#table( columns: (auto, auto, auto), align: (left, center, center), fill: (col, row) => if row == 0 { rgb("d6e3da") }, table.header([Subconjunto], [Filas], [% del total]), [train.csv], [299], [69.9%], [test.csv], [64], [15.0%], [eval.csv], [65], [15.2%], )

La distribución de outlier_flag se mantiene prácticamente idéntica entre subconjuntos (81.3% / 81.2% / 80.0% de True en train/test/eval respectivamente, frente al 81.1% del dataset completo), confirmando que la estratificación por país no ha desequilibrado esta variable de calidad. De igual forma, la proporción de muestras por país se mantiene estable en los tres splits (por ejemplo, Rumanía mantiene un 70.6% de sus muestras en train, muy cercano al 69.9% global), con la única excepción esperable de Italia, cuyas 2 únicas muestras se reparten una a test y otra a eval, sin ninguna en train.

// TODO: insertar aquí el gráfico de tarta (distribución de splits) y el gráfico de barras (muestras por país y split) generados en data-prep-div.ipynb

#let file = "../media/anexos/data-prep-div.pdf"
#let total_pages = 4 
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

#let file = "../media/anexos/comparador_modelos.pdf"
#let total_pages = 16 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

==== Comparador de clasificación <clas-comp>

#let file = "../media/anexos/comparador_clasificacion.pdf"
#let total_pages = 13 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

==== Comparador entre ramas <branch-comp>

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

#let file = "../media/anexos/comparador_barrido_rs.pdf"
#let total_pages = 7 
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