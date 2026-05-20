def test_tipo_rol_list_requires_auth(client):
    response = client.get("/api/v1/tipos-rol/")
    assert response.status_code == 401


def test_tipo_rol_crud(client, auth_headers):
    created = client.post(
        "/api/v1/tipos-rol/",
        json={"nombre": "Soporte"},
        headers=auth_headers,
    )
    assert created.status_code == 201
    tipo_id = created.json()["id_tipo"]

    listed = client.get("/api/v1/tipos-rol/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/tipos-rol/{tipo_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/tipos-rol/{tipo_id}",
        json={"nombre": "Soporte 2"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["nombre"] == "Soporte 2"

    deleted = client.delete(f"/api/v1/tipos-rol/{tipo_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/tipos-rol/{tipo_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_tipo_rol_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/tipos-rol/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_tipo_rol_not_found(client, auth_headers):
    response = client.get("/api/v1/tipos-rol/9999", headers=auth_headers)
    assert response.status_code == 404
