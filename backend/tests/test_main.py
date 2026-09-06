import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_main():
    # Example basic test
    response = client.get("/")
    # Check that we either get a 404 (if / is not defined) or a 200, 
    # but not a 500 error, indicating the app loads properly.
    assert response.status_code in [200, 404]

def test_docs_load():
    # Verify that the OpenAPI docs load correctly
    response = client.get("/docs")
    assert response.status_code == 200
