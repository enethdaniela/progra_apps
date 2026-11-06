# Deber 5 — MCP Detective

## Arquitectura

El LLM interpreta la petición y propone qué herramienta usar y con qué argumentos. El host (Copilot en VS Code) coordina la conversación y ofrece las herramientas al modelo; el cliente MCP envía la llamada al servidor mediante el protocolo MCP. El servidor MCP es quien ejecuta Python, lee los casos, valida los argumentos y registra las alertas en memoria.

## Evidencia

`INC-003` merece investigación porque registra cuatro intentos fallidos consecutivos del usuario `admin` y luego un acceso exitoso desde la misma IP en el panel de administración. Los logs no muestran quién controlaba esa IP, el contexto del acceso ni si fue autorizado; por tanto, el patrón es sospechoso, pero no demuestra por sí solo una intrusión.

## Validación y seguridad

El servidor valida `INC-999`, los niveles, los motivos y las alertas duplicadas, y devuelve un error cuando los datos no cumplen las reglas. No es seguro confiar solo en los argumentos generados por el modelo: puede equivocarse o inventar valores, así que la validación debe aplicarse en el servidor antes de actuar.

## Agente y conexión

Usé Copilot en VS Code para trabajar en el servidor y MCP Inspector 2.13.0 para probarlo. En Inspector confirmé el estado `Connected`, el discovery de las tres herramientas y las respuestas de sus llamadas. Esta comprobación confirma la conexión de Inspector; todavía no he verificado una llamada de herramientas desde Copilot como host.

## Instrucciones breves

Desde la raíz del proyecto, instala el SDK y pytest en el entorno Python que utilizará el servidor:

```powershell
python -m pip install "mcp[cli]>=2,<3" pytest
```

Inicia MCP Inspector:

```powershell
uv run --with "mcp[cli]==2.3.0" mcp dev --with "mcp[cli]==2.3.0" mcp-detective/server.py
```

Para conectar el servidor a un host compatible con MCP, configura un servidor `stdio` en `.vscode/mcp.json`. Usa las rutas absolutas locales al entorno Python y a `mcp-detective/server.py`, y establece como directorio de trabajo `mcp-detective`. Por ejemplo:

```json
{
  "servers": {
    "mcp-detective": {
      "type": "stdio",
      "command": "C:\\ruta\\al\\proyecto\\.venv\\Scripts\\python.exe",
      "args": [
        "C:\\ruta\\al\\proyecto\\mcp-detective\\server.py"
      ],
      "cwd": "C:\\ruta\\al\\proyecto\\mcp-detective"
    }
  }
}
```

Después de guardar la configuración, reinicia o actualiza el host y comprueba que descubra `listar_casos`, `consultar_eventos` y `registrar_alerta`. No se requieren tokens ni contraseñas.
