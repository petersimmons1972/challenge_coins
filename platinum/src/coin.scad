// McCloud Bux Platinum Challenge Coin - DOUBLE-SIDED
// $1,000,000 Platinum Coin - 100mm oversized display piece
// Single print, no glue. Bambu P1S + AMS Pro 2 (4 colors)
//
// Top = Obverse (McCloud lithophane portrait in brown + "McCLOUD BUX" / "PLATINUM")
// Bottom = Reverse ("ONE MILLION" / "$1,000,000" / "McCLOUD BUX")
//
// IMPORTANT: Each color part has NO overlap with any other.
// Base layer uses difference() to subtract all other color shapes.
//
// COLOR selects which filament layer to render:
//   0 = All (preview)
//   1 = Black (#1A1A1A)              - Rim, reverse denomination
//   2 = Matte Caramel (#B4823C)      - Portrait disc with lithophane relief
//   3 = Iron Gray Metallic (#78787D) - Accent ring + inner field (base layer)
//   4 = White (#F5F5F5)              - Text

COLOR = 0;

// === DIMENSIONS (100mm coin, doubled from standard 50mm) ===
coin_d = 100;
total_h = 8.0;
rim_w = 5.0;
accent_w = 2.4;
relief = 1.0;
portrait_depth = 1.0;

// Derived
inner_r = coin_d/2 - rim_w;
field_r = inner_r - accent_w;
text_r = field_r - 4;

// Heightmap: 300x300 grid
portrait_size = 65;
portrait_r = portrait_size / 2;

// === COLORS ===
black_c = [0.05, 0.05, 0.05];
caramel = [0.71, 0.51, 0.24];     // Matte Caramel - warm skin tone
iron_gray = [0.47, 0.47, 0.49];   // Iron Gray Metallic
white_c = [1.0, 1.0, 1.0];

// === TEXT MODULES ===
module arc_text(str, radius, size, start_angle, char_angle) {
    for (i = [0:len(str)-1]) {
        angle = start_angle - i * char_angle;
        rotate([0, 0, angle])
            translate([0, radius, 0])
                text(str[i], size=size, font="Arial:style=Bold",
                     halign="center", valign="center");
    }
}

module bottom_arc_text(str, radius, size, start_angle, char_angle) {
    for (i = [0:len(str)-1]) {
        angle = start_angle + i * char_angle;
        translate([radius * sin(angle), -radius * cos(angle), 0])
            rotate([0, 0, angle])
                text(str[i], size=size, font="Arial:style=Bold",
                     halign="center", valign="center");
    }
}

// =================================================================
// OBVERSE DESIGN (top face)
// =================================================================

// Lithophane portrait surface — the heightmap creates varying depth
module portrait_surface_3d() {
    pixel_size = portrait_size / 300;
    translate([-portrait_size/2, -portrait_size/2, 0])
        scale([pixel_size, pixel_size, portrait_depth])
            surface(file="portrait_heightmap.dat", center=false, convexity=5);
}

// The recess shape — solid block minus heightmap, clipped to circle
module portrait_recess_3d() {
    translate([0, 0, total_h - portrait_depth])
    intersection() {
        cylinder(h=portrait_depth + 0.2, r=portrait_r, $fn=128);
        difference() {
            translate([-portrait_size/2, -portrait_size/2, 0])
                cube([portrait_size, portrait_size, portrait_depth + 0.1]);
            portrait_surface_3d();
        }
    }
}

// The portrait disc — a cylinder with the heightmap surface on top
module portrait_disc_3d() {
    translate([0, 0, total_h - portrait_depth])
    intersection() {
        cylinder(h=portrait_depth + 0.1, r=portrait_r, $fn=128);
        portrait_surface_3d();
    }
}

// Arc text (white, top face)
module obverse_white_2d() {
    arc_text("McCLOUD BUX",
             radius=text_r, size=5.2,
             start_angle=52, char_angle=9.5);

    bottom_arc_text("PLATINUM",
                    radius=text_r, size=5.2,
                    start_angle=-30, char_angle=9.5);
}

// =================================================================
// REVERSE DESIGN (bottom face)
// =================================================================

module reverse_black_2d() {
    mirror([1, 0, 0])
        text("$1,000,000", size=8, font="Arial:style=Bold",
             halign="center", valign="center");
}

module reverse_white_2d() {
    mirror([1, 0, 0]) {
        arc_text("ONE MILLION",
                 radius=text_r, size=5.2,
                 start_angle=48, char_angle=9.5);

        bottom_arc_text("McCLOUD BUX",
                        radius=text_r, size=5.2,
                        start_angle=-48, char_angle=9.5);
    }
}

// =================================================================
// 3D SHAPES
// =================================================================

module black_denom_3d() {
    linear_extrude(height=relief)
        reverse_black_2d();
}

module white_obverse_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_white_2d();
}

module white_reverse_3d() {
    linear_extrude(height=relief)
        reverse_white_2d();
}

// =================================================================
// COLOR LAYERS — NO OVERLAP
// =================================================================

// 1. BLACK: rim + reverse denomination
module black_parts() {
    color(black_c) {
        difference() {
            cylinder(h=total_h, d=coin_d, $fn=200);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=inner_r, $fn=200);
        }
        black_denom_3d();
    }
}

// 2. CARAMEL: portrait disc with lithophane relief on top face
module caramel_parts() {
    color(caramel) {
        // Portrait disc — a cylinder filling the portrait area,
        // with the heightmap surface forming the top
        difference() {
            // Full cylinder for portrait area (from base to top)
            translate([0, 0, 0])
                cylinder(h=total_h, r=portrait_r, $fn=128);
            // Cut the top to follow the heightmap surface
            portrait_recess_3d();
        }
    }
}

// 3. IRON GRAY: accent ring + field (with portrait area cut out)
module gray_parts() {
    color(iron_gray) {
        // Accent ring
        difference() {
            cylinder(h=total_h, r=inner_r, $fn=200);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=field_r, $fn=200);
        }
        // Inner field minus portrait area, text, and denomination
        difference() {
            cylinder(h=total_h, r=field_r, $fn=200);
            // Cut out portrait disc area
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=portrait_r, $fn=128);
            // Subtract white text from top
            white_obverse_3d();
            // Subtract black denomination from bottom
            black_denom_3d();
            // Subtract white text from bottom
            white_reverse_3d();
        }
    }
}

// 4. WHITE: all text
module white_parts() {
    color(white_c) {
        white_obverse_3d();
        white_reverse_3d();
    }
}

// === RENDER ===
if (COLOR == 0) {
    black_parts();
    caramel_parts();
    gray_parts();
    white_parts();
} else if (COLOR == 1) {
    black_parts();
} else if (COLOR == 2) {
    caramel_parts();
} else if (COLOR == 3) {
    gray_parts();
} else if (COLOR == 4) {
    white_parts();
}
