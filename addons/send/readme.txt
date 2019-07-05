Syntax for the send command is send [playername, @others, @all, @job] [command]

If you wish to change the color of the text added from aecho. Or any plugin that includes send <player> atc. Near the end of the send.lua you will find the following:

windower.add_to_chat(55,msg:sub(5))

You may change the 55 to any number from 1 to 255 to get a (not always) different color. 

Can use <tid> (stands for target id) from the user originating the send and it will replace the <tid> with the senders currently targeted mob id.

/con send @others /ma "Blizzard IV" <tid>

and another program, e.g. gearswap will resolve the target id to the monster and cast blizzard IV on the mob targeted by the sender. 

Can use <lstid> (stands for last sub-target id) and works the same as <tid> but with the last sub-target.

/ta <stnpc>
/con send //@others /ma "Blizzard IV" <lstid>

This would have all the other characters cast Blizzard IV on the last sub target from the sender.

