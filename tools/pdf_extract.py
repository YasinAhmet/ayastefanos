"""Extract a PDF into page-by-page paragraphs using layout information.

Returns, for every PDF page, a list of blocks:
    ("h", text)   heading-like line (bigger font or short bold line)
    ("p", text)   body paragraph
    ("fn", text)  footnote paragraph (small font near the bottom)
Page numbers and running headers/footers are dropped.
"""
import re
import statistics
from collections import Counter

import pymupdf

SOFT_HYPHEN = "­"
SENT_END = tuple('.!?:;"”’»)…')


def _norm_key(s):
    return re.sub(r"[\d\W_]+", "", s.lower())


def _lines(page):
    """Yield text lines with geometry and font size."""
    d = page.get_text("rawdict", flags=pymupdf.TEXT_PRESERVE_WHITESPACE)
    out = []
    for b in d["blocks"]:
        if b.get("type") != 0:
            continue
        for ln in b["lines"]:
            dx, dy = ln.get("dir", (1, 0))
            if abs(dy) > 0.2:
                continue  # vertical / rotated text
            # split the line wherever there is a gap much wider than a word space:
            # scanned text layers often run one "line" across two columns
            segs, cur, prev_x1 = [], [], None
            for s in ln["spans"]:
                bold = ("Bold" in s["font"]) or bool(s["flags"] & 16)
                thr = max(10.0, 1.6 * s["size"])
                for ch in s["chars"]:
                    c = ch["c"]
                    cx0, cy0, cx1, cy1 = ch["bbox"]
                    wide_space = c.isspace() and (cx1 - cx0) > thr
                    if cur and (wide_space or (prev_x1 is not None and cx0 - prev_x1 > thr)):
                        segs.append(cur); cur = []
                    if not wide_space:
                        cur.append((c, cx0, cy0, cx1, cy1, s["size"], bold))
                    prev_x1 = cx1
            if cur:
                segs.append(cur)
            for seg in segs:
                text = "".join(c[0] for c in seg)
                if not text.strip():
                    continue
                vis = [c for c in seg if not c[0].isspace()] or seg
                out.append(dict(text=text.strip(), size=round(max(c[5] for c in vis), 1), bold=all(c[6] for c in vis),
                                x0=min(c[1] for c in vis), y0=min(c[2] for c in vis),
                                x1=max(c[3] for c in vis), y1=max(c[4] for c in vis)))
    out.sort(key=lambda l: (round(l["y0"] / 3), l["x0"]))
    # merge fragments sitting on the same baseline (but not across a column gap)
    merged = []
    for l in out:
        if merged and abs(merged[-1]["y0"] - l["y0"]) < 2.5 and merged[-1]["x1"] - 1 <= l["x0"] <= merged[-1]["x1"] + max(10.0, 1.6 * l["size"]):
            m = merged[-1]
            gap = l["x0"] - m["x1"]
            m["text"] += ("" if gap < 1.5 else " ") + l["text"]
            m["x1"] = l["x1"]; m["size"] = max(m["size"], l["size"]); m["bold"] = m["bold"] and l["bold"]
        else:
            merged.append(dict(l))
    return merged


def prev_end_any(s):
    return s.rstrip().endswith(SENT_END) or len(s) > 0


def join_lines(a, b):
    """Join two consecutive lines of the same paragraph, undoing hyphenation."""
    a = a.rstrip()
    b = b.lstrip()
    if a.endswith(SOFT_HYPHEN):
        return a[:-1] + b
    if a.endswith("-") and len(a) > 1 and a[-2].isalpha() and b[:1].islower():
        return a[:-1] + b
    return a + " " + b


def order_columns(lines, page_w):
    """Reorder lines of a two-column page (or a two-page spread): left column, then
    right column, band by band between full-width lines (titles, headers)."""
    if len(lines) < 12:
        return lines
    best = None
    for k in range(30, 71, 2):
        gx = page_w * k / 100
        cross = sum(1 for l in lines if l["x0"] < gx - 2 and l["x1"] > gx + 2)
        left = sum(1 for l in lines if l["x1"] <= gx + 2)
        right = sum(1 for l in lines if l["x0"] >= gx - 2)
        if left >= 5 and right >= 5 and cross <= max(2, len(lines) * 0.12):
            score = cross - 0.01 * min(left, right)
            if best is None or score < best[0]:
                best = (score, gx)
    if not best:
        return lines
    gx = best[1]
    out, left, right = [], [], []
    for l in sorted(lines, key=lambda l: l["y0"]):
        if l["x0"] < gx - 2 and l["x1"] > gx + 2:  # spans both columns
            out += sorted(left, key=lambda l: l["y0"]) + sorted(right, key=lambda l: l["y0"])
            left, right = [], []
            l["col"] = 2
            out.append(l)
        elif l["x1"] <= gx + 2:
            l["col"] = 0
            left.append(l)
        else:
            l["col"] = 1
            right.append(l)
    return out + sorted(left, key=lambda l: l["y0"]) + sorted(right, key=lambda l: l["y0"])


def _ocr_lines(rec, page_w, body):
    """Turn a cached OCR record (tools/ocr_pages.py) into line dicts in PDF units."""
    sc = page_w / rec["w"]
    hs = sorted(l[3] - l[1] for l in rec["lines"]) or [1]
    med = hs[len(hs) // 2] or 1
    out = []
    for x0, y0, x1, y1, text, score in rec["lines"]:
        rel = (y1 - y0) / med  # OCR boxes vary in height; only clearly bigger lines count as larger type
        out.append(dict(text=text.rstrip(), size=round(body * rel, 1) if rel > 1.6 else body, bold=False,
                        x0=x0 * sc, y0=y0 * sc, x1=x1 * sc, y1=y1 * sc))
    out.sort(key=lambda l: (round(l["y0"] / 3), l["x0"]))
    merged = []
    for l in out:  # OCR sometimes splits a line into boxes
        if merged and abs(merged[-1]["y0"] - l["y0"]) < 4 and l["x0"] >= merged[-1]["x1"] - 2:
            m = merged[-1]; m["text"] += " " + l["text"]; m["x1"] = l["x1"]
        else:
            merged.append(dict(l))
    return merged


def extract(path, ocr=None):
    """ocr: optional {page_no: cached OCR record}; those pages use the OCR text."""
    doc = pymupdf.open(path)
    pages = [_lines(p) for p in doc]
    heights = [p.rect.height for p in doc]
    widths = [p.rect.width for p in doc]

    sizes = Counter(l["size"] for pg in pages for l in pg for _ in range(max(1, len(l["text"]) // 20)))
    body = sizes.most_common(1)[0][0] if sizes else 10.0
    if ocr:
        for pno, rec in ocr.items():
            if 1 <= pno <= len(pages):
                pages[pno - 1] = _ocr_lines(rec, widths[pno - 1], body)

    # running headers / footers: same normalised text at page edges on many pages
    edge = Counter()
    for pg, h in zip(pages, heights):
        for l in pg:
            if l["y0"] < h * 0.09 or l["y1"] > h * 0.92:
                k = _norm_key(l["text"])
                if k:
                    edge[k] += 1
    running = {k for k, c in edge.items() if c >= max(4, len(pages) // 40)}

    result = []
    for pg, h, w in zip(pages, heights, widths):
        keep = []
        for l in pg:
            t = l["text"].strip()
            at_edge = l["y0"] < h * 0.09 or l["y1"] > h * 0.92
            if at_edge and re.fullmatch(r"[\divxlcIVXLC\-–— .]{1,8}", t):
                continue  # page number
            if at_edge and _norm_key(t) in running:
                continue
            if l["y0"] < h * 0.08 and len(t) < 70 and re.search(r"^\d{1,4}\s|\s\d{1,4}$", t):
                letters = [ch for ch in t if ch.isalpha()]
                if letters and sum(ch.isupper() for ch in letters) >= 0.6 * len(letters):
                    continue  # running header with page number (OCR noise defeats exact matching)
            keep.append(l)
        if not keep:
            result.append([])
            continue
        keep = order_columns(keep, w)
        body_lines = [l for l in keep if abs(l["size"] - body) < 1.2] or keep
        lh = statistics.median([l["y1"] - l["y0"] for l in body_lines]) or body
        margins = {}
        for c in (0, 1, 2, None):
            bl = [l for l in body_lines if l.get("col") == c] if c is not None else body_lines
            if not bl:
                continue
            lft = statistics.median(l["x0"] for l in bl)
            rgt = max(statistics.quantiles([l["x1"] for l in bl], n=10)[-1] if len(bl) > 3 else max(l["x1"] for l in bl), lft + 50)
            margins[c] = (lft, rgt)
        def mg(l):
            return margins.get(l.get("col"), margins[None])
        left, right = margins[None]
        width = right - left

        blocks = []
        cur = None  # [kind, text, last_line]
        for l in keep:
            t = l["text"].strip()
            small = l["size"] < body - 1.2
            big = l["size"] > body + 1.5
            kind = "fn" if (small and l["y0"] > h * 0.55) else "p"
            if kind == "p" and l["y0"] > h * 0.5 and re.match(r"^\d{1,3}\s?[A-ZÇĞİÖŞÜ“\"'(\[]", t) and cur and cur[0] in ("p", "fn")                     and (cur[0] == "fn" or l["y0"] - cur[2]["y1"] > 0 and not re.match(r"^\d{1,3}\.", t)):
                kind = "fn"
            if kind == "fn" and cur and cur[0] == "fn" and not re.match(r"^\d{1,3}\s?\S", t):
                pass
            elif kind == "p" and cur and cur[0] == "fn" and cur[2].get("col") == l.get("col"):
                kind = "fn"  # everything after the first footnote on a page is footnote text
            cw_l = mg(l)[1] - mg(l)[0]
            after_sentence = cur is None or cur[0] in ("h", "b") or cur[1].rstrip().endswith(SENT_END)
            heading = (big or (l["bold"] and len(t) < 90 and not t.endswith(",")
                               and (l["x1"] - l["x0"]) < 0.7 * cw_l)) and len(t) < 120 and after_sentence
            if heading:
                hk = "h" if l["size"] > body + 2.5 else "b"
                if cur and cur[0] in ("h", "b") and l["y0"] - cur[2]["y1"] < lh * 1.2:
                    cur[1] += " " + t; cur[2] = l
                    if hk == "h": cur[0] = "h"
                    continue
                if cur: blocks.append(cur)
                cur = [hk, t, l, [0]]
                cur.append(l["y0"] / h)
                continue
            new_par = True
            if cur and cur[0] == kind:
                prev = cur[2]
                L, R = mg(l)
                pL, pR = mg(prev)
                cw = R - L
                if prev.get("col") != l.get("col"):  # moved to the next column
                    gap = 0
                    indented = l["x0"] - L > 6 and l["x0"] - L < cw * 0.3
                else:
                    gap = l["y0"] - prev["y1"]
                    indented = l["x0"] - prev["x0"] > 6 and l["x0"] - L < cw * 0.3
                prev_short = prev["x1"] < pR - max(12, (pR - pL) * 0.08)
                if kind == "fn" and re.match(r"^\d{1,3}\s?\S", t) and prev_end_any(cur[1]):
                    indented = True
                prev_end = cur[1].rstrip().endswith(SENT_END)
                new_par = (gap > lh * 0.9) or indented or (prev_short and prev_end)
            if new_par:
                if cur: blocks.append(cur)
                cur = [kind, t, l]
                cur.append([l["x0"] - mg(l)[0]])
            else:
                cur[1] = join_lines(cur[1], t); cur[2] = l
                cur[3].append(l["x0"] - mg(l)[0])
        if cur: blocks.append(cur)
        out = []
        for blk in blocks:
            k, t, _, offs = blk[:4]
            t = re.sub(r"\s+", " ", t).strip()
            if t.endswith(SOFT_HYPHEN):
                t = t[:-1] + "-"
            if k == "p" and len(offs) >= 2 and min(offs) > 10 and min(offs) < width * 0.35:
                k = "q"  # indented block quotation
            if k == "h" and blk[4] > 0.4:
                k = "b"  # big text low on the page: treat as an inline heading
            out.append((k, t))
        result.append(out)
    toc = doc.get_toc()
    return result, toc
