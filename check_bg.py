import sys
from PIL import Image

def check_bg(img_path):
    img = Image.open(img_path)
    img = img.convert("RGB")
    # check top left pixel
    pixel = img.getpixel((0,0))
    print(f"{img_path} top-left pixel: {pixel}")

check_bg(r"c:\FP_IMK\read_lexia\assets\images\benar.jpeg")
check_bg(r"c:\FP_IMK\read_lexia\assets\images\salah.jpeg")
