def create_proyecto(client, auth_headers) -> str:
    payload = {
        "id_proyecto": "PRJ-PTR-01",
        "nombre": "Proyecto PT",
        "entidad_financiadora": "Financiador PT",
    }
    response = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert response.status_code == 201
    return response.json()["id_proyecto"]


def create_trabajo(client, auth_headers, proyecto_id: str) -> int:
    payload = {
        "id_proyecto": proyecto_id,
        "nombre": "Trabajo PT",
        "facultad": "Ingenieria",
    }
    response = client.post(
        "/api/v1/trabajos-grado/",
        json=payload,
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_trabajo"]


def create_producto(client, auth_headers) -> int:
    response = client.post(
        "/api/v1/productos/",
        json={"descripcion": "Producto PT"},
        headers=auth_headers,
    )
    assert response.status_code == 201
    return response.json()["id_producto"]


def test_producto_trabajo_list_requires_auth(client):
    response = client.get("/api/v1/producto-trabajos/")
    assert response.status_code == 401


def test_producto_trabajo_crud(client, auth_headers):
    proyecto_id = create_proyecto(client, auth_headers)
    trabajo_id = create_trabajo(client, auth_headers, proyecto_id)
    producto_id = create_producto(client, auth_headers)

    created = client.post(
        "/api/v1/producto-trabajos/",
        json={"id_trabajo": trabajo_id, "id_producto": producto_id},
        headers=auth_headers,
    )
    assert created.status_code == 201
    rel_id = created.json()["id"]

    listed = client.get("/api/v1/producto-trabajos/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(
        f"/api/v1/producto-trabajos/{rel_id}",
        headers=auth_headers,
    )
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/producto-trabajos/{rel_id}",
        json={"id_trabajo": trabajo_id, "id_producto": producto_id},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(
        f"/api/v1/producto-trabajos/{rel_id}",
        headers=auth_headers,
    )
    assert deleted.status_code == 204

    missing = client.get(
        f"/api/v1/producto-trabajos/{rel_id}",
        headers=auth_headers,
    )
    assert missing.status_code == 404


def test_producto_trabajo_invalid_payload(client, auth_headers):
    response = client.post(
        "/api/v1/producto-trabajos/",
        json={},
        headers=auth_headers,
    )
    assert response.status_code == 422


def test_producto_trabajo_not_found(client, auth_headers):
    response = client.get("/api/v1/producto-trabajos/9999", headers=auth_headers)
    assert response.status_code == 404
