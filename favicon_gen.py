from PIL import Image, ImageDraw

def create_favicon():
    # Create a 256x256 transparent image
    img = Image.new('RGBA', (256, 256), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Draw a solid red triangle pointing right
    d.polygon([(48, 32), (48, 224), (224, 128)], fill=(204, 0, 0, 255))
    
    img.save('frontend/web/favicon.ico', format='ICO', sizes=[(16,16), (32,32), (48,48), (64,64), (128,128), (256,256)])

create_favicon()
