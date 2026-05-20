def test_proyecto_list_requires_auth(client):
    response = client.get("/api/v1/proyectos/")
    assert response.status_code == 401


def test_proyecto_crud(client, auth_headers):
    payload = {
        "id_proyecto": "PRJ-TEST-01",
        "nombre": "Proyecto Test",
        "entidad_financiadora": "Financiador Test",
    }
    created = client.post("/api/v1/proyectos/", json=payload, headers=auth_headers)
    assert created.status_code == 201
    proyecto_id = created.json()["id_proyecto"]

    listed = client.get("/api/v1/proyectos/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/proyectos/{proyecto_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/proyectos/{proyecto_id}",
        json={"nombre": "Proyecto Actualizado"},
        headers=auth_headers,
    )
    assert updated.status_code == 200
    assert updated.json()["nombre"] == "Proyecto Actualizado"

    deleted = client.delete(f"/api/v1/proyectos/{proyecto_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/proyectos/{proyecto_id}", headers=auth_headers)
    assert missing.status_code == 404


def test_proyecto_invalid_payload(client, auth_headers):
    response = client.post("/api/v1/proyectos/", json={}, headers=auth_headers)
    assert response.status_code == 422


def test_proyecto_not_found(client, auth_headers):
    response = client.get("/api/v1/proyectos/PRJ-NOEXISTE", headers=auth_headers)
    assert response.status_code == 404
