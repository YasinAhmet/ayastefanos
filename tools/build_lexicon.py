"""Build tools/lexicon.json from the books in Lore/Converted.

counts : word frequencies over every Turkish book with intact Turkish letters
seed   : words seen in the born-digital e-books (treated as known-valid)
Books whose OCR lost the Turkish letters, English books and OCR'd e-books are
left out. Re-run after adding a new clean book.
"""
import glob, json, re, sys
sys.path.insert(0, 'tools')
from ocr_fix import TOKEN_RE, WORD_RE, tr_lower, norm_apos
from collections import Counter

def book_kind(t):
    body = t[t.find('\n## ') + 1:]
    letters = sum(ch.isalpha() for ch in body) or 1
    trr = sum(body.count(c) for c in 'ıŞşğİ') / letters
    eng = len(re.findall(r'\b(the|and|of|which|with)\b', body)) / max(1, len(body.split()))
    if eng > 0.05: return 'english'
    if trr < 0.02: return 'ascii'
    return 'turkish'

if __name__ == '__main__':
    counts, cap, seed = Counter(), Counter(), set()
    for f in glob.glob('Lore/Converted/*.md'):
        t = open(f, encoding='utf-8').read()
        src = re.search(r'^source_file:\s*"?(.*?)"?$', t, re.M).group(1)
        if book_kind(t) != 'turkish':
            continue
        ocr_ebook = 'OCR" hatası' in t[:6000] or 'produced by OCR' in t[:4000]
        born_digital = src.rsplit('.', 1)[-1] in ('epub', 'mobi', 'txt') and not ocr_ebook
        for m in TOKEN_RE.finditer(t):
            w = m.group(0)
            if not WORD_RE.match(w) or len(w) < 2:
                continue
            lw = tr_lower(norm_apos(w))
            counts[lw] += 1
            if w[0].isupper(): cap[lw] += 1
            if born_digital: seed.add(lw)
    counts = {w: n for w, n in counts.items() if n >= 2 or w in seed}
    capital = [w for w in counts if cap[w] >= 0.9 * counts[w]]
    json.dump({"counts": counts, "capital": capital, "seed": sorted(seed)},
              open('tools/lexicon.json', 'w', encoding='utf-8'), ensure_ascii=False)
    print(len(counts), 'words,', len(seed), 'seed words')
