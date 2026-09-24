"""Re-sync the quotes in the notes with the cleaned text in Lore/Converted.

    py tools/refresh_quotes.py            update every note, print a summary
    py tools/refresh_quotes.py --dry-run  only report

A quote is text in “…” paired with a page link [[Book#p. N…]] (on the same line,
or on the next "> — [[…]]" line for block quotes). The quote is located on that
page (or across that page and the next) by fuzzy matching on a folded form of
the text (case, Turkish letters, hyphenation and spacing ignored), and replaced
with the exact passage from the cleaned book. Quotes that cannot be matched
confidently are left as they are. A report goes to Lore/Raw/OCR corrections/_quotes.tsv.
"""
import glob
import os
import re
import sys
from collections import Counter

from rapidfuzz import fuzz

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LORE = os.path.join(ROOT, "Lore")
sys.path.insert(0, HERE)
from ocr_fix import FOLD, tr_lower  # noqa: E402

SEC = re.compile(r"^#{2,3} ((?:p|loc)\. \d+)\s*$", re.M)
LINK = re.compile(r"\[\[([^\]|#]+)#((?:p|loc)\. \d+)(?:\|[^\]]*)?\]\]")
QUOTE = re.compile(r"“([^”]{12,})”")

_books = {}


def book_pages(title):
    if title not in _books:
        p = os.path.join(LORE, "Converted", title + ".md")
        if not os.path.exists(p):
            _books[title] = None
        else:
            parts = SEC.split(open(p, encoding="utf-8").read())
            _books[title] = {parts[i]: parts[i + 1] for i in range(1, len(parts), 2)}
    return _books[title]


def plain(md):
    """Page body without Markdown decoration, as one line of text."""
    out = []
    for line in md.splitlines():
        if re.match(r"^\s*> \[!", line):
            continue
        line = re.sub(r"^\s*>\s?", "", line)
        line = line.replace("**", "")
        out.append(line)
    return re.sub(r"\s+", " ", " ".join(out)).strip()


def folded(s):
    """Fold text for matching; return (folded, index map back into s)."""
    chars, idx = [], []
    prev_space = True
    for i, ch in enumerate(s):
        if ch in "­":
            continue
        c = tr_lower(ch).translate(FOLD)
        if not c.isalnum():
            if prev_space:
                continue
            c = " "
            prev_space = True
        else:
            prev_space = False
        for cc in c:
            chars.append(cc); idx.append(i)
    return "".join(chars), idx


def locate(quote, text, cutoff=80):
    q, _ = folded(quote)
    t, idx = folded(text)
    if len(q) < 12 or len(t) < len(q) * 0.6:
        return None, 0
    al = fuzz.partial_ratio_alignment(q, t, score_cutoff=cutoff)
    if not al:
        return None, 0
    s, e = idx[al.dest_start], idx[min(al.dest_end, len(idx)) - 1] + 1
    # widen to whole words
    while s > 0 and text[s - 1].isalnum():
        s -= 1
    while e < len(text) and text[e].isalnum():
        e += 1
    span = text[s:e].strip()
    # the alignment can be loose at the edges: drop or add whole words while the fit improves
    words = span.split(" ")
    def fit(ws):
        return fuzz.ratio(q, folded(" ".join(ws))[0])
    best = fit(words)
    for side in (0, 1):
        while len(words) > 3:
            trial = words[1:] if side == 0 else words[:-1]
            sc = fit(trial)
            if sc >= best:
                words, best = trial, sc
            else:
                break
    span = " ".join(words)
    if not (0.75 <= len(span) / max(1, len(quote)) <= 1.3) or best < cutoff:
        return None, al.score
    return span, best


def next_label(label):
    unit, n = label.split(" ")
    return f"{unit} {int(n) + 1}"


def refresh_quote(quote, title, label):
    pages = book_pages(title)
    if not pages or label not in pages:
        return None, 0
    tail = ""
    core = quote
    if core.rstrip().endswith(("…", "...")):
        core = core.rstrip().rstrip(".…").rstrip()
        tail = "…"
    text = plain(pages[label])
    span, score = locate(core, text)
    if span is None and next_label(label) in pages:
        span, score = locate(core, text + " " + plain(pages[next_label(label)]))
    if span is None and title in ascii_books():
        # the old text of these books was letterless OCR; the page is known, so a looser match is safe
        span, score = locate(core, text, cutoff=62)
        if span is None and next_label(label) in pages:
            span, score = locate(core, text + " " + plain(pages[next_label(label)]), cutoff=62)
    if span is None:
        return None, score
    return span + tail, score


_ascii = None


def ascii_books():
    global _ascii
    if _ascii is None:
        _ascii = {os.path.splitext(os.path.basename(f))[0] for f in glob.glob(os.path.join(LORE, "Converted", "*.md"))
                  if "text_mode: ascii" in open(f, encoding="utf-8").read(3000)}
    return _ascii


def main():
    dry = "--dry-run" in sys.argv
    files = [f for f in glob.glob(os.path.join(LORE, "*", "*", "*.md")) + glob.glob(os.path.join(LORE, "*", "*.md"))
             if not os.path.relpath(f, LORE).startswith(("Converted", "Sources", "Raw", "Attachments"))]
    stats = Counter()
    rows = []
    for f in sorted(set(files)):
        lines = open(f, encoding="utf-8").read().split("\n")
        changed = False
        for i, line in enumerate(lines):
            if "“" not in line:
                continue
            link = LINK.search(line)
            if not link and line.lstrip().startswith(">") and i + 1 < len(lines):
                link = LINK.search(lines[i + 1]) if lines[i + 1].lstrip().startswith("> —") else None
            if not link:
                continue
            title, label = link.group(1).strip(), link.group(2)

            def repl(m):
                old = m.group(1)
                new, score = refresh_quote(old, title, label)
                if new is None:
                    stats["unmatched"] += 1
                    rows.append((os.path.basename(f), title, label, "unmatched", f"{score:.0f}", old[:80]))
                    return m.group(0)
                if new == old:
                    stats["same"] += 1
                    return m.group(0)
                stats["updated"] += 1
                rows.append((os.path.basename(f), title, label, "updated", "", old[:80] + " → " + new[:80]))
                return "“" + new + "”"

            new_line = QUOTE.sub(repl, line)
            if new_line != line:
                lines[i] = new_line
                changed = True
        if changed and not dry:
            open(f, "w", encoding="utf-8").write("\n".join(lines))
            stats["files"] += 1
    out = os.path.join(LORE, "Raw", "OCR corrections", "_quotes.tsv")
    with open(out, "w", encoding="utf-8") as fh:
        fh.write("note\tbook\tpage\tresult\tscore\tquote\n")
        for r in rows:
            fh.write("\t".join(x.replace("\t", " ").replace("\n", " ") for x in r) + "\n")
    print(dict(stats), "report:", out)


if __name__ == "__main__":
    main()
