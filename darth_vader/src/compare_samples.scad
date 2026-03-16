// Compare Samples — Two complete coins side by side
// Both have identical obverse (Vader helmet + arc text)
// Left = Sample 2 (horizontal text reverse, no siren)
// Right = Sample 1 (siren + arc text reverse)
//
// COLOR param: 0=preview, 1=black, 2=gold, 3=green, 4=white
//
// NOTE: Zero mesh overlap — green base uses difference() to subtract all
// other color shapes, exactly like the NCCS coin. Overlap strategy was
// tried previously but Bambu gives priority to higher-numbered extruders,
// so green (slot 3) ate the black vader (slot 1).

COLOR = 0;

// === SHARED DIMENSIONS ===
coin_d   = 50;
total_h  = 5.0;
rim_w    = 2.5;
accent_w = 1.2;
relief   = 0.6;
inner_r = coin_d/2 - rim_w;
field_r = inner_r - accent_w;
text_r  = field_r - 1.8;

vader_scale = 0.29;
siren_scale = 0.26;
spacing = coin_d + 8;

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
// SHARED SHELL PARTS (per color)
// =================================================================

module shell_black() {
    difference() {
        cylinder(h=total_h, d=coin_d, $fn=128);
        translate([0, 0, -0.01])
            cylinder(h=total_h+0.02, r=inner_r, $fn=128);
    }
}

module shell_gold() {
    difference() {
        cylinder(h=total_h, r=inner_r, $fn=128);
        translate([0, 0, -0.01])
            cylinder(h=total_h + 0.02, r=field_r, $fn=128);
    }
}

// =================================================================
// SHARED OBVERSE — Vader helmet (black) + arc text (white)
// Detail parts overlap into green by 'overlap' mm
// =================================================================

module obverse_vader_2d() {
    scale([vader_scale, vader_scale])
        difference() {
            import("vader_outer.svg", center=true);
            import("vader_details.svg", center=true);
        }
}

module obverse_text_2d() {
    arc_text("DARTH VADER DRINK", radius=text_r, size=2.6,
             start_angle=52, char_angle=6.5);
    bottom_arc_text("PETERSIMMONS@DUCK.COM", radius=text_r, size=2.3,
                    start_angle=-60, char_angle=6);
}

module black_vader_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_vader_2d();
}

module white_obverse_text_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_text_2d();
}

// =================================================================
// SAMPLE 1 REVERSE — Siren + arc text
// =================================================================

module s1_siren_2d() {
    scale([siren_scale, siren_scale])
        import("starbucks_siren.svg", center=true);
}

module s1_reverse_text_2d() {
    arc_text("VENTI SALTED CARAMEL CREAM COLD BREW", radius=text_r, size=2.2,
             start_angle=87.5, char_angle=5.0);
    bottom_arc_text("... BUT DARK CARAMEL", radius=text_r, size=2.4,
                    start_angle=-61.75, char_angle=6.5);
}

module s1_white_reverse_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) {
            s1_siren_2d();
            s1_reverse_text_2d();
        }
}

// =================================================================
// SAMPLE 2 REVERSE — Horizontal text (no siren)
// =================================================================

module s2_reverse_text_2d() {
    line_h = 5.5;
    sz = 3.2;
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

module s2_white_reverse_3d() {
    linear_extrude(height=relief)
        mirror([1, 0, 0]) s2_reverse_text_2d();
}

// =================================================================
// COLOR LAYERS — both coins
// Zero overlap: green subtracts all detail geometry (NCCS flush approach).
// =================================================================

module all_black() {
    color(black_c) {
        translate([-spacing/2, 0, 0]) shell_black();
        translate([ spacing/2, 0, 0]) shell_black();
        translate([-spacing/2, 0, 0]) black_vader_3d();
        translate([ spacing/2, 0, 0]) black_vader_3d();
    }
}

module all_gold() {
    color(gold_c) {
        translate([-spacing/2, 0, 0]) shell_gold();
        translate([ spacing/2, 0, 0]) shell_gold();
    }
}

module all_green() {
    color(green_c) {
        // Left coin (Sample 2): subtract vader, obverse text, s2 reverse text
        translate([-spacing/2, 0, 0])
            difference() {
                cylinder(h=total_h, r=field_r, $fn=128);
                black_vader_3d();
                white_obverse_text_3d();
                s2_white_reverse_3d();
            }
        // Right coin (Sample 1): subtract vader, obverse text, s1 reverse (siren + arc)
        translate([ spacing/2, 0, 0])
            difference() {
                cylinder(h=total_h, r=field_r, $fn=128);
                black_vader_3d();
                white_obverse_text_3d();
                s1_white_reverse_3d();
            }
    }
}

module all_white() {
    color(white_c) {
        // Obverse text (both coins)
        translate([-spacing/2, 0, 0]) white_obverse_text_3d();
        translate([ spacing/2, 0, 0]) white_obverse_text_3d();
        // Sample 2 reverse (left)
        translate([-spacing/2, 0, 0]) s2_white_reverse_3d();
        // Sample 1 reverse (right)
        translate([ spacing/2, 0, 0]) s1_white_reverse_3d();
    }
}

// === RENDER ===
if      (COLOR == 0) { all_black(); all_gold(); all_green(); all_white(); }
else if (COLOR == 1) { all_black(); }
else if (COLOR == 2) { all_gold(); }
else if (COLOR == 3) { all_green(); }
else if (COLOR == 4) { all_white(); }
