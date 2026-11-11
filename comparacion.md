# Comparación sin skill / con skill

**Montaje.** Hice dos sesiones headless independientes de Claude Code
(`claude -p`), cada una en un proceso nuevo, sin `--resume` y con un
`session_id` distinto. Las dos usaron el mismo modelo (`claude-opus-5-5`,
según el evento `init`), las mismas herramientas permitidas y el mismo prompt:

> Investiga los logs sintéticos (logs_sinteticos.csv), identifica incidentes justificables y distingue señales de seguridad de actividad normal. Devuelve evidencia concreta.

- **Sin skill:** carpeta aislada que solo contenía una copia del CSV. El evento `init` confirma que `incident-investigator` **no** estaba en la lista de skills. No se le dio `SKILL.md`, la referencia ni el script. Traza: [evidencias/mision5_sin_skill.md](evidencias/mision5_sin_skill.md).
- **Con skill:** carpeta aislada con la copia del CSV y el skill en `.claude/skills/incident-investigator/`. El `init` lo lista y la traza muestra la llamada `Skill` y la lectura de `detection-rules.md`. Traza: [evidencias/mision5_con_skill.md](evidencias/mision5_con_skill.md).

| Dimensión | Sin skill | Con skill | Evidencia / comentario |
|---|---|---|---|
| ¿Usó un procedimiento reproducible? | Parcial. Exploró con `head`, `Read` y conteos `awk` improvisados. Los criterios («ráfagas», «origen externo», «tasa base») son suyos y no tienen umbrales declarados. | Sí. Llamó al skill, leyó `detection-rules.md` antes de clasificar, leyó el CSV y aplicó R1–R4 con los umbrales escritos. | Orden de las llamadas en cada traza. |
| ¿Citó filas concretas? | Sí: 17–28, 33, 38–42, 57, 59, 67–74. Las llamó «líneas» y en algún caso dio rangos (`67–74` incluye las filas 69 y 72, que son de otras IP). | Sí, fila por fila: 17, 19, 20, 22, 23, 25, 26, 27, 28, 33, 59, 57, 67, 68, 70, 71, 73, 74 y los descartes. | Comprobado con `grep -n` en [hallazgos.md](hallazgos.md). |
| Alertas sustentadas | Las mismas 4 situaciones, pero las presentó como hechos: «acceso conseguido», «compromiso de credenciales», «el control de autorización se saltó», severidad «crítica». | Las 4 alertas (R1 con éxito posterior aparte, R2, R3, R4), redactadas como «probable / según el registro». | El skill separa alerta de hecho (paso 5 del procedimiento). |
| Falsos positivos detectados o evitados | Descartó a maria (3 fallos), a healthbot y los fallos sueltos. Lo argumentó con heurísticas propias (ritmo, IP «interna»). | Descartó lo mismo, pero justificado por el umbral (3 < 6) y por la coincidencia exacta (`healthcheck` ≠ `login/failed`). | Se ve en la tabla «Descartados» de cada respuesta. |
| ¿Ocultó posibles tokens? | **No.** Imprimió el valor completo del token de la fila 33 (lo redacté después para no publicarlo en el PR). | **Sí:** `token=[REDACTED]`. | Nota de redacción en la traza sin skill. |
| ¿Reconoció incertidumbre? | Poca. Mencionó la «brecha de visibilidad» y que la relación entre incidentes era una hipótesis. **No vio** que había filas duplicadas. Supuso una «red interna» y que «el atacante conoce la lista de usuarios», cosas que el log no dice. | Sí. Señaló que con los 3 pares idénticos R1 bajaría a 5 (por debajo del umbral), la resolución por minutos, que el log no dice quién hizo el `role_change`, y dejó las observaciones sin regla como tales. | Sección «Incertidumbre» de cada respuesta. |
| ¿Qué hizo gracias al skill? | — | Leyó la referencia, aplicó la ventana con extremos incluidos y la coincidencia exacta, detectó la ambigüedad de los duplicados, redactó el token, usó la tabla estándar y no atribuyó culpas ni dio recomendaciones de respuesta. | — |
| Tiempo / tokens (según el evento `result`) | 54 s · 5 turnos · 3911 tokens de salida · 0,249 USD | 46 s · 7 turnos · 3619 tokens de salida · 0,277 USD | Una sola corrida por condición: no es comparable estadísticamente. |

## Qué aportó el skill en concreto

1. **Contención de invenciones y separación alerta/hecho.** Sin skill, el modelo pasó de «8 fallos y un éxito» a «acceso conseguido» y «tratar como compromiso», y añadió suposiciones que no están en el log (red interna, enumeración previa de usuarios, acciones de respuesta). Con skill se quedó en «fuerza bruta probable» y «no prueba compromiso».
2. **Secretos.** Es la diferencia más clara y medible: sin skill el token se imprimió completo; con skill salió `[REDACTED]`.
3. **La referencia de reglas.** Gracias a ella apareció la limitación de los duplicados (19=20, 22=23, 25=26). Sin skill el modelo contó 8 fallos y no notó que, deduplicados, quedarían 5, por debajo del umbral. Es el hallazgo que más cambia la lectura del caso.
4. **Formato.** La tabla estándar con «limitaciones» por fila y la sección de verificación hacen el informe comparable entre corridas y entre CSV.
5. **Activación.** Se activó sola por la `description` en la Prueba B y en esta sesión (no se le nombró), y no se activó en el control negativo.

**Lo que no mejoró:** las dos sesiones encontraron las mismas cuatro situaciones. Con este CSV el modelo base ya detecta los patrones obvios; el skill aporta **criterio, límites y trazabilidad**, no detección adicional.

**Qué cambiaría:** en la Prueba A y en esta sesión el agente intentó ejecutar `scripts/analyze_logs.py` encadenando un `sed` de redacción. El permiso headless lo bloqueó y el agente siguió a mano. Añadiría a `SKILL.md` que el script ya redacta secretos y que debe ejecutarse sin tuberías, para que la ayuda se use de verdad.
