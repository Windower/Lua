function split_by_pipe(s)
	return s and type(s) == 'string' and string.split(s, '|') or L{}
end

function palette_settings_parser()
	palette_settings = config.load('overlays/MsJans/data/settings.xml', {
		default = {},
		everything_but_anchovies = {
			macros = 'Curaga I|Curaga II|Curaga III|Curaga IV|Curaga V|'
				.. 'Cure|Cure II|Cure III|Cure IV|Cure V|Cure VI',
			macro_labels = 'I|II|III|IV|V|1|2|3|4|5|6',

			buffs = 'Haste|Regen IV|Protect V|Shell V',
			buff_labels = 'Haste|Reg4|Pro5|She5',
			buff_icons = 'haste|regen iv|protect v|shell v',

			statuses = 'Poisona|Stona|Paralyna|Blindna',
			status_labels = 'Psn|Stn|Ppp|Bbb',
			status_icons = 'poisona|stona|paralyna|blindna',
		},
	}).default
	
	macro_order = {}

	macro_order.macro = split_by_pipe(palette_settings.macros)
	macro_order.macro_labels = split_by_pipe(palette_settings.macro_labels)

	macro_order.buff = split_by_pipe(palette_settings.buffs)
	macro_order.buff_labels = split_by_pipe(palette_settings.buff_labels)
	macro_order.buff_icons = split_by_pipe(palette_settings.buff_icons)

	macro_order.status = split_by_pipe(palette_settings.statuses)
	macro_order.status_labels = split_by_pipe(palette_settings.status_labels)
	macro_order.status_icons = split_by_pipe(palette_settings.status_icons)	
end

function measure_text_labels()
	local cat = settings.text.macro_buttons
	local measures
	
	if text_dimensions[cat.font] then
		if text_dimensions[cat.font][cat.font_size] then
			measures = text_dimensions[cat.font][cat.font_size]
		else
			measures = {}
			text_dimensions[cat.font][cat.font_size] = measures
		end
	else
		text_dimensions[cat.font] = {}
		measures = {}
		text_dimensions[cat.font][cat.font_size] = measures
	end
	
	-- check that dimensions are available for each label 
	local temp_texts = {}
	local measurement_neccessary = false

	for label, _  in macro_order.macro_labels:it() do
		if not measures[label] then	
			is_measurement_necessary = true
			
			temp_texts[label] = texts.new(label, {
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
					x = 50*_,
					y = 20*_,
				},
			})
			
			temp_texts[label]:show()
		end
	end
	
	if is_measurement_necessary then
		-- stall until the text is visible
		coroutine.sleep(1)

		-- measure the missing labels
		for label, text in pairs(temp_texts) do
			local w, h = text:extents()

			measures[label] = {x = w, y = h}

			text:destroy()
			temp_texts[label] = nil
		end
		
		-- add new dimensions to records
		text_dimensions = table.update(text_dimensions, temp_texts, true) -- last arg?
		
		-- format -> json and write to /data/textdb.json
		local json_file = files.new('overlays/MsJans/data/textdb.json')
		local font_json = L{}
		
		for font, size_bin in pairs(text_dimensions) do
		
			local size_json = L{}
			
			for font_size, label_bin in pairs(size_bin) do
			
				local label_json = L{}
				
				for label, dimension_bin in pairs(label_bin) do
					label_json:append('\n\t\t\t"' .. label .. '":{"x":' .. dimension_bin.x .. ',"y":' .. dimension_bin.y .. '}')
				end
				
				size_json:append('\n\t\t' .. font_size .. ':{' .. label_json:concat(',') .. '\n\t\t}')
			end
			
			font_json:append('"' .. font .. '":{' .. size_json:concat(',') .. '\n\t}')
		end
		
		json_file:write('{\n\t' .. font_json:concat(',\n\t') .. '\n}')
	end	
end

function load_text_dimensions()
	local path = 'overlays/MsJans/data/textdb.json'
	
	if files.exists(path) then
		text_dimensions = json.read(path) or {}
	else
		text_dimensions = {}
		local file = files.new(path)
		file:create()
	end
end

function update_all(bin, player)
	hp(bin, player.hp)
	tp(bin, player.tp)
	mp(bin, player.mp)
	hpp(bin, player.hpp)
	hpp_bar(bin, player.hpp)
	mpp_bar(bin, player.mpp)
	name(bin, player.name)
end

function check_display_state(n)
	return macro_grid[n] and true or false
end

function locate_macro(n)
	local grid = macro_grid[n]
	
	if grid then return grid:pos() end
end

function vertical_adjustment(party_number, up_or_down)
	local adjustment = (up_or_down and -1 or 1) * (settings.prim.unit_height + 1)

	-- bump the main display and palette
	for i = party_number, 3 do
		if check_display_state(i) then
			local grid = macro_grid[i]
			local x, y = grid:pos()
			
			grid:pos(x, y + adjustment)
			
			grid = palette_grid[i]
			
			if grid then
				x, y = grid:pos()
				grid:pos(x, y + adjustment)
			end
		else
			break
		end
	end
	
	-- bump the specials display
	if party_number == 1 then
		local grid = specials_grid
		
		if grid then
			local x, y = grid:pos()
			
			grid:pos(x, y + adjustment)
		end
	end
	
	--[[local h = settings.prim.unit_height + 1
	local adjust = (up_or_down and -1 or 1) * h
	
	if party_number == 1 then
		for _, obj in pairs(misc_bin) do
			obj:up(h)
		end
	end
	
	for i = party_number, 3 do
		if check_display_state(i) then
			local macro = macro[i]
			local labels_bin = macro.labels
			local labels_n = labels_bin[1] and #labels_bin[1]
			local display = macro.display
			local slots = #display
			
			local x, y = locate_macro(i)
			x, y = x, y + adjust
			
			macro_grid[i]:pos(x, y)
			
			if bg[i] then
				bg[i]:pos(x, y)
			end
			
			if labels_n then
				for i = 1, slots do
					local labels = labels_bin[i]
					
					for j = 1, labels_n do
						labels[j]:up(h)
					end
				end
			end
			
			for i = 1, slots do
				for _, obj in pairs(display[i]) do
					obj:up(h)
				end				
			end
			
			if settings.prim.show_macro_button_background then
				local buttons_bin = macro.buttons
				local buttons_n = #macro.buttons[1]
		
				for i = 1, slots do
					local buttons = buttons_bin[i]
					
					for j = 1, buttons_n do
						buttons[j]:up(h)
					end
				end
			end
			
			-- display needs to use up: too cluttered to recalculate positions
			-- buttons and labels can all be calculated
			-- bg should be checked for existance before adjustment
			
		else
			break
		end
	end--]]
end
