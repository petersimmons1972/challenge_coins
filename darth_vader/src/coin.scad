// Darth Vader Challenge Coin — Double-Sided
// Obverse (top):  Vader helmet + "VENTI SALTED CARAMEL CREAM COLD BREW..." top arc
//                 + "BUT DARK CARAMEL" bottom arc in White
// Reverse (bottom): Starbucks siren silhouette in White
//
// AMS Slots:
//   1 = Black         (#1A1A1A) — rim, Vader helmet (obverse)
//   2 = Starbucks Gold (#CBA258) — accent ring
//   3 = Starbucks Green (#00704A) — inner field (base layer)
//   4 = White         (#FFFFFF) — arc text (obverse) + siren (reverse)

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
text_r  = field_r - 1.8;

// SVG scale factors
vader_scale  = 0.32;  // Vader helmet fills center, clears text arcs
siren_scale  = 0.36;  // Starbucks siren fills reverse field

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
    // start_angle = (17-1)/2 * 5.5 = 44
    arc_text("DARTH VADER DRINK", radius=text_r, size=2.2,
             start_angle=44, char_angle=5.5);
    // Bottom arc: "PETERSIMMONS@DUCK.COM" — 21 chars
    // start_angle = -(21-1)/2 * 5 = -50
    bottom_arc_text("PETERSIMMONS@DUCK.COM", radius=text_r, size=1.9,
                    start_angle=-50, char_angle=5);
}

module reverse_text_2d() {
    // Top arc: "VENTI SALTED CARAMEL CREAM COLD BREW" — 36 chars
    // start_angle = (36-1)/2 * 4.8 = 84
    arc_text("VENTI SALTED CARAMEL CREAM COLD BREW", radius=text_r, size=2.0,
             start_angle=87.5, char_angle=5.0);
    // Bottom arc: "... BUT DARK CARAMEL" — 20 chars
    // start_angle = -(20-1)/2 * 6.5 = -61.75
    bottom_arc_text("... BUT DARK CARAMEL", radius=text_r, size=2.2,
                    start_angle=-61.75, char_angle=6.5);
}

// =================================================================
// REVERSE 2D (bottom face) — Starbucks siren
// All wrapped in mirror([1,0,0]) for correct read when coin is flipped
// =================================================================

module reverse_siren_2d() {
    scale([siren_scale, siren_scale])
        import("starbucks_siren.svg", center=true);
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

module white_siren_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_siren_2d();
}

module white_reverse_text_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) reverse_text_2d();
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
            // Reverse — subtract siren + arc text
            white_siren_3d();
            white_reverse_text_3d();
        }
    }
}

// 4. WHITE: arc text (obverse) + Starbucks siren (reverse)
module white_parts() {
    color(white_c) {
        white_text_3d();
        white_siren_3d();
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
else if (COLOR == 6) { color(white_c) { white_siren_3d(); white_reverse_text_3d(); } }
