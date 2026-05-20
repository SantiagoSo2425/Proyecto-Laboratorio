def test_login_success(client):
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "admin", "password": "Admin123!"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["token_type"] == "bearer"
    assert data["access_token"]


def test_login_invalid(client):
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "admin", "password": "BadPass"},
    )
    assert response.status_code == 401


def test_login_invalid_payload(client):
    response = client.post("/api/v1/auth/login", data={"username": "admin"})
    assert response.status_code == 422
