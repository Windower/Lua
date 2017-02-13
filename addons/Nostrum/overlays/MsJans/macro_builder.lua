macro_builder = {}

macro_builder.new_party = function(alliance_spot)
	local macro = macro[alliance_spot]
	macro.display = macro.display or {}
	macro.labels = macro.labels or {}
	macro.buttons = macro.buttons or {}
	local bar_width = settings.prim.bar_width

	
	-- jump to the display's position
	local y = windower_settings.y_res - settings.location.y_offset
	local x = windower_settings.x_res - settings.location.x_offset - bar_width - 2
	
	for i = alliance_spot-1, 1, -1 do
		y = y - alliance[i].count() * (settings.prim.unit_height+1) - 1 
			- ({
				settings.distance_between_parties_one_and_two,
				settings.distance_between_parties_two_and_three,
			})[i]
	end
	
	-- build the display grid
	local count = alliance[alliance_spot].count()
	local w, h = bar_width + 2, (settings.prim.unit_height + 1) * count + 1
	
	local mgrid = grids.new(x, y, w, h, 1, 0) -- set columns to 0: new_player will ++

	macro_grid[alliance_spot] = mgrid

	if settings.prim.bg.visible then
		macro_builder.bg(x, y, w, 0, alliance_spot)
		mgrid:add(bg[alliance_spot])
	end
	
	-- build the palette grid (if there is a palette)
	local macro_count = macro_order.macro_labels.n
	
	if macro_count > 0 then
		local palette_settings = settings.prim.palette.main
		local width = settings.prim.palette.main.buttons.width
		local macro_x = x - macro_count * (width + 1) - 1
		local sgrid = grids.new(
			macro_x,
			y, 
			width,
			settings.prim.unit_height,
			macro_count,
			0
		)
		
		if palette_settings.background_visible then
			local background = prims.new({
				pos = {macro_x, y},
				w = macro_count * (width + 1) + 1,
				color = settings.prim.bg.color,
				h = h,
				visible = true,
			})
			
			sgrid:add(background)
			
			macro.palette_bg = background
		end
		
		palette_grid[alliance_spot] = sgrid
	end
	--widgets.track(grid, x, y, w, h)
	-- store buttons in the grid.
	
	
	for i = 1, count do
		local h = settings.prim.unit_height
		local y = y + h * (i - 1)
		
		--grid[i] = buttons.new(x, y, w, h, true)
		--widgets.allow_focus(grid[i])
		-- this bit should be under new_player
		
		--register buttons to grid, run some function?
	end
end

macro_builder.bg = function(x, y, w, h, spot)
	local background = prims.new({
        pos = {x, y},
        w = w,
        color = settings.prim.bg.color,
        h = h,
        visible = true,
    })
	
	bg[spot] = background
end

macro_builder.new_player = function(party, position)
	local bin = {}
	local unit_height = settings.prim.unit_height
	local bar_width = settings.prim.bar_width
	local grid = macro_grid[party]
	
	if bg[party] then
		bg[party]:height((unit_height+1) * position + 1)
	end
	
	if macro[party].palette_bg then
		macro[party].palette_bg:height((unit_height+1) * position + 1)
	end
	
	widget_lookup[party][position] = bin
	
	local x = windower_settings.x_res - settings.location.x_offset - bar_width - 2
	local y = grid:pos_y() + (unit_height + 1)*(position-1)-- - settings.location.y_offset
	local cat
	local player = alliance[party][position]
	
	for _, stat in pairs{'hp', 'tp', 'mp', 'hpp', 'name'} do
		cat = settings.text[stat]
		
		if cat.visible then
			bin[stat] = texts.new(tostring(player[stat]), {
				text = {
					size = cat.font_size,
					font = cat.font,
				},
				flags = {
					bold = cat.bold,
					right = cat.right_justified,
					draggable = false,
				},
				bg = {
					visible = false,
				},
				pos = {
					x = (cat.right_justified and -settings.location.x_offset or x) + cat.offset.x,
					y = y + cat.offset.y,
				},
			})
			
			bin[stat]:show()
			grid:add(bin[stat])
		end
	end
	
	name(bin, player.name)
	
	bin.phpp = prims.new({
        pos = {x+1, y+1},
        w = bar_width * player.hpp / 100,
        color = settings.prim.hp[math.ceil(player.hpp/25) * 25],
        h = unit_height,
        visible = true,
        image = false,
    })
	
	bin.pmpp = prims.new({
        pos = {x + 1, y + unit_height - settings.prim.mp.height},
        w = bar_width * player.mpp / 100,
        color = settings.prim.mp.color,
        h = settings.prim.mp.height,
        visible = true,
        image = false,
    })
	
	grid:add(bin.phpp)
	grid:add(bin.pmpp)
	
	macro[party].display[position] = bin
	
	grid:new_row()
	--grid[position] = buttons.new(x, y, bar_width, unit_height)
	
	macro_builder.palette(party, position, x, y)
	vertical_adjustment(party, true)	
end

macro_builder.header = function()
	local grid = macro_grid[1]
	local y = grid:pos_y()
	local x = windower_settings.x_res - settings.location.x_offset - 2
	local cat = settings.text.name
	local bar_width = settings.prim.bar_width
	
	misc_bin.header_text = texts.new('menu', {
		text = {
			size = cat.font_size,
			font = cat.font,
		},
		flags = {
			bold = cat.bold,
			right = false,
			draggable = false,
		},
		bg = {
			visible = false,
		},
		pos = {
			x = x - 94,	--adjust for modified name.size setting... Font will need to be measured and header resized.
			y = y - 18,
		},
	})
	
	misc_bin.header_text:show()

	misc_bin.header = prims.new({
		pos = {x - bar_width, y - 20},
		w = bar_width + 2,
		color = settings.prim.bg.color,
		h = 20,
		visible = settings.prim.bg.visible,
	})
	
	grid:add(misc_bin.header)
	grid:add(misc_bin.header_text)
end

macro_builder.palette = function(party, position, x, y)
	if not (macro_order.macro.n > 0) then return end
	
	y = y + 1
	local labels = {}
	local buttons = {}
	local height = settings.prim.unit_height
	local width = settings.prim.palette.main.buttons.width
	local grid = palette_grid[party] -- this should be the palette grid
	
	x = x - macro_order.macro_labels.n * (width + 1) - 1
	
	local mbutton_settings = settings.prim.palette.main.buttons
	
	if mbutton_settings.background_visible then
		local x, y = x, y
		
		for i = 1, macro_order.macro.n do
			buttons[i] = prims.new({
				pos = {x + 1, y},
				w = width,
				color = mbutton_settings.color,
				h = height,
				visible = true,
				image = false,
			})

			x = x + width + 1

			grid:add(buttons[i])
		end
	end
	
	local cat = settings.text.macro_buttons
	local label_dimensions = text_dimensions[cat.font][cat.font_size]
	for label, n in macro_order.macro_labels:it() do
		labels[n] = texts.new(label, {
			text = {
				size = cat.font_size,
				font = cat.font,
			},
			flags = {
				bold = cat.bold,
				right = cat.right_justified,
				draggable = false,
			},
			bg = {
				visible = false,
			},
			pos = {
				x = x + (width-label_dimensions[label].x)/2 + 1,
				y = y + (height-label_dimensions[label].y)/2,
			},
		})
		
		x = x + width + 1
		
		labels[n]:show()
		grid:add(labels[n])
	end
	
	macro[party].labels[position] = labels
	macro[party].buttons[position] = buttons
end

macro_builder.specials = function()
	if macro_order.status:empty() and macro_order.buff:empty() then return end
	
	local x, y = locate_macro(1)
	local prim_settings = settings.prim.palette.specials
	local button_settings = prim_settings.buttons
	local height, width = button_settings.height, button_settings.width
	
	-- create specials grid
	local grid_rows = math.max(macro_order.status.n, macro_order.buff.n)
	local grid_columns = (macro_order.status.n > 0 and 1 or 0) 
		+ (macro_order.buff.n > 0 and 1 or 0)
	local grid = grids.new(
		x - (grid_rows * (width + 1) + 1), 
		y - height * grid_columns - 2, 
		width, 
		height, 
		grid_rows, 
		grid_columns
	)
	
	specials_grid = grid

	-- create specials display
	for spell_type, n in L{'status', 'buff'}
		:filter(function(s) return macro_order[s].n > 0 end)
		:it() do
	
		local macro = macro_order[spell_type]
		local bg_width = macro.n * (width + 1) + 1
		local x, y = x - bg_width, y - height * n - 2
	
		-- build the background
		if prim_settings.background_visible then
			local background = prims.new({
				pos = {x, y},
				w = bg_width,
				color = settings.prim.bg.color,
				h = height + 2, -- -1?
				visible = true,
			})
			
			grid:add(background)
		end
		
		-- build the button outlines
		if button_settings.background_visible then
			local x, y = x, y
			
			for i = 1, macro.n do
				local button = prims.new({
					pos = {x + 1, y + 1},
					w = width,
					color = button_settings.color,
					h = height,
					visible = true,
					image = false,
				})
				
				x = x + width + 1

				grid:add(button)				
			end
		end
		
		-- build the images
		if button_settings.images_visible then
			local x, y = x, y
			local path = addon_path .. 'icons/'
			local icons_key = spell_type .. '_icons'

			for i = 1, macro.n do
				local icon = prims.new({
					pos = {x + 1, y + 1},
					w = width,
					h = height,
					visible = true,
					set_texture = true,
					texture = path .. macro_order[icons_key][i] .. '.png',
					fit_texture = false,
				})
				
				x = x + width + 1

				grid:add(icon)				
			end
		end
		
		-- build the text labels
		if settings.text.specials.visible then
			local x, y = x, y
			local cat = settings.text.specials
			local labels_key = spell_type .. '_labels'
			
			for i = 1, macro.n do
				local label = texts.new(macro_order[labels_key][i], {
					text = {
						size = cat.font_size,
						font = cat.font,
						stroke = {
							width = 1,
						}
					},
					flags = {
						bold = cat.bold,
						right = cat.right_justified,
						draggable = false,
					},
					bg = {
						visible = false,
					},
					pos = {
						x = x + 1,
						y = y + 1,
					},
				})
				
				x = x + width + 1
				label:show()
				grid:add(label)				
			end
		end
		
		-- build buttons
		do
			local x, y = x, y
			local offset = grid_rows - macro.n
			
			for i = 1, macro.n do
				local button = buttons.new(
					x + 1,
					y + 1,
					width + 1,
					height + 1, -- + 1?
					true
				)
				
				x = x + width + 1
				
				--[[
					widgets.track grid
				]]
				grid[n][i + offset] = button
				grid:add(button)			
			end
		end
	end
end