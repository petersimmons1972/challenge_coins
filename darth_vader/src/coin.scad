// Darth Vader Challenge Coin — Double-Sided
// Obverse (top):  Vader helmet + "DARTH VADER DRINK" / "PETERSIMMONS@DUCK.COM" arcs
// Reverse (bottom): Drink name in centered horizontal text (White on Green)
//
// AMS Slots:
//   1 = Black         (#1A1A1A) — rim, Vader helmet (obverse)
//   2 = Starbucks Gold (#CBA258) — accent ring
//   3 = Starbucks Green (#00704A) — inner field (base layer)
//   4 = White         (#FFFFFF) — arc text (obverse) + drink text (reverse)

COLOR = 0;

// === DIMENSIONS ===
coin_d   = 50;
total_h  = 5.0;
rim_w    = 2.5;
accent_w = 1.2;
relief   = 0.6;
gold_relief = 0;    // flush with coin top face

// Derived
inner_r = coin_d/2 - rim_w;
field_r = inner_r - accent_w;
text_r  = field_r - 1.8;

// SVG scale factors
vader_scale  = 0.261; // Vader helmet fills center, clears text arcs (shrunk 10% from 0.29)

// === COLORS ===
black_c = [0.102, 0.102, 0.102];
gold_c  = [0.796, 0.643, 0.345];
green_c = [0.000, 0.416, 0.290];
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
// OBVERSE 2D (top face) — Vader helmet + arc text
// =================================================================

module obverse_vader_2d() {
    // Outer silhouette minus inner detail cutouts (eyes, nose, mouth grille)
    // — green base shows through the cutouts giving helmet detail
    scale([vader_scale, vader_scale])
        difference() {
            import("vader_outer.svg", center=true);
            import("vader_details.svg", center=true);
        }
}

module obverse_text_2d() {
    // Top arc: "DARTH VADER DRINK" — 17 chars
    // start_angle = (17-1)/2 * 7.5 = 60
    arc_text("DARTH VADER DRINK", radius=text_r, size=3.2,
             start_angle=60, char_angle=7.5);
    // Bottom arc: "PETERSIMMONS@DUCK.COM" — 21 chars
    // start_angle = -(21-1)/2 * 7 = -70
    bottom_arc_text("PETERSIMMONS@DUCK.COM", radius=text_r, size=2.8,
                    start_angle=-70, char_angle=7);
}

// =================================================================
// REVERSE 2D (bottom face) — Drink name in centered horizontal text
// =================================================================

module reverse_drink_text_2d() {
    // 4 lines of centered text, spaced to fill the green field
    // field_r ≈ 21.3mm, so usable width ≈ 38mm
    line_h = 5.5;  // vertical spacing between lines
    sz = 3.2;      // text size — large for legibility
    translate([0, line_h * 1.5, 0])
        text("VENTI SALTED", size=sz, font="Arial:style=Bold",
             halign="center", valign="center");
    translate([0, line_h * 0.5, 0])
        text("CARAMEL CREAM", size=sz, font="Arial:style=Bold",
             halign="center", valign="center");
    translate([0, -line_h * 0.5, 0])
        text("COLD BREW", size=sz, font="Arial:style=Bold",
             halign="center", valign="center");
    translate([0, -line_h * 1.5, 0])
        text("... BUT DARK CARAMEL", size=sz * 0.72, font="Arial:style=Bold",
             halign="center", valign="center");
}

// =================================================================
// 3D SHAPES — used for rendering AND green base subtraction
// =================================================================

module black_vader_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_vader_2d();
}

module white_text_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_text_2d();
}

module white_reverse_text_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_drink_text_2d();
}

// =================================================================
// COLOR LAYER GEOMETRY — ZERO OVERLAP between parts
// =================================================================

// 1. BLACK: rim + Vader helmet (obverse)
module black_parts() {
    color(black_c) {
        // Outer rim ring
        difference() {
            cylinder(h=total_h, d=coin_d, $fn=128);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=inner_r, $fn=128);
        }
        // Vader helmet on obverse
        black_vader_3d();
    }
}

// 2. GOLD (Starbucks): accent ring
module gold_parts() {
    color(gold_c) {
        difference() {
            cylinder(h=total_h + gold_relief, r=inner_r, $fn=128);
            translate([0, 0, -0.01])
                cylinder(h=total_h + gold_relief + 0.02, r=field_r, $fn=128);
        }
    }
}

// 3. GREEN (Starbucks): inner field — subtracts ALL detail shapes
module green_parts() {
    color(green_c) {
        difference() {
            cylinder(h=total_h, r=field_r, $fn=128);
            // Obverse
            black_vader_3d();
            white_text_3d();
            // Reverse — subtract drink text
            white_reverse_text_3d();
        }
    }
}

// 4. WHITE: arc text (obverse) + drink text (reverse)
module white_parts() {
    color(white_c) {
        white_text_3d();
        white_reverse_text_3d();
    }
}

// === RENDER ===
if      (COLOR == 0) { black_parts(); gold_parts(); green_parts(); white_parts(); }
else if (COLOR == 1) { black_parts(); }
else if (COLOR == 2) { gold_parts(); }
else if (COLOR == 3) { green_parts(); }
else if (COLOR == 4) { white_parts(); }
// Preview-only modes (obverse / reverse white split, not for printing)
else if (COLOR == 5) { color(white_c) { white_text_3d(); } }
else if (COLOR == 6) { color(white_c) { white_reverse_text_3d(); } }
