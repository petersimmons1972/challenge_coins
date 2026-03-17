# Darth Vader Challenge Coin — Claude Instructions

## Stack
- **CAD**: OpenSCAD (`src/coin.scad`) with `COLOR` parameter (0=preview, 1–4=per color)
- **Slicer**: Bambu Studio 02.05.00.66 on Bambu P1S + AMS Pro 2
- **Build**: `./build.sh` → STLs + preview PNGs; `python3 create_3mf.py` → 3MF
- **Tests**: `python3 -m pytest test_3mf.py -v` (18 tests, always green before commit)

## AMS Slot Color Convention
| Slot | Color           | Hex       | Used For                                    |
|------|-----------------|-----------|---------------------------------------------|
|  1   | Black           | `#1A1A1A` | Outer rim · Vader helmet silhouette (front) |
|  2   | Starbucks Gold  | `#CBA258` | Accent ring                                 |
|  3   | Starbucks Green | `#00704A` | Inner field (base layer, both faces)        |
|  4   | White           | `#FFFFFF` | Arc text (front) · Starbucks siren (back)   |

## Key Rules
- **Zero mesh overlap** — each color layer is geometrically exclusive
- **Green base uses `difference()`** to subtract all other color shapes
- **Reverse face wrapped in `mirror([1,0,0])`** — reads correctly when coin is physically flipped
- **TDD first** — write failing test before changing `create_3mf.py` format
- See `~/projects/3dprint/lessons/` for full Bambu 3MF spec and patterns

## Obverse (top face)
- Center: Darth Vader helmet silhouette in Black (scale=0.261)
- Top arc: `"DARTH VADER DRINK"` in White (17 chars, size=3.2, angle=7.5°)
- Bottom arc: `"PETERSIMMONS@DUCK.COM"` in White (21 chars, size=2.8, angle=7°)

## Reverse (bottom face)
- Centered horizontal text: drink recipe in White on Green field (4 lines)

## Context
Inside joke coin — gift for the local Starbucks coffee shop where the owner orders this
custom drink twice daily. The drink is named "VENTI SALTED CARAMEL CREAM COLD BREW...
BUT DARK CARAMEL."

## Workflow
1. Edit `src/coin.scad`
2. `./build.sh` — exports 4 color STLs + preview PNGs
3. `python3 create_3mf.py` — packages into Bambu-native 3MF
4. `python3 -m pytest test_3mf.py -v` — verify 18 tests pass
5. Open `build/Darth_Vader_Challenge_Coin.3mf` in Bambu Studio to confirm

## SVG Sources
- `src/vader_helmet.svg` — Darth Vader helmet silhouette, traced from logos-world.net PNG
- `archive/starbucks_siren.svg` — Starbucks siren (archived, not used in current design)

## Tuning Notes
- `vader_scale = 0.261` — keeps helmet within text arcs (shrunk 10% from 0.29)
- Top arc: `char_angle=7.5°`, `start_angle=60°`, `size=3.2` — 17 chars, legible at print size
- Bottom arc: `char_angle=7°`, `start_angle=-70°`, `size=2.8` — 21 chars, legible at print size
