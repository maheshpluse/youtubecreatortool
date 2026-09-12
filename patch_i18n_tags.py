import os, json

d = 'frontend/web/assets/i18n'
for f in os.listdir(d):
    if f.endswith('.json'):
        with open(os.path.join(d, f), 'r') as fp:
            data = json.load(fp)
        
        # Add new keys
        if f == 'si.json':
            data["seo_fb_tags_missing"] = "Fail: වීඩියෝවට අදාළ Tags කිසිවක් ඇතුළත් කර නොමැත."
            data["seo_fb_tags_pass"] = "Pass: වීඩියෝවට අදාළ Tags ඇතුළත් කර ඇත."
        else:
            data["seo_fb_tags_missing"] = "Fail: No tags have been provided."
            data["seo_fb_tags_pass"] = "Pass: Video tags have been provided."
            
        with open(os.path.join(d, f), 'w') as fp:
            json.dump(data, fp, ensure_ascii=False, indent=2)

print("Done patching i18n files for tags!")
