"""Manual smoke test: verify an admin can sign in against Firebase Auth.

Never hardcode real credentials here. Pass them via environment variables:

    ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=... FIREBASE_WEB_API_KEY=... python test_auth.py
"""
import os
import sys
import requests

api_key = os.environ.get("FIREBASE_WEB_API_KEY", "").strip()
email = os.environ.get("ADMIN_EMAIL", "").strip()
password = os.environ.get("ADMIN_PASSWORD", "")

if not (api_key and email and password):
    sys.exit(
        "Missing credentials. Set FIREBASE_WEB_API_KEY, ADMIN_EMAIL and "
        "ADMIN_PASSWORD environment variables before running this script."
    )

url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}"

payload = {
    "email": email,
    "password": password,
    "returnSecureToken": True
}

try:
    response = requests.post(url, json=payload, timeout=10)
    data = response.json()
    if "error" in data:
        print(f"Login failed: {data['error']['message']}")
    else:
        print("Login successful!")
except Exception as e:
    print(f"Request failed: {e}")
