#!/bin/bash
# Build Chattahoochee Gold Swimming Challenge Coin STL files
set -e
cd "$(dirname "$0")"

BUILD_DIR="build"
SRC_DIR="src"
mkdir -p "$BUILD_DIR"

echo "=== Chattahoochee Gold Swimming Challenge Coin Build ==="
echo ""

echo "--- Rendering 3 color layers ---"
for color in 1 2 3; do
    case $color in
        1) name="gold"  ;;
        2) name="navy"  ;;
        3) name="white" ;;
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
echo "  Obverse (top)..."
openscad -o "$BUILD_DIR/coin_obverse.png" \
    --camera=0,-1,3.5,25,0,3,150 \
    --imgsize=800,800 \
    -D "COLOR=0" \
    "$SRC_DIR/coin.scad" 2>/dev/null

echo "  Reverse (bottom)..."
openscad -o "$BUILD_DIR/coin_reverse_raw.png" \
    --camera=0,3,-2,160,0,0,150 \
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
