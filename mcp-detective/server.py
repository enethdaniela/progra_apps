import json
from pathlib import Path

from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError

mcp = MCPServer("MCP Detective")

_alertas_en_memoria: dict[str, dict] = {}


def _cargar_datos() -> dict[str, dict]:
    """Carga los casos desde el archivo ubicado junto a este servidor."""
    ruta = Path(__file__).with_name("casos.json")
    with ruta.open(encoding="utf-8") as archivo:
        return json.load(archivo)


def _reiniciar_alertas() -> None:
    """Limpia el almacenamiento en memoria para aislar las pruebas."""
    _alertas_en_memoria.clear()


def logica_listar_casos() -> list[dict]:
    """Prepara el resumen de los casos sin clasificarlos."""
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
    """Obtiene los eventos exactos de un caso existente."""
    casos = _cargar_datos()
    if not isinstance(caso_id, str) or caso_id not in casos:
        raise ValueError(f"El caso '{caso_id}' no existe en el sistema.")
    return casos[caso_id]["eventos"]


def logica_registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Valida y registra una alerta en la memoria de esta instancia."""
    casos = _cargar_datos()
    if not isinstance(caso_id, str) or caso_id not in casos:
        raise ValueError(f"El caso '{caso_id}' no existe.")

    niveles_validos = {"bajo", "medio", "alto"}
    if not isinstance(nivel, str) or nivel not in niveles_validos:
        raise ValueError("Nivel inválido. Debe ser 'bajo', 'medio' o 'alto'.")

    if not isinstance(motivo, str) or not motivo.strip():
        raise ValueError("El motivo no puede estar vacío ni contener solo espacios.")

    if caso_id in _alertas_en_memoria:
        raise ValueError(f"Ya existe una alerta registrada para el caso '{caso_id}'.")

    alerta = {
        "caso_id": caso_id,
        "nivel": nivel,
        "motivo": motivo,
        "estado": "registrada",
    }
    _alertas_en_memoria[caso_id] = alerta
    return alerta


@mcp.tool()
def listar_casos() -> list[dict]:
    """Lista los identificadores, sistemas y cantidades de eventos de los casos."""
    return logica_listar_casos()


@mcp.tool()
def consultar_eventos(caso_id: str) -> list[dict]:
    """Consulta los registros exactos de eventos del caso indicado."""
    try:
        return logica_consultar_eventos(caso_id)
    except ValueError as error:
        raise ToolError(str(error)) from error


@mcp.tool()
def registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Registra una alerta válida en memoria, una sola vez por caso."""
    try:
        return logica_registrar_alerta(caso_id, nivel, motivo)
    except ValueError as error:
        raise ToolError(str(error)) from error


if __name__ == "__main__":
    mcp.run(transport="stdio")
