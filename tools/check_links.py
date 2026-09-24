"""Check every wikilink in the vault: the target note must exist and, for
[[Note#Heading]] links, the heading must exist in that note.

    py tools/check_links.py            summary + first broken links
    py tools/check_links.py --all      list every broken link
"""
import glob
import os
import re
import sys
from collections import Counter, defaultdict

sys.stdout.reconfigure(encoding="utf-8")
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LORE = os.path.join(ROOT, "Lore")
LINK = re.compile(r"!?\[\[([^\]|#]*)(?:#([^\]|]*))?(?:\|[^\]]*)?\]\]")
HEAD = re.compile(r"^#{1,6} (.+?)\s*$", re.M)


def norm(h):
    return re.sub(r"\s+", " ", h).strip().lower()


def main():
    files = {}
    for f in glob.glob(os.path.join(LORE, "**", "*"), recursive=True):
        rel = os.path.relpath(f, LORE)
        if rel.startswith("Raw" + os.sep) or os.path.isdir(f) or rel.startswith(".obsidian"):
            continue
        name = os.path.basename(f)
        files.setdefault(os.path.splitext(name)[0] if name.endswith(".md") else name, f)
    headings = {}
    broken = Counter()
    examples = defaultdict(list)
    n_links = 0
    for key, f in files.items():
        if not f.endswith(".md"):
            continue
        text = open(f, encoding="utf-8").read()
        text = re.sub(r"```.*?```", "", text, flags=re.S)
        text = re.sub(r"`[^`\n]*`", "", text)  # inline code is not a link
        for m in LINK.finditer(text):
            target, head = m.group(1).strip(), m.group(2)
            n_links += 1
            if not target:
                target = key  # [[#Heading]] = same note
            tkey = os.path.basename(target)
            tf = files.get(tkey) or files.get(os.path.splitext(tkey)[0])
            if not tf:
                broken[("missing note", tkey)] += 1
                examples[("missing note", tkey)].append(key)
                continue
            if head and tf.endswith(".md"):
                if tf not in headings:
                    headings[tf] = {norm(h) for h in HEAD.findall(open(tf, encoding="utf-8").read())}
                if norm(head) not in headings[tf]:
                    broken[("missing heading", f"{tkey}#{head}")] += 1
                    examples[("missing heading", f"{tkey}#{head}")].append(key)
    total = sum(broken.values())
    print(f"{n_links} links checked, {total} broken ({len(broken)} distinct)")
    limit = None if "--all" in sys.argv else 40
    for (kind, t), c in broken.most_common(limit):
        print(f"  {kind}: {t}  x{c}  (e.g. in {examples[(kind, t)][0]})")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
