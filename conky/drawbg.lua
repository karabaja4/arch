local bg_colour = 0x000000
local bg_alpha = 0.2

require 'cairo'
local cs, cr = nil

local function rgb_to_r_g_b(colour, alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function conky_draw_bg()

	if conky_window == nil then return end
	if cs == nil then cairo_surface_destroy(cs) end
	if cr == nil then cairo_destroy(cr) end

	local w = conky_window.width
	local h = conky_window.height
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	local cr = cairo_create(cs)
	
	cairo_move_to(cr, 0, 0)
	cairo_line_to(cr, w, 0)
	cairo_curve_to(cr, w, 0, w, 0, w, 0)
	cairo_line_to(cr, w, h)
	cairo_curve_to(cr, w, h, w, h, w, h)
	cairo_line_to(cr, 0, h)
	cairo_curve_to(cr, 0, h, 0, h, 0, h)
	cairo_line_to(cr, 0, 0)
	cairo_curve_to(cr, 0, 0, 0, 0, 0, 0)
	cairo_close_path(cr)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(bg_colour, bg_alpha))
	cairo_fill(cr)

	cairo_surface_destroy(cs)
	cairo_destroy(cr)
end