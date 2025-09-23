import os
import requests
import cairosvg

GROUPS_URL = "https://naturblick.museumfuernaturkunde.berlin/django/groups/"

def download_file(url, filepath):
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        with open(filepath, "wb") as f:
            f.write(response.content)
    except Exception as e:
        print(f"error: Fehler beim Laden {url}: {e}")

def main():
    response = requests.get(GROUPS_URL)
    response.raise_for_status()
    data = response.json()

    downloaded_dir = os.path.join(os.path.dirname(__file__), "resources", "downloaded")

    for group in data:
        name = group.get("name").lower()
        image_url = group.get("image")
        svg_url = group.get("svg")

        if image_url:
            img_path = os.path.join(downloaded_dir, f"group_{name}.png")
            download_file(image_url, img_path)

        if svg_url:
            pdf_path = os.path.join(downloaded_dir, f"map_{name}.pdf")
            # download_file(svg_url, svg_path)
            cairosvg.svg2pdf(url=svg_url, write_to=pdf_path)

main()
