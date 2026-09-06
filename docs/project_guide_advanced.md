# VidSEOKit - Advanced YouTube Utility & SaaS Platform

A premium, highly mobile-responsive utility website designed for YouTube creators targeting Tier-1 countries. Now upgraded with a Firebase-powered Admin Panel for real-time API and configuration updates.

## 🚀 Upgraded Tech Stack
* **Frontend (User UI & Admin Panel):** Jaspr (Dart Web Framework)
* **Styling:** Tailwind CSS (Dark Mode, Vercel-like theme, Mobile-First)
* **Backend:** Python (FastAPI)
* **Database & Auth:** Firebase (Firestore & Firebase Auth)
* **Scraping:** BeautifulSoup4, Requests

## 📱 Mobile-Responsive Strategy
* **Touch Optimization:** 100% mobile-friendly with large touch targets (`py-3`, `py-4`), bottom-sheet style popups for mobile, and scrollable horizontal tabs (`overflow-x-auto`).
* **Responsive Grid:** Uses Tailwind's `grid-cols-1 md:grid-cols-2` for seamless switching from mobile screens to desktop monitors.
* **No Layout Shifts:** Fixed height containers for results to prevent the screen from jumping when data loads.

## 🛠️ Core User Features (The Tools)
1. **SEO Analyzer:** Calculates a 0-100 optimization score.
2. **Title Generator:** Generates clickable, high-CTR titles.
3. **Tag Extractor (Spy):** Scrapes and extracts hidden meta tags.
4. **Earnings Calculator:** Estimates monthly Tier-1 AdSense revenue.

## 👑 Admin Panel & Firebase Integration
* **Secure Access:** Firebase Authentication (Email/Password) to access the `/admin` dashboard.
* **Dynamic API Updates (Firestore):** 
  * The Python backend reads configurations (like RPM rates, SEO scoring rules, and algorithm variables) directly from Firebase Firestore.
  * The Admin Panel allows the site owner to update these RPM rates or SEO rules in real-time. (e.g., If the "Finance" niche RPM drops to $10, the admin changes it in the dashboard, and the Python API instantly uses the new value without restarting the server).
* **Usage Analytics:** Track how many times each tool was used (stored in Firestore).

## 💰 Monetization & SEO Strategy
* Built-in educational article integrated naturally into the UI containing 20+ High-CPC keywords (e.g., *Search Engine Optimization (SEO), High RPM, Passive income streams, Affiliate marketing strategies, etc.*).

---

## 💻 Python Backend (Firebase Integrated)
`main.py` snippet for Firebase connection:
```python
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

# Initialize Firebase Admin
cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI(title="VidSEOKit API")

@app.post("/api/calculate-earnings")
def calculate_earnings(request: EarningsRequest):
    # Fetch REAL-TIME RPM rates from Firebase Firestore instead of hardcoding
    rpm_doc = db.collection('configs').document('rpm_rates').get()
    if rpm_doc.exists:
        niche_rpm_rates = rpm_doc.to_dict()
    else:
        # Fallback rates
        niche_rpm_rates = {"finance": [12.0, 25.0], "tech": [5.0, 12.0]}
    
    # ... calculation logic ...
```
