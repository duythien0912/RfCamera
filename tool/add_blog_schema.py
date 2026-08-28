import re

with open('landing/blog/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

schema_json_ld = """  <!-- Schema.org Blog/CollectionPage JSON-LD -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Blog",
    "name": "RfCamera Blog & Guides",
    "url": "https://rfcam.roycorp.xyz/blog/",
    "description": "50 in-depth photography guides, film recipes, camera emulations, and privacy-first engineering breakdowns.",
    "publisher": {
      "@type": "Organization",
      "name": "RfCamera",
      "url": "https://rfcam.roycorp.xyz"
    }
  }
  </script>
</head>"""

content = content.replace('</head>', schema_json_ld)

with open('landing/blog/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated landing/blog/index.html with Blog JSON-LD schema.")
