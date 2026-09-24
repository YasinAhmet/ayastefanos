"""Illustrate vault notes with images from Wikipedia / Wikimedia Commons.

Stages (each caches its result, so it can be re-run):
    py tools/wiki_images.py map        search EN + TR Wikipedia for every note  -> tools/wiki/map.json
    py tools/wiki_images.py fetch      collect images + captions from both pages -> tools/wiki/images.json
    py tools/wiki_images.py download   save images to Lore/Attachments/Images/
    py tools/wiki_images.py insert     add the images to the notes + write the credits page

Manual fixes to the article mapping go in tools/wiki/overrides.json:
    {"Note name": {"en": "English title" | null, "tr": "Türkçe başlık" | null}}
Images and captions come from the web, so notes mark them "⚠ Not from vault sources".
"""
import glob
import html
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.error
import urllib.request
from html.parser import HTMLParser

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LORE = os.path.join(ROOT, "Lore")
WIKI = os.path.join(HERE, "wiki")
IMGDIR = os.path.join(LORE, "Attachments", "Images")
UA = "AyastefanosLoreVault/1.0 (personal offline research notes; low-volume script using python-urllib)"
MAX_IMAGES = 6  # per note, lead image included


def api(lang, **params):
    params.update(format="json", formatversion="2")
    url = f"https://{lang}.wikipedia.org/w/api.php?" + urllib.parse.urlencode(params)
    for attempt in range(8):
        try:
            time.sleep(0.8)
            req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept-Encoding": "identity"})
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            wait = int(e.headers.get("Retry-After", "0") or 0) if e.code == 429 else 0
            time.sleep(max(wait, 5 * (attempt + 1)))
            err = e
        except Exception as e:  # noqa: BLE001
            time.sleep(3 + attempt * 3)
            err = e
    raise err


def notes():
    out = []
    for f in sorted(glob.glob(os.path.join(LORE, "*", "*", "*.md"))):
        rel = os.path.relpath(f, LORE)
        if rel.startswith(("Converted", "Sources", "Raw", "Attachments")):
            continue
        head = open(f, encoding="utf-8").read(1500)
        ty = re.search(r"^type:\s*(\S+)", head, re.M)
        out.append(dict(name=os.path.splitext(os.path.basename(f))[0], path=f, type=ty.group(1) if ty else ""))
    return out


def load(name, default):
    p = os.path.join(WIKI, name)
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else default


def save(name, data):
    os.makedirs(WIKI, exist_ok=True)
    json.dump(data, open(os.path.join(WIKI, name), "w", encoding="utf-8"), ensure_ascii=False, indent=1)


def search(lang, q):
    r = api(lang, action="query", list="search", srsearch=q, srlimit=1, srnamespace=0)
    hits = r.get("query", {}).get("search", [])
    return hits[0]["title"] if hits else None


def langlink(lang, title, to):
    r = api(lang, action="query", prop="langlinks", titles=title, lllang=to, redirects=1)
    pages = r.get("query", {}).get("pages", [])
    for p in pages:
        for ll in p.get("langlinks", []):
            return ll["title"]
    return None


def stage_map():
    m = load("map.json", {})
    for n in notes():
        if n["name"] in m:
            continue
        q = re.sub(r"\s*\(([^)]*\d[^)]*)\)", r" \1", n["name"])  # keep years as search terms
        q = q.replace(" and ", " ")
        en = search("en", q)
        tr = search("tr", q)
        en_from_tr = langlink("tr", tr, "en") if tr else None
        tr_from_en = langlink("en", en, "tr") if en else None
        m[n["name"]] = dict(type=n["type"], en=en, tr=tr, en_from_tr=en_from_tr, tr_from_en=tr_from_en,
                            agree=bool(en and tr and (en_from_tr == en or tr_from_en == tr)))
        print(f"{n['name']} | en={en} | tr={tr} | agree={m[n['name']]['agree']}", flush=True)
        save("map.json", m)
        time.sleep(0.2)


def _batch_titles(lang, titles, other):
    """Resolve titles (following redirects) and fetch their langlink into `other`."""
    out = {}
    for i in range(0, len(titles), 45):
        batch = titles[i:i + 45]
        r = api(lang, action="query", titles="|".join(batch), redirects=1, prop="langlinks", lllang=other, lllimit="max")
        q = r.get("query", {})
        norm = {x["from"]: x["to"] for x in q.get("normalized", [])}
        redir = {x["from"]: x["to"] for x in q.get("redirects", [])}
        pages = {p["title"]: p for p in q.get("pages", [])}
        for t in batch:
            final = redir.get(norm.get(t, t), norm.get(t, t))
            p = pages.get(final, {})
            if p.get("missing") or not p:
                out[t] = None
            else:
                ll = p.get("langlinks", [])
                out[t] = (final, ll[0]["title"] if ll else None)
    return out


def stage_titles():
    """Build map.json from the hand-made tools/wiki/titles.tsv (note<TAB>English title | tr:Türkçe | -)."""
    rows = [l.rstrip("\n").split("\t") for l in open(os.path.join(WIKI, "titles.tsv"), encoding="utf-8") if "\t" in l]
    given = {n: t for n, t in rows}
    missing_notes = [n["name"] for n in notes() if n["name"] not in given]
    en_titles = sorted({t for t in given.values() if t != "-" and not t.startswith("tr:")})
    tr_titles = sorted({t[3:] for t in given.values() if t.startswith("tr:")})
    en = _batch_titles("en", en_titles, "tr")
    tr = _batch_titles("tr", tr_titles, "en")
    m = {}
    for name, t in given.items():
        if t == "-":
            m[name] = dict(en=None, tr=None)
        elif t.startswith("tr:"):
            res = tr.get(t[3:])
            m[name] = dict(en=res[1] if res else None, tr=res[0] if res else None)
            if not res:
                print("  ! missing TR article:", name, "->", t[3:])
        else:
            res = en.get(t)
            m[name] = dict(en=res[0] if res else None, tr=res[1] if res else None)
            if not res:
                print("  ! missing EN article:", name, "->", t)
    save("map.json", m)
    print(len(m), "notes mapped;", sum(1 for v in m.values() if v["en"] or v["tr"]), "with an article")
    if missing_notes:
        print("notes not in titles.tsv:", missing_notes)


class _FigureParser(HTMLParser):
    """Collect content images (infobox + thumbnails) in page order with captions."""

    def __init__(self):
        super().__init__()
        self.items = []
        self.depth_skip = 0
        self.stack = []
        self.cur = None
        self.in_caption = False
        self.caption_depth = 0

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        cls = a.get("class", "") or ""
        self.stack.append((tag, cls))
        if tag in ("table", "div") and any(k in cls for k in ("navbox", "sidebar", "ambox", "metadata", "vertical-navbox", "sistersitebox")):
            self.depth_skip += 1
            self.stack[-1] = (tag, cls + " __skip")
        if self.depth_skip:
            return
        if tag == "img":
            src = a.get("src", "")
            file = a.get("resource", "") or ""
            w = int(a.get("width", "0") or 0)
            h = int(a.get("height", "0") or 0)
            if "/wikipedia/" in src and max(w, h) >= 90:
                m = re.search(r"/(?:commons|en|tr)/(?:thumb/)?[0-9a-f]/[0-9a-f]{2}/([^/]+)", src)
                if m:
                    fname = urllib.parse.unquote(m.group(1))
                    self.items.append({"file": fname, "caption": "", "infobox": any("infobox" in c for _, c in self.stack)})
                    self.cur = self.items[-1]
        if tag == "figcaption" or "infobox-caption" in cls:
            self.in_caption = True
            self.caption_depth = len(self.stack)

    def handle_endtag(self, tag):
        if self.stack:
            t, cls = self.stack.pop()
            if "__skip" in cls:
                self.depth_skip -= 1
            if self.in_caption and len(self.stack) < self.caption_depth:
                self.in_caption = False

    def handle_data(self, data):
        if self.in_caption and self.cur is not None and not self.depth_skip:
            self.cur["caption"] += data


BAD_FILE = re.compile(r"(^Flag_of|^Coat_of_arms_of_(?!the_Ottoman)|Commons-logo|Wiki|Ambox|Question_book|Edit-|Symbol_|OOjs|"
                      r"Padlock|Crystal_Clear|Nuvola|Folder_Hexagonal|Red_pog|Location_dot|Blue_pencil|Increase|Decrease|"
                      r"Steady|Portal|Speaker_Icon|Loudspeaker|Signature|Firma|Imza|İmza|Unterschrift)", re.I)


def page_images(lang, title):
    r = api(lang, action="parse", page=title, prop="text", redirects=1, disableeditsection=1)
    text = r.get("parse", {}).get("text", "")
    p = _FigureParser()
    p.feed(text)
    out, seen = [], set()
    for it in p.items:
        f = it["file"]
        if f in seen or BAD_FILE.search(f):
            continue
        seen.add(f)
        cap = re.sub(r"\s+", " ", html.unescape(it["caption"])).strip()
        out.append({"file": f, "caption": cap, "lang": lang, "infobox": it["infobox"]})
    return out


def rest_images(lang, title):
    """Images + captions via the REST media-list endpoint (lighter than action=parse)."""
    url = f"https://{lang}.wikipedia.org/api/rest_v1/page/media-list/" + urllib.parse.quote(title.replace(" ", "_"), safe="")
    for attempt in range(5):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=30) as r:
                data = json.load(r)
            break
        except Exception:  # noqa: BLE001
            time.sleep(3 + attempt * 4)
    else:
        return []
    out = []
    for it in data.get("items", []):
        if it.get("type") != "image" or not it.get("showInGallery", True):
            continue
        f = it["title"].split(":", 1)[1].replace(" ", "_")
        if BAD_FILE.search(f) or f.lower().endswith(".svg") and not it.get("leadImage"):
            continue
        out.append({"file": f, "caption": (it.get("caption") or {}).get("text", ""), "lang": lang,
                    "infobox": bool(it.get("leadImage"))})
    return out


def stage_fetch_rest():
    m = load("map.json", {})
    imgs = load("images.json", {})
    for name, e in m.items():
        if name in imgs:
            continue
        found = []
        for lang in ("en", "tr"):
            if e.get(lang):
                found += rest_images(lang, e[lang])
        seen, merged = set(), []
        for it in sorted(found, key=lambda x: (not x["infobox"])):
            if it["file"].lower() in seen:
                continue
            seen.add(it["file"].lower())
            merged.append(it)
        imgs[name] = dict(en=e.get("en"), tr=e.get("tr"), images=merged[:MAX_IMAGES])
        print(f"{name}: {len(imgs[name]['images'])} images", flush=True)
    save("images.json", imgs)


NOT_PORTRAIT = re.compile(r"(tughra|tuğra|tugra|seal|mühür|muhur|coat_of_arms|arms_of|armoiries|wappen|monogram|"
                          r"signature|imza|firma|autograph|flag|map|harita|grave|tomb|mezar|türbe|turbe|mausoleum|"
                          r"statue|heykel|anıt|monument|house|ev_|museum|müze|stamp|pul|coin|medal)", re.I)


def wikidata_images(titles_by_lang):
    """{(lang, title): [P18 file names]} via pageprops → Wikidata claims."""
    qids = {}
    for lang, titles in titles_by_lang.items():
        titles = sorted(set(titles))
        for i in range(0, len(titles), 45):
            r = api(lang, action="query", titles="|".join(titles[i:i + 45]), prop="pageprops", ppprop="wikibase_item", redirects=1)
            q = r.get("query", {})
            norm = {x["from"]: x["to"] for x in q.get("normalized", [])}
            redir = {x["from"]: x["to"] for x in q.get("redirects", [])}
            pages = {p["title"]: p for p in q.get("pages", [])}
            for t in titles[i:i + 45]:
                final = redir.get(norm.get(t, t), norm.get(t, t))
                qid = pages.get(final, {}).get("pageprops", {}).get("wikibase_item")
                if qid:
                    qids[(lang, t)] = qid
    out = {}
    ids = sorted(set(qids.values()))
    claims = {}
    for i in range(0, len(ids), 50):
        url = "https://www.wikidata.org/w/api.php?" + urllib.parse.urlencode(
            dict(action="wbgetentities", ids="|".join(ids[i:i + 50]), props="claims", format="json"))
        for attempt in range(8):
            try:
                time.sleep(1.0)
                req = urllib.request.Request(url, headers={"User-Agent": UA})
                with urllib.request.urlopen(req, timeout=30) as r:
                    data = json.load(r)
                break
            except urllib.error.HTTPError as e:
                wait = int(e.headers.get("Retry-After", "0") or 0) if e.code == 429 else 0
                print(f"  wikidata {e.code}, waiting {max(wait, 15)}s", flush=True)
                time.sleep(max(wait, 15))
        else:
            data = {}
        for qid, ent in data.get("entities", {}).items():
            vals = [c["mainsnak"].get("datavalue", {}).get("value") for c in ent.get("claims", {}).get("P18", [])]
            claims[qid] = [v.replace(" ", "_") for v in vals if v]
    for key, qid in qids.items():
        out[key] = claims.get(qid, [])
    return out


def stage_portraits():
    """People notes: keep only portraits (Wikidata P18 + each article's first infobox image)."""
    m = load("map.json", {})
    imgs = load("images.json", {})
    people = [n["name"] for n in notes() if n["type"] == "person"]
    by_lang = {"en": [], "tr": []}
    for name in people:
        e = m.get(name, {})
        for lang in ("en", "tr"):
            if e.get(lang):
                by_lang[lang].append(e[lang])
    p18 = wikidata_images(by_lang)
    changed = 0
    for name in people:
        e = m.get(name, {})
        old = imgs.get(name, {}).get("images", [])
        caps = {it["file"].lower(): it.get("caption", "") for it in old}
        picks = []
        for lang in ("en", "tr"):
            if e.get(lang):
                picks += p18.get((lang, e[lang]), [])
        for lang in ("en", "tr"):  # first infobox image of each article
            lead = next((it for it in old if it["lang"] == lang and it["infobox"]
                         and not NOT_PORTRAIT.search(it["file"]) and not it["file"].lower().endswith(".svg")), None)
            if lead:
                picks.append(lead["file"])
        seen, portraits = set(), []
        for f in picks:
            if f.lower() in seen or NOT_PORTRAIT.search(f) or f.lower().endswith(".svg"):
                continue
            seen.add(f.lower())
            portraits.append({"file": f, "caption": caps.get(f.lower(), ""), "lang": "wd", "infobox": True})
        imgs.setdefault(name, dict(en=e.get("en"), tr=e.get("tr")))["images"] = portraits[:3]
        changed += 1
    save("images.json", imgs)
    print(changed, "people notes now use portraits only;",
          sum(1 for n in people if imgs.get(n, {}).get("images")), "have at least one")


def prune_unused():
    """Delete downloaded images that no note uses any more."""
    used = set()
    for n in notes():
        used |= set(re.findall(r"!\[\[([^\]|]+)", open(n["path"], encoding="utf-8").read()))
    removed = 0
    for f in os.listdir(IMGDIR):
        if f not in used:
            os.remove(os.path.join(IMGDIR, f)); removed += 1
    print(removed, "unused image files removed")


def stage_fetch():
    m = load("map.json", {})
    ov = load("overrides.json", {})
    imgs = load("images.json", {})
    for name, e in m.items():
        if name in imgs:
            continue
        o = ov.get(name, {})
        en = o["en"] if "en" in o else e.get("en")
        tr = o["tr"] if "tr" in o else e.get("tr")
        found = []
        for lang, title in (("en", en), ("tr", tr)):
            if not title:
                continue
            try:
                found += page_images(lang, title)
            except Exception as ex:  # noqa: BLE001
                print("  !", name, lang, title, ex)
            time.sleep(0.2)
        # merge: lead (infobox) images first, then EN, then TR; drop duplicates
        seen, merged = set(), []
        for it in sorted(found, key=lambda x: (not x["infobox"])):
            key = it["file"].lower()
            if key in seen:
                continue
            seen.add(key)
            merged.append(it)
        imgs[name] = dict(en=en, tr=tr, images=merged[:MAX_IMAGES])
        print(f"{name}: {len(merged[:MAX_IMAGES])} images", flush=True)
        save("images.json", imgs)


def safe_name(s):
    s = re.sub(r'[\\/:*?"<>|#^\[\]]', "", s)
    return re.sub(r"\s+", " ", s).strip()


def stage_download():
    imgs = load("images.json", {})
    meta = load("files.json", {})
    os.makedirs(IMGDIR, exist_ok=True)
    allfiles = sorted({it["file"] for e in imgs.values() for it in e["images"]})
    todo = [f for f in allfiles if f not in meta]
    print(len(todo), "files to look up")
    for i in range(0, len(todo), 40):
        batch = todo[i:i + 40]
        r = api("en", action="query", prop="imageinfo", titles="|".join("File:" + f for f in batch),
                iiprop="url|extmetadata|size|mime", iiurlwidth=500, redirects=1)
        norm = {x["to"]: x["from"] for x in r.get("query", {}).get("normalized", [])}
        for p in r.get("query", {}).get("pages", []):
            title = p.get("title", "")
            orig = norm.get(title, title).replace("File:", "", 1)
            info = (p.get("imageinfo") or [{}])[0]
            em = info.get("extmetadata", {})
            def g(k):
                return re.sub(r"<[^>]+>", "", html.unescape(em.get(k, {}).get("value", ""))).strip()
            meta[orig.replace(" ", "_")] = dict(
                url=info.get("thumburl") or info.get("url"), page=info.get("descriptionurl"),
                mime=info.get("mime"), width=info.get("width"), license=g("LicenseShortName"),
                artist=g("Artist")[:200], credit=g("Credit")[:200], description=g("ImageDescription")[:300])
        save("files.json", meta)
        time.sleep(0.3)
    from concurrent.futures import ThreadPoolExecutor

    def fetch_one(f):
        info = meta.get(f) or meta.get(f.replace(" ", "_"))
        if not info or not info.get("url"):
            return
        local = local_name(f, info)
        info["local"] = local
        dst = os.path.join(IMGDIR, local)
        if os.path.exists(dst):
            return
        for attempt in range(6):
            try:
                time.sleep(0.6)
                req = urllib.request.Request(info["url"], headers={"User-Agent": UA})
                with urllib.request.urlopen(req, timeout=60) as r:
                    data = r.read()
                open(dst, "wb").write(data)
                return
            except urllib.error.HTTPError as e:
                wait = int(e.headers.get("Retry-After", "0") or 0) if e.code == 429 else 0
                print(f"  {e.code} on {f}, waiting {max(wait, 10)}s", flush=True)
                time.sleep(max(wait, 10))
            except Exception as e:  # noqa: BLE001
                time.sleep(5 + attempt * 5)
        print("  ! download failed", f, flush=True)

    with ThreadPoolExecutor(2) as ex:  # upload.wikimedia.org rate-limits per IP: stay gentle
        list(ex.map(fetch_one, allfiles))
    save("files.json", meta)
    print("downloaded; files in", IMGDIR)


def local_name(f, info):
    ext = os.path.splitext(urllib.parse.urlparse(info["url"]).path)[1].lower() or ".jpg"
    return safe_name(os.path.splitext(f.replace("_", " "))[0])[:120] + ext


def caption_text(it, info):
    cap = it.get("caption") or ""
    if not cap:  # no Wikipedia caption: use the file name (Commons descriptions can be in any language)
        cap = os.path.splitext(urllib.parse.unquote(it["file"]).replace("_", " "))[0]
    cap = re.sub(r"[\[\]|#^]", "", cap)
    return cap[:220]


def stage_insert():
    imgs = load("images.json", {})
    meta = load("files.json", {})
    by_name = {n["name"]: n for n in notes()}
    credits = {}
    for name, e in imgs.items():
        n = by_name.get(name)
        if not n:
            continue
        pics = []
        for it in e["images"]:
            info = meta.get(it["file"]) or meta.get(it["file"].replace(" ", "_"))
            if info and info.get("url"):
                info["local"] = local_name(it["file"], info)
            if info and info.get("local") and os.path.exists(os.path.join(IMGDIR, info["local"])):
                pics.append((it, info))
        text = open(n["path"], encoding="utf-8").read()
        text = re.sub(r"\n<!-- images:start -->.*?<!-- images:end -->\n", "\n", text, flags=re.S)
        text = re.sub(r"\n## Images\n.*?(?=\n## |\Z)", "\n", text, flags=re.S)
        if not pics:
            open(n["path"], "w", encoding="utf-8").write(text)
            continue
        lead, linfo = pics[0]
        src_links = " · ".join(f"[{l.upper()} Wikipedia](https://{l}.wikipedia.org/wiki/{urllib.parse.quote(t.replace(' ', '_'))})"
                              for l, t in (("en", e.get("en")), ("tr", e.get("tr"))) if t)
        lead_block = (f"\n<!-- images:start -->\n![[{linfo['local']}|320]]\n"
                      f"*{caption_text(lead, linfo) or name}* — ⚠ Not from vault sources (image: Wikimedia Commons)\n<!-- images:end -->\n")
        # lead image goes right after the info line under the title
        text = re.sub(r"(\n# [^\n]+\n\n>[^\n]*\n)", lambda mm: mm.group(1) + lead_block, text, count=1)
        gallery = ["", "## Images", "",
                   "> [!info] ⚠ Not from vault sources",
                   f"> Illustrations only, from Wikipedia and Wikimedia Commons ({src_links}). "
                   "Captions are Wikipedia's, not the books'. Credits: [[Image credits]].", ""]
        for it, info in pics:
            cap = caption_text(it, info)
            gallery.append(f"![[{info['local']}|480]]")
            gallery.append(f"*{cap}*" if cap else f"*{name}*")
            gallery.append("")
            credits[info["local"]] = (info, name)
        block = "\n".join(gallery)
        if "\n## Related" in text:
            text = text.replace("\n## Related", block + "\n## Related", 1)
        else:
            text = text.rstrip() + "\n" + block + "\n"
        open(n["path"], "w", encoding="utf-8").write(text)
    lines = ["---", "tags: [meta, credits]", "---", "# Image credits", "",
             "Every image in `Attachments/Images/` comes from Wikimedia Commons or Wikipedia. "
             "This page lists the source page, author and licence of each file, as those licences require. ",
             "Images are illustrations only and are ⚠ not from vault sources.", "",
             "| File | Used in | Author | Licence | Source |", "|---|---|---|---|---|"]
    for local, (info, name) in sorted(credits.items()):
        esc = lambda s: (s or "").replace("|", "/").replace("\n", " ")
        lines.append(f"| {esc(local)} | [[{name}]] | {esc(info.get('artist'))[:80]} | {esc(info.get('license'))} | [link]({info.get('page')}) |")
    open(os.path.join(LORE, "Attachments", "Image credits.md"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print(len(credits), "images placed")


if __name__ == "__main__":
    {"map": stage_map, "portraits": stage_portraits, "prune": prune_unused, "titles": stage_titles, "fetch-rest": stage_fetch_rest, "fetch": stage_fetch, "download": stage_download, "insert": stage_insert}[sys.argv[1]]()
