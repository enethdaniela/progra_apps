# Participación 6 — Respuestas

## 1. ¿Dónde quedan los datos y qué implica abrir la app en otro teléfono?

Las credenciales y los perfiles se guardan en el proyecto Supabase: las cuentas en
`auth.users` y los nombres en la tabla `perfiles`. La app consulta el servicio remoto, así
que una persona que inicie sesión desde otro teléfono puede ver los mismos perfiles,
siempre que tenga conexión y las políticas de acceso lo permitan.

## 2. ¿Por qué la clave publicable puede ir en Flutter y la secreta no?

La clave publicable identifica al cliente y está diseñada para quedar expuesta en la app;
no concede privilegios por sí sola. Las políticas RLS limitan qué operaciones puede hacer
una sesión. La clave secreta tiene privilegios administrativos y puede omitir RLS, por lo
que debe permanecer en el servidor y en variables de entorno no versionadas.

## 3. ¿Qué necesita un compañero que clona el repositorio?

Necesita configurar su propio `.env` local con la URL y la clave publicable de Supabase, y
contar con acceso al proyecto y sus políticas. Es correcto que el archivo no esté en Git:
evita publicar configuración local. Si se subiera una clave por error, borrarla en otro
commit no la revoca; se debe rotar/revocar en Supabase y limpiar el historial según el
procedimiento del repositorio.

## 4. ¿Qué ocurre si se intenta borrar perfiles usando la clave publicable?

La clave publicable no elimina las políticas RLS. Como las políticas de la práctica solo
permiten consultar perfiles e insertar el perfil propio, una operación de borrado no tiene
una política que la autorice y Supabase la rechaza. La clave secreta sí podría eludir RLS,
por eso nunca debe ir en Flutter.

## 5. ¿Por qué separar los providers y nombrar las implementaciones en `main.dart`?

`SesionProvider` administra registro, ingreso y cierre de sesión; `PerfilesProvider`
administra la carga de la lista. Separarlos evita mezclar estados y razones de cambio.
`main.dart` compone las interfaces de dominio con las implementaciones Supabase; así
presentación depende de contratos y no queda acoplada al proveedor concreto de datos.

## 6. ¿Dónde se guarda la contraseña?

La contraseña la administra Supabase Authentication (`auth.users`); la app no debe
guardarla en `perfiles` ni en almacenamiento propio. Supabase gestiona su protección y la
app solo la envía durante registro o ingreso por HTTPS. La comprobación real de las tablas
Authentication → Users y Table Editor → perfiles debe hacerse en el proyecto Supabase
configurado; no se afirma aquí haber inspeccionado una cuenta real.

## 7. ¿Por qué el servidor puede crear usuarios y la app no?

El servidor puede usar la clave secreta para llamar a `auth.admin.create_user`; Flutter solo
debe usar la clave publicable, que no ofrece esa operación administrativa. Si la app
necesita esa capacidad, debe llamar a un endpoint autenticado y validado. Así se mantiene
la clave secreta fuera del dispositivo y se puede aplicar control de acceso y validación
en el servidor. El costo es operar y proteger un backend, autenticar sus solicitudes,
limitar abusos y manejar errores. No se debe poner la clave secreta en Flutter.

## Verificación pendiente en el entorno de Supabase

El código y las pruebas locales no sustituyen la configuración del servicio externo.
Antes de la demostración, confirma en el panel que existe `perfiles` con las políticas RLS
de la guía, que la confirmación de correo está desactivada para esta práctica, que el `.env`
Flutter contiene únicamente la clave publicable y que el `.env` de `api_usuarios` contiene
la clave secreta. Luego prueba registro, reingreso, lectura de perfiles y `POST /usuarios`
con una cuenta de prueba.
