#!/bin/bash
# Build McCloud Bux Platinum Challenge Coin STL files
# Runs all 4 color layers in parallel — one core per color.
set -e
cd "$(dirname "$0")"

BUILD_DIR="build"
SRC_DIR="src"
mkdir -p "$BUILD_DIR"

echo "=== McCloud Bux Platinum Coin Build (parallel) ==="
echo ""

declare -A NAMES=([1]=black [2]=brown [3]=gray [4]=white)
PIDS=()

for color in 1 2 3 4; do
    name="${NAMES[$color]}"
    echo "  Launching coin_${name}.stl (color $color)..."
    openscad -o "$BUILD_DIR/coin_${name}.stl" \
        -D "COLOR=$color" \
        "$SRC_DIR/coin.scad" 2>/dev/null &
    PIDS+=($!)
done

# Wait for all 4 and capture any failures
FAILED=0
for i in "${!PIDS[@]}"; do
    color=$((i+1))
    name="${NAMES[$color]}"
    if ! wait "${PIDS[$i]}"; then
        echo "  ERROR: coin_${name}.stl failed" >&2
        FAILED=1
    else
        echo "  Done: coin_${name}.stl"
    fi
done

[[ $FAILED -ne 0 ]] && exit 1

echo ""
echo "Done! STL files in $BUILD_DIR/"
ls -lh "$BUILD_DIR"/*.stl
