function event_load()
	a = 0
	player = get_player()['name']
	salvage_cell_name ={ 
				'incus cell','castellanus cell','undulatus cell',
				'cumulus cell','radiatus cell','virga cell',
				'cirrocumulus cell','stratus cell','duplicatus cell',
				'opacus cell', 'praecipitatio cell', 'humilus cell',
				'spissatus cell', 'pannus cell', 'fractus cell',
				'congestus cell',  'nimbus cell', 'velum cell',
				'pileus cell', 'mediocris cell'
			}
	salvage_cell_ident = { 
				'Weapons and Shields', 'Head and Neck', 'Ranged and Ammo', 'Body', 'Hand', 'Earring and Ring', 'Back and Waist', 'Legs and Feet', 'Support Job','Job and Weaponskill', 'Magic', 'HP', 'MP', 'STR', 'DEX', 'VIT', 'AGI', 'INT', 'MND', 'CHR'
				} 
	cells_id = { 
				'5365','5366','5371','5367','5368','5372','5370','5369','5373','5374','5375','5383','5384','5376','5377','5378','5379','5380','5381','5382'
				}
	cells_id_concat = table.concat(cells_id, ',')
	obtained_cells = {}
	start_cells = table.concat(salvage_cell_name, '  \n  ')
	tb_create('salvage_box')
	tb_set_bg_color('salvage_box',200,30,30,30)
	tb_set_color('salvage_box',255,200,200,200)
	tb_set_location('salvage_box',200,130)
	tb_set_visibility('salvage_box',1)
	tb_set_bg_visibility('salvage_box',1)
	tb_set_font('salvage_box','Arial',12)
	tb_set_text('salvage_box',' Still Need:  \n  '..start_cells);

end
function event_unload()
	tb_delete('salvage_box')
	io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write(''):close()
end

function event_incoming_text(old, new, color)
	match_obt =  old:match(player..' obtains an? ..(.*)..%.')
	match_drop = old:match ('You find an? ..(.*)..%.')
	
	celltest = old:find(player..' obtains an? ')
	droptest = old:find('You find an? (.*) cell')
	
	if celltest == nil and droptest == nil then 
		return new,color
	end	
	if celltest ~= nil then
		for i=1, 20 do
			if match_obt == salvage_cell_name[i] then 
				a = a+1
				obtained_cells[#obtained_cells+1] = cells_id[i]
				salvage_cell_name[i]='1'
				update_cells()
				return new,color, a
			end
		end
		return new,color
	end

if droptest ~= nil then
	for i=1, #salvage_cell_name do
		if match_drop == salvage_cell_name[i]  then
			new = 'You find a '..string.char(31,158)..salvage_cell_name[i]..' ('..string.char(31,158)..salvage_cell_ident[i]..')'..string.char(31,167)..' /Need/'
		return new,color
		else 
			new = old..' /Have/'
		end	
	end	
	return new,color		
	end
end

function update_cells()
	if a<20 then
		local pass = table.concat(obtained_cells, ',')
		local needed_cells = table.concat(salvage_cell_name, '  \n  ')
		local textbox_cells = string.gsub(needed_cells, '(1  \n  )'or'%d', '')
		tb_set_text('salvage_box',' Still Need:  \n  '..textbox_cells)
		io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write('if item is '..pass..' then pass'):close()
	else 
		tb_set_text('salvage_box', '  Obtained all the cells.  ')
	end
end
