#!/usr/bin/env python3
"""
CreatorTools.io blog hero-image generator.

Every image is drawn from code here — no stock photography, no scraped assets,
nothing with a licence attached. That matters for AdSense: image provenance is
one of the things a policy review actually checks, and "we generated it" is the
only answer that is airtight.

Reads  : blog_src/posts.json
Writes : web/images/blog/hero/<slug>.svg   in-page hero (~4 KB, crisp on retina)
         web/images/blog/hero/<slug>.png   1200x630 og:image / twitter:image
         blog_src/hero_manifest.json       paths + alt text, read by build_blog.py

The PNG exists because Facebook, LinkedIn and X will not render an SVG in a
social card, and Google Discover wants a raster >=1200px wide. It is rendered
by headless Chrome so it matches the SVG exactly.

Run:  python3 blog_src/build_images.py
Then: python3 blog_src/build_blog.py     (wires them into the HTML)
"""

import hashlib
import html
import json
import math
import os
import random
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "blog_src")
HERO = os.path.join(ROOT, "web", "images", "blog", "hero")

W, H = 1200, 630          # 1.91:1, the og:image aspect every platform crops to

# Site palette, lifted from web/blog/assets/blog.css (dark theme).
BG        = "#0f0f0f"
PANEL     = "#181818"
BORDER    = "#303030"
GRID      = "#1e1e1e"
TEXT      = "#f1f1f1"
MUTED     = "#aaaaaa"
DIM       = "#717171"
RED       = "#ff0000"
RED_DIM   = "#cc0000"
BLUE      = "#3ea6ff"
GREEN     = "#2ba640"

FONT = ("system-ui,-apple-system,'Segoe UI',Roboto,'Helvetica Neue',Arial,sans-serif")

# Motif per post. Keyword match wins; category is the fallback. Keeping this
# explicit beats being clever — you can see at a glance what each post gets.
KEYWORD_MOTIFS = [
    ("click-through",          "ctr"),
    ("engagement-rate",        "rings"),
    ("keyword-research",       "keywords"),
    ("algorithm",              "network"),
    ("competitor",             "radar"),
    ("target-audience",        "radar"),
    ("funnel",                 "funnel"),
    ("checklist",              "checklist"),
    ("monetization-requirem",  "checklist"),
    ("rpm",                    "bars"),
    ("adsense-revenue",        "bars"),
    ("cpc",                    "bars"),
    ("passive-income",         "streams"),
    ("affiliate",              "streams"),
    ("sponsored",              "streams"),
    ("online-business",        "streams"),
    ("tools",                  "toolbox"),
    ("organic-traffic",        "line"),
    ("analytics",              "line"),
    ("rank-higher",            "search"),
]
CATEGORY_MOTIFS = {
    "SEO": "search", "Analytics": "line", "Monetization": "bars",
    "Strategy": "network", "Marketing": "funnel", "Growth": "radar",
    "Tools": "toolbox",
}


def motif_for(post):
    for needle, motif in KEYWORD_MOTIFS:
        if needle in post["slug"]:
            return motif
    return CATEGORY_MOTIFS.get(post["category"], "bars")


def count_words(post):
    """Same arithmetic as build_blog.py, so the image and the byline agree."""
    path = os.path.join(SRC, "posts", post["slug"] + ".html")
    text = ""
    if os.path.exists(path):
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
    text += " ".join(q + " " + a for q, a in post.get("faq", []))
    text = html.unescape(re.sub(r"<[^>]+>", " ", text))
    return len([w for w in re.split(r"\s+", text) if w.strip()])


def rng_for(slug):
    """Deterministic per-post randomness, so rebuilds never churn the images."""
    return random.Random(int(hashlib.md5(slug.encode()).hexdigest()[:12], 16))


# ─────────────────────────────────────────────────────────────
#  Text helpers
# ─────────────────────────────────────────────────────────────

def esc(s):
    return html.escape(str(s), quote=True)


def wrap(text, max_chars, max_lines):
    words, lines, cur = text.split(), [], ""
    for word in words:
        trial = (cur + " " + word).strip()
        if len(trial) <= max_chars:
            cur = trial
            continue
        if cur:
            lines.append(cur)
        cur = word
        if len(lines) == max_lines:
            break
    if cur and len(lines) < max_lines:
        lines.append(cur)
    if len(lines) == max_lines and len(" ".join(lines)) < len(text):
        last = lines[-1]
        while last and len(last) > max_chars - 1:
            last = last.rsplit(" ", 1)[0] if " " in last else last[:-1]
        lines[-1] = last.rstrip(" ,.;:") + "…"
    return lines


# ─────────────────────────────────────────────────────────────
#  Motifs — each returns SVG drawn inside the 428x430 right-hand panel
#  at (px, py). All coordinates are absolute for readability.
# ─────────────────────────────────────────────────────────────

def m_bars(r, px, py, pw, ph):
    """Ascending revenue bars with a trend line — RPM, CPC, AdSense."""
    n = 7
    gap, pad = 14, 34
    bw = (pw - pad * 2 - gap * (n - 1)) / n
    base = py + ph - pad - 26
    top = py + pad + 30
    vals, v = [], r.uniform(0.16, 0.28)
    for i in range(n):
        v = min(1.0, v + r.uniform(0.06, 0.20))
        vals.append(v)
    out, pts = [], []
    for i, val in enumerate(vals):
        x = px + pad + i * (bw + gap)
        bh = (base - top) * val
        fill = RED if i >= n - 2 else "#3a3a3a"
        out.append(f'<rect x="{x:.0f}" y="{base-bh:.0f}" width="{bw:.0f}" height="{bh:.0f}" rx="4" fill="{fill}"/>')
        pts.append((x + bw / 2, base - bh))
    path = " ".join(("M" if i == 0 else "L") + f"{x:.0f} {y:.0f}" for i, (x, y) in enumerate(pts))
    out.append(f'<path d="{path}" fill="none" stroke="{BLUE}" stroke-width="2.5" stroke-linecap="round" opacity=".85"/>')
    for x, y in pts[-2:]:
        out.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="4" fill="{BLUE}"/>')
    out.append(f'<line x1="{px+pad}" y1="{base+1}" x2="{px+pw-pad}" y2="{base+1}" stroke="{BORDER}" stroke-width="2"/>')
    return "\n".join(out)


def m_line(r, px, py, pw, ph):
    """Growth curve with filled area — analytics, organic traffic."""
    pad = 34
    x0, x1 = px + pad, px + pw - pad
    base = py + ph - pad - 26
    top = py + pad + 34
    n = 9
    vals, v = [], r.uniform(0.10, 0.20)
    for _ in range(n):
        v = min(1.0, max(0.05, v + r.uniform(0.02, 0.17)))
        vals.append(v)
    pts = [(x0 + (x1 - x0) * i / (n - 1), base - (base - top) * v) for i, v in enumerate(vals)]
    line = " ".join(("M" if i == 0 else "L") + f"{x:.0f} {y:.0f}" for i, (x, y) in enumerate(pts))
    area = line + f" L{x1:.0f} {base:.0f} L{x0:.0f} {base:.0f} Z"
    out = [f'<path d="{area}" fill="url(#gArea)"/>',
           f'<path d="{line}" fill="none" stroke="{RED}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>']
    for gy in range(4):
        y = top + (base - top) * gy / 3
        out.insert(0, f'<line x1="{x0}" y1="{y:.0f}" x2="{x1}" y2="{y:.0f}" stroke="{GRID}" stroke-width="1"/>')
    lx, ly = pts[-1]
    out += [f'<circle cx="{lx:.0f}" cy="{ly:.0f}" r="7" fill="{RED}" opacity=".25"/>',
            f'<circle cx="{lx:.0f}" cy="{ly:.0f}" r="4" fill="{RED}"/>',
            f'<line x1="{x0}" y1="{base+1}" x2="{x1}" y2="{base+1}" stroke="{BORDER}" stroke-width="2"/>']
    return "\n".join(out)


def m_search(r, px, py, pw, ph):
    """Ranked search results, top slot highlighted — SEO / ranking."""
    pad = 32
    x = px + pad
    w = pw - pad * 2
    out, y = [], py + pad + 22
    for i in range(5):
        hi = i == 0
        rowh = 54 if hi else 46
        stroke = RED if hi else BORDER
        fill = "#1f1414" if hi else PANEL
        out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{rowh}" rx="8" fill="{fill}" stroke="{stroke}" stroke-width="{2 if hi else 1}"/>')
        out.append(f'<rect x="{x+14}" y="{y+ (rowh-26)/2:.0f}" width="40" height="26" rx="4" fill="{"#3a1616" if hi else "#242424"}"/>')
        out.append(f'<polygon points="{x+30},{y+rowh/2-6:.0f} {x+30},{y+rowh/2+6:.0f} {x+40},{y+rowh/2:.0f}" fill="{RED if hi else DIM}"/>')
        tw = w - 90 - r.randint(0, 60)
        out.append(f'<rect x="{x+66}" y="{y+rowh/2-11:.0f}" width="{tw:.0f}" height="8" rx="4" fill="{TEXT if hi else "#3a3a3a"}" opacity="{1 if hi else .9}"/>')
        out.append(f'<rect x="{x+66}" y="{y+rowh/2+3:.0f}" width="{tw*0.55:.0f}" height="7" rx="3.5" fill="{DIM if hi else "#2c2c2c"}"/>')
        if hi:
            out.append(f'<text x="{x+w-16}" y="{y+rowh/2+5:.0f}" text-anchor="end" font-family="{FONT}" font-size="13" font-weight="700" fill="{RED}">#1</text>')
        y += rowh + 12
    return "\n".join(out)


def m_ctr(r, px, py, pw, ph):
    """Thumbnail grid with a cursor on the winner — click-through rate."""
    pad = 34
    cols, rows = 3, 2
    gap = 16
    tw = (pw - pad * 2 - gap * (cols - 1)) / cols
    th = tw * 9 / 16
    grid_h = rows * th + (rows - 1) * (gap + 18)
    x0, y0 = px + pad, py + (ph - grid_h) / 2 + 14
    win = r.randrange(cols * rows)
    out = []
    for i in range(cols * rows):
        cx = x0 + (i % cols) * (tw + gap)
        cy = y0 + (i // cols) * (th + gap + 18)
        hi = i == win
        out.append(f'<rect x="{cx:.0f}" y="{cy:.0f}" width="{tw:.0f}" height="{th:.0f}" rx="7" fill="{"#241414" if hi else "#1c1c1c"}" stroke="{RED if hi else BORDER}" stroke-width="{2 if hi else 1}"/>')
        out.append(f'<rect x="{cx+9:.0f}" y="{cy+th+7:.0f}" width="{tw*r.uniform(.55,.9):.0f}" height="6" rx="3" fill="{"#3a3a3a" if not hi else DIM}"/>')
        if hi:
            out.append(f'<circle cx="{cx+tw/2:.0f}" cy="{cy+th/2:.0f}" r="17" fill="{RED}" opacity=".18"/>')
            out.append(f'<polygon points="{cx+tw/2-5:.0f},{cy+th/2-8:.0f} {cx+tw/2-5:.0f},{cy+th/2+8:.0f} {cx+tw/2+8:.0f},{cy+th/2:.0f}" fill="{RED}"/>')
    # cursor
    wx = x0 + (win % cols) * (tw + gap) + tw * 0.72
    wy = y0 + (win // cols) * (th + gap + 18) + th * 0.74
    out.append(f'<path d="M{wx:.0f} {wy:.0f} l0 22 l5.5 -6 l4 9 l5 -2.4 l-4 -8.6 l8 -0.5 Z" fill="{TEXT}" stroke="{BG}" stroke-width="1.6" stroke-linejoin="round"/>')
    pct = r.choice(["7.4%", "8.1%", "9.6%", "11.2%", "6.8%"])
    out.append(f'<text x="{px+pad}" y="{py+pad+22}" font-family="{FONT}" font-size="15" font-weight="700" fill="{MUTED}">CTR <tspan fill="{GREEN}">{pct}</tspan></text>')
    return "\n".join(out)


def m_funnel(r, px, py, pw, ph):
    """Four-stage funnel — marketing / conversion posts."""
    pad = 58
    cx = px + pw / 2
    top, bot = py + pad + 30, py + ph - pad - 20
    stages = 4
    sh = (bot - top - 12 * (stages - 1)) / stages
    widths = [pw - pad * 2]
    for _ in range(stages):
        widths.append(widths[-1] * r.uniform(0.62, 0.78))
    out = []
    for i in range(stages):
        y = top + i * (sh + 12)
        wt, wb = widths[i], widths[i + 1]
        col = [RED, "#d81f1f", "#a52020", "#6e1c1c"][i]
        out.append(f'<path d="M{cx-wt/2:.0f} {y:.0f} L{cx+wt/2:.0f} {y:.0f} L{cx+wb/2:.0f} {y+sh:.0f} L{cx-wb/2:.0f} {y+sh:.0f} Z" fill="{col}" opacity="{0.92 - i*0.13:.2f}"/>')
        out.append(f'<rect x="{cx-wb/2*0.5:.0f}" y="{y+sh/2-4:.0f}" width="{wb*0.5:.0f}" height="8" rx="4" fill="{BG}" opacity=".38"/>')
    return "\n".join(out)


def m_network(r, px, py, pw, ph):
    """Recommendation graph — algorithm / strategy posts."""
    pad = 46
    cx, cy = px + pw / 2, py + ph / 2 + 8
    out, nodes = [], []
    for ring, (count, rad, size) in enumerate([(5, 96, 9), (8, 165, 6)]):
        off = r.uniform(0, math.tau)
        for i in range(count):
            a = off + math.tau * i / count
            nodes.append((cx + math.cos(a) * rad * 1.06, cy + math.sin(a) * rad * 0.82, size, ring))
    for x, y, s, ring in nodes:
        out.insert(0, f'<line x1="{cx:.0f}" y1="{cy:.0f}" x2="{x:.0f}" y2="{y:.0f}" stroke="{"#3a2020" if ring==0 else GRID}" stroke-width="{1.6 if ring==0 else 1}"/>')
    for i in range(6):
        a, b = r.sample(nodes, 2)
        out.insert(0, f'<line x1="{a[0]:.0f}" y1="{a[1]:.0f}" x2="{b[0]:.0f}" y2="{b[1]:.0f}" stroke="{GRID}" stroke-width="1"/>')
    for x, y, s, ring in nodes:
        out.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{s}" fill="{RED_DIM if ring==0 else "#3a3a3a"}"/>')
    out.append(f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="30" fill="{RED}" opacity=".16"/>')
    out.append(f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="20" fill="{RED}"/>')
    out.append(f'<polygon points="{cx-6:.0f},{cy-9:.0f} {cx-6:.0f},{cy+9:.0f} {cx+9:.0f},{cy:.0f}" fill="#fff"/>')
    return "\n".join(out)


def m_radar(r, px, py, pw, ph):
    """Radar chart — competitor analysis / audience fit."""
    cx, cy = px + pw / 2, py + ph / 2 + 6
    rad = min(pw, ph) / 2 - 56
    axes = 6
    out = []
    for step in (0.34, 0.67, 1.0):
        pts = " ".join(f"{cx + math.cos(math.tau*i/axes - math.pi/2)*rad*step:.0f},"
                       f"{cy + math.sin(math.tau*i/axes - math.pi/2)*rad*step:.0f}" for i in range(axes))
        out.append(f'<polygon points="{pts}" fill="none" stroke="{GRID}" stroke-width="1"/>')
    for i in range(axes):
        a = math.tau * i / axes - math.pi / 2
        out.append(f'<line x1="{cx:.0f}" y1="{cy:.0f}" x2="{cx+math.cos(a)*rad:.0f}" y2="{cy+math.sin(a)*rad:.0f}" stroke="{GRID}" stroke-width="1"/>')
    for name, col, lo, hi in (("them", DIM, 0.30, 0.62), ("you", RED, 0.45, 0.97)):
        pts, dots = [], []
        for i in range(axes):
            a = math.tau * i / axes - math.pi / 2
            v = r.uniform(lo, hi)
            x, y = cx + math.cos(a) * rad * v, cy + math.sin(a) * rad * v
            pts.append(f"{x:.0f},{y:.0f}")
            dots.append((x, y))
        out.append(f'<polygon points="{" ".join(pts)}" fill="{col}" fill-opacity="{.13 if name=="them" else .22}" stroke="{col}" stroke-width="{2 if name=="them" else 2.8}" stroke-linejoin="round"/>')
        if name == "you":
            out += [f'<circle cx="{x:.0f}" cy="{y:.0f}" r="3.5" fill="{col}"/>' for x, y in dots]
    return "\n".join(out)


def m_rings(r, px, py, pw, ph):
    """Concentric progress rings — engagement rate."""
    cx, cy = px + pw / 2, py + ph / 2 + 4
    out = []
    specs = [(132, RED, r.uniform(.58, .88)), (98, BLUE, r.uniform(.42, .74)), (64, GREEN, r.uniform(.30, .60))]
    for rad, col, frac in specs:
        circ = math.tau * rad
        out.append(f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="{rad}" fill="none" stroke="{PANEL}" stroke-width="16"/>')
        out.append(f'<circle cx="{cx:.0f}" cy="{cy:.0f}" r="{rad}" fill="none" stroke="{col}" stroke-width="16" '
                   f'stroke-linecap="round" stroke-dasharray="{circ*frac:.0f} {circ:.0f}" '
                   f'transform="rotate(-90 {cx:.0f} {cy:.0f})"/>')
    pct = f"{specs[0][2]*10:.1f}%"
    out.append(f'<text x="{cx:.0f}" y="{cy+9:.0f}" text-anchor="middle" font-family="{FONT}" font-size="30" font-weight="800" fill="{TEXT}">{pct}</text>')
    return "\n".join(out)


def m_keywords(r, px, py, pw, ph):
    """Keyword rows with volume bars and a magnifier — keyword research."""
    pad = 34
    x, w = px + pad, pw - pad * 2
    out, y = [], py + pad + 30
    for i in range(6):
        vol = r.uniform(0.22, 1.0)
        col = RED if vol > 0.72 else ("#8a2626" if vol > 0.45 else "#333")
        out.append(f'<rect x="{x}" y="{y}" width="{w}" height="34" rx="6" fill="{PANEL}"/>')
        out.append(f'<rect x="{x}" y="{y}" width="{w*vol:.0f}" height="34" rx="6" fill="{col}" opacity=".55"/>')
        out.append(f'<rect x="{x+12}" y="{y+13}" width="{r.randint(58,120)}" height="8" rx="4" fill="{TEXT}" opacity=".55"/>')
        out.append(f'<text x="{x+w-12}" y="{y+22}" text-anchor="end" font-family="{FONT}" font-size="12" font-weight="700" fill="{MUTED}">{int(vol*90)+9}K</text>')
        y += 42
    mx, my = px + pw - 74, py + pad + 6
    out.append(f'<circle cx="{mx}" cy="{my}" r="20" fill="none" stroke="{BLUE}" stroke-width="4"/>')
    out.append(f'<line x1="{mx+14}" y1="{my+14}" x2="{mx+28}" y2="{my+28}" stroke="{BLUE}" stroke-width="4" stroke-linecap="round"/>')
    return "\n".join(out)


def m_checklist(r, px, py, pw, ph):
    """Requirement checklist — monetization requirements, SEO checklist."""
    pad = 36
    x, w = px + pad, pw - pad * 2
    out, y = [], py + pad + 26
    done = r.randint(3, 5)
    for i in range(6):
        ok = i < done
        out.append(f'<rect x="{x}" y="{y}" width="{w}" height="44" rx="8" fill="{PANEL}" stroke="{BORDER}" stroke-width="1"/>')
        bx, by = x + 16, y + 22
        if ok:
            out.append(f'<circle cx="{bx+8}" cy="{by}" r="11" fill="{GREEN}"/>')
            out.append(f'<path d="M{bx+3} {by} l4 4.5 l8 -9" fill="none" stroke="#fff" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>')
        else:
            out.append(f'<circle cx="{bx+8}" cy="{by}" r="11" fill="none" stroke="{DIM}" stroke-width="2"/>')
        out.append(f'<rect x="{bx+30}" y="{by-4}" width="{r.randint(120, int(w-90))}" height="8" rx="4" fill="{TEXT if ok else DIM}" opacity="{.72 if ok else .45}"/>')
        y += 52
    return "\n".join(out)


def m_streams(r, px, py, pw, ph):
    """Stacked income streams flowing into one total — passive income, affiliate."""
    pad = 38
    x0, x1 = px + pad, px + pw - pad
    cy = py + ph / 2 + 6
    out = []
    cols = [RED, "#d81f1f", BLUE, GREEN]
    n = 4
    for i in range(n):
        sy = py + pad + 34 + i * 62
        wgt = r.uniform(6, 20)
        out.append(f'<rect x="{x0}" y="{sy-9}" width="{r.randint(70,110)}" height="18" rx="9" fill="{cols[i]}" opacity=".85"/>')
        out.append(f'<path d="M{x0+118} {sy} C{x0+200} {sy}, {x1-150} {cy}, {x1-70} {cy}" fill="none" '
                   f'stroke="{cols[i]}" stroke-width="{wgt:.0f}" stroke-linecap="round" opacity=".32"/>')
    out.append(f'<circle cx="{x1-44}" cy="{cy:.0f}" r="42" fill="{RED}" opacity=".14"/>')
    out.append(f'<circle cx="{x1-44}" cy="{cy:.0f}" r="30" fill="{RED}"/>')
    out.append(f'<text x="{x1-44}" y="{cy+11:.0f}" text-anchor="middle" font-family="{FONT}" font-size="27" font-weight="800" fill="#fff">$</text>')
    return "\n".join(out)


def m_toolbox(r, px, py, pw, ph):
    """Grid of tool tiles — the tools round-up post."""
    pad = 38
    cols, rows_n = 3, 3
    gap = 16
    tw = (pw - pad * 2 - gap * (cols - 1)) / cols
    th = (ph - pad * 2 - 26 - gap * (rows_n - 1)) / rows_n
    out = []
    lit = r.sample(range(cols * rows_n), 3)
    for i in range(cols * rows_n):
        cx = px + pad + (i % cols) * (tw + gap)
        cy = py + pad + 26 + (i // cols) * (th + gap)
        hi = i in lit
        out.append(f'<rect x="{cx:.0f}" y="{cy:.0f}" width="{tw:.0f}" height="{th:.0f}" rx="10" fill="{"#241414" if hi else PANEL}" stroke="{RED if hi else BORDER}" stroke-width="{2 if hi else 1}"/>')
        icx, icy = cx + tw / 2, cy + th / 2
        out.append(f'<rect x="{icx-15:.0f}" y="{icy-15:.0f}" width="30" height="30" rx="8" fill="{RED if hi else "#333"}" opacity="{.9 if hi else .8}"/>')
    return "\n".join(out)


ALT = {
    "bars": "Bar chart of rising revenue per thousand views, with a trend line over the final months",
    "line": "Line chart showing channel traffic growing steadily across nine reporting periods",
    "search": "YouTube search results list with the number one ranking position highlighted",
    "ctr": "Grid of video thumbnails with a cursor clicking the best performing one",
    "funnel": "Four-stage marketing funnel narrowing from audience reach down to conversion",
    "network": "Recommendation network diagram with a central video linked to related videos",
    "radar": "Radar chart comparing your channel against a competitor across six metrics",
    "rings": "Concentric progress rings showing an engagement rate percentage",
    "keywords": "Keyword research table with monthly search volume bars and a magnifier",
    "checklist": "Requirements checklist with several criteria met and others outstanding",
    "streams": "Four separate income streams converging into a single revenue total",
    "toolbox": "Grid of creator tool tiles with three highlighted as recommended picks",
}

# Short editorial caption under the in-page label. Written to fit two lines —
# truncating the longer ALT strings here just looked unfinished.
CAPTION = {
    "bars": "Revenue per thousand views, month over month",
    "line": "Traffic compounding across nine periods",
    "search": "The top slot takes most of the clicks",
    "ctr": "One thumbnail earns the click",
    "funnel": "Reach narrowing down to conversion",
    "network": "How one video pulls in the next",
    "radar": "Where you beat the competition",
    "rings": "Likes and comments per view",
    "keywords": "Search volume behind each term",
    "checklist": "What you need before monetizing",
    "streams": "Four income lines, one total",
    "toolbox": "The tools worth paying for",
}

LABEL = {
    "bars": "Revenue growth", "line": "Traffic growth", "search": "Search ranking",
    "ctr": "Click-through rate", "funnel": "Conversion funnel",
    "network": "Recommendation graph", "radar": "Competitive gap",
    "rings": "Engagement rate", "keywords": "Keyword volume",
    "checklist": "Eligibility checklist", "streams": "Revenue streams",
    "toolbox": "Creator toolkit",
}

MOTIFS = {"bars": m_bars, "line": m_line, "search": m_search, "ctr": m_ctr,
          "funnel": m_funnel, "network": m_network, "radar": m_radar,
          "rings": m_rings, "keywords": m_keywords, "checklist": m_checklist,
          "streams": m_streams, "toolbox": m_toolbox}


# ─────────────────────────────────────────────────────────────
#  Composition
# ─────────────────────────────────────────────────────────────

def build_svg(post, titled):
    """titled=True  -> social card; the headline has to be in the picture.
       titled=False -> in-page hero; the <h1> is right above it, so repeating
                       the headline just makes the page look stuttered."""
    r = rng_for(post["slug"])
    motif = motif_for(post)
    lines = wrap(post["title"], 24, 3) if titled else [LABEL[motif]]

    px, py, pw, ph = 668, 100, 460, 430          # right-hand motif panel
    art = MOTIFS[motif](r, px, py, pw, ph)

    ty = 250 - (len(lines) - 1) * 27
    title = "\n".join(
        f'    <text x="72" y="{ty + i*62}" font-family="{FONT}" font-size="46" font-weight="800" '
        f'fill="{TEXT}" letter-spacing="-.5">{esc(l)}</text>' for i, l in enumerate(lines))

    read = max(1, round(post["_words"] / 220))
    sub_y = ty + len(lines) * 62 + 6
    if titled:
        read_line = (f'  <text x="72" y="{sub_y}" font-family="{FONT}" font-size="17" '
                     f'font-weight="500" fill="{DIM}">{read} min read</text>')
    else:
        # Caption the graphic, wrapped so it stays clear of the motif panel.
        read_line = "\n".join(
            f'  <text x="72" y="{sub_y + i*26}" font-family="{FONT}" font-size="18" '
            f'font-weight="500" fill="{DIM}">{esc(cl)}</text>'
            for i, cl in enumerate(wrap(CAPTION[motif], 34, 2)))

    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="{esc(post['title'])}">
  <defs>
    <linearGradient id="gArea" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{RED}" stop-opacity=".30"/>
      <stop offset="1" stop-color="{RED}" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="gGlow" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{RED}" stop-opacity=".14"/>
      <stop offset="1" stop-color="{RED}" stop-opacity="0"/>
    </linearGradient>
    <pattern id="gGrid" width="40" height="40" patternUnits="userSpaceOnUse">
      <path d="M40 0H0V40" fill="none" stroke="{GRID}" stroke-width="1"/>
    </pattern>
  </defs>

  <rect width="{W}" height="{H}" fill="{BG}"/>
  <rect width="{W}" height="{H}" fill="url(#gGrid)" opacity=".55"/>
  <circle cx="{W-150}" cy="90" r="330" fill="url(#gGlow)"/>
  <rect width="{W}" height="6" fill="{RED}"/>

  <!-- motif panel -->
  <rect x="{px}" y="{py}" width="{pw}" height="{ph}" rx="18" fill="{BG}" fill-opacity=".72" stroke="{BORDER}" stroke-width="1"/>
{art}

  <!-- headline block -->
  <rect x="72" y="{ty-76}" width="46" height="4" rx="2" fill="{RED}"/>
  <text x="72" y="{ty-46}" font-family="{FONT}" font-size="17" font-weight="700" fill="{RED}" letter-spacing="2.2">{esc(post['category'].upper())}</text>
{title}
{read_line}

  <!-- footer lockup -->
  <g transform="translate(72 {H-64})">
    <rect x="0" y="-16" width="30" height="30" rx="8" fill="{RED}"/>
    <polygon points="11,-8 11,6 22,-1" fill="#fff"/>
    <text x="42" y="6" font-family="{FONT}" font-size="19" font-weight="700" fill="{TEXT}">CreatorTools<tspan fill="{DIM}">.io</tspan></text>
  </g>
</svg>
"""


# ─────────────────────────────────────────────────────────────
#  Rasterise via headless Chrome
# ─────────────────────────────────────────────────────────────

CHROME_CANDIDATES = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    shutil.which("google-chrome") or "",
    shutil.which("chromium") or "",
]


def find_chrome():
    for c in CHROME_CANDIDATES:
        if c and os.path.exists(c):
            return c
    return None


def rasterise(chrome, sources, outdir):
    """One Chrome launch per image; the SVG is wrapped so it fills the viewport.
    `sources` maps slug -> SVG markup (the titled social variant)."""
    made = 0
    with tempfile.TemporaryDirectory() as tmp:
        for slug, svg in sorted(sources.items()):
            shim = os.path.join(tmp, slug + ".html")
            with open(shim, "w", encoding="utf-8") as fh:
                fh.write("<!doctype html><meta charset=utf-8>"
                         "<style>html,body{margin:0;padding:0;background:%s}"
                         "svg{display:block;width:%dpx;height:%dpx}</style>%s" % (BG, W, H, svg))
            png = os.path.join(outdir, slug + ".png")
            proc = subprocess.run(
                [chrome, "--headless", "--disable-gpu", "--no-sandbox", "--hide-scrollbars",
                 f"--window-size={W},{H}", f"--screenshot={png}", "file://" + shim],
                capture_output=True, text=True, timeout=90)
            if os.path.exists(png):
                made += 1
            else:
                print(f"  ! chrome failed for {slug}: {proc.stderr.strip()[:160]}")
    return made


def main():
    with open(os.path.join(SRC, "posts.json"), encoding="utf-8") as fh:
        posts = json.load(fh)
    os.makedirs(HERO, exist_ok=True)

    svgs = []
    social = {}
    counts = {}
    for post in posts:
        post["_words"] = count_words(post)
        path = os.path.join(HERO, post["slug"] + ".svg")
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(build_svg(post, titled=False))
        svgs.append(path)
        social[post["slug"]] = build_svg(post, titled=True)
        m = motif_for(post)
        counts[m] = counts.get(m, 0) + 1

    manifest = {
        p["slug"]: {
            "svg": "../images/blog/hero/%s.svg" % p["slug"],
            "png": "/images/blog/hero/%s.png" % p["slug"],
            "alt": ALT[motif_for(p)],
            "motif": motif_for(p),
            "w": W, "h": H,
        } for p in posts
    }
    with open(os.path.join(SRC, "hero_manifest.json"), "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=2, sort_keys=True)

    print(f"SVG   {len(svgs)} heroes -> web/images/blog/hero/")
    print("      motifs: " + ", ".join(f"{k}x{v}" for k, v in sorted(counts.items())))

    chrome = find_chrome()
    if not chrome:
        print("PNG   skipped - no Chrome/Chromium found. og:image needs the PNGs;")
        print("      install Chrome and re-run, or the build will fall back to SVG.")
        return 1
    made = rasterise(chrome, social, HERO)
    print(f"PNG   {made}/{len(social)} rendered at {W}x{H} via {os.path.basename(chrome)}")
    return 0 if made == len(svgs) else 1


if __name__ == "__main__":
    sys.exit(main())
