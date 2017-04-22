--[[Copyright © 2014-2017, trv
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Nostrum nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL trv BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER I N CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.--]]

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
					color = {a = 200, r = 0, g = 0, b = 0},
				},
				background_visible = true
			},
			specials = {
				buttons = {
					width = 25,
					height = 25,
					background_visible = false,
					color = {a = 200, r = 0, g = 0, b = 0},
					images_visible = true,
				},
				background_visible = true,
			},
			highlight = {
				color = {a = 100, r = 255, g = 255, b = 255},
				visible = true,
			},
		},
		bar_width = 150,
		bg = {
			visible=true,
            color = {a = 200, r = 0, g = 0, b = 0},
			visible_for_specials = true,
		},
		hp = {
			--a = 176, -- uncomment for a bug
			[100] = {a = 176, r = 1, g = 100, b = 14},
			[75] = {a = 176, r = 255, g = 255, b = 0},
			[50] = {a = 176, r = 255, g = 100, b = 1},
			[25] = {a = 176, r = 255, g = 0, b = 0},
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
