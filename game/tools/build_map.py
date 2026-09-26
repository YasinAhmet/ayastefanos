"""Build the province map (game/data/map/provinces.json + provinces.svg) from Natural Earth.

    python3 game/tools/build_map.py

Merges Natural Earth's public-domain admin-1 regions (1:10m) into the simplified 1878-1914
vilayets and neighbouring states listed in Lore/Game Design/GD 05 Harita ve Harpler.md
(table "## İller"). The borders are an approximation, not a source (⚠ Not from vault sources).

The Natural Earth file is downloaded once into game/tools/.cache/ (not committed).
Needs: shapely.
"""
import json
import math
import os
import re
import sys
import urllib.request

from shapely.geometry import MultiPolygon, Polygon, box, mapping, shape
from shapely.ops import unary_union

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
CACHE = os.path.join(HERE, ".cache")
NE_URL = ("https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/"
          "ne_10m_admin_1_states_provinces.geojson")
NE_FILE = os.path.join(CACHE, "ne_10m_admin_1_states_provinces.geojson")
GD05 = os.path.join(ROOT, "Lore", "Game Design", "GD 05 Harita ve Harpler.md")
OUT = os.path.join(ROOT, "game", "data", "map")

BOUNDS = (5.0, 11.0, 63.0, 53.5)          # lon_min, lat_min, lon_max, lat_max
SIMPLIFY = 0.035                          # degrees
MIN_PART = 0.02                           # drop islands smaller than this (deg²) ...
MIN_PART_ISLES = 0.003                    # ... except in island provinces
ISLES = {"girit", "ege_adalari", "oniki_ada", "kibris", "yunanistan", "batum"}
REF_LAT = 38.0                            # equirectangular projection's standard parallel

# Whole countries (by adm0_a3) → province. "-" means neutral land (drawn, not owned by anyone in the game).
COUNTRY = {
    "ARM": "kafkasya", "AZE": "kafkasya", "CYP": "kibris", "CYN": "kibris", "LBN": "beyrut", "JOR": "suriye",
    "PSX": "kudus", "KWT": "kuveyt", "QAT": "lahsa", "BHR": "umman", "ARE": "umman", "OMN": "umman",
    "IRN": "iran", "TKM": "rusya", "UZB": "rusya", "KAZ": "rusya", "RUS": "rusya", "BLR": "rusya", "LTU": "rusya",
    "MDA": "rusya", "EGY": "misir", "SDN": "misir", "SDS": "-", "LBY": "trablusgarp", "TUN": "tunus",
    "DZA": "cezayir", "ITA": "italya", "SMR": "italya", "VAT": "italya", "MLT": "-", "FRA": "fransa",
    "MCO": "fransa", "CHE": "-", "LIE": "-", "DEU": "almanya", "AUT": "avusturya", "CZE": "avusturya",
    "SVK": "avusturya", "HUN": "avusturya", "SVN": "avusturya", "HRV": "avusturya", "BIH": "bosna",
    "MNE": "karadag", "KOS": "kosova", "AFG": "-", "PAK": "-", "TJK": "rusya", "KGZ": "rusya", "TCD": "-",
    "NER": "-", "MLI": "-", "ERI": "-", "ETH": "-", "DJI": "-", "SOM": "-", "SOL": "-", "LVA": "rusya",
    "EST": "rusya", "NLD": "-", "BEL": "-", "LUX": "-", "DNK": "-", "SWE": "-", "IND": "-", "CHN": "-",
    "ESP": "-", "AND": "-", "NGA": "-", "CAF": "-", "CMR": "-", "ESB": "kibris", "WSB": "kibris", "KAB": "rusya",
}

TUR = {
    "istanbul": ["Istanbul", "Kocaeli", "Yalova"],
    "edirne": ["Edirne", "Kirklareli", "Tekirdag"],
    "hudavendigar": ["Bursa", "Balikesir", "Bilecik", "Kütahya", "Eskisehir", "Afyonkarahisar", "Çanakkale",
                     "Sakarya"],
    "aydin": ["Izmir", "Manisa", "Aydin", "Denizli", "Mugla", "Usak"],
    "konya": ["Konya", "Karaman", "Antalya", "Isparta", "Burdur", "Nigde", "Aksaray"],
    "ankara": ["Ankara", "Kinkkale", "Kirsehir", "Kayseri", "Yozgat", "Çorum", "Nevsehir"],
    "kastamonu": ["Kastamonu", "Sinop", "Çankiri", "Bolu", "Düzce", "Zinguldak", "Bartın", "Karabük"],
    "sivas": ["Sivas", "Tokat", "Amasya"],
    "trabzon": ["Trabzon", "Rize", "Giresun", "Ordu", "Samsun", "Gümüshane"],
    "erzurum": ["Erzurum", "Erzincan", "Bayburt", "Agri"],
    "kars": ["Kars", "Ardahan"],
    "batum": ["Artvin"],
    "kafkasya": ["Iğdir"],
    "van": ["Van", "Hakkari"],
    "bitlis": ["Bitlis", "Mus", "Siirt", "Bingöl"],
    "diyarbakir": ["Diyarbakir", "Mardin", "Batman", "Sirnak"],
    "mamuretulaziz": ["Elazig", "Malatya", "Tunceli", "Adiyaman"],
    "adana": ["Adana", "Mersin", "Osmaniye"],
    "halep": ["Gaziantep", "K. Maras", "Kilis", "Sanliurfa", "Hatay"],
}
BGR_RUMELI = {"Plovdiv", "Pazardzhik", "Stara Zagora", "Haskovo", "Sliven", "Yambol", "Burgas"}
BGR_EDIRNE = {"Kardzhali", "Smolyan"}
BGR_SELANIK = {"Blagoevgrad"}
ROU_AV = {"Satu Mare", "Arad", "Bihor", "Timis", "Caras-Severin", "Maramures", "Cluj", "Bistrita-Nasaud", "Salaj",
          "Hunedoara", "Covasna", "Brasov", "Sibiu", "Mures", "Harghita", "Alba", "Suceava"}
ROU_DOB = {"Tulcea", "Constanta"}
SRB_AV = {"Severno-Backi", "Zapadno-Backi", "Severno-Banatski", "Sremski", "Južno-Backi", "Srednje-Banatski",
          "Južno-Banatski"}
SRB_NIS = {"Pirotski", "Jablanicki", "Toplicki", "Nišavski", "Pcinjski"}
SRB_KOS = {"Raški"}
UKR_AV = {"L'viv", "Ivano-Frankivs'k", "Ternopil'", "Chernivtsi", "Transcarpathia"}
POL_AV = {"Lesser Poland", "Subcarpathian", "Małopolskie", "Podkarpackie"}
POL_DE = {"West Pomeranian", "Lubusz", "Lower Silesian", "Opole", "Silesian", "Greater Poland", "Pomeranian",
          "Kuyavian-Pomeranian", "Zachodniopomorskie", "Lubuskie", "Dolnośląskie", "Opolskie", "Śląskie",
          "Wielkopolskie", "Pomorskie", "Kujawsko-Pomorskie", "Warmian-Masurian", "Warmińsko-Mazurskie"}
SAU = {"Makkah": "hicaz", "Al Madinah": "hicaz", "Tabuk": "hicaz", "Al Bahah": "hicaz", "`Asir": "yemen",
       "Jizan": "yemen", "Najran": "yemen", "Ash Sharqiyah": "lahsa"}
YEM_ADEN = {"`Adan", "Lahij", "Abyan", "Shabwah", "Hadramawt", "Al Mahrah", "Al Dali'"}
SYR_HALEP = {"Aleppo", "Idlib", "Ar Raqqah", "Hasaka (Al Haksa)", "Dayr Az Zawr"}
SYR_BEYRUT = {"Lattakia", "Tartus"}
IRQ_MUSUL = {"Ninawa", "Dihok", "Arbil", "As-Sulaymaniyah", "At-Ta'mim"}
IRQ_BASRA = {"Al-Basrah", "Dhi-Qar", "Maysan", "Al-Muthannia"}
ISR_BEYRUT = {"Haifa", "HaZafon"}


def province_of(p, part_centroid):
    """Province id for one admin-1 feature (or one of its parts), '-' for neutral land, None to skip."""
    a3, name = p.get("adm0_a3"), p.get("name") or ""
    lon, lat = part_centroid
    if a3 == "TUR":
        for prov, names in TUR.items():
            if name in names:
                return prov
        return None
    if a3 == "GRC":
        if name == "Ipeiros":
            return "yanya"
        if name == "Thessalia":
            return "teselya"
        if name == "Dytiki Makedonia":
            return "manastir"
        if name in ("Kentriki Makedonia", "Ayion Oros"):
            return "selanik"
        if name == "Anatoliki Makedonia kai Thraki":
            return "edirne" if lon > 24.85 else "selanik"
        if name == "Kriti":
            return "girit"
        if name == "Voreio Aigaio":
            return "ege_adalari"
        if name == "Notio Aigaio":
            return "oniki_ada" if lon > 26.4 and lat < 37.6 else "yunanistan"
        return "yunanistan"
    if a3 == "BGR":
        if name in BGR_RUMELI:
            return "dogu_rumeli"
        if name in BGR_EDIRNE:
            return "edirne"
        if name in BGR_SELANIK:
            return "selanik"
        return "tuna"
    if a3 == "ROU":
        if name in ROU_AV:
            return "avusturya"
        if name in ROU_DOB:
            return "dobruca"
        return "romanya"
    if a3 == "SRB":
        if name in SRB_AV:
            return "avusturya"
        if name in SRB_NIS:
            return "nis"
        if name in SRB_KOS:
            return "kosova"
        return "sirbistan"
    if a3 == "MKD":
        return "kosova" if lat > 41.72 else "manastir"
    if a3 == "ALB":
        return "iskodra" if lat > 41.05 else "yanya"
    if a3 == "GEO":
        return "batum" if name == "Ajaria" else "kafkasya"
    if a3 == "UKR":
        return "avusturya" if name in UKR_AV else "rusya"
    if a3 == "POL":
        if name in POL_AV:
            return "avusturya"
        if name in POL_DE:
            return "almanya"
        return "rusya"
    if a3 == "SAU":
        return SAU.get(name, "necd")
    if a3 == "YEM":
        return "aden" if name in YEM_ADEN else "yemen"
    if a3 == "SYR":
        if name in SYR_HALEP:
            return "halep"
        if name in SYR_BEYRUT:
            return "beyrut"
        return "suriye"
    if a3 == "IRQ":
        if name in IRQ_MUSUL:
            return "musul"
        if name in IRQ_BASRA:
            return "basra"
        return "bagdat"
    if a3 == "ISR":
        return "beyrut" if name in ISR_BEYRUT else "kudus"
    return COUNTRY.get(a3)


def registry():
    rows, text = [], open(GD05, encoding="utf-8").read().split("\n")
    for i, line in enumerate(text):
        if line.strip() == "## İller":
            j = i + 1
            while j < len(text) and not text[j].startswith("|"):
                j += 1
            head = [c.strip() for c in text[j].strip().strip("|").split("|")]
            j += 2
            while j < len(text) and text[j].startswith("|"):
                rows.append(dict(zip(head, [c.strip() for c in text[j].strip().strip("|").split("|")])))
                j += 1
    return {r["id"]: r for r in rows}


def parts(geom):
    if geom.is_empty:
        return []
    if isinstance(geom, Polygon):
        return [geom]
    if isinstance(geom, MultiPolygon):
        return list(geom.geoms)
    return [g for g in getattr(geom, "geoms", []) if isinstance(g, Polygon)]


def main():
    if not os.path.exists(NE_FILE):
        os.makedirs(CACHE, exist_ok=True)
        print("downloading", NE_URL)
        urllib.request.urlretrieve(NE_URL, NE_FILE)
    reg = registry()
    frame = box(*BOUNDS)
    groups = {}
    unknown = set()
    for f in json.load(open(NE_FILE, encoding="utf-8"))["features"]:
        geom = shape(f["geometry"])
        if not geom.intersects(frame):
            continue
        for part in parts(geom.buffer(0)):
            if not part.intersects(frame):
                continue
            c = part.representative_point()
            prov = province_of(f["properties"], (c.x, c.y))
            if prov is None:
                unknown.add((f["properties"].get("adm0_a3"), f["properties"].get("name")))
                continue
            groups.setdefault(prov, []).append(part.intersection(frame))
    missing = [p for p in reg if p not in groups]
    extra = [p for p in groups if p != "-" and p not in reg]
    if unknown:
        print("unassigned regions (drawn nowhere):", sorted(unknown)[:40])
    if missing or extra:
        sys.exit(f"province mismatch with GD 05: missing geometry {missing}, not in GD 05 {extra}")

    out = {"bounds": list(BOUNDS), "ref_lat": REF_LAT, "provinces": {}, "neutral": []}
    for prov, geoms in sorted(groups.items()):
        merged = unary_union([g.buffer(0.004) for g in geoms]).buffer(-0.004)
        merged = merged.simplify(SIMPLIFY, preserve_topology=True)
        keep = [pp for pp in parts(merged)
                if pp.area >= (MIN_PART_ISLES if prov in ISLES else MIN_PART)]
        if not keep:
            keep = sorted(parts(merged), key=lambda g: -g.area)[:1]
        polys = [[[round(x, 3), round(y, 3)] for x, y in list(pp.exterior.coords)[:-1]] for pp in keep]
        if prov == "-":
            out["neutral"] += polys
            continue
        big = max(keep, key=lambda g: g.area)
        lp = big.representative_point()
        out["provinces"][prov] = {"polys": polys, "label": [round(lp.x, 3), round(lp.y, 3)],
                                  "area": round(sum(g.area for g in keep), 2)}
    # neighbours (for front lines)
    shapes = {p: unary_union([Polygon(pl) for pl in d["polys"]]).buffer(0.08) for p, d in out["provinces"].items()}
    for p, sh in shapes.items():
        out["provinces"][p]["neighbors"] = sorted(q for q, sh2 in shapes.items() if q != p and sh.intersects(sh2))
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "provinces.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, separators=(",", ":"))
    write_svg(out, reg)
    n = sum(len(pl) for d in out["provinces"].values() for pl in d["polys"])
    print(f"{len(out['provinces'])} provinces, {n} vertices → game/data/map/provinces.json, provinces.svg")


def project(lon, lat):
    k = math.cos(math.radians(REF_LAT))
    return (lon - BOUNDS[0]) * k, (BOUNDS[3] - lat)


def write_svg(out, reg):
    """The same map as an SVG, one <path id="…"> per province, for viewing and editing outside Godot."""
    scale = 22.0
    w, h = project(BOUNDS[2], BOUNDS[1])
    rows = [f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w * scale:.0f} {h * scale:.0f}" '
            f'style="background:#c9d3cf">',
            '<!-- Ayastefanos Utancı · il haritası · Natural Earth (kamu malı) sınırlarından sadeleştirildi -->']

    def d(polys):
        segs = []
        for pl in polys:
            pts = [project(x, y) for x, y in pl]
            segs.append("M" + " L".join(f"{x * scale:.1f},{y * scale:.1f}" for x, y in pts) + " Z")
        return " ".join(segs)
    rows.append(f'<path id="neutral" d="{d(out["neutral"])}" fill="#d8cfb8" stroke="#6b5a45" stroke-width="0.6"/>')
    for pid, data in out["provinces"].items():
        name = reg.get(pid, {}).get("Ad", pid)
        rows.append(f'<path id="{pid}" data-name="{name}" d="{d(data["polys"])}" fill="#e6d7b5" '
                    f'stroke="#4a3a2a" stroke-width="0.8"><title>{name}</title></path>')
    rows.append("</svg>")
    open(os.path.join(OUT, "provinces.svg"), "w", encoding="utf-8").write("\n".join(rows) + "\n")


if __name__ == "__main__":
    main()
