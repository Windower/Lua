Watches buffs/debuffs and sends messages to alts when you gain certain
ones. Also, automatically uses echo drops if you get silenced.

Can watch more or less buffs just by changing the watchbuffs table.

Also, this program assumes you have send. If not, then you can just remove the following parts that use it:

		send_command('send @others atc '..player["name"]..' - '..name)
	else
		send_command('send @others atc '..player["name"]..' - '..name)

Removing those 3 lines will make it so it only automatically uses echo drops if you get silenced.
If you do have send and want to use my addtochat portion (that's what the atc means) You will need to make the following change.

In the relevant_msg() function the last few lines are:
	if msg:sub(1,1)=='/' then
		send_command('input '..msg)
	else
		send_command(msg)
	end

end

To include my addtochat mod all you need to do is add the following:
	elseif msg:sub(1,3)=='atc' then
		add_to_chat(55,msg:sub(5))

So the end of the file should look like this:
function relevant_msg(msg)
	local player = get_player()
	msg:gsub("<me>", player['name'])
	msg:gsub("<hp>", tostring(player['hp']))
	msg:gsub("<mp>", tostring(player['mp']))
	msg:gsub("<hpp>", tostring(player['hpp']))
	msg:gsub("<mpp>", tostring(player['mpp']))
	msg:gsub("<tp>", tostring(player['tp']))
	msg:gsub("<job>", player['main_job_full']..'/'..player['sub_job_full'])
	msg:gsub("<mjob>", player['main_job_full'])
	msg:gsub("<sjob>", player['sub_job_full'])
	

	if msg:sub(1,1)=='/' then
		send_command('input '..msg)
	elseif msg:sub(1,3)=='atc' then
		add_to_chat(55,msg:sub(5))
	else
		send_command(msg)
	end

end