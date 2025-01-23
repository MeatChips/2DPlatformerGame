// Draw GUI
draw_set_font(fnt_game);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var healthText = "Health: " + string(hp);
draw_text(100, 50, healthText);
