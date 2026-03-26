// McCloud Bux Platinum Challenge Coin — DOUBLE-SIDED
// $1,000,000 Platinum Coin — 100mm oversized display piece
// Single print, no glue. Bambu P1S + AMS Pro 2 (4 colors)
//
// Obverse (top): Pencil sketch portrait + "HISTORIAE ET FIDEI" / "MMXXVI"
// Reverse (bottom): Kawaii capybara + "McCLOUD BUX" / "ONE MILLION"
//
// Each color part has NO overlap with any other.
// Gray (base layer) uses difference() to subtract all other colors.
//
// COLOR selects which filament layer to render:
//   0 = All (preview)
//   1 = Black (#1A1A1A)    — Rim, portrait lines, capybara details
//   2 = Brown (#A07A56)    — Capybara body
//   3 = Light Gray (#8F9694) — Field (base layer)
//   4 = White (#FFFFFF)    — Accent ring, portrait disc, text, capybara nose

COLOR = 0;

// === DIMENSIONS ===
coin_d = 100;
total_h = 8.0;
rim_w = 5.0;
accent_w = 2.4;
relief = 1.0;

// Derived
inner_r = coin_d/2 - rim_w;       // 45mm
field_r = inner_r - accent_w;      // 42.6mm
text_r = field_r - 4;              // 38.6mm

// Portrait disc
portrait_r = 27;

// Capybara scale: without viewBox, raw paths import at 96 DPI
// Raw width ~75mm. Target ~30mm → scale ≈ 0.4
capy_scale = 0.4;

// Portrait scale (SVG is 1024x1024pt = 361.27mm; target ~43mm)
portrait_scale = 0.119;

// === COLORS (Overture PLA) ===
black_c   = [0.10, 0.10, 0.10];
brown_c   = [0.63, 0.48, 0.34];   // Overture Brown #A07A56
gray_c    = [0.56, 0.59, 0.58];   // Overture Light Gray #8F9694
white_c   = [1.0, 1.0, 1.0];

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

// Portrait sketch — black line art (imported SVG)
module portrait_sketch_2d() {
    scale([portrait_scale, portrait_scale])
        import("portrait_sketch.svg", center=true);
}

// Obverse white text (top face)
module obverse_white_text_2d() {
    // Top: HISTORIAE ET FIDEI (18 chars)
    // char_angle=9.0 → ~6.1mm arc gap at r=38.6; start=(17/2)*9=76.5→77 centers at top
    arc_text("HISTORIAE ET FIDEI",
             radius=text_r, size=6.0,
             start_angle=77, char_angle=9.0);

    // Bottom: MMXXVI (6 chars)
    // start=-(5/2)*9=-22.5→-23 centers at bottom
    bottom_arc_text("MMXXVI",
                    radius=text_r, size=6.0,
                    start_angle=-23, char_angle=9.0);
}

// =================================================================
// REVERSE DESIGN (bottom face)
// =================================================================

// Capybara body — brown (bottom face)
module capybara_body_2d() {
    mirror([1, 0, 0])
        scale([capy_scale, capy_scale])
            import("capybara_body.svg", center=true);
}

// Capybara details — black (ears, snout, feet, fur marks)
module capybara_details_2d() {
    mirror([1, 0, 0])
        scale([capy_scale, capy_scale])
            import("capybara_details.svg", center=true);
}

// Capybara nose — white
module capybara_nose_2d() {
    mirror([1, 0, 0])
        scale([capy_scale, capy_scale])
            import("capybara_nose.svg", center=true);
}

// Reverse white text (bottom face)
module reverse_white_text_2d() {
    mirror([1, 0, 0]) {
        // Top: McCLOUD BUX (11 chars)
        // char_angle=9.0 → ~6.1mm arc gap; start=(10/2)*9=45 centers at top
        arc_text("McCLOUD BUX",
                 radius=text_r, size=6.0,
                 start_angle=45, char_angle=9.0);

        // Bottom: ONE MILLION (11 chars)
        // start=-(10/2)*9=-45 centers at bottom
        bottom_arc_text("ONE MILLION",
                        radius=text_r, size=6.0,
                        start_angle=-45, char_angle=9.0);

        // Flat purity/mint marks — lower-right field (under capybara rump)
        // Negative x inside mirror = left in Bambu; positive x = right in Bambu
        translate([20, -20, 0])
            text("FINE PLATINUM", size=3.5, font="Arial:style=Bold",
                 halign="center", valign="center");
        translate([20, -25, 0])
            text("HS", size=3.0, font="Arial:style=Bold",
                 halign="center", valign="center");
    }
}

// =================================================================
// 3D SHAPES
// =================================================================

// --- Obverse (top face) ---
// Portrait clipped to portrait disc so nothing extends beyond
module portrait_sketch_3d() {
    intersection() {
        translate([0, 0, total_h - relief])
            linear_extrude(height=relief)
                portrait_sketch_2d();
        translate([0, 0, total_h - relief - 0.01])
            cylinder(h=relief+0.1, r=portrait_r, $fn=128);
    }
}

module white_obverse_text_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_white_text_2d();
}

// --- Reverse (bottom face) ---
// All capybara parts clipped to field radius so nothing extends beyond coin edge
module capybara_body_3d() {
    intersection() {
        linear_extrude(height=relief)
            capybara_body_2d();
        cylinder(h=relief+0.1, r=field_r, $fn=200);
    }
}

module capybara_details_3d() {
    intersection() {
        linear_extrude(height=relief)
            capybara_details_2d();
        cylinder(h=relief+0.1, r=field_r, $fn=200);
    }
}

module capybara_nose_3d() {
    intersection() {
        linear_extrude(height=relief)
            capybara_nose_2d();
        cylinder(h=relief+0.1, r=field_r, $fn=200);
    }
}

module white_reverse_text_3d() {
    linear_extrude(height=relief)
        reverse_white_text_2d();
}

// =================================================================
// COLOR LAYERS — NO OVERLAP
// =================================================================

// 1. BLACK: rim + portrait sketch lines + capybara details
module black_parts() {
    color(black_c) {
        // Outer rim ring
        difference() {
            cylinder(h=total_h, d=coin_d, $fn=200);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=inner_r, $fn=200);
        }
        // Portrait sketch on top face
        portrait_sketch_3d();
        // Capybara details on bottom face
        capybara_details_3d();
    }
}

// 2. BROWN: capybara body only (reverse)
module brown_parts() {
    color(brown_c) {
        // Capybara body minus detail overlaps
        difference() {
            capybara_body_3d();
            capybara_details_3d();
            capybara_nose_3d();
        }
    }
}

// 3. LIGHT GRAY: field (base layer — subtracts everything else)
module gray_parts() {
    color(gray_c) {
        difference() {
            cylinder(h=total_h, r=field_r, $fn=200);
            // Subtract portrait disc area (obverse only — leave reverse face for capybara)
            translate([0, 0, relief])
                cylinder(h=total_h - relief + 0.01, r=portrait_r, $fn=128);
            // Subtract obverse white text
            white_obverse_text_3d();
            // Subtract portrait sketch lines
            portrait_sketch_3d();
            // Subtract capybara body (bottom face)
            capybara_body_3d();
            // Subtract capybara details
            capybara_details_3d();
            // Subtract capybara nose
            capybara_nose_3d();
            // Subtract reverse white text
            white_reverse_text_3d();
        }
    }
}

// 4. WHITE: accent ring + portrait disc + all text + capybara nose
module white_parts() {
    color(white_c) {
        // Accent ring
        difference() {
            cylinder(h=total_h, r=inner_r, $fn=200);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=field_r, $fn=200);
        }
        // Portrait disc (white circle, sketch lines subtracted)
        // Starts above relief height so it doesn't cover the reverse (capybara) face
        difference() {
            translate([0, 0, relief])
                cylinder(h=total_h - relief, r=portrait_r, $fn=128);
            portrait_sketch_3d();
        }
        // Obverse text
        white_obverse_text_3d();
        // Reverse text
        white_reverse_text_3d();
        // Capybara nose
        capybara_nose_3d();
    }
}

// === RENDER ===
if (COLOR == 0) {
    black_parts();
    brown_parts();
    gray_parts();
    white_parts();
} else if (COLOR == 1) {
    black_parts();
} else if (COLOR == 2) {
    brown_parts();
} else if (COLOR == 3) {
    gray_parts();
} else if (COLOR == 4) {
    white_parts();
}
