Syntax for the send command is send [playername, @others, @all, @job] [command]

If you wish to change the color of the text added from aecho. Or any plugin that includes send <player> atc. Near the end of the send.lua you will find the following:

windower.add_to_chat(55,msg:sub(5))

You may change the 55 to any number from 1 to 255 to get a (not always) different color. 
