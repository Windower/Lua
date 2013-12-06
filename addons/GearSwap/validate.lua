function validate()
	local temp_items,item_list = get_items(),{empty=true}
	
	for i,v in pairs(temp_items.inventory) do
		if v.id ~= 0 then
			item_list[r_items[v.id][language]:lower()] = true
			item_list[r_items[v.id][language..'_log']:lower()] = true
		end
	end
	
	add_to_chat(123,'Gearswap: Validating sets against inventory')
	add_to_chat(123,'           (does not detect multiple identical items or look at augments)')
	local missing = unpack_layer({},item_list,sets)
	add_to_chat(123,'Gearswap: '..table.length(missing)..' missing items detected.')
end

function unpack_layer(missing,item_list,tab)
	for i,v in pairs(tab) do
		if type(v)=='table' and not v.name then
			missing = unpack_layer(missing,item_list,v)
		elseif (type(v) == 'table' and v.name and slot_map[i:lower()]) or (type(v) == 'string' and slot_map[i:lower()]) then
			local nam = v.name or v
			if not item_list[nam:lower()] and not missing[nam:lower()] then
				add_to_chat(123,'Gearswap: '..tostring(nam)..' not found in inventory.')
				missing[nam:lower()] = true
			end
		elseif type(v) == 'table' and v.name and not slot_map[i:lower()] then
			if item_list[v.name:lower()] then
				add_to_chat(123,'Gearswap: '..tostring(i)..' contains a "name" element but is not a valid slot.')
			elseif not missing[v.name:lower()] then
				add_to_chat(123,'Gearswap: '..tostring(i)..' contains a "name" element but is not a valid slot, and '..tostring(v.name)..' is not found in inventory.')
				missing[v.name:lower()] = true
			end
		end
	end
	return missing
end