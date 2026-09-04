import json
import os
import google.generativeai as genai
from dotenv import load_dotenv
import time

load_dotenv()

# Configure Gemini
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    print("Error: GEMINI_API_KEY is not set in .env")
    exit(1)

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-1.5-flash")

# Define target languages
LANGUAGES = {
    "si": "Sinhala",
    "hi": "Hindi",
    "es": "Spanish"
}

input_file = "../frontend/web/assets/i18n/en.json"
output_dir = "../frontend/web/assets/i18n"

with open(input_file, "r") as f:
    base_texts = json.load(f)

for lang_code, lang_name in LANGUAGES.items():
    output_file = os.path.join(output_dir, f"{lang_code}.json")
    if os.path.exists(output_file):
        print(f"Skipping {lang_name} ({lang_code}.json) as it already exists.")
        continue

    print(f"Translating to {lang_name}...")
    
    prompt = f"""
    You are an expert translator specializing in localizing modern software applications, particularly for YouTube Creators.
    Translate the following JSON object containing UI text from English to {lang_name}.
    
    Rules:
    1. The translation MUST feel natural and native to someone speaking {lang_name}. Avoid robotic or literal translations.
    2. Maintain any placeholders like {{count}} exactly as they are.
    3. Output ONLY valid JSON. Do not include markdown code blocks, just the raw JSON text.
    4. Keep the JSON keys exactly the same.
    
    JSON to translate:
    {json.dumps(base_texts, indent=2)}
    """
    
    try:
        response = model.generate_content(prompt)
        # Strip potential markdown formatting
        text = response.text.strip()
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]
            
        translated_json = json.loads(text)
        
        with open(output_file, "w") as f:
            json.dump(translated_json, f, indent=2, ensure_ascii=False)
            
        print(f"Successfully generated {lang_code}.json")
        time.sleep(2) # Rate limit protection
    except Exception as e:
        print(f"Failed to translate {lang_name}: {e}")
