# PDA Scanner demo

Mini Flutter aplikacija sa **jednim ekranom** i **jednim input poljem**. Sken sa Honeywell ili Zebra PDA-a upisuje se u to polje kroz isti `PdaScanner` interface.

## Kako radi

```
ScanScreen.onScanned()
        │
        ▼
  PdaScannerCallback
        │
        ▼
   PdaScanner  ◄── ScannerFactory bira implementaciju
        │
        ├── HoneywellPdaScanner  (honeywell_scanner 8.0.1)
        ├── ZebraPdaScanner      (DataWedge, npr. MC3450)
        └── SimulatedPdaScanner  (emulator / desktop)
```

`ScanScreen` implementira `PdaScannerCallback.onScanned` isto kao što Honeywell ekran implementira `ScannerCallback.onDecoded`. Factory na startu pita `isSupported()` i bira uređaj.

## Pokretanje

Na Honeywell ili Zebra Android uređaju:

```bash
cd pda_scanner_demo
flutter pub get
flutter run
```

Pritisni hardware trigger. Barkod se upisuje u polje **Barkod**.

Na emulatoru/desktopu factory padne na simulator. Polje ostaje običan TextField; tok `onScanned` je pokriven testovima.

## Honeywell setup

Plugin zahteva `honeywell.aar` kao Android modul. Folder `android/honeywell/` je već u projektu, a `settings.gradle.kts` ima `include(":honeywell")`. Manifest ima `tools:replace="android:label"` zbog konflikta iz AAR-a.

## Zebra / MC3450

Native sloj (`ZebraScannerPlugin`) preko DataWedge-a:

- kreira profil `PdaScannerDemo`
- Intent Output (isključen Keystroke Output da se barkod ne duplira u polju)
- hardware trigger i `startScanning()` / `stopScanning()` (`SOFT_SCAN_TRIGGER`)
- Honeywell `DEC_*` property ključevi se mapiraju na DataWedge `decoder_*` parametre

Nije potreban Zebra EMDK AAR.

## Testovi

```bash
cd pda_scanner_demo
flutter test
```
