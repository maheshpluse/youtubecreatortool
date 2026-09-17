import re

with open('frontend/lib/app.dart', 'r') as f:
    content = f.read()

# Replace the existing JSON-LD scripts with the new @graph one
json_ld_start = content.find("head.add(_jsonLd({")
if json_ld_start != -1:
    json_ld_end = content.find("    if (kTwitterHandle.isNotEmpty) {", json_ld_start)
    
    new_json_ld = """
    // Add structured data @graph as recommended by SEO audit
    head.add(script(
      type: 'application/ld+json',
      [RawText(r'''
{"@context":"https://schema.org","@graph":[{"@type":"Organization","@id":"https://vidseokit.com/#organization","name":"VidSEOKit","url":"https://vidseokit.com/","logo":{"@type":"ImageObject","url":"https://vidseokit.com/images/og-image.jpg","width":1200,"height":630}},{"@type":"WebSite","@id":"https://vidseokit.com/#website","url":"https://vidseokit.com/","name":"VidSEOKit","publisher":{"@id":"https://vidseokit.com/#organization"},"inLanguage":"en"},{"@type":"WebApplication","@id":"https://vidseokit.com/#webapp","name":"VidSEOKit YouTube SEO Analyzer","url":"https://vidseokit.com/youtube-seo-analyzer","applicationCategory":"BusinessApplication","applicationSubCategory":"SEO Tool","operatingSystem":"Any (web browser)","browserRequirements":"Requires JavaScript","description":"Free tool that scores a YouTube video title, description and tags against a target keyword and lists the specific changes to make before publishing.","featureList":["Title keyword placement and length scoring","Description first-150-character analysis","Tag relevance scoring","Combined score out of 100"],"isAccessibleForFree":true,"publisher":{"@id":"https://vidseokit.com/#organization"},"offers":{"@type":"Offer","price":"0","priceCurrency":"USD"}},{"@type":"FAQPage","@id":"https://vidseokit.com/#faq","mainEntity":[{"@type":"Question","name":"What is a good YouTube SEO score?","acceptedAnswer":{"@type":"Answer","text":"Anything above 80 means your metadata is not holding the video back. Below 60 usually points to a missing keyword in the title or a description too short for YouTube to categorise confidently. The score measures metadata quality only, so a high score does not guarantee views."}},{"@type":"Question","name":"Should my target keyword go at the start of the title?","acceptedAnswer":{"@type":"Answer","text":"Where it fits naturally, yes. Front-loading the keyword helps on mobile, where titles are truncated after roughly 40 characters, and it matches how viewers scan a results page. Do not force it at the cost of a title that reads badly."}},{"@type":"Question","name":"How long should a YouTube description be?","acceptedAnswer":{"@type":"Answer","text":"Aim for 150 to 300 words. The first 150 characters appear before the more link and should contain your keyword and a reason to watch. The rest gives YouTube context, and is a reasonable place for timestamps, links and chapter markers."}},{"@type":"Question","name":"Does changing the title of an old video help?","acceptedAnswer":{"@type":"Answer","text":"It can, particularly if the video already gets impressions but a low click-through rate. Re-optimising the title and thumbnail on a video with existing watch history is often faster than publishing a new one. Change one variable at a time so you can tell what worked."}},{"@type":"Question","name":"How do I get more of my views from the US, UK and Europe?","acceptedAnswer":{"@type":"Answer","text":"Publish so the video lands in the morning in New York and London rather than overnight, since the first hours decide who the algorithm keeps showing it to. Reference the currencies, retailers and regulations those viewers recognise, and add English subtitles to widen reach into the Netherlands, the Nordics and Germany."}},{"@type":"Question","name":"Is this YouTube SEO analyzer free?","acceptedAnswer":{"@type":"Answer","text":"Yes. There is no account, no trial and no view limit. You can analyse as many videos as you like."}}]}]}
      ''')]
    ));
"""
    content = content[:json_ld_start] + new_json_ld + content[json_ld_end:]

with open('frontend/lib/app.dart', 'w') as f:
    f.write(content)

