import datetime
from google.cloud import firestore

# Fallback in-memory cache if Firebase is not properly initialized
_memory_cache = {}
CACHE_EXPIRY_DAYS = 7

def get_cached_keyword(db, keyword: str):
    keyword_id = keyword.lower().strip().replace(" ", "_")
    
    if db:
        try:
            doc_ref = db.collection('keyword_cache').document(keyword_id)
            doc = doc_ref.get()
            if doc.exists:
                data = doc.to_dict()
                cached_time = data.get('timestamp')
                if cached_time:
                    # firestore returns a datetime object with timezone
                    now = datetime.datetime.now(datetime.timezone.utc)
                    if (now - cached_time).days < CACHE_EXPIRY_DAYS:
                        return data.get('data')
        except Exception as e:
            print(f"Firestore Cache Read Error: {e}")
    else:
        if keyword_id in _memory_cache:
            entry = _memory_cache[keyword_id]
            if (datetime.datetime.now() - entry['timestamp']).days < CACHE_EXPIRY_DAYS:
                return entry['data']
    
    return None

def set_cached_keyword(db, keyword: str, data: dict):
    keyword_id = keyword.lower().strip().replace(" ", "_")
    
    if db:
        try:
            doc_ref = db.collection('keyword_cache').document(keyword_id)
            doc_ref.set({
                'keyword': keyword,
                'data': data,
                'timestamp': firestore.SERVER_TIMESTAMP
            })
        except Exception as e:
            print(f"Firestore Cache Write Error: {e}")
    else:
        _memory_cache[keyword_id] = {
            'data': data,
            'timestamp': datetime.datetime.now()
        }
