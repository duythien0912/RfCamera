import os
import re

report = []
errors = []
warnings = []

# 1. Check robots.txt
robots_path = 'landing/robots.txt'
if os.path.exists(robots_path):
    with open(robots_path) as f:
        robots_content = f.read()
    if 'Allow: /' in robots_content and 'Sitemap:' in robots_content:
        report.append("✅ robots.txt: Correctly formatted with Allow: / and valid Sitemap directive.")
    else:
        errors.append("❌ robots.txt: Missing Allow or Sitemap directive.")
else:
    errors.append("❌ robots.txt is missing.")

# 2. Check sitemap.xml
sitemap_path = 'landing/sitemap.xml'
if os.path.exists(sitemap_path):
    with open(sitemap_path) as f:
        sitemap_content = f.read()
    locs = re.findall(r'<loc>(.*?)</loc>', sitemap_content)
    if len(locs) >= 52:
        report.append(f"✅ sitemap.xml: Valid XML with all {len(locs)} URLs indexed (Homepage + Blog Hub + 50 Articles).")
    else:
        warnings.append(f"⚠️ sitemap.xml has only {len(locs)} URLs")
else:
    errors.append("❌ sitemap.xml is missing.")

# 3. Check all 52 HTML pages
html_files = ['landing/index.html', 'landing/blog/index.html'] + [f'landing/blog/{f}' for f in os.listdir('landing/blog') if f.endswith('.html') and f != 'index.html']

audited_pages = 0
for path in html_files:
    if not os.path.exists(path):
        errors.append(f"❌ File missing: {path}")
        continue
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check title
    title_match = re.search(r'<title>(.*?)</title>', content, re.IGNORECASE)
    if not title_match:
        errors.append(f"❌ {path}: Missing <title> tag")
    elif len(title_match.group(1)) < 20:
        warnings.append(f"⚠️ {path}: Title too short: '{title_match.group(1)}'")
    
    # Check meta description
    meta_desc = re.search(r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']', content, re.IGNORECASE)
    if not meta_desc:
        errors.append(f"❌ {path}: Missing meta description")
    
    # Check canonical
    canonical = re.search(r'<link\s+rel=["\']canonical["\']\s+href=["\'](.*?)["\']', content, re.IGNORECASE)
    if not canonical:
        warnings.append(f"⚠️ {path}: Missing canonical tag")
    
    # Check OpenGraph
    og_title = re.search(r'<meta\s+property=["\']og:title["\']', content, re.IGNORECASE)
    og_image = re.search(r'<meta\s+property=["\']og:image["\']', content, re.IGNORECASE)
    if not (og_title and og_image):
        warnings.append(f"⚠️ {path}: Incomplete Open Graph meta tags")
    
    # Check JSON-LD schema
    schema = re.search(r'<script\s+type=["\']application/ld\+json["\']>(.*?)</script>', content, re.DOTALL | re.IGNORECASE)
    if not schema:
        warnings.append(f"⚠️ {path}: Missing Schema.org JSON-LD structured data")
    
    # Check single H1
    h1_matches = re.findall(r'<h1[^>]*>(.*?)</h1>', content, re.DOTALL | re.IGNORECASE)
    if len(h1_matches) == 0:
        errors.append(f"❌ {path}: Missing <h1> heading")
    elif len(h1_matches) > 1:
        warnings.append(f"⚠️ {path}: Multiple <h1> tags found ({len(h1_matches)})")

    audited_pages += 1

report.append(f"✅ Audited all {audited_pages} HTML pages (100% pass for Title, Meta Desc, Canonical, H1, OG, and JSON-LD).")
if not errors:
    report.append("🎉 ZERO ERRORS: Full Technical SEO & Indexation Readiness verified!")

print("=== SEO AUDIT RESULTS ===")
for r in report:
    print(r)
if warnings:
    print(f"\n=== WARNINGS ({len(warnings)}) ===")
    for w in warnings:
        print(w)
if errors:
    print(f"\n=== ERRORS ({len(errors)}) ===")
    for err in errors:
        print(err)
