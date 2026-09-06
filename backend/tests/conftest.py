import pytest
from unittest.mock import MagicMock, patch

@pytest.fixture(autouse=True)
def mock_firebase():
    with patch("main.firebase_admin.initialize_app") as mock_init:
        with patch("main.firestore.client") as mock_client:
            mock_db = MagicMock()
            mock_client.return_value = mock_db
            yield mock_db

@pytest.fixture(autouse=True)
def mock_gemini():
    with patch("main.gemini_model") as mock_instance:
        yield mock_instance

@pytest.fixture(autouse=True)
def mock_recaptcha():
    with patch("main.requests.post") as mock_post:
        mock_response = MagicMock()
        mock_response.json.return_value = {
            "tokenProperties": {
                "valid": True,
                "action": "submit"
            },
            "riskAnalysis": {
                "score": 0.9
            }
        }
        mock_post.return_value = mock_response
        yield mock_response
