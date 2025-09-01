import os
import requests

GROUPS_URL = "https://naturblick.museumfuernaturkunde.berlin/django/groups/"

def download_file(url, filepath):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        with open(filepath, "wb") as f:
            f.write(response.content)
        print(f"ok: {filepath}")
    except Exception as e:
        print(f"error: Fehler beim Laden {url}: {e}")

def main():
    response = requests.get(GROUPS_URL)
    response.raise_for_status()
    data = response.json()

    asset_dir = os.path.join(os.path.dirname(__file__), "naturblick", "BuildtimeAssets")
    os.makedirs(asset_dir, exist_ok=True)

    for group in data:
        name = group.get("name").lower()
        image_url = group.get("image")
        svg_url = group.get("svg")

        if image_url:
            img_path = os.path.join(asset_dir, f"{name}.png")
            download_file(image_url, img_path)

        if svg_url:
            svg_path = os.path.join(asset_dir, f"{name}_icon.svg")
            download_file(svg_url, svg_path)

main()
