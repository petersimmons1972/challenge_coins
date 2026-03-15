# Turtles, Inc. — Challenge Coin

A premium 4-color multi-material challenge coin for **Turtles, Inc.**, a 5th grade school business club.

**Double-sided · 50mm diameter · Bambu P1S + AMS**

---

## Design

| Side | Content |
|---|---|
| **Obverse** | Sea turtle silhouette (Black) · "Fifth Grade - 2025-2026" top arc (White) · "TURTLES,INC." bottom arc (White) |
| **Reverse** | NCC school logo — diamond fill (Black) · border outline (Gold) · letters (White) |

### Color / AMS Slots

| Slot | Color | Hex | Filament |
|---|---|---|---|
| 1 | Black | `#1A1A1A` | Outer rim · turtle · NCC diamond |
| 2 | Gold | `#D4AF37` | Accent ring · NCC border |
| 3 | Green | `#2D6A4F` | Inner field (base layer) |
| 4 | White | `#FFFFFF` | All text · NCC letters |

---

## Files

```
src/
  coin.scad          — OpenSCAD parametric source
  turtle.svg         — Sea turtle silhouette (UXWing, free commercial use)
  ncc_diamond.svg    — NCC logo: diamond fill layer
  ncc_border.svg     — NCC logo: border/frame layer
  ncc_letters.svg    — NCC logo: letter fill layer

build/
  coin_black.stl     — Color 1: Black parts
  coin_gold.stl      — Color 2: Gold parts
  coin_green.stl     — Color 3: Green parts
  coin_white.stl     — Color 4: White parts
  Turtles_Challenge_Coin.3mf  — Ready-to-print Bambu Studio file

build.sh             — Renders STLs + preview images via OpenSCAD
create_3mf.py        — Packages STLs into Bambu-native 3MF
test_3mf.py          — pytest suite (18 tests) validating 3MF structure
```

---

## Print Settings

Tested on **Bambu P1S** with **AMS Pro 2**.

| Setting | Value |
|---|---|
| Layer height | 0.1mm (fine detail) |
| Infill | 15% gyroid |
| Walls | 4 |
| Support | None |
| Prime tower | Enabled |
| Filament | Overture PLA (all 4 colors) |

The coin is designed at **5.0mm total height** with **0.6mm relief** for all raised features.

---

## How to Print

### Option A — Use the pre-built 3MF (easiest)

1. Download `build/Turtles_Challenge_Coin.3mf`
2. Open in Bambu Studio
3. Assign your 4 filaments to match the color table above
4. Slice and print

### Option B — Build from source

**Requirements:** OpenSCAD, Python 3, Pillow

```bash
# Install Python deps
pip install pillow pytest

# Render STLs and preview images
./build.sh

# Package into Bambu 3MF
python3 create_3mf.py

# Verify 3MF structure (18 tests)
python3 -m pytest test_3mf.py -v
```

Output: `build/Turtles_Challenge_Coin.3mf`

---

## Customization

All parameters are at the top of `src/coin.scad`:

| Variable | Default | Description |
|---|---|---|
| `coin_d` | 50 | Coin diameter (mm) |
| `total_h` | 5.0 | Total coin height (mm) |
| `rim_w` | 2.5 | Outer rim width (mm) |
| `relief` | 0.6 | Height of raised features (mm) |
| `turtle_scale` | 0.45 | Turtle silhouette scale |
| `logo_scale` | 1.05 | NCC logo scale |

To render a single color layer for inspection:

```bash
openscad -D "COLOR=1" src/coin.scad  # 1=Black 2=Gold 3=Green 4=White
```

---

## Technical Notes

- **Zero mesh overlap** — each color layer is geometrically exclusive; the Green base uses `difference()` to subtract all other shapes
- **Reverse face** uses `mirror([1,0,0])` so the logo reads correctly when the coin is physically flipped
- **3MF format** follows the Bambu Studio native spec: root model contains only the assembly object with 4 component references; mesh objects live in `3D/Objects/object_1.model`

---

## License

Design files: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
Turtle SVG: [UXWing](https://uxwing.com) (free for commercial use, no attribution required)
NCC logo: property of the school — used with permission for personal/club use only
