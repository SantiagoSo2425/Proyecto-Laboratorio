def test_rol_list_requires_auth(client):
    response = client.get("/api/v1/roles/")
    assert response.status_code == 401


def test_rol_crud(client, auth_headers):
    tipo = client.post(
        "/api/v1/tipos-rol/",
        json={"nombre": "Gestion"},
        headers=auth_headers,
    )
    assert tipo.status_code == 201
    tipo_id = tipo.json()["id_tipo"]

    created = client.post(
        "/api/v1/roles/",
        json={"id_tipo": tipo_id, "tipo": "Editor"},
        headers=auth_headers,
    )
    assert created.status_code == 201
    rol_id = created.json()["id_rol"]

    listed = client.get("/api/v1/roles/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/roles/{rol_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/roles/{rol_id}",
        json={"tipo": "Editor Senior"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["tipo"] == "Editor Senior"

    deleted = client.delete(f"/api/v1/roles/{rol_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/roles/{rol_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_rol_delete_in_use_is_blocked(client, auth_headers):
    tipo = client.post(
        "/api/v1/tipos-rol/",
        json={"nombre": "Soporte"},
        headers=auth_headers,
    )
    assert tipo.status_code == 201
    tipo_id = tipo.json()["id_tipo"]

    rol = client.post(
        "/api/v1/roles/",
        json={"id_tipo": tipo_id, "tipo": "Rol En Uso"},
        headers=auth_headers,
    )
    assert rol.status_code == 201
    rol_id = rol.json()["id_rol"]

    institucion = client.post(
        "/api/v1/instituciones/",
        json={"nombre": "Institucion Rol Test"},
        headers=auth_headers,
    )
    assert institucion.status_code == 201
    institucion_id = institucion.json()["id_institucion"]

    proyecto = client.post(
        "/api/v1/proyectos/",
        json={
            "id_proyecto": "PRJ-ROL-USE",
            "nombre": "Proyecto Rol",
            "entidad_financiadora": "Financiador",
            "tipo": "investigacion",
            "institucion_ids": [institucion_id],
        },
        headers=auth_headers,
    )
    assert proyecto.status_code == 201

    persona = client.post(
        "/api/v1/personas/",
        json={
            "nombre": "Persona Rol",
            "programa": "Programa",
            "documento": "9000000001",
            "correo": "persona.rol@example.com",
            "nivel_academico": "Estudiante",
            "semestre": 1,
            "activo": True,
            "usuario": "persona_rol",
            "clave": "Secret123",
            "institucion_ids": [institucion_id],
        },
    )
    assert persona.status_code == 201

    rel = client.post(
        "/api/v1/proyecto-personas/",
        json={
            "id_proyecto": "PRJ-ROL-USE",
            "persona_id": persona.json()["id_persona"],
            "id_rol": rol_id,
            "horas_semanales": 10,
            "fecha_inicio": "2026-03-01",
            "fecha_fin": None,
        },
        headers=auth_headers,
    )
    assert rel.status_code == 201

    deleted = client.delete(f"/api/v1/roles/{rol_id}", headers=auth_headers)
    assert deleted.status_code == 400
    assert "rol en uso" in deleted.json()["detail"].lower()


def test_rol_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/roles/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_rol_not_found(client, auth_headers):
    response = client.get("/api/v1/roles/9999", headers=auth_headers)
    assert response.status_code == 404
