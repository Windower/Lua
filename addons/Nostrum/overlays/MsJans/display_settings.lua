settings = {
    text = {
        macro_buttons = {
            bold = true,
            font = "Times",
            --visible = true,
            font_size = 15,
            right_justified = false
        },
        name = {
            bold = true,
            font = "Consolas",
            font_size = 10,
			truncate = 10,
            offset = {x = 0, y = -3},
			visible = true,
            right_justified = false
        },
        tp = {
            bold = true,
            font = "Consolas",
            font_size = 10,
            offset = {x = 0, y = 11},
			visible = true,
            right_justified = false
        },
        hp = {
            bold = true,
            font = "Consolas",
            font_size = 10,
            offset = {x = -42, y = -3},
			visible = true,
            right_justified = true
        },
        mp = {
            bold = true,
            font = "Consolas",
            font_size = 10,
            offset = {x = -42, y = 11},
			visible = true,
            right_justified = true    
        },
        hpp = {
            bold = true,
            font = "Times",
            font_size = 20,
            offset = {x = 0, y = -2},
			visible = true,
            right_justified = true
        },
        specials = {
            bold = true,
            font = "Times",
            font_size = 9,
            offset = {x = 0, y = 0},
			visible = true,
            right_justified = false
        },
    },
	prim = {
		unit_height = 25,
		palette = {
			main = {
				buttons = {
					width = 30,
					background_visible = false,
					color={a=200, r=0, g=0, b=0},
				},
				background_visible = true
			},
			specials = {
				buttons = {
					width = 25,
					height = 25,
					background_visible = false,
					color={a=200, r=0, g=0, b=0},
					images_visible = true,
				},
				background_visible = true,
			},
		},
		bar_width = 150,
		bg = {
			visible=true,
            color={a=200, r=0, g=0, b=0},
			visible_for_specials = true,
		},
		hp = {
			--a = 176,
			[100] = {a=176, r=1, g=100, b=14},
			[75] = {a=176, r=255, g=255, b=0},
			[50] = {a=176, r=255, g=100, b=1},
			[25] = {a=176, r=255, g=0, b=0},
		},
		mp = {
			color = {a = 100, r = 149, g = 212, b = 255},
			height = 5,
		},
		target = {
			create_target_display = true,
			height = 30,
			width = 150,
		},
		buffs = {
			display_party_buffs = false,
			display_p0_buffs = false,
		},
	},
	distance_between_parties_one_and_two = 100,
	distance_between_parties_two_and_three = 25,
	location = {
		x_offset = 0,
		y_offset = 0,
	},
}
