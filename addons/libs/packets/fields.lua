--[[
    A collection of detailed packet field information.
]]

require('pack')
require('functools')
require('stringhelper')
require('mathhelper')
require('lists')

local fields = {}
fields.outgoing = {_mult = {}}
fields.incoming = {_mult = {}}

-- String decoding definitions
local ls_name_msg = T(('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'):split())
ls_name_msg[0] = (0):char()
local item_inscr = T(('0123456798ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{'):split())
item_inscr[0] = (0):char()
local ls_name_ext = T(('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'..(0):char():rep(11)):split())
ls_name_ext[0] = '`'

-- Function definitions. Used to display packet field information.

res = require('resources')

local function s(val, from, to)
    from = from - 1
    val = val/2^from

    if to then
        val = val % 2^(to - from)
    end

    return val
end

local function id(val)
    local mob = windower.ffxi.get_mob_by_id(val)
    return mob and mob.name
end

local function index(val)
    local mob = windower.ffxi.get_mob_by_index(val)
    return mob and mob.name
end

local function ip(val)
    return (val / 2^24):floor()..'.'..((val / 2^16):floor() % 0x100)..'.'..((val / 2^8):floor() % 0x100)..'.'..(val % 0x100)
end

local function gil(val)
    return tostring(val):reverse():chunks(3):concat(','):reverse()..' G'
end

local function bool(val)
    return val ~= 0
end

local time = (function()
    local now = os.time()
    local h, m = math.modf(os.difftime(now, os.time(os.date('!*t', now))) / 3600)

    local timezone = ('%+.2d:%.2d'):format(h, 60 * m)
    now, h, m = nil, nil, nil
    return function(ts)
        return os.date('%Y-%m-%dT%H:%M:%S'..timezone, ts)
    end
end)()

local dir = (function()
    local dir_sets = L{'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N', 'NNE', 'NE', 'ENE', 'E'}
    return function(val)
        return dir_sets[((val + 8)/16):floor() + 1]
    end
end)()

local function cap(val, max)
    return ('%.1f'):format(100*val/max)..'%'
end

local function zone(val)
    return res.zones[val].name
end

local function item(val)
    return res.items[val].name_full:capitalize()
end

local function server(val)
    return res.servers[val].name
end

local function weather(val)
    return res.weather[val].name
end

local function chat(val)
    return res.chat[val].name
end

local function skill(val)
    return res.skills[val].name
end

local function title(val)
    return res.titles[val].name
end

local function job(val)
    return res.jobs[val].name
end

local function emote(val)
    return '/'..res.emotes[val].command
end

local function bag(val)
    return res.bags[val].name
end

local function race(val)
    return res.races[val].name
end

local function slots(val)
    return res.slots[val].name
end

local function slot(val)
    return res.slots[2^val].name
end

local function inv(val)
    if val == 0 then
        return '(None)'
    end

    local id = windower.ffxi.get_items().inventory[val].id
    return id > 0 and res.items[id].name or 'Unknown'
end

local function hex(val, fill)
    local res = val:hex()
    return fill and res:zfill(8*fill) or res
end

local function bin(val, fill)
    local res = val:binary()
    return fill and res:zfill(8*fill) or res
end

local function cskill(val)
    return  s(val, 1, 15):string() .. ' (' .. (val >= 0x8000 and 'Capped' or 'Uncapped') .. ')'
end

--[[
    Custom types
]]
local types = {}
types.shop_item = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            --  0
    {ctype='unsigned short',    label='Item ID',            fn=item},           --  4
    {ctype='unsigned short',    label='Shop Slot'},                             --  8
}

--[[
    Outgoing packets
]]

-- Client Leave
fields.outgoing[0x00D] = L{
    {ctype='unsigned char',     label='_unknown1'},                             --  4 -- Always 00?
    {ctype='unsigned char',     label='_unknown2'},                             --  5 -- Always 00?
    {ctype='unsigned char',     label='_unknown3'},                             --  6 -- Always 00?
    {ctype='unsigned char',     label='_unknown4'},                             --  7 -- Always 00?
}

-- Standard Client
fields.outgoing[0x015] = L{
    {ctype='float',             label='X Position'},                            --  4
    {ctype='float',             label='Y Position'},                            --  8
    {ctype='float',             label='Z Position'},                            --  C
    {ctype='unsigned short',    label='_zero1'},                                -- 10
    {ctype='unsigned short',    label='Run Count'},                             -- 12 -- Counter that indicates how long you've been running?
    {ctype='unsigned char',     label='Rotation',           fn=dir},            -- 14
    {ctype='unsigned char',     label='_unknown2'},                             -- 15
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 18
    {ctype='unsigned int',      label='_unknown3'},                             -- 1A
}

-- Action
fields.outgoing[0x01A] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             --  4
    {ctype='unsigned short',    label='Target Index',       fn=index},          --  8
    {ctype='unsigned short',    label='Category'},                              --  A
    {ctype='unsigned short',    label='Param'},                                 --  C
    {ctype='unsigned short',    label='_unknown1'},                             --  E
}

-- Sort Item
fields.outgoing[0x03A] = L{
    {ctype='unsigned char',     label='Storage ID'},                            --  4
    {ctype='unsigned char',     label='_unknown1'},                             --  5
    {ctype='unsigned short',    label='_unknown2'},                             --  6
}

-- Delivery Box
fields.outgoing[0x04D] = L{
    {ctype='unsigned char',     label='Manipulation Type'},                     --  4
	-- 
	
	-- Removing an item from the d-box sends type 0x08
	-- It then responds to the server's 0x4B (id=0x08) with a 0x0A type packet.
	-- Their assignment is the same, as far as I can see.
    {ctype='unsigned char',     label='_unknown1'},                             --  5  -- 01 observed
    {ctype='unsigned char',     label='Slot ID'},                               --  6
    {ctype='char[5]',           label='_unknown2'},                             --  7  -- FF FF FF FF FF observed
    {ctype='char[20]',          label='_unknown3'},                             --  C  -- All 00 observed
}

-- Equip
fields.outgoing[0x050] = L{
    {ctype='unsigned char',     label='Inventory ID',       fn=inv},            --  4
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           --  5
    {ctype='unsigned char',     label='_unknown1'},                             --  6
    {ctype='unsigned char',     label='_unknown2'},                             --  7
}

-- Conquest
fields.outgoing[0x05A] = L{
}

-- Dialogue options
fields.outgoing[0x05B] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned char',     label='Option index'},                          --  8
    {ctype='unsigned short',    label='_unknown1'},                             --  9
    {ctype='unsigned char',     label='_unknown2'},                             --  B
    {ctype='unsigned short',    label='Player Index',       fn=index},          --  C
    {ctype='unsigned short',    label='_unknown3'},                             --  E
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           -- 10
    {ctype='unsigned char',     label='_unknown4'},                             -- 12
    {ctype='unsigned char',     label='_unknown5'},                             -- 13
}

-- Equipment Screen (0x02 length) -- Also observed when zoning
fields.outgoing[0x061] = L{
}

-- Party invite
fields.outgoing[0x06E] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             --  4  This is so weird. The client only knows IDs from searching for people or running into them. So if neither has happened, the manual invite will fail, as the ID cannot be retrieved.
    {ctype='unsigned short',    label='Target index',       fn=index},          --  8  00 if target not in zone
    {ctype='unsigned char',     label='Alliance'},                              --  A  02 for alliance, 00 for party or if invalid alliance target (the client somehow knows..)
    {ctype='unsigned char',     label='_const1',            const=0x041},       --  B
}

-- Party leaving
fields.outgoing[0x06F] = L{
    {ctype='unsigned char',     label='_const1',            const=0x00},        --  4
    {ctype='unsigned char[3]',  label='_junk1'},                                --  5
}

-- Party breakup
fields.outgoing[0x070] = L{
    {ctype='unsigned char',     label='Alliance'},                              --  4  02 for alliance, 00 for party
    {ctype='unsigned char[3]',  label='_junk1'},                                --  5
}

-- Party invite response
fields.outgoing[0x074] = L{
    {ctype='unsigned char',     label='Join',               fn=bool},           --  4
    {ctype='unsigned char[3]',  label='_junk1'},                                --  5
}

-- Party change leader
fields.outgoing[0x077] = L{
    {ctype='char[16]',          label='Target name'},                           --  4  Name of the person to give leader to
    {ctype='unsigned short',    label='Alliance'},                              -- 14  02 01 for alliance, 00 00 for party
    {ctype='unsigned short',    label='_unknown1'},                             -- 16
}

-- Synth
fields.outgoing[0x096] = L{
    {ctype='unsigned char',     label='_unknown1'},                             --  4 -- Crystal ID? Earth = 0x02, Wind-break = 0x19?, Wind no-break = 0x2D?
    {ctype='unsigned char',     label='_unknown2'},                             --  5
    {ctype='unsigned short',    label='Crystal Item ID'},                       --  6 -- Item ID
    {ctype='unsigned char',     label='Crystal Inventory slot'},                --  8 -- Inventory slot ID
    {ctype='unsigned char',     label='Number of Ingredients'},                 --  9
    {ctype='unsigned short',    label='Ingredient 1 ID'},                       --  A -- Item ID
    {ctype='unsigned short',    label='Ingredient 2 ID'},                       --  C
    {ctype='unsigned short',    label='Ingredient 3 ID'},                       --  E
    {ctype='unsigned short',    label='Ingredient 4 ID'},                       -- 10
    {ctype='unsigned short',    label='Ingredient 5 ID'},                       -- 12
    {ctype='unsigned short',    label='Ingredient 6 ID'},                       -- 14
    {ctype='unsigned short',    label='Ingredient 7 ID'},                       -- 16
    {ctype='unsigned short',    label='Ingredient 8 ID'},                       -- 18
    {ctype='unsigned char',     label='Ingredient 1 slot'},                     -- 1A -- Inventory slot ID
    {ctype='unsigned char',     label='Ingredient 2 slot'},                     -- 1B
    {ctype='unsigned char',     label='Ingredient 3 slot'},                     -- 1C
    {ctype='unsigned char',     label='Ingredient 4 slot'},                     -- 1D
    {ctype='unsigned char',     label='Ingredient 5 slot'},                     -- 1E
    {ctype='unsigned char',     label='Ingredient 6 slot'},                     -- 1F
    {ctype='unsigned char',     label='Ingredient 7 slot'},                     -- 20
    {ctype='unsigned char',     label='Ingredient 8 slot'},                     -- 21
    {ctype='unsigned short',    label='_unknown3'},                             -- 22
}

-- Speech
fields.outgoing[0x0B5] = L{
    {ctype='unsigned char',     label='Mode'},                                  --  4   05 for LS chat?
    {ctype='unsigned char',     label='GM'},                                    --  5   01 for GM
    {ctype='char[255]',         label='Message'},                               --  6   Message, occasionally terminated by spare 00 bytes.
}

-- Tell
fields.outgoing[0x0B6] = L{
    {ctype='unsigned char',     label='GM?'},                                   --  4   00 for a normal tell -- Varying this does nothing.
    {ctype='char[15]',          label='Target name'},                           --  5   Name of the person to send a tell to
    {ctype='char[255]',         label='Message'},                               -- 14   Message, occasionally terminated by spare 00 bytes.
}

-- Set LS Message
fields.outgoing[0x0E2] = L{
    {ctype='unsigned int',      label='_unknown1',          const=0x00000040},  --  4
    {ctype='unsigned int',      label='_unknown2'},                             --  8   Usually 0, but sometimes contains some junk
    {ctype='char[128]',         label='Message'}                                --  C
}

-- Logout
fields.outgoing[0x0E7] = L{
    {ctype='unsigned char',      label='_unknown1'},                            --  4 -- Observed to be 00
    {ctype='unsigned char',      label='_unknown2'},                            --  5 -- Observed to be 00
    {ctype='unsigned char',      label='Logout Type'},                          --  6 -- /logout = 01, /pol == 02 (removed), /shutdown = 03
    {ctype='unsigned char',      label='_unknown3'},                            --  7 -- Observed to be 00
}

-- Sit
fields.outgoing[0x0EA] = L{
    {ctype='unsigned char',     label='Movement'},                              --  4
    {ctype='unsigned char',     label='_unknown1'},                             --  5
    {ctype='unsigned char',     label='_unknown2'},                             --  6
    {ctype='unsigned char',     label='_unknown3'},                             --  7
}

-- Cancel
fields.outgoing[0x0F1] = L{
    {ctype='unsigned char',     label='Buff ID'},                               --  4
    {ctype='unsigned char',     label='_unknown1'},                             --  5
    {ctype='unsigned char',     label='_unknown2'},                             --  6
    {ctype='unsigned char',     label='_unknown3'},                             --  7
}

-- Widescan
fields.outgoing[0x0F4] = L{
    {ctype='unsigned char',     label='Flags'},                                 --  4   1 when requesting widescan information. No other values observed.
    {ctype='unsigned char',     label='_unknown1'},                             --  5
    {ctype='unsigned short',    label='_unknown2'},                             --  6
}

-- Widescan Track
fields.outgoing[0x0F5] = L{
    {ctype='unsigned short',    label='Index',                  fn=index},      --  4 Setting an index of 0 stops tracking
}

-- Job Change
fields.outgoing[0x100] = L{
    {ctype='unsigned char',     label='Main Job ID'},                           --  4
    {ctype='unsigned char',     label='Sub Job ID'},                            --  5
    {ctype='unsigned char',     label='_unknown1'},                             --  6
    {ctype='unsigned char',     label='_unknown2'},                             --  7
}

-- Untraditional Equip
-- Currently only commented for changing instincts in Monstrosity. Refer to the doku wiki for information on Autos/BLUs.
-- http://dev.windower.net/doku.php?id=packets:outgoing:0x102_blue_magic_pup_attachment_equip
fields.outgoing[0x102] = L{
    {ctype='unsigned short',    label='_unknown1'},                             --  4  -- 00 00 for Monsters
    {ctype='unsigned short',    label='_unknown1'},                             --  6  -- Varies by Monster family for the species change packet. Monsters that share the same tnl seem to have the same value. 00 00 for instinct changing.
    {ctype='unsigned char',     label='Main Job ID'},                           --  8  --  0x17 for Monsters
    {ctype='unsigned char',     label='Sub Job ID'},                            --  9  --  0x00 for Monsters
    {ctype='unsigned short',    label='Flag'},                                  --  A  -- 04 00 for Monsters changing instincts. 01 00 for changing Monsters
    {ctype='unsigned short',    label='Species ID'},                            --  C  -- True both for species change and instinct change packets
    {ctype='unsigned short',    label='_unknown2'},                             --  E  -- 00 00 for Monsters
    {ctype='unsigned short',    label='Instinct ID 1'},                         -- 10
    {ctype='unsigned short',    label='Instinct ID 2'},                         -- 12
    {ctype='unsigned short',    label='Instinct ID 3'},                         -- 14
    {ctype='unsigned short',    label='Instinct ID 4'},                         -- 16
    {ctype='unsigned short',    label='Instinct ID 5'},                         -- 18
    {ctype='unsigned short',    label='Instinct ID 6'},                         -- 1A
    {ctype='unsigned short',    label='Instinct ID 7'},                         -- 1C
    {ctype='unsigned short',    label='Instinct ID 8'},                         -- 1E
    {ctype='unsigned short',    label='Instinct ID 9'},                         -- 20
    {ctype='unsigned short',    label='Instinct ID 10'},                        -- 22
    {ctype='unsigned short',    label='Instinct ID 11'},                        -- 24
    {ctype='unsigned short',    label='Instinct ID 12'},                        -- 26
    {ctype='unsigned char',     label='Name ID 1'},                             -- 28
    {ctype='unsigned char',     label='Name ID 2'},                             -- 29
    {ctype='char*',             label='_unknown'},                              -- 2A  -- All 00s for Monsters
}

-- Zone update
fields.incoming[0x00A] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned short',    label='Player index',       fn=index},          --  8
    {ctype='char[38]',          label='_unknown1'},                             --  A
    {ctype='unsigned char',     label='Zone ID',            fn=zone},           -- 30
    {ctype='char[19]',          label='_unknown3'},                             -- 31
    {ctype='unsigned char',     label='Weather ID',         fn=weather},        -- 44
    {ctype='char[63]',          label='_unknown4'},                             -- 45
    {ctype='char[16]',          label='Player name'},                           -- 84
    {ctype='char[113]',         label='_unknown5'},                             -- 94
}

-- Zone Response
fields.incoming[0x00B] = L{
    {ctype='unsigned int',      label='Type'},                                  --  4 Logout: 1, Teleport/Warp: 2, Regular zone: 3
    {ctype='unsigned int',      label='IP',                 fn=ip},             --  8
    {ctype='unsigned short',    label='Port'},                                  --  C
    {ctype='unsigned short',    label='_unknown1'},                             -- 10
    {ctype='unsigned short',    label='_unknown2'},                             -- 12
    {ctype='unsigned short',    label='_unknown3'},                             -- 14
    {ctype='unsigned short',    label='_unknown4'},                             -- 16
    {ctype='unsigned short',    label='_unknown5'},                             -- 18
    {ctype='unsigned short',    label='_unknown6'},                             -- 1A
    {ctype='unsigned short',    label='_unknown7'},                             -- 1C
}

-- PC Update
fields.incoming[0x00D] = L{
	-- The flags in this byte are complicated and may not strictly be flags. 
	-- Byte 32: -- Mentor is somewhere in this byte
	--  1 = None
	--  2 = Deletes everyone
	--  4 = Deletes everyone
	--  8 = None
	-- 16 = None
	-- 32 = None
	-- 64 = None
	-- 128 = None
	
	
	-- Byte 33:
	--  1 = None
	--  2 = None
	--  4 = None
	--  8 = LFG
	-- 16 = Anon
	-- 32 = Turns your name orange
	-- 64 = Away
	-- 128 = None
	
	-- Byte 34:
	--  1 = POL Icon, can target?
	--  2 = no notable effect
	--  4 = DCing
	--  8 = Untargettable
	-- 16 = No linkshell
	-- 32 = No Linkshell again
	-- 64 = No linkshell again
	-- 128 = No linkshell again
	
	-- Byte 35:
	--  1 = Trial Account
	--  2 = Trial Account
	--  4 = GM Mode
	--  8 = None
	-- 16 = None
	-- 32 = Invisible models
	-- 64 = None
	-- 128 = Bazaar
    {ctype='unsigned int',      label='ID',                 fn=id},             --  4
    {ctype='unsigned short',    label='Index',              fn=index},          --  8
    {ctype='unsigned char',     label='Mask',               fn=bin-{1}},        --  A
    {ctype='unsigned char',     label='Body Rotation',      fn=dir},            --  B
    {ctype='float',             label='X Position'},                            --  C
    {ctype='float',             label='Z Position'},                            -- 10
    {ctype='float',             label='Y Position'},                            -- 14
    {ctype='unsigned short',    label='Head Rotation',      fn=dir},            -- 18
    {ctype='unsigned short',    label='Target Index *2',    fn=index..s-{2}},   -- 1A
    {ctype='unsigned char',     label='Current Speed'},                         -- 1C
    {ctype='unsigned char',     label='Base Speed'},                            -- 1D
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Animation'},                             -- 1F
    {ctype='unsigned short',    label='Status'},                                -- 20
    {ctype='unsigned short',    label='Flags'},                                 -- 22
    {ctype='unsigned char',     label='Linkshell Red'},                         -- 24
    {ctype='unsigned char',     label='Linkshell Green'},                       -- 25
    {ctype='unsigned char',     label='Linkshell Blue'},                        -- 26
    {ctype='unsigned int',      label='_unknown3'},                             -- 27
    {ctype='unsigned int',      label='_unknown4'},                             -- 2B   Flags again
    {ctype='unsigned int',      label='_unknown5'},                             -- 2F
    {ctype='unsigned int',      label='_unknown6'},                             -- 33   DSP notes that the 6th bit of byte 54 is the Ballista flag
    {ctype='unsigned int',      label='_unknown7'},                             -- 37
    {ctype='unsigned int',      label='_unknown8'},                             -- 3B
    {ctype='unsigned int',      label='_unknown9'},                             -- 3F
    {ctype='unsigned char',     label='Face Flags'},                            -- 43   0, 3, 4, or 8
    {ctype='unsigned char',     label='Face'},                                  -- 44
    {ctype='unsigned char',     label='Race'},                                  -- 45
    {ctype='unsigned short',    label='Head'},                                  -- 46
    {ctype='unsigned short',    label='Body'},                                  -- 48
    {ctype='unsigned short',    label='Hands'},                                 -- 4A
    {ctype='unsigned short',    label='Legs'},                                  -- 4C
    {ctype='unsigned short',    label='Feet'},                                  -- 4E
    {ctype='unsigned short',    label='Main'},                                  -- 50
    {ctype='unsigned short',    label='Sub'},                                   -- 52
    {ctype='unsigned short',    label='Ranged'},                                -- 54
    {ctype='char*',             label='Character Name'},                        -- 56 -   *
}

-- NPC Update
-- There are two different types of these packets. One is for regular NPCs, the other occurs for certain NPCs (often nameless) and differs greatly in structure.
-- The common fields seem to be the ID, Index, mask and _unknown3.
-- The second one seems to have an int counter at 0x38 that increases by varying amounts every time byte 0x1F changes.
-- Currently I don't know how to algorithmically distinguish when the packets are different.
fields.incoming[0x00E] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             --  4
    {ctype='unsigned short',    label='Index',              fn=index},          --  8
    {ctype='unsigned char',     label='Mask',               fn=bin-{1}},        --  A
    {ctype='unsigned char',     label='Rotation',           fn=dir},            --  B
    {ctype='float',             label='X Position'},                            --  C
    {ctype='float',             label='Z Position'},                            -- 10
    {ctype='float',             label='Y Position'},                            -- 14
    {ctype='unsigned int',      label='Walk Count'},                            -- 18   Steadily increases until rotation changes. Does not reset while the mob isn't walking. Only goes until 0xFF1F.
    {ctype='unsigned short',    label='_unknown3',          fn=bin-{2}},        -- 1A
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Animation'},                             -- 1F
    {ctype='unsigned int',      label='_unknown4',          fn=bin-{4}},        -- 20
    {ctype='unsigned int',      label='_unknown5',          fn=bin-{4}},        -- 24
    {ctype='unsigned int',      label='_unknown6',          fn=bin-{4}},        -- 28
    {ctype='unsigned int',      label='Claimer ID',         fn=id},             -- 2C
    {ctype='unsigned short',    label='_unknown7'},                             -- 30
    {ctype='unsigned short',    label='Model'},                                 -- 32
    {ctype='char*',             label='Name'},                                  -- 34 -   *
}

-- Incoming Chat
fields.incoming[0x017] = L{
    {ctype='unsigned char',     label='Mode'},                                  --  4   Chat mode.
    {ctype='bool',              label='GM'},                                    --  5   1 for GM or 0 for not
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           --  6   Zone ID, used for Yell
    {ctype='char[16]',          label='Sender Name'},                           --  8   Name
    {ctype='char*',             label='Message'},                               -- 17   Message, occasionally terminated by spare 00 bytes. Max of 150 characters.
}

-- Job Info
fields.incoming[0x01B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             --  4   Observed value of 05
    {ctype='unsigned char',     label='Main Job ID'},                           --  8
    {ctype='unsigned char',     label='Flag or Main Job Level?'},               --  9
    {ctype='unsigned char',     label='Flag or Sub Job Level?'},                --  A
    {ctype='unsigned char',     label='Sub Job ID'},                            --  B
    {ctype='unsigned int',      label='_unknown2'},                             --  C   Flags -- FF FF FF 00 observed
    {ctype='unsigned char',     label='_unknown3'},                             -- 10   Flag or List Start
    {ctype='unsigned char',     label='WAR Level'},                             -- 11
    {ctype='unsigned char',     label='MNK Level'},                             -- 12
    {ctype='unsigned char',     label='WHM Level'},                             -- 13
    {ctype='unsigned char',     label='BLM Level'},                             -- 14
    {ctype='unsigned char',     label='RDM Level'},                             -- 15
    {ctype='unsigned char',     label='THF Level'},                             -- 16
    {ctype='unsigned char',     label='PLD Level'},                             -- 17
    {ctype='unsigned char',     label='DRK Level'},                             -- 18
    {ctype='unsigned char',     label='BST Level'},                             -- 19
    {ctype='unsigned char',     label='BRD Level'},                             -- 1A
    {ctype='unsigned char',     label='RNG Level'},                             -- 1B
    {ctype='unsigned char',     label='SAM Level'},                             -- 1C
    {ctype='unsigned char',     label='NIN Level'},                             -- 1D
    {ctype='unsigned char',     label='DRG Level'},                             -- 1E
    {ctype='unsigned char',     label='SMN Level'},                             -- 1F
    {ctype='unsigned short',    label='Base STR'},                              -- 20  -- Altering these stat values has no impact on your equipment menu.
    {ctype='unsigned short',    label='Base DEX'},                              -- 22
    {ctype='unsigned short',    label='Base VIT'},                              -- 24
    {ctype='unsigned short',    label='Base AGI'},                              -- 26
    {ctype='unsigned short',    label='Base INT'},                              -- 28
    {ctype='unsigned short',    label='Base MND'},                              -- 2A
    {ctype='unsigned short',    label='Base CHR'},                              -- 2C
    {ctype='char[14]',          label='_unknown4'},                             -- 2E   Flags and junk? Hard to say. All 0s observed.
    {ctype='unsigned int',      label='Maximum HP'},                            -- 3C
    {ctype='unsigned int',      label='Maximum MP'},                            -- 40
    {ctype='unsigned int',      label='Flags'},                                 -- 44   Looks like a bunch of flags. Observed value if 01 00 00 00
    {ctype='unsigned char',     label='_unknown5'},                             -- 48   Potential flag to signal the list start. Observed value of 01
    {ctype='unsigned char',     label='WAR Level'},                             -- 49
    {ctype='unsigned char',     label='MNK Level'},                             -- 4A
    {ctype='unsigned char',     label='WHM Level'},                             -- 4B
    {ctype='unsigned char',     label='BLM Level'},                             -- 4C
    {ctype='unsigned char',     label='RDM Level'},                             -- 4D
    {ctype='unsigned char',     label='THF Level'},                             -- 4E
    {ctype='unsigned char',     label='PLD Level'},                             -- 4F
    {ctype='unsigned char',     label='DRK Level'},                             -- 50
    {ctype='unsigned char',     label='BST Level'},                             -- 51
    {ctype='unsigned char',     label='BRD Level'},                             -- 52
    {ctype='unsigned char',     label='RNG Level'},                             -- 53
    {ctype='unsigned char',     label='SAM Level'},                             -- 54
    {ctype='unsigned char',     label='NIN Level'},                             -- 55
    {ctype='unsigned char',     label='DRG Level'},                             -- 56
    {ctype='unsigned char',     label='SMN Level'},                             -- 57
    {ctype='unsigned char',     label='BLU Level'},                             -- 58
    {ctype='unsigned char',     label='COR Level'},                             -- 59
    {ctype='unsigned char',     label='PUP Level'},                             -- 5A
    {ctype='unsigned char',     label='DNC Level'},                             -- 5B
    {ctype='unsigned char',     label='SCH Level'},                             -- 5C
    {ctype='unsigned char',     label='GEO Level'},                             -- 5D
    {ctype='unsigned char',     label='RUN Level'},                             -- 5E
    {ctype='unsigned char',     label='Current Monster Level'},                 -- 5F
    {ctype='unsigned int',      label='Encumbrance Flags'},                     -- 60   [legs, hands, body, head, ammo, range, sub, main,] [back, right_ring, left_ring, right_ear, left_ear, waist, neck, feet] [HP, CHR, MND, INT, AGI, VIT, DEX, STR,] [X X X X X X X MP]
}

-- Item Assign
fields.incoming[0x01F] = L{
    {ctype='unsigned int',      label='_unknown1',          const=0x00000001},  --  4
    {ctype='unsigned short',    label='Item ID',            fn=item},           --  8
    {ctype='unsigned char',     label='_padding1',          const=0x00},        --  A
    {ctype='unsigned char',     label='Inventory ID'},                          --  B
    {ctype='unsigned char',     label='Inventory Status'},                      --  C
    {ctype='char[3]',           label='_junk1'},                                --  D
}

-- Count to 80
fields.incoming[0x026] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        --  4
    {ctype='unsigned char',     label='Counter'},                               --  5   Varies sequentially between 0x01 and 0x50
    {ctype='char[22]',          label='_unknown2',          const=0},           --  6
}

-- Encumbrance Release
fields.incoming[0x027] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned short',    label='Player index',       fn=index},          --  8
    {ctype='unsigned char',     label='Slot or Stat ID'},                       --  A  -- 85 = DEX Down, 87 = AGI Down, 8A = CHR Down, 8B = HP Down, 7A = Head/Neck restriction, 7D = Leg/Foot Restriction
    {ctype='unsigned char',     label='_unknown1'},                             --  B  --  9C
    {ctype='unsigned int',      label='_unknown2'},                             --  C  -- 04 00 00 00
    {ctype='unsigned int',      label='_unknown3'},                             -- 10  -- B6 E3 39 00
    {ctype='unsigned char',     label='_unknown4'},                             -- 14  -- 01 or 04?
    {ctype='char[11]',          label='_unknown5'},                             -- 15
    {ctype='char[16]',          label='Player name'},                           -- 20
    {ctype='char[16]',          label='_unknown6'},                             -- 30
    {ctype='char[16]',          label='Player name'},                           -- 40
    {ctype='char[32]',          label='_unknown7'},                             -- 50
}

-- Action Message
fields.incoming[0x029] = L{
    {ctype='unsigned int',      label='Actor ID',           fn=id},             --  4
    {ctype='unsigned int',      label='Target ID',          fn=id},             --  8
    {ctype='unsigned int',      label='param_1'},                               --  C
    {ctype='unsigned char',     label='param_2'},                               -- 10  --  6 bits of byte 16
    {ctype='char[3]',           label='param_3'},                               -- 11  -- Also includes the last 2 bits of byte 16.
    {ctype='unsigned short',    label='Actor Index',        fn=index},          -- 14  -- B6 E3 39 00
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16  -- 01 or 04?
    {ctype='unsigned short',    label='Message ID'},                            -- 18
    {ctype='unsigned short',    label='_unknown1'},                             -- 1A
}

-- Item Assign
fields.incoming[0x02A] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned int',      label='Param 1'},                               --  8
    {ctype='unsigned int',      label='Param 2'},                               --  C
    {ctype='unsigned int',      label='Param 3'},                               -- 10
    {ctype='unsigned int',      label='Param 4'},                               -- 14
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 18
    {ctype='unsigned short',    label='Message ID'},                            -- 1A   The high bit is occasionally set, though the reason for it is unclear.
    {ctype='unsigned int',      label='_unknown1',          const=0x06000000},  -- 1C
}

-- Synth Animation
fields.incoming[0x030] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned short',    label='Index',              fn=index},          --  8
    {ctype='unsigned short',    label='Effect'},                                --  A  -- 10 00 is water, 11 00 is wind, 12 00 is fire, 13 00 is earth, 14 00 is lightning, 15 00 is ice, 16 00 is light, 17 00 is dark
    {ctype='unsigned char',     label='Param'},                                 --  C  -- 00 is NQ, 01 is break, 02 is HQ
    {ctype='unsigned char',     label='Animation'},                             --  D  -- Always C2 for me.
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        --  E  -- Appears to just be trash.
}

-- Shop
fields.incoming[0x03C] = L{
    {ctype='unsigned short',    label='_zero1',             const=0x0000},      --  4
    {ctype='unsigned short',    label='_padding1'},                             --  6
    {ref=types.shop_item,       label='Item',               count='*'},         --  8 -   *
}

-- Pet Stat
-- This packet varies and is indexed by job ID (byte 4)
fields.incoming._mult[0x044] = {}
fields.incoming[0x044] = function(data)
    return data, fields.incoming._mult[0x044][data:sub(5,5):byte()]
end

fields.incoming._mult[0x044][0x12] = L{     -- PUP
-- Packet 0x044 is sent twice in sequence when stats could change. This can be caused by anything from
-- using a Maneuver on PUP to changing job. The two packets are the same length. The first
-- contains information about your main job. The second contains information about your
-- subjob and has the Subjob flag flipped. Below is mostly for PUP.

    {ctype='unsigned char',     label='Job ID'},                                --  4
    {ctype='bool',              label='Subjob Flag'},                           --  5
    {ctype='unsigned char',     label='_unknown'},                              --  6
    {ctype='unsigned char',     label='_unknown'},                              --  7
    {ctype='unsigned char',     label='Automaton Head'},                        --  8   Harlequinn 1, Valoredge 2, Sharpshot 3, Stormwaker 4, Soulsoother 5, Spiritreaver 6
    {ctype='unsigned char',     label='Automaton Frame'},                       --  9   Harlequinn 20, Valoredge 21, Sharpshot 22, Stormwaker 23
    {ctype='unsigned char',     label='Slot 1'},                                --  A   Attachment assignments are based off their position in the equipment list.
    {ctype='unsigned char',     label='Slot 2'},                                --  B   Strobe is 01, etc.
    {ctype='unsigned char',     label='Slot 3'},                                --  C
    {ctype='unsigned char',     label='Slot 4'},                                --  D
    {ctype='unsigned char',     label='Slot 5'},                                --  E
    {ctype='unsigned char',     label='Slot 6'},                                --  F
    {ctype='unsigned char',     label='Slot 7'},                                -- 10
    {ctype='unsigned char',     label='Slot 8'},                                -- 11
    {ctype='unsigned char',     label='Slot 9'},                                -- 12
    {ctype='unsigned char',     label='Slot 10'},                               -- 13
    {ctype='unsigned char',     label='Slot 11'},                               -- 14
    {ctype='unsigned char',     label='Slot 12'},                               -- 15
    {ctype='unsigned short',    label='_unknown'},                              -- 16
    {ctype='unsigned int',      label='Available Heads'},                       -- 18   Flags for the available heads (Position corresponds to Item ID shifted down by 8192)
    {ctype='unsigned int',      label='Available Bodies'},                      -- 1C   Flags for the available bodies (Position corresponds to Item ID)
    {ctype='unsigned int',      label='_unknown'},                              -- 20
    {ctype='unsigned int',      label='_unknown'},                              -- 24
    {ctype='unsigned int',      label='_unknown'},                              -- 28
    {ctype='unsigned int',      label='_unknown'},                              -- 2C
    {ctype='unsigned int',      label='_unknown'},                              -- 30
    {ctype='unsigned int',      label='_unknown'},                              -- 34
    {ctype='unsigned int',      label='Fire Attachments'},                      -- 38   Flags for the available Fire Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Ice Attachments'},                       -- 3C   Flags for the available Ice Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Wind Attachments'},                      -- 40   Flags for the available Wind Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Earth Attachments'},                     -- 44   Flags for the available Earth Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Thunder Attachments'},                   -- 48   Flags for the available Thunder Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Water Attachments'},                     -- 4C   Flags for the available Water Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Light Attachments'},                     -- 50   Flags for the available Light Attachments (Position corresponds to Item ID)
    {ctype='unsigned int',      label='Dark Attachments'},                      -- 54   Flags for the available Dark Attachments (Position corresponds to Item ID)
    {ctype='char[16]',          label='Pet Name'},                              -- 58
    {ctype='unsigned short',    label='Max or Current HP'},                     -- 68   The next two are max or current HP. My PUP sucks too much to fight things, so idk which.
    {ctype='unsigned short',    label='Max or Current HP'},                     -- 6A   The next two are max or current HP. My PUP sucks too much to fight things, so idk which.
    {ctype='unsigned short',    label='Max or Current MP'},                     -- 6C   Likely max or current MP
    {ctype='unsigned short',    label='Max or Current MP'},                     -- 6E   Likely max or current MP
    {ctype='unsigned short',    label='Max or Current Melee Skill'},            -- 70
    {ctype='unsigned short',    label='Max or Current Melee Skill'},            -- 72
    {ctype='unsigned short',    label='Max or Current Ranged Skill'},           -- 74
    {ctype='unsigned short',    label='Max or Current Ranged Skill'},           -- 76
    {ctype='unsigned short',    label='Max or Current Magic Skill'},            -- 78
    {ctype='unsigned short',    label='Max or Current Magic Skill'},            -- 7A
    {ctype='unsigned int',      label='_unknown'},                              -- 7C
    {ctype='unsigned short',    label='Base STR'},                              -- 80
    {ctype='unsigned short',    label='Additional STR'},                        -- 82
    {ctype='unsigned short',    label='Base DEX'},                              -- 84
    {ctype='unsigned short',    label='Additional DEX'},                        -- 86
    {ctype='unsigned short',    label='Base VIT'},                              -- 88
    {ctype='unsigned short',    label='Additional VIT'},                        -- 8A
    {ctype='unsigned short',    label='Base AGI'},                              -- 8C
    {ctype='unsigned short',    label='Additional AGI'},                        -- 8E
    {ctype='unsigned short',    label='Base INT'},                              -- 90
    {ctype='unsigned short',    label='Additional INT'},                        -- 92
    {ctype='unsigned short',    label='Base MND'},                              -- 94
    {ctype='unsigned short',    label='Additional MND'},                        -- 96
    {ctype='unsigned short',    label='Base CHR'},                              -- 98
    {ctype='unsigned short',    label='Additional CHR'},                        -- 9A

    -- For Black Mage, 0x29 to 0x43 appear to represent the black magic that you know
}

-- Delivery Item
fields.incoming[0x04B] = L{
    {ctype='unsigned char',     label='Packet Type'},                           --  4

	--  0x01: (Length is 88 bytes)
	-- Seems to occur when refreshing the d-box after any change (or before changes).
    {ctype='unsigned char',     label='_unknown2'},                             --  5
    {ctype='unsigned char',     label='Delivery Slot ID'},                      --  6   This goes left to right and then drops down a row and left to right again. Value is 0 to 7.
    {ctype='char[5]',           label='_unknown3'},                             --  7   All FF values observed
    {ctype='unsigned char',     label='_unknown4'},                             --  C   01 observed
    {ctype='unsigned char',     label='_unknown5'},                             --  D   02 observed
    {ctype='unsigned short',    label='_unknown6'},                             --  E   FF FF observed
    {ctype='unsigned int',      label='_unknown7'},                             -- 10   07 00 00 00 and 0B 00 00 00 observed - Possibly flags. Rare vs. Rare/Ex.
    {ctype='char[16]',          label='Sender Name'},                           -- 14
    {ctype='unsigned int',      label='_unknown7'},                             -- 24   46 32 00 00 and 42 32 00 00 observed - Possibly flags. Rare vs. Rare/Ex.?
    {ctype='unsigned int',      label='UNIX Timestamp for sending time'},       -- 28
    {ctype='unsigned int',      label='_unknown8'},                             -- 2C   00 00 00 00 observed
    {ctype='unsigned short',    label='Item ID'},                               -- 30
    {ctype='unsigned short',    label='_unknown9'},                             -- 32   Fiendish Tome: Chapter 11 had it, but Oneiros Pebble was just 00 00
    {ctype='unsigned int',      label='Flags1'},                                -- 34   01/04 00 00 00 observed
    {ctype='unsigned short',    label='Number of Item'},                        -- 38
    {ctype='char[30]',          label='_unknown10'},                            -- 40   All 00 observed
	
	--  0x02: (Length is 88 bytes)
	-- Seems to occur when placing items into the d-box.
	
	--  0x03: (Length is 88 bytes)
	-- Two occur per item that is actually sent (hitting okay to send).
	
	--  0x04: (Length is 88 bytes)
	-- Two occur per sent item that is Canceled.
	
	--  0x05 (Length is 20 bytes)
	-- Seems to occur quasi-randomly. Can be seen following spells.
    {ctype='unsigned char',     label='_unknown2'},                             --  5
    {ctype='char[6]',           label='_unknown3'},                             --  6   All FF values observed
    {ctype='unsigned char',     label='_unknown4'},                             --  C   01 and 02 observed
    {ctype='unsigned char',     label='_unknown5'},                             --  D   FF observed
    {ctype='unsigned char',     label='_unknown6'},                             --  E   00 and FF observed
    {ctype='unsigned char',     label='_unknown7'},                             --  F   FF observed
    {ctype='unsigned int',      label='_unknown8'},                             -- 10   00 00 00 00 observed
	
	--  0x06: (Length is 88 bytes)
	-- Occurs for new items.
	-- Two of these are sent sequentially. The first one doesn't seem to contain much/any
	-- information and the second one is very similar to a type 0x01 packet
	-- First packet's frst line:   4B 58 xx xx 06 01 00 01 FF FF FF FF 02 02 FF FF
	-- Second packet's first line: 4B 58 xx xx 06 01 00 FF FF FF FF FF 01 02 FF FF
    {ctype='unsigned char',     label='_unknown2'},                             --  5   01 Observed
    {ctype='unsigned char',     label='Delivery Slot ID'},                      --  6
    {ctype='char[5]',           label='_unknown3'},                             --  7   01 FF FF FF FF and FF FF FF FF FF observed
    {ctype='unsigned char',     label='_unknown4'},                             --  C   01 observed
    {ctype='unsigned char',     label='Packet Number'},                         --  D   02 and 03 observed
    {ctype='unsigned short',    label='_unknown6'},                             --  E   FF FF observed
    {ctype='unsigned int',      label='_unknown7'},                             -- 10   06 00 00 00 and 07 00 00 00 observed - (06 was for the first packet and 07 was for the second)
    {ctype='char[16]',          label='Sender Name'},                           -- 14
    {ctype='unsigned int',      label='_unknown7'},                             -- 24   46 32 00 00 and 42 32 00 00 observed - Possibly flags. Rare vs. Rare/Ex.?
    {ctype='unsigned int',      label='UNIX Timestamp for sending time'},       -- 28
    {ctype='unsigned int',      label='_unknown8'},                             -- 2C   00 00 00 00 observed
    {ctype='unsigned short',    label='Item ID'},                               -- 30
    {ctype='unsigned short',    label='_unknown9'},                             -- 32   Fiendish Tome: Chapter 11 had it, but Oneiros Pebble was just 00 00
    {ctype='unsigned int',      label='Flags1'},                                -- 34   01/04 00 00 00 observed
    {ctype='unsigned short',    label='Number of Item'},                        -- 38
    {ctype='char[30]',          label='_unknown10'},                            -- 3A   All 00 observed

	--  0x07: Length is 20 or 88 bytes
	-- Sent when something is being removed from the outbox. 20 byte packet is followed by an 88 byte packet for each item removed.
	
	--  0x08: (Length is 88 bytes)
	-- Occur as the first packet when removing or dropping something from the d-box.
	
	--  0x09: (Length is 88 bytes)
	-- Occur when someone returns something from the d-box.
	
	--  0x0A: (Length is 88 bytes)
	-- Occurs as the second packet when removing something from the d-box or outbox.
	
	--  0x0B: (Length is 88 bytes)
	-- Occurs as the second packet when dropping something from the d-box.
	
	--  0x0C: (Length is 20 bytes)
	-- Sent after entering a name and hitting "OK" in the outbox.
	
	--  0x0F: (Length is 20 bytes)
	-- One is sent after closing the d-box or outbox.
}

-- Data Download 2
fields.incoming[0x04F] = L{
--   This packet's contents are nonessential. They are often leftovers from other outgoing
--   packets. It is common to see things like inventory size, equipment information, and
--   character ID in this packet. They do not appear to be meaningful and the client functions 
--   normally even if they are blocked.
    {ctype='unsigned int',     label='_unknown1'},                              --  4
}

-- Equip
fields.incoming[0x050] = L{
    {ctype='unsigned char',     label='Inventory ID',       fn=inv},            --  4
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           --  5
    {ctype='unsigned char',     label='_unknown1'},                             --  6
    {ctype='unsigned char',     label='_unknown2'},                             --  7
}

-- Model Change
fields.incoming[0x051] = L{
    {ctype='unsigned char',     label='Face'},                                  --  4
    {ctype='unsigned char',     label='Race'},                                  --  5
    {ctype='unsigned short',    label='Head'},                                  --  6
    {ctype='unsigned short',    label='Body'},                                  --  8
    {ctype='unsigned short',    label='Hands'},                                 --  A
    {ctype='unsigned short',    label='Legs'},                                  --  C
    {ctype='unsigned short',    label='Feet'},                                  --  E
    {ctype='unsigned short',    label='Main'},                                  -- 10
    {ctype='unsigned short',    label='Sub'},                                   -- 12
    {ctype='unsigned short',    label='Ranged'},                                -- 14
    {ctype='unsigned short',    label='_unknown1'},                             -- 16   May varying meaningfully, but it's unclear
}

-- Logout Time - This packet is likely used for an entire class of system messages,
-- but the only one commonly encountered is the logout counter.
fields.incoming[0x053] = L{
    {ctype='unsigned int',      label='param'},                                 --  4   Parameter
    {ctype='unsigned int',      label='_unknown1'},                             --  8   00 00 00 00 observed
    {ctype='unsigned short',    label='Message ID'},                            --  C   It is unclear which dialogue table this corresponds to
    {ctype='unsigned short',    label='_unknown2'},                             --  E   Probably junk.
}

-- Key Item Log
--[[fields.incoming[0x055] = L{
	-- There are 6 of these packets sent on zone, which likely corresponds to the 6 categories of key items.
	-- FFing these packets between bytes 0x14 and 0x82 gives you access to all (or almost all) key items.
}]]

-- Weather Change
fields.incoming[0x057] = L{
    {ctype='unsigned int',      label='Vanadiel Time',      fn=vtime},          --  4   Units of minutes.
    {ctype='unsigned char',     label='Weather ID',         fn=weather},        --  8
    {ctype='unsigned char',     label='_unknown1'},                             --  9
    {ctype='unsigned short',    label='_unknown2'},                             --  A
}

-- NPC Spawn
fields.incoming[0x05B] = L{
    {ctype='float',             label='X Position'},                            --  4
    {ctype='float',             label='Z Position'},                            --  8
    {ctype='float',             label='Y Position'},                            --  C
    {ctype='unsigned int',      label='Mob ID',             fn=id},             -- 10
    {ctype='unsigned short',    label='Mob Index',          fn=index},          -- 14
    {ctype='unsigned char',     label='Type'},                                  -- 16   3 for regular Monsters, 0 for Treasure Caskets and NPCs
    {ctype='unsigned char',     label='_unknown1'},                             -- 17   Always 0 if Type is 3, otherwise a seemingly random non-zero number
    {ctype='unsigned int',      label='_unknown2'},                             -- 18
}

-- Char Stats
fields.incoming[0x061] = L{
    {ctype='unsigned int',      label='Maximum HP'},                            --  4
    {ctype='unsigned int',      label='Maximum MP'},                            --  8
    {ctype='unsigned char',     label='Main Job ID',        fn=job},            --  C
    {ctype='unsigned char',     label='Main Job Level'},                        --  D
    {ctype='unsigned char',     label='Sub Job ID',         fn=job},            --  E
    {ctype='unsigned char',     label='Sub Job Level'},                         --  F
    {ctype='unsigned short',    label='Current EXP'},                           -- 10
    {ctype='unsigned short',    label='Required EXP'},                          -- 12
    {ctype='unsigned short',    label='Base STR'},                              -- 14
    {ctype='unsigned short',    label='Base DEX'},                              -- 16
    {ctype='unsigned short',    label='Base VIT'},                              -- 18
    {ctype='unsigned short',    label='Base AGI'},                              -- 1A
    {ctype='unsigned short',    label='Base INT'},                              -- 1C
    {ctype='unsigned short',    label='Base MND'},                              -- 1E
    {ctype='unsigned short',    label='Base CHR'},                              -- 20
    {ctype='signed short',      label='Added STR'},                             -- 22
    {ctype='signed short',      label='Added DEX'},                             -- 24
    {ctype='signed short',      label='Added VIT'},                             -- 26
    {ctype='signed short',      label='Added AGI'},                             -- 28
    {ctype='signed short',      label='Added INT'},                             -- 2A
    {ctype='signed short',      label='Added MND'},                             -- 2C
    {ctype='signed short',      label='Added CHR'},                             -- 2E
    {ctype='unsigned short',    label='Attack'},                                -- 30
    {ctype='unsigned short',    label='Defense'},                               -- 32
    {ctype='signed short',      label='Fire Resistance'},                       -- 34
    {ctype='signed short',      label='Wind Resistance'},                       -- 36
    {ctype='signed short',      label='Thunder Resistance'},                    -- 38
    {ctype='signed short',      label='Light Resistance'},                      -- 3A
    {ctype='signed short',      label='Ice Resistance'},                        -- 3C
    {ctype='signed short',      label='Earth Resistance'},                      -- 3E
    {ctype='signed short',      label='Water Resistance'},                      -- 40
    {ctype='signed short',      label='Dark Resistance'},                       -- 42
    {ctype='unsigned short',    label='Title ID',           fn=title},          -- 44
    {ctype='unsigned short',    label='Nation rank'},                           -- 46
    {ctype='unsigned short',    label='Rank points',        fn=cap-{0xFFF}},    -- 48
    {ctype='unsigned short',    label='Home point',         fn=zone},           -- 4A
    {ctype='unsigned short',    label='_unknown23'},                            -- 4C
    {ctype='unsigned short',    label='_unknown24'},                            -- 4E
    {ctype='unsigned short',    label='_unknown25'},                            -- 50
    {ctype='unsigned short',    label='_unknown26'},                            -- 52   00 00 observed.
}

-- Skills Update
fields.incoming[0x062] = L{
    {ctype='unsigned char[126]', label='_unknown1'},                             --  4
    {ctype='unsigned short',     label='Hand-to-Hand',       fn=cskill},         -- 82
    {ctype='unsigned short',     label='Dagger',             fn=cskill},         -- 84
    {ctype='unsigned short',     label='Sword',              fn=cskill},         -- 86
    {ctype='unsigned short',     label='Great Sword',        fn=cskill},         -- 88
    {ctype='unsigned short',     label='Axe',                fn=cskill},         -- 8A
    {ctype='unsigned short',     label='Great Axe',          fn=cskill},         -- 8C
    {ctype='unsigned short',     label='Scythe',             fn=cskill},         -- 8E
    {ctype='unsigned short',     label='Polearm',            fn=cskill},         -- 90
    {ctype='unsigned short',     label='Katana',             fn=cskill},         -- 92
    {ctype='unsigned short',     label='Great Katana',       fn=cskill},         -- 94
    {ctype='unsigned short',     label='Club',               fn=cskill},         -- 96
    {ctype='unsigned short',     label='Staff',              fn=cskill},         -- 98
--    {ctype='unsigned short',     label='',fn=cskill},         --  1
}

-- Unnamed 0x067
fields.incoming[0x067] = L{
-- The length of this packet is 24, 28, 36 or 40 bytes. The latter two seem to feature a 16 char
-- name field. 24/28 appears to be for NPCs/monsters. When summoning pets, their name appear in 
-- the 16 byte name field. 40 Appears to be for players, although it's 36 when summoning a pet.
-- _unknown1 is 02 09 for players and 03 05 for NPCs, unless players summon a pet, then it's
-- 44 07. The use of this packet is unclear.
    {ctype='unsigned short',    label='_unknown1'},                             --  4
    {ctype='unsigned short',    label='Player Index',       fn=index},          --  6
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  8
    {ctype='unsigned short',    label='Other Index',        fn=index},          --  C
    {ctype='unsigned short',    label='_unknown2'},                             --  E
    {ctype='unsigned int',      label='_unknown3'},                             -- 10   Always 0?
    {ctype='char*',             label='Other Name'},                            -- 14
}

-- LS Message
fields.incoming[0x0CC] = L{
    {ctype='int',               label='_unknown1'},                             --  4
    {ctype='char[128]',         label='Message'},                               --  8
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 88
    {ctype='char[16]',          label='Player Name'},                           -- 8C
    {ctype='unsigned int',      label='Permissions'},                           -- 98
    {ctype='char[16]',          label='Linkshell Name',     enc=ls_name_msg},   -- 9C   6-bit packed
}

-- Bazaar Message
fields.incoming[0x0CA] = L{
    {ctype='int',               label='_unknown1'},                             --  4   Could be characters starting the line - FD 02 02 18 observed
    {ctype='unsigned short',    label='_unknown2'},                             --  8   Could also be characters starting the line - 01 FD observed
    {ctype='char[118]',         label='Bazaar Message'},                        --  A   Terminated with a vertical tab
    {ctype='char[16]',          label='Player Name'},                           -- 80
    {ctype='unsigned short',    label='_unknown3'},                             -- 90   C6 01 observed. Not player index.
    {ctype='unsigned short',    label='_unknown4'},                             -- 92   00 00 observed.
}

-- Found Item
fields.incoming[0x0D2] = L{
--[[07:29:49  Incoming Packet: Found Item Content:  (Ancient Brass)
  XX  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
  00  D2 3C xx xx 01 00 00 00 9B 60 02 01 00 00 00 00 
  10  8D 07 9B 00 00 00 01 C3 53 94 94 52 00 00 00 00 
  20  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
  30  00 00 00 00 00 00 00 00 24 00 00 00 ]]
    {ctype='int',               label='_unknown1'},                             --  4   Could be characters starting the line - FD 02 02 18 observed
    {ctype='int',               label='Dropper ID'},                            --  8   Could also be characters starting the line - 01 FD observed
    {ctype='int',               label='_unknown2'},                             --  C   
    {ctype='short',             label='Item ID'},                               -- 10
    {ctype='int',               label='_unknown3'},                             -- 12
    {ctype='unsigned short',    label='_unknown4'},                             -- 92   00 00 observed.
}

-- Char Update
fields.incoming[0x0DF] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             --  4
    {ctype='unsigned int',      label='HP'},                                    --  8
    {ctype='unsigned int',      label='MP'},                                    --  C
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10   Truncated, does not include the decimal value.
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 14
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 16
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 17
    {ctype='unsigned short',    label='_unknown1'},                             -- 18
    {ctype='unsigned short',    label='_unknown2'},                             -- 1A
}

-- Char Info
fields.incoming[0x0E2] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned int',      label='HP'},                                    --  8
    {ctype='unsigned int',      label='MP'},                                    --  A
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10
    {ctype='unsigned int',      label='_unknown1'},                             -- 14   Looks like it could be flags for something.
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 18
    {ctype='unsigned char',     label='_unknown2'},                             -- 1A
    {ctype='unsigned char',     label='_unknown3'},                             -- 1B
    {ctype='unsigned char',     label='_unknown4'},                             -- 1C
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 1D
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 1E
    {ctype='unsigned char',     label='_unknown5'},                             -- 1F
    {ctype='unsigned char',     label='_unknown6'},                             -- 20
    {ctype='unsigned char',     label='_unknown7'},                             -- 21   Could be an initialization for the name. 0x01 observed.
    {ctype='char*',             label='Player Name'},                           -- 22   *   Maybe a base stat
}

-- Toggle Heal
fields.incoming[0x0E8] = L{
    {ctype='unsigned char',     label='Movement'},                              --  4   02 if caused by movement
    {ctype='unsigned char',     label='_unknown2'},                             --  5   00 observed
    {ctype='unsigned char',     label='_unknown3'},                             --  6   00 observed
    {ctype='unsigned char',     label='_unknown4'},                             --  7   00 observed
}

-- Widescan Mob
fields.incoming[0x0F4] = L{
    {ctype='unsigned short',    label='Index',              fn=index},          --  4
    {ctype='unsigned char',     label='_unknown1'},                             --  6
    {ctype='unsigned char',     label='Type'},                                  --  7   1 = NPC (green), 2 = Enemy (red), 0 = Other (blue)
    {ctype='short',             label='X Offset'},                              --  8   Offset on the map
    {ctype='short',             label='Y Offset'},                              --  A
    {ctype='char[16]',          label='Name'},                                  --  C   Slugged, may not extend all the way to 27. Up to 25 has been observed. This will be used if Type == 0
}

-- Widescan Track
fields.incoming[0x0F5] = L{
    {ctype='float',             label='X Position'},                            --  4
    {ctype='float',             label='Z Position'},                            --  8
    {ctype='float',             label='Y Position'},                            --  C
    {ctype='unsigned char',     label='_unknown1'},                             -- 10 Same value as _unknown1 of 0x0F4
    {ctype='unsigned char',     label='_padding1'},                             -- 11
    {ctype='unsigned short',    label='Index',              fn=index},          -- 12
    {ctype='unsigned int',      label='Status'},                                -- 14 1 for regular data, 2 when zoning (resets tracker), 3 when resetting (new wide scan)
}

-- Widescan Mark
fields.incoming[0x0F6] = L{
    {ctype='unsigned int',      label='Type'},                                  --  4   1 for the start of a widescan list. 2 for the end of the list.
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --  4
    {ctype='unsigned short',    label='Player Index',       fn=index},          --  8
    {ctype='unsigned char',     label='_unknown1'},                             --  A
    {ctype='unsigned char',     label='_unknown2'},                             --  B
}

local sizes = {}
sizes.bool = 1
sizes.char = 1
sizes.short = 2
sizes.int = 4
sizes.long = 8
sizes.float = 4
sizes.double = 8

local function parse(fs, data, max)
    max = max == '*' and 0 or max or 1

    local res = L{}
    local index = 0
    local count = 0
    while index < #data do
        count = count + 1
        for field in fs:it() do
            if field.ctype then
                field = table.copy(field)
                if max ~= 1 then
                    field.label = field.label..' '..tostring(count)
                end

                res:append(field)
                index = index + sizes[field.ctype:match('(%a+)[^%a]*$')]
            else
                local ext, size = parse(field.ref, data:sub(index + 1), field.count)
                res = res + ext
                index = index + size
            end
        end

        if count == max then
            return res, index
        end
    end

    return res, index
end

function fields.get(dir, id, data)
    local f = fields[dir][id]
    f = type(f) == 'function' and f(data) or f
    return f and data and parse(f, data:sub(5)) or f
end

return fields

--[[
Copyright (c) 2013, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
