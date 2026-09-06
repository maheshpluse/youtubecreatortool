from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import os
import random
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore, auth as firebase_auth
import google.generativeai as genai
import json

# Import new services
from services.keyword_api import fetch_keyword_data
from services.cache import get_cached_keyword, set_cached_keyword
from services.logger import log_error, log_admin_action
from services.rate_limiter import rate_limiter
from services.languages import language_name
import traceback

load_dotenv()

# We will initialize Gemini dynamically from Firestore
gemini_model = None

# Initialize Firebase Admin
if not firebase_admin._apps:
    try:
        import os
        key_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
        if os.path.exists(key_path):
            cred = credentials.Certificate(key_path)
            firebase_admin.initialize_app(cred)
        else:
            firebase_admin.initialize_app(options={'projectId': 'vidseokit-cf7e6'})
    except Exception as e:
        print(f"Firebase Init Error: {e}")

db = None
try:
    db = firestore.client()

    # --- DYNAMIC API KEY CONFIGURATION ---
    def on_api_keys_snapshot(col_snapshot, changes, read_time):
        global gemini_model
        for doc in col_snapshot:
            data = doc.to_dict()
            if data:
                gemini_key = data.get("gemini_api_key")
                if gemini_key:
                    try:
                        genai.configure(api_key=gemini_key)
                        gemini_model = genai.GenerativeModel("gemini-1.5-flash")
                        print("Gemini API Key dynamically updated from Firestore.")
                    except Exception as e:
                        print(f"Failed to configure Gemini from Firestore: {e}")
                else:
                    gemini_model = None

    # Watch the api_keys document for real-time updates
    try:
        api_keys_ref = db.collection("app_settings").document("api_keys")
        api_keys_watch = api_keys_ref.on_snapshot(on_api_keys_snapshot)

        # Also attempt a one-time initial load just in case the listener takes a moment
        initial_doc = api_keys_ref.get()
        if initial_doc.exists:
            initial_data = initial_doc.to_dict()
            if initial_data.get("gemini_api_key"):
                genai.configure(api_key=initial_data.get("gemini_api_key"))
                gemini_model = genai.GenerativeModel("gemini-1.5-flash")
                print("Gemini API Key loaded from Firestore on startup.")
    except Exception as e:
        print(f"Could not setup Firestore API key listener: {e}")
        # Fallback to .env if Firestore fails
        env_key = os.getenv("GEMINI_API_KEY")
        if env_key:
            genai.configure(api_key=env_key)
            gemini_model = genai.GenerativeModel("gemini-1.5-flash")
            print("Gemini API Key loaded from .env fallback.")
    # --- END DYNAMIC API KEY CONFIGURATION ---
except Exception as e:
    print(f"Warning: Could not initialize Firestore client: {e}")

app = FastAPI(title="VidSEOKit API", version="1.0.0")

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """
    Catch any unhandled exceptions, log them to Firestore, and return a clean generic message to the frontend.
    """
    error_details = traceback.format_exc()
    log_error(db, f"Global Error - {request.url.path}", str(exc), error_details)
    return {"error": "Something went wrong. Please try again later.", "status": "error"}

@app.on_event("startup")
async def startup_event():
    """
    Generate sample data on startup if the database is empty or we need initial logs.
    """
    if db:
        try:
            # Check if we have logs, if not generate a sample log
            logs_ref = db.collection("system_logs").limit(1).get()
            if not logs_ref:
                log_error(db, "System Startup", "Initial system check", "Sample log generated on startup to initialize the collection.")
                print("Sample system log generated.")
        except Exception as e:
            print(f"Sample data generation failed: {e}")

ALLOWED_ORIGINS = [
    o.strip()
    for o in os.environ.get(
        "ALLOWED_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080,http://localhost:8082,http://127.0.0.1:8082,http://localhost:5173,http://127.0.0.1:5173,http://vidseokit.com,https://vidseokit.com,https://www.vidseokit.com"
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
ALLOW_INSECURE_RECAPTCHA = os.environ.get(
    "ALLOW_INSECURE_RECAPTCHA", ""
).strip().lower() in ("1", "true", "yes")

async def verify_recaptcha(request: Request):
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
        PROJECT_ID = "vidseokit-cf7e6"
        SITE_KEY = "6LetP6ktAAAAAPn6G2UlIc-EQSMoVHBsJ4FWu5RH"
        url = f"https://recaptchaenterprise.googleapis.com/v1/projects/{PROJECT_ID}/assessments?key={RECAPTCHA_SECRET_KEY}"
        payload = {
            "event": {
                "token": token,
                "siteKey": SITE_KEY,
                "expectedAction": "submit"
            }
        }
        response = requests.post(url, json=payload, timeout=10)
        result = response.json()
    except requests.RequestException as e:
        raise HTTPException(
            status_code=502, detail=f"Could not reach reCAPTCHA service: {e}"
        )

    token_props = result.get("tokenProperties", {})
    if not token_props.get("valid"):
        reason = token_props.get("invalidReason", "Unknown")
        raise HTTPException(status_code=403, detail=f"Invalid reCAPTCHA token: {reason}")
    
    if token_props.get("action") != "submit":
        raise HTTPException(status_code=403, detail="Invalid reCAPTCHA action")
        
    risk_analysis = result.get("riskAnalysis", {})
    score = risk_analysis.get("score", 0.0)
    if score < 0.3:
        raise HTTPException(status_code=403, detail="reCAPTCHA score too low (bot detected)")

    return True

async def verify_admin(request: Request):
    """
    Gate for /api/admin/* endpoints. Requires a Firebase ID token (from the
    signed-in admin_panel user) carrying the `admin` custom claim - the same
    claim admin_panel/src/App.tsx and firestore.rules require.
    """
    authorization = request.headers.get("Authorization", "")
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing bearer token")

    token = authorization.split(" ", 1)[1].strip()
    try:
        decoded = firebase_auth.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    if not decoded.get("admin"):
        raise HTTPException(status_code=403, detail="Admin privileges required")

    return decoded

class SEOCheckRequest(BaseModel):
    title: str
    description: str
    tags: list[str]
    target_keyword: str

class SEOFeedbackItem(BaseModel):
    # `key` maps to a frontend i18n string (see seo_fb_* entries in
    # frontend/web/assets/i18n/en.json) so the UI can render feedback in
    # whatever language the viewer has selected instead of fixed English text.
    key: str
    params: dict[str, str] = {}
    status: str  # "pass" | "fail"

class SEOResponseSchema(BaseModel):
    score: int
    feedback: list[SEOFeedbackItem]
    status: str

@app.post("/api/calculate-seo", dependencies=[Depends(verify_recaptcha), Depends(rate_limiter)])
def calculate_seo(request: SEOCheckRequest):
    title = request.title.lower()
    desc = request.description.lower()
    keyword = request.target_keyword.lower().strip()

    score = 0
    feedback: list[SEOFeedbackItem] = []

    # Fetch Keyword Data using Cache & API
    kw_data = get_cached_keyword(db, keyword)
    if not kw_data:
        kw_data = fetch_keyword_data(keyword, db)
        set_cached_keyword(db, keyword, kw_data)

    volume = kw_data.get('search_volume', 0)
    competition = kw_data.get('competition_level', 'High')

    # SEO Logic based on real data
    if volume > 50000:
        feedback.append(SEOFeedbackItem(key="seo_fb_volume_high", params={"volume": str(volume)}, status="pass"))
        score += 20
    elif volume > 5000:
        feedback.append(SEOFeedbackItem(key="seo_fb_volume_good", params={"volume": str(volume)}, status="pass"))
        score += 15
    else:
        feedback.append(SEOFeedbackItem(key="seo_fb_volume_low", params={"volume": str(volume)}, status="fail"))
        score += 5

    if competition == "Low":
        feedback.append(SEOFeedbackItem(key="seo_fb_competition_low", status="pass"))
        score += 20
    elif competition == "Medium":
        feedback.append(SEOFeedbackItem(key="seo_fb_competition_medium", status="pass"))
        score += 10
    else:
        feedback.append(SEOFeedbackItem(key="seo_fb_competition_high", status="fail"))

    if keyword and keyword in title:
        score += 30
        feedback.append(SEOFeedbackItem(key="seo_fb_keyword_title_pass", status="pass"))
    else:
        feedback.append(SEOFeedbackItem(key="seo_fb_keyword_title_fail", status="fail"))

    if keyword and keyword in desc[:200]:
        score += 20
        feedback.append(SEOFeedbackItem(key="seo_fb_keyword_desc_pass", status="pass"))
    else:
        feedback.append(SEOFeedbackItem(key="seo_fb_keyword_desc_fail", status="fail"))

    if 30 <= len(request.title) <= 70:
        score += 10
        feedback.append(SEOFeedbackItem(key="seo_fb_title_length_pass", status="pass"))
    else:
        feedback.append(SEOFeedbackItem(key="seo_fb_title_length_fail", status="fail"))

    # Cap score at 100
    score = min(score, 100)
    status = "Excellent" if score >= 80 else ("Good" if score >= 50 else "Needs Improvement")

    return SEOResponseSchema(score=score, feedback=feedback, status=status)

class TitleRequest(BaseModel):
    topic: str
    lang: str = "en"

class TitleResult(BaseModel):
    title: str
    ctr_score: int

class TitlesResponse(BaseModel):
    titles: list[TitleResult]

@app.post("/api/generate-titles", dependencies=[Depends(verify_recaptcha), Depends(rate_limiter)])
def generate_titles(request: TitleRequest):
    topic = request.topic.strip() or "this topic"
    
    if gemini_model:
        try:
            lang_instruction = (
                f" Write the titles in {language_name(request.lang)}."
                if request.lang != "en" else ""
            )
            prompt = f"Generate 5 highly clickable, engaging YouTube video titles about '{topic}'.{lang_instruction} Return ONLY a valid JSON array of objects, where each object has a 'title' string and a 'ctr_score' integer between 85 and 99. Example: [{{\"title\": \"The truth about {topic}\", \"ctr_score\": 92}}]"
            response = gemini_model.generate_content(prompt, generation_config={"response_mime_type": "application/json"})
            data = json.loads(response.text)
            titles = [TitleResult(**item) for item in data]
            return TitlesResponse(titles=titles)
        except Exception as e:
            print(f"Gemini Title Error: {e}")
            # Fallback below
            
    templates = [
        f"The Ultimate Guide to {topic} (2026)",
        f"Why {topic} is Changing Everything",
        f"I Tried {topic} For 30 Days",
        f"The TRUTH About {topic}",
        f"Stop Doing {topic} Like This!"
    ]
    
    titles = [TitleResult(title=t, ctr_score=random.randint(85, 98)) for t in random.sample(templates, min(4, len(templates)))]
    return TitlesResponse(titles=titles)

class ThumbnailRequest(BaseModel):
    topic: str
    lang: str = "en"

class ThumbnailIdea(BaseModel):
    concept_name: str
    visual_description: str
    text_on_screen: str

class ThumbnailsResponse(BaseModel):
    thumbnails: list[ThumbnailIdea]

@app.post("/api/generate-thumbnails", dependencies=[Depends(verify_recaptcha), Depends(rate_limiter)])
def generate_thumbnails(request: ThumbnailRequest):
    topic = request.topic.strip() or "this"
    
    if gemini_model:
        try:
            lang_instruction = (
                f" Write all three fields in {language_name(request.lang)}."
                if request.lang != "en" else ""
            )
            prompt = f"Generate 3 distinct, high-converting YouTube thumbnail concepts for a video about '{topic}'.{lang_instruction} Return ONLY a valid JSON array of objects, where each object has 'concept_name' (string), 'visual_description' (detailed prompt describing the visuals), and 'text_on_screen' (very short catchy 1-4 word text). Example: [{{\"concept_name\": \"Shocked Face\", \"visual_description\": \"A close up of a shocked face pointing at a chart.\", \"text_on_screen\": \"OMG!\"}}]"
            response = gemini_model.generate_content(prompt, generation_config={"response_mime_type": "application/json"})
            data = json.loads(response.text)
            ideas = [ThumbnailIdea(**item) for item in data]
            return ThumbnailsResponse(thumbnails=ideas)
        except Exception as e:
            print(f"Gemini Thumbnail Error: {e}")
            # Fallback below
            
    ideas = [
        ThumbnailIdea(concept_name="The Shocked Reaction", visual_description=f"Shocked face, blurred {topic} background.", text_on_screen="DON'T DO THIS!"),
        ThumbnailIdea(concept_name="Before & After", visual_description=f"Split screen {topic} comparison.", text_on_screen="NOOB vs PRO"),
        ThumbnailIdea(concept_name="The Proof", visual_description=f"Holding physical proof of {topic} results.", text_on_screen="IT WORKED!")
    ]
    return ThumbnailsResponse(thumbnails=ideas)

class TagRequest(BaseModel):
    url: str

@app.post("/api/extract-tags", dependencies=[Depends(verify_recaptcha), Depends(rate_limiter)])
def extract_tags(request: TagRequest):
    return {"tags": ["seo", "youtube growth", "monetization"]}

class EarningsRequest(BaseModel):
    daily_views: int
    niche: str

@app.post("/api/calculate-earnings", dependencies=[Depends(verify_recaptcha), Depends(rate_limiter)])
def calculate_earnings(request: EarningsRequest):
    niche = request.niche.lower().strip()
    
    # Fetch real CPC data for the niche/keyword
    kw_data = get_cached_keyword(db, niche)
    if not kw_data:
        kw_data = fetch_keyword_data(niche, db)
        set_cached_keyword(db, niche, kw_data)
        
    cpc = kw_data.get('cpc', 1.0)
    
    # Assuming 1% CTR, 1000 views = 10 clicks. 
    # YouTube keeps ~45%, Creator gets 55%.
    # RPM = 10 clicks * CPC * 0.55 = CPC * 5.5
    rpm = cpc * 5.5
    
    # Create a range
    min_rpm = rpm * 0.7
    max_rpm = rpm * 1.3
        
    monthly_views = request.daily_views * 30
    min_earnings = (monthly_views / 1000) * min_rpm
    max_earnings = (monthly_views / 1000) * max_rpm
    
    return {
        "min_monthly": round(min_earnings, 2),
        "max_monthly": round(max_earnings, 2),
        "currency": "USD"
    }

# --- Admin user management -------------------------------------------------
# Backs admin_panel's "Admins" page. The Firebase Admin SDK is the only way to
# list users or grant the `admin` custom claim, so this can't be done from the
# browser with the client SDK the rest of admin_panel uses.

class AdminUserInfo(BaseModel):
    uid: str
    email: str | None = None
    disabled: bool
    admin: bool
    created_at: str | None = None
    last_sign_in: str | None = None

class AdminUsersResponse(BaseModel):
    users: list[AdminUserInfo]

@app.get("/api/admin/users", response_model=AdminUsersResponse)
def list_admin_users(caller: dict = Depends(verify_admin)):
    users = []
    for u in firebase_auth.list_users().iterate_all():
        claims = u.custom_claims or {}
        users.append(AdminUserInfo(
            uid=u.uid,
            email=u.email,
            disabled=u.disabled,
            admin=bool(claims.get("admin")),
            created_at=str(u.user_metadata.creation_timestamp) if u.user_metadata.creation_timestamp else None,
            last_sign_in=str(u.user_metadata.last_sign_in_timestamp) if u.user_metadata.last_sign_in_timestamp else None,
        ))
    return AdminUsersResponse(users=users)

class InviteAdminRequest(BaseModel):
    email: str
    password: str

@app.post("/api/admin/users/invite")
def invite_admin(request: InviteAdminRequest, caller: dict = Depends(verify_admin)):
    try:
        user = firebase_auth.create_user(email=request.email, password=request.password)
        firebase_auth.set_custom_user_claims(user.uid, {"admin": True})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    log_admin_action(db, caller.get("email", "unknown"), "Admin Invited", f"Invited {request.email} as admin (uid={user.uid})")
    return {"status": "ok", "uid": user.uid}

class SetRoleRequest(BaseModel):
    uid: str
    admin: bool

@app.post("/api/admin/users/set-role")
def set_admin_role(request: SetRoleRequest, caller: dict = Depends(verify_admin)):
    if request.uid == caller.get("uid") and not request.admin:
        raise HTTPException(status_code=400, detail="You cannot remove your own admin access.")
    try:
        firebase_auth.set_custom_user_claims(request.uid, {"admin": request.admin})
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    log_admin_action(
        db, caller.get("email", "unknown"), "Admin Role Changed",
        f"Set admin={request.admin} for uid={request.uid}"
    )
    return {"status": "ok"}

class SetDisabledRequest(BaseModel):
    uid: str
    disabled: bool

@app.post("/api/admin/users/set-disabled")
def set_user_disabled(request: SetDisabledRequest, caller: dict = Depends(verify_admin)):
    if request.uid == caller.get("uid") and request.disabled:
        raise HTTPException(status_code=400, detail="You cannot disable your own account.")
    try:
        firebase_auth.update_user(request.uid, disabled=request.disabled)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    log_admin_action(
        db, caller.get("email", "unknown"), "Admin Account Disabled" if request.disabled else "Admin Account Enabled",
        f"uid={request.uid}"
    )
    return {"status": "ok"}
