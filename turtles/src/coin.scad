// Turtles Challenge Coin — Double-Sided
// Obverse (top):  sea turtle + "TURTLES,INC." bottom arc in White
// Reverse (bottom): NCC logo only (Black diamond + Gold border + White letters)
//
// AMS Slots:
//   1 = Black  (#1A1A1A) — rim, turtle (obverse), NCC diamond fill (reverse)
//   2 = Gold   (#D4AF37) — accent ring, NCC border outline (reverse)
//   3 = Green  (#2D6A4F) — inner field (base layer)
//   4 = White  (#FFFFFF) — "TURTLES,INC." arc (obverse) + NCC letters (reverse)

COLOR = 0;

// === DIMENSIONS ===
coin_d   = 50;
total_h  = 5.0;
rim_w    = 2.5;
accent_w = 1.2;
relief   = 0.6;
gold_relief = 1.2;  // gold ring raised above green field

// Derived
inner_r = coin_d/2 - rim_w;
field_r = inner_r - accent_w;
text_r  = field_r - 2;

// SVG scale factors
turtle_scale = 0.54;  // 20% larger than 0.45
logo_scale   = 1.05;  // NCC logo fills reverse field

// === COLORS ===
black_c = [0.102, 0.102, 0.102];
gold_c  = [0.831, 0.686, 0.216];
green_c = [0.176, 0.416, 0.310];
white_c = [1.0,   1.0,   1.0  ];

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
// OBVERSE 2D (top face) — turtle + "TURTLES,INC." arc
// =================================================================

module obverse_turtle_2d() {
    scale([turtle_scale, turtle_scale])
        import("turtle.svg", center=true);
}

module obverse_text_2d() {
    // "TURTLES,INC." arcing at bottom — 12 chars
    // start_angle = -(12-1)/2 * 7.2 = -39.6 ≈ -40
    bottom_arc_text("TURTLES,INC.", radius=text_r, size=2.4,
                    start_angle=-40, char_angle=7.2);
    // "FIFTH GRADE - 2025-2026" arcing at top — 23 chars
    // Uppercase is wider, so use char_angle=5.5 and start_angle=60.5
    arc_text("FIFTH GRADE - 2025-2026", radius=text_r, size=2.2,
             start_angle=60.5, char_angle=5.5);
}

// =================================================================
// REVERSE 2D (bottom face) — NCC logo + arc text
// All wrapped in mirror([1,0,0]) for correct read when coin is flipped
// =================================================================

module ncc_diamond_full_2d() {
    // Full diamond fill — used for subtraction in other modules
    scale([logo_scale, logo_scale])
        import("ncc_diamond.svg", center=true);
}

module ncc_border_full_2d() {
    // Border outline shapes — used for subtraction in other modules
    scale([logo_scale, logo_scale])
        import("ncc_border.svg", center=true);
}

module ncc_letters_full_2d() {
    // Filled NCC letters
    scale([logo_scale, logo_scale])
        import("ncc_letters.svg", center=true);
}

// Zero-overlap 2D regions (exclusive areas per color)
module reverse_black_2d() {
    // Diamond fill MINUS border MINUS letters
    difference() {
        ncc_diamond_full_2d();
        ncc_border_full_2d();
        ncc_letters_full_2d();
    }
}

module reverse_gold_2d() {
    // Border outline MINUS letters (letters sit on top of border region)
    difference() {
        ncc_border_full_2d();
        ncc_letters_full_2d();
    }
}

module reverse_white_2d() {
    // NCC letters only (arc text is on obverse)
    ncc_letters_full_2d();
}

// =================================================================
// 3D SHAPES — used for rendering AND green base subtraction
// =================================================================

module black_turtle_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_turtle_2d();
}

module white_text_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_text_2d();
}

module ncc_diamond_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_black_2d();
}

module ncc_border_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_gold_2d();
}

module ncc_white_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_white_2d();
}

// =================================================================
// COLOR LAYER GEOMETRY — ZERO OVERLAP between parts
// =================================================================

// 1. BLACK: rim + turtle (obverse) + NCC diamond fill (reverse)
module black_parts() {
    color(black_c) {
        // Outer rim ring
        difference() {
            cylinder(h=total_h, d=coin_d, $fn=128);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=inner_r, $fn=128);
        }
        // Turtle on obverse
        black_turtle_3d();
        // NCC diamond fill on reverse
        ncc_diamond_3d();
    }
}

// 2. GOLD: accent ring + NCC border outline (reverse)
module gold_parts() {
    color(gold_c) {
        // Accent ring — raised above green field
        difference() {
            cylinder(h=total_h + gold_relief, r=inner_r, $fn=128);
            translate([0, 0, -0.01])
                cylinder(h=total_h + gold_relief + 0.02, r=field_r, $fn=128);
        }
        // NCC border outline on reverse
        ncc_border_3d();
    }
}

// 3. GREEN: inner field — subtracts ALL detail shapes
module green_parts() {
    color(green_c) {
        difference() {
            cylinder(h=total_h, r=field_r, $fn=128);
            // Obverse
            black_turtle_3d();
            white_text_3d();
            // Reverse — subtract full diamond footprint (covers all NCC parts)
            linear_extrude(height=relief)
                mirror([1, 0, 0]) ncc_diamond_full_2d();
            ncc_white_3d();
        }
    }
}

// 4. WHITE: "TURTLES,INC." arc (obverse) + NCC letters (reverse)
module white_parts() {
    color(white_c) {
        white_text_3d();
        ncc_white_3d();
    }
}

// === RENDER ===
if      (COLOR == 0) { black_parts(); gold_parts(); green_parts(); white_parts(); }
else if (COLOR == 1) { black_parts(); }
else if (COLOR == 2) { gold_parts(); }
else if (COLOR == 3) { green_parts(); }
else if (COLOR == 4) { white_parts(); }
