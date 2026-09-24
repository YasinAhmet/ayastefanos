import sys, re, glob
sys.stdout.reconfigure(encoding='utf-8'); sys.path.insert(0,'tools')
from pdf_extract import extract
def src(book):
    t=open(glob.glob('Lore/Converted/'+book+'*.md')[0],encoding='utf-8').read(3000)
    return 'Lore/'+re.search(r'^source_file:\s*"?(.*?)"?$',t,re.M).group(1)
book, pages = sys.argv[1], [int(x) for x in sys.argv[2:]]
res, toc = extract(src(book))
print('TOC', toc[:8])
for p in pages:
    print(f'===== p. {p}')
    for k,t in res[p-1]: print(f'[{k}] {t[:600]}')
