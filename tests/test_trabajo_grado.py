def create_proyecto(client, auth_headers) -> str:
    payload = {
        "id_proyecto": "PRJ-TG-01",
        "nombre": "Proyecto TG",
        "entidad_financiadora": "Financiador TG",
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def test_trabajo_grado_list_requires_auth(client):
    response = client.get("/api/v1/trabajos-grado/")
    assert response.status_code == 401


def test_trabajo_grado_crud(client, auth_headers):
    proyecto_id = create_proyecto(client, auth_headers)
    payload = {
        "id_proyecto": proyecto_id,
        "nombre": "Trabajo Test",
        "facultad": "Ingenieria",
    }
    created = client.post(
        "/api/v1/trabajos-grado/",
        json=payload,
        headers=auth_headers,
    )
    assert created.status_code == 201
    trabajo_id = created.json()["id_trabajo"]

    listed = client.get("/api/v1/trabajos-grado/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(
        f"/api/v1/trabajos-grado/{trabajo_id}",
        headers=auth_headers,
    )
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/trabajos-grado/{trabajo_id}",
        json={"nombre": "Trabajo Actualizado"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["nombre"] == "Trabajo Actualizado"

    deleted = client.delete(
        f"/api/v1/trabajos-grado/{trabajo_id}",
        headers=auth_headers,
    )
    assert deleted.status_code == 204

    missing = client.get(
        f"/api/v1/trabajos-grado/{trabajo_id}",
        headers=auth_headers,
    )
    assert missing.status_code == 404


def test_trabajo_grado_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/trabajos-grado/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_trabajo_grado_not_found(client, auth_headers):
    response = client.get("/api/v1/trabajos-grado/9999", headers=auth_headers)
    assert response.status_code == 404
