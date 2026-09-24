---
tags: [handbook, meta]
---
# Handbook

How to find things in this vault, answer questions from it, and add to it. Written mainly for Claude (the assistant working on this vault), but it works as a map for anyone. Back to [[Home]] · [[Rules]].

> [!important] Claude: read this first
> Whenever the user asks anything about the lore, the books or the vault, start here. Then follow [[Rules]] strictly. The short version:
> 1. **Only the books count.** Answer from `Converted/` and the notes built on it. The web is used only when the user explicitly asks, and anything from it is marked ⚠ *Not from vault sources*.
> 2. **Cite everything** with a book, an author, the author's side and a page link: `[[Book (Author)#p. N|Author, *Book*, p. N]]`.
> 3. **Name the side** when sources disagree ("According to the Turkish view (…)"; "the German view (Liman von Sanders)…").
> 4. **Fiction is never evidence.** The six novels and plays only feed [[Soul of the Age]].
> 5. **Say what the books do not say.** If a claim cannot be found, say so and say where you looked.

---

## 1. What is where

| Place | What it holds |
|---|---|
| [[Home]] | Entry point: periods, key notes, links to the ledgers |
| [[Rules]] | The rules every note follows (protocols, citations, structure) |
| [[Sources Ledger]] | Every book: author, side, date, what it covers |
| [[Timeline]] | Dated events, oldest first, each with its source |
| [[Soul of the Age]] | How 1873–1919 *felt*, from fiction only |
| `<period>/_Ledger <period>` | One line per note in that period folder, with source and page counts |
| `<period>/People`, `Places`, `Events`, `Factions and Institutions`, `Concepts` | The subject notes |
| `Converted/` | The full text of every book, one heading per page (`p. N`) or chunk (`loc. N`) |
| `Sources/` | One note per book (`Source - <Title>`), listing every note that uses it |
| `Attachments/Images/` | Wikipedia / Commons illustrations (⚠ not from vault sources). Credits: [[Image credits]] |
| `Raw/NormalTrust/` | The original book files (PDF, EPUB, MOBI, DjVu) |
| `Raw/MostTrusted/` | The 5 cleaned video transcripts (+ raw subtitles in `_Subtitles/`) |
| `Raw/_Duplicates/`, `Raw/Doubtful/` | Extra copies; empty |
| `Raw/Converted (original)/` | The converted books as they were before the 2026-09-24 cleanup (`.txt`) |
| `Raw/OCR corrections/` | Per book: every word the OCR corrector changed (`.tsv`) + `_page quality.tsv` |
| `Raw/_Snapshots/` | Zip of the whole vault before the cleanup |
| `../tools/` (outside the vault) | The Python scripts described in §6 |

**Periods:** 15th century and earlier · 16th · 17th · 18th · 19th (1800–1872) · **1873–1919 (core)** · 20th (1920–1999). A note sits in the period of its subject's main activity (anyone active in 1873–1919 goes there).

### Anatomy of a subject note
1. Front matter: `type`, `period`, `aliases` (search stems, e.g. `"Balkan Sava"`), `sources`, `mentions`, `tags`.
2. Header line: type, period, counts.
3. Lead image (if any) with ⚠ marker.
4. `## Summary`: a digest of the quotes, nothing more, with links.
5. `## Interesting details`: numbered, each with a quote, a link and the side.
6. `## Quotes and sources`: quotes grouped by the author's side (`### Turkish sources`, `### German sources`, …).
7. `## All mentions`: every page in every book that names the subject.
8. `## Images`: gallery (⚠ not from vault sources).
9. `## Related`: notes whose subjects share pages with this one.

### Anatomy of a converted book (`Converted/`)
- Front matter: `title`, `author`, `side`, `protocol`, `written`, `covers`, `source_file`, `location_unit`, `text_mode` (`turkish` / `ascii` / `english`: how the corrector treats it).
- `> [!info] Cleanup`: what was done to the text.
- `## Contents` (books with chapters) → `## Chapter` → `### p. N`. Books without chapters: `## p. N`.
- Paragraphs as in the book. `> ` lines are indented quotations in the book. `> [!note]+ Footnotes` holds the footnotes of that page. `> [!warning]` means the page is still hard to read: check the PDF.
- **`p. N` is the PDF page index, not the printed page number.** `loc. N` is a ~3,000-character chunk of an e-book or transcript.

---

## 2. Navigating in Obsidian

- **Quick switcher** (Ctrl+O): type a note name or an alias.
- **Search** (Ctrl+Shift+F). Useful operators:
  - `path:Converted "Sarıkamış"`: search only the books
  - `path:"1873-1919/People" Enver`: search one folder
  - `file:Enver`, `tag:#source`, `line:(Enver Sarıkamış)` (both words on one line), `section:(Enver Sarıkamış)` (same page section)
  - Turkish spellings vary: also try `Sarikamis`, `Sankamış`, circumflex forms (`Kâzım`/`Kazım`), old forms (`Mısır`/`Misir`).
- **Page links:** `[[Enver (Murat Bardakçı)#p. 146]]` opens the book at that page. Hover (with Ctrl) to preview it.
- **Outline** (right sidebar) shows a book's chapters and pages, or a note's sections.
- **Backlinks** show every note citing the open note or book page.
- **Graph view**: filter with `path:` to see one period.
- **Images:** `![[file.jpg|320]]` embeds at 320 px.

---

## 3. Answering a question (the research protocol)

1. **Find the subject note(s).** Check the file name and `aliases:`. Several notes may apply (a person, an event, a place). Read Summary → Interesting details → Quotes.
2. **Go to the books.** Open the pages listed under *All mentions*, and read around them (the page before and after), because a quote in a note is only a fragment.
3. **Search the books for more,** using every spelling variant:
   ```bash
   py tools/mentions.py "Enver Paşa"                         # all pages naming the note (name + aliases)
   py tools/mentions.py --terms "Allahüekber,Allahuekber"    # free terms
   py tools/mentions.py "Hafız Hakkı Paşa" --book Enver       # one book only
   ```
   or grep: `grep -n -i "sarıkamış" "Lore/Converted/Enver (Murat Bardakçı).md"`.
   To print one page: `awk '/^#+ p\. 141$/,/^#+ p\. 142$/' "Lore/Converted/<Book>.md"`.
4. **Check hard pages against the scan.** If a page has a `[!warning]`, or a quote matters word for word, render the PDF page and look at it:
   ```bash
   py -c "import pymupdf; d=pymupdf.open(r'Lore/Raw/NormalTrust/<file>.pdf'); d[141-1].get_pixmap(dpi=150).save('page.png')"
   ```
   (page `p. N` = index `N-1`). Then read `page.png`.
5. **Weigh the sources.** Who wrote it, when, from which side (see [[Sources Ledger]])? Memoirs defend their authors (Talat says he knew nothing of Sarıkamış; Hafız Hakkı blames Enver although he helped plan it). Later polemics can be campaigns (Şerif Bey's 1922 book, per Bardakçı). Say so.
6. **Write the answer:** a digest, then the evidence with links, then disagreements by side, then what the books do *not* cover. Answer in the user's language, keep the quotes in the original language.
7. **If the user asks for web sources:** use them only then, and label them ⚠ *Not from vault sources*, with URLs. Never add web information to notes without that marker.
8. **If the answer is worth keeping,** offer to add it to the relevant note(s) (quotes + links), following §5.

---

## 4. Adding a new source

1. **Put the file in `Raw/`.** Books go in `Raw/NormalTrust/`, cleaned transcripts in `Raw/MostTrusted/`. Check for duplicates (see [[Sources Ledger#Duplicates]]).
2. **Convert it:**
   ```bash
   py tools/new_book.py --file "Raw/NormalTrust/<file>.pdf" --title "<Title>" --author "<Author>" \
       --side Turkish --protocol historical --written "1920" --covers "1908 – 1918"
   ```
   - This creates `Converted/<Title> (<Author>).md` and `Sources/Source - <Title>.md`.
   - **Scanned PDF, or OCR without Turkish letters:** the script says so. Then run `py tools/ocr_pages.py "<Title>"` (GPU OCR, about 1.5 s per page) and `py tools/convert_book.py "<Title>"`.
   - **EPUB, MOBI or TXT:** split into `loc.` chunks automatically.
   - **DjVu:** not readable offline. Convert it to PDF first.
   - **Fiction:** use `--protocol fictional`. It may only feed [[Soul of the Age]].
3. **Check the text.**
   - Open a few pages.
   - Look at `Raw/OCR corrections/<Title>.tsv` for bad "corrections".
   - Look at `Raw/OCR corrections/_page quality.tsv` for pages that are still hard to read.
   - If it is a clean Turkish book, rebuild the word list so it helps future corrections: `py tools/build_lexicon.py`.
4. **Record it:**
   - Fill in the source note (side, dates).
   - Add a row to [[Sources Ledger]] (right period table, side counts).
5. **Mine it:**
   - `py tools/mentions.py --scan-book "<Title>"` lists every existing note the book mentions, with page counts.
   - For each note: add the pages to *All mentions* and the book to the counts (`sources`, `mentions` in the front matter and the ledger row).
   - Add the best quotes to *Quotes and sources* under the right side, and new facts to *Interesting details* and the *Summary*.
   - List the note in the source note's "Notes that use this source".
6. **New subjects:**
   - A person, place, event, faction or concept that recurs (roughly 10+ pages, or important to the story) gets its own note. Use the template in §5, in the right period folder.
   - Add it to that period's `_Ledger`, and link it from related notes.
7. **Timeline:** add dated events, each with its page link, in date order.
8. **Images for new notes:** add a line `Note name<TAB>English Wikipedia title` (or `tr:Türkçe başlık`, or `-`) to `tools/wiki/titles.tsv`, then run:
   ```bash
   py tools/wiki_images.py titles && py tools/wiki_images.py fetch-rest && py tools/wiki_images.py portraits && py tools/wiki_images.py download && py tools/wiki_images.py insert && py tools/wiki_images.py prune
   ```
9. **Check links:** `py tools/check_links.py`. It must report 0 broken links, except the Obsidian `Welcome` note.
10. **Log it:** add a dated line to §8 below.

---

## 5. Templates

**Subject note** (file name = the subject's usual name; Turkish names keep Turkish letters):
```markdown
---
type: person            # person | place | event | faction | concept
period: "1873-1919"
aliases: ["Stem1", "Stem2"]
sources: 0
mentions: 0
tags: [person, "1873-1919"]
---
# Name

> **Person** · Period: [[_Ledger 1873-1919|1873-1919]] · Found in **0** sources on **0** pages · [[Home]] · [[Timeline]]

## Summary

Digest of the quotes below, with [[links]] and (Author) attributions.

## Interesting details

1. One-line point.
   > “Quote in the original language.”
   > — [[Book (Author)#p. N|Author, *Book*, p. N]] · *Turkish source*

## Quotes and sources

### Turkish sources

**Author, *Book*** — [[Source - Book|about this source]]
- [[Book (Author)#p. N|p. N]] — “Quote.”

## All mentions

Every page where this subject is named. Each number links to that page in the converted book.

- **[[Book (Author)|Author, *Book*]]** (Turkish, 2 ps): [[Book (Author)#p. 1|1]] · [[Book (Author)#p. 5|5]]

## Related

- **People:** …
```
**Ledger row:** `| [[Name]] | One-sentence digest. | <sources> | <pages> |`
**Timeline line:** `- **1915-01-10**: What happened → [[Note]] · [[Book (Author)#p. N|Author, *Book*, p. N]]`
**Side labels:** Turkish (incl. Ottoman-era authors), German, British, American, French, Russian, Italian, Iraqi, Australian, … = the author's country.

---

## 6. Tools (`tools/`, run from the project root with `py`)

| Script | What it does |
|---|---|
| `new_book.py` | Adds a new source: converted text + source note (§4) |
| `convert_book.py "<Title>"` / `--all` | Rebuilds a book in `Converted/` from its source: paragraphs, footnotes, chapters, OCR repair, quality report. Never changes page numbers. Safe to re-run |
| `ocr_pages.py "<Title>" [--pages 1-20,45]` | OCRs PDF pages on the GPU (RapidOCR PP-OCRv5 Latin, DirectML) into `tools/ocr_cache/`; resumable |
| `ocr_fix.py` | The OCR corrector (used by the others). "light" mode fixes slips (Ankara'mn → Ankara'nın); "ascii" mode restores Turkish letters; `fix_ocr_text` adds vowel-harmony ı restoration for RapidOCR output |
| `build_lexicon.py` | Rebuilds `lexicon.json` (word counts from the clean books). `valid_words.txt` is a general Turkish word list (OpenSubtitles frequency list, hermitdave/FrequencyWords) |
| `mentions.py` | Finds pages naming a note or terms; `--scan-book` lists notes a book mentions |
| `check_links.py` | Verifies every `[[link]]` and `#heading` in the vault |
| `wiki_images.py titles/fetch-rest/portraits/download/insert/prune` | Maps notes to Wikipedia (`wiki/titles.tsv`); collects images and captions; `portraits` limits **People** notes to portraits of the person (Wikidata P18 + each article's infobox image; no tughras, graves, buildings, relatives); downloads to `Attachments/Images/` (gently: Wikimedia rate-limits per IP); inserts them and writes [[Image credits]]; `prune` deletes unused files |
| `refresh_quotes.py` | Re-syncs the quotes in notes with the cleaned book text |

Python 3.14 via the `py` launcher. Packages: `pymupdf`, `rapidfuzz`, `rapidocr`, `onnxruntime-directml`. The GPU is an RTX 3050 (DirectML). Godot ignores `Lore/` and `tools/` (`.gdignore`).

---

## 7. Known limits

- **Atatürk'ün Almanya ve Avusturya Gezileri** (DjVu) has no text. It needs a DjVu → PDF conversion, then `ocr_pages.py`.
- **Machine-corrected text is not perfect.**
  - Roughly 5% of the logged corrections are wrong (e.g. `PAŞANI → PAŞAM`).
  - Scans with blurred type (*Naciyem, Ruhum, Efendim*, *Şahbaba*) still have misread words.
  - Quote word for word only after checking the PDF (§3.4).
- **Born-digital PDFs with transliteration marks** (Allawi, Massie, Sanders…) can look "garbled" to the quality check but are fine. They were deliberately not OCR'd.
- **Wikipedia images** illustrate. They are never evidence, and their captions are Wikipedia's.

---

## 8. Maintenance log

- **2026-09-24:**
  - 73 converted books rebuilt into paragraphs (53 with a Contents list).
    - Two-column pages and two-page spreads are now read in order.
    - Running headers and page numbers removed.
  - About 94,000 OCR slips corrected and logged in `Raw/OCR corrections/`; the originals kept in `Raw/Converted (original)/`.
  - 5,333 scanned pages re-read with RapidOCR on the GPU: the ten books with letterless OCR, plus the garbled pages of 34 other scanned books.
  - 60 pages remain marked `[!warning]`.
  - About 10,900 quotes in the notes re-synced with the cleaned text. 452 could not be matched safely and were left as they were (listed in `Raw/OCR corrections/_quotes.tsv`).
  - Wikipedia/Commons images added to the notes, with [[Image credits]].
  - This handbook, `CLAUDE.md` and `tools/` created.
