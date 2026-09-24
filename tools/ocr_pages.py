"""OCR PDF pages with RapidOCR (PP-OCRv5 Latin model, reads ç ğ ö ş ü).

Usage:
    py tools/ocr_pages.py <book-title-prefix> [--pages 1-20,45] [--workers 4]

Results go to tools/ocr_cache/<book title>.jsonl, one JSON object per page:
    {"page": N, "w": width_px, "h": height_px, "lines": [[x0, y0, x1, y1, text, score], ...]}
Already-cached pages are skipped, so the job can be stopped and resumed.
"""
import argparse
import glob
import json
import os
import re
import sys
sys.stdout.reconfigure(encoding="utf-8")
from concurrent.futures import ProcessPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CACHE = os.path.join(ROOT, "tools", "ocr_cache")
DPI = 170

_engine = None


def _init():
    global _engine
    import logging
    from rapidocr import RapidOCR, LangRec, OCRVersion, ModelType
    logging.getLogger("RapidOCR").setLevel(logging.WARNING)
    _engine = RapidOCR(params={"Rec.lang_type": LangRec.LATIN, "Rec.ocr_version": OCRVersion.PPOCRV5,
                               "Rec.model_type": ModelType.MOBILE,
                               "EngineConfig.onnxruntime.intra_op_num_threads": 2,
                               "EngineConfig.onnxruntime.use_dml": True})


def _ocr(args):
    path, idx = args
    import pymupdf
    doc = pymupdf.open(path)
    pix = doc[idx].get_pixmap(dpi=DPI)
    r = _engine(pix.tobytes("png"))
    lines = []
    if r.txts:
        for box, txt, sc in zip(r.boxes, r.txts, r.scores):
            xs = [p[0] for p in box]; ys = [p[1] for p in box]
            lines.append([round(float(min(xs)), 1), round(float(min(ys)), 1), round(float(max(xs)), 1), round(float(max(ys)), 1), str(txt), round(float(sc), 3)])
    return {"page": idx + 1, "w": pix.width, "h": pix.height, "lines": lines}


def book_source(prefix):
    f = glob.glob(os.path.join(ROOT, "Lore", "Converted", prefix + "*.md"))
    if len(f) != 1:
        sys.exit(f"book prefix {prefix!r} matched {len(f)} files")
    head = open(f[0], encoding="utf-8").read(4000)
    src = re.search(r'^source_file:\s*"?(.*?)"?$', head, re.M).group(1)
    return os.path.splitext(os.path.basename(f[0]))[0], os.path.join(ROOT, "Lore", src)


def parse_pages(spec, n):
    if not spec:
        return list(range(1, n + 1))
    out = []
    for part in spec.split(","):
        a, _, b = part.partition("-")
        out += list(range(int(a), int(b or a) + 1))
    return [p for p in out if 1 <= p <= n]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("book")
    ap.add_argument("--pages", default="")
    ap.add_argument("--workers", type=int, default=2)
    a = ap.parse_args()
    import pymupdf
    title, path = book_source(a.book)
    n = pymupdf.open(path).page_count
    os.makedirs(CACHE, exist_ok=True)
    out = os.path.join(CACHE, title + ".jsonl")
    done = set()
    if os.path.exists(out):
        good = []
        for l in open(out, encoding="utf-8"):
            try:
                good.append(json.loads(l))
            except ValueError:
                pass  # line cut off when a run was stopped
        done = {r["page"] for r in good}
        with open(out, "w", encoding="utf-8") as fh:
            fh.writelines(json.dumps(r, ensure_ascii=False) + "\n" for r in good)
    todo = [p for p in parse_pages(a.pages, n) if p not in done]
    print(f"{title}: {len(todo)} pages to OCR", flush=True)
    with ProcessPoolExecutor(a.workers, initializer=_init) as ex, open(out, "a", encoding="utf-8") as fh:
        for i, res in enumerate(ex.map(_ocr, [(path, p - 1) for p in todo], chunksize=2)):
            fh.write(json.dumps(res, ensure_ascii=False) + "\n"); fh.flush()
            if i % 25 == 0:
                print(f"  {title}: {i + 1}/{len(todo)}", flush=True)
    print(f"{title}: done", flush=True)


if __name__ == "__main__":
    main()
