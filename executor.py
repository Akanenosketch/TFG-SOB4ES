#!/usr/bin/env python3
"""
Ejecuta de principio a fin varios notebooks (todos los .ipynb de una carpeta, o los
que le indiques) y deja constancia de si cada uno termino bien o fallo.

Que hace por cada notebook:
  1. Ejecuta todas las celdas en orden (jupyter nbconvert --execute).
  2. Guarda el resultado en <notebook>_ejecutado.ipynb (con las tablas/graficas ya
     generadas), sin tocar el notebook original.
  3. Exporta tambien una version en HTML, para verlo sin abrir Jupyter.
  4. Si un notebook falla (una celda lanza una excepcion, o se agota el timeout), no
     interrumpe el resto: sigue con el siguiente y lo apunta en el resumen final.

Que NO ejecuta (se descarta automaticamente):
  - Los notebooks que ya son una salida de una ejecucion anterior de este script
    (terminan en "_ejecutado.ipynb"), para no re-ejecutar resultados sobre resultados.
  - Cualquier cosa dentro de una carpeta ".ipynb_checkpoints" (son copias temporales
    que crea Jupyter, no notebooks reales).

Uso:
    python ejecutar_pruebas.py
        -> ejecuta TODOS los .ipynb del directorio actual (no busca en subcarpetas)

    python ejecutar_pruebas.py --recursive
        -> ejecuta TODOS los .ipynb del directorio actual y sus subcarpetas

    python ejecutar_pruebas.py prueba4_ensamblado_corregido.ipynb prueba5_ensamblado_stacking.ipynb
        -> ejecuta solo los notebooks que le pases (ignora --pattern/--recursive)

    python ejecutar_pruebas.py --pattern "prueba*.ipynb"
        -> vuelve al comportamiento anterior: solo los que empiecen por "prueba"

    python ejecutar_pruebas.py --timeout 1200 --output-dir resultados
        -> timeout mas largo (en segundos) por notebook, y carpeta de salida distinta

Requisitos: jupyter y nbconvert instalados (pip install jupyter nbconvert ipykernel),
y el kernel de Python que usan los notebooks disponible (el que se ve en
"kernelspec" -> "name" dentro del .ipynb; por defecto "python3").
"""

import argparse
import subprocess
import sys
import time
from pathlib import Path


def buscar_notebooks(directorio: Path, pattern: str, recursive: bool, output_dir: Path) -> list:
    """Busca notebooks segun el patron, descartando checkpoints, salidas de una
    ejecucion anterior de este script, y cualquier cosa dentro de output_dir."""
    buscador = directorio.rglob(pattern) if recursive else directorio.glob(pattern)

    notebooks = []
    for nb in buscador:
        if ".ipynb_checkpoints" in nb.parts:
            continue
        if nb.stem.endswith("_ejecutado"):
            continue
        try:
            if output_dir.resolve() in nb.resolve().parents:
                continue
        except OSError:
            pass
        notebooks.append(nb)

    return sorted(notebooks)


def ejecutar_notebook(nb_path: Path, output_dir: Path, timeout: int) -> dict:
    """Ejecuta un notebook de principio a fin y devuelve un resumen del resultado."""
    output_dir.mkdir(parents=True, exist_ok=True)
    nb_ejecutado = output_dir / f"{nb_path.stem}_ejecutado.ipynb"

    inicio = time.time()
    cmd = [
        sys.executable, "-m", "jupyter", "nbconvert",
        "--to", "notebook",
        "--execute",
        f"--ExecutePreprocessor.timeout={timeout}",
        "--output", nb_ejecutado.name,
        "--output-dir", str(output_dir),
        str(nb_path),
    ]
    resultado = subprocess.run(cmd, capture_output=True, text=True)
    duracion = time.time() - inicio

    ok = resultado.returncode == 0 and nb_ejecutado.exists()

    html_generado = None
    if ok:
        # Exporta tambien a HTML, para poder verlo sin abrir Jupyter.
        cmd_html = [
            sys.executable, "-m", "jupyter", "nbconvert",
            "--to", "html",
            str(nb_ejecutado),
        ]
        r_html = subprocess.run(cmd_html, capture_output=True, text=True)
        if r_html.returncode == 0:
            html_generado = nb_ejecutado.with_suffix(".html").name

    return {
        "notebook": nb_path.name,
        "ok": ok,
        "duracion_s": round(duracion, 1),
        "salida_ipynb": nb_ejecutado.name if ok else None,
        "salida_html": html_generado,
        "error": None if ok else _extraer_error(resultado.stderr),
    }


def _extraer_error(stderr: str) -> str:
    """Se queda con las ultimas lineas del stderr, que suelen tener el traceback util
    (el principio de la salida de nbconvert suele ser solo progreso, no el error)."""
    lineas = [l for l in stderr.strip().split("\n") if l.strip()]
    return "\n".join(lineas[-15:]) if lineas else "Error desconocido (nbconvert no genero stderr)."


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
        "--timeout", type=int, default=900,
        help="Timeout en segundos por notebook (default: 900 = 15 min)",
    )
    parser.add_argument(
        "--output-dir", default="resultados_ejecucion",
        help="Carpeta donde se guardan los notebooks ejecutados y los HTML (default: resultados_ejecucion)",
    )
    args = parser.parse_args()

    output_dir = Path(args.output_dir)

    if args.notebooks:
        notebooks = [Path(n) for n in args.notebooks]
        notebooks_existentes = [nb for nb in notebooks if nb.exists()]
        notebooks_faltantes = [nb for nb in notebooks if not nb.exists()]
        for nb in notebooks_faltantes:
            print(f"[AVISO] No existe: {nb} (se omite)")
    else:
        notebooks_existentes = buscar_notebooks(Path("."), args.pattern, args.recursive, output_dir)

    if not notebooks_existentes:
        print(f"No se encontro ningun notebook (patron: {args.pattern}, recursive={args.recursive}). "
              f"Nada que ejecutar.")
        sys.exit(1)

    print(f"Ejecutando {len(notebooks_existentes)} notebook(s), timeout={args.timeout}s cada uno, "
          f"salida en '{output_dir}/'\n")

    resultados = []
    for nb_path in notebooks_existentes:
        print(f"-> {nb_path.name} ...", end=" ", flush=True)
        r = ejecutar_notebook(nb_path, output_dir, args.timeout)
        resultados.append(r)
        if r["ok"]:
            print(f"OK ({r['duracion_s']}s) -> {output_dir}/{r['salida_ipynb']}")
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

    resumen_path = output_dir / "resumen_ejecucion.txt"
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
