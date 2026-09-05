import os, glob

files_to_fix = glob.glob('frontend/web/blog/*.html') + ['frontend/web/index.html', 'frontend/blog_src/build_blog.py']

for f in files_to_fix:
    try:
        with open(f, 'r') as file:
            content = file.read()
        
        if '1234567890123456' in content:
            new_content = content.replace('1234567890123456', '3988155577590737')
            with open(f, 'w') as file:
                file.write(new_content)
            print(f"Fixed {f}")
    except Exception as e:
        pass
