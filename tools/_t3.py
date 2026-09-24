import sys, re, glob
sys.stdout.reconfigure(encoding='utf-8'); sys.path.insert(0,'tools')
from pdf_extract import extract
from ocr_fix import Corrector, load_lexicon
C = Corrector(*load_lexicon('tools/lexicon.json'))
book, mode = sys.argv[1], sys.argv[2]
t=open(glob.glob('Lore/Converted/'+book+'*.md')[0],encoding='utf-8').read(3000)
res, toc = extract('Lore/'+re.search(r'^source_file:\s*"?(.*?)"?$',t,re.M).group(1))
tot=0
for pg in res:
    for k,x in pg:
        C.fix_text(x, mode); tot+=len(x.split())
print(tot,'words', sum(C.log.values()),'changes', len(C.log),'distinct')
print(' | '.join(f'{a}→{b} {n}' for (a,b),n in C.log.most_common(int(sys.argv[3]) if len(sys.argv)>3 else 250)))
