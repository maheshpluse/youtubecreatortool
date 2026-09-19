import os
import sys
import json
import time
import re
from datetime import date
from dotenv import load_dotenv
import google.generativeai as genai

# Add backend to path to import keyword_api
root_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
backend_dir = os.path.join(root_dir, 'backend')
sys.path.append(backend_dir)
from services.keyword_api import fetch_keyword_ideas

load_dotenv(os.path.join(backend_dir, '.env'))

api_key = os.environ.get("GEMINI_API_KEY")
if not api_key:
    print("No GEMINI_API_KEY found")
    sys.exit(1)

genai.configure(api_key=api_key)
model = genai.GenerativeModel("gemini-3.6-flash")

BLOG_SRC = os.path.dirname(os.path.abspath(__file__))
POSTS_JSON_PATH = os.path.join(BLOG_SRC, 'posts.json')
POSTS_DIR = os.path.join(BLOG_SRC, 'posts')

def generate_post_content(keyword, volume):
    prompt = f"""
You are an expert YouTube strategist and technical writer. 
Write a comprehensive, highly tactical, and detailed blog post about "{keyword}". 
The monthly search volume for this term is {volume}.

Return a JSON object with the following fields:
- "title": A catchy, click-worthy H1 title (max 60 chars)
- "seo_title": An SEO-optimized title tag
- "description": A compelling meta description (max 160 chars)
- "category": One of: "SEO", "Monetization", "Analytics", "Growth", "Equipment"
- "keywords": A list of 5-8 related keywords
- "faq": A list of 3-5 lists, each containing exactly two strings: [Question, Answer]
- "sources": A list of 1-2 lists, each containing exactly two strings: [Source Name, URL]
- "html_body": The main content of the article as a clean HTML string. 
  - DO NOT include an `<h1>` (it's injected automatically by the template).
  - Use `<h2>`, `<h3>`, `<p>`, `<ul>`, `<ol>`, `<li>`, `<strong>`, `<em>`, `<blockquote>`.
  - The content MUST be long-form, highly detailed, source-backed, and practical (at least 800-1000 words equivalent in HTML).
  - Do not use markdown backticks in the html_body field, just raw HTML string.
  - DO NOT include the `hero_figure` or ad slots, just the article body.

Example JSON output format:
{{
  "title": "...",
  "seo_title": "...",
  "description": "...",
  "category": "...",
  "keywords": ["..."],
  "faq": [["Q1", "A1"], ["Q2", "A2"]],
  "sources": [["YouTube Help", "https://support.google.com/youtube/..."]],
  "html_body": "<h2>...</h2><p>...</p>..."
}}
"""
    try:
        response = model.generate_content(prompt, generation_config={"response_mime_type": "application/json"})
        return json.loads(response.text)
    except Exception as e:
        print(f"Error generating content for {keyword}: {e}")
        return None

def main():
    with open(POSTS_JSON_PATH, 'r', encoding='utf-8') as f:
        posts = json.load(f)
    
    existing_slugs = {p['slug'] for p in posts}
    
    print("Generating keyword ideas via Gemini...")
    kw_prompt = f"""
    You are an expert YouTube SEO strategist. Generate a JSON list of exactly 50 high-value, highly specific target keywords/topics for a blog about YouTube SEO, growth, monetization, and analytics. 
    Ensure these topics are long-tail and cover practical issues creators face (e.g., "how to increase youtube retention", "best lighting for faceless channels", "what is youtube shorts rpm").
    
    Return a raw JSON array of objects with 'keyword' and 'volume' (an estimated monthly search volume integer between 500 and 20000).
    Exclude generic topics that are already heavily covered.
    
    Example output format:
    [
      {{"keyword": "how to increase youtube audience retention", "volume": 3500}},
      {{"keyword": "best lighting setup for faceless channels", "volume": 1200}}
    ]
    """
    
    try:
        res = model.generate_content(kw_prompt, generation_config={"response_mime_type": "application/json"})
        ideas = json.loads(res.text)
    except Exception as e:
        print(f"Failed to generate keywords: {e}")
        return
        
    candidates = []
    for idea in ideas:
        kw = idea.get('keyword', '')
        vol = idea.get('volume', 1000)
        slug = re.sub(r'[^a-z0-9]+', '-', kw.lower()).strip('-')
        if slug and slug not in existing_slugs:
            candidates.append((slug, kw, vol))
            existing_slugs.add(slug)
    
    target_count = 50
    selected = candidates[:target_count]
    
    print(f"Selected {len(selected)} keywords to generate.")
    
    today = date.today().isoformat()
    
    new_posts = []
    
    for i, (slug, kw, vol) in enumerate(selected):
        print(f"[{i+1}/{len(selected)}] Generating post for '{kw}' (slug: {slug})...")
        
        post_data = generate_post_content(kw, vol)
        if not post_data:
            print(f"  -> Failed. Skipping.")
            continue
            
        post_entry = {
            "slug": slug,
            "title": post_data.get("title", kw.title()),
            "seo_title": post_data.get("seo_title", kw.title()),
            "description": post_data.get("description", f"Guide to {kw}"),
            "category": post_data.get("category", "Growth"),
            "date": today,
            "keywords": post_data.get("keywords", []),
            "faq": post_data.get("faq", []),
            "sources": post_data.get("sources", [])
        }
        
        html_body = post_data.get("html_body", f"<p>Comprehensive guide to {kw}.</p>")
        
        # Write HTML body
        html_path = os.path.join(POSTS_DIR, f"{slug}.html")
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_body)
            
        new_posts.append(post_entry)
        
        time.sleep(2)
        
    print(f"Successfully generated {len(new_posts)} posts.")
    
    if new_posts:
        posts.extend(new_posts)
        with open(POSTS_JSON_PATH, 'w', encoding='utf-8') as f:
            json.dump(posts, f, indent=2)
        print("Updated posts.json.")

    
if __name__ == "__main__":
    main()
