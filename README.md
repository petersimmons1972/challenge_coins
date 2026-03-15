# Challenge Coins

A collection of 3D-printed, multi-color challenge coins designed for the **Bambu P1S + AMS Pro 2**.

Every coin is double-sided, 50mm diameter, 4-color, and prints in a single pass — no assembly, no glue.

---

## Coins

| Coin | Description | Colors | Status |
|---|---|---|---|
| [NCCS Challenge Coin](nccs_challenge_coin/) | North Cobb Christian School 2026 Swim Team — NCC shield (obverse) + swimmer silhouette (reverse) | Navy · Gray · Carolina Blue · White | ✅ Complete |
| [Turtles Challenge Coin](turtles/) | Turtles, Inc. 5th grade business club — sea turtle (obverse) + NCC school logo (reverse) | Black · Gold · Green · White |  ✅ Complete |

---

## Gallery

### NCCS Challenge Coin

| Obverse (Front) | Reverse (Back) |
|---|---|
| ![NCCS Obverse](nccs_challenge_coin/build/coin_top.png) | ![NCCS Reverse](nccs_challenge_coin/build/coin_reverse.png) |

### Turtles Challenge Coin

| Obverse (Front) | Reverse (Back) |
|---|---|
| ![Turtles Obverse](turtles/build/coin_top.png) | ![Turtles Reverse](turtles/build/coin_reverse.png) |

---

## Build Requirements

- [OpenSCAD](https://openscad.org/) (any recent version)
- Python 3 + `pip install pillow pytest`
- Bambu Studio 02.05.00.66+
- Bambu P1S with AMS Pro 2 (4 slots)

---

## Quick Start

```bash
# Build a specific coin
cd nccs_challenge_coin/
./build.sh                        # renders STLs + preview PNGs
python3 create_3mf.py             # packages Bambu-native 3MF
python3 -m pytest test_3mf.py -v  # verify (18 tests)
# Open build/*.3mf in Bambu Studio
```

---

## Design Standards

All coins share the same architecture:

- **50mm diameter · 5mm thick · 0.6mm relief**
- **4-color AMS** — each layer geometrically exclusive (zero mesh overlap)
- **Single-print double-sided** — obverse at z=4.4–5.0mm, reverse at z=0–0.6mm
- **Reverse face** wrapped in `mirror([1,0,0])` for correct readout when flipped
- **OpenSCAD** parametric source with `COLOR=N` parameter for per-layer export

See [CLAUDE.md](CLAUDE.md) for full shared standards and build patterns.

---

## License

Individual coin designs may have different licenses — see each coin's README.
Build tooling (`create_3mf.py`, `test_3mf.py`, `build.sh`) is MIT.
