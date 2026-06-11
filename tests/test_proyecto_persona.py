def create_tipo_rol(client, auth_headers) -> int:
    response = client.post(
        "/api/v1/tipos-rol/",
        json={"nombre": "Academico Test"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_tipo"]


def create_rol(client, auth_headers, id_tipo: int) -> int:
    response = client.post(
        "/api/v1/roles/",
        json={"id_tipo": id_tipo, "tipo": "Rol Test"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_rol"]


def create_proyecto(client, auth_headers) -> str:
    institucion = client.post(
        "/api/v1/instituciones/",
        json={"nombre": "Institucion PP Proyecto"},
        headers=auth_headers,
    )
    assert institucion.status_code == 201
    institucion_id = institucion.json()["id_institucion"]

    payload = {
        "id_proyecto": "PRJ-PP-01",
        "nombre": "Proyecto PP",
        "entidad_financiadora": "Financiador PP",
        "tipo": "investigacion",
        "institucion_ids": [institucion_id],
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def create_persona(client) -> int:
    payload = {
        "nombre": "Persona PP",
        "programa": "Programa",
        "documento": "4000000001",
        "correo": "pp.persona@example.com",
        "nivel_academico": "Estudiante",
        "semestre": 2,
        "activo": True,
        "usuario": "persona_pp",
        "clave": "Secret123",
        "institucion_ids": [],
    }
    response = client.post("/api/v1/personas/", json=payload)
    assert response.status_code == 201
    return response.json()["id_persona"]


def test_proyecto_persona_list_requires_auth(client):
    response = client.get("/api/v1/proyecto-personas/")
    assert response.status_code == 401


def test_proyecto_persona_crud(client, auth_headers):
    id_tipo = create_tipo_rol(client, auth_headers)
    rol_id = create_rol(client, auth_headers, id_tipo)
    proyecto_id = create_proyecto(client, auth_headers)
    persona_id = create_persona(client)

    created = client.post(
        "/api/v1/proyecto-personas/",
        json={
            "id_proyecto": proyecto_id,
            "persona_id": persona_id,
            "id_rol": rol_id,
            "horas_semanales": 10,
            "fecha_inicio": "2026-03-01",
            "fecha_fin": None,
        },
        headers=auth_headers,
    )
    assert created.status_code == 201
    rel_id = created.json()["id"]

    listed = client.get("/api/v1/proyecto-personas/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(
        f"/api/v1/proyecto-personas/{rel_id}",
        headers=auth_headers,
    )
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/proyecto-personas/{rel_id}",
        json={"horas_semanales": 12, "fecha_fin": "2026-12-31"},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(
        f"/api/v1/proyecto-personas/{rel_id}",
        headers=auth_headers,
    )
    assert deleted.status_code == 204

    missing = client.get(
        f"/api/v1/proyecto-personas/{rel_id}",
        headers=auth_headers,
    )
    assert missing.status_code == 404


def test_proyecto_persona_invalid_payload(client, auth_headers):
    response = client.post(
        "/api/v1/proyecto-personas/",
        json={},
        headers=auth_headers,
    )
    assert response.status_code == 422


def test_proyecto_persona_not_found(client, auth_headers):
    response = client.get("/api/v1/proyecto-personas/9999", headers=auth_headers)
    assert response.status_code == 404
