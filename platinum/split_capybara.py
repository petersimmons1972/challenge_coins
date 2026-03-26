#!/usr/bin/env python3
"""Split capybara.svg into 3 SVGs by filament color for OpenSCAD import."""

import re
from pathlib import Path

SRC = Path(__file__).parent / "src"
INPUT = SRC / "capybara.svg"

# Color groupings
BODY_COLORS = {"#C99B72"}
DETAIL_COLORS = {"#986A3E", "#6A4A2C"}  # merge dark brown + darkest marks
NOSE_COLORS = {"#F9BBBC"}

def parse_svg(svg_text):
    """Extract viewBox and all path elements with fill and d attributes."""
    vb_match = re.search(r'viewBox="([^"]+)"', svg_text)
    viewbox = vb_match.group(1) if vb_match else ""

    # Match path elements - handle both self-closing and multiline d attributes
    paths = []
    for m in re.finditer(r'<path\s+fill="([^"]+)"\s+d="([^"]+)"\s*/>', svg_text, re.DOTALL):
        paths.append((m.group(1), m.group(2).strip()))
    return viewbox, paths

def write_svg(filepath, viewbox, paths):
    """Write a clean SVG with no fill attributes (OpenSCAD ignores fill)."""
    lines = [
        '<?xml version="1.0" encoding="utf-8"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{viewbox}">',
    ]
    for d in paths:
        lines.append(f'  <path d="{d}"/>')
    lines.append('</svg>')
    lines.append('')
    filepath.write_text('\n'.join(lines))

def main():
    svg_text = INPUT.read_text()
    viewbox, all_paths = parse_svg(svg_text)

    print(f"viewBox: {viewbox}")
    print(f"Total paths found: {len(all_paths)}")

    # Group by color role
    body = [d for fill, d in all_paths if fill in BODY_COLORS]
    details = [d for fill, d in all_paths if fill in DETAIL_COLORS]
    nose = [d for fill, d in all_paths if fill in NOSE_COLORS]

    # Count by original color for verification
    counts = {}
    for fill, _ in all_paths:
        counts[fill] = counts.get(fill, 0) + 1
    print("\nPaths by color:")
    for color, count in sorted(counts.items()):
        print(f"  {color}: {count}")

    print(f"\nBody paths: {len(body)}")
    print(f"Detail paths (merged): {len(details)}")
    print(f"Nose paths: {len(nose)}")

    # Write output SVGs
    write_svg(SRC / "capybara_body.svg", viewbox, body)
    write_svg(SRC / "capybara_details.svg", viewbox, details)
    write_svg(SRC / "capybara_nose.svg", viewbox, nose)

    print("\nWrote:")
    print(f"  {SRC / 'capybara_body.svg'}")
    print(f"  {SRC / 'capybara_details.svg'}")
    print(f"  {SRC / 'capybara_nose.svg'}")

if __name__ == "__main__":
    main()
