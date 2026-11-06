import pytest

import server


@pytest.fixture(autouse=True)
def alertas_aisladas() -> None:
    server._reiniciar_alertas()
    yield
    server._reiniciar_alertas()


def test_listar_casos_devuelve_los_tres_casos_y_sus_cantidades() -> None:
    casos = server.logica_listar_casos()

    assert casos == [
        {"caso_id": "INC-001", "sistema": "portal_acceso", "total_eventos": 2},
        {"caso_id": "INC-002", "sistema": "portal_acceso", "total_eventos": 6},
        {
            "caso_id": "INC-003",
            "sistema": "panel_administracion",
            "total_eventos": 5,
        },
    ]


def test_consultar_eventos_devuelve_los_seis_fallos_de_inc_002() -> None:
    eventos = server.logica_consultar_eventos("INC-002")

    assert len(eventos) == 6
    assert all(evento["evento"] == "LOGIN_FAILED" for evento in eventos)


def test_consultar_eventos_rechaza_un_caso_inexistente() -> None:
    with pytest.raises(ValueError, match="INC-999.*no existe"):
        server.logica_consultar_eventos("INC-999")


def test_registrar_alerta_guarda_una_alerta_valida() -> None:
    alerta = server.logica_registrar_alerta(
        "INC-003",
        "alto",
        "Cuatro fallos y un acceso exitoso; requiere revisión",
    )

    assert alerta == {
        "caso_id": "INC-003",
        "nivel": "alto",
        "motivo": "Cuatro fallos y un acceso exitoso; requiere revisión",
        "estado": "registrada",
    }


def test_registrar_alerta_rechaza_duplicados() -> None:
    server.logica_registrar_alerta("INC-003", "alto", "Primera alerta")

    with pytest.raises(ValueError, match="Ya existe una alerta"):
        server.logica_registrar_alerta("INC-003", "alto", "Alerta duplicada")


def test_registrar_alerta_rechaza_niveles_invalidos() -> None:
    with pytest.raises(ValueError, match="bajo.*medio.*alto"):
        server.logica_registrar_alerta("INC-002", "critico", "Intentos repetidos")


def test_registrar_alerta_rechaza_motivos_en_blanco() -> None:
    with pytest.raises(ValueError, match="motivo no puede estar vacío"):
        server.logica_registrar_alerta("INC-002", "medio", "   ")


def test_registrar_alerta_rechaza_casos_inexistentes() -> None:
    with pytest.raises(ValueError, match="INC-999.*no existe"):
        server.logica_registrar_alerta("INC-999", "medio", "Caso inexistente")
