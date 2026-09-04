from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import os
import json
from dotenv import load_dotenv
import anthropic
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

# Initialize Firebase Admin
if not firebase_admin._apps:
    try:
        firebase_admin.initialize_app(options={'projectId': 'creatortools-admin-mj-2026'})
    except ValueError:
        pass

db = None
try:
    db = firestore.client()
except Exception as e:
    print(f"Warning: Could not initialize Firestore client: {e}")

def get_anthropic_client():
    if db is not None:
        try:
            doc_ref = db.collection(u'app_settings').document(u'api_keys')
            doc = doc_ref.get()
            if doc.exists:
                api_key = doc.to_dict().get('anthropic_api_key')
                if api_key:
                    return anthropic.Anthropic(api_key=api_key)
        except Exception as e:
            print(f"Error fetching API key from Firestore: {e}")
    
    # Fallback to local env var
    return anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY"))

app = FastAPI(title="CreatorTools API", version="1.0.0")

# Comma-separated list of browser origins allowed to call this API.
# Defaults to the local Jaspr dev server; set ALLOWED_ORIGINS in production.
ALLOWED_ORIGINS = [
    o.strip()
    for o in os.environ.get(
        "ALLOWED_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080"
    ).split(",")
    if o.strip()
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

RECAPTCHA_SECRET_KEY = os.environ.get("RECAPTCHA_SECRET_KEY", "").strip()

# Escape hatch for local development only: skips reCAPTCHA entirely. Every AI
# endpoint bills a real Anthropic key, so this must never be set in production.
ALLOW_INSECURE_RECAPTCHA = os.environ.get(
    "ALLOW_INSECURE_RECAPTCHA", ""
).strip().lower() in ("1", "true", "yes")

if not RECAPTCHA_SECRET_KEY:
    if ALLOW_INSECURE_RECAPTCHA:
        print(
            "WARNING: ALLOW_INSECURE_RECAPTCHA is enabled and no RECAPTCHA_SECRET_KEY "
            "is set. All AI endpoints are UNPROTECTED. Do not use this in production."
        )
    else:
        print(
            "WARNING: RECAPTCHA_SECRET_KEY is not set. AI endpoints will reject every "
            "request with HTTP 503. Set RECAPTCHA_SECRET_KEY, or set "
            "ALLOW_INSECURE_RECAPTCHA=true for local development."
        )


async def verify_recaptcha(request: Request):
    # Fail closed: without a configured secret we cannot verify anything, so we
    # refuse rather than silently waving every caller through.
    if not RECAPTCHA_SECRET_KEY:
        if ALLOW_INSECURE_RECAPTCHA:
            return True
        raise HTTPException(
            status_code=503, detail="reCAPTCHA is not configured on this server."
        )

    token = request.headers.get("X-Recaptcha-Token")
    if not token:
        raise HTTPException(status_code=403, detail="Missing reCAPTCHA token")

    try:
        response = requests.post(
            "https://www.google.com/recaptcha/api/siteverify",
            data={"secret": RECAPTCHA_SECRET_KEY, "response": token},
            timeout=10,
        )
        result = response.json()
        print(f"DEBUG RECAPTCHA: {result}, Token: {token[:20]}...", flush=True)
    except requests.RequestException as e:
        raise HTTPException(
            status_code=502, detail=f"Could not reach reCAPTCHA service: {e}"
        )

    if not result.get("success"):
        raise HTTPException(status_code=403, detail="Invalid reCAPTCHA token")
    return True

class SEOCheckRequest(BaseModel):
    title: str
    description: str
    tags: list[str]
    target_keyword: str

class SEOResponseSchema(BaseModel):
    score: int
    feedback: list[str]
    status: str

MODEL = "claude-opus-5"


def call_anthropic(prompt: str, schema_class: type[BaseModel]) -> BaseModel:
    """Ask Claude for a response matching schema_class and return it parsed.

    Uses structured outputs, so the schema is enforced by the API rather than
    described in the prompt. That removes the old markdown-fence stripping, and
    avoids reading response.content[0] -- with adaptive thinking (on by default
    on Opus 5) the first block is not necessarily the text block.
    """
    client = get_anthropic_client()
    response = client.messages.parse(
        model=MODEL,
        max_tokens=16000,
        output_config={"effort": "medium"},
        system="You are a backend API component for a YouTube creator tools site.",
        messages=[{"role": "user", "content": prompt}],
        output_format=schema_class,
    )
    return response.parsed_output

@app.post("/api/calculate-seo", dependencies=[Depends(verify_recaptcha)])
def calculate_seo(request: SEOCheckRequest):
    prompt = f"""
    Act as an expert YouTube SEO Analyzer.
    Analyze the following YouTube video details, paying VERY close attention to the entire Description text.
    
    Title: {request.title}
    Description: {request.description}
    Tags: {', '.join(request.tags)}
    Target Keyword: {request.target_keyword}
    
    Do not just count words. Evaluate how well the Description is written, how naturally the keywords are placed, and how engaging it is.
    Provide an overall SEO score (0-100), a list of highly detailed, actionable feedback points explaining exactly how to improve the SEO, and a status string ('Excellent', 'Good', 'Needs Improvement').
    Prefix good points with 'Pass: ' and bad points with 'Fail: '.
    """
    try:
        return call_anthropic(prompt, SEOResponseSchema)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class TitleRequest(BaseModel):
    topic: str

class TitleResult(BaseModel):
    title: str
    ctr_score: int

class TitlesResponse(BaseModel):
    titles: list[TitleResult]

@app.post("/api/generate-titles", dependencies=[Depends(verify_recaptcha)])
def generate_titles(request: TitleRequest):
    prompt = f"""
    Act as an expert YouTube content strategist.
    The user wants to make a video about the following topic: {request.topic}
    
    Generate exactly 4 highly clickable, viral YouTube titles that tap into human psychology and curiosity to achieve a High CTR (Click-Through Rate).
    Avoid being overly clickbaity; make them compelling and relevant.
    Also predict a realistic CTR score (0-99) for each title based on your analysis.
    """
    try:
        res = call_anthropic(prompt, TitlesResponse)
        return res.titles
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class ThumbnailRequest(BaseModel):
    topic: str

class ThumbnailIdea(BaseModel):
    concept_name: str
    visual_description: str
    text_on_screen: str

class ThumbnailsResponse(BaseModel):
    thumbnails: list[ThumbnailIdea]

@app.post("/api/generate-thumbnails", dependencies=[Depends(verify_recaptcha)])
def generate_thumbnails(request: ThumbnailRequest):
    prompt = f"""
    Act as an expert YouTube strategist and designer.
    The user wants to make a video about the following topic: {request.topic}
    
    Generate exactly 3 highly clickable visual concepts for YouTube thumbnails.
    For each concept, provide:
    1. A catchy concept name.
    2. A detailed visual description (background, foreground, facial expressions, colors).
    3. The exact short text to overlay on the screen (keep it under 5 words).
    """
    try:
        res = call_anthropic(prompt, ThumbnailsResponse)
        return res.thumbnails
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class TagRequest(BaseModel):
    url: str

@app.post("/api/extract-tags", dependencies=[Depends(verify_recaptcha)])
def extract_tags(request: TagRequest):
    # Mock extraction for demonstration
    return {"tags": ["seo", "youtube growth", "monetization", "tutorial"]}

class EarningsRequest(BaseModel):
    daily_views: int
    niche: str

class RPMResponse(BaseModel):
    min_rpm: float
    max_rpm: float

@app.post("/api/calculate-earnings", dependencies=[Depends(verify_recaptcha)])
def calculate_earnings(request: EarningsRequest):
    prompt = f"""
    Act as an expert YouTube monetization analyst.
    What is the current, realistic RPM (Revenue Per Mille) range in USD for a YouTube channel in the '{request.niche}' niche?
    Consider current industry averages, seasonality, and advertiser demand.
    Return only a JSON object with 'min_rpm' and 'max_rpm' as float values representing the realistic range.
    """
    
    try:
        res = call_anthropic(prompt, RPMResponse)
        rpm_range = (res.min_rpm, res.max_rpm)
    except Exception as e:
        print(f"Error fetching RPM from AI: {e}")
        # Fallback to generic average RPM if AI request fails
        rpm_range = (2.0, 6.0)
        
    monthly_views = request.daily_views * 30
    
    min_earnings = (monthly_views / 1000) * rpm_range[0]
    max_earnings = (monthly_views / 1000) * rpm_range[1]
    
    return {
        "min_monthly": round(min_earnings, 2),
        "max_monthly": round(max_earnings, 2),
        "currency": "USD"
    }
