from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response: Response = await call_next(request)
        
        # Security headers based on Module 4 checklist
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
        # Since this is an API, Content-Security-Policy is mostly to prevent HTML execution if someone accesses endpoints directly in browser
        response.headers["Content-Security-Policy"] = "default-src 'none'; frame-ancestors 'none'"
        
        # Remove X-Powered-By if it somehow gets added by other middleware (FastAPI doesn't add it by default, but good measure)
        if "X-Powered-By" in response.headers:
            del response.headers["X-Powered-By"]
            
        return response
