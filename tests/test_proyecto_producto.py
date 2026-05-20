def create_proyecto(client, auth_headers) -> str:
    payload = {
        "id_proyecto": "PRJ-PPROD-01",
        "nombre": "Proyecto Producto",
        "entidad_financiadora": "Financiador PP",
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def create_producto(client, auth_headers) -> int:
    response = client.post(
        "/api/v1/productos/",
        json={"descripcion": "Producto Rel"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_producto"]


def test_proyecto_producto_list_requires_auth(client):
    response = client.get("/api/v1/proyecto-productos/")
    assert response.status_code == 401


def test_proyecto_producto_crud(client, auth_headers):
    proyecto_id = create_proyecto(client, auth_headers)
    producto_id = create_producto(client, auth_headers)

    created = client.post(
        "/api/v1/proyecto-productos/",
        json={"id_proyecto": proyecto_id, "id_producto": producto_id},
        headers=auth_headers,
    )
    assert created.status_code == 201
    rel_id = created.json()["id"]

    listed = client.get("/api/v1/proyecto-productos/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(
        f"/api/v1/proyecto-productos/{rel_id}",
        headers=auth_headers,
    )
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/proyecto-productos/{rel_id}",
        json={"id_proyecto": proyecto_id, "id_producto": producto_id},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(
        f"/api/v1/proyecto-productos/{rel_id}",
        headers=auth_headers,
    )
    assert deleted.status_code == 204

    missing = client.get(
        f"/api/v1/proyecto-productos/{rel_id}",
        headers=auth_headers,
    )
    assert missing.status_code == 404


def test_proyecto_producto_invalid_payload(client, auth_headers):
    response = client.post(
        "/api/v1/proyecto-productos/",
        json={},
        headers=auth_headers,
    )
    assert response.status_code == 422


def test_proyecto_producto_not_found(client, auth_headers):
    response = client.get("/api/v1/proyecto-productos/9999", headers=auth_headers)
    assert response.status_code == 404
