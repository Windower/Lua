return {
    -- Configurable game colors
    say =         string.char(0x1F, 0x01),        -- Menu > Font Colors > Chat > Immediate vicinity ('Say')
    tell =        string.char(0x1F, 0x04),        -- Menu > Font Colors > Chat > Tell target only ('Tell')
    party =       string.char(0x1F, 0x05),        -- Menu > Font Colors > Chat > All party members ('Party')
    linkshell =   string.char(0x1F, 0x06),        -- Menu > Font Colors > Chat > Linkshell group ('Linkshell')
    emote =       string.char(0x1F, 0x07),        -- Menu > Font Colors > Chat > Emotes
    message =     string.char(0x1F, 0x11),        -- Menu > Font Colors > Chat > Messages ('Message')
    npc =         string.char(0x1F, 0x8E),        -- Menu > Font Colors > Chat > NPC Conversations
    shout =       string.char(0x1F, 0x02),        -- Menu > Font Colors > Chat > Wide area ('Shout')
    yell =        string.char(0x1F, 0x03),        -- Menu > Font Colors > Chat > Extremely wide area ('Yell')
    selfheal =    string.char(0x1F, 0x1E),        -- Menu > Font Colors > For Self > HP/MP you recover
    selfhurt =    string.char(0x1F, 0x1C),        -- Menu > Font Colors > For Self > HP/MP you loose
    selfbuff =    string.char(0x1F, 0x38),        -- Menu > Font Colors > For Self > Beneficial effects you are granted
    selfdebuff =  string.char(0x1F, 0x39),        -- Menu > Font Colors > For Self > Detrimental effects you receive
    selfresist =  string.char(0x1F, 0x3B),        -- Menu > Font Colors > For Self > Effects you resist
    selfevade =   string.char(0x1F, 0x1D),        -- Menu > Font Colors > For Self > Actions you evade
    otherheal =   string.char(0x1F, 0x16),        -- Menu > Font Colors > For Others > HP/MP others recover
    otherhurt =   string.char(0x1F, 0x14),        -- Menu > Font Colors > For Others > HP/MP others loose
    otherbuff =   string.char(0x1F, 0x3C),        -- Menu > Font Colors > For Others > Beneficial effects others are granted
    otherdebuff = string.char(0x1F, 0x3D),        -- Menu > Font Colors > For Others > Detrimental effects others receive
    otherresist = string.char(0x1F, 0x3F),        -- Menu > Font Colors > For Others > Effects others resist
    otherevade =  string.char(0x1F, 0x15),        -- Menu > Font Colors > For Others > Actions others evade
    cfh =         string.char(0x1F, 0x08),        -- Menu > Font Colors > System > Calls for help
    battle =      string.char(0x1F, 0x32),        -- Menu > Font Colors > System > Standard battle messages
    system =      string.char(0x1F, 0x79),        -- Menu > Font Colors > System > Basic system messages
}
