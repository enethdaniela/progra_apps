# Evidencias

## Cómo se instaló y se invocó

- **Plataforma:** Claude Code 2.1.322 (el binario que trae la extensión de VS Code), modelo `claude-opus-5-5`.
- **Instalación:** como *project skill*, copiando la carpeta [`incident-investigator/`](../incident-investigator/) a `.claude/skills/incident-investigator/` en la raíz del repositorio. Claude Code descubre ahí los skills de proyecto. La copia instalada no se sube al repo para no duplicar archivos; la fuente es `incident-investigator/`.
- **Invocación:** cada prueba es una sesión nueva e independiente:
  `claude -p "<prompt>" --output-format stream-json --verbose`,
  con herramientas de solo lectura permitidas (`Read`, `Glob`, `Grep`, `Skill` y algunos `Bash`) y con `WebFetch`, `WebSearch`, `Write` y `Edit` bloqueadas.
- **Trazas:** los archivos `.md` de esta carpeta se generaron automáticamente a partir del JSON de cada sesión. Contienen el evento `init` (modelo y lista de skills disponibles), cada llamada a herramienta en orden, las métricas del evento `result` y la respuesta final literal. No son capturas de pantalla: son trazas textuales reales. Los resultados de herramientas aparecen recortados a 160 caracteres.

## Pruebas

| archivo | prueba | qué se **vio** en la traza | resultado |
|---|---|---|---|
| [activacion_explicita.md](activacion_explicita.md) | A — explícita | `Skill {"skill":"incident-investigator"}` → `Read …/references/detection-rules.md` → `Read logs_sinteticos.csv` | Se activó y aplicó R1–R4 con el formato del skill. |
| [activacion_contextual.md](activacion_contextual.md) | B — contextual, sin nombrar el skill | La misma secuencia: `Skill` → `detection-rules.md` → CSV | **Se activó por la `description`.** |
| [control_negativo.md](control_negativo.md) | C — conteo por hora | Solo `Bash` (`head`, `wc`, `cut \| sort \| uniq -c`). **Ninguna** llamada `Skill` ni lectura de `SKILL.md` o de las reglas. | **No se activó**, que es lo deseado. Resultado: 63 eventos en la hora 01 y 30 en la 02 (los recomprobé: filas 2–64 y 65–94). |
| [mision5_sin_skill.md](mision5_sin_skill.md) | Misión 5, sin skill | `init` sin `incident-investigator` en la lista de skills | Ver [comparacion.md](../comparacion.md). |
| [mision5_con_skill.md](mision5_con_skill.md) | Misión 5, con skill | `Skill` → `detection-rules.md` → CSV | Ver [comparacion.md](../comparacion.md). |

## Visto frente a inferido

- **Visto:** la llamada a la herramienta `Skill`, su resultado (`Launching skill: incident-investigator`) y la lectura de `detection-rules.md` aparecen en el JSON de las sesiones A, B y Misión 5 con skill, pero no en C ni en Misión 5 sin skill.
- **Inferido:** que el contenido de `SKILL.md` entró en el contexto. La traza muestra que se lanzó el skill, no el texto inyectado. Lo deduzco de que, justo después, el agente abre `references/detection-rules.md` (algo que solo menciona `SKILL.md`) y usa su tabla de salida.
- En A y en Misión 5 con skill, el agente intentó ejecutar `scripts/analyze_logs.py` encadenado con `sed`. El modo headless pidió aprobación y el comando **no se ejecutó**. El agente continuó a mano, como se ve en la traza.

## Misión 4: ajuste de `description`

B se activó y C no, así que **no hizo falta cambiar la `description`** ni repetir pruebas. La `description` ya incluía señales positivas («investigar… accesos sospechosos… secretos filtrados… citar filas») y límites explícitos («NO lo uses para tareas solo descriptivas: contar eventos por hora…»).

## Sobre los secretos

En la sesión sin skill, el agente imprimió el token completo. En la traza publicada se sustituyó por `token=[REDACTED]`, y así lo indica una nota al inicio del archivo. Ningún archivo de este PR contiene el valor completo.
