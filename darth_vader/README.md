# Darth Vader Challenge Coin

**Inside Joke · Starbucks Edition · 2026**

A gift for the local Starbucks baristas — commemorating the custom drink ordered twice daily,
dubbed *"VENTI SALTED CARAMEL CREAM COLD BREW... BUT DARK CARAMEL."*

---

| Obverse (Front) | Reverse (Back) |
|:---:|:---:|
| ![Obverse](build/coin_obverse.png) | ![Reverse](build/coin_reverse.png) |

---

## Design

**Front:** Darth Vader helmet silhouette (Black) on Starbucks Green field, encircled by "DARTH VADER DRINK" / "PETERSIMMONS@DUCK.COM" in White
**Back:** Drink recipe in centered horizontal text (White) on Starbucks Green field

## Colors

| Slot | Color           | Hex       | Used For                                    |
|:----:|-----------------|-----------|---------------------------------------------|
|  1   | ⚫ Black        | `#1A1A1A` | Outer rim · Vader helmet silhouette (front) |
|  2   | 🟡 Starbucks Gold | `#CBA258` | Accent ring                               |
|  3   | 🟢 Starbucks Green | `#00704A` | Inner field (base layer)                 |
|  4   | ⚪ White        | `#FFFFFF` | Arc text (front) · Starbucks siren (back)   |

## Build

```bash
cd darth_vader/
./build.sh                     # render STLs + preview PNGs
python3 create_3mf.py          # package Bambu-native 3MF
python3 -m pytest test_3mf.py  # verify 18 tests pass
# Open build/Darth_Vader_Challenge_Coin.3mf in Bambu Studio
```

## Specifications

| Parameter     | Value             |
|---------------|-------------------|
| Diameter      | 50 mm             |
| Thickness     | 5.0 mm            |
| Relief height | 0.6 mm            |
| Colors        | 4 (AMS slots 1–4) |
| Supports      | None required     |

## Text

| Position   | Text                                      |
|------------|-------------------------------------------|
| Top arc (front)    | `DARTH VADER DRINK`                             |
| Bottom arc (front) | `PETERSIMMONS@DUCK.COM`                         |
| Back (4 lines)     | `VENTI SALTED / CARAMEL CREAM / COLD BREW / ... BUT DARK CARAMEL` |
