# Challenge Coins — Shared Claude Instructions

## Stack

- **CAD**: OpenSCAD with `COLOR` parameter (0=preview, 1–4=per color layer)
- **Slicer**: Bambu Studio 02.05.00.66 on Bambu P1S + AMS Pro 2 (4 filament slots)
- **Build**: `./build.sh` → STLs + preview PNGs; `python3 create_3mf.py` → Bambu-native 3MF
- **Tests**: `python3 -m pytest test_3mf.py -v` — 18 tests, always green before commit

## Standard Coin Specifications

| Parameter | Value |
|---|---|
| Diameter | 50 mm |
| Thickness | 5.0 mm |
| Relief height | 0.6 mm |
| Obverse detail z | 4.4–5.0 mm (top face) |
| Reverse detail z | 0–0.6 mm (bottom face) |
| Colors | 4 (AMS slots 1–4) |
| Supports | None required |
| Layer height | 0.1–0.2 mm |

## Key Design Rules

- **Zero mesh overlap** — each color layer is geometrically exclusive
- **Base layer uses `difference()`** to subtract all other color shapes from itself
- **Reverse face wrapped in `mirror([1,0,0])`** so logos/text read correctly when coin is flipped
- **TDD first** — write failing test before changing `create_3mf.py`

## Shared Workflow

1. Edit `src/coin.scad`
2. `./build.sh` — exports 4 color STLs + preview PNGs
3. `python3 create_3mf.py` — packages into Bambu-native 3MF
4. `python3 -m pytest test_3mf.py -v` — verify 18 tests pass
5. Open the `.3mf` in Bambu Studio to confirm visually

## Bambu 3MF Format

- All 4 color meshes live in `3D/Objects/object_1.model`
- Root model contains only an assembly wrapper with `p:path` component references
- `Application: BambuStudio-02.05.00.66` metadata triggers Bambu's native multi-color mode
- Filament colors are 6-digit hex in `Metadata/project_settings.config`

## Reference Lessons

See `~/projects/3dprint/lessons/` for:
- `3mf-format.md` — full Bambu Studio 3MF spec
- `openscad-coin-design.md` — OpenSCAD patterns and gotchas
- `bambu-3mf-format.md` — exact format spec

## Per-Coin Color Conventions

### NCCS Challenge Coin (`nccs_challenge_coin/`)
| Slot | Color | Hex | Used For |
|---|---|---|---|
| 1 | Navy Blue | #1B3B60 | Rim, diamond, swimmer |
| 2 | Dark Gray | #999DA2 | Accent ring |
| 3 | Carolina Blue | #8BD1EE | Inner field |
| 4 | White | #FFFFFF | Letters + arc text |

### Turtles Challenge Coin (`turtles/`)
| Slot | Color | Hex | Used For |
|---|---|---|---|
| 1 | Black | #1A1A1A | Rim, turtle, NCC diamond |
| 2 | Gold | #D4AF37 | Accent ring, NCC border |
| 3 | Green | #2D6A4F | Inner field (base layer) |
| 4 | White | #FFFFFF | Arc text + NCC letters |

### Chattahoochee Gold Challenge Coin (`gold/`)
| Slot | Color | Hex | Used For |
|---|---|---|---|
| 1 | Gold  | #FFD324 | Rim, trident (obverse), swimmer (reverse) |
| 2 | Navy  | #000B39 | Inner field both faces (base layer) |
| 3 | White | #FFFFFF | Arc text both faces |

### Darth Vader Challenge Coin (`darth_vader/`)
| Slot | Color           | Hex       | Used For                                    |
|---|---|---|---|
| 1 | Black           | #1A1A1A | Rim, Vader helmet silhouette (obverse)      |
| 2 | Starbucks Gold  | #CBA258 | Accent ring                                 |
| 3 | Starbucks Green | #00704A | Inner field (base layer)                    |
| 4 | White           | #FFFFFF | Arc text (obverse) + Starbucks siren (reverse) |

## Adding a New Coin

1. Create a new subdirectory: `mkdir new_coin_name/`
2. Copy `build.sh`, `create_3mf.py`, `test_3mf.py` from an existing coin as a template
3. Create `src/coin.scad` with the `COLOR` parameter pattern
4. Update root `README.md` gallery table with the new coin
5. Add per-coin color table to this CLAUDE.md
