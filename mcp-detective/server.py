import json
from pathlib import Path

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("MCP Detective")

_alertas_en_memoria: dict[str, dict] = {}


def _cargar_datos() -> dict:
    """Carga casos.json relativo a la ubicación de este archivo."""
    ruta = Path(__file__).parent / "casos.json"
    with open(ruta, "r", encoding="utf-8") as archivo:
        return json.load(archivo)


def _reiniciar_alertas() -> None:
    """Limpia el almacenamiento en memoria para las pruebas."""
    global _alertas_en_memoria
    _alertas_en_memoria = {}


def logica_listar_casos() -> list[dict]:
    casos = _cargar_datos()
    return [
        {
            "caso_id": caso_id,
            "sistema": datos["sistema"],
            "total_eventos": len(datos["eventos"]),
        }
        for caso_id, datos in casos.items()
    ]


def logica_consultar_eventos(caso_id: str) -> list[dict]:
    casos = _cargar_datos()
    if caso_id not in casos:
        raise ValueError(f"El caso '{caso_id}' no existe en el sistema.")
    return casos[caso_id]["eventos"]


def logica_registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    casos = _cargar_datos()
    if caso_id not in casos:
        raise ValueError(f"El caso '{caso_id}' no existe.")

    niveles_validos = {"bajo", "medio", "alto"}
    if nivel not in niveles_validos:
        raise ValueError(
            f"Nivel inválido '{nivel}'. Debe ser 'bajo', 'medio' o 'alto'."
        )

    if not isinstance(motivo, str) or not motivo.strip():
        raise ValueError(
            "El motivo no puede estar vacío ni contener solo espacios en blanco."
        )

    if caso_id in _alertas_en_memoria:
        raise ValueError(f"Ya existe una alerta registrada para el caso '{caso_id}'.")

    alerta = {
        "caso_id": caso_id,
        "nivel": nivel,
        "motivo": motivo.strip(),
        "estado": "registrada",
    }
    _alertas_en_memoria[caso_id] = alerta
    return alerta


@mcp.tool()
def listar_casos() -> list[dict]:
    """Devuelve el identificador, sistema y cantidad de eventos de cada caso."""
    return logica_listar_casos()


@mcp.tool()
def consultar_eventos(caso_id: str) -> list[dict]:
    """Devuelve los registros exactos de eventos de un caso específico."""
    return logica_consultar_eventos(caso_id)


@mcp.tool()
def registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Registra una alerta en memoria validando el caso, nivel y motivo."""
    return logica_registrar_alerta(caso_id, nivel, motivo)


if __name__ == "__main__":
    mcp.run(transport="stdio")
