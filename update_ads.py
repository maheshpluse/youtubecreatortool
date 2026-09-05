import os, glob, re

blog_dir = 'frontend/web/blog'
files = glob.glob(os.path.join(blog_dir, '*.html'))
count = 0
for f in files:
    with open(f, 'r') as file:
        content = file.read()
    
    new_ins = 'style="display:block; text-align:center;" data-ad-layout="in-article" data-ad-format="fluid" data-ad-client="ca-pub-3988155577590737" data-ad-slot="6771159533"'
    
    new_content = re.sub(
        r'<ins class="adsbygoogle"[^>]+></ins>',
        f'<ins class="adsbygoogle" {new_ins}></ins>',
        content
    )
    
    if new_content != content:
        with open(f, 'w') as file:
            file.write(new_content)
        count += 1

print(f"Updated {count} files.")
