#!/usr/bin/env python3
"""
rebuild_hub_and_sitemap.py
Scans all article HTML files in landing/blog/, extracts metadata, and regenerates:
- landing/blog/index.html (with category filter pills and responsive card grid)
- landing/sitemap.xml (with all 81+ article URLs)
"""

import os
import glob
import re

def extract_meta(path):
    txt = open(path, encoding='utf-8').read()
    slug = os.path.basename(path).replace('.html', '')
    
    # Title
    title_m = re.search(r'<title>(.*?)(?: - RfCamera Guides)?</title>', txt, re.S)
    title = title_m.group(1).strip() if title_m else slug
    
    # Description
    desc_m = re.search(r'<meta name="description" content="(.*?)"', txt, re.S)
    desc = desc_m.group(1).strip() if desc_m else ""
    
    # Category
    cat_m = re.search(r'<span class="cat-badge mono">(.*?)</span>', txt, re.S)
    cat = cat_m.group(1).strip() if cat_m else "Analog Guides"
    
    # Hero Image
    hero_m = re.search(r'<div class="hero-img-box">\s*<img src="(.*?)"', txt, re.S)
    hero = hero_m.group(1).strip() if hero_m else "../assets/og_image.png"
    
    # Date
    date_m = re.search(r'<span class="mono">(.*?2026)</span>', txt, re.S)
    date = date_m.group(1).strip() if date_m else "August 28, 2026"
    
    # Read time
    read_m = re.search(r'<span class="mono">(\d+\s*(?:min read|phút đọc))</span>', txt, re.S)
    read_time = read_m.group(1).strip() if read_m else "5 min read"
    
    return {
        "slug": slug,
        "title": title,
        "desc": desc,
        "category": cat,
        "hero": hero,
        "date": date,
        "read_time": read_time,
        "path": path
    }

def main():
    files = sorted(glob.glob('landing/blog/*.html'))
    files = [f for f in files if not f.endswith('index.html')]
    
    articles = [extract_meta(f) for f in files]
    print(f"Loaded {len(articles)} articles from landing/blog/")
    
    # Unique categories
    categories = sorted(list(set(a['category'] for a in articles)))
    
    # Category pills
    pills_html = '<button class="cat-pill active" onclick="filterCategory(\'all\')">All Guides (' + str(len(articles)) + ')</button>\n'
    for c in categories:
        count = sum(1 for a in articles if a['category'] == c)
        pills_html += f'        <button class="cat-pill" onclick="filterCategory(\'{c}\')">{c} ({count})</button>\n'
        
    # Cards HTML
    cards_html = ""
    for a in articles:
        cards_html += f"""      <a href="/blog/{a['slug']}.html" class="hub-card" data-category="{a['category']}">
        <div class="hub-card-img">
          <img src="{a['hero']}" alt="{a['title']}" loading="lazy" />
          <span class="hub-card-cat">{a['category']}</span>
        </div>
        <div class="hub-card-body">
          <h2 class="hub-card-title">{a['title']}</h2>
          <p class="hub-card-desc">{a['desc']}</p>
          <div class="hub-card-footer mono">{a['date']} • {a['read_time']}</div>
        </div>
      </a>\n"""

    index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>RfCamera Guides & Stories — 35mm Rangefinder & Analog Film Craft</title>
  <meta name="description" content="Master analog film photography: rangefinder optics, 35mm recipes, shutter acoustics, and zero-permission offline camera architecture." />
  <link rel="canonical" href="https://rfcam.roycorp.xyz/blog/" />
  
  <meta property="og:type" content="website" />
  <meta property="og:url" content="https://rfcam.roycorp.xyz/blog/" />
  <meta property="og:title" content="RfCamera Guides & Stories — Analog Photography & Optics" />
  <meta property="og:description" content="Detailed guides on classic film stocks, optical physics, camera emulations, and 100% offline privacy." />
  <meta property="og:image" content="https://rfcam.roycorp.xyz/assets/og_image.png" />

  <style>
    :root {{
      --bg: #0A0A0D;
      --surface: #121217;
      --surface-card: #181820;
      --surface-hover: #22222D;
      --border: #262633;
      --text: #F0F0F5;
      --text-muted: #8E8EA0;
      --accent: #E05A47;
      --orange: #FF7A2F;
      --font-mono: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, Consolas, monospace;
      --font-sans: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      background: var(--bg);
      color: var(--text);
      font-family: var(--font-sans);
      line-height: 1.6;
      -webkit-font-smoothing: antialiased;
      padding: 0 20px 80px;
    }}
    .hub-wrap {{
      max-width: 1200px;
      margin: 0 auto;
      padding-top: 50px;
    }}
    .back-home {{
      display: inline-flex;
      align-items: center;
      gap: 6px;
      color: var(--text-muted);
      text-decoration: none;
      font-size: 13.5px;
      font-weight: 500;
      margin-bottom: 24px;
      transition: color 0.15s ease;
    }}
    .back-home:hover {{ color: var(--text); }}
    .hub-header {{
      margin-bottom: 40px;
    }}
    .hub-header h1 {{
      font-size: clamp(32px, 5vw, 44px);
      font-weight: 900;
      letter-spacing: -0.03em;
      margin-bottom: 12px;
      color: #FFFFFF;
    }}
    .hub-header h1 span {{
      color: var(--orange);
    }}
    .hub-sub {{
      font-size: 16px;
      color: var(--text-muted);
      max-width: 640px;
      margin-bottom: 28px;
    }}
    .category-pills-row {{
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
      margin-top: 20px;
    }}
    .cat-pill {{
      background: var(--surface);
      border: 1px solid var(--border);
      color: var(--text-muted);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
    }}
    .cat-pill:hover {{
      border-color: rgba(255, 255, 255, 0.3);
      color: var(--text);
    }}
    .cat-pill.active {{
      background: var(--orange);
      border-color: var(--orange);
      color: #000;
      font-weight: 800;
    }}
    .hub-grid {{
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
      gap: 24px;
      margin-top: 36px;
    }}
    .hub-card {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 16px;
      overflow: hidden;
      display: flex;
      flex-direction: column;
      text-decoration: none;
      transition: transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), border-color 0.2s ease;
    }}
    .hub-card:hover {{
      transform: translateY(-4px);
      border-color: rgba(255, 255, 255, 0.3);
      background: var(--surface-hover);
    }}
    .hub-card-img {{
      position: relative;
      width: 100%;
      height: 200px;
      background: #08080A;
      overflow: hidden;
    }}
    .hub-card-img img {{
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      transition: transform 0.3s ease;
    }}
    .hub-card:hover .hub-card-img img {{
      transform: scale(1.04);
    }}
    .hub-card-cat {{
      position: absolute;
      top: 12px;
      left: 12px;
      background: rgba(0, 0, 0, 0.75);
      backdrop-filter: blur(8px);
      color: var(--orange);
      border: 1px solid rgba(255, 122, 47, 0.3);
      font-size: 10.5px;
      font-weight: 800;
      padding: 3px 8px;
      border-radius: 6px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }}
    .hub-card-body {{
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 8px;
      flex: 1;
      justify-content: space-between;
    }}
    .hub-card-title {{
      font-size: 17px;
      font-weight: 800;
      line-height: 1.35;
      color: #FFFFFF;
    }}
    .hub-card-desc {{
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.5;
    }}
    .hub-card-footer {{
      font-size: 11.5px;
      color: #777785;
      padding-top: 12px;
      border-top: 1px solid rgba(255, 255, 255, 0.06);
      margin-top: auto;
    }}
    .mono {{ font-family: var(--font-mono); }}
  </style>
</head>
<body>
  <div class="hub-wrap">
    <div class="hub-header">
      <a href="/" class="back-home">← RfCamera Home</a>
      <h1>RfCamera <span>Guides & Stories</span></h1>
      <p class="hub-sub">Comprehensive guides on 35mm rangefinders, analog film recipes, optical physics, and privacy-first camera architecture.</p>
      
      <div class="category-pills-row">
{pills_html}      </div>
    </div>

    <div class="hub-grid" id="hub-grid">
{cards_html}    </div>
  </div>

  <script>
    function filterCategory(cat) {{
      document.querySelectorAll('.cat-pill').forEach(p => p.classList.remove('active'));
      event.target.classList.add('active');

      const cards = document.querySelectorAll('.hub-card');
      cards.forEach(c => {{
        const cardCat = c.getAttribute('data-category');
        if (cat === 'all' || cardCat === cat) {{
          c.style.display = 'flex';
        }} else {{
          c.style.display = 'none';
        }}
      }});
    }}
  </script>
</body>
</html>
"""

    with open('landing/blog/index.html', 'w', encoding='utf-8') as f:
        f.write(index_html)
    print("Rebuilt landing/blog/index.html")

    # Generate Sitemap
    sitemap_urls = [
        "https://rfcam.roycorp.xyz/",
        "https://rfcam.roycorp.xyz/privacy.html",
        "https://rfcam.roycorp.xyz/blog/"
    ] + [f"https://rfcam.roycorp.xyz/blog/{a['slug']}.html" for a in articles]

    sitemap_xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    for u in sitemap_urls:
        sitemap_xml += f'  <url>\n    <loc>{u}</loc>\n    <lastmod>2026-08-28</lastmod>\n    <changefreq>weekly</changefreq>\n    <priority>0.8</priority>\n  </url>\n'
    sitemap_xml += '</urlset>'

    with open('landing/sitemap.xml', 'w', encoding='utf-8') as f:
        f.write(sitemap_xml)
    print(f"Rebuilt landing/sitemap.xml with {len(sitemap_urls)} URLs")

if __name__ == '__main__':
    main()
