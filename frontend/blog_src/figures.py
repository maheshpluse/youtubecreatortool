#!/usr/bin/env python3
"""
Inline animated SVG figures for blog articles.

Authors drop a `{{figure:name}}` token into a post fragment; build_blog.py
swaps it for the markup below. Keeping the artwork here (rather than pasted
into 50 fragments) means a fix to one diagram fixes every article using it.

Rules every figure follows:
  * Inline `<style>` inside an SVG is NOT scoped to that SVG -- it leaks into
    the page. Every class is therefore namespaced `f<name>-` so two figures on
    one page cannot fight.
  * Colours come from the blog's CSS custom properties, with literal
    fallbacks, so a figure themes itself in both light and dark mode.
  * Motion is wrapped in `prefers-reduced-motion: no-preference`, so the
    animation is opt-in. With reduced motion the diagram renders in its final
    state -- still complete, just still.
  * `role="img"` + `<title>` so a screen reader gets one clear description
    instead of a pile of unlabelled shapes.
  * No JavaScript and no external requests: these cost nothing at runtime and
    cannot shift layout, which keeps Core Web Vitals clean.
"""

# Shared palette shorthand. Kept as a plain format string so each figure can
# interpolate it without importing anything.
_P = {
    "red": "var(--red, #cc0000)",
    "link": "var(--link, #065fd4)",
    "soft": "var(--text-soft, #606060)",
    "mute": "var(--text-mute, #909090)",
    "border": "var(--border, #e5e5e5)",
    "bgsoft": "var(--bg-soft, #f9f9f9)",
    "text": "var(--text, #0f0f0f)",
}


def _fig(name, title, caption, svg_body, view="0 0 720 300"):
    """Wrap a figure body in the shared <figure>/<svg> shell."""
    return (
        f'<figure class="fig" role="group">\n'
        f'  <svg class="fig-svg" viewBox="{view}" role="img" '
        f'aria-labelledby="t-{name}" preserveAspectRatio="xMidYMid meet">\n'
        f'    <title id="t-{name}">{title}</title>\n'
        f'{svg_body}\n'
        f'  </svg>\n'
        f'  <figcaption>{caption}</figcaption>\n'
        f'</figure>'
    )


# ── 1. Revenue bars ────────────────────────────────────────────────────────
_REVENUE_BARS = _fig(
    "revbars",
    "Bar chart showing advertising revenue climbing across six months",
    "Revenue compounds when RPM and volume rise together — the bars that matter "
    "are the last three, not the first.",
    f"""    <style>
      .frb-bar {{ fill: {_P['red']}; transform-origin: center bottom; }}
      .frb-grid {{ stroke: {_P['border']}; stroke-width: 1; }}
      .frb-lbl {{ fill: {_P['mute']}; font: 500 13px Roboto, system-ui, sans-serif; }}
      @media (prefers-reduced-motion: no-preference) {{
        .frb-bar {{ animation: frb-grow 2.4s cubic-bezier(.2,.7,.3,1) infinite; }}
        .frb-bar:nth-of-type(2) {{ animation-delay: .10s; }}
        .frb-bar:nth-of-type(3) {{ animation-delay: .20s; }}
        .frb-bar:nth-of-type(4) {{ animation-delay: .30s; }}
        .frb-bar:nth-of-type(5) {{ animation-delay: .40s; }}
        .frb-bar:nth-of-type(6) {{ animation-delay: .50s; }}
        @keyframes frb-grow {{
          0%, 100% {{ transform: scaleY(.35); opacity: .55; }}
          45%, 70% {{ transform: scaleY(1);   opacity: 1; }}
        }}
      }}
    </style>
    <line class="frb-grid" x1="60" y1="245" x2="680" y2="245"/>
    <line class="frb-grid" x1="60" y1="165" x2="680" y2="165"/>
    <line class="frb-grid" x1="60" y1="85"  x2="680" y2="85"/>
    <g>
      <rect class="frb-bar" x="90"  y="175" width="58" height="70"  rx="5"/>
      <rect class="frb-bar" x="188" y="150" width="58" height="95"  rx="5"/>
      <rect class="frb-bar" x="286" y="128" width="58" height="117" rx="5"/>
      <rect class="frb-bar" x="384" y="104" width="58" height="141" rx="5"/>
      <rect class="frb-bar" x="482" y="74"  width="58" height="171" rx="5"/>
      <rect class="frb-bar" x="580" y="52"  width="58" height="193" rx="5"/>
    </g>
    <text class="frb-lbl" x="105" y="268">Jan</text>
    <text class="frb-lbl" x="203" y="268">Feb</text>
    <text class="frb-lbl" x="301" y="268">Mar</text>
    <text class="frb-lbl" x="399" y="268">Apr</text>
    <text class="frb-lbl" x="497" y="268">May</text>
    <text class="frb-lbl" x="595" y="268">Jun</text>""",
)


# ── 2. Retention curve ─────────────────────────────────────────────────────
_RETENTION = _fig(
    "retention",
    "Audience retention curve falling steeply in the first thirty seconds",
    "Most channels lose a third of the audience before the 30-second mark. "
    "The shape of that first drop is the single most useful thing in your analytics.",
    f"""    <style>
      .frt-curve {{ fill: none; stroke: {_P['link']}; stroke-width: 3.5;
                   stroke-linecap: round; stroke-dasharray: 900; }}
      .frt-area  {{ fill: {_P['link']}; opacity: .10; }}
      .frt-grid  {{ stroke: {_P['border']}; stroke-width: 1; }}
      .frt-lbl   {{ fill: {_P['mute']}; font: 500 13px Roboto, system-ui, sans-serif; }}
      .frt-drop  {{ stroke: {_P['red']}; stroke-width: 2; stroke-dasharray: 5 5; }}
      .frt-dot   {{ fill: {_P['red']}; }}
      .frt-curve {{ stroke-dashoffset: 0; }}
      @media (prefers-reduced-motion: no-preference) {{
        .frt-curve {{ animation: frt-draw 3.2s ease-in-out infinite; }}
        .frt-dot   {{ animation: frt-pulse 3.2s ease-in-out infinite; }}
        @keyframes frt-draw {{
          0%   {{ stroke-dashoffset: 900; }}
          55%, 100% {{ stroke-dashoffset: 0; }}
        }}
        @keyframes frt-pulse {{
          0%, 30% {{ opacity: 0; r: 4; }}
          45%     {{ opacity: 1; r: 8; }}
          60%,100% {{ opacity: 1; r: 5.5; }}
        }}
      }}
    </style>
    <line class="frt-grid" x1="60" y1="250" x2="690" y2="250"/>
    <line class="frt-grid" x1="60" y1="60"  x2="690" y2="60"/>
    <path class="frt-area" d="M60 62 C 120 96, 150 168, 210 190 C 300 222, 420 232, 690 242 L690 250 L60 250 Z"/>
    <path class="frt-curve" d="M60 62 C 120 96, 150 168, 210 190 C 300 222, 420 232, 690 242"/>
    <line class="frt-drop" x1="210" y1="60" x2="210" y2="250"/>
    <circle class="frt-dot" cx="210" cy="190" r="5.5"/>
    <text class="frt-lbl" x="60"  y="272">0:00</text>
    <text class="frt-lbl" x="184" y="272">0:30</text>
    <text class="frt-lbl" x="640" y="272">End</text>
    <text class="frt-lbl" x="228" y="150">The cliff</text>""",
)


# ── 3. Funnel flow ─────────────────────────────────────────────────────────
_FUNNEL = _fig(
    "funnel",
    "Funnel narrowing from viewers to subscribers to customers",
    "Every stage loses people. That is normal — the job is knowing which stage "
    "leaks hardest before you spend money fixing the wrong one.",
    f"""    <style>
      .ffn-band {{ fill: {_P['link']}; }}
      .ffn-b1 {{ opacity: .95; }} .ffn-b2 {{ opacity: .75; }}
      .ffn-b3 {{ opacity: .55; }} .ffn-b4 {{ opacity: .38; }}
      .ffn-t  {{ fill: #fff; font: 700 14px Roboto, system-ui, sans-serif; }}
      .ffn-n  {{ fill: {_P['soft']}; font: 500 13px Roboto, system-ui, sans-serif; }}
      .ffn-dot {{ fill: {_P['red']}; opacity: 0; }}
      @media (prefers-reduced-motion: no-preference) {{
        .ffn-dot {{ animation: ffn-fall 3s linear infinite; }}
        .ffn-dot:nth-of-type(2) {{ animation-delay: 1s; }}
        .ffn-dot:nth-of-type(3) {{ animation-delay: 2s; }}
        @keyframes ffn-fall {{
          0%   {{ opacity: 0; transform: translateY(0); }}
          10%  {{ opacity: 1; }}
          85%  {{ opacity: 1; }}
          100% {{ opacity: 0; transform: translateY(196px); }}
        }}
      }}
    </style>
    <path class="ffn-band ffn-b1" d="M150 40  H570 L536 92  H184 Z"/>
    <path class="ffn-band ffn-b2" d="M188 100 H532 L498 152 H222 Z"/>
    <path class="ffn-band ffn-b3" d="M226 160 H494 L460 212 H260 Z"/>
    <path class="ffn-band ffn-b4" d="M264 220 H456 L422 272 H298 Z"/>
    <text class="ffn-t" x="322" y="72">Impressions</text>
    <text class="ffn-t" x="336" y="132">Viewers</text>
    <text class="ffn-t" x="326" y="192">Subscribers</text>
    <text class="ffn-t" x="332" y="252">Customers</text>
    <text class="ffn-n" x="592" y="72">100%</text>
    <text class="ffn-n" x="592" y="132">~6%</text>
    <text class="ffn-n" x="592" y="192">~1%</text>
    <text class="ffn-n" x="592" y="252">~0.1%</text>
    <g><circle class="ffn-dot" cx="360" cy="52" r="5"/>
       <circle class="ffn-dot" cx="344" cy="52" r="5"/>
       <circle class="ffn-dot" cx="376" cy="52" r="5"/></g>""",
)


# ── 4. Geographic reach ────────────────────────────────────────────────────
_GEO = _fig(
    "geo",
    "World map dots pulsing over North America, Europe and Australia",
    "Advertiser demand is not evenly spread. The same video earns very "
    "different money depending on where the watch time comes from.",
    f"""    <style>
      .fgo-ring {{ fill: none; stroke: {_P['red']}; stroke-width: 2; opacity: 0; }}
      .fgo-pin  {{ fill: {_P['red']}; }}
      .fgo-land {{ fill: {_P['border']}; }}
      .fgo-lbl  {{ fill: {_P['soft']}; font: 600 13px Roboto, system-ui, sans-serif; }}
      .fgo-cpm  {{ fill: {_P['text']}; font: 700 15px Roboto, system-ui, sans-serif; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fgo-ring {{ animation: fgo-ping 2.8s ease-out infinite; }}
        .fgo-r2 {{ animation-delay: .7s; }}
        .fgo-r3 {{ animation-delay: 1.4s; }}
        .fgo-r4 {{ animation-delay: 2.1s; }}
        @keyframes fgo-ping {{
          0%   {{ opacity: .9; transform: scale(.4); transform-origin: center; }}
          70%, 100% {{ opacity: 0; transform: scale(2.4); }}
        }}
      }}
      .fgo-g1 {{ transform-box: fill-box; transform-origin: center; }}
    </style>
    <ellipse class="fgo-land" cx="150" cy="120" rx="78" ry="52"/>
    <ellipse class="fgo-land" cx="360" cy="105" rx="58" ry="38"/>
    <ellipse class="fgo-land" cx="196" cy="222" rx="40" ry="30"/>
    <ellipse class="fgo-land" cx="588" cy="212" rx="52" ry="34"/>
    <g class="fgo-g1"><circle class="fgo-ring" cx="150" cy="120" r="14"/></g>
    <g class="fgo-g1"><circle class="fgo-ring fgo-r2" cx="360" cy="105" r="14"/></g>
    <g class="fgo-g1"><circle class="fgo-ring fgo-r3" cx="588" cy="212" r="14"/></g>
    <g class="fgo-g1"><circle class="fgo-ring fgo-r4" cx="196" cy="222" r="14"/></g>
    <circle class="fgo-pin" cx="150" cy="120" r="7"/>
    <circle class="fgo-pin" cx="360" cy="105" r="7"/>
    <circle class="fgo-pin" cx="588" cy="212" r="7"/>
    <circle class="fgo-pin" cx="196" cy="222" r="7"/>
    <text class="fgo-lbl" x="112" y="62">United States</text>
    <text class="fgo-cpm" x="126" y="44">high</text>
    <text class="fgo-lbl" x="332" y="52">Europe</text>
    <text class="fgo-lbl" x="548" y="164">Australia</text>
    <text class="fgo-lbl" x="158" y="278">Global avg</text>""",
)


# ── 5. Shield / compliance ─────────────────────────────────────────────────
_SHIELD = _fig(
    "shield",
    "Shield outline drawing itself with a checkmark forming inside",
    "Getting the paperwork right is unglamorous and permanent. It is far "
    "cheaper to set up correctly than to unwind later.",
    f"""    <style>
      .fsh-body  {{ fill: none; stroke: {_P['link']}; stroke-width: 5;
                   stroke-linejoin: round; stroke-dasharray: 620; }}
      .fsh-fill  {{ fill: {_P['link']}; opacity: .09; }}
      .fsh-check {{ fill: none; stroke: {_P['red']}; stroke-width: 7;
                   stroke-linecap: round; stroke-linejoin: round;
                   stroke-dasharray: 120; }}
      .fsh-lbl   {{ fill: {_P['soft']}; font: 600 14px Roboto, system-ui, sans-serif; }}
      .fsh-tick  {{ fill: {_P['link']}; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fsh-body  {{ animation: fsh-draw 4s ease-in-out infinite; }}
        .fsh-check {{ animation: fsh-tick 4s ease-in-out infinite; }}
        @keyframes fsh-draw {{
          0% {{ stroke-dashoffset: 620; }}
          40%, 100% {{ stroke-dashoffset: 0; }}
        }}
        @keyframes fsh-tick {{
          0%, 42% {{ stroke-dashoffset: 120; }}
          62%, 100% {{ stroke-dashoffset: 0; }}
        }}
      }}
    </style>
    <path class="fsh-fill" d="M232 46 L340 78 V166 c0 52-46 82-108 106 -62-24-108-54-108-106 V78 Z"/>
    <path class="fsh-body" d="M232 46 L340 78 V166 c0 52-46 82-108 106 -62-24-108-54-108-106 V78 Z"/>
    <path class="fsh-check" d="M186 158 l32 34 66-74"/>
    <circle class="fsh-tick" cx="432" cy="94"  r="5"/>
    <circle class="fsh-tick" cx="432" cy="146" r="5"/>
    <circle class="fsh-tick" cx="432" cy="198" r="5"/>
    <text class="fsh-lbl" x="452" y="99">Ownership recorded</text>
    <text class="fsh-lbl" x="452" y="151">Income declared</text>
    <text class="fsh-lbl" x="452" y="203">Licences documented</text>""",
)


# ── 6. Gear / tool stack ───────────────────────────────────────────────────
_GEAR = _fig(
    "gear",
    "Equipment blocks assembling into a creator workstation",
    "Spend in this order. Audio first, lighting second, camera last — that "
    "sequence buys more perceived quality per pound than any other.",
    f"""    <style>
      .fgr-box {{ fill: {_P['bgsoft']}; stroke: {_P['border']}; stroke-width: 2; }}
      .fgr-ic  {{ fill: {_P['link']}; }}
      .fgr-ic2 {{ fill: {_P['red']}; }}
      .fgr-t   {{ fill: {_P['text']}; font: 700 14px Roboto, system-ui, sans-serif; }}
      .fgr-s   {{ fill: {_P['mute']}; font: 500 12px Roboto, system-ui, sans-serif; }}
      .fgr-card {{ transform-box: fill-box; transform-origin: center; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fgr-card {{ animation: fgr-lift 3.6s ease-in-out infinite; }}
        .fgr-c2 {{ animation-delay: .35s; }}
        .fgr-c3 {{ animation-delay: .70s; }}
        @keyframes fgr-lift {{
          0%, 100% {{ transform: translateY(6px); opacity: .72; }}
          40%, 62% {{ transform: translateY(-6px); opacity: 1; }}
        }}
      }}
    </style>
    <g class="fgr-card">
      <rect class="fgr-box" x="52"  y="80" width="180" height="140" rx="14"/>
      <rect class="fgr-ic" x="126" y="112" width="32" height="52" rx="16"/>
      <rect class="fgr-ic" x="138" y="164" width="8"  height="18"/>
      <rect class="fgr-ic" x="118" y="182" width="48" height="7" rx="3.5"/>
      <text class="fgr-t" x="112" y="208">Audio</text>
    </g>
    <g class="fgr-card fgr-c2">
      <rect class="fgr-box" x="270" y="80" width="180" height="140" rx="14"/>
      <circle class="fgr-ic2" cx="360" cy="140" r="26"/>
      <g class="fgr-ic2">
        <rect x="356" y="98"  width="8" height="16" rx="4"/>
        <rect x="356" y="166" width="8" height="16" rx="4"/>
        <rect x="318" y="136" width="16" height="8" rx="4"/>
        <rect x="386" y="136" width="16" height="8" rx="4"/>
      </g>
      <text class="fgr-t" x="318" y="208">Lighting</text>
    </g>
    <g class="fgr-card fgr-c3">
      <rect class="fgr-box" x="488" y="80" width="180" height="140" rx="14"/>
      <rect class="fgr-ic" x="524" y="116" width="90" height="60" rx="10"/>
      <circle class="fgr-box" cx="569" cy="146" r="18"/>
      <text class="fgr-t" x="542" y="208">Camera</text>
    </g>
    <text class="fgr-s" x="52" y="252">Fix in this order — each step is cheaper than the next.</text>""",
)


# ── 7. Thumbnail A/B ───────────────────────────────────────────────────────
_THUMB_AB = _fig(
    "thumbab",
    "Two thumbnails side by side with click-through rate bars beneath",
    "Same video, two packages. Click-through rate is the only honest referee — "
    "test it rather than arguing about taste.",
    f"""    <style>
      .fta-fr  {{ fill: {_P['bgsoft']}; stroke: {_P['border']}; stroke-width: 2; }}
      .fta-a   {{ fill: {_P['mute']}; opacity: .5; }}
      .fta-b   {{ fill: {_P['red']}; }}
      .fta-bar {{ transform-origin: left center; }}
      .fta-t   {{ fill: {_P['text']}; font: 700 15px Roboto, system-ui, sans-serif; }}
      .fta-s   {{ fill: {_P['mute']}; font: 500 13px Roboto, system-ui, sans-serif; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fta-bar {{ animation: fta-w 3.4s cubic-bezier(.25,.8,.3,1) infinite; }}
        .fta-b2 {{ animation-delay: .4s; }}
        @keyframes fta-w {{
          0%, 100% {{ transform: scaleX(.08); }}
          45%, 72% {{ transform: scaleX(1); }}
        }}
      }}
    </style>
    <rect class="fta-fr" x="52"  y="40" width="280" height="150" rx="12"/>
    <rect class="fta-fr" x="388" y="40" width="280" height="150" rx="12"/>
    <circle class="fta-a" cx="140" cy="106" r="34"/>
    <rect class="fta-a" x="190" y="86"  width="112" height="14" rx="7"/>
    <rect class="fta-a" x="190" y="112" width="78"  height="14" rx="7"/>
    <circle class="fta-b" cx="476" cy="106" r="34" opacity=".85"/>
    <rect class="fta-b" x="526" y="80"  width="118" height="18" rx="9"/>
    <rect class="fta-b" x="526" y="108" width="86"  height="18" rx="9" opacity=".6"/>
    <text class="fta-t" x="52"  y="222">Version A</text>
    <text class="fta-t" x="388" y="222">Version B</text>
    <rect class="fta-a fta-bar"        x="52"  y="238" width="150" height="14" rx="7"/>
    <rect class="fta-b fta-bar fta-b2" x="388" y="238" width="252" height="14" rx="7"/>
    <text class="fta-s" x="212" y="250">3.1% CTR</text>
    <text class="fta-s" x="650" y="250">7.4%</text>""",
)


# ── 8. Content layers / repurposing ────────────────────────────────────────
_LAYERS = _fig(
    "layers",
    "One source video fanning out into shorts, article, newsletter and podcast",
    "One recording, five surfaces. Repurposing is the cheapest growth lever "
    "available to a solo creator because the expensive part is already done.",
    f"""    <style>
      .fly-src {{ fill: {_P['red']}; }}
      .fly-out {{ fill: {_P['bgsoft']}; stroke: {_P['border']}; stroke-width: 2; }}
      .fly-ln  {{ stroke: {_P['border']}; stroke-width: 2; stroke-dasharray: 4 5; }}
      .fly-t   {{ fill: {_P['text']}; font: 600 13px Roboto, system-ui, sans-serif; }}
      .fly-w   {{ fill: #fff; font: 700 15px Roboto, system-ui, sans-serif; }}
      .fly-card {{ transform-box: fill-box; transform-origin: center; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fly-card {{ animation: fly-in 4s ease-in-out infinite; }}
        .fly-k2 {{ animation-delay: .25s; }} .fly-k3 {{ animation-delay: .5s; }}
        .fly-k4 {{ animation-delay: .75s; }}
        @keyframes fly-in {{
          0%, 100% {{ transform: translateX(-22px) scale(.94); opacity: .45; }}
          45%, 70% {{ transform: translateX(0) scale(1); opacity: 1; }}
        }}
      }}
    </style>
    <rect class="fly-src" x="40" y="104" width="150" height="94" rx="12"/>
    <text class="fly-w" x="66" y="158">Source video</text>
    <path class="fly-ln" d="M196 122 H300 M196 140 H300 M196 162 H300 M196 180 H300"/>
    <g class="fly-card"><rect class="fly-out" x="306" y="34"  width="150" height="52" rx="10"/>
      <text class="fly-t" x="330" y="65">Shorts clips</text></g>
    <g class="fly-card fly-k2"><rect class="fly-out" x="306" y="98"  width="150" height="52" rx="10"/>
      <text class="fly-t" x="330" y="129">Blog article</text></g>
    <g class="fly-card fly-k3"><rect class="fly-out" x="306" y="162" width="150" height="52" rx="10"/>
      <text class="fly-t" x="330" y="193">Newsletter</text></g>
    <g class="fly-card fly-k4"><rect class="fly-out" x="306" y="226" width="150" height="52" rx="10"/>
      <text class="fly-t" x="330" y="257">Podcast cut</text></g>
    <path class="fly-ln" d="M462 60 H540 M462 124 H540 M462 188 H540 M462 252 H540"/>
    <text class="fly-t" x="552" y="160">One recording</text>""",
)


# ── 9. Community engagement ────────────────────────────────────────────────
_COMMUNITY = _fig(
    "community",
    "Comment bubbles appearing in sequence around a channel avatar",
    "Replies in the first hour do more for a video than anything you can do "
    "to the video itself after publishing.",
    f"""    <style>
      .fcm-b   {{ fill: {_P['bgsoft']}; stroke: {_P['border']}; stroke-width: 2; }}
      .fcm-l   {{ fill: {_P['mute']}; opacity: .55; }}
      .fcm-av  {{ fill: {_P['red']}; }}
      .fcm-t   {{ fill: {_P['soft']}; font: 600 13px Roboto, system-ui, sans-serif; }}
      .fcm-pop {{ transform-box: fill-box; transform-origin: center; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fcm-pop {{ animation: fcm-pop 3.6s ease-in-out infinite; }}
        .fcm-p2 {{ animation-delay: .5s; }} .fcm-p3 {{ animation-delay: 1s; }}
        .fcm-p4 {{ animation-delay: 1.5s; }}
        @keyframes fcm-pop {{
          0%, 100% {{ transform: scale(.86) translateY(8px); opacity: .35; }}
          35%, 68% {{ transform: scale(1) translateY(0);     opacity: 1; }}
        }}
      }}
    </style>
    <circle class="fcm-av" cx="112" cy="150" r="40"/>
    <circle class="fcm-b"  cx="112" cy="150" r="40" fill="none"/>
    <text class="fcm-t" x="72" y="216">Your channel</text>
    <g class="fcm-pop"><rect class="fcm-b" x="230" y="36"  width="230" height="56" rx="14"/>
      <rect class="fcm-l" x="250" y="54" width="150" height="9" rx="4.5"/>
      <rect class="fcm-l" x="250" y="70" width="104" height="9" rx="4.5"/></g>
    <g class="fcm-pop fcm-p2"><rect class="fcm-b" x="266" y="104" width="230" height="56" rx="14"/>
      <rect class="fcm-l" x="286" y="122" width="172" height="9" rx="4.5"/>
      <rect class="fcm-l" x="286" y="138" width="88"  height="9" rx="4.5"/></g>
    <g class="fcm-pop fcm-p3"><rect class="fcm-b" x="240" y="172" width="230" height="56" rx="14"/>
      <rect class="fcm-l" x="260" y="190" width="132" height="9" rx="4.5"/>
      <rect class="fcm-l" x="260" y="206" width="166" height="9" rx="4.5"/></g>
    <g class="fcm-pop fcm-p4"><rect class="fcm-b" x="500" y="72"  width="176" height="56" rx="14"/>
      <rect class="fcm-l" x="520" y="90"  width="118" height="9" rx="4.5"/>
      <rect class="fcm-l" x="520" y="106" width="76"  height="9" rx="4.5"/></g>
    <text class="fcm-t" x="500" y="216">Reply within the hour</text>""",
)


# ── 10. Growth steps ───────────────────────────────────────────────────────
_STEPS = _fig(
    "steps",
    "Ascending steps with a marker climbing from first video to sustainable channel",
    "Nothing here is a shortcut. Each step only works once the one below it is "
    "genuinely solid.",
    f"""    <style>
      .fst-s  {{ fill: {_P['link']}; }}
      .fst-s1 {{ opacity: .32; }} .fst-s2 {{ opacity: .5; }}
      .fst-s3 {{ opacity: .7; }}  .fst-s4 {{ opacity: .92; }}
      .fst-t  {{ fill: {_P['soft']}; font: 600 13px Roboto, system-ui, sans-serif; }}
      .fst-m  {{ fill: {_P['red']}; }}
      @media (prefers-reduced-motion: no-preference) {{
        .fst-m {{ animation: fst-climb 5s cubic-bezier(.5,0,.5,1) infinite; }}
        @keyframes fst-climb {{
          0%,  8%  {{ transform: translate(0, 0); }}
          25%, 33% {{ transform: translate(148px, -52px); }}
          50%, 58% {{ transform: translate(296px, -104px); }}
          75%, 83% {{ transform: translate(444px, -156px); }}
          100%     {{ transform: translate(0, 0); }}
        }}
      }}
    </style>
    <rect class="fst-s fst-s1" x="40"  y="212" width="132" height="60" rx="8"/>
    <rect class="fst-s fst-s2" x="188" y="160" width="132" height="112" rx="8"/>
    <rect class="fst-s fst-s3" x="336" y="108" width="132" height="164" rx="8"/>
    <rect class="fst-s fst-s4" x="484" y="56"  width="132" height="216" rx="8"/>
    <text class="fst-t" x="56"  y="290">Publish</text>
    <text class="fst-t" x="204" y="290">Find a niche</text>
    <text class="fst-t" x="352" y="290">Systemise</text>
    <text class="fst-t" x="500" y="290">Monetise</text>
    <circle class="fst-m" cx="106" cy="192" r="13"/>""",
)


FIGURES = {
    "revenue-bars": _REVENUE_BARS,
    "retention-curve": _RETENTION,
    "funnel": _FUNNEL,
    "geo-reach": _GEO,
    "shield": _SHIELD,
    "gear-stack": _GEAR,
    "thumbnail-ab": _THUMB_AB,
    "content-layers": _LAYERS,
    "community": _COMMUNITY,
    "growth-steps": _STEPS,
}


def render(fragment: str) -> str:
    """Swap every {{figure:name}} token for its SVG. Unknown names raise."""
    import re

    def sub(m):
        name = m.group(1).strip()
        if name not in FIGURES:
            raise KeyError(
                "Unknown figure %r. Available: %s"
                % (name, ", ".join(sorted(FIGURES)))
            )
        return FIGURES[name]

    return re.sub(r"\{\{\s*figure:([a-z0-9-]+)\s*\}\}", sub, fragment)
