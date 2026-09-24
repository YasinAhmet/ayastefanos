#!/bin/sh
# Second OCR round: garbled pages of scanned books (from _garbled_pages.json).
cd "$(dirname "$0")/.."
py tools/ocr_pages.py "Arap İsyanı 1916-1918 (David Murphy)" --pages 2,4,6,19,38,49,53,71,74,75,77,79,80,81,87,89,90 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Atatürk Hakkında Hatıralar ve Belgeler (Afet İnan)" --pages 24,29,160,292,317,464,523,524,527,528,529,530 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Atatürk'le Beraber (Mazhar Müfit Kansu)" --pages 11,14,15 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Avrupa ve Biz (İlber Ortaylı)" --pages 144,196,200,205,223 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Avrupa'da Müslümanlar (Lucette Valensi)" --pages 2,12,21,25,33,37,43,45,47,49,51,54,55,56,57,58,60,61,62,63,64,66,67,68,70,74,76,78,79,80,82,84,90,91,99,101,103,105,107,109,111,119,131,134,135,145,148,149,150,158,162,164,165,166,168,170,180,182,187,190,191,194,197,198,200,202,204,206,212,215,216,222,228,237,241,261,263,265,277,281,282,286,309 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Balkan Harbi'nde Ulaştırma (Bülent Durgun)" --pages 25,154,202,203,229,279 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Balkan Savaşı Günlüğü (Gustav von Hochwächter)" --pages 34 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Bir Yedek Subayın Anıları (Faik Tonguç)" --pages 12 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Bu Defa Niçin Harp Edeceğimi Biliyorum (İbrahim Sorguç)" --pages 7,134,140,144,145,147,149,153,155 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Büyük Petro (Robert K. Massie)" --pages 550 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Cemal Paşa Hatıralar (Cemal Paşa)" --pages 435,436,457 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Cumhuriyet'in Çinli Misafirleri (Giray Fidan)" --pages 54,58,76,96,112,128,146,155,159 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Değişen İstanbul (Zeynep Çelik)" --pages 1,9,23,26,31,33,34,35,49,97,107,110,111,115,137,145,151,167,182,184,193,202,205,207,232 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Enver (Murat Bardakçı)" --pages 3,7,9,10,15,17,21,23,25,27,29,31,32,37,39,41,43,45,47,51,53,54,55,57,59,61,63,64,67,69,71,73,76,79,80,81,83,86,87,89,91,93,95,96,97,103,104,105,106,107,108,109,111,112,113,115,116,117,119,121,123,125,126,127,129,130,131,132,133,135,137,139,141,142,143,144,145,147,149,151,152,153,154,155,157,159,163,165,167,169,170,171,173,174,175,177,179,181,183,185,187,188,189,191,192,193,195,196,197,198,199,200,201,202,203,205,206,207,209,210,211,213,215,217,219,220,221,223,224,225,227,228,229,230,231,232,233,234,235,237,239,241,243,245,247,249,250,251,253,254,255,256,257,258,259,260,261,262,263,265,267,269,271,273,274,275,276,277,279,280,281,283,284,285,287,289,293,294,295,296,297,299,301,302,303,304,305,306,307,308,309,310,311,312,314,315,317,318,319,320,321,323,325,326,329,333,335,336,337,339,341,342,343,344,345,346,347,348,349,350,351,353,357,359,363,368,369,370,371,374,375,381,382,383,384,385,386,387,388,390,391,392,393,395,397,399,400,401,411,413,415,417,419,421,423,425,427,429,431,433,435,437,445,447,449,451,453,457,459,461,462,465,469,471,477,479,481,483,489,491,497,499,503,517,519,520,530,531,534,537,539,541,545,548,549,551,555,559,562,563,565,566,569,570,578,579,580,581,583,584,588,590,591,593,597,598,604,607,608,609,613,614,615,616,617,618,620,621,622,624,634,637,638,639,641,642,644,645,667,678,679,681,694,699,704,705,706,707,709,714,715,719,722,723,724,725,726,727,730,732,734,735,738,743,749,750,752,784 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Hafız Hakkı Paşa'nın Sarıkamış Günlüğü (Hafız Hakkı Paşa)" --pages 119,123,124,143,165,173,176,179,180,181,182,184,185,186,188,189,191,193,198,201,202,206,211,215,216,217,218,219,220,221,222,224,228,231,232,234,235,236,237,240,241,242 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Halas (Mehmet Rauf)" --pages 11,185,273,274,276,277 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Irak Kralı I. Faysal (Ali A. Allawi)" --pages 44,92,213,255,324,542,620 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Kılıç Ali'nin Anıları (Kılıç Ali)" --pages 4,5,6,7,8,9,10,13,14,35,49,50,67,68,71,87,94,95,98,99,109,122,124,126,129,175,184,192,215,245,255,276,296,302,313,332,341,379,391,397,409,412,427,436,437,444,445,447,449,455,495,509,516,521,531,534,535,537,538,539,572,622,645,656,670,671,672,674,675,698,771,786 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Kırım Savaşı ve Osmanlılar (Candan Badem)" --pages 121,270,286 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Kızıltoprak Anıları (Nezih H. Neyzi)" --pages 26,40,44,48,50,51,59,66,68,70,80,83,84,86,87,89,90,94,106,120,125,131,133,142,152,162,169,187,200,209,210,221,238,250,252,253,254,259,289,311,332,354,355,375,393,395,397,418,420,423,424,425,426,427,428,429,430,431 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Osmanlı Ortadoğu'sunu Yeniden Düşünmek (Cem Emrence)" --pages 85,121 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Osmanlı Piyadesi 1914-1918 (David Nicolle)" --pages 6,9,10,51,63,66 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Osmanlı İmparatorluğu Tarihi (Robert Mantran)" --pages 19,101 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Son Osmanlılar (Murat Bardakçı)" --pages 171,177,178,179,183,192 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Sultanın Paşaları (Olivier Bouquet)" --pages 101,116,118,215,234,235,290,291,383,393,465,502 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Türkiye'de Beş Yıl (Liman von Sanders)" --pages 191,290,344,488 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Türkiye'de Milli İktisat (Zafer Toprak)" --pages 121,141,144,177,309,324,327,349,359,450,451,470,517 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Vatan Yahut Silistre (Namık Kemal)" --pages 2,5,79 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Zabit ve Kumandan ile Hasbihal (Mustafa Kemal)" --pages 8,10,14,74,75 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "Çariçe Katerina (Robert K. Massie)" --pages 17,369 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "İstanbul'da Ramazan (François Georgeon)" --pages 3,201 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "İstiklal Harbi ve Anadolu (Mehmet Turgut Argun)" --pages 1,12,49,58,146,202,204,244 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "İttihad ve Terakki Yargılamaları I (Erol Şadi Erdinç)" --pages 461 --workers 5 2>&1 | grep --line-buffered -v INFO
py tools/ocr_pages.py "İttihad ve Terakki Yargılamaları III (Erol Şadi Erdinç)" --pages 1035 --workers 5 2>&1 | grep --line-buffered -v INFO
echo GARBLED-OCR-DONE
