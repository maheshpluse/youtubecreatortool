import time
from fastapi import Request, HTTPException
from typing import Dict, List

# Dictionary to store request timestamps per IP
# Format: { "ip_address": [timestamp1, timestamp2, ...] }
_request_records: Dict[str, List[float]] = {}
_last_cleanup = time.monotonic()

# Configuration
MAX_REQUESTS_PER_MINUTE = 20  # Increased slightly to prevent legitimate usage blocks
WINDOW_SECONDS = 60
CLEANUP_INTERVAL = 300 # Clean up memory every 5 minutes

def _cleanup_old_records(now: float):
    global _last_cleanup
    if now - _last_cleanup > CLEANUP_INTERVAL:
        expired_ips = []
        for ip, timestamps in _request_records.items():
            valid_timestamps = [ts for ts in timestamps if now - ts < WINDOW_SECONDS]
            if not valid_timestamps:
                expired_ips.append(ip)
            else:
                _request_records[ip] = valid_timestamps
                
        for ip in expired_ips:
            del _request_records[ip]
            
        _last_cleanup = now

async def rate_limiter(request: Request):
    client_ip = request.client.host if request.client else "unknown"
    
    # Use monotonic time to prevent clock skew issues
    now = time.monotonic()
    
    # Run cleanup periodically to prevent memory leaks
    _cleanup_old_records(now)
    
    # Get existing records for this IP
    records = _request_records.get(client_ip, [])
    
    # Remove timestamps older than the window
    records = [ts for ts in records if now - ts < WINDOW_SECONDS]
    
    if len(records) >= MAX_REQUESTS_PER_MINUTE:
        # Include Retry-After header for compliant clients
        raise HTTPException(
            status_code=429,
            detail="Too many requests. Please wait a moment and try again.",
            headers={"Retry-After": str(WINDOW_SECONDS)}
        )
    
    # Record the new request
    records.append(now)
    _request_records[client_ip] = records
