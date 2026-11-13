"""Ayuda opcional para incident-investigator.

Calcula candidatos de R1-R4 (ver references/detection-rules.md) sobre un CSV
compatible y los imprime con números de fila originales (encabezado = fila 1).
No modifica el archivo, no usa red y redacta cualquier valor secreto.
La salida es una ayuda para revisar, no una prueba: verifica las filas a mano.

Uso: python analyze_logs.py ruta/al/archivo.csv
"""

import csv
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta

VENTANA = timedelta(minutes=5)
SECRETO = re.compile(r"(token|password|secret|api_key)=[^;\s,]*", re.IGNORECASE)
COLUMNAS = {"timestamp", "ip", "user", "event", "result", "detail"}


def redactar(texto):
    return SECRETO.sub(lambda m: f"{m.group(1)}=[REDACTED]", texto)


def cargar(ruta):
    with open(ruta, newline="", encoding="utf-8") as f:
        lector = csv.DictReader(f)
        faltan = COLUMNAS - set(lector.fieldnames or [])
        if faltan:
            sys.exit(f"CSV incompatible, faltan columnas: {sorted(faltan)}")
        filas = []
        for n, r in enumerate(lector, start=2):
            r["_fila"] = n
            r["_t"] = datetime.fromisoformat(r["timestamp"])
            filas.append(r)
    return sorted(filas, key=lambda r: r["_t"])  # sorted es estable


def ventanas(eventos):
    """Devuelve la ventana más grande (≤ 5 min, extremos incluidos) por inicio."""
    mejor = []
    for i, ini in enumerate(eventos):
        dentro = [e for e in eventos[i:] if e["_t"] - ini["_t"] <= VENTANA]
        if len(dentro) > len(mejor):
            mejor = dentro
    return mejor


def es(r, event, result):
    return r["event"] == event and r["result"] == result


def main(ruta):
    sys.stdout.reconfigure(encoding="utf-8")
    filas = cargar(ruta)
    print(f"Filas de datos: {len(filas)}  rango: {filas[0]['timestamp']} .. {filas[-1]['timestamp']}")
    fallos = [r for r in filas if es(r, "login", "failed")]

    print("\n[R1] Fuerza bruta (>=6 login/failed misma ip->mismo user en 5 min)")
    por_par = defaultdict(list)
    for r in fallos:
        por_par[(r["ip"], r["user"])].append(r)
    for (ip, user), evs in sorted(por_par.items()):
        v = ventanas(evs)
        if len(v) < 3:
            continue
        estado = "ALERTA" if len(v) >= 6 else "no alcanza umbral"
        claves = [(e["timestamp"], e["detail"]) for e in v]
        duplicadas = len(claves) - len(set(claves))
        print(f"  {estado}: {ip} -> {user}: {len(v)} fallos, filas {[e['_fila'] for e in v]}, "
              f"filas idénticas a otra: {duplicadas} (sin ellas: {len(set(claves))})")
        fin = v[-1]["_t"]
        exitos = [r["_fila"] for r in filas if es(r, "login", "success") and r["ip"] == ip
                  and r["user"] == user and fin <= r["_t"] <= fin + VENTANA]
        if exitos:
            print(f"    éxito posterior en <=5 min: filas {exitos}")

    print("\n[R2] Spraying (login/failed misma ip contra >=5 users en 5 min)")
    por_ip = defaultdict(list)
    for r in fallos:
        por_ip[r["ip"]].append(r)
    for ip, evs in sorted(por_ip.items()):
        mejor = []
        for i, ini in enumerate(evs):
            dentro = [e for e in evs[i:] if e["_t"] - ini["_t"] <= VENTANA]
            if len({e["user"] for e in dentro}) > len({e["user"] for e in mejor}):
                mejor = dentro
        usuarios = sorted({e["user"] for e in mejor})
        if len(usuarios) >= 5:
            print(f"  ALERTA: {ip}: {len(usuarios)} usuarios {usuarios}, filas {[e['_fila'] for e in mejor]}")

    print("\n[R3] Secretos en detail")
    for r in filas:
        if "token=" in r["detail"]:
            print(f"  ALERTA fila {r['_fila']}: {r['ip']} {r['user']} {r['event']}/{r['result']} "
                  f"detail='{redactar(r['detail'])}'")

    print("\n[R4] role_change/success con approved=false")
    for r in filas:
        if es(r, "role_change", "success") and "approved=false" in r["detail"]:
            print(f"  ALERTA fila {r['_fila']}: {r['ip']} {r['user']} detail='{redactar(r['detail'])}'")

    print("\n[Contexto] eventos no-login")
    for r in filas:
        if r["event"] != "login":
            print(f"  fila {r['_fila']}: {r['timestamp']} {r['ip']} {r['user']} "
                  f"{r['event']}/{r['result']} '{redactar(r['detail'])}'")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
