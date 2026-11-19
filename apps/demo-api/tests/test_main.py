from src.main import app


def test_healthz_returns_healthy_status():
    response = app.test_client().get("/healthz")
    assert response.status_code == 200
    assert response.json == {"status": "healthy"}


def test_index_identifies_service():
    response = app.test_client().get("/")
    assert response.status_code == 200
    assert response.json["service"] == "demo-api"
