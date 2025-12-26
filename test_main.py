from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"messag": "this is cicd"}

def test_read_shahryar():
    """Test the /shahryar endpoint"""
    response = client.get("/shahryar")
    assert response.status_code == 200
    assert response.json() == {"this is greate": "thinker "}

def test_nonexistent_endpoint():
    """Test that non-existent endpoints return 404"""
    response = client.get("/nonexistent")
    assert response.status_code == 404
