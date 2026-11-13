---
name: incident-investigator
description: >-
  Investiga logs CSV sintéticos de autenticación y seguridad (columnas tipo
  timestamp, ip, user, event, result, detail) para detectar y justificar alertas
  de incidente con evidencia por fila: fuerza bruta, password spraying, tokens o
  secretos expuestos en el detalle y cambios de rol no aprobados, separando
  señales de actividad normal y falsos positivos. Úsalo cuando se pida investigar,
  auditar o revisar registros buscando accesos sospechosos, intrusiones, ataques,
  escaladas de privilegios, secretos filtrados o "alguien entró al sistema", o
  citar filas que respalden alertas. NO lo uses para tareas solo descriptivas
  (contar eventos por hora/usuario, graficar, resumir, convertir o limpiar el
  CSV) cuando no se pide investigar incidentes, ni para logs reales de
  producción, consultas de IP en Internet o respuesta/atribución forense.
---

# incident-investigator

Guía para investigar de forma **reproducible** un log CSV sintético y entregar
**alertas justificadas** (no conclusiones forenses), cada una respaldada por
números de fila del archivo original.

## Cuándo aplicar y cuándo no

- **Aplica** si el usuario pide buscar actividad sospechosa, incidentes, intentos
  de acceso, fuerza bruta, spraying, escaladas, secretos expuestos o pide
  justificar alertas con filas.
- **No aplica** si solo pide estadísticas descriptivas (eventos por hora, por
  usuario, totales, gráficos) o transformar el archivo, y menos aún si dice
  explícitamente «no investigues incidentes». En ese caso responde la pregunta
  descriptiva sin clasificar amenazas.
- Si el archivo no tiene columnas compatibles, dilo y detente: no adaptes las
  reglas inventando equivalencias.

## Procedimiento

1. **Inspeccionar el archivo** sin modificarlo: confirma el encabezado (fila 1),
   el número de filas de datos, el formato de `timestamp` (zona horaria,
   resolución) y los valores distintos de `event` y `result`.
2. **Leer las reglas**: abre `references/detection-rules.md` **antes** de
   clasificar cualquier evento (ver la sección siguiente). No uses umbrales de
   memoria.
3. **Ordenar por `timestamp`** conservando el número de fila original de cada
   registro (encabezado = fila 1, primer dato = fila 2). Las citas siempre usan
   esa numeración original, aunque reordenes.
4. **Analizar evidencias** regla por regla, con coincidencia exacta de `event` y
   `result`. Opcional: `python scripts/analyze_logs.py <csv>` calcula ventanas y
   candidatos; su salida es una ayuda, no una prueba. Verifica a mano (por
   ejemplo con `Read` o `grep -n`) al menos las filas de cada alerta.
5. **Distinguir alerta de hecho**: el log dice lo que se registró; tú reportas
   «alerta probable según la regla X». No afirmes que hubo intrusión, quién fue
   ni intención. Un `login/success` posterior a la fuerza bruta se anota aparte
   como «éxito tras fallos», no como «cuenta comprometida».
6. **Revisar falsos positivos**: lista lo que parece sospechoso pero no alcanza
   umbral (fallos aislados, `healthcheck`, éxitos normales) y explica por qué.
7. **Reportar** con el formato de salida estándar y **declarar incertidumbre**:
   duplicados ambiguos, resolución del reloj, columnas ausentes, reglas que el
   archivo no permite evaluar.

## Cuándo abrir `references/detection-rules.md`

- Siempre en el paso 2, antes de la primera clasificación.
- De nuevo cuando un caso quede cerca de un umbral (p. ej. 5 fallos, ventana de
  exactamente 5 minutos, duplicados) o cuando dudes si un evento cuenta.
- Ese archivo es la fuente de umbrales, ventanas, convenciones y falsos
  positivos; este `SKILL.md` solo define el flujo.

## Formato de salida

1. **Resumen del archivo**: ruta, filas de datos, rango temporal, columnas.
2. **Tabla de alertas**:

| alerta | severidad orientativa | regla | timestamp (inicio–fin) | ip | usuario | filas/evidencia | limitaciones |
|---|---|---|---|---|---|---|---|

   - Severidad orientativa: `alta` / `media` / `baja`, según la referencia; es
     una prioridad de revisión, no un veredicto.
   - `filas/evidencia`: números de fila originales y, si aplica, el conteo
     (p. ej. «8 fallos: filas 17, 19, …»).
3. **Descartados / falsos positivos**: tabla corta con filas y motivo.
4. **Verificación manual**: al menos una alerta comprobada contra las filas
   originales, indicando cómo se comprobó.
5. **Incertidumbre y límites**.

## Seguridad y límites

- Solo logs **inventados/sintéticos**. Si parecen reales (datos personales,
  credenciales válidas), detente y avisa.
- **Sin red**: no consultes IP, dominios ni servicios externos (geolocalización,
  reputación, WHOIS). Las IP `192.0.2.0/24`, `198.51.100.0/24` y
  `203.0.113.0/24` son de documentación (RFC 5737): no son infraestructura real
  ni permiten atribuir a nadie.
- **No inventes** eventos, filas, usuarios ni causas. Si algo no está en el log,
  di «no consta en el registro».
- **Nunca muestres secretos**: cualquier valor después de `token=` (o
  `password=`, `secret=`, `key=`) se escribe `token=[REDACTED]`, también en
  tablas, comandos y citas de filas.
- **No modifiques** el CSV original; si necesitas transformar, trabaja en
  memoria o en una copia temporal.
