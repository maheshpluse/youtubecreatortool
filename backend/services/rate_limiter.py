import time
from fastapi import Request, HTTPException
from typing import Dict, List

# Dictionary to store request timestamps per IP
# Format: { "ip_address": [timestamp1, timestamp2, ...] }
_request_records: Dict[str, List[float]] = {}

# Configuration
MAX_REQUESTS_PER_MINUTE = 5
WINDOW_SECONDS = 60

async def rate_limiter(request: Request):
    client_ip = request.client.host if request.client else "unknown"
    
    now = time.time()
    
    # Get existing records for this IP
    records = _request_records.get(client_ip, [])
    
    # Remove timestamps older than the window
    records = [ts for ts in records if now - ts < WINDOW_SECONDS]
    
    if len(records) >= MAX_REQUESTS_PER_MINUTE:
        raise HTTPException(
            status_code=429,
            detail="Too many requests. Please wait a moment and try again."
        )
    
    # Record the new request
    records.append(now)
    _request_records[client_ip] = records
