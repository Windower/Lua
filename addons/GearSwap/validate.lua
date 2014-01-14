function validate(filter)
	local temp_items,item_list = windower.ffxi.get_items(),{empty=true}
	
	for i,v in pairs(temp_items.inventory) do
		if v.id ~= 0 then
			item_list[r_items[v.id][language]:lower()] = true
			item_list[r_items[v.id][language..'_log']:lower()] = true
		end
	end
	
	windower.add_to_chat(123,'GearSwap: Validating sets against inventory')
	windower.add_to_chat(123,'           (does not detect multiple identical items or look at augments)')
	local missing = unpack_layer({},item_list,sets,filter)
	windower.add_to_chat(123,'GearSwap: '..table.length(missing)..' missing items detected.')
end

function unpack_layer(missing,item_list,tab,filter)
	for i,v in pairs(tab) do
		if type(v)=='table' and not v.name then
			missing = unpack_layer(missing,item_list,v,filter)
		elseif type(i) == 'string' and ((type(v) == 'table' and v.name and slot_map[i:lower()]) or (type(v) == 'string' and slot_map[i:lower()])) then
			local nam = v.name or v
			if not item_list[nam:lower()] and not missing[nam:lower()] and tryfilter(nam:lower(), filter) then
				windower.add_to_chat(123,'GearSwap: '..tostring(nam)..' not found in inventory.')
				missing[nam:lower()] = true
			end
		elseif type(i) == 'string' and type(v) == 'table' and v.name and not slot_map[i:lower()] then
			if item_list[v.name:lower()] then
				windower.add_to_chat(123,'GearSwap: '..tostring(i)..' contains a "name" element but is not a valid slot.')
			elseif not missing[v.name:lower()] then
				windower.add_to_chat(123,'GearSwap: '..tostring(i)..' contains a "name" element but is not a valid slot, and '..tostring(v.name)..' is not found in inventory.')
				missing[v.name:lower()] = true
			end
		elseif type(i) ~= 'string' and debugging >=1 then
			windower.ffxi.add_to_chat(8,'Debugging: '..tostring(i))
		end
	end
	return missing
end

function tryfilter(name, filter)
	if not filter or #filter == 0 then
		return true
	end
	
	for _,v in pairs(filter) do
		if name:contains(v:lower()) then
			return true
		end
	end
	return false
end

