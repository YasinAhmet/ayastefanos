---
tags: [rules, meta]
---
# Rules

These are the rules this vault is built on. Every note follows them. Start at [[Home]].

## 1. Two protocols

### Fictional protocol
- Applies to **novels, plays and other fiction** in the library:
  - [[Vatan Yahut Silistre (Namık Kemal)]]
  - [[Şair Evlenmesi (Şinasi)]]
  - [[İntibah (Namık Kemal)]]
  - [[Turfanda mı Yoksa Turfa mı (Mizancı Murat)]]
  - [[Halas (Mehmet Rauf)]]
  - [[Allahın Süngüleri Reis Paşa (Attilâ İlhan)]]
- Information from these books is **never used as a source of fact**. It is never cited as evidence in a person, place, event or faction note.
- Fiction is used only to feed [[Soul of the Age]]: a note about **how it felt to live in 1873–1919**. That covers moods, manners, speech, money, streets, fears and hopes.
- When fiction is quoted there, it is always labelled as fiction.

### Historical protocol
- Applies to **all non-fiction books**: histories, memoirs, diaries, document collections, folklore studies.
- The 5 cleaned-up **video transcripts** in `Raw/MostTrusted/` also follow this protocol, but they are labelled as *video transcript (secondary)*.
- Every other note in the vault is built only from these sources.

## 2. Every piece of information has its source
- A note's description is a **digest**: a readable summary of the quotes found in the books, nothing more.
- Every note lists its references. That means quotes, with the book, the author, the author's side and the page (or location).
- Every citation links straight to the page in the converted book, for example `[[Türkiye'de Beş Yıl (Liman von Sanders)#p. 45]]`.
- **Location units:**
  - `p. N` is the page index of the **PDF file**, not the printed page number.
  - `loc. N` is a location in an e-book or transcript. E-books have no page numbers, so they are split into chunks of about 3,000 characters.
- Where sources disagree, the note says so and names the side: "According to the Turkish view (…)…", "According to the Russian view (…)…".
- **Side** means the author's country. Ottoman-era authors count as Turkish. See [[Sources Ledger]].
- **No web information.** Nothing in the vault comes from the internet. If a note ever contains something that is not in the books, it is marked `⚠ Not from vault sources` and explained.

## 3. Structure
- **Period folders:**
  - [[_Ledger 1873-1919|1873-1919]] is the core section.
  - Everything else is sorted by century:
    - [[_Ledger 15th Century and Earlier|15th Century and Earlier]]
    - [[_Ledger 16th Century|16th Century]]
    - [[_Ledger 17th Century|17th Century]]
    - [[_Ledger 18th Century|18th Century]]
    - [[_Ledger 19th Century (1800-1872)|19th Century (1800-1872)]]
    - [[_Ledger 20th Century (1920-1999)|20th Century (1920-1999)]]
- Inside each period folder, notes are grouped into `People`, `Places`, `Events`, `Factions` and `Concepts`.
- **Where a note goes:**
  - A person goes in the period of their main activity. Anyone active during 1873–1919 goes in `1873-1919`.
  - An event goes in the period when it happened.
  - A place or concept goes in the period where the books discuss it most.
- **Each period folder has a ledger** (`_Ledger …`) that explains every note inside it.
- **One subject, one note.** Writings about the same matter are gathered into a single shared note.
- **Every person** who appears often enough in the books gets their own note.

## 4. What every note contains
1. **Summary**: the digest, with links to related notes.
2. **Interesting details**: a numbered list, each with a quote and its source.
3. **Quotes and sources**: the selected quotes, grouped by the author's side.
4. **All mentions**: every page in every book where the subject appears, each one a link.
5. **Related**: links to the notes whose subjects appear on the same pages most often.

Links are only made to notes that exist.

## 5. Other parts of the vault
- **Converted:** `Converted/` holds every book converted to Markdown, with page headings you can link to. `Raw/` keeps the original files.
  - Since 2026-09-24 every book is laid out in **paragraphs**, with footnotes grouped in a callout under each page, indented quotations as blockquotes and chapter headings with a Contents list where the book has them. Page headings (`p. N`, `loc. N`) never change, so citations keep working.
  - OCR slips were machine-corrected. Every change is listed in `Raw/OCR corrections/<book>.tsv`. The texts as they were before the cleanup are in `Raw/Converted (original)/` (as `.txt`, so Obsidian does not mix them up with the real notes).
  - A page that is still hard to read carries a `[!warning]` callout: check the PDF before quoting it word for word.
- **Handbook:** [[Handbook]] explains how to navigate the vault, answer questions from it and add new sources.
- **Images:** `Attachments/Images/` holds illustrations from Wikipedia / Wikimedia Commons. They are ⚠ not from vault sources and never count as evidence. Credits are in [[Image credits]].
- **Timeline:** [[Timeline]] lists the dated events, each with its source.
- **Sources:** every book has a source note in `Sources/`. It shows the book's side and which notes cite it.
- **OCR books:**
  - Ten books had OCR text without Turkish letters (four of them made with the Windows English OCR engine). They were read again from the scans with RapidOCR (PP-OCRv5 Latin model), and the Turkish letters were restored by the corrector. Garbled pages of other scanned books were re-read the same way. Each converted file's `[!info] Cleanup` box says what was done to it.
  - One DjVu file could not be converted offline.
