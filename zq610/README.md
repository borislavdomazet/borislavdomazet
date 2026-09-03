# ZQ610 kalibracija (ZPL)

CPCL na ZQ610 štampa OK bez kalibracije dužine. ZPL koristi izmjerenu dužinu naljepnice.
Ako ZPL odštampa zadanu naljepnicu pa izbaci još praznih, printer traži gap/mark sa pogrešnim
senzorom ili pogrešnom dužinom. Zebra to rješava slanjem jednog txt fajla na printer.

Zvanični članak: https://support.zebra.com/article/ZQ610-and-ZQ620-Media-Calibration

Isti simptom (jedna dobra, pa prazne): https://support.zebra.com/article/000026219

## Koji fajl slati

- `calibrate-gap.txt` — die-cut naljepnice sa razmakom (gap/notch). Ovo je najčešće.
- `calibrate-black-mark.txt` — crna crta (black mark) na poleđini.
- `calibrate-journal.txt` — continuous/receipt, bez gapa.
- `query-settings.txt` — samo čita trenutne postavke (odgovor stiže kroz ZSU komunikaciju).

Ključna ZPL linija u svakom kalibracionom fajlu:

    ~jc^xa^jus^xz

`~jc` izmjeri dužinu, `^JUS` snimi u printer. CPCL ovu kalibraciju ne treba.

## Kako poslati

1. Ubaci medij, zatvori poklopac.
2. Zebra Setup Utilities → Open Communication With Printer
   (ili pošalji raw fajl preko USB/Bluetooth, bez Windows spooler-a).
3. Pošalji sadržaj odgovarajućeg `calibrate-*.txt` fajla.
4. Printer će izbaciti nekoliko naljepnica dok kalibriše.
5. Ugasi printer i upali ga ponovo.
6. Feed dugme mora izbaciti tačno jednu naljepnicu.

Ne slati preko običnog Windows print dijaloga — može ubaciti form-feed (0x0C),
a mobilni Zebra printer to tretira kao prazan feed. Samo raw komande.

## Ako i posle kalibracije ZPL izbacuje prazne

Provjeri ZPL stream: ne smije imati extra `^XZ`, form-feed (0x0C), ni spooler header.
Mobilni printeri reaguju na te karaktere, desktop Zebra ih ignoriše.
