--Copyright (c) 2013, Thomas Rogers / Balloon - Cerberus
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--   * Neither the name of cellhelp nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function event_addon_command(...)
    cmd = {...}
	if cmd[1] ~= nil then
		if cmd[1]:lower() == "help" then
			write('cellhelp position: <x> <y> coordinates')
			write('cellhelp hide: hides the cellhelp box')
			write('cellhelp show: shows the cellhelp box')
			write('cellhelp : In order to add custom lot pass rules, add it to your salvage-'..player..'-add.txt file. \n (One line for pass, one for lot)')
		end

		if cmd[1]:lower() == "position" then
			if cmd[3] ~= nil then
				tb_set_location('salvage_box',cmd[2],cmd[3])
			end
		end
		
		if cmd[1]:lower() == "hide" then
			tb_set_visibility('salvage_box', false)
		end
		
		if cmd[1]:lower() == "show" then
			tb_set_visibility('salvage_box', true)
		end
	end
end


function event_load()
	send_command('alias ch lua c cellhelp')
	a = 0
	player = get_player()['name']
	get_ll()
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
	io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write('if item is '..custompass..' then pass\nif item is '..customlot..' then lot\n'):close()

end
function event_unload()
	tb_delete('salvage_box')
	end_command('unalias ch')
	--io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write(''):close()
end

function event_zone_change(fromId, from, toId, to)
	if fromId == 72 and toId == 74 or toId == 75 or toId == 76 or toId == 73 then
		send_command('ll profile salvage-'..player..'.txt')
	end
end


function event_incoming_text(old, new, color)
	match_obt =  old:match(player..' obtains an? ..(.*)..%.')
	match_drop = old:match ('You find an? ..(.*).. %o?i?n')
	
	celltest = old:find(player..' obtains an? ')
	droptest = old:find('%w+%You find')
	
	if celltest == nil and droptest == nil then 
		return new,color
	end	
	if celltest ~= nil then
		for i=1, #salvage_cell_name do
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

function get_ll()
local ll = io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'-add.txt', 'r')
	if ll then
		for l in ll:lines() do
			if l:find('if (.*)% then lot') then
				customlot = l:match('if item is (.*)% then lot')
			end
			if l:find('if (.*)% then pass') then
				custompass = l:match('if item is (.*)% then pass')
			end
		end
	end
	if custompass == nil then
		write('Add something to the top line of your salvage-'..player..'-add.txt file to pass things other than cells.  Please keep these on one line. Reload after.')
		custompass=''
	end
	if customlot == nil then
		write('Add something to the second line of your salvage-'..player..'-add.txt file to lot things other than cells. Please keep these on one line. Reload after')
		customlot=''
	end
return customlot,custompass
end

function update_cells()
	if a<20 then
		local pass = table.concat(obtained_cells, ',')
		local needed_cells = table.concat(salvage_cell_name, '  \n  ')
		local textbox_cells = string.gsub(needed_cells, '(1  \n  )'or'%d', '')
		tb_set_text('salvage_box',' Still Need:  \n  '..textbox_cells)
		io.open(lua_base_path..'../../plugins/ll/salvage-'..player..'.txt',"w"):write('if item is '..custompass..' then pass\nif item is '..customlot..' then lot\nif item is '..pass..' then pass'):close()
	else 
		tb_set_text('salvage_box', '  Obtained all the cells.  ')
	end
end
