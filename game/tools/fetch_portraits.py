"""Download period portraits of the game's people from Wikimedia Commons into the vault.

    python3 game/tools/fetch_portraits.py

Each file is saved to Lore/Attachments/Images/ under its Commons name (Commons' standard 500 px
thumbnail) and gets a row in Lore/Attachments/Image credits.md (author, licence, link), like the images that
tools/wiki_images.py fetched. Files already present are skipped. The portraits are illustrations only:
⚠ Not from vault sources. The kişi blocks in GD 02 name them in `görsel:` / `görseller:`.
"""
import html
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
IMGDIR = os.path.join(ROOT, "Lore", "Attachments", "Images")
CREDITS = os.path.join(ROOT, "Lore", "Attachments", "Image credits.md")
UA = "AyastefanosLoreVault/1.0 (personal offline research notes; low-volume script using python-urllib)"

# vault note -> Commons files (period portraits, earliest first)
WANTED = {
    "Talat Paşa": ["Talat Pasha.jpg", "Idman19140528TalatBey.jpg"],
    "Mahmud Şevket Paşa": ["Mahmud Shevket Pasha.png"],
    "Midhat Paşa": ["Nadar - Portrait of Midhat Pasha.jpg"],
    "Mustafa Kemal Atatürk": ["Mustafa Kemal, Gelibolu, Çanakkale’de, 16 Temmuz 1915.png", "Mustafa Kemal, 1916.png"],
    "Enver Paşa": ["Enver beg, 1908.jpg"],
    "Cemal Paşa": ["Cemal Paşa (1915).jpg"],
    "Gazi Osman Paşa": ["Osman Pascha (Gazi Osman Paşa).jpg"],
    "Fahreddin Paşa": ["Ömer Fahreddin Paşa.jpg"],
    "GD 02 Sistemler": ["Bozcaadalı Hasan Hüsnü Paşa.jpg"],   # Hasan Hüsnü Paşa has no vault note
}


def api(**params):
    params.update(format="json", formatversion="2")
    url = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(params)
    for attempt in range(6):
        try:
            time.sleep(1.0)
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            return json.load(urllib.request.urlopen(req, timeout=40))
        except Exception as e:  # 429 / network: back off
            print("  retry", attempt + 1, e)
            time.sleep(4 * (attempt + 1))
    return {}


def plain(s):
    return html.unescape(re.sub(r"<[^>]+>", "", s or "")).strip().replace("|", "/").replace("\n", " ")


def main():
    credits = open(CREDITS, encoding="utf-8").read()
    rows = []
    for note, files in WANTED.items():
        for name in files:
            dest = os.path.join(IMGDIR, name)
            if os.path.exists(dest):
                print("have", name)
                continue
            d = api(action="query", titles="File:" + name, prop="imageinfo", iiprop="url|extmetadata", iiurlwidth=500)  # a standard thumbnail size (https://w.wiki/GHai)
            pages = d.get("query", {}).get("pages", [])
            if not pages or "imageinfo" not in pages[0]:
                print("MISSING on Commons:", name)
                continue
            info = pages[0]["imageinfo"][0]
            src = info.get("thumburl") or info["url"]
            data = download(src)
            if data is None:
                print("FAILED", name)
                continue
            open(dest, "wb").write(data)
            meta = info.get("extmetadata", {})
            author = plain(meta.get("Artist", {}).get("value")) or "unknown"
            licence = plain(meta.get("LicenseShortName", {}).get("value")) or "see source"
            link = info.get("descriptionurl", "https://commons.wikimedia.org/wiki/File:" + urllib.parse.quote(name))
            if f"| {name} |" not in credits:
                rows.append(name)
                with open(CREDITS, "a", encoding="utf-8") as f:
                    f.write(f"| {name} | [[{note}]] | {author} | {licence} | [link]({link}) |\n")
            print("saved", name, len(data) // 1024, "KB")
    print(len(rows), "credit rows added")


def download(url):
    for attempt in range(6):
        try:
            time.sleep(15.0)  # upload.wikimedia.org rate-limits bursts
            return urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=60).read()
        except Exception as e:
            print("  download retry", attempt + 1, e)
            time.sleep(30 * (attempt + 1))
    return None


if __name__ == "__main__":
    main()
