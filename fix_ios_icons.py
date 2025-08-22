#!/usr/bin/env python3
import os
from PIL import Image
import glob

def remove_alpha_channel(image_path):
    """Remove alpha channel from PNG image and replace with white background"""
    img = Image.open(image_path)
    
    if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
        # Create a white background
        background = Image.new('RGB', img.size, (255, 255, 255))
        
        # Paste the image on the white background
        if img.mode == 'P':
            img = img.convert('RGBA')
        background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
        
        # Save the image without alpha channel
        background.save(image_path, 'PNG', optimize=True)
        print(f"Fixed: {os.path.basename(image_path)}")
    else:
        print(f"Skipped (no alpha): {os.path.basename(image_path)}")

def main():
    icon_dir = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    icon_files = glob.glob(os.path.join(icon_dir, "Icon-App-*.png"))
    
    if not icon_files:
        print(f"No icon files found in {icon_dir}")
        return
    
    print(f"Found {len(icon_files)} icon files to process")
    
    for icon_file in icon_files:
        try:
            remove_alpha_channel(icon_file)
        except Exception as e:
            print(f"Error processing {icon_file}: {e}")
    
    print("\nDone! All icons have been processed.")

if __name__ == "__main__":
    main()