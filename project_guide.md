# CreatorTools.io - YouTube Utility Website

A premium, fast, and mobile-friendly utility website designed for YouTube creators targeting Tier-1 countries (USA, UK, Canada). Built to maximize AdSense revenue (High RPM) and provide real value to content creators.

## 🚀 Tech Stack
* **Frontend:** Jaspr (Dart Web Framework)
* **Styling:** Tailwind CSS (Dark Mode, Vercel-like theme)
* **Backend:** Python (FastAPI)
* **Scraping:** BeautifulSoup4, Requests

## 🎨 UI/UX Vibe (The Design System)
* **Theme:** Deep Dark Premium (`bg-[#09090b]`, cards: `bg-[#18181b]`).
* **Accents:** Professional Blue (`#3b82f6`) and Emerald Green for success states.
* **Animations:** Smooth transitions, `animate-fade-up` for tab switches, `scale-in` for results, hover glow effects, and `active:scale` for button presses.
* **Mobile-First:** Large touch targets (Padding `py-3`, `py-4`), scrollable tab bars, and no intrusive popups.

## 🛠️ Core Features (The Tools)
1. **SEO Analyzer:** Calculates a 0-100 optimization score based on Target Keyword presence in Title, Description, and Tags.
2. **Title Generator:** Generates clickable, high-CTR titles based on a topic using predefined highly-optimized templates.
3. **Tag Extractor (Spy):** Scrapes and extracts hidden meta tags from any competitor's YouTube video URL.
4. **Earnings Calculator:** Estimates monthly Tier-1 AdSense revenue based on daily views and niche-specific RPM rates (e.g., Finance $12-$25 RPM).

## 💰 Monetization & SEO Strategy
* AdSense approved structure.
* Includes a built-in educational article integrated naturally into the UI containing 20+ High-CPC keywords:
  *(Search Engine Optimization (SEO), AdSense revenue, Target audience, Video analytics, Click-Through Rate (CTR), Video engagement rate, Keyword research tool, Competitor analysis, High CPC keywords, High RPM, Passive income streams, Affiliate marketing strategies, Sponsored content, Online business, Algorithm update, Content creation tools, Organic traffic growth, Digital marketing, Rank higher on YouTube, Monetization).*

---

## 💻 Full Backend Code (Python FastAPI)
`main.py`:
```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
from bs4 import BeautifulSoup
import re
import random

app = FastAPI(title="CreatorTools API", version="1.0.0")

app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

class SEOCheckRequest(BaseModel):
    title: str
    description: str
    tags: list[str]
    target_keyword: str

@app.post("/api/calculate-seo")
def calculate_seo(request: SEOCheckRequest):
    title, desc, keyword = request.title.lower(), request.description.lower(), request.target_keyword.lower().strip()
    score = 0
    feedback = []

    if keyword in title:
        score += 35
        feedback.append("Pass: Exact Keyword in Title.")
    if keyword in desc[:200]:
        score += 35
        feedback.append("Pass: Keyword in first 200 chars of Description.")
    
    if 30 <= len(title) <= 70:
        score += 30
        feedback.append("Pass: Title Length is Optimal (30-70 chars).")

    return {"score": score, "feedback": feedback, "status": "Excellent" if score >= 80 else "Needs Improvement"}
# (Other endpoints: /api/generate-titles, /api/extract-tags, /api/calculate-earnings omitted for brevity - see full python file)

```

## 💻 Frontend Setup (Jaspr + Dart + CSS)

`web/styles.css`:

```css
@keyframes fadeUp { 0% { opacity: 0; transform: translateY(15px); } 100% { opacity: 1; transform: translateY(0); } }
@keyframes scaleIn { 0% { opacity: 0; transform: scale(0.9); } 50% { transform: scale(1.05); } 100% { opacity: 1; transform: scale(1); } }
.animate-fade-up { animation: fadeUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.animate-scale-in { animation: scaleIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.btn-press:active { transform: scale(0.97); }

```

## 🚀 Deployment Guide

* **Frontend:** Deploy to Cloudflare Pages or Vercel (Fast global CDN for Tier-1 loading speeds).
* **Backend:** Deploy to Render.com, DigitalOcean, or Railway.app.
