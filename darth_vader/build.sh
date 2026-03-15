#!/bin/bash
# Build Darth Vader Challenge Coin STL files
set -e
cd "$(dirname "$0")"

BUILD_DIR="build"
SRC_DIR="src"
mkdir -p "$BUILD_DIR"

echo "=== Darth Vader Challenge Coin Build ==="
echo ""

echo "--- Rendering 4 color layers ---"
for color in 1 2 3 4; do
    case $color in
        1) name="black" ;;
        2) name="gold"  ;;
        3) name="green" ;;
        4) name="white" ;;
    esac
    echo "  coin_${name}.stl (color $color)..."
    openscad -o "$BUILD_DIR/coin_${name}.stl" \
        -D "COLOR=$color" \
        "$SRC_DIR/coin.scad" 2>/dev/null
done

echo "  coin_preview.stl..."
openscad -o "$BUILD_DIR/coin_preview.stl" \
    -D "COLOR=0" \
    "$SRC_DIR/coin.scad" 2>/dev/null

echo ""
echo "--- Preview images ---"
echo "  Obverse (top, composited)..."
# Render each color layer separately (top-down), then composite.
# COLOR=0 combined view causes z-fighting at z=5.0 which hides the helmet.
# Composite order: green base → gold ring → black (rim+helmet) → white text ring only.
# Use COLOR=5 for obverse-only white (name + email arcs), avoiding reverse bleed
for color in 1 2 3 5; do
    case $color in
        1) name="black" ;; 2) name="gold" ;; 3) name="green" ;; 5) name="white_obs" ;;
    esac
    openscad -o "$BUILD_DIR/tmp_${name}.png" \
        --camera=0,0,0,0,0,0,120 --projection=ortho --imgsize=800,800 \
        -D "COLOR=$color" "$SRC_DIR/coin.scad" 2>/dev/null
done
python3 -c "
from PIL import Image
import os

BUILD = '$BUILD_DIR'

def load_transparent(fname):
    img = Image.open(fname).convert('RGBA')
    data = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = data[x, y]
            if r > 210 and g > 210 and b > 195:
                data[x, y] = (0, 0, 0, 0)
    return img

bg = Image.new('RGBA', (800, 800), (240, 240, 220, 255))
for n in ['green', 'gold', 'black', 'white_obs']:
    layer = load_transparent(f'{BUILD}/tmp_{n}.png')
    bg.paste(layer, (0, 0), layer)
bg.convert('RGB').save(f'{BUILD}/coin_obverse.png')
for n in ['black', 'gold', 'green', 'white_obs']:
    os.remove(f'{BUILD}/tmp_{n}.png')
"

echo "  Reverse (bottom, top-down)..."
openscad -o "$BUILD_DIR/coin_reverse_raw.png" \
    --camera=0,0,-120,180,0,0,120 --projection=ortho \
    --imgsize=800,800 \
    -D "COLOR=0" \
    "$SRC_DIR/coin.scad" 2>/dev/null
python3 -c "
from PIL import Image
img = Image.open('$BUILD_DIR/coin_reverse_raw.png').rotate(180)
img.save('$BUILD_DIR/coin_reverse.png')
"
rm -f "$BUILD_DIR/coin_reverse_raw.png"

echo ""
echo "=== Build Complete ==="
ls -lh "$BUILD_DIR/"*.stl "$BUILD_DIR/"*.png 2>/dev/null
echo ""
echo "Next: python3 create_3mf.py"
