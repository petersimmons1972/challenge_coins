# Turtles Challenge Coin — Claude Instructions

## Stack
- **CAD**: OpenSCAD (`src/coin.scad`) with `COLOR` parameter (0=preview, 1–4=per color)
- **Slicer**: Bambu Studio 02.05.00.66 on Bambu P1S + AMS Pro 2
- **Build**: `./build.sh` → STLs + preview PNGs; `python3 create_3mf.py` → 3MF
- **Tests**: `python3 -m pytest test_3mf.py -v` (18 tests, always green before commit)

## AMS Slot Color Convention
| Slot | Color | Hex | Used For |
|---|---|---|---|
| 1 | Black | #1A1A1A | Rim, turtle silhouette, NCC diamond fill |
| 2 | Gold | #D4AF37 | Accent ring, NCC border outline |
| 3 | Green | #2D6A4F | Inner field (base layer) |
| 4 | White | #FFFFFF | Arc text (obverse) + NCC letters (reverse) |

## Key Rules
- **Zero mesh overlap** — each color layer is geometrically exclusive
- **Green base uses `difference()`** to subtract all other color shapes
- **Reverse face wrapped in `mirror([1,0,0])`** — reads correctly when coin is physically flipped
- **TDD first** — write failing test before changing `create_3mf.py` format
- See `~/projects/3dprint/lessons/` for full Bambu 3MF spec and patterns

## Obverse (top face)
- Top arc: "Fifth Grade - 2025-2026" in White
- Center: Sea turtle silhouette in Black
- Bottom arc: "TURTLES,INC." in White

## Reverse (bottom face)
- NCC logo: Black diamond fill + Gold border outline + White letters

## Workflow
1. Edit `src/coin.scad`
2. `./build.sh` — exports 4 color STLs + preview PNGs
3. `python3 create_3mf.py` — packages into Bambu-native 3MF
4. `python3 -m pytest test_3mf.py -v` — verify 18 tests pass
5. Open `build/Turtles_Challenge_Coin.3mf` in Bambu Studio to confirm

## SVG Sources
- `src/turtle.svg` — UXWing sea turtle (free commercial use, top-down view)
- `src/ncc_diamond.svg` — NCC logo diamond fill layer
- `src/ncc_border.svg` — NCC logo border/frame layer
- `src/ncc_letters.svg` — NCC logo letter fill layer
