== Scripts y notebooks auxiliares <elementos-auxiliares>

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

=== Notebooks para la comparación de modelos <model-comp>

==== Comparador de regresión <reg-comp>

==== Comparador de clasificación <clas-comp>

==== Comparador entre ramas <branch-comp>

=== Notebook para la comparación de variables (Prueba I) <notebook-p1>

=== Notebook para la comparación de barrido de rs (Prueba III) <notebook-p1>