def test_producto_list_requires_auth(client):
    response = client.get("/api/v1/productos/")
    assert response.status_code == 401


def test_producto_crud(client, auth_headers):
    created = client.post(
        "/api/v1/productos/",
        json={"descripcion": "Producto Test"},
        headers=auth_headers,
    )
    assert created.status_code == 201
    producto_id = created.json()["id_producto"]

    listed = client.get("/api/v1/productos/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/productos/{producto_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/productos/{producto_id}",
        json={"descripcion": "Producto Actualizado"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["descripcion"] == "Producto Actualizado"

    deleted = client.delete(f"/api/v1/productos/{producto_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/productos/{producto_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_producto_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/productos/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_producto_not_found(client, auth_headers):
    response = client.get("/api/v1/productos/9999", headers=auth_headers)
    assert response.status_code == 404
