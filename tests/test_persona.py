def persona_payload() -> dict:
    return {
        "nombre": "Persona Test",
        "programa": "Programa Test",
        "documento": "2000000001",
        "correo": "persona.test@example.com",
        "institucion": "Institucion Test",
        "nivel_academico": "Estudiante",
        "semestre": 4,
        "activo": True,
        "usuario": "persona_test",
        "clave": "Secret123",
    }


def test_persona_list_requires_auth(client):
    response = client.get("/api/v1/personas/")
    assert response.status_code == 401


def test_persona_crud(client, auth_headers):
    create = client.post("/api/v1/personas/", json=persona_payload())
    assert create.status_code == 201
    persona_id = create.json()["id_persona"]

    listed = client.get("/api/v1/personas/", headers=auth_headers)
    assert listed.status_code == 200
    assert len(listed.json()) >= 1

    fetched = client.get(f"/api/v1/personas/{persona_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/personas/{persona_id}",
        json={"nombre": "Persona Actualizada"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["nombre"] == "Persona Actualizada"

    deleted = client.delete(f"/api/v1/personas/{persona_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/personas/{persona_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_persona_invalid_payload(client):
    response = client.post("/api/v1/personas/", json={"nombre": "X"})
    assert response.status_code == 422


def test_persona_not_found(client, auth_headers):
    response = client.get("/api/v1/personas/9999", headers=auth_headers)
    assert response.status_code == 404
