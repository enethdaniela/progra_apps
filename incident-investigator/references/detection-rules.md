# Reglas de detección — incident-investigator

Fuente de verdad para umbrales y convenciones. Las reglas producen **alertas
justificadas**, no conclusiones forenses.

## Convenciones comunes

- **Numeración**: el encabezado es la fila 1; el primer registro es la fila 2.
  Cita siempre la fila del archivo original, aunque reordenes.
- **Orden**: ordena por `timestamp` (orden estable: empates conservan el orden
  original) antes de evaluar ventanas.
- **Ventana**: dura **≤ 5 minutos incluyendo ambos extremos**
  (`t_fin − t_inicio ≤ 5 min`). Ej.: 01:14 y 01:19 caben en la misma ventana;
  01:14 y 01:20 no.
- **Coincidencia exacta**: un evento cuenta solo si `event` y `result` coinciden
  literalmente con la regla (`login` + `failed`). `healthcheck`, `access/denied`
  o `debug/warning` **no** son `login/failed`.
- **Duplicados**: filas con todos los campos idénticos pueden ser intentos
  distintos dentro del mismo minuto o un registro duplicado. Si el archivo no
  trae un identificador de evento o resolución de segundos, **no los elimines**:
  cuenta las filas tal como están y anota en `limitaciones` cuántas filas son
  idénticas y si la alerta seguiría alcanzando el umbral sin ellas.
- **Zona horaria**: usa el desfase del propio `timestamp`; no lo conviertas a
  otra zona salvo que se pida.

## R1 — Fuerza bruta probable (severidad orientativa: alta)

- **Condición**: ≥ 6 eventos `login/failed` desde la **misma `ip`** hacia el
  **mismo `user`** dentro de una ventana de 5 minutos.
- **Evidencia**: lista de filas de los fallos, primer y último timestamp, conteo.
- **Anotación aparte — éxito tras fallos**: si existe un `login/success` de la
  misma `ip` y el mismo `user` en los **5 minutos siguientes** al último fallo de
  la ventana, repórtalo como fila separada («éxito posterior, fila N»). Eleva la
  prioridad de revisión, pero **no** prueba que la cuenta esté comprometida.

## R2 — Password spraying probable (severidad orientativa: alta)

- **Condición**: eventos `login/failed` desde la **misma `ip`** contra **al menos
  5 usuarios distintos** dentro de una ventana de 5 minutos.
- **Evidencia**: filas, lista de usuarios distintos y conteo.
- Si la misma IP también cumple R1 contra un usuario, reporta ambas alertas.
- Comprueba si hubo algún `login/success` de esa IP en la ventana o justo
  después; si no lo hay, dilo explícitamente («sin éxito registrado»).

## R3 — Token potencialmente expuesto (severidad orientativa: media/alta)

- **Condición**: el campo `detail` contiene la subcadena `token=`.
- **Salida**: cita la fila con el valor reemplazado: `token=[REDACTED]`.
  **Nunca** imprimas el valor completo ni parcial (ni prefijos, ni longitud).
- Aunque el valor diga «demo» o «not real», trátalo igual: la regla es sobre la
  práctica de registrar secretos, no sobre su validez.
- Extensión prudente: `password=`, `secret=`, `api_key=` se redactan igual; si
  aparecen, repórtalos como misma categoría indicando que es una extensión.

## R4 — Escalada no autorizada según el registro (severidad orientativa: alta)

- **Condición**: `event = role_change`, `result = success` y `detail` contiene
  `approved=false`.
- **Evidencia**: fila, usuario, rol origen → destino si consta.
- Puedes citar como **contexto** eventos cercanos del mismo usuario o IP (p. ej.
  `access/denied` previo), pero no inventes una cadena causal.
- **No infieras culpabilidad**: el registro indica que el cambio no consta como
  aprobado; no dice quién lo hizo ni por qué.

## Falsos positivos y casos que NO son alerta

- **Fallos aislados**: menos de 6 `login/failed` misma IP→mismo usuario en 5
  minutos no cumplen R1 (p. ej. 3 fallos seguidos de un éxito es compatible con
  un usuario que se equivocó de contraseña). Repórtalos en «descartados» con su
  conteo.
- **Monitoreo**: `healthcheck/success` repetidos (cuentas tipo `healthbot`) son
  actividad programada, no fallos de login.
- **Fallos sueltos dispersos** de distintas IP/usuarios no forman R1 ni R2.
- **`access/denied`** por sí solo no es ninguna de estas reglas; puede citarse
  como contexto.

## Reglas que no existen

Si observas algo que te parece raro pero no encaja en R1–R4, menciónalo como
«observación sin regla» en la sección de incertidumbre. No crees umbrales nuevos.
