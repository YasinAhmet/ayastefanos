"""Rebuild a converted book in Lore/Converted as clean, paragraph-based Markdown.

    py tools/convert_book.py <title-prefix> [<title-prefix> ...]
    py tools/convert_book.py --all

What it does for each book:
  * PDF books: re-extracts every page from the source PDF (Lore/Raw/...), rebuilds
    paragraphs from the layout, drops page numbers and running headers, puts
    footnotes in a callout, marks indented quotations as blockquotes, and adds
    chapter headings (from the PDF outline or from large headings at the top of
    a page). Pages OCR'd with tools/ocr_pages.py are taken from the OCR cache.
  * E-books / transcripts (loc. units): keeps the existing loc. chunks (their
    numbering is cited everywhere) and only tidies the text.
  * Fixes OCR slips with tools/ocr_fix.py and logs every change to
    Lore/Raw/OCR corrections/<title>.tsv.
  * Scores every page; hard-to-read pages are listed in
    Lore/Raw/OCR corrections/_page quality.tsv and get a warning callout.
Page headings (p. N / loc. N) never change, so every existing citation link
keeps working. The untouched original is in Lore/Raw/Converted (original)/.
"""
import glob
import json
import os
import re
import sys
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)

from build_lexicon import book_kind  # noqa: E402
from ocr_fix import Corrector, load_lexicon, TOKEN_RE, tr_lower, norm_apos  # noqa: E402
from pdf_extract import extract  # noqa: E402

LORE = os.path.join(ROOT, "Lore")
CONV = os.path.join(LORE, "Converted")
LOGDIR = os.path.join(LORE, "Raw", "OCR corrections")
OCR_CACHE = os.path.join(HERE, "ocr_cache")
PAGE_RE = re.compile(r"^#{2,3} ((?:p|loc)\. \d+)\s*$", re.M)
TODAY = "2026-09-24"

_C = None


def corrector():
    global _C
    if _C is None:
        _C = Corrector(*load_lexicon(os.path.join(HERE, "lexicon.json")))
    return _C


def split_book(text):
    """Return (header, [(label, body), ...]) for an existing converted book."""
    parts = PAGE_RE.split(text)
    header = parts[0]
    pages = [(parts[i], parts[i + 1]) for i in range(1, len(parts), 2)]
    # drop chapter headings / contents written by an earlier run
    header = re.sub(r"\n## Contents\n.*", "\n", header, flags=re.S)
    return header.rstrip() + "\n", pages


def clean_heading(t):
    t = re.sub(r"[#\[\]|^:]", " ", t)
    return re.sub(r"\s+", " ", t).strip(" .-–—")


def page_quality(text, C):
    toks = [m.group(0) for m in TOKEN_RE.finditer(text)]
    words = [t for t in toks if sum(ch.isalpha() for ch in t) >= 3]
    if len(words) < 15:
        return 0.0, len(words)
    bad = 0
    for w in words:
        low = norm_apos(tr_lower(w))
        if low in C.valid or C.counts.get(low, 0) >= 3 or low.split("'")[0] in C.valid:
            continue
        if w[:1].isupper() and w[1:].islower():
            continue  # probably a name
        bad += 1
    return bad / len(words), len(words)


def load_ocr(title):
    p = os.path.join(OCR_CACHE, title + ".jsonl")
    if not os.path.exists(p):
        return {}
    out = {}
    for line in open(p, encoding="utf-8"):
        try:
            r = json.loads(line)
            out[r["page"]] = r
        except ValueError:
            pass
    return out


def good_toc(toc, n_pages):
    toc = [(lvl, clean_heading(t), p) for lvl, t, p in toc if lvl <= 2 and 1 <= p <= n_pages]
    toc = [x for x in toc if x[1] and not re.search(r"sayfa|^page|^\d+$|^cilt\d", x[1], re.I)]
    if not toc or len(toc) > n_pages * 0.5:
        return {}
    by_page = {}
    for lvl, t, p in toc:
        by_page.setdefault(p, []).append(t)
    return by_page


def fix_numbers(t):
    t = re.sub(r"(?<=\d)[ıI](?=[\d'’.,:;)\s]|$)|(?<![\w])[ıI](?=\d)", "1", t)  # ı9ı6 -> 1916 (OCR read 1 as ı)
    t = re.sub(r"(?<![\d.,])(\d) (?=\d{3}(?!\d))", r"\1", t)          # 1 914 -> 1914
    t = re.sub(r"(?<![\d.,])(\d) (\d) ?\.(?=\s)", r"\1\2.", t)        # 3 1 . -> 31.
    return t


def render_blocks(blocks):
    out, notes = [], []
    for k, t in blocks:
        if not t:
            continue
        if k == "fn":
            notes.append(t)
        elif k in ("h", "b"):
            out.append(f"**{t}**")
        elif k == "q":
            out.append("> " + t)
        else:
            out.append(t)
    body = "\n\n".join(out)
    if notes:
        body += "\n\n> [!note]+ Footnotes\n" + "\n>\n".join("> " + n for n in notes)
    return body


def update_header(header, note):
    header = re.sub(r"\n> \*\*This text was produced by OCR\*\*[^\n]*\n", "\n", header)
    header = re.sub(r"\n> \[!info\] Cleanup\n(?:>[^\n]*\n)*", "\n", header)
    return header.rstrip() + "\n\n> [!info] Cleanup\n" + "".join("> " + l + "\n" for l in note) + "\n"


def convert_pdf(path_md, header, pages_old, src, mode, title, qrows):
    C = corrector()
    ocr = load_ocr(title)
    blocks_by_page, toc = extract(src, ocr)
    n = len(blocks_by_page)
    chapters = good_toc(toc, n)
    if not chapters:
        cand = {}
        C = corrector()
        for i, blocks in enumerate(blocks_by_page, 1):
            if i <= 4 or not blocks or blocks[0][0] != "h":
                continue  # cover / title pages
            t = clean_heading(C.fix_text(blocks[0][1], mode) if mode != "none" else blocks[0][1])
            letters = sum(ch.isalpha() or ch == " " for ch in t)
            words = [w for w in re.findall(r"\w+", t) if len(w) > 2]
            known = [w for w in words if norm_apos(tr_lower(w)) in C.valid or C.counts.get(norm_apos(tr_lower(w)), 0) >= 3]
            if 3 <= len(t) <= 80 and letters >= 0.85 * len(t) and words and len(known) >= 0.6 * len(words):
                cand[i] = [t]
        if len(cand) <= max(3, n // 4):
            chapters = cand
            for i in cand:
                blocks_by_page[i - 1] = blocks_by_page[i - 1][1:]
    lvl = "###" if chapters else "##"
    out_pages, contents = [], []
    for i, blocks in enumerate(blocks_by_page, 1):
        if i in ocr and mode != "none":
            blocks = [(k, fix_numbers(C.fix_ocr_text(t))) for k, t in blocks]
        else:
            blocks = [(k, fix_numbers(C.fix_text(t, mode) if mode != "none" else t)) for k, t in blocks]
        body = render_blocks(blocks)
        q, nw = page_quality(body, C) if mode != "none" else (0.0, 0)
        if q > 0.25:
            qrows.append((title, f"p. {i}", f"{q:.2f}", nw, "ocr" if i in ocr else "text"))
        if q > 0.35:
            body = "> [!warning] Parts of this page are hard to read in the source; check the PDF before quoting.\n\n" + body
        sec = ""
        for t in chapters.get(i, []):
            sec += f"## {t}\n\n"
            contents.append(t)
        sec += f"{lvl} p. {i}\n\n" + (body if body.strip() else "*[no text on this page]*") + "\n"
        out_pages.append(sec)
    return out_pages, contents, len(ocr)


def tidy_loc_text(body, mode):
    C = corrector()
    body = re.sub("­\\s*", "", body)
    paras = [re.sub(r"[ \t]+", " ", p).strip() for p in re.split(r"\n\s*\n", body.strip())]
    paras = [re.sub(r"\s*\n\s*", " ", p) if not p.startswith((">", "- ", "* ", "|")) else p for p in paras]
    if mode != "none":
        paras = [C.fix_text(p, mode) for p in paras]
    return "\n\n".join(p for p in paras if p)


def convert(path_md, qrows):
    text = open(path_md, encoding="utf-8").read()
    title = os.path.splitext(os.path.basename(path_md))[0]
    header, pages_old = split_book(text)
    src = re.search(r'^source_file:\s*"?(.*?)"?$', header, re.M).group(1)
    ext = src.rsplit(".", 1)[-1].lower()
    m = re.search(r"^text_mode:\s*(\w+)", header, re.M)
    kind = m.group(1) if m else book_kind(text)
    if not m:
        header = re.sub(r"^(tags:.*)$", lambda mm: f"text_mode: {kind}\n" + mm.group(1), header, count=1, flags=re.M)
    C = corrector()
    C.log = Counter()
    if ext == "pdf":
        mode = {"turkish": "light", "ascii": "ascii", "english": "none"}[kind]
        out_pages, contents, n_ocr = convert_pdf(path_md, header, pages_old, os.path.join(LORE, src), mode, title, qrows)
        note = [f"Rebuilt on {TODAY} from the source PDF: paragraphs restored, page numbers and running headers removed, footnotes grouped under each page."]
        if n_ocr:
            note.append(f"{n_ocr} page(s) were re-read with RapidOCR (PP-OCRv5 Latin model), which reads Turkish letters.")
        if mode != "none":
            note.append("OCR slips were machine-corrected; every change is listed in `Raw/OCR corrections/" + title + ".tsv`. Check the PDF before quoting word for word.")
    elif ext in ("epub", "mobi", "txt"):
        ocr_ebook = 'OCR" hatası' in text[:8000]
        mode = "light" if ocr_ebook else "none"
        out_pages, contents = [], []
        for label, body in pages_old:
            b = tidy_loc_text(body, mode)
            out_pages.append(f"## {label}\n\n" + (b if b else "*[no text in this part]*") + "\n")
        note = [f"Tidied on {TODAY}: paragraphs normalised" + (", OCR slips machine-corrected (see `Raw/OCR corrections/" + title + ".tsv`)." if mode != "none" else ".")]
    else:
        print(f"skip {title}: {ext} source")
        return
    header = update_header(header, note)
    if contents:
        header += "## Contents\n\n" + "\n".join(f"- [[#{t}]]" for t in dict.fromkeys(contents)) + "\n\n"
    open(path_md, "w", encoding="utf-8").write(header + "\n".join(out_pages))
    os.makedirs(LOGDIR, exist_ok=True)
    if C.log:
        with open(os.path.join(LOGDIR, title + ".tsv"), "w", encoding="utf-8") as fh:
            fh.write("original\tcorrected\tcount\n")
            for (a, b), c in sorted(C.log.items(), key=lambda x: -x[1]):
                fh.write(f"{a}\t{b}\t{c}\n")
    print(f"{title}: {len(out_pages)} sections, {len(contents)} chapters, {sum(C.log.values())} corrections", flush=True)


def main():
    args = sys.argv[1:]
    files = sorted(glob.glob(os.path.join(CONV, "*.md"))) if args == ["--all"] else \
        [f for a in args for f in glob.glob(os.path.join(CONV, a + "*.md"))]
    qrows = []
    for f in files:
        try:
            convert(f, qrows)
        except Exception as e:  # keep going; report at the end
            print(f"ERROR {os.path.basename(f)}: {e!r}", flush=True)
    qpath = os.path.join(LOGDIR, "_page quality.tsv")
    old = []
    if os.path.exists(qpath):
        titles = {os.path.splitext(os.path.basename(f))[0] for f in files}
        old = [l.rstrip("\n").split("\t") for l in open(qpath, encoding="utf-8")][1:]
        old = [r for r in old if r[0] not in titles]
    with open(qpath, "w", encoding="utf-8") as fh:
        fh.write("book\tpage\tunknown_ratio\twords\tsource\n")
        for r in old + [list(map(str, r)) for r in qrows]:
            fh.write("\t".join(r) + "\n")


if __name__ == "__main__":
    main()
