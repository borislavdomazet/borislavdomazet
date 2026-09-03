# ZQ610 kalibracija (ZPL)

CPCL na ZQ610 štampa OK bez kalibracije dužine. ZPL koristi izmjerenu dužinu naljepnice.
Ako ZPL odštampa zadanu naljepnicu pa izbaci još praznih, printer traži gap sa pogrešnom
dužinom. Rješenje je raw slanje ovog txt fajla (ne preko Windows Print dijaloga):

```
! U1 setvar "media.type" "label"
! U1 setvar "media.sense_mode" "gap"
~jc^xa^jus^xz
```

To je fajl `calibrate-gap.txt`. Zebra: https://support.zebra.com/article/ZQ610-and-ZQ620-Media-Calibration

## Kako poslati txt na printer

Najčešće se ovo radilo sa PC-a preko USB-a i **Zebra Setup Utilities**. ZQ610 koristi USB kabl
(printer strana je mini-USB). Driver i ZSU: https://www.zebra.com/us/en/support-downloads/software/printer-software/zebra-setup-utilities.html

### Način 1: Send File (ako šalješ sačuvani .txt)

1. Ubaci naljepnice, zatvori poklopac, uključi printer.
2. Spoji ZQ610 na PC USB kablom.
3. Otvori **Zebra Setup Utilities**, označi ZQ610 u listi.
4. **Open Printer Tools**.
5. Tab **Action** → **Send File**.
6. Izaberi `calibrate-gap.txt` → **Send**.

Na novijem ZDesigner drajveru (v8/v10): Printer properties → **Driver Settings** → **Send file**.

### Način 2: paste komandi (isti efekat, bez fajla)

1. U ZSU označi printer → **Open Communication with Printer**.
2. U gornji box zalijepi tri linije iz `calibrate-gap.txt`.
3. Svaka SGD linija mora imati Enter na kraju (CR/LF), inače printer ignoriše `setvar`.
4. **Send to Printer**.

### Posle slanja

1. Printer će sam izbaciti nekoliko naljepnica dok mjeri gap (`~jc`).
2. Ugasi printer i upali ga ponovo (`^JUS` je snimio postavke).
3. Feed dugme mora izbaciti **tačno jednu** naljepnicu. Ako i dalje ide više, pošalji fajl još jednom.

Ne koristiti običan Windows *Print* na .txt — spooler može ubaciti form-feed (0x0C), a mobilni
Zebra to tretira kao prazan feed.

## Ostali mediji

- `calibrate-black-mark.txt` — crna crta na poleđini (`sense_mode` = `bar`)
- `calibrate-journal.txt` — continuous/receipt, bez gapa
- `query-settings.txt` — čita trenutne postavke; odgovor se vidi u Communication prozoru
