cd "$(dirname "$0")/.."
while IFS= read -r b; do py tools/convert_book.py "$b"; done < tools/_nonascii_list.txt
echo CONVERT-DONE
