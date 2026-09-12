import os, json

d = 'frontend/web/assets/i18n'
for f in os.listdir(d):
    if f.endswith('.json'):
        with open(os.path.join(d, f), 'r') as fp:
            data = json.load(fp)
        
        # Add new keys
        if f == 'si.json':
            data["seo_fb_title_desc_match_fail"] = "Fail: මාතෘකාව සහ විස්තරය (Title & Description) හරියටම සමානයි. විස්තරය වෙනස් විය යුතුයි."
            data["seo_fb_desc_length_pass"] = "Pass: විස්තරය (Description) ප්‍රමාණවත් තරම් දිගයි."
            data["seo_fb_desc_length_fail"] = "Fail: විස්තරය (Description) ඉතා කෙටියි. අවම වශයෙන් අකුරු 150ක් වත් තිබිය යුතුයි."
        else:
            data["seo_fb_title_desc_match_fail"] = "Fail: Title and Description are identical. Please write a detailed description."
            data["seo_fb_desc_length_pass"] = "Pass: Description is detailed and optimal."
            data["seo_fb_desc_length_fail"] = "Fail: Description is too short. It should be at least 150 characters."
            
        with open(os.path.join(d, f), 'w') as fp:
            json.dump(data, fp, ensure_ascii=False, indent=2)

print("Done patching i18n files!")
