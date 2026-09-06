import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from main import app

client = TestClient(app)

def test_missing_recaptcha_token():
    response = client.post(
        "/api/calculate-seo",
        json={"title": "Test", "description": "Test"}
    )
    # Should fail if RECAPTCHA_SECRET_KEY is set and no token is provided.
    # We can patch os.environ or let verify_recaptcha read current env.
    with patch("main.RECAPTCHA_SECRET_KEY", "dummy_secret"):
        with patch("main.ALLOW_INSECURE_RECAPTCHA", False):
            response = client.post(
                "/api/calculate-seo",
                json={"title": "Test", "description": "Test"}
            )
            assert response.status_code == 403
            assert response.json()["detail"] == "Missing reCAPTCHA token"

def test_invalid_recaptcha_token():
    with patch("main.RECAPTCHA_SECRET_KEY", "dummy_secret"):
        with patch("main.ALLOW_INSECURE_RECAPTCHA", False):
            with patch("main.requests.post") as mock_post:
                mock_response = MagicMock()
                mock_response.json.return_value = {
                    "tokenProperties": {
                        "valid": False,
                        "invalidReason": "MALFORMED"
                    }
                }
                mock_post.return_value = mock_response
                
                response = client.post(
                    "/api/calculate-seo",
                    headers={"X-Recaptcha-Token": "invalid_token"},
                    json={"title": "Test", "description": "Test"}
                )
                assert response.status_code == 403
                assert "Invalid reCAPTCHA token" in response.json()["detail"]

def test_missing_admin_token():
    response = client.get("/api/admin/users")
    assert response.status_code == 401
    assert response.json()["detail"] == "Missing bearer token"

def test_invalid_admin_token():
    with patch("main.firebase_auth.verify_id_token") as mock_verify:
        mock_verify.side_effect = Exception("Expired token")
        response = client.get("/api/admin/users", headers={"Authorization": "Bearer fake_token"})
        assert response.status_code == 401
        assert response.json()["detail"] == "Invalid or expired token"

def test_valid_admin_token_without_admin_claim():
    with patch("main.firebase_auth.verify_id_token") as mock_verify:
        # User is authenticated but does not have the 'admin' custom claim
        mock_verify.return_value = {"uid": "123", "admin": False}
        response = client.get("/api/admin/users", headers={"Authorization": "Bearer fake_token"})
        assert response.status_code == 403
        assert response.json()["detail"] == "Admin privileges required"
