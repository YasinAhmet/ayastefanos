import sys, re, glob
sys.stdout.reconfigure(encoding='utf-8'); sys.path.insert(0,'tools')
from pdf_extract import extract
from ocr_fix import Corrector, load_lexicon
C = Corrector(*load_lexicon('tools/lexicon.json'))
def src(book):
    t=open(glob.glob('Lore/Converted/'+book+'*.md')[0],encoding='utf-8').read(3000)
    return 'Lore/'+re.search(r'^source_file:\s*"?(.*?)"?$',t,re.M).group(1)
book, mode, pages = sys.argv[1], sys.argv[2], [int(x) for x in sys.argv[3:]]
res, toc = extract(src(book))
for p in pages:
    print(f'===== p. {p}')
    for k,t in res[p-1]: print(f'[{k}] {C.fix_text(t, mode)[:700]}')
print('CHANGES:', ', '.join(f'{a}→{b}' for (a,b),n in C.log.most_common(150)))
