import pytest
from fastapi.testclient import TestClient
from unittest.mock import MagicMock

# Important: import app after mocking is configured via conftest, 
# but FastAPI test client can be initialized here safely since 
# firebase_admin and gemini are mocked before endpoints are hit.
from main import app

client = TestClient(app)

def test_calculate_seo_endpoint(mock_recaptcha, mock_gemini):
    # Setup mock gemini response
    mock_response = MagicMock()
    mock_response.text = '{"seo_score": 85, "suggestions": ["Add keyword to title"]}'
    mock_gemini.generate_content.return_value = mock_response

    response = client.post(
        "/api/calculate-seo",
        headers={"X-Recaptcha-Token": "valid_token"},
        json={
            "title": "My Video", 
            "description": "A video about stuff",
            "tags": ["stuff", "video"],
            "target_keyword": "stuff video"
        }
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "score" in data

def test_generate_titles_endpoint(mock_recaptcha, mock_gemini):
    mock_response = MagicMock()
    mock_response.text = '[{"title": "Title 1", "ctr_score": 95}, {"title": "Title 2", "ctr_score": 90}]'
    mock_gemini.generate_content.return_value = mock_response

    response = client.post(
        "/api/generate-titles",
        headers={"X-Recaptcha-Token": "valid_token"},
        json={"topic": "Python programming", "lang": "en"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "titles" in data
    assert len(data["titles"]) > 0

def test_extract_tags_endpoint(mock_recaptcha, mock_gemini):
    mock_response = MagicMock()
    mock_response.text = '{"tags": ["python", "programming", "tutorial"]}'
    mock_gemini.generate_content.return_value = mock_response

    response = client.post(
        "/api/extract-tags",
        headers={"X-Recaptcha-Token": "valid_token"},
        json={"url": "https://youtube.com/watch?v=123"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "tags" in data
    assert len(data["tags"]) > 0

def test_generate_thumbnails_endpoint(mock_recaptcha, mock_gemini):
    mock_response = MagicMock()
    mock_response.text = '[{"concept_name": "Idea 1", "visual_description": "A cool thumbnail", "text_on_screen": "Wow"}]'
    mock_gemini.generate_content.return_value = mock_response

    response = client.post(
        "/api/generate-thumbnails",
        headers={"X-Recaptcha-Token": "valid_token"},
        json={"topic": "Python for Beginners", "lang": "en"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "thumbnails" in data
    assert len(data["thumbnails"]) > 0

def test_calculate_earnings_endpoint(mock_recaptcha):
    # Does not use Gemini, just math
    response = client.post(
        "/api/calculate-earnings",
        headers={"X-Recaptcha-Token": "valid_token"},
        json={"daily_views": 1000, "niche": "gaming"}
    )
    
    assert response.status_code == 200
    data = response.json()
    assert "min_monthly" in data
    assert "max_monthly" in data
