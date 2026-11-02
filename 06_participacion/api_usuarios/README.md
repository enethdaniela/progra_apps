# API de usuarios con FastAPI

Este servicio crea una cuenta en Supabase Auth y su fila en `perfiles`. La clave
`SUPABASE_SECRET` es privilegiada y solo se carga en el servidor; nunca se copies a Flutter
ni la subas al repositorio.

## Configuración local

1. Desde esta carpeta, crea un entorno e instala dependencias:

   ```powershell
   py -m venv .venv
   .\.venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

2. Copia `.env.example` a `.env` y completa `SUPABASE_URL` y `SUPABASE_SECRET` con los
   valores del proyecto Supabase. No compartas ni confirmes `.env`.
3. Inicia el servidor:

   ```powershell
   uvicorn main:app --reload
   ```

4. Abre <http://127.0.0.1:8000/docs> y prueba `POST /usuarios` con correo, clave y nombre.

Si falla la inserción del perfil después de crear la cuenta, el endpoint intenta borrar la
cuenta incompleta y devuelve un error genérico, sin exponer detalles internos.
Este endpoint administrativo no implementa autenticación del cliente ni limitación de
solicitudes: úsalo solo localmente para la práctica, no lo publiques en internet.

## Pruebas sin Supabase

```powershell
pytest -q
```

Las pruebas inyectan un cliente falso; no necesitan credenciales ni crean usuarios reales.
