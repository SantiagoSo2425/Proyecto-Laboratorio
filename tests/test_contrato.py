def create_proyecto(client, auth_headers) -> str:
    payload = {
        "id_proyecto": "PRJ-CT-01",
        "nombre": "Proyecto Contrato",
        "entidad_financiadora": "Financiador CT",
        "tipo": "investigacion",
        "institucion_ids": [],
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def create_persona(client) -> int:
    payload = {
        "nombre": "Persona Contrato",
        "programa": "Programa",
        "documento": "3000000001",
        "correo": "contrato.persona@example.com",
        "nivel_academico": "Estudiante",
        "semestre": 3,
        "activo": True,
        "usuario": "persona_contrato",
        "clave": "Secret123",
        "institucion_ids": [],
    }
    response = client.post("/api/v1/personas/", json=payload)
    assert response.status_code == 201
    return response.json()["id_persona"]


def test_contrato_list_requires_auth(client):
    response = client.get("/api/v1/contratos/")
    assert response.status_code == 401


def test_contrato_crud(client, auth_headers):
    proyecto_id = create_proyecto(client, auth_headers)
    persona_id = create_persona(client)

    created = client.post(
        "/api/v1/contratos/",
        json={"id_proyecto": proyecto_id, "id_persona": persona_id},
        headers=auth_headers,
    )
    assert created.status_code == 201
    contrato_id = created.json()["id"]

    listed = client.get("/api/v1/contratos/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/contratos/{contrato_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/contratos/{contrato_id}",
        json={"id_proyecto": proyecto_id, "id_persona": persona_id},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(f"/api/v1/contratos/{contrato_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/contratos/{contrato_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_contrato_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/contratos/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_contrato_not_found(client, auth_headers):
    response = client.get("/api/v1/contratos/9999", headers=auth_headers)
    assert response.status_code == 404
