function export_set(options)
	local temp_items,item_list = get_items(),{}
	local targinv,xml,all_sets
	if #options > 0 then
		for _,v in pairs(options) do
			if v:lower() == 'inventory' then
				targinv = true
			elseif v:lower() == 'xml' then
				xml = true
			elseif v:lower() == 'sets' then
				all_sets = true
			end
		end
	end
	
	if not windower.dir_exists(lua_base_path..'data/export') then
		windower.create_dir(lua_base_path..'data/export')
	end
	
	local inv = temp_items['inventory']
	if targinv then
		-- Load the entire inventory
		for _,v in pairs(inv) do
			if v.id ~= 0 then
				if r_items[v.id] then
					item_list[#item_list+1] = {}
					item_list[#item_list].name = r_items[v.id][language]
					item_list[#item_list].slot = 'item'
				else
					add_to_chat(123,'GearSwap: You possess an item that is not in the resources yet.')
				end
			end
			for i = 1,80 do
				if not item_list[i] then
					item_list[i] = {}
					item_list[i].name = 'empty'
					item_list[i].slot = 'item'
				end
			end
		end
	elseif all_sets then
		-- Iterate through user_env.sets and find all the gear.
		item_list = unpack_names('L1',user_env.sets,{})
	else
		-- Default to loading the currently worn gear.
		local gear = temp_items['equipment']
		for i,v in pairs(gear) do
			if v ~= 0 then
				if r_items[inv[v].id] then
					item_list[slot_map[i]+1] = {}
					item_list[slot_map[i]+1].name = r_items[inv[v].id][language]
					item_list[slot_map[i]+1].slot = i --default_slot_map[inv[v].slot_id]
				else
					add_to_chat(123,'GearSwap: You are wearing an item that is not in the resources yet.')
				end
			end
		end
		for i = 1,16 do
			if not item_list[i] then
				item_list[i] = {}
				item_list[i].name = 'empty'
				item_list[i].slot = default_slot_map[i-1]
			end
		end
	end
	
	if #item_list == 0 then
		add_to_chat(123,'GearSwap: There is nothing to export.')
		return
	else
		local not_empty
		for i,v in pairs(item_list) do
			if v.name ~= 'empty' then
				not_empty = true
				break
			end
		end
		if not not_empty then
			add_to_chat(123,'GearSwap: There is nothing to export.')
			return
		end
	end
	
	local path = lua_base_path..'data/export/'..player.name..os.date(' %H %M %S%p  %y-%d-%m')
	if xml then
		-- Export in .xml
		if windower.file_exists(path..'.xml') then
			path = path..' '..os.clock()
		end
		local f = io.open(path..'.xml','w+')
		f:write('<spellcast>\n  <sets>\n    <group name="exported">\n      <set name="exported">\n')
		for i,v in ipairs(item_list) do
			if v.name ~= 'empty' then
				f:write('        <'..v.slot..'>'..v.name..'</'..v.slot..'>\n')
			end
		end
		f:write('      </set>\n    </group>\n  </sets>\n</spellcast>')
		f:close()
	else
		-- Default to exporting in .lua
		if windower.file_exists(path..'.lua') then
			path = path..' '..os.clock()
		end
		local f = io.open(path..'.lua','w+')
		f:write('sets.exported={\n')
		for i,v in ipairs(item_list) do
			if v.name ~= 'empty' then
				f:write('    '..v.slot..'="'..v.name..'",\n')
			end
		end
		f:write('}')
		f:close()
	end
end

function unpack_names(up,tab_level,unpacked_table)
	for i,v in pairs(tab_level) do
		if type(v)=='table' then
			unpacked_table = unpack_names(i,v,unpacked_table)
		elseif i=='name' then
			unpacked_table[#unpacked_table+1] = {}
			unpacked_table[#unpacked_table].slot = up
			unpacked_table[#unpacked_table].name = unlogify_unpacked_name(v)
		elseif type(v) == 'string' and v~='augment' and v~= 'augments' then
			unpacked_table[#unpacked_table+1] = {}
			unpacked_table[#unpacked_table].slot = i
			unpacked_table[#unpacked_table].name = unlogify_unpacked_name(v)
		end
	end
	return unpacked_table
end

function unlogify_unpacked_name(name)
	for i,v in pairs(r_items) do
		if type(v) == 'table' then
			if not v[language..'_log'] then
				add_to_chat(8,'v = '..tostring(v.english))
			elseif v[language..'_log']:lower() == name:lower() then
				return v[language]
			end
		end
	end
	return name
end