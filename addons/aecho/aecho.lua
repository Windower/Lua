require 'imgHelper'
function event_load()
	player = get_player()
	watchbuffs = {	"Light Arts",
					"Addendum: White",
					"Penury",
					"Celerity",
					"Accession",
					"Perpetuance",
					"Rapture",
					"Dark Arts",
					"Addendum: Black",
					"Parsimony",
					"Alacrity",
					"Manifestation",
					"Ebullience",
					"Immanence",
					"Stun",
					"Petrified",
					"Silence",
					"Stun",
					"Sleep",
					"Slow",
					"Paralyze",
					"Protect",
					"Shell",
					"Haste"
				}
end

function event_gain_status(id,name)
	for u = 1, #watchbuffs do
		if watchbuffs[u]:lower() == name:lower() then
			if name:upper() == 'SILENCE' then
				send_command('input /item "Echo Drops" '..player["name"])
				send_command('send @others atc '..player["name"]..' - '..name)
			else
				send_command('send @others atc '..player["name"]..' - '..name)
				createImage(name)
			end
		end
	end
end

function event_lose_status(id,name)
	for u = 1, #watchbuffs do
		if watchbuffs[u]:lower() == name:lower() then
			deleteImage(name)
		end
	end
end