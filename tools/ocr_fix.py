"""Dictionary-based OCR repair for Turkish text.

A rare or malformed word is replaced only when a much more common word from the
lexicon has the same "OCR skeleton" (the form that typical OCR confusions such
as ın→m, rı→n, ü→ii, ş→$ collapse to) and scores clearly better than the word
as written. Known-valid words are never touched in "light" mode.
Every replacement is logged in Corrector.log so it can be reviewed.

Modes:
  "light"  good Turkish text layer: fix OCR slips only (Ankara'mn → Ankara'nın)
  "ascii"  OCR engine without Turkish letters (Talat Paşa, Windows OCR books):
           also restore ı ş ğ ç ö ü (Sarikamis → Sarıkamış, iizere → üzere)

Lexicon: tools/lexicon.json (built by tools/build_lexicon.py from the vault's
books) + tools/valid_words.txt (general Turkish word list, OpenSubtitles 2018
frequency list from hermitdave/FrequencyWords, words seen >= 5 times).
"""
import itertools
import json
import math
import os
import re
from collections import Counter, defaultdict

from rapidfuzz.distance import Levenshtein

APOS = "'’‘`´"
LET = "A-Za-zÇĞİÖŞÜçğıöşüÂÎÛâîûÉéÈèÊêÀàÄäËëÏïÔôÖöÙùÜü"
GLY = "0-9$#*}{¢&!|"
TOKEN_RE = re.compile(f"[{LET}{GLY}]+(?:[{APOS}][{LET}{GLY}]+)?")
WORD_RE = re.compile(f"^[{LET}]+(?:[{APOS}][{LET}]+)?$")

FOLD = str.maketrans({"ç": "c", "ş": "s", "ğ": "g", "ı": "i", "ö": "o", "ü": "u", "â": "a", "î": "i", "û": "u",
                      "é": "e", "è": "e", "ê": "e", "à": "a", "ä": "a", "ë": "e", "ï": "i", "ô": "o"})
CIRC = str.maketrans({"â": "a", "î": "i", "û": "u", "Â": "A", "Î": "I", "Û": "U"})
# glyph → letter guesses (OCR side only)
OCR_GLYPHS = {"1": "i", "!": "i", "&": "i", "|": "i", "$": "s", "9": "s", "#": "s", "*": "s", "}": "s", "{": "s",
              "¢": "c", "6": "o", "é": "o", "0": "o"}
COLLAPSE = [("ii", "u"), ("rn", "n"), ("ri", "n"), ("ni", "n"), ("in", "n")]


def tr_lower(s):
    return s.replace("I", "ı").replace("İ", "i").lower()


def tr_upper(s):
    return s.replace("i", "İ").replace("ı", "I").upper()


def norm_apos(s):
    return re.sub(f"[{APOS}]", "'", s)


def fold(s):
    return norm_apos(tr_lower(s)).translate(FOLD)


def _collapse(s):
    s = s.replace("m", "n")
    out, i = [], 0
    while i < len(s):
        for a, b in COLLAPSE:
            if s.startswith(a, i):
                out.append(b); i += len(a); break
        else:
            out.append(s[i]); i += 1
    return "".join(out)


def skeleton(word):
    return _collapse(fold(word))


def glyph_fold(low):
    return "".join(OCR_GLYPHS.get(ch, ch) for ch in low).translate(FOLD)


def ocr_skeletons(low, ascii_mode=False):
    g = glyph_fold(low)
    variants = {g}
    if ascii_mode:
        variants.add(g.replace("l", "i"))
        if "1" in low:  # Windows OCR also wrote 1 for l
            variants.add("".join("l" if ch == "1" else OCR_GLYPHS.get(ch, ch) for ch in low).translate(FOLD))
        # Talat Paşa's OCR wrote g for ç/ş (topgusu → topçusu, gehri → şehri)
        pos = [i for i, ch in enumerate(g) if ch == "g"][:3]
        for combo in itertools.product("gcs", repeat=len(pos)):
            v = list(g)
            for i, ch in zip(pos, combo):
                v[i] = ch
            variants.add("".join(v))
        # RapidOCR's Latin model reads a blurred dotless ı as u, a or s (yanumda, zarflars)
        pos = [i for i, ch in enumerate(g) if ch in "uas"][:8]
        for k in (1, 2):
            for combo in itertools.combinations(pos, k):
                v = list(g)
                for i in combo:
                    v[i] = "i"
                variants.add("".join(v))
        # blurred "lı" read as h (akhm → aklım, esash → esaslı)
        for v in list(variants):
            hpos = [i for i, ch in enumerate(v) if ch == "h"][:2]
            for i in hpos:
                variants.add(v[:i] + "li" + v[i + 1:])
    return {_collapse(v) for v in variants}


def load_lexicon(path, valid_path=None):
    """Return (counts, capitalised words, known-valid words)."""
    data = json.load(open(path, encoding="utf-8"))
    valid_path = valid_path or os.path.join(os.path.dirname(path), "valid_words.txt")
    general = set()
    if os.path.exists(valid_path):
        general = {l.strip() for l in open(valid_path, encoding="utf-8") if l.strip()}
    return Counter(data["counts"]), set(data.get("capital", [])), (general, set(data.get("seed", [])))


class Corrector:
    def __init__(self, counts, capital, valid=((), ())):
        self.counts = counts
        self.capital = capital
        self.general = set(valid[0])   # general Turkish word list: always trusted
        self.seed = set(valid[1])      # words from the vault's e-books: trusted unless a look-alike is far more common
        self.valid = self.general | self.seed
        self.index = defaultdict(list)
        for w, n in counts.items():
            self.index[skeleton(w)].append((n, w))
        for k in self.index:
            self.index[k].sort(reverse=True)
            del self.index[k][8:]
        self.cache = {}
        self.log = Counter()

    def _score(self, n, d):
        return math.log(max(n, 1)) - 1.2 * d

    def _best(self, low, mode):
        ascii_mode = mode == "ascii"
        n0 = self.counts.get(low, 0)
        has_glyph = any(ch in OCR_GLYPHS for ch in low)
        is_ascii = low == fold(low)
        if not has_glyph and low in self.general and not (ascii_mode and is_ascii):
            return None
        seed_only = low in self.seed and not has_glyph and not (ascii_mode and is_ascii)
        g = glyph_fold(low)
        self_score = self._score(n0, 0) if (n0 and not has_glyph) else -1e9
        best, best_score = None, -1e9
        for sk in ocr_skeletons(low, ascii_mode):
            for n, w in self.index.get(sk, []):
                if w == low or n < 5:
                    continue
                if w.translate(CIRC) == low.translate(CIRC):
                    continue  # circumflex spelling only
                if fold(w) == fold(low) and not ascii_mode:
                    continue  # Turkish letters present but differ: not an OCR slip we trust
                fw = fold(w)
                d = min(Levenshtein.distance(fw, g, weights=(2, 2, 1)),
                        Levenshtein.distance(fw, g.replace("ii", "u"), weights=(2, 2, 1)))
                if d > max(4, len(w) * 2 // 3):
                    continue
                sc = self._score(n, d) + (1.5 if d == 0 else 0)
                if sc > best_score:
                    best, best_score = w, sc
        if best is None:
            return None
        nb = self.counts[best]
        if seed_only and nb < 40 * max(n0, 1):
            return None
        if ascii_mode:
            if best_score < self_score + 1.0 or nb < 20:
                return None
        else:
            if n0 and nb < 4 * n0 or nb < 30:
                return None
            ft, fb = glyph_fold(low), fold(best)
            # OCR slips of this family change the length (ın→m, rı→n, rn→m); a same-length
            # m↔n swap or a bare suffix difference is usually a different valid word form
            if len(ft) == len(fb) and not has_glyph:
                return None
            if fb.startswith(ft) or ft.startswith(fb):
                return None
            # "-ım" vs "-ını" is a classic OCR slip but also a valid possessive
            if n0 >= 2 and re.search("[ıiuü]m$", low.split("'")[-1]) and best.endswith(("nı", "ni", "nu", "nü")):
                return None
        return best

    def fix_token(self, token, mode):
        key = (token, mode)
        if key in self.cache:
            return self.cache[key]
        out = token
        letters_n = sum(ch.isalpha() for ch in token)
        core = re.split(f"[{APOS}]", token)[0]
        odd_case = bool(re.search(r"[a-zçğıöşü][A-ZÇĞİÖŞÜ]", core))
        skip = (letters_n < 3 or letters_n < 0.6 * len(token) or token[:1].isdigit()
                or (odd_case and mode != "ascii")
                or (mode == "light" and (re.search("[âîûÂÎÛ]", token) or letters_n <= 4)))
        stripped = token.rstrip("!&|$#*}{¢")
        if not skip and stripped != token and norm_apos(tr_lower(stripped)) in self.valid:
            skip = True  # trailing punctuation, e.g. "Hayır!"
        if not skip:
            low = norm_apos(tr_lower(token))
            best = self._best(low, mode)
            if best:
                out = best
                ap = next((ch for ch in token if ch in APOS), None)
                if ap:
                    out = out.replace("'", ap)
                letters = [ch for ch in token if ch.isalpha()]
                if len(letters) > 1 and sum(ch.isupper() for ch in letters) >= len(letters) - 1 and token[1:2].isupper():
                    out = tr_upper(out)
                elif token[:1].isupper() or best in self.capital:
                    out = tr_upper(out[:1]) + out[1:]
                self.log[(token, out)] += 1
        self.cache[key] = out
        return out

    def _stem_index(self):
        if not hasattr(self, "_folds"):
            book, gen = {}, {}
            for w, n in self.counts.most_common():
                if n >= 2:
                    book.setdefault(fold(w), w)  # most frequent spelling in the books
            for w in self.general:
                gen.setdefault(fold(w), w)
            self._folds = (book, gen)
        return self._folds

    def _stem(self, part):
        book, gen = self._stem_index()
        f = fold(part)
        if f in book:
            return book[f]
        w = gen.get(f)
        # a general-list stem may only differ from the OCR text by a non-initial i→ı
        if w and len(w) == len(part) and all(a == b or (a == "i" and b == "ı" and k > 0)
                                             for k, (a, b) in enumerate(zip(part, w))):
            return w
        return None

    def harmonize(self, token):
        """OCR that reads dotless ı as i: keep the longest known stem, then set ı/i in
        the suffix by vowel harmony (tutuklamiş → tutuklamış, Sarikamış'a → Sarıkamış'a)."""
        low = norm_apos(tr_lower(token))
        if "i" not in low or low in self.valid or self.counts.get(low, 0) >= 2:
            return token
        stem_part, sep, rest = low.partition("'")
        best = None
        for k in range(len(stem_part), 2, -1):
            w = self._stem(stem_part[:k])
            if w and (k == len(stem_part) or len(stem_part) - k <= 9):
                best = (w, stem_part[k:])
                break
        if not best:
            return token
        stem, suffix = best
        vowels_back, vowels_front = "aıou", "eiöü"
        last = next((ch for ch in reversed(stem) if ch in vowels_back + vowels_front + "âû"), None)
        out = []
        for ch in suffix + ((sep + rest) if sep else ""):
            if ch == "i" and last is not None and last in "aıouâû":
                ch = "ı"
            if ch in vowels_back + vowels_front:
                last = ch
            out.append(ch)
        new = stem + "".join(out)
        if fold(new) != fold(low) or new == low:
            return token
        if token[:1].isupper():
            new = tr_upper(new[:1]) + new[1:]
        ap = next((ch for ch in token if ch in APOS), None)
        if ap:
            new = new.replace("'", ap)
        self.log[(token, new)] += 1
        return new

    def fix_ocr_text(self, text):
        """For RapidOCR output: dictionary repair, then vowel-harmony ı restoration."""
        text = self.fix_text(text, "ascii")
        return TOKEN_RE.sub(lambda m: self.harmonize(m.group(0)), text)

    def fix_text(self, text, mode="light"):
        if not text or mode not in ("light", "ascii"):
            return text
        return TOKEN_RE.sub(lambda m: self.fix_token(m.group(0), mode), text)
