-- Fetches the current selling price for a 100g gold bar from degussa.com

set pythonCode to "import re, urllib.request

url = 'https://degussa.com/de/header_navigation/preise/preisliste/'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as r:
    html = r.read().decode('utf-8')

m = re.search(
    r'100 g Degussa Goldbarren \\([^)]+\\)</div>.*?priceListBuy[^>]*>.*?</span>([^<]+)',
    html, re.DOTALL
)
if m:
    raw = m.group(1).strip()
    numeric = re.sub(r'[^\\d,.]', '', raw).replace('.', '').replace(',', '.')
    val = float(numeric)
    total = val * 5
    def fmt(n):
        s = f'{n:,.2f}'.replace(',', 'X').replace('.', ',').replace('X', '.')
        return s
    print(raw + '|' + fmt(total))
else:
    print('Nicht gefunden|Nicht gefunden')
"

set tmpFile to POSIX path of (path to temporary items folder) & "degussa_price.py"

set fileRef to open for access tmpFile with write permission
set eof of fileRef to 0
write pythonCode to fileRef
close access fileRef

try
    set output to do shell script "python3 " & quoted form of tmpFile
    do shell script "rm -f " & quoted form of tmpFile
    set preis1 to do shell script "echo " & quoted form of output & " | cut -d'|' -f1"
    set preis5 to do shell script "echo " & quoted form of output & " | cut -d'|' -f2"
    set ts to do shell script "date '+%d.%m.%Y %H:%M Uhr'"
    set msg to "Degussa Goldbarren 100g (gepragt)" & return & return & "Ankauf 1 Barren:  " & preis1 & return & "Ankauf 5 Barren:  " & preis5 & " EUR" & return & return & "Abgerufen am:  " & ts
    display dialog msg buttons {"OK"} default button "OK" with title "Goldpreis - Degussa"
on error errMsg
    do shell script "rm -f " & quoted form of tmpFile
    display dialog "Fehler:" & return & errMsg buttons {"OK"} default button "OK" with icon stop with title "Goldpreis - Fehler"
end try
