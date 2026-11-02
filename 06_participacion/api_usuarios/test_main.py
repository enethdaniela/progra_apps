from types import SimpleNamespace

import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient

from main import app, obtener_cliente_admin


class FakeAdmin:
    def __init__(self):
        self.deleted_users = []

    def create_user(self, payload):
        self.payload = payload
        return SimpleNamespace(user=SimpleNamespace(id="user-123"))

    def delete_user(self, user_id):
        self.deleted_users.append(user_id)


class FakeAuth:
    def __init__(self):
        self.admin = FakeAdmin()


class FakeTable:
    def __init__(self, client):
        self.client = client

    def insert(self, row):
        self.client.inserted_row = row
        return self

    def execute(self):
        if self.client.fail_profile_insert:
            raise RuntimeError("database failure")


class FakeClient:
    def __init__(self, fail_profile_insert=False):
        self.auth = FakeAuth()
        self.fail_profile_insert = fail_profile_insert
        self.inserted_row = None

    def table(self, table_name):
        assert table_name == "perfiles"
        return FakeTable(self)


@pytest.fixture
def client():
    fake = FakeClient()
    app.dependency_overrides[obtener_cliente_admin] = lambda: fake
    with TestClient(app) as test_client:
        yield test_client, fake
    app.dependency_overrides.clear()


def test_crea_usuario_y_perfil_con_clave_confirmada(client):
    test_client, fake = client

    respuesta = test_client.post(
        "/usuarios",
        json={
            "correo": "robot@usfq.edu.ec",
            "clave": "clave-segura-123",
            "nombre": "  Robot FastAPI  ",
        },
    )

    assert respuesta.status_code == 201
    assert respuesta.json() == {"ok": True, "id": "user-123"}
    assert fake.auth.admin.payload["email_confirm"] is True
    assert fake.inserted_row == {"id": "user-123", "nombre": "Robot FastAPI"}
    assert "clave" not in respuesta.text


def test_limpia_cuenta_si_falla_la_creacion_del_perfil():
    fake = FakeClient(fail_profile_insert=True)
    app.dependency_overrides[obtener_cliente_admin] = lambda: fake
    try:
        with TestClient(app) as test_client:
            respuesta = test_client.post(
                "/usuarios",
                json={
                    "correo": "robot@usfq.edu.ec",
                    "clave": "clave-segura-123",
                    "nombre": "Robot",
                },
            )
    finally:
        app.dependency_overrides.clear()

    assert respuesta.status_code == 502
    assert respuesta.json()["detail"] == (
        "No fue posible crear el perfil del usuario."
    )
    assert fake.auth.admin.deleted_users == ["user-123"]
    assert "database failure" not in respuesta.text


@pytest.mark.parametrize(
    ("payload", "field"),
    [
        (
            {"correo": "no-es-correo", "clave": "clave-segura", "nombre": "Ana"},
            "correo",
        ),
        (
            {"correo": "ana@example.com", "clave": "123", "nombre": "Ana"},
            "clave",
        ),
        (
            {"correo": "ana@example.com", "clave": "clave-segura", "nombre": " "},
            "nombre",
        ),
    ],
)
def test_rechaza_datos_invalidos(payload, field):
    fake = FakeClient()
    app.dependency_overrides[obtener_cliente_admin] = lambda: fake
    try:
        with TestClient(app) as test_client:
            respuesta = test_client.post("/usuarios", json=payload)
    finally:
        app.dependency_overrides.clear()

    assert respuesta.status_code == 422
    assert any(error["loc"][-1] == field for error in respuesta.json()["detail"])
    assert fake.auth.admin.deleted_users == []
    assert fake.inserted_row is None


def test_informa_si_falta_configuracion():
    with pytest.MonkeyPatch.context() as monkeypatch:
        monkeypatch.delenv("SUPABASE_URL", raising=False)
        monkeypatch.delenv("SUPABASE_SECRET", raising=False)
        with pytest.raises(HTTPException) as error:
            obtener_cliente_admin()

    assert error.value.status_code == 503
