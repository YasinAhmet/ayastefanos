#!/bin/sh
# Re-OCR the books whose original OCR lost the Turkish letters.
cd "$(dirname "$0")/.."
for b in "Talat Paşa'nın Anıları" "Naciyem, Ruhum" "Şahbaba" "Türkiye'de Hükümetler" "Türk Halkbilimi" \
         "İttihadçı'nın Sandığı" "Plevne'de Bir Avustralyalı" "Trablusgarp Savaşı" \
         "Osmanlı'da Değişim ve Anayasal" "Bir Amerikan Diplomatının"; do
  py tools/ocr_pages.py "$b" --workers 5 2>&1 | grep --line-buffered -v "INFO"
done
echo ALL-OCR-DONE
