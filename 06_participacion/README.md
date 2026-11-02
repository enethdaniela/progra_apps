# Participación 6 — Usuarios con Supabase

La app Flutter permite registrar e iniciar sesión, y después consulta una lista compartida
de perfiles. La capa de datos implementa Supabase; las pantallas solo dependen de providers
y dominio.

## Configuración

1. Crea `.env` en esta carpeta a partir de `.env.example` y define `SUPABASE_URL` y
   `SUPABASE_KEY` con la URL y la clave publicable de tu proyecto. Nunca pongas aquí la
   clave secreta.
2. En el SQL Editor de Supabase ejecuta [`supabase_setup.sql`](supabase_setup.sql) para
   crear `perfiles` y activar las políticas RLS de lectura e inserción.
3. Para que el registro seguido de creación de perfil deje una sesión activa durante esta
   práctica, desactiva la confirmación de correo en el proveedor Email de Supabase.
4. Ejecuta:

   ```powershell
   flutter pub get
   flutter run
   ```

El archivo `.env` local está ignorado por Git. Flutter incluye la clave publicable en la
app compilada; RLS, no la ocultación de esa clave, protege los datos.

## Pruebas locales

```powershell
flutter test
flutter analyze
```

Las pruebas usan repositorios falsos y no crean usuarios en Supabase. La API administrativa
está en `api_usuarios/`; su configuración y pruebas están descritas en
[`api_usuarios/README.md`](api_usuarios/README.md).
