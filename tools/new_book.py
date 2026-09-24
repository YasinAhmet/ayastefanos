"""Add a new source to the vault.

    py tools/new_book.py --file "Raw/NormalTrust/<file>.pdf" --title "Kitap Adı" --author "Yazar Adı"
        --side Turkish --protocol historical --written "1920" --covers "1908 – 1918"

Creates:
  Lore/Converted/<Title> (<Author>).md   the text, one heading per page (p. N) or chunk (loc. N)
  Lore/Sources/Source - <Title>.md       the source note (fill in "Notes that use this source" later)
PDF: text is taken from the PDF text layer. If the PDF is a scan without text, or
its OCR has no Turkish letters, the script says so: run
    py tools/ocr_pages.py "<Title>"        (GPU OCR, reads Turkish letters)
    py tools/convert_book.py "<Title>"     (rebuild the book from the OCR)
EPUB / MOBI / FB2 / TXT: text is split into loc. chunks of about 3,000 characters
at paragraph breaks (e-books have no page numbers).
DjVu is not supported offline: convert it to PDF first.
"""
import argparse
import os
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LORE = os.path.join(ROOT, "Lore")
sys.path.insert(0, HERE)

CHUNK = 3000


def front_matter(a, unit):
    written = f'written: "{a.written}"\n' if a.written else ""
    covers = f'covers: "{a.covers}"\n' if a.covers else ""
    head = (f'---\ntitle: "{a.title}"\nauthor: "{a.author}"\nside: {a.side}\nprotocol: {a.protocol}\n'
            f'{written}{covers}source_file: "{a.file}"\nlocation_unit: "{unit}"\ntags: [converted-book]\n---\n\n'
            f"# {a.title}\n\n**Author:** {a.author} · **Side:** {a.side} · **Protocol:** {a.protocol}"
            + (f" · **Written:** {a.written}" if a.written else "") + (f" · **Covers:** {a.covers}" if a.covers else "") + "\n\n")
    if unit == "p.":
        head += "> Page numbers (`p. N`) are the page index of the PDF file, not the printed page number.\n"
    else:
        head += "> This is an e-book or transcript with no page numbers. `loc. N` is a chunk of about 3,000 characters.\n"
    return head


def ebook_chunks(path):
    import pymupdf
    doc = pymupdf.open(path)
    paras = []
    for page in doc:
        for b in page.get_text("blocks"):
            t = re.sub(r"\s+", " ", b[4]).strip()
            if t:
                paras.append(t)
    chunks, cur = [], []
    size = 0
    for p in paras:
        cur.append(p); size += len(p)
        if size >= CHUNK:
            chunks.append(cur); cur = []; size = 0
    if cur:
        chunks.append(cur)
    return chunks


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True, help="path relative to Lore/, e.g. Raw/NormalTrust/x.pdf")
    ap.add_argument("--title", required=True)
    ap.add_argument("--author", required=True)
    ap.add_argument("--side", required=True, help="author's country, e.g. Turkish, German, British")
    ap.add_argument("--protocol", default="historical", choices=["historical", "fictional"])
    ap.add_argument("--written", default="")
    ap.add_argument("--covers", default="")
    a = ap.parse_args()
    src = os.path.join(LORE, a.file)
    if not os.path.exists(src):
        sys.exit(f"not found: {src}")
    ext = a.file.rsplit(".", 1)[-1].lower()
    name = f"{a.title} ({a.author})"
    out = os.path.join(LORE, "Converted", name + ".md")
    if os.path.exists(out):
        sys.exit(f"already exists: {out}")
    if ext == "djvu":
        sys.exit("DjVu cannot be read offline here; convert it to PDF first.")
    if ext == "pdf":
        import pymupdf
        doc = pymupdf.open(src)
        text = "".join(p.get_text() for p in doc)
        body = "\n".join(f"## p. {i}\n\n*[not converted yet]*\n" for i in range(1, doc.page_count + 1))
        open(out, "w", encoding="utf-8").write(front_matter(a, "p.") + "\n" + body)
        letters = sum(ch.isalpha() for ch in text)
        turkish = sum(text.count(c) for c in "ıŞşğİ") / max(1, letters)
        if letters < doc.page_count * 200:
            print(f"The PDF has almost no text layer (scan). Run:\n  py tools/ocr_pages.py \"{name}\"\n  py tools/convert_book.py \"{name}\"")
            return
        if a.side == "Turkish" and turkish < 0.02:
            print(f"The text layer has no Turkish letters (English OCR). Better to OCR it:\n  py tools/ocr_pages.py \"{name}\"")
        import convert_book
        convert_book.main.__globals__["sys"].argv = ["convert_book.py", name]
        convert_book.main()
    else:
        chunks = ebook_chunks(src)
        body = "\n".join(f"## loc. {i}\n\n" + "\n\n".join(c) + "\n" for i, c in enumerate(chunks, 1))
        open(out, "w", encoding="utf-8").write(front_matter(a, "loc.") + "\n" + body)
        import convert_book
        convert_book.main.__globals__["sys"].argv = ["convert_book.py", name]
        convert_book.main()
    src_note = os.path.join(LORE, "Sources", f"Source - {a.title}.md")
    if not os.path.exists(src_note):
        open(src_note, "w", encoding="utf-8").write(
            f"---\ntags: [source]\nside: {a.side}\nprotocol: {a.protocol}\n---\n# Source - {a.title}\n\n"
            f"- **Author:** {a.author}\n- **Side:** {a.side}\n- **Protocol:** {a.protocol}\n"
            f"- **Written:** {a.written or '?'}\n- **Covers:** {a.covers or '?'}\n"
            f"- **Converted text:** [[{name}]]\n- **Original file:** `{a.file}`\n\n"
            "Back to [[Home]] · [[Sources Ledger]]\n\n## Notes that use this source\n\n*(none yet)*\n")
    print(f"Created [[{name}]] and [[Source - {a.title}]]. Next: follow 'Adding a new source' in [[Handbook]].")


if __name__ == "__main__":
    main()
