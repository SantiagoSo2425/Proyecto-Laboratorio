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


def test_rol_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/roles/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_rol_not_found(client, auth_headers):
    response = client.get("/api/v1/roles/9999", headers=auth_headers)
    assert response.status_code == 404
