Watches buffs/debuffs and sends messages to alts when you gain certain
ones. Also, automatically uses echo drops if you get silenced.

Can watch more or less buffs just by changing the watchbuffs table.

Also, this program assumes you have send. If not, then you can just remove the following parts that use it:

		send_command('send @others atc '..player["name"]..' - '..name)
	else
		send_command('send @others atc '..player["name"]..' - '..name)

Removing those 3 lines will make it so it only automatically uses echo drops if you get silenced.

If you don't want to use the atc part you can easily change the atc to input /echo. so it looks like send @others input /echo '..player["name"]..  and it'll work perfectly fine just echoing on your alt. I'm not a fan of the /echo color so i changed it to a shinier gold.
