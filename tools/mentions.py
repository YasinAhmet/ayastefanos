"""Find where a subject is mentioned in the books.

    py tools/mentions.py "Enver Paşa"                 every page of every book naming the note (name + aliases)
    py tools/mentions.py "Enver Paşa" --book Talat    only books whose title starts with "Talat"
    py tools/mentions.py --terms "Sarıkamış,Sarikamis" [--book ...]   free search terms
    py tools/mentions.py --scan-book "Talat Paşa'nın Anıları"         which notes a (new) book mentions, with page counts

Matching is case-insensitive (Turkish-aware), at the start of a word, on the
note's name and its `aliases:` (aliases are often stems like "Balkan Sava").
Output lines are ready-made Obsidian links: [[Book#p. N|N]].
"""
import argparse
import glob
import os
import re
import sys
from collections import defaultdict

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
LORE = os.path.join(os.path.dirname(HERE), "Lore")
SEC = re.compile(r"^#{2,3} ((?:p|loc)\. \d+)\s*$", re.M)


def tr_lower(s):
    return s.replace("I", "ı").replace("İ", "i").lower()


def note_terms(name):
    f = [p for p in glob.glob(os.path.join(LORE, "*", "*", name + ".md"))]
    if not f:
        sys.exit(f"no note named {name!r}")
    head = open(f[0], encoding="utf-8").read(2000)
    m = re.search(r"^aliases:\s*\[(.*)\]", head, re.M)
    aliases = re.findall(r'"([^"]+)"', m.group(1)) if m else []
    base = re.sub(r"\s*\([^)]*\)$", "", name)
    return [t for t in dict.fromkeys([base] + aliases) if len(t) >= 3]


def books(prefix=None):
    for f in sorted(glob.glob(os.path.join(LORE, "Converted", "*.md"))):
        title = os.path.splitext(os.path.basename(f))[0]
        if prefix and not title.startswith(prefix):
            continue
        yield title, open(f, encoding="utf-8").read()


def sections(text):
    parts = SEC.split(text)
    for i in range(1, len(parts), 2):
        yield parts[i], parts[i + 1]


def pattern(terms):
    alts = "|".join(re.escape(tr_lower(t).replace("’", "'")) for t in sorted(terms, key=len, reverse=True))
    return re.compile(r"(?<![\wçğıöşü])(?:" + alts + ")")


def find(terms, prefix=None):
    pat = pattern(terms)
    hits = defaultdict(list)
    for title, text in books(prefix):
        for label, body in sections(text):
            if pat.search(tr_lower(body).replace("’", "'")):
                hits[title].append(label)
    return hits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("note", nargs="?")
    ap.add_argument("--terms")
    ap.add_argument("--book")
    ap.add_argument("--scan-book")
    a = ap.parse_args()
    if a.scan_book:
        notes = [os.path.splitext(os.path.basename(f))[0] for f in glob.glob(os.path.join(LORE, "*", "*", "*.md"))
                 if not os.path.relpath(f, LORE).startswith(("Converted", "Sources", "Raw", "Attachments"))]
        rows = []
        for n in notes:
            h = find(note_terms(n), a.scan_book)
            c = sum(len(v) for v in h.values())
            if c:
                rows.append((c, n))
        for c, n in sorted(rows, reverse=True):
            print(f"{c:5d}  [[{n}]]")
        return
    terms = [t.strip() for t in a.terms.split(",")] if a.terms else note_terms(a.note)
    print("terms:", terms)
    hits = find(terms, a.book)
    total = 0
    for title, labels in hits.items():
        total += len(labels)
        links = " · ".join(f"[[{title}#{l}|{l.split(' ')[1]}]]" for l in labels)
        print(f"- **{title}** ({len(labels)}): {links}")
    print(f"{total} pages in {len(hits)} books")


if __name__ == "__main__":
    main()
