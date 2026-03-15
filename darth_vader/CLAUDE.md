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
- Center: Darth Vader helmet silhouette in Black
- Top arc: `"VENTI SALTED CARAMEL CREAM COLD BREW"` in White (36 chars, size=1.8, angle=4.5°)
- Bottom arc: `"... BUT DARK CARAMEL"` in White (20 chars, size=2.2, angle=6.5°)

## Reverse (bottom face)
- Center: Starbucks siren silhouette in White on Green field

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
- `src/starbucks_siren.svg` — Starbucks siren (white elements), traced from logos-world.net PNG

## Tuning Notes
- `vader_scale = 0.32` — keeps helmet within text arcs
- `siren_scale = 0.36` — fills reverse field without clipping
- Top arc: `char_angle=4.5°`, `start_angle=78.75°` — fits 36 chars across top hemisphere
- Bottom arc: `char_angle=6.5°`, `start_angle=-61.75°` — centers 20 chars at bottom
