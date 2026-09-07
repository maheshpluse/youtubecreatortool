import time
import random
import requests
import json

# Default DataForSEO Credentials
DATAFORSEO_BASE64 = "aW5mb0BlYXN5c2lnbmx5LmNvbTo3NDY0MTZmMGZmYzQ1ZTNi"

def fetch_keyword_data(keyword: str, db=None, gemini_model=None) -> dict:
    """
    Fetches real YouTube search volume and CPC data from DataForSEO API.
    If the API fails, it falls back to Gemini AI for realistic estimations.
    """
    api_key = DATAFORSEO_BASE64
    
    if db:
        try:
            doc_ref = db.collection("app_settings").document("api_keys").get()
            if doc_ref.exists:
                dynamic_key = doc_ref.to_dict().get("dataforseo_api_key")
                if dynamic_key:
                    api_key = dynamic_key
        except Exception as e:
            print(f"Failed to fetch DataForSEO key from Firestore: {e}")

    url = "https://api.dataforseo.com/v3/dataforseo_labs/google/keyword_ideas/live"
    headers = {
        'Authorization': f'Basic {api_key}',
        'Content-Type': 'application/json'
    }
    
    payload = [{
        "keywords": [keyword.lower()],
        "location_code": 2840, # United States
        "language_code": "en"
    }]
    
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('tasks') and len(data['tasks']) > 0:
                result = data['tasks'][0].get('result')
                if result and len(result) > 0:
                    items = result[0].get('items', [])
                    if items:
                        item = items[0]
                        keyword_info = item.get('keyword_info', {})
                        
                        volume = keyword_info.get('search_volume', 0)
                        cpc = keyword_info.get('cpc', 0.5)
                        competition_index = keyword_info.get('competition_index', 50)
                        
                        if competition_index > 79:
                            comp_level = "High"
                        elif competition_index > 39:
                            comp_level = "Medium"
                        else:
                            comp_level = "Low"
                            
                        return {
                            "keyword": keyword,
                            "search_volume": volume,
                            "cpc": round(cpc, 2) if cpc else 0.5,
                            "competition_level": comp_level,
                            "competition_index": competition_index,
                            "source": "DataForSEO API"
                        }
        else:
            err_msg = f"API Error: Status {response.status_code}"
            print(f"DataForSEO {err_msg}. Response: {response.text}")
            if db:
                from services.logger import log_error
                log_error(db, "DataForSEO API", err_msg, response.text)
            
    except Exception as e:
        print(f"DataForSEO API Error: {e}")
        if db:
            from services.logger import log_error
            log_error(db, "DataForSEO API Request", str(e), "Exception occurred during request")
        
    # --- FALLBACK GEMINI AI ESTIMATION ---
    if gemini_model:
        try:
            prompt = f"Estimate the global monthly search volume (integer) and average cost-per-click (CPC) in USD (float) for the YouTube keyword or niche '{keyword}'. Return ONLY a valid JSON object with 'search_volume' (integer, e.g., 50000), 'cpc' (float, e.g., 2.50), 'competition_level' (string: 'Low', 'Medium', or 'High'), and 'competition_index' (integer 0-100). Example: {{\"search_volume\": 45000, \"cpc\": 3.2, \"competition_level\": \"Medium\", \"competition_index\": 60}}"
            response = gemini_model.generate_content(prompt, generation_config={"response_mime_type": "application/json"})
            data = json.loads(response.text)
            return {
                "keyword": keyword,
                "search_volume": data.get("search_volume", 10000),
                "cpc": round(data.get("cpc", 1.0), 2),
                "competition_level": data.get("competition_level", "Medium"),
                "competition_index": data.get("competition_index", 50),
                "source": "Gemini AI Estimation"
            }
        except Exception as e:
            print(f"Gemini Estimation Error: {e}")
            raise ValueError("Failed to estimate keyword data using AI.")
            
    raise ValueError("No data sources available to fetch keyword data.")
