import datetime
from collections import OrderedDict
from google.cloud import firestore

# ── L1: Fast in-memory LRU cache ──────────────────────────────────
# Eliminates Firestore round-trip for repeated lookups of the same
# keyword within the same process. Capped at 256 entries to keep
# memory bounded.
_LRU_MAX = 256

class _LRUCache:
    """Thread-unsafe LRU — fine for a single-process FastAPI worker."""
    def __init__(self, maxsize: int = _LRU_MAX):
        self._data: OrderedDict = OrderedDict()
        self._maxsize = maxsize

    def get(self, key: str):
        entry = self._data.get(key)
        if entry is None:
            return None
        # Check TTL
        if (datetime.datetime.now(datetime.timezone.utc) - entry['ts']).days >= CACHE_EXPIRY_DAYS:
            self._data.pop(key, None)
            return None
        # Move to end (most-recently used)
        self._data.move_to_end(key)
        return entry['data']

    def put(self, key: str, data):
        self._data[key] = {'data': data, 'ts': datetime.datetime.now(datetime.timezone.utc)}
        self._data.move_to_end(key)
        if len(self._data) > self._maxsize:
            self._data.popitem(last=False)

_l1 = _LRUCache()

# ── L2: Firestore / fallback in-memory cache ──────────────────────
_memory_cache = {}
CACHE_EXPIRY_DAYS = 7

def get_cached_keyword(db, keyword: str):
    keyword_id = keyword.lower().strip().replace(" ", "_")

    # L1 check — instant, no network
    hit = _l1.get(keyword_id)
    if hit is not None:
        return hit

    # L2 check — Firestore or fallback dict
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
                        result = data.get('data')
                        # Promote to L1
                        _l1.put(keyword_id, result)
                        return result
        except Exception as e:
            print(f"Firestore Cache Read Error: {e}")
    else:
        if keyword_id in _memory_cache:
            entry = _memory_cache[keyword_id]
            if (datetime.datetime.now() - entry['timestamp']).days < CACHE_EXPIRY_DAYS:
                result = entry['data']
                _l1.put(keyword_id, result)
                return result

    return None

def set_cached_keyword(db, keyword: str, data: dict):
    keyword_id = keyword.lower().strip().replace(" ", "_")

    # Always write to L1 first for immediate availability
    _l1.put(keyword_id, data)

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

