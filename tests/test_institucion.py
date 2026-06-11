def test_institucion_list_requires_auth(client):
    response = client.get("/api/v1/instituciones/")
    assert response.status_code == 401


def test_institucion_crud(client, auth_headers):
    created = client.post(
        "/api/v1/instituciones/",
        json={"nombre": "Institucion Test"},
        headers=auth_headers,
    )
    assert created.status_code == 201
    institucion_id = created.json()["id_institucion"]

    listed = client.get("/api/v1/instituciones/", headers=auth_headers)
    assert listed.status_code == 200

    fetched = client.get(f"/api/v1/instituciones/{institucion_id}", headers=auth_headers)
    assert fetched.status_code == 200

    updated = client.put(
        f"/api/v1/instituciones/{institucion_id}",
        json={"nombre": "Institucion Actualizada"},
        headers=auth_headers,
    )
    assert updated.status_code == 200

    deleted = client.delete(f"/api/v1/instituciones/{institucion_id}", headers=auth_headers)
    assert deleted.status_code == 204

    missing = client.get(f"/api/v1/instituciones/{institucion_id}", headers=auth_headers)
    assert missing.status_code == 404
