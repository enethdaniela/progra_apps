# Hallazgos — `logs_sinteticos.csv`

Informe producido con el skill `incident-investigator` (Prueba A, traza en
[evidencias/activacion_explicita.md](evidencias/activacion_explicita.md)) y
verificado a mano contra el CSV original. Son **alertas justificadas según las
reglas** de [detection-rules.md](incident-investigator/references/detection-rules.md),
no conclusiones forenses.

## Archivo

- 93 filas de datos (filas 2–94; el encabezado es la fila 1). No se modificó.
- Columnas: `timestamp, ip, user, event, result, detail`.
- Rango: 2026-11-05 de 01:01 a 02:29 (`-05:00`), con resolución de minutos. El archivo ya venía ordenado por `timestamp`.
- Todas las IP son de rangos de documentación (RFC 5737). No se consultó ninguna.

## Alertas

| alerta | severidad orientativa | regla | timestamp (inicio–fin) | ip | usuario | filas/evidencia | limitaciones |
|---|---|---|---|---|---|---|---|
| Fuerza bruta probable | alta | R1 | 01:14–01:18 | 198.51.100.77 | admin | 8 × `login/failed`: filas 17, 19, 20, 22, 23, 25, 26, 27 | Hay 3 pares idénticos (19=20, 22=23, 25=26). Si fueran duplicados de registro quedarían 5 fallos, por debajo del umbral. Sin segundos ni ID de evento no se puede decidir, así que se cuentan las filas tal cual. |
| ↳ Éxito tras fallos (anotación aparte) | eleva prioridad | R1 | 01:19 | 198.51.100.77 | admin | Fila 28: `login/success`, «login after multiple failures», 1 min después del último fallo | No prueba que la cuenta esté comprometida. |
| Password spraying probable | alta | R2 | 02:01–02:03 | 203.0.113.89 | ana, carlos, luisa, diego, maria, sofia | 6 × `login/failed` contra 6 usuarios distintos: filas 67, 68, 70, 71, 73, 74 | No hay ningún `success` de esa IP en todo el archivo. |
| Token potencialmente expuesto | media/alta | R3 | 01:27 | 192.0.2.44 | api_service | Fila 33: `debug/warning`, `token=[REDACTED]; debug output` | Parece un valor de demostración, pero la regla evalúa la práctica de registrar secretos. |
| Escalada no autorizada según el registro | alta | R4 | 01:50 | 203.0.113.42 | guest | Fila 59: `role_change/success`, `role=user->admin; approved=false` | Contexto: fila 57 (01:49), `access/denied` a `/admin` de la misma IP y usuario. El log no dice quién hizo el cambio ni que una cosa causara la otra. |

## Descartados / falsos positivos

| filas | motivo |
|---|---|
| 38, 39, 41 → 42 | 192.0.2.25 → maria: 3 fallos («mistyped password») y luego un éxito. No alcanza el umbral de R1 (ver abajo). |
| 78, 80–84 | `healthbot`: 6 × `healthcheck/success` cada minuto. Es monitoreo programado, no `login/failed`. |
| 57 | `access/denied` aislado. No cumple ninguna regla; solo es contexto de R4. |
| 3, 7, 14, 24, 31, 34, 46, 47, 51, 60, 87 | Fallos sueltos `ordinary login` de 192.0.2.10–13. Ningún par IP→usuario llega a 6 fallos en 5 min ni ninguna IP a 5 usuarios. |

## Verificación manual (hecha por mí, no por el modelo)

Comprobé las alertas R1 y R2 y el descarte de maria con `grep -n`. Como el CSV
no tiene campos multilínea, el número que da `grep -n` es la fila del archivo
(encabezado = 1).

```text
$ grep -n "198.51.100.77" logs_sinteticos.csv
17:2026-11-05T01:14:00-05:00,198.51.100.77,admin,login,failed,incorrect password
19:2026-11-05T01:15:00-05:00,198.51.100.77,admin,login,failed,incorrect password
20:2026-11-05T01:15:00-05:00,198.51.100.77,admin,login,failed,incorrect password
22:2026-11-05T01:16:00-05:00,198.51.100.77,admin,login,failed,incorrect password
23:2026-11-05T01:16:00-05:00,198.51.100.77,admin,login,failed,incorrect password
25:2026-11-05T01:17:00-05:00,198.51.100.77,admin,login,failed,incorrect password
26:2026-11-05T01:17:00-05:00,198.51.100.77,admin,login,failed,incorrect password
27:2026-11-05T01:18:00-05:00,198.51.100.77,admin,login,failed,incorrect password
28:2026-11-05T01:19:00-05:00,198.51.100.77,admin,login,success,login after multiple failures
```

- **R1:** son 8 filas `login,failed` exactas, misma IP y mismo usuario. La ventana va de 01:14 a 01:18: 4 min, que es ≤ 5. Como 8 ≥ 6, se cumple. La fila 28 cae 1 min después del último fallo, dentro de los 5 min siguientes. Coincide con lo que dijo el modelo.
- **R2:** `grep -n "203.0.113.89"` devuelve solo las filas 67, 68, 70, 71, 73 y 74, todas `login,failed`, con 6 usuarios distintos entre 02:01 y 02:03. No hay ningún `success`.
- **Duplicados:** las filas 19/20, 22/23 y 25/26 son idénticas campo por campo. Por eso dejé la limitación anotada en lugar de inventar una regla para eliminarlas.

### Por qué los 3 fallos de maria no son fuerza bruta

```text
$ grep -n "192.0.2.25" logs_sinteticos.csv
38:2026-11-05T01:35:00-05:00,192.0.2.25,maria,login,failed,mistyped password
39:2026-11-05T01:36:00-05:00,192.0.2.25,maria,login,failed,mistyped password
41:2026-11-05T01:37:00-05:00,192.0.2.25,maria,login,failed,mistyped password
42:2026-11-05T01:38:00-05:00,192.0.2.25,maria,login,success,legitimate user
```

R1 exige **6 o más** `login/failed` de la misma IP al mismo usuario en 5
minutos. Aquí hay 3, uno por minuto, y después un éxito. Es la mitad del
umbral y encaja con alguien que se equivocó al escribir la contraseña. Que el
`detail` diga «legitimate user» no es la razón del descarte (es texto del
propio log); la razón es que no se alcanza el umbral. Tampoco hay otros fallos
de maria desde 192.0.2.25.

## Incertidumbre

- R1 depende de que las 3 parejas idénticas sean intentos distintos y no duplicados de registro.
- Con resolución de minutos no se puede ordenar con precisión dentro del mismo minuto.
- El log no registra quién ejecutó el `role_change` ni qué pasó después de las filas 28 y 59.
- R2 y R4 vienen de IP del mismo rango de documentación (203.0.113.0/24). Ninguna regla relaciona ambas, así que no se afirma que estén vinculadas.
