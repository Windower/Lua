--[[
A collection of detailed packet field information.
]]

local fields = {}
fields.outgoing = {}
fields.incoming = {}

--[[
	Function definitions. Used to display packet field information.
]]

res = require 'resources'
local language = get_ffxi_info().language:lower()
local short_language = ({english='en', japanese='jp', german='de', french='fr'})[language]

local function id(val)
	local mob = get_mob_by_id(val)
	return mob and mob.name
end

local function index(val)
	local mob = get_mob_by_index(val)
	return mob and mob.name
end

local function ip(val)
	return math.floor(val / 2^24)..'.'..(math.floor(val / 2^16) % 0x100)..'.'..(math.floor(val / 2^8) % 0x100)..'.'..(val % 0x100)
end

local function bool(val)
	return val == 0 and 'false' or 'true'
end

local zones = res.zones():map(table.get-{short_language})
local function zone(val)
	return zones[val]
end

local items = res.items():map(string.capitalize..table.get-{short_language..'l'})
local function item(val)
	return items[val]
end

local timezone
local function time(ts)-- Cancel
fields.outgoing[0x0F1] = L{
	{ctype='unsigned char',     label='Buff ID'},                               --    4 -   4
	{ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
	{ctype='unsigned char',     label='_unknown2'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown3'},                             --    7 -   7
}


	if not timezone then
		local now = os.time()
		local h, m = math.modf(os.difftime(now, os.time(os.date('!*t', now))) / 3600)

		timezone = ('%+.2d:%.2d'):format(h, 60 * m)
	end

	return os.date('%Y-%m-%dT%H:%M:%S'..timezone)
end

-- Standard Client
fields.outgoing[0x015] = L{
	{ctype='float',             label='X Position'},                            --    4 -   7
	{ctype='float',             label='Y Position'},                            --    8 -  11
	{ctype='float',             label='Z Position'},                            --   12 -  15
	{ctype='float',             label='_unknown1'},                             --   16 -  19
	{ctype='unsigned char',     label='Rotation'},                              --   20 -  20
	{ctype='unsigned char',     label='_unknown2'},                             --   21 -  21
	{ctype='unsigned short',    label='Player Index',       fn=index},          --   22 -  23
	{ctype='unsigned int',      label='Timestamp',          fn=time},           --   24 -  27
	{ctype='unsigned int',      label='_unknown3'},                             --   28 -  31
}

-- Speech
fields.outgoing[0x0B5] = L{
	{ctype='unsigned short',     label='GM'},                                   --    4 -   5   05 00 for LS chat?
	{ctype='char[255]',          label='Message'},                              --    6 - 260   Message, occasionally terminated by spare 00 bytes.
}

-- Action
fields.outgoing[0x01A] = L{
	{ctype='unsigned int',      label='Player ID',          fn=id},             --    4 -   7
	{ctype='unsigned short',    label='Player Index',       fn=index},          --    8 -   9
	{ctype='unsigned short',    label='Category'},                              --   10 -  11
	{ctype='unsigned short',    label='Param'},                                 --   12 -  13
	{ctype='unsigned short',    label='_unknown1'},                             --   14 -  15
}

-- Action
fields.outgoing[0x03A] = L{
	{ctype='unsigned char',     label='Storage ID'},                            --    4 -   4
	{ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
	{ctype='unsigned short',    label='_unknown2'},                             --    6 -   7
}

-- Dialogue options
fields.outgoing[0x05B] = L{
	{ctype='unsigned int',      label='Player ID',          fn=id},             --    4 -   7
	{ctype='unsigned char',     label='Option index'},                          --    8 -   8
	{ctype='unsigned short',    label='_unknown1'},                             --    9 -  10
	{ctype='unsigned char',     label='_unknown2'},                             --   11 -  11
	{ctype='unsigned short',    label='Player Index',       fn=index},          --   12 -  13
	{ctype='unsigned short',    label='_unknown3'},                             --   14 -  15
	{ctype='unsigned short',    label='Zone ID',            fn=zone},           --   16 -  17
	{ctype='unsigned char',     label='_unknown4'},                             --   18 -  18
	{ctype='unsigned char',     label='_unknown5'},                             --   19 -  19
}

-- Equip
fields.outgoing[0x050] = L{
	{ctype='unsigned char',     label='Inventory ID'},                          --    4 -   4
	{ctype='unsigned char',     label='Equip Slot'},                            --    5 -   5
	{ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Equipment Screen (0x02 length)
fields.outgoing[0x061] = L{
}

-- Set LS Message
fields.outgoing[0x0E2] = L{
	{ctype='unsigned int',      label='_unknown1',          const=0x00000040},  --    4 -   7
	{ctype='unsigned int',      label='_unknown2'},                             --    8 -  11   Usually 0, but sometimes contains some junk
    {ctype='char[128]',         label='Message'}                                --   12 - 140
}

-- Sit
fields.outgoing[0x0EA] = L{
	{ctype='unsigned char',     label='Movement'},                              --    4 -   4
	{ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
	{ctype='unsigned char',     label='_unknown2'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown3'},                             --    7 -   7
}

-- Cancel
fields.outgoing[0x0F1] = L{
	{ctype='unsigned char',     label='Buff ID'},                               --    4 -   4
	{ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
	{ctype='unsigned char',     label='_unknown2'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown3'},                             --    7 -   7
}

-- Job Change
fields.outgoing[0x100] = L{
	{ctype='unsigned char',     label='Main Job ID'},                           --    4 -   4
	{ctype='unsigned char',     label='Sub Job ID'},                            --    5 -   5
	{ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Zone Response
fields.incoming[0x00B] = L{
	{ctype='unsigned int',      label='Type'},                                  --    4 -   7
	{ctype='unsigned int',      label='IP',                 fn=ip},             --    8 -   8
	{ctype='unsigned short',    label='Port'},                                  --   12 -  15
	{ctype='unsigned short',    label='_unknown1'},                             --   16 -  17
	{ctype='unsigned short',    label='_unknown2'},                             --   18 -  19
	{ctype='unsigned short',    label='_unknown3'},                             --   20 -  21
	{ctype='unsigned short',    label='_unknown4'},                             --   22 -  23
	{ctype='unsigned short',    label='_unknown5'},                             --   24 -  25
	{ctype='unsigned short',    label='_unknown6'},                             --   26 -  27
	{ctype='unsigned short',    label='_unknown7'},                             --   28 -  29
}

-- PC Update
fields.incoming[0x00D] = L{
	{ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
	{ctype='unsigned short',    label='Index',              fn=index},          --    8 -   9
	{ctype='unsigned char',     label='Mask'},                                  --   10 -  10
	{ctype='unsigned char',     label='Rotation'},                              --   11 -  11
	{ctype='float',             label='X Position'},                            --   12 -  15
	{ctype='float',             label='Z Position'},                            --   16 -  19
	{ctype='float',             label='Y Position'},                            --   20 -  23
	{ctype='unsigned short',    label='_unknown1'},                             --   24 -  25
	{ctype='unsigned short',    label='M_TID'},                                 --   26 -  27
	{ctype='unsigned char',     label='Speed Rating'},                          --   28 -  28
	{ctype='unsigned char',     label='_unknown2'},                             --   29 -  29
	{ctype='unsigned char',     label='HP %',               fn=percent},        --   30 -  30
	{ctype='unsigned char',     label='Animation'},                             --   31 -  31
	{ctype='unsigned short',    label='Status'},                                --   32 -  33
	{ctype='unsigned short',    label='Flags'},                                 --   34 -  35
	{ctype='unsigned int',      label='_unknown3'},                             --   36 -  39
	{ctype='unsigned int',      label='_unknown4'},                             --   40 -  43
	{ctype='unsigned int',      label='_unknown5'},                             --   44 -  47
	{ctype='unsigned int',      label='_unknown6'},                             --   48 -  51
	{ctype='unsigned int',      label='_unknown7'},                             --   52 -  55
	{ctype='unsigned int',      label='_unknown8'},                             --   56 -  59
	{ctype='unsigned short',    label='_unknown9'},                             --   60 -  61
	{ctype='unsigned char',     label='Face'},                                  --   62 -  62
	{ctype='unsigned char',     label='Race'},                                  --   63 -  63
	{ctype='unsigned short',    label='Head'},                                  --   64 -  65
	{ctype='unsigned short',    label='Body'},                                  --   66 -  67
	{ctype='unsigned short',    label='Hands'},                                 --   68 -  69
	{ctype='unsigned short',    label='Legs'},                                  --   70 -  71
	{ctype='unsigned short',    label='Feet'},                                  --   72 -  73
	{ctype='unsigned short',    label='Main'},                                  --   74 -  75
	{ctype='unsigned short',    label='Sub'},                                   --   76 -  77
	{ctype='unsigned short',    label='Ranged'},                                --   78 -  79
	{ctype='char[16]',          label='Character Name'},                        --   80 -  95
}

-- NPC Update
fields.incoming[0x00E] = L{
	{ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
	{ctype='unsigned short',    label='Index',              fn=index},          --    8 -   9
	{ctype='unsigned char',     label='Mask'},                                  --   10 -  10
	{ctype='unsigned char',     label='Rotation'},                              --   11 -  11
	{ctype='float',             label='X Position'},                            --   12 -  15
	{ctype='float',             label='Z Position'},                            --   16 -  19
	{ctype='float',             label='Y Position'},                            --   20 -  23
	{ctype='unsigned short',    label='_unknown1'},                             --   24 -  25
	{ctype='unsigned short',    label='_unknown2'},                             --   26 -  27
	{ctype='unsigned short',    label='_unknown3'},                             --   28 -  29
	{ctype='unsigned char',     label='HP %',               fn=percent},        --   30 -  30
	{ctype='unsigned char',     label='Animation'},                             --   31 -  31
	{ctype='unsigned short',    label='Status'},                                --   32 -  33
	{ctype='unsigned short',    label='_unknown4'},                             --   34 -  35
	{ctype='unsigned int',      label='_unknown5'},                             --   36 -  39
	{ctype='unsigned int',      label='_unknown6'},                             --   40 -  43
	{ctype='unsigned int',      label='Claimer ID',         fn=id},             --   44 -  47
	{ctype='unsigned short',    label='_unknown7'},                             --   48 -  49
	{ctype='unsigned short',    label='Model'},                                 --   50 -  51
-- This value can't be displayed properly yet, since the array length varies.
-- Will need to implement a workaround for that.
	{ctype='char[16]',          label='Name'},                                  --   52 -  75
}

-- Incoming Chat
fields.incoming[0x017] = L{
	{ctype='unsigned char',     label='Mode'},                                  --    4 -   4   Chat mode.
	{ctype='bool',              label='is_GM'},                                 --    5 -   5   1 for GM or 0 for not
	{ctype='unsigned short',    label='Zone ID',            fn=zone},           --    6 -   7   Zone ID, used for Yell
	{ctype='char[16]',          label='Sender Name'},                           --    8 -  22   Name
	{ctype='char[231]',         label='Message'},                               --   23 - 253   Message, occasionally terminated by spare 00 bytes.
}

-- Item Assign
fields.incoming[0x01F] = L{
	{ctype='unsigned short',    label='_unknown1'},                             --    4 -   5
	{ctype='unsigned short',    label='_unknown2'},                             --    6 -   7
	{ctype='unsigned short',    label='Item ID'},           fn=item             --    8 -   9
	{ctype='unsigned char',     label='_unknown3'},                             --   10 -  10
	{ctype='unsigned char',     label='Inventory ID'},                          --   11 -  11
	{ctype='unsigned char',     label='Inventory Status'},                      --   12 -  12
	{ctype='unsigned char',     label='_unknown4'},                             --   13 -  13
	{ctype='unsigned char',     label='_unknown5'},                             --   14 -  14
	{ctype='unsigned char',     label='_unknown6'},                             --   15 -  15
}

-- Item Assign
fields.incoming[0x02A] = L{
	{ctype='unsigned int',      label='Player ID',          fn=id},             --    4 -   7
	{ctype='unsigned int',      label='Param 1'},                               --    8 -  11
	{ctype='unsigned int',      label='Param 2'},                               --   12 -  15
	{ctype='unsigned int',      label='Param 3'},                               --   16 -  19
	{ctype='unsigned int',      label='Param 4'},                               --   20 -  23
	{ctype='unsigned short',    label='Player Index',       fn=index},          --   24 -  25
	{ctype='unsigned short',    label='Message ID'},                            --   26 -  27   The high bit is occasionally set, though the reason for it is unclear.
	{ctype='unsigned int',      label='_unknown1',          const=0x06000000},  --   28 -  31
}

-- Pet Stat
fields.incoming[0x044] = L{
-- Packet 0x044 is sent twice in sequence when stats. This can be caused by anything from
-- using a Maneuver on PUP to changing job. The two packets are the same length. The first
-- contains information about your main job. The second contains information about your
-- subjob and has the Subjob flag flipped. Below is mostly for PUP.

	{ctype='unsigned char',     label='Job ID'},                                --    4 -   4
	{ctype='bool',              label='Subjob Flag'},                           --    5 -   5
	{ctype='unsigned char',     label='_unknown'},                              --    6 -   6
	{ctype='unsigned char',     label='_unknown'},                              --    7 -   7
	{ctype='unsigned char',     label='Automaton Head'},                        --    8 -   8   Harlequinn 1, Valoredge 2, Sharpshot 3, Stormwaker 4, Soulsoother 5, Spiritreaver 6
	{ctype='unsigned char',     label='Automaton Frame'},                       --    9 -   9   Harlequinn 20, Valoredge 21, Sharpshot 22, Stormwaker 23
	{ctype='unsigned char',     label='Slot 1'},                                --   10 -  10   Attachment assignments are based off their position in the equipment list.
	{ctype='unsigned char',     label='Slot 2'},                                --   11 -  11   Strobe is 01, etc.
	{ctype='unsigned char',     label='Slot 3'},                                --   12 -  12
	{ctype='unsigned char',     label='Slot 4'},                                --   13 -  13
	{ctype='unsigned char',     label='Slot 5'},                                --   14 -  14
	{ctype='unsigned char',     label='Slot 6'},                                --   15 -  15
	{ctype='unsigned char',     label='Slot 7'},                                --   16 -  16
	{ctype='unsigned char',     label='Slot 8'},                                --   17 -  17
	{ctype='unsigned char',     label='Slot 9'},                                --   18 -  18
	{ctype='unsigned char',     label='Slot 10'},                               --   19 -  19
	{ctype='unsigned char',     label='Slot 11'},                               --   20 -  20
	{ctype='unsigned char',     label='Slot 12'},                               --   21 -  21
	{ctype='unsigned short',    label='_unknown'},                              --   22 -  23
	{ctype='unsigned int',      label='Available Heads'},                       --   24 -  27   Flags for the available heads (Position corresponds to Item ID shifted down by 8192)
	{ctype='unsigned int',      label='Available Bodies'},                      --   28 -  31   Flags for the available bodies (Position corresponds to Item ID)
	{ctype='unsigned int',      label='_unknown'},                              --   32 -  35
	{ctype='unsigned int',      label='_unknown'},                              --   36 -  39
	{ctype='unsigned int',      label='_unknown'},                              --   40 -  43
	{ctype='unsigned int',      label='_unknown'},                              --   44 -  47
	{ctype='unsigned int',      label='_unknown'},                              --   48 -  51
	{ctype='unsigned int',      label='_unknown'},                              --   52 -  55
	{ctype='unsigned int',      label='Fire Attachments'},                      --   56 -  59   Flags for the available Fire Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Ice Attachments'},                       --   60 -  63   Flags for the available Ice Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Wind Attachments'},                      --   64 -  67   Flags for the available Wind Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Earth Attachments'},                     --   68 -  71   Flags for the available Earth Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Thunder Attachments'},                   --   72 -  75   Flags for the available Thunder Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Water Attachments'},                     --   76 -  79   Flags for the available Water Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Light Attachments'},                     --   80 -  83   Flags for the available Light Attachments (Position corresponds to Item ID)
	{ctype='unsigned int',      label='Dark Attachments'},                      --   84 -  87   Flags for the available Dark Attachments (Position corresponds to Item ID)
	{ctype='char[16]',          label='Pet Name'},                              --   88 - 103
	{ctype='unsigned short',    label='Max or Current HP'},                     --  104 - 105   The next two are max or current HP. My PUP sucks too much to fight things, so idk which.
	{ctype='unsigned short',    label='Max or Current HP'},                     --  106 - 107   The next two are max or current HP. My PUP sucks too much to fight things, so idk which.
	{ctype='unsigned short',    label='Max or Current MP'},                     --  108 - 109   Likely max or current MP
	{ctype='unsigned short',    label='Max or Current MP'},                     --  110 - 111   Likely max or current MP
	{ctype='unsigned short',    label='Max or Current Melee Skill'},            --  112 - 113
	{ctype='unsigned short',    label='Max or Current Melee Skill'},            --  114 - 115
	{ctype='unsigned short',    label='Max or Current Ranged Skill'},           --  116 - 117
	{ctype='unsigned short',    label='Max or Current Ranged Skill'},           --  118 - 119
	{ctype='unsigned short',    label='Max or Current Magic Skill'},            --  120 - 121
	{ctype='unsigned short',    label='Max or Current Magic Skill'},            --  122 - 123
	{ctype='unsigned int',      label='_unknown'},                              --  124 - 127
	{ctype='unsigned short',    label='Base STR'},                              --  128 - 129
	{ctype='unsigned short',    label='Additional STR'},                        --  130 - 131
	{ctype='unsigned short',    label='Base DEX'},                              --  132 - 133
	{ctype='unsigned short',    label='Additional DEX'},                        --  134 - 135
	{ctype='unsigned short',    label='Base VIT'},                              --  136 - 137
	{ctype='unsigned short',    label='Additional VIT'},                        --  138 - 139
	{ctype='unsigned short',    label='Base AGI'},                              --  140 - 141
	{ctype='unsigned short',    label='Additional AGI'},                        --  142 - 143
	{ctype='unsigned short',    label='Base INT'},                              --  144 - 145
	{ctype='unsigned short',    label='Additional INT'},                        --  146 - 147
	{ctype='unsigned short',    label='Base MND'},                              --  148 - 149
	{ctype='unsigned short',    label='Additional MND'},                        --  150 - 151
	{ctype='unsigned short',    label='Base CHR'},                              --  152 - 153
	{ctype='unsigned short',    label='Additional CHR'},                        --  154 - 155
	
	-- For Black Mage, 0x29 to 0x43 appear to represent the black magic that you know
	
}

-- Data Download 2
fields.incoming[0x04F] = L{
	{ctype='unsigned char',     label='_unknown1'},                             --    4 -   4
	{ctype='unsigned char',     label='_unknown2'},                             --    5 -   5
	{ctype='unsigned char',     label='_unknown3'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown4'},                             --    7 -   7
}

-- Equip
fields.incoming[0x050] = L{
	{ctype='unsigned char',     label='Inventory ID'},                          --    4 -   4
	{ctype='unsigned char',     label='Equip Slot'},                            --    5 -   5
	{ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
	{ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Data Download 3
fields.incoming[0x051] = L{
	{ctype='unsigned char',      label='face'},                                 --    4 -   4
	{ctype='unsigned char',      label='race'},                                 --    5 -   5
	{ctype='unsigned short',     label='_unknown1',         const=0x10},        --    6 -   7
	{ctype='unsigned short',     label='_unknown2',         const=0x20},        --    8 -   9
	{ctype='unsigned short',     label='_unknown3',         const=0x30},        --   10 -  11
	{ctype='unsigned short',     label='_unknown4',         const=0x40},        --   12 -  13
	{ctype='unsigned short',     label='_unknown5',         const=0x50},        --   14 -  15
	{ctype='unsigned short',     label='_unknown6',         const=0x60},        --   16 -  17
	{ctype='unsigned short',     label='_unknown7',         const=0x70},        --   18 -  19
	{ctype='unsigned short',     label='_unknown8',         const=0x80},        --   20 -  21
	{ctype='unsigned short',     label='_unknown9'},                            --   22 -  23
}

-- Weather Change
fields.incoming[0x057] = L{
	{ctype='unsigned int',      label='Vanadiel Time'},                         --    4 -   7   Units of minutes.
	{ctype='unsigned char',     label='Weather ID'},                            --    8 -   8
	{ctype='unsigned char',     label='_unknown1'},                             --    9 -   9
	{ctype='unsigned short',    label='_unknown2'},                             --   10 -  11
}

-- Unnamed 0x067
fields.incoming[0x067] = L{
-- The length of this packet is 28 or 40 bytes. 28 appears to be for NPCs/monsters
-- and 40 appears to be for players. _unknown1 is 02 09 for players and 03 05 for
-- NPCs. The use of this packet is unclear.
	{ctype='unsigned short',    label='_unknown1'},                             --    4 -   5
	{ctype='unsigned short',    label='Player Index',       fn=index},          --    5 -   6
	{ctype='unsigned int',      label='Player ID',          fn=id},             --    7 -  10
}

-- Char Update
fields.incoming[0x0DF] = L{
	{ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
	{ctype='unsigned int',      label='HP'},                                    --    8 -  11
	{ctype='unsigned int',      label='MP'},                                    --   12 -  15
	{ctype='unsigned int',      label='TP'},                                    --   16 -  19   Truncated, does not include the decimal value.
	{ctype='unsigned short',    label='Player Index'},                          --   20 -  21
	{ctype='unsigned char',     label='HPP'},                                   --   22 -  22
	{ctype='unsigned char',     label='MPP'},                                   --   23 -  23
	{ctype='unsigned short',    label='_unknown1'},                             --   24 -  25
	{ctype='unsigned short',    label='_unknown2'},                             --   26 -  27
}

-- LS Message
fields.incoming[0x0CC] = L{
	{ctype='int',               label='_unknown1'},                             --    4 -   7
	{ctype='char[128]',         label='Message'},                               --    8 - 135
	{ctype='int',               label='_unknown2'},                             --  136 - 139
	{ctype='char[16]',          label='Player Name'},                           --  140 - 155
	{ctype='int',               label='Permissions'},                           --  156 - 159
	{ctype='char[16]',          label='Linkshell Name'},                        --  160 - 175   6-bit packed
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
	{ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
	{ctype='unsigned short',    label='Player Index'},                          --    8 -   9
	{ctype='unsigned char',      label='_unknown1'},                            --   10 -  10
	{ctype='unsigned char',      label='_unknown2'},                            --   11 -  11
}

return fields
