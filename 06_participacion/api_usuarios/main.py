import logging
import os
from typing import Annotated

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException
from pydantic import BaseModel, EmailStr, Field, SecretStr, field_validator
from supabase import Client, create_client

load_dotenv()
logger = logging.getLogger(__name__)

app = FastAPI(title="API de usuarios USFQ")


class NuevoUsuario(BaseModel):
    correo: EmailStr
    clave: SecretStr = Field(min_length=6)
    nombre: str = Field(min_length=1, max_length=120)

    @field_validator("nombre")
    @classmethod
    def limpiar_nombre(cls, nombre: str) -> str:
        nombre = nombre.strip()
        if not nombre:
            raise ValueError("El nombre es obligatorio.")
        return nombre


class UsuarioCreado(BaseModel):
    ok: bool
    id: str


def obtener_cliente_admin() -> Client:
    url = os.getenv("SUPABASE_URL", "").strip()
    clave_secreta = os.getenv("SUPABASE_SECRET", "").strip()
    if not url or not clave_secreta:
        raise HTTPException(
            status_code=503,
            detail="La API no tiene configurada su conexión con Supabase.",
        )
    return create_client(url, clave_secreta)


ClienteAdmin = Annotated[Client, Depends(obtener_cliente_admin)]


@app.post("/usuarios", response_model=UsuarioCreado, status_code=201)
def crear_usuario(usuario: NuevoUsuario, cliente: ClienteAdmin) -> UsuarioCreado:
    try:
        respuesta = cliente.auth.admin.create_user(
            {
                "email": str(usuario.correo),
                "password": usuario.clave.get_secret_value(),
                "email_confirm": True,
            }
        )
    except Exception as error:
        logger.error(
            "Supabase rechazó la creación de la cuenta (%s).",
            type(error).__name__,
        )
        raise HTTPException(
            status_code=502,
            detail="No fue posible crear la cuenta en Supabase.",
        ) from error

    usuario_creado = getattr(respuesta, "user", None)
    usuario_id = getattr(usuario_creado, "id", None)
    if not usuario_id:
        raise HTTPException(
            status_code=502,
            detail="Supabase no devolvió el identificador del usuario.",
        )

    try:
        cliente.table("perfiles").insert(
            {"id": usuario_id, "nombre": usuario.nombre}
        ).execute()
    except Exception as error:
        logger.error(
            "Supabase no pudo crear el perfil (%s).",
            type(error).__name__,
        )
        try:
            cliente.auth.admin.delete_user(usuario_id)
        except Exception as error_reversion:
            logger.error(
                "Falló la limpieza de la cuenta incompleta (%s).",
                type(error_reversion).__name__,
            )
        raise HTTPException(
            status_code=502,
            detail="No fue posible crear el perfil del usuario.",
        ) from error

    return UsuarioCreado(ok=True, id=str(usuario_id))
