import time
import random
import requests
import json

# Default DataForSEO Credentials
DATAFORSEO_BASE64 = "aW5mb0BlYXN5c2lnbmx5LmNvbTo3NDY0MTZmMGZmYzQ1ZTNi"

def fetch_keyword_data(keyword: str, db=None) -> dict:
    """
    Fetches real YouTube search volume and CPC data from DataForSEO API.
    If the API fails (e.g., account not verified), it falls back to mock data.
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
        
        # Check if the response is successful and the account is verified
        if response.status_code == 200:
            data = response.json()
            if data.get('tasks') and len(data['tasks']) > 0:
                result = data['tasks'][0].get('result')
                if result and len(result) > 0:
                    items = result[0].get('items', [])
                    if items:
                        # Extract data from the first matched keyword item
                        item = items[0]
                        keyword_info = item.get('keyword_info', {})
                        
                        volume = keyword_info.get('search_volume', 0)
                        cpc = keyword_info.get('cpc', 0.5)
                        competition_index = keyword_info.get('competition_index', 50)
                        
                        # Determine competition level
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
            # Handle API errors (like unverified account error 40104)
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
        
    # --- FALLBACK MOCK DATA ---
    # If the API call fails or account is unverified, fallback to realistic mock data
    keyword_lower = keyword.lower()
    
    if any(k in keyword_lower for k in ["finance", "money", "crypto", "business", "invest"]):
        volume = random.randint(50000, 200000)
        cpc = round(random.uniform(8.0, 25.0), 2)
        competition = "High"
        comp_index = random.randint(80, 100)
    elif any(k in keyword_lower for k in ["gaming", "vlog", "funny", "entertainment", "prank"]):
        volume = random.randint(100000, 500000)
        cpc = round(random.uniform(0.5, 3.0), 2)
        competition = "Medium"
        comp_index = random.randint(40, 79)
    else:
        volume = random.randint(1000, 50000)
        cpc = round(random.uniform(1.0, 8.0), 2)
        competition = "Low"
        comp_index = random.randint(10, 39)

    return {
        "keyword": keyword,
        "search_volume": volume,
        "cpc": cpc,
        "competition_level": competition,
        "competition_index": comp_index,
        "source": "Mock Fallback (API Unverified)"
    }
