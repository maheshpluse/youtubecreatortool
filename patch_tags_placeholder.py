import os, json

d = 'frontend/web/assets/i18n'
for f in os.listdir(d):
    if f.endswith('.json'):
        with open(os.path.join(d, f), 'r') as fp:
            data = json.load(fp)
        
        if f == 'si.json':
            data["seo_placeholder_tags"] = "Tags ඇතුළත් කරන්න (comma වලින් වෙන් කරන්න)"
        elif f == 'en.json':
            data["seo_placeholder_tags"] = "Enter tags (comma separated, e.g. tech, review, gadget)"
        else:
            data["seo_placeholder_tags"] = "Enter tags (comma separated)"
            
        with open(os.path.join(d, f), 'w') as fp:
            json.dump(data, fp, ensure_ascii=False, indent=2)

print("Done!")
