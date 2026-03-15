// =====================================================================
// Chattahoochee Gold Swimming — Challenge Coin
// Double-sided · 50mm · 3-color · Bambu P1S + AMS Pro 2
//
// AMS Slots:
//   1 = Gold   (#FFD324) — rim + trident (obverse) + swimmer (reverse)
//   2 = Navy   (#000B39) — inner field both faces (base layer)
//   3 = White  (#FFFFFF) — all arc text
//
// Obverse (top):  trident (tilted, held at angle) + arc text + 2026
// Reverse (bottom): swimmer silhouette + arc text
// =====================================================================

COLOR = 0;

// === DIMENSIONS ===
coin_d          = 50;
coin_r          = coin_d / 2;
total_h         = 5.0;
rim_w           = 2.5;
relief          = 0.6;
trident_relief  = 1.2;   // trident raised higher for punch
$fn             = 120;

inner_r = coin_r - rim_w;   // 22.5
text_r  = inner_r - 2.8;    // 19.7

// === COLORS ===
gold_c  = [1.000, 0.851, 0.141];
navy_c  = [0.000, 0.043, 0.224];
white_c = [1.000, 1.000, 1.000];

// =====================================================================
// TRIDENT — parametric, no SVG
//
// Classical proportions: handle ≈ half total height, tines slim & tall
// Held at angle: rotate tr_tilt degrees CW (like it's being carried)
// =====================================================================

tr_handle_w  =  1.6;   // fine shaft
tr_handle_h  = 16.0;   // long handle — dominant lower half
tr_bar_w     = 10.5;   // narrow crossbar
tr_bar_h     =  1.4;
tr_bar_r     =  0.70;

tr_ctr_w     =  1.8;   // very slim center prong
tr_ctr_h     = 10.0;   // tine height above crossbar
tr_ctr_taper =  6.5;   // long taper = light elegant tip

// Side prongs — slim, upright, light
tr_s_bx_in   =  1.8;   // inner edge
tr_s_bx_out  =  4.0;   // outer edge (narrow = no wings)
tr_s_tx      =  3.6;   // tip x
tr_s_ty      =  9.0;   // tip y (tall)
tr_s_tw      =  0.30;  // near-point tip
tr_s_out_bow =  0.5;   // very subtle bow
tr_s_in_pull =  1.8;   // concave inner edge

tr_tilt      = -20;    // degrees CW — "being held" angle

// --- Bezier helpers ---
function _bz(a, b, c, t) = (1-t)*(1-t)*a + 2*(1-t)*t*b + t*t*c;
function bz2(p0, p1, p2, t) = [_bz(p0[0],p1[0],p2[0],t),
                                 _bz(p0[1],p1[1],p2[1],t)];
function bz_pts(p0, p1, p2, n=20) = [for (i=[0:n]) bz2(p0, p1, p2, i/n)];

module trident_2d() {
    ybar = tr_handle_h;
    ycbt = ybar + tr_bar_h;

    union() {
        // Handle shaft — long, slim
        translate([-tr_handle_w/2, 0])
            square([tr_handle_w, tr_handle_h]);

        // Crossbar — pill shape
        hull() {
            translate([-tr_bar_w/2 + tr_bar_r, ybar + tr_bar_r])
                circle(r=tr_bar_r, $fn=32);
            translate([ tr_bar_w/2 - tr_bar_r, ybar + tr_bar_r])
                circle(r=tr_bar_r, $fn=32);
            translate([-tr_bar_w/2 + tr_bar_r, ybar + tr_bar_h - tr_bar_r])
                circle(r=tr_bar_r, $fn=32);
            translate([ tr_bar_w/2 - tr_bar_r, ybar + tr_bar_h - tr_bar_r])
                circle(r=tr_bar_r, $fn=32);
        }

        // Center prong — slim spear, long elegant taper
        {
            hw = tr_ctr_w / 2;
            y0 = ycbt;
            y1 = ycbt + tr_ctr_h;
            ys = y1 - tr_ctr_taper;
            polygon([
                [ 0,   y1],
                [ hw,  ys],
                [ hw,  y0],
                [-hw,  y0],
                [-hw,  ys],
            ]);
        }

        // Side prongs — slim, upright swept arms
        right_prong(ycbt);
        mirror([1,0]) right_prong(ycbt);
    }
}

module right_prong(ycbt) {
    bxi = tr_s_bx_in;
    bxo = tr_s_bx_out;
    tx  = tr_s_tx;
    ty  = ycbt + tr_s_ty;
    tw  = tr_s_tw;
    mid = ycbt + tr_s_ty * 0.48;

    outer = bz_pts(
        [bxo,                  ycbt],
        [bxo + tr_s_out_bow,   mid ],
        [tx + tw,              ty  ], 20
    );
    inner = bz_pts(
        [tx - tw,              ty  ],
        [bxi + tr_s_in_pull,   mid ],
        [bxi,                  ycbt], 20
    );
    polygon(concat(outer, inner));
}

// Trident centered on coin face, tilted at angle
tr_total_h = tr_handle_h + tr_bar_h + tr_ctr_h;

module obverse_trident_2d() {
    // Center trident vertically (shift handle base down so full height centers)
    // then tilt to "held at angle"
    rotate([0, 0, tr_tilt])
        translate([0, -(tr_total_h * 0.46)])
            trident_2d();
}

// =====================================================================
// TEXT HELPERS
// =====================================================================

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

// =====================================================================
// OBVERSE 2D — trident + arc text + year
// =====================================================================

module obverse_text_2d() {
    // "CHATTAHOOCHEE GOLD" — 18 chars, top arc
    arc_text("CHATTAHOOCHEE GOLD",
             radius=text_r, size=2.3,
             start_angle=61, char_angle=7.2);

    // "WOODSTOCK" — bottom arc
    bottom_arc_text("WOODSTOCK",
                    radius=text_r, size=2.3,
                    start_angle=-32, char_angle=8.0);
}

// =====================================================================
// REVERSE 2D — swimmer + arc text
// All wrapped in mirror([1,0,0]) for correct read when coin is flipped
// =====================================================================

swimmer_scale = 0.62;

module reverse_swimmer_2d() {
    mirror([1, 0, 0])
        translate([0, 2])
            scale([swimmer_scale, swimmer_scale])
                import("swimmer.svg", center=true);
}

module reverse_text_2d() {
    mirror([1, 0, 0]) {
        // "CHATTAHOOCHEE GOLD" — top arc
        arc_text("CHATTAHOOCHEE GOLD",
                 radius=text_r, size=2.3,
                 start_angle=61, char_angle=7.2);

        // "2026 SWIM TEAM" — bottom arc
        bottom_arc_text("2026 SWIM TEAM",
                        radius=text_r, size=2.3,
                        start_angle=-44, char_angle=7.2);
    }
}

// =====================================================================
// 3D SHAPES
// =====================================================================

module gold_trident_3d() {
    translate([0, 0, total_h - trident_relief])
        linear_extrude(height=trident_relief)
            obverse_trident_2d();
}

module gold_swimmer_3d() {
    linear_extrude(height=trident_relief)   // same height as trident for visibility
        reverse_swimmer_2d();
}

module white_obverse_3d() {
    translate([0, 0, total_h - relief])
        linear_extrude(height=relief)
            obverse_text_2d();
}

module white_reverse_3d() {
    linear_extrude(height=relief)
        reverse_text_2d();
}

// =====================================================================
// COLOR LAYERS — zero overlap
// =====================================================================

// 1. GOLD: rim + trident (obverse) + swimmer (reverse)
module gold_parts() {
    color(gold_c) {
        // Rim ring
        difference() {
            cylinder(h=total_h, d=coin_d, $fn=128);
            translate([0, 0, -0.01])
                cylinder(h=total_h+0.02, r=inner_r, $fn=128);
        }
        // Trident on obverse
        gold_trident_3d();
        // Swimmer on reverse
        gold_swimmer_3d();
    }
}

// 2. NAVY: inner field — base layer, all detail subtracted out
module navy_parts() {
    color(navy_c) {
        difference() {
            cylinder(h=total_h, r=inner_r, $fn=128);
            // Trident (higher relief — subtract deeper)
            translate([0, 0, total_h - trident_relief - 0.02])
                linear_extrude(height=trident_relief + 0.04)
                    obverse_trident_2d();
            // Obverse text
            translate([0, 0, total_h - relief - 0.02])
                linear_extrude(height=relief + 0.04)
                    obverse_text_2d();
            // Reverse swimmer (at bottom face, same relief as trident)
            translate([0, 0, -0.02])
                linear_extrude(height=trident_relief + 0.04)
                    reverse_swimmer_2d();
            // Reverse text
            translate([0, 0, -0.02])
                linear_extrude(height=relief + 0.04)
                    reverse_text_2d();
        }
    }
}

// 3. WHITE: obverse arc text + reverse arc text
module white_parts() {
    color(white_c) {
        white_obverse_3d();
        white_reverse_3d();
    }
}

// === RENDER ===
if      (COLOR == 0) { gold_parts(); navy_parts(); white_parts(); }
else if (COLOR == 1) { gold_parts(); }
else if (COLOR == 2) { navy_parts(); }
else if (COLOR == 3) { white_parts(); }
