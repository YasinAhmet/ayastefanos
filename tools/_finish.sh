cd "$(dirname "$0")/.."
until grep -q GARBLED-OCR-DONE tools/ocr_cache/queue2.log 2>/dev/null; do sleep 30; done
echo "== convert all $(date +%T)"
py tools/convert_book.py --all
echo "== refresh quotes $(date +%T)"
py tools/refresh_quotes.py
echo "== check links $(date +%T)"
py tools/check_links.py
echo "FINISH-DONE $(date +%T)"
