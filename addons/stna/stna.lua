require 'tablehelper'

function event_load()
	player = get_player()
	send_command('alias stna lua c stna')
	statSpell = { 
				Paralysis='Paralyna',
				Curse='Cursna',
				Doom='Cursna',
				Silence='Silena',
				Plague='Viruna',
				Diseased='Viruna',
				Petrification='Stona',
				Poison='Poisona',
				Blindness='Blindna'
			}
	--You may change this priority as you see fit this is my personal preference		
	priority = { 
				'Doom','Curse','Petrification',
				'Paralysis','Plague','Silence',
				'Blindness','Poison','Diseased'
			}
	statusTable = T{}
end

function event_addon_command()
	if statusTable[1] == nil then
		add_to_chat(55,"You are not afflicted by a status with a -na spell.")
	else
		for i = 1, 9 do
			for u = 1, #statusTable do
				if statusTable[u]:lower() == priority[i]:lower() then
					send_command('send @others '..statSpell[priority[i]]..' '..player['name'])
					if statusTable[u]:lower() == 'doom' then
						send_command('input /item "Holy Water" '..player['name'])  --Auto Holy water for doom
					end
					return
				end
			end
			if i == 9 then
				add_to_chat(55,"You are not afflicted by a status with a -na spell.")
			end
		end
	end
end

function event_gain_status(id,name)
	if #statusTable == 0 then
		for i = 1, #priority do
			if priority[i]:lower() == name:lower() then
				statusTable[#statusTable+1] = name
			end
		end
	else	
		for u = 1, #statusTable do
			if statusTable[u]:lower() == name:lower() then
				return
			else
				for i = 1, #priority do
					if priority[i]:lower() == name:lower() then
						statusTable[#statusTable+1] = name
					end
				end
			end
		end
	end
end


function event_lose_status(id,name)
	for u = 1, #statusTable do
		if statusTable[u]:lower() == name:lower() then
			table.remove(statusTable,u)
			return
		end
	end
end