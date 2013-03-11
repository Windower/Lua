function event_addon_command(...)
    inp = table.concat({...}, ' ')
	if inp=='?' then
		write('dance <mode> - Changes your style to <mode>')
	else
		mode = inp
	end
end

function event_load()
	send_command('alias dance lua c dance')
	mode = "freestyle"
	dancenum = { mimic29="panic", mimic65="dance1", mimic66="dance2", mimic67="dance3", mimic68="dance4",
	advance29="dance1", advance65="dance2", advance66="dance3", advance67="dance4", advance68="panic",
	freestyle29="dance4", freestyle65="dance3", freestyle66="dance1", freestyle67="panic", freestyle68="dance2" }
end

function event_unload()
	send_command('unalias dance')
end

function event_emote(senderId,targetId,emoteId,MotionOnly)
	local player = get_player()
	if targetId==player["id"] then
		local emoter = get_mob_by_id(senderId)
		send_command('input /target '..emoter["name"])

		if dancenum[mode..emoteId] ~= nil then
			send_command('wait 1.8;input /'..dancenum[mode..emoteId]..' motion')
		end
	end
end
