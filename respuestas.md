# Respuestas — Semana 12: Cyber Detective

## 1. Skill frente a plugin

`incident-investigator` es un **skill** porque lo que aporta son instrucciones y
recursos que el agente carga **cuando el contexto lo pide**: la `description`
decide la activación, `SKILL.md` define el procedimiento y el formato, y
`references/detection-rules.md` se abre bajo demanda. No ejecuta nada por sí
solo, no reacciona a eventos del entorno y no expone una capacidad externa.
Funciona igual sobre cualquier CSV compatible.

Para distribuirlo como **plugin** de Claude Code se empaquetaría en un directorio
con su manifiesto `.claude-plugin/plugin.json` (nombre, versión, descripción) y,
además del skill en `skills/incident-investigator/`, podría incluir:

- **Comando** (`commands/investigar.md`): un `/investigar <csv>` que invoque el skill de forma explícita.
- **Hook** (`hooks/hooks.json`): por ejemplo un `PostToolUse` que revise la salida y bloquee o avise si aparece `token=` seguido de algo distinto de `[REDACTED]`, o un `PreToolUse` que impida escribir sobre el CSV original. Así la redacción se vuelve una garantía automática y no solo una instrucción.
- **Servidor MCP** (`.mcp.json`): un detector local, como el MCP Detective del deber anterior, que exponga herramientas tipo `detectar_fuerza_bruta(csv)` con resultados deterministas.
- **Subagente** (`agents/`): un revisor que vuelva a comprobar las filas citadas.

Los nombres de ruta siguen la documentación de plugins de Claude Code; en otra
plataforma cambiarían.

## 2. Ralph Loop: repetir el análisis con comprobaciones verificables

La idea es iterar **sobre el mismo CSV y el mismo informe**. Cada vuelta corrige
solo lo que una comprobación objetiva marca como fallo; no añade evidencia nueva.

**Comprobaciones verificables** (deterministas: un script o un `grep`, no la
opinión del modelo):

1. Cada fila citada existe y su `ip`, `user`, `event` y `result` coinciden con la alerta.
2. Cada alerta cumple su umbral recontando las filas citadas: R1 ≥ 6 en ≤ 5 min, R2 ≥ 5 usuarios, R3 contiene `token=`, R4 tiene `approved=false`.
3. No aparece ningún valor de secreto: toda ocurrencia de `token=` va seguida de `[REDACTED]`.
4. El hash del CSV sigue siendo el mismo (no se modificó).
5. Toda alerta tiene la columna `limitaciones` rellena.

**Bucle** (máximo **3 iteraciones**):

1. Iteración 1: el agente produce `hallazgos.md` con el skill.
2. Se ejecutan las comprobaciones y se guarda la lista de fallos.
3. Si hay fallos, el agente recibe solo esa lista y el informe anterior. Puede **corregir o eliminar** alertas y citas, pero no añadir alertas que no salgan de una regla ni filas que no existan. Toda corrección debe volver a pasar las comprobaciones.

**Criterio de parada explícito:** se detiene en cuanto todas las comprobaciones
pasan, o al terminar la iteración 3, lo que ocurra primero. Si en la 3 sigue
habiendo fallos, no se fuerza un «verde»: se entrega el informe con los fallos
pendientes listados como limitación, para que los revise una persona. También se
para antes si dos iteraciones seguidas devuelven exactamente los mismos fallos,
porque no hay progreso.
