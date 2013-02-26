colors = {}
colors[1] = 'Menu > Font Colors > Chat > Immediate vicinity ("Say")'
colors[2] = 'Menu > Font Colors > Chat > Wide area ("Shout")'
colors[4] = 'Menu > Font Colors > Chat > Tell target only ("Tell")'
colors[5] = 'Menu > Font Colors > Chat > All party members ("Party")'
colors[6] = 'Menu > Font Colors > Chat > Linkshell group ("Linkshell")'
colors[7] = 'Menu > Font Colors > Chat > Emotes'
colors[17] = 'Menu > Font Colors > Chat > Messages ("Message")'
colors[142] = 'Menu > Font Colors > Chat > NPC Conversations'
colors[20] = 'Menu > Font Colors > For Others > HP/MP others loose'
colors[21] = 'Menu > Font Colors > For Others > Actions others evade'
colors[22] = 'Menu > Font Colors > For Others > HP/MP others recover'
colors[60] = 'Menu > Font Colors > For Others > Beneficial effects others are granted'
colors[61] = 'Menu > Font Colors > For Others > Detrimental effects others receive'
colors[63] = 'Menu > Font Colors > For Others > Effects others resist'
colors[28] = 'Menu > Font Colors > For Self > HP/MP you loose'
colors[29] = 'Menu > Font Colors > For Self > Actions you evade'
colors[30] = 'Menu > Font Colors > For Self > HP/MP you recover'
colors[56] = 'Menu > Font Colors > For Self > Beneficial effects you are granted'
colors[57] = 'Menu > Font Colors > For Self > Detrimental effects you receive'
colors[59] = 'Menu > Font Colors > For Self > Effects you resist'
colors[8] = 'Menu > Font Colors > System > Calls for help'
colors[50] = 'Menu > Font Colors > System > Standard battle messages'
colors[121] = 'Menu > Font Colors > System > Basic system messages'

for v = 0, 255, 1 do
	if(colors[v] ~= nil) then
		add_to_chat(v, "Color "..v..": "..colors[v])
	else
		add_to_chat(v, "Color "..v..": This is some random text to display the color.")
	end
end