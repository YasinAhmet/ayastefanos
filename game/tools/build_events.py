"""Build the game's data from the design notes in Lore/Game Design.

    py game/tools/build_events.py            build game/data/events.json and copy images
    py game/tools/build_events.py --check    same, and exit with 1 if there is any error
    py game/tools/build_events.py --warnings print every warning (default: first 60)

Reads every `GD *.md` file (grammar: Lore/Game Design/GD 02 Sistemler.md, section
"Olay yazım kuralları"), validates events, conditions, effects, flags, links, quotes
and images, then writes game/data/events.json and copies the used images (resized)
into game/assets/images with a CREDITS.md.
"""
import glob
import hashlib
import json
import os
import re
import sys
from collections import defaultdict

sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
LORE = os.path.join(ROOT, "Lore")
DESIGN = os.path.join(LORE, "Game Design")
IMG_SRC = os.path.join(LORE, "Attachments", "Images")
CREDITS_SRC = os.path.join(LORE, "Attachments", "Image credits.md")
OUT_DATA = os.path.join(ROOT, "game", "data")
OUT_IMG = os.path.join(ROOT, "game", "assets", "images")

sys.path.insert(0, os.path.join(ROOT, "tools"))
sys.dont_write_bytecode = True  # never write into tools/__pycache__
from check_links import LINK, HEAD, norm  # noqa: E402  (reuse the vault's link checker rules)

KINDS = {"zorunlu", "isteğe bağlı", "geçici", "ara", "kural", "manşet", "epilog", "karar"}
PLAYABLE = ("zorunlu", "isteğe bağlı", "geçici", "ara")
TAGS = {"zincir", "alternatif"}
SEATS = {"maliye": "maliye", "harbiye": "harbiye", "bahriye": "bahriye"}
TIME_VARS = {"yıl": "year", "yil": "year", "ay": "month", "tarihî_mod": "hist_mode", "tarihi_mod": "hist_mode"}
MAX_IMG = 1280

errors, warnings = [], []
POP = {"groups": {}, "regions": {}, "provinces": set()}  # filled in main(); read by parse_effects for 👥


def err(where, msg):
    errors.append(f"{where}: {msg}")


def warn(where, msg):
    warnings.append(f"{where}: {msg}")


def tr_lower(s):
    return s.replace("I", "ı").replace("İ", "i").lower()


# ---------------------------------------------------------------- vault index

def vault_index():
    files = {}
    for f in glob.glob(os.path.join(LORE, "**", "*"), recursive=True):
        rel = os.path.relpath(f, LORE)
        if rel.startswith("Raw" + os.sep) or rel.startswith(".obsidian") or os.path.isdir(f):
            continue
        name = os.path.basename(f)
        files.setdefault(os.path.splitext(name)[0] if name.endswith(".md") else name, f)
    return files


FILES = vault_index()
_heads, _pages = {}, {}


def headings(path):
    if path not in _heads:
        _heads[path] = {norm(h) for h in HEAD.findall(open(path, encoding="utf-8").read())}
    return _heads[path]


def page_text(book, label):
    """Text of one `p. N` / `loc. N` section of a converted book."""
    key = (book, label)
    if key not in _pages:
        path = FILES.get(book)
        txt = ""
        if path and path.endswith(".md"):
            parts = re.split(r"^#{2,3} ((?:p|loc)\. \d+)\s*$", open(path, encoding="utf-8").read(), flags=re.M)
            for i in range(1, len(parts), 2):
                _pages[(book, parts[i])] = parts[i + 1]
            txt = _pages.get(key, "")
        _pages[key] = txt
    return _pages[key]


def check_link(where, target, head):
    target = target.strip()
    tf = FILES.get(os.path.basename(target)) or FILES.get(os.path.splitext(os.path.basename(target))[0])
    if not tf:
        err(where, f"broken link: [[{target}]]")
        return None
    if head and tf.endswith(".md") and norm(head) not in headings(tf):
        err(where, f"missing heading: [[{target}#{head}]]")
    return tf


# ---------------------------------------------------------------- text helpers

def link_label(m):
    inner = m.group(0).lstrip("!")[2:-2]
    target, _, label = inner.partition("|")
    target = target.split("#")[0]
    return label or target


def to_bbcode(s, codex_refs=None):
    """Markdown-lite → Godot RichTextLabel BBCode. [[Note]] becomes a codex link."""
    def repl(m):
        inner = m.group(0).lstrip("!")[2:-2]
        target, _, label = inner.partition("|")
        note = target.split("#")[0].strip()
        label = label or note
        path = FILES.get(note, "")
        is_lore_note = path.endswith(".md") and os.sep + "Converted" + os.sep not in path \
            and os.sep + "Game Design" + os.sep not in path
        if codex_refs is not None and is_lore_note:
            codex_refs.add(note)
            return f"[url=codex:{note}]{label}[/url]"
        return label
    s = LINK.sub(repl, s)
    s = re.sub(r"\*\*(.+?)\*\*", r"[b]\1[/b]", s)
    s = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"[i]\1[/i]", s)
    return s


# ---------------------------------------------------------------- conditions

TOKEN = re.compile(r"\s*(>=|<=|!=|=|>|<|&|\||!|\(|\)|\+|-|⚑\s*[\wçğıöşüÇĞİÖŞÜ]+|f:[\wçğıöşüÇĞİÖŞÜ]+|(?:il|sahip):[a-z0-9_]+|\d+|[\wçğıöşüÇĞİÖŞÜ]+)")


class CondError(Exception):
    pass


def tokenize(s):
    pos, out = 0, []
    s = s.strip()
    while pos < len(s):
        m = TOKEN.match(s, pos)
        if not m or m.end() == pos:
            raise CondError(f"cannot read '{s[pos:]}'")
        out.append(m.group(1))
        pos = m.end()
    return out


class Parser:
    def __init__(self, text, resolve, world=None, provinces=None, nation_codes=None):
        self.t = tokenize(text)
        self.i = 0
        self.resolve = resolve
        self.flags = set()
        self.world = world or {}            # world-state key -> set of values
        self.provinces = provinces or set()
        self.nation_codes = nation_codes or set()
        self.world_read = set()             # (key, value) pairs this condition compares

    def peek(self):
        return self.t[self.i] if self.i < len(self.t) else None

    def take(self, want=None):
        tok = self.peek()
        if tok is None or (want and tok != want):
            raise CondError(f"expected {want or 'more'}, got {tok}")
        self.i += 1
        return tok

    def parse(self):
        node = self.or_()
        if self.peek() is not None:
            raise CondError(f"unexpected '{self.peek()}'")
        return node

    def or_(self):
        args = [self.and_()]
        while self.peek() == "|":
            self.take()
            args.append(self.and_())
        return args[0] if len(args) == 1 else {"op": "or", "args": args}

    def and_(self):
        args = [self.unary()]
        while self.peek() == "&":
            self.take()
            args.append(self.unary())
        return args[0] if len(args) == 1 else {"op": "and", "args": args}

    def unary(self):
        tok = self.peek()
        if tok == "!":
            self.take()
            return {"op": "not", "arg": self.unary()}
        if tok == "(":
            self.take()
            node = self.or_()
            self.take(")")
            return node
        if tok and (tok.startswith("⚑") or tok.startswith("f:")):
            self.take()
            name = tok[1:].strip() if tok.startswith("⚑") else tok[2:]
            self.flags.add(name)
            return {"op": "flag", "name": name}
        nxt = self.t[self.i + 1] if self.i + 1 < len(self.t) else None
        if tok and nxt in ("=", "!=") and (tok in self.world or tok.startswith("il:") or tok.startswith("sahip:")):
            return self.state_compare()
        return self.compare()

    def state_compare(self):
        """`reji = milli`, `il:kars = RU` (who holds it), `sahip:misir != OS` (who owns it)."""
        key = self.take()
        eq = self.take() == "="
        val = self.take()
        if key.startswith("il:") or key.startswith("sahip:"):
            layer, _, prov = key.partition(":")
            if prov not in self.provinces:
                raise CondError(f"unknown province '{prov}'")
            if val not in self.nation_codes:
                raise CondError(f"unknown nation '{val}'")
            return {"op": "prov", "layer": "ctl" if layer == "il" else "own", "id": prov, "eq": eq, "val": val}
        if val not in self.world[key]:
            raise CondError(f"'{val}' is not a value of {key} ({', '.join(sorted(self.world[key]))})")
        self.world_read.add((key, val))
        return {"op": "state", "key": key, "eq": eq, "val": val}

    def term_list(self):
        terms = [[1, self.name()]]
        while self.peek() in ("+", "-"):
            sign = 1 if self.take() == "+" else -1
            terms.append([sign, self.name()])
        return terms

    def name(self):
        tok = self.take()
        if tok.isdigit():
            raise CondError(f"expected a name, got {tok}")
        rid = self.resolve(tok)
        if rid is None:
            raise CondError(f"unknown value '{tok}'")
        return rid

    def compare(self):
        left = self.term_list()
        op = self.take()
        if op not in (">=", "<=", "!=", "=", ">", "<"):
            raise CondError(f"expected a comparison, got {op}")
        sign = 1
        if self.peek() == "-":
            self.take()
            sign = -1
        num = self.take()
        if not num.isdigit():
            raise CondError(f"expected a number, got {num}")
        return {"op": "cmp", "cmp": op, "left": left, "right": sign * int(num)}


def cond_text(node, names):
    """Human-readable lock reason, in Turkish."""
    op = node["op"]
    if op == "and":
        return " ve ".join(cond_text(a, names) for a in node["args"])
    if op == "or":
        return "(" + " ya da ".join(cond_text(a, names) for a in node["args"]) + ")"
    if op == "not":
        return "değil: " + cond_text(node["arg"], names)
    if op in ("flag", "state", "prov"):
        return "önceki bir karar"
    left = " ".join(("" if i == 0 and s > 0 else ("+ " if s > 0 else "− ")) + names.get(n, n)
                    for i, (s, n) in enumerate(node["left"]))
    sym = {">=": "≥", "<=": "≤", "!=": "≠", "=": "=", ">": ">", "<": "<"}[node["cmp"]]
    return f"{left} {sym} {node['right']}"


def cond_hidden(node, visible):
    """True if a condition depends on hidden values or flags (lock reason is then vague)."""
    op = node["op"]
    if op in ("and", "or"):
        return any(cond_hidden(a, visible) for a in node["args"])
    if op == "not":
        return cond_hidden(node["arg"], visible)
    if op in ("flag", "state", "prov"):
        return True
    return any(n not in visible and n not in ("year", "month", "hist_mode") for _, n in node["left"])


# ---------------------------------------------------------------- parsing

FIELD = re.compile(r"`([^`]+)`")
HEADER = re.compile(r"^###\s+(.+?)\s*$")
EVENT_TITLE = re.compile(r"^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?\s*·\s*(.+)$")
OPTION = re.compile(r"^\s*(\d+)\.\s+\*\*(.+?)\*\*\s*(.*)$")
ADVICE = re.compile(r"^(?:💬|say)\s*(?:\[eğer:\s*(.+?)\]\s*)?([^:]+):\s*(.+)$")
IF_PREFIX = re.compile(r"^\[eğer:\s*(.+?)\]\s*")
IF_INLINE = re.compile(r"\{eğer\s+(.+?):\s+(.*?)(?:\s*/\s*aksi:\s*(.*?))?\}")  # "il:kars" has no space after ":"


def parse_fields(line):
    fields, tags = {}, set()
    for seg in FIELD.findall(line):
        key, sep, val = seg.partition(":")
        if sep:
            fields[key.strip()] = val.strip()
        else:
            tags.add(seg.strip())
    return fields, tags


def is_field_line(line):
    s = line.strip()
    return s.startswith("`") and bool(re.fullmatch(r"(`[^`]+`\s*(·\s*)?)+", s))


def parse_table(lines, start):
    """Markdown table beginning at or after `start`; returns list of dicts."""
    i = start
    while i < len(lines) and not lines[i].startswith("|"):
        if lines[i].startswith("## "):
            return []
        i += 1
    if i >= len(lines):
        return []
    head = [c.strip() for c in lines[i].strip().strip("|").split("|")]
    rows = []
    i += 2
    while i < len(lines) and lines[i].startswith("|"):
        cells = [c.strip() for c in re.split(r"(?<!\\)\|", lines[i].strip().strip("|"))]
        rows.append(dict(zip(head, cells)))
        i += 1
    return rows


def blocks(path):
    """Yield (header, lines, first_line_no) for every ### block in a file."""
    lines = open(path, encoding="utf-8").read().split("\n")
    in_code = False
    cur, buf, start = None, [], 0
    for n, line in enumerate(lines, 1):
        if line.strip().startswith("```"):
            in_code = not in_code
        if in_code:
            if cur is not None:
                buf.append(line)
            continue
        m = HEADER.match(line)
        if m or line.startswith("## ") or line.startswith("# "):
            if cur is not None:
                yield cur, buf, start
            cur, buf, start = (m.group(1) if m else None), [], n
            continue
        if cur is not None:
            buf.append(line)
    if cur is not None:
        yield cur, buf, start


def main():
    check = "--check" in sys.argv
    gd_files = sorted(glob.glob(os.path.join(DESIGN, "GD *.md")))
    if not gd_files:
        sys.exit("no GD files found in " + DESIGN)

    # ---- resources and cabinets (tables in GD 02)
    sys_path = os.path.join(DESIGN, "GD 02 Sistemler.md")
    sys_lines = open(sys_path, encoding="utf-8").read().split("\n")
    resources, cabinets = [], []
    for i, line in enumerate(sys_lines):
        if line.strip() == "## Kaynaklar":
            for r in parse_table(sys_lines, i + 1):
                resources.append({"id": r["id"], "name": r["Ad"], "start": int(r["Başlangıç"]),
                                  "visible": r["Görünür"].lower().startswith("e"), "desc": r.get("Açıklama", "")})
        if line.strip() == "## Kabineler":
            cabinets = parse_table(sys_lines, i + 1)
    if not resources:
        err("GD 02", "no ## Kaynaklar table")
    names = {}
    for r in resources:
        names[tr_lower(r["id"])] = r["id"]
        names[tr_lower(r["name"])] = r["id"]
    for k, v in TIME_VARS.items():
        names[k] = v
    display = {r["id"]: r["name"] for r in resources}
    display.update({"year": "yıl", "month": "ay", "hist_mode": "Tarihî mod"})
    visible = {r["id"] for r in resources if r["visible"]}

    def resolve(tok):
        return names.get(tr_lower(tok))

    # ---- world state (GD 04) and provinces (GD 05)
    world, world_values = [], {}
    provinces = []
    for fname_, title_, cols in (("GD 04 Dünya Durumu ve İplikler.md", "## Dünya durumu", "world"),
                                 ("GD 05 Harita ve Harpler.md", "## İller", "prov")):
        path_ = os.path.join(DESIGN, fname_)
        if not os.path.exists(path_):
            err(fname_, "missing registry file")
            continue
        lines_ = open(path_, encoding="utf-8").read().split("\n")
        for i, line in enumerate(lines_):
            if line.strip() != title_:
                continue
            for r in parse_table(lines_, i + 1):
                if cols == "world":
                    vals = {}
                    for part in re.split(r"\s·\s", r["Değerler"]):
                        k, _, lab = part.partition(":")
                        vals[k.strip()] = lab.strip() or k.strip()
                    if r["Başlangıç"] not in vals:
                        err(fname_, f"{r['id']}: start value '{r['Başlangıç']}' not among its values")
                    world.append({"id": r["id"], "name": r["Ad"], "start": r["Başlangıç"], "values": vals,
                                  "desc": r.get("Açıklama", "")})
                    world_values[r["id"]] = set(vals)
                else:
                    provinces.append({"id": r["id"], "name": r["Ad"], "own": r["Sahip"], "ctl": r["Tutan"],
                                      "region": r.get("Bölge", "")})
    for w in world:
        if w["id"] in names.values() or tr_lower(w["id"]) in names:
            err("GD 04", f"world key '{w['id']}' clashes with a resource name")
    prov_ids = {p["id"] for p in provinces}

    # ---- population (GD 05 ## Nüfus): groups, 1873 table; regions come from the İller table
    map_lines = open(os.path.join(DESIGN, "GD 05 Harita ve Harpler.md"), encoding="utf-8").read().split("\n")
    pop_groups, population, figure_rows = [], {}, []
    for i, line in enumerate(map_lines):
        s = line.strip()
        if s == "### Nüfus grupları":
            for r in parse_table(map_lines, i + 1):
                pop_groups.append({"id": r["id"], "name": r["Ad"], "power": r.get("Güç", "-"),
                                   "leave": int(r.get("Göç", "0") or 0), "_press": r.get("Baskı", "-"),
                                   "_revolt": r.get("Ayaklanma", "-")})
        elif s == "### Nüfus tablosu":
            for r in parse_table(map_lines, i + 1):
                pid = r.pop("il")
                if pid not in prov_ids:
                    err("GD 05 Nüfus", f"unknown il '{pid}'")
                row = {}
                for g, v in r.items():
                    v = v.strip()
                    if v:
                        try:
                            row[g] = float(v)
                        except ValueError:
                            err("GD 05 Nüfus", f"{pid}/{g}: '{v}' is not a number")
                population[pid] = row
        elif s == "## Kişiler haritada":
            figure_rows = parse_table(map_lines, i + 1)
    gids = {g["id"] for g in pop_groups}
    for pid, row in population.items():
        for g in row:
            if g not in gids:
                err("GD 05 Nüfus", f"{pid}: unknown group column '{g}'")
    POP["groups"] = {g["id"]: g for g in pop_groups}
    POP["provinces"] = set(population)
    POP["regions"] = defaultdict(list)
    for p in provinces:
        if p["id"] in population and p["region"]:
            POP["regions"][tr_lower(p["region"])].append(p["id"])
    nation_codes = set()
    for path in gd_files:
        nation_codes |= set(re.findall(r"`devlet:\s*([A-Z]{2})`", open(path, encoding="utf-8").read()))
    for p in provinces:
        for layer in ("own", "ctl"):
            if p[layer] not in nation_codes:
                err("GD 05", f"province {p['id']}: unknown nation '{p[layer]}'")
    world_read, world_set = defaultdict(list), defaultdict(list)

    def parse_cond(where, text):
        try:
            p = Parser(text, resolve, world_values, prov_ids, nation_codes)
            node = p.parse()
            for kv in p.world_read:
                world_read[kv].append(where)
            return node, p.flags
        except CondError as e:
            err(where, f"condition '{text}': {e}")
            return None, set()

    def compile_text(where, raw, ev_id=None):
        """Markdown paragraph → plain BBCode string, or {cond, parts} when it has [eğer: …] / {eğer …} variants."""
        cond = None
        m = IF_PREFIX.match(raw)
        if m:
            cond, fl = parse_cond(where, m.group(1))
            for f in fl:
                flags_read[f].append(ev_id or where)
            raw = raw[m.end():]
        parts, pos = [], 0
        for im in IF_INLINE.finditer(raw):
            if im.start() > pos:
                parts.append(to_bbcode(raw[pos:im.start()], codex_refs))
            c, fl = parse_cond(where, im.group(1))
            for f in fl:
                flags_read[f].append(ev_id or where)
            parts.append({"cond": c, "a": to_bbcode(im.group(2), codex_refs),
                          "b": to_bbcode(im.group(3) or "", codex_refs)})
            pos = im.end()
        if pos < len(raw):
            parts.append(to_bbcode(raw[pos:], codex_refs))
        if cond is None and all(isinstance(x, str) for x in parts):
            return "".join(parts)
        return {"cond": cond, "parts": parts}

    events, persons, nations, endings, landmarks = [], {}, {}, {}, {}
    fronts = {}
    flags_set, flags_read = defaultdict(list), defaultdict(list)
    queued = defaultdict(list)
    codex_refs = set()
    used_images = {}

    def image(where, name):
        if not name:
            return None
        src = os.path.join(IMG_SRC, name)
        if not os.path.exists(src):
            warn(where, f"image not found (placeholder used): {name}")
            return None
        base, ext = os.path.splitext(name)
        safe = re.sub(r"[^A-Za-z0-9]+", "_", base).strip("_")[:60] or "img"
        safe = f"{safe}_{hashlib.md5(name.encode('utf-8')).hexdigest()[:6]}{'.png' if ext.lower() == '.png' else '.jpg'}"
        used_images[name] = safe
        return "res://game/assets/images/" + safe

    for path in gd_files:
        fname = os.path.splitext(os.path.basename(path))[0]
        text = open(path, encoding="utf-8").read()
        # every link in the file must resolve (code blocks excluded, as in tools/check_links.py)
        clean = re.sub(r"```.*?```", "", text, flags=re.S)
        clean = re.sub(r"`[^`\n]*`", "", clean)
        for m in LINK.finditer(clean):
            target = m.group(1).strip() or fname
            check_link(fname, target, m.group(2))

        for header, lines, line_no in blocks(path):
            if header is None:
                continue
            where = f"{fname}:{line_no}"
            # first non-empty line must be the field line
            body = list(lines)
            while body and not body[0].strip():
                body.pop(0)
            if not body or not is_field_line(body[0]):
                continue  # a plain ### heading (documentation), not a data block
            fields, tags = parse_fields(body.pop(0))
            cond_src, etki_src = None, []
            while body and is_field_line(body[0]) and ("koşul:" in body[0] or "etki:" in body[0]):
                line0 = body.pop(0)
                f2, _ = parse_fields(line0)
                cond_src = f2.get("koşul", cond_src)
                # every `etki: …` segment is kept (several lines allow `etki: eğer cond: …` groups)
                etki_src += [seg.partition(":")[2].strip() for seg in FIELD.findall(line0)
                             if seg.strip().startswith("etki:")]

            # ---- person / nation / ending blocks
            if "kişi" in fields and "id" not in fields:
                title = header.split("·", 1)[-1].strip()
                para = " ".join(l.strip() for l in body if l.strip() and not l.startswith(">"))
                srcs = [l.strip()[1:].strip() for l in body if l.startswith(">")]
                persons[fields["kişi"]] = {"id": fields["kişi"], "name": title, "title": fields.get("unvan", title),
                                           "role": fields.get("rol", ""), "image": image(where, fields.get("görsel")),
                                           "text": to_bbcode(para, codex_refs),
                                           "sources": [to_bbcode(s) for s in srcs]}
                continue
            if "devlet" in fields:
                title = header.split("·", 1)[-1].strip()
                para = " ".join(l.strip() for l in body if l.strip() and not l.startswith(">"))
                pos = [float(x) for x in fields.get("konum", "0.5,0.5").split(",")]
                nations[fields["devlet"]] = {"id": fields["devlet"], "name": fields.get("ad", title),
                                             "short": title, "pos": pos, "text": to_bbcode(para, codex_refs),
                                             "image": image(where, fields.get("görsel"))}
                continue
            if "cephe" in fields and "id" not in fields:
                title = header.split("·", 1)[-1].strip()
                para = " ".join(l.strip() for l in body if l.strip() and not l.startswith(">"))
                srcs = [l.strip()[1:].strip() for l in body if l.startswith(">")]
                fid = fields["cephe"]
                fcond = None
                if cond_src:
                    fcond, fl = parse_cond(where, cond_src)
                    for f in fl:
                        flags_read[f].append("cephe " + fid)
                try:
                    lon, lat = [float(x) for x in fields.get("konum", "").split(",")]
                except ValueError:
                    err(where, f"cephe {fid}: konum must be 'lon,lat'")
                    lon, lat = 0.0, 0.0
                val = resolve(fields.get("değer", ""))
                if val is None:
                    err(where, f"cephe {fid}: değer must be a resource")
                strength = [resolve(x.strip()) for x in fields.get("güç", "harbiye").split(",")]
                if None in strength:
                    err(where, f"cephe {fid}: unknown güç value")
                sm = re.fullmatch(r"(\d{4})-(\d{2})", fields.get("başlangıç", ""))
                if not sm:
                    err(where, f"cephe {fid}: başlangıç must be YYYY-MM")
                fronts[fid] = {"id": fid, "name": title, "war": fields.get("harp", ""), "value": val,
                               "enemy": fields.get("düşman", ""), "lonlat": [lon, lat], "cond": fcond,
                               "start": {"y": int(sm.group(1)), "m": int(sm.group(2))} if sm else {"y": 0, "m": 1},
                               "strength": [x for x in strength if x], "opposition": int(fields.get("karşı", "45")),
                               "win": int(fields.get("zafer", "70")), "lose": int(fields.get("yenilgi", "25")),
                               "provinces": [x.strip() for x in fields.get("iller", "").split(",") if x.strip()],
                               "border": [x.strip() for x in fields.get("sınır", "").split(",") if x.strip()],
                               "results": [x.strip() for x in fields.get("sonuç", "").split(",") if x.strip()],
                               "text": to_bbcode(para, codex_refs), "sources": [to_bbcode(x) for x in srcs],
                               "_where": where}
                continue
            if "yer" in fields and "id" not in fields:
                title = header.split("·", 1)[-1].strip()
                para = " ".join(l.strip() for l in body if l.strip() and not l.startswith(">"))
                srcs = [l.strip()[1:].strip() for l in body if l.startswith(">")]
                try:
                    lon, lat = [float(x) for x in fields.get("konum", "").split(",")]
                except ValueError:
                    err(where, f"yer {fields['yer']}: konum must be 'lon,lat'")
                    lon, lat = 0.0, 0.0
                landmarks[fields["yer"]] = {"id": fields["yer"], "name": title, "province": fields.get("il", ""),
                                            "nation": fields.get("bayrak", "OS"), "lonlat": [lon, lat],
                                            "icon": fields.get("simge", "yer"),
                                            "image": image(where, fields.get("görsel")),
                                            "text": to_bbcode(para, codex_refs),
                                            "sources": [to_bbcode(x) for x in srcs]}
                continue
            if "son" in fields and "id" not in fields:
                title = header.split("·", 1)[-1].strip()
                paras, srcs = [], []
                for l in body:
                    s = l.strip()
                    if not s:
                        continue
                    if s.startswith("**Nasıl gelinir") or s.startswith("#"):
                        break
                    (srcs if s.startswith(">") else paras).append(s.lstrip("> ").strip())
                endings[fields["son"]] = {"id": fields["son"], "title": title, "alternative": "alternatif" in tags,
                                          "image": image(where, fields.get("görsel")),
                                          "text": [to_bbcode(p, codex_refs) for p in paras],
                                          "sources": [to_bbcode(s) for s in srcs]}
                continue
            if "id" not in fields:
                continue

            # ---- event block
            m = EVENT_TITLE.match(header)
            if not m:
                err(where, f"event header must be '### YYYY[-MM[-DD]] · Title', got '{header}'")
                continue
            y, mo, d, title = m.groups()
            ev_id = fields["id"]
            kind_parts = [p.strip() for p in fields.get("tür", "zorunlu").split("·")]
            kind = next((p for p in kind_parts if p in KINDS), None)
            etags = {p for p in kind_parts if p in TAGS} | (tags & TAGS)
            for p in kind_parts:
                if p not in KINDS and p not in TAGS:
                    err(where, f"unknown tür '{p}'")
            if kind is None:
                err(where, f"missing tür for {ev_id}")
                kind = "zorunlu"
            if not re.fullmatch(r"[a-z0-9_]+", ev_id):
                err(where, f"id must be lowercase ASCII: '{ev_id}'")
            cond = None
            if cond_src:
                cond, fl = parse_cond(where, cond_src)
                for f in fl:
                    flags_read[f].append(ev_id)
            nation = fields.get("bayrak", "OS")
            ev = {"id": ev_id, "file": fname, "line": line_no,
                  "date": {"y": int(y), "m": int(mo or 1), "d": int(d or 1)},
                  "title": title.strip(), "kind": kind, "tags": sorted(etags), "nation": nation,
                  "image": image(where, fields.get("görsel")), "rank": fields.get("sıra"),
                  "until": fields.get("bitiş"), "ending": fields.get("son"), "cond": cond,
                  "cond_src": cond_src, "slot": fields.get("yuva"), "thread": fields.get("iplik"),
                  "place": fields.get("yer"), "text": [], "advice": [], "sources": [], "quotes": [], "options": []}
            if ev["until"]:
                mm = re.fullmatch(r"(\d{4})(?:-(\d{2}))?", ev["until"])
                if not mm:
                    err(where, f"bitiş must be YYYY or YYYY-MM: {ev['until']}")
                    ev["until"] = None
                else:
                    ev["until"] = {"y": int(mm.group(1)), "m": int(mm.group(2) or 12)}
            para = []
            cur_opt = None
            for raw in body:
                s = raw.strip()
                if not s:
                    if para:
                        ev["text"].append(compile_text(where, " ".join(para), ev_id))
                        para = []
                    continue
                om = OPTION.match(raw)
                if om:
                    if para:
                        ev["text"].append(compile_text(where, " ".join(para), ev_id))
                        para = []
                    cur_opt = parse_option(where, ev_id, om, parse_cond, resolve, flags_set, flags_read, queued,
                                           display, visible, codex_refs, compile_text, world_values, prov_ids,
                                           nation_codes, world_set)
                    ev["options"].append(cur_opt)
                    continue
                if cur_opt is not None and raw.startswith("   ") and not s.startswith(">"):
                    cur_opt["_out_raw"] = (cur_opt.get("_out_raw", "") + " " + s).strip()
                    cur_opt["outcome"] = compile_text(where, cur_opt["_out_raw"], ev_id)
                    continue
                am = ADVICE.match(s)
                if am:
                    seat = tr_lower(am.group(2).strip())
                    acond = None
                    if am.group(1):
                        acond, fl = parse_cond(where, am.group(1))
                        for f in fl:
                            flags_read[f].append(ev_id)
                    ev["advice"].append({"seat": SEATS.get(seat, am.group(2).strip()), "cond": acond,
                                         "text": compile_text(where, am.group(3).strip().strip('"“”'), ev_id)})
                    continue
                if s.startswith(">"):
                    q = s[1:].strip()
                    if q.startswith("Kaynak:"):
                        ev["sources"].append(to_bbcode(q[len("Kaynak:"):].strip()))
                        ev.setdefault("_src_raw", []).append(q)
                    elif q[:1] in "“\"":
                        ev["quotes"].append(q.strip("“”\""))
                        ev["sources"].append("“" + q.strip("“”\"") + "”")
                    elif q.startswith("—"):
                        ev["sources"].append(to_bbcode(q))
                        ev.setdefault("_src_raw", []).append(q)
                    else:
                        ev["sources"].append(to_bbcode(q))
                    continue
                if s.startswith("#"):
                    continue
                para.append(s)
            if para:
                ev["text"].append(compile_text(where, " ".join(para), ev_id))
            for o in ev["options"]:
                o.pop("_out_raw", None)
            if etki_src:
                # `etki:` applies to every option of the event (a treaty's map changes, whatever is answered)
                if not ev["options"]:
                    ev["options"].append({"label": "Devam.", "cond": None, "lock": None, "hint": None, "effects": [],
                                          "outcome": "", "alt": False})
                common = parse_effects(where, ev_id, etki_src, resolve, parse_cond, flags_set, flags_read, queued,
                                       world_values, prov_ids, nation_codes, world_set)
                for o in ev["options"]:
                    o["effects"] = common + o["effects"]
            if kind in PLAYABLE and not ev["options"]:
                ev["options"].append({"label": "Devam.", "cond": None, "lock": None, "hint": None, "effects": [],
                                      "outcome": "", "alt": False})
            if kind == "karar" and not ev["place"]:
                err(where, f"karar '{ev_id}' needs a yer: field")
            events.append(ev)

    # ---- population groups' power and conditions; figures on the map
    for g in pop_groups:
        where = "GD 05 Nüfus grupları"
        if g["power"] in ("-", ""):
            g["power"] = None
        else:
            rid = resolve(g["power"])
            if rid is None:
                err(where, f"{g['id']}: Güç '{g['power']}' is not a resource")
            g["power"] = rid
        for key, out in (("_press", "press"), ("_revolt", "revolt")):
            src = g.pop(key).strip()
            g[out] = None
            if src and src != "-":
                g[out], fl = parse_cond(where, src)
                for f in fl:
                    flags_read[f].append("nüfus " + g["id"])
    figures = []
    for r in figure_rows:
        where = "GD 05 Kişiler haritada"
        pid = r.get("Kişi", "")
        if pid not in persons:
            err(where, f"unknown person '{pid}'")
        span = []
        for col in ("Başlangıç", "Bitiş"):
            mm = re.fullmatch(r"(\d{4})-(\d{2})", r.get(col, ""))
            if not mm:
                err(where, f"{pid}: {col} must be YYYY-MM")
                span.append(0)
            else:
                span.append(int(mm.group(1)) * 12 + int(mm.group(2)) - 1)
        place = r.get("Yer", "").strip()
        fig = {"person": pid, "from": span[0], "to": span[1], "place": "", "label": "", "lonlat": [0.0, 0.0],
               "cond": None, "source": to_bbcode(r.get("Dayanak", "").replace("\\|", "|"))}
        if "@" in place:
            label, _, ll = place.partition("@")
            try:
                fig["lonlat"] = [float(x) for x in ll.split(",")]
            except ValueError:
                err(where, f"{pid}: '{place}' must be 'Ad @ lon,lat'")
            fig["label"] = label.strip()
        elif place in landmarks:
            fig["place"] = place
            fig["label"] = landmarks[place]["name"]
            fig["lonlat"] = landmarks[place]["lonlat"]
        else:
            err(where, f"{pid}: unknown yer '{place}'")
        c = r.get("Koşul", "-").strip()
        if c and c != "-":
            fig["cond"], fl = parse_cond(where, c)
            for f in fl:
                flags_read[f].append("kişi " + pid)
        figures.append(fig)

    # ---- cross checks
    ids = defaultdict(list)
    for ev in events:
        ids[ev["id"]].append(f"{ev['file']}:{ev['line']}")
    for i, where in ids.items():
        if len(where) > 1:
            err(where[0], f"duplicate id '{i}' (also {', '.join(where[1:])})")
    for ev in events:
        where = f"{ev['file']}:{ev['line']}"
        if ev["nation"] not in nations:
            err(where, f"unknown bayrak '{ev['nation']}'")
        if ev["kind"] == "epilog":
            if not ev["ending"] or ev["ending"] not in endings:
                err(where, f"epilog needs a valid son: '{ev['ending']}'")
        for opt in ev["options"]:
            for eff in flat_effects(opt["effects"]):
                if eff["t"] == "queue" and eff["id"] not in ids:
                    err(where, f"▶ unknown event '{eff['id']}'")
                if eff["t"] == "persona" and eff["id"] not in persons:
                    err(where, f"👤 unknown person '{eff['id']}'")
                if eff["t"] == "end" and eff["id"] not in endings:
                    err(where, f"☠ unknown ending '{eff['id']}'")
        if "zincir" in ev["tags"] and ev["id"] not in queued:
            warn(where, f"zincir event '{ev['id']}' is never queued with ▶")
        # quotes must appear on a page cited by this event
        pages = []
        for s in ev.get("_src_raw", []):
            for lm in LINK.finditer(s):
                if lm.group(2):
                    pages.append((lm.group(1).strip(), lm.group(2).strip()))
        for q in ev["quotes"]:
            if not pages:
                warn(where, f"quote without a page link: “{q[:50]}…”")
                continue
            best = max(fuzzy(q, page_text(b, p)) for b, p in pages)
            if best < 90:
                warn(where, f"quote not found on its cited page(s) (best {best:.0f}): “{q[:60]}…”")
        ev.pop("_src_raw", None)
        ev.pop("quotes", None)
    for row in cabinets:
        where = "GD 02:Kabineler"
        for col, role in (("Hükümdar", "hükümdar"), ("Maliye", "maliye"), ("Harbiye", "harbiye"), ("Bahriye", "bahriye")):
            pid = row.get(col, "")
            if pid not in persons:
                err(where, f"unknown person '{pid}' in column {col}")
            elif persons[pid]["role"] != role:
                warn(where, f"{pid} sits in {col} but has rol '{persons[pid]['role']}'")
        c = row.get("Koşul", "-").strip()
        row["cond"] = None
        if c and c != "-":
            row["cond"], fl = parse_cond(where, c)
            for f in fl:
                flags_read[f].append("kabine")
    for f, where in flags_read.items():
        if f not in flags_set:
            err(where[0], f"flag ⚑{f} is read but never set")
    for f, where in flags_set.items():
        if f not in flags_read:
            warn(where[0], f"flag ⚑{f} is set but never read")

    # ---- world state, slots, decisions, historical mode
    for w in world:
        sets = {v for (k, v) in world_set if k == w["id"]}
        if not sets:
            warn("GD 04", f"world key '{w['id']}' is never changed by any event")
        elif len(sets | {w["start"]}) < 2:
            warn("GD 04", f"world key '{w['id']}' can only reach one outcome")
        if not any(k == w["id"] for (k, _) in world_read):
            warn("GD 04", f"world key '{w['id']}' is never read (no text variant, slot or condition uses it)")
    for (k, v), where in world_set.items():
        if (k, v) not in world_read:
            warn(where[0], f"world value {k} = {v} is set but no later event reacts to it")
    slots = defaultdict(list)
    for ev in events:
        if ev["slot"]:
            slots[ev["slot"]].append(ev)
    for slot, evs in slots.items():
        if "alternatif" in evs[-1]["tags"]:
            err(f"{evs[-1]['file']}:{evs[-1]['line']}", f"yuva '{slot}': the last version must be the historical one")
        for e in evs[:-1]:
            if e["cond"] is None:
                err(f"{e['file']}:{e['line']}", f"yuva '{slot}': only the last (historical) version may be unconditional")
        for i, e in enumerate(evs):
            e["slot_rank"] = i
    hist_basis = defaultdict(int)
    for ev in events:
        if ev["kind"] in PLAYABLE + ("karar",) and "alternatif" not in ev["tags"]:
            if ev["options"] and all(o["alt"] for o in ev["options"]):
                err(f"{ev['file']}:{ev['line']}", f"{ev['id']}: every option is (alternatif); Tarihî mod would be stuck")
        for o in ev["options"]:
            o.setdefault("hist", None)
        if ev["kind"] in PLAYABLE and "alternatif" not in ev["tags"]:
            hs = [o for o in ev["options"] if o["hist"]]
            if len(ev["options"]) == 1 and not hs:
                ev["options"][0]["hist"] = "kasa"  # a single option ("Devam.") is what happened
                hs = ev["options"]
            if len(hs) != 1:
                err(f"{ev['file']}:{ev['line']}", f"{ev['id']}: needs exactly one (tarihî) option, has {len(hs)}")
            elif hs[0]["alt"]:
                err(f"{ev['file']}:{ev['line']}", f"{ev['id']}: the (tarihî) option cannot also be (alternatif)")
            else:
                hist_basis[hs[0]["hist"]] += 1
        if "alternatif" not in ev["tags"] and ev["kind"] in PLAYABLE + ("karar",):
            by_id = {e["id"]: e for e in events}
            for n, o in enumerate(ev["options"], 1):
                q = [x["id"] for x in flat_effects(o["effects"]) if x["t"] == "queue"]
                if not o["alt"] and q and all("alternatif" in by_id[x]["tags"] for x in q if x in by_id):
                    warn(f"{ev['file']}:{ev['line']}", f"{ev['id']} option {n} only leads to Alternatif tarih; "
                                                         "mark it (alternatif)")
        if ev["place"] and ev["place"] not in landmarks:
            err(f"{ev['file']}:{ev['line']}", f"unknown yer '{ev['place']}'")
    for lm in landmarks.values():
        if lm["province"] and lm["province"] not in prov_ids:
            err("GD 05", f"yer {lm['id']}: unknown il '{lm['province']}'")
    ev_ids = {e["id"] for e in events}
    for fr in fronts.values():
        where = fr.pop("_where")
        if fr["enemy"] not in nation_codes:
            err(where, f"cephe {fr['id']}: unknown düşman '{fr['enemy']}'")
        for p in fr["provinces"] + fr["border"]:
            if p not in prov_ids:
                err(where, f"cephe {fr['id']}: unknown il '{p}'")
        for r in fr["results"]:
            if r not in ev_ids:
                err(where, f"cephe {fr['id']}: unknown sonuç event '{r}'")
        if not fr["results"]:
            err(where, f"cephe {fr['id']}: needs sonuç events")

    # ---- codex from lore notes' Interesting details
    codex = {}
    for note in sorted(codex_refs):
        codex[note] = codex_entry(note)

    # ---- write
    os.makedirs(OUT_DATA, exist_ok=True)
    data = {"version": 2, "resources": resources, "persons": persons, "nations": nations, "endings": endings,
            "world": world, "provinces": provinces, "landmarks": landmarks, "fronts": fronts,
            "pop_groups": pop_groups, "population": population, "figures": figures,
            "cabinets": [{"from": r["Başlangıç"], "to": r["Bitiş"], "cond": r["cond"], "ruler": r["Hükümdar"],
                          "maliye": r["Maliye"], "harbiye": r["Harbiye"], "bahriye": r["Bahriye"]} for r in cabinets],
            "events": sorted(events, key=lambda e: (e["date"]["y"], e["date"]["m"], e["date"]["d"])),
            "codex": codex}
    with open(os.path.join(OUT_DATA, "events.json"), "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
    copy_images(used_images)

    # ---- report
    kinds = defaultdict(int)
    for ev in events:
        kinds[ev["kind"]] += 1
    years = sorted({ev["date"]["y"] for ev in events if ev["kind"] not in ("kural", "manşet", "epilog")})
    print(f"{len(events)} events ({', '.join(f'{k} {v}' for k, v in sorted(kinds.items()))})")
    print(f"{len(years)} years with events; {len(persons)} persons, {len(nations)} nations, {len(endings)} endings, "
          f"{len(codex)} codex entries, {len(used_images)} images")
    print(f"{len(flags_set)} flags set, {len(flags_read)} read; {len(world)} world keys, {len(provinces)} provinces, "
          f"{len(landmarks)} landmarks, {len(slots)} slots, {len(fronts)} fronts")
    pop_effects = sum(1 for e in events for o in e["options"] for x in flat_effects(o["effects"]) if x["t"] == "pop")
    total = sum(sum(r.values()) for r in population.values())
    print(f"population: {len(population)} provinces, {len(pop_groups)} groups, {total:.0f} thousand in 1873; "
          f"{pop_effects} 👥 effects; {len(figures)} figure rows")
    play = [e for e in events if e["kind"] in PLAYABLE]
    opts = [o for e in play for o in e["options"] if o["label"] != "Devam."]
    stat_only = sum(all(x["t"] in ("res", "set") for x in flat_effects(o["effects"])) for o in opts)
    reactive = sum(1 for e in play if e["slot"] or e["cond"] is not None or any(isinstance(t, dict) for t in e["text"]))
    print(f"Tarihî mod dayanakları: " + ", ".join(f"{k} {v}" for k, v in sorted(hist_basis.items())))
    print(f"branching: {stat_only}/{len(opts)} options only move numbers; {reactive}/{len(play)} events react to earlier choices")
    limit = None if "--warnings" in sys.argv else 60
    print(f"\n{len(errors)} errors")
    for e in errors:
        print("  ERROR", e)
    print(f"{len(warnings)} warnings")
    for w in warnings[:limit]:
        print("  warn ", w)
    if limit and len(warnings) > limit:
        print(f"  … {len(warnings) - limit} more (use --warnings)")
    return 1 if (check and errors) else 0


def parse_option(where, ev_id, om, parse_cond, resolve, flags_set, flags_read, queued, display, visible, codex_refs,
                 compile_text, world_values, prov_ids, nation_codes, world_set):
    label, rest = om.group(2).strip(), om.group(3)
    opt = {"label": to_bbcode(label, codex_refs), "cond": None, "lock": None, "hint": None, "effects": [], "outcome": "",
           "alt": False}
    if re.search(r"\(alternatif\)", rest):
        opt["alt"] = True
        rest = re.sub(r"\s*\(alternatif\)", "", rest)
    hm0 = re.search(r"\(tarihî(?::\s*(wiki|varsayım))?\)", rest)
    opt["hist"] = None
    if hm0:
        opt["hist"] = hm0.group(1) or "kasa"
        rest = rest[:hm0.start()] + rest[hm0.end():]
    cm = re.search(r"\[koşul:\s*(.+?)\]", rest)
    if cm:
        opt["cond"], fl = parse_cond(where, cm.group(1))
        for f in fl:
            flags_read[f].append(ev_id)
        if opt["cond"]:
            opt["lock"] = "Yeterli nüfuzunuz yok." if cond_hidden(opt["cond"], visible) \
                else cond_text(opt["cond"], display) + " gerekir."
        rest = rest[:cm.start()] + rest[cm.end():]
    hm = re.search(r"\(ipucu:\s*(.+?)\)", rest)
    if hm:
        opt["hint"] = to_bbcode(hm.group(1).strip(), codex_refs)
        rest = rest[:hm.start()] + rest[hm.end():]
    effects_src = FIELD.findall(rest)
    out = re.sub(r"`[^`]*`", "", rest)
    if "—" in out:
        opt["_out_raw"] = out.split("—", 1)[1].strip()
        opt["outcome"] = compile_text(where, opt["_out_raw"], ev_id)
    opt["effects"] = parse_effects(where, ev_id, effects_src, resolve, parse_cond, flags_set, flags_read, queued,
                                   world_values, prov_ids, nation_codes, world_set)
    return opt


def parse_effects(where, ev_id, segments, resolve, parse_cond, flags_set, flags_read, queued, world_values, prov_ids,
                  nation_codes, world_set):
    """Effect segments (the text between backticks) → effect list. `eğer cond: a · b` becomes one conditional effect."""
    out = []
    for seg in segments:
        seg = seg.strip()
        m = re.match(r"^eğer\s+(.+?):\s+(.+)$", seg)
        if m:
            cond, fl = parse_cond(where, m.group(1))
            for f in fl:
                flags_read[f].append(ev_id)
            inner = parse_effects(where, ev_id, [m.group(2)], resolve, parse_cond, flags_set, flags_read, queued,
                                  world_values, prov_ids, nation_codes, world_set)
            out.append({"t": "if", "cond": cond, "then": inner})
            continue
        for tok in [t.strip() for t in re.split(r"\s·\s|\s*;\s*", seg) if t.strip()]:
            eff = parse_effect(tok, resolve)
            if eff is None:
                err(where, f"cannot read effect '{tok}' in {ev_id}")
                continue
            if eff["t"] == "world":
                if eff["id"] not in world_values:
                    err(where, f"unknown world key '{eff['id']}' in {ev_id} (register it in GD 04)")
                elif eff["v"] not in world_values[eff["id"]]:
                    err(where, f"'{eff['v']}' is not a value of {eff['id']} in {ev_id}")
                world_set[(eff["id"], eff["v"])].append(where)
            if eff["t"] == "pop":
                if eff["g"] not in POP["groups"]:
                    err(where, f"unknown population group '{eff['g']}' in {ev_id} (GD 05 Nüfus grupları)")
                target = tr_lower(eff["to"])
                if target == "imparatorluk":
                    eff["to"] = ["*"]
                elif eff["to"] in POP["provinces"]:
                    eff["to"] = [eff["to"]]
                elif target in POP["regions"]:
                    eff["to"] = POP["regions"][target]
                else:
                    err(where, f"👥 target '@{eff['to']}' is not a province with population, a region or imparatorluk")
                    eff["to"] = []
            if eff["t"] == "prov":
                if eff["id"] not in prov_ids:
                    err(where, f"unknown province '{eff['id']}' in {ev_id} (register it in GD 05)")
                if eff["v"] not in nation_codes:
                    err(where, f"unknown nation '{eff['v']}' in {ev_id}")
            out.append(eff)
            if eff["t"] == "flag":
                (flags_set if eff["on"] else flags_read)[eff["name"]].append(ev_id)
            if eff["t"] == "queue":
                queued[eff["id"]].append(ev_id)
    return out


def flat_effects(effects):
    for e in effects:
        if e["t"] == "if":
            yield from flat_effects(e["then"])
        else:
            yield e


def parse_effect(tok, resolve):
    m = re.fullmatch(r"([+-])\s*(?:⚑\s*|f:)([\w]+)", tok)
    if m:
        return {"t": "flag", "name": m.group(2), "on": m.group(1) == "+"}
    m = re.fullmatch(r"(?:▶\s*|>)([a-z0-9_]+)(?:\s*\+\s*(\d+)\s*(ay|yıl|yil))?", tok)
    if m:
        eff = {"t": "queue", "id": m.group(1)}
        if m.group(2):
            eff["delay"] = int(m.group(2)) * (1 if m.group(3) == "ay" else 12)
        return eff
    m = re.fullmatch(r"(?:≡\s*|set:)([a-z0-9_]+)\s*=\s*([a-z0-9_]+)", tok)
    if m:
        return {"t": "world", "id": m.group(1), "v": m.group(2)}
    m = re.fullmatch(r"(?:🗺\s*|map:)([a-z0-9_]+)\s+(~?)([A-Z]{2})", tok)
    if m:
        return {"t": "prov", "id": m.group(1), "v": m.group(3), "own": m.group(2) != "~"}
    m = re.fullmatch(r"(?:👤\s*|@)([a-z0-9_]+)", tok)
    if m:
        return {"t": "persona", "id": m.group(1)}
    m = re.fullmatch(r"(?:👥\s*|pop:)([a-z_]+)\s+([+-−]\s*\d+(?:[.,]\d+)?)\s*(%?)(?:\s+@\s*(\S+))?", tok)
    if m:
        return {"t": "pop", "g": m.group(1), "d": float(m.group(2).replace("−", "-").replace(" ", "").replace(",", ".")),
                "pct": m.group(3) == "%", "to": m.group(4) or "imparatorluk"}
    m = re.fullmatch(r"(?:☠\s*|end:)([a-z0-9_]+)", tok)
    if m:
        return {"t": "end", "id": m.group(1)}
    m = re.fullmatch(r"([\wçğıöşüÇĞİÖŞÜ]+)\s*([+-−]\s*\d+)", tok)
    if m:
        rid = resolve(m.group(1))
        if rid is None:
            return None
        return {"t": "res", "id": rid, "d": int(m.group(2).replace("−", "-").replace(" ", ""))}
    m = re.fullmatch(r"([\wçğıöşüÇĞİÖŞÜ]+)\s*=\s*(\d+)", tok)
    if m:
        rid = resolve(m.group(1))
        if rid is None:
            return None
        return {"t": "set", "id": rid, "v": int(m.group(2))}
    return None


def fuzzy(q, page):
    from rapidfuzz import fuzz
    if not page:
        return 0.0
    qn = re.sub(r"\s+", " ", q).strip().lower()
    pn = re.sub(r"\s+", " ", page).lower()
    if qn in pn:
        return 100.0
    return fuzz.partial_ratio(qn, pn)


def codex_entry(note):
    path = FILES.get(note)
    text = open(path, encoding="utf-8").read()
    entry = {"title": note, "quotes": []}
    m = re.search(r"^## Interesting details\s*$(.*?)^## ", text, flags=re.S | re.M)
    if m:
        lines = m.group(1).split("\n")
        for i, line in enumerate(lines):
            s = line.strip()
            if s.startswith("> “") or s.startswith('> "'):
                attr = lines[i + 1].strip()[1:].strip() if i + 1 < len(lines) and lines[i + 1].strip().startswith("> —") else ""
                entry["quotes"].append({"text": s[1:].strip(), "source": to_bbcode(attr.lstrip("— ").strip())})
            if len(entry["quotes"]) >= 3:
                break
    return entry


def copy_images(used):
    os.makedirs(OUT_IMG, exist_ok=True)
    from PIL import Image
    credits = {}
    if os.path.exists(CREDITS_SRC):
        for line in open(CREDITS_SRC, encoding="utf-8"):
            if line.startswith("| ") and not line.startswith("| File"):
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if len(cells) >= 5:
                    credits[cells[0]] = cells
    rows = ["# Görsel kaynakları", "",
            "Bu görseller Wikimedia Commons / Wikipedia'dandır; kasa kaynağı değildir (⚠ Not from vault sources).", "",
            "| Dosya | Özgün ad | Yazar | Lisans | Kaynak |", "|---|---|---|---|---|"]
    for name, safe in sorted(used.items()):
        dst = os.path.join(OUT_IMG, safe)
        if not os.path.exists(dst):
            try:
                im = Image.open(os.path.join(IMG_SRC, name))
                im.thumbnail((MAX_IMG, MAX_IMG))
                if safe.endswith(".jpg"):
                    im.convert("RGB").save(dst, quality=85)
                else:
                    im.save(dst)
            except Exception as e:  # corrupt or unsupported file
                warn("images", f"could not convert {name}: {e}")
                continue
        c = credits.get(name)
        rows.append(f"| {safe} | {name} | {c[2] if c else '?'} | {c[3] if c else '?'} | {c[4] if c else '?'} |")
    open(os.path.join(OUT_IMG, "CREDITS.md"), "w", encoding="utf-8").write("\n".join(rows) + "\n")


if __name__ == "__main__":
    sys.exit(main())
