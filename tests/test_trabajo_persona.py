def create_tipo_rol(client, auth_headers) -> int:
    response = client.post(
        "/api/v1/tipos-rol/",
        json={"nombre": "Academico TP"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_tipo"]


def create_rol(client, auth_headers, id_tipo: int) -> int:
    response = client.post(
        "/api/v1/roles/",
        json={"id_tipo": id_tipo, "tipo": "Rol TP"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_rol"]


def create_proyecto(client, auth_headers) -> str:
    payload = {
        "id_proyecto": "PRJ-TP-01",
        "nombre": "Proyecto TP",
        "entidad_financiadora": "Financiador TP",
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def create_trabajo(client, auth_headers, proyecto_id: str) -> int:
    payload = {
        "id_proyecto": proyecto_id,
        "nombre": "Trabajo TP",
        "facultad": "Ingenieria",
    }
    response = client.post(
        "/api/v1/trabajos-grado/",
        json=payload,
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_trabajo"]


def create_persona(client) -> int:
    payload = {
        "nombre": "Persona TP",
        "programa": "Programa",
        "documento": "5000000001",
        "correo": "tp.persona@example.com",
        "institucion": "Institucion",
        "nivel_academico": "Estudiante",
        "semestre": 6,
        "activo": True,
        "usuario": "persona_tp",
        "clave": "Secret123",
    }
    response = client.post("/api/v1/personas/", json=payload)
    assert response.status_code == 201
    return response.json()["id_persona"]


def test_trabajo_persona_list_requires_auth(client):
    response = client.get("/api/v1/trabajo-personas/")
    assert response.status_code == 401


def test_trabajo_persona_crud(client, auth_headers):
    id_tipo = create_tipo_rol(client, auth_headers)
    rol_id = create_rol(client, auth_headers, id_tipo)
    proyecto_id = create_proyecto(client, auth_headers)
    trabajo_id = create_trabajo(client, auth_headers, proyecto_id)
    persona_id = create_persona(client)

    created = client.post(
        "/api/v1/trabajo-personas/",
        json={"id_trabajo": trabajo_id, "id_persona": persona_id, "id_rol": rol_id},
        headers=auth_headers,
    )
    assert created.status_code == 201
    rel_id = created.json()["id"]

    listed = client.get("/api/v1/trabajo-personas/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(
        f"/api/v1/trabajo-personas/{rel_id}",
        headers=auth_headers,
    )
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/trabajo-personas/{rel_id}",
        json={"id_rol": rol_id},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(
        f"/api/v1/trabajo-personas/{rel_id}",
        headers=auth_headers,
    )
    assert deleted.status_code == 204

    missing = client.get(
        f"/api/v1/trabajo-personas/{rel_id}",
        headers=auth_headers,
    )
    assert missing.status_code == 404


def test_trabajo_persona_invalid_payload(client, auth_headers):
    response = client.post(
        "/api/v1/trabajo-personas/",
        json={},
        headers=auth_headers,
    )
    assert response.status_code == 422


def test_trabajo_persona_not_found(client, auth_headers):
    response = client.get("/api/v1/trabajo-personas/9999", headers=auth_headers)
    assert response.status_code == 404
