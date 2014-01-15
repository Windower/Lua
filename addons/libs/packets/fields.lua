--[[
    A collection of detailed packet field information.
]]

require('pack')
require('functions')
require('strings')
require('maths')
require('lists')
bit = require('bit')

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
    from = from and from - 1 or 0
    to = to or 16
    return bit.band(bit.rshift(val, from), 2^(to - from) - 1)
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
        return os.date('%Y-%m-%dT%H:%M:%S'..timezone, os.time() - ts)
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

local function srank(val)
    return res.synth_ranks[val].name
end

local function inv(bag, val)
    if val == 0 then
        return '(None)'
    end

    local id = windower.ffxi.get_items()[res.bags[bag].english:lower()][val].id
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
    return  s(val, 1, 15):string() .. ', ' .. (s(val, 16, 16) == 1 and 'Capped' or 'Uncapped')
end

local function sskill(val)
    return  s(val, 6, 15):string() .. ', ' .. (s(val, 16, 16) == 1 and 'Capped' or 'Uncapped') .. ', ' .. (res.synth_ranks[s(val, 1, 5)] and res.synth_ranks[s(val, 1, 5)].name or 'Unknown: ' .. s(val, 1, 5))
end

--[[
    Custom types
]]
local types = {}
types.shop_item = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 00
    {ctype='unsigned short',    label='Item ID',            fn=item},           -- 04
    {ctype='unsigned short',    label='Shop Slot'},                             -- 08
}

--[[
    Outgoing packets
]]

-- Client Leave
fields.outgoing[0x00D] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04 -- Always 00?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05 -- Always 00?
    {ctype='unsigned char',     label='_unknown3'},                             -- 06 -- Always 00?
    {ctype='unsigned char',     label='_unknown4'},                             -- 07 -- Always 00?
}

-- Standard Client
fields.outgoing[0x015] = L{
    {ctype='float',             label='X Position'},                            -- 04
    {ctype='float',             label='Y Position'},                            -- 08
    {ctype='float',             label='Z Position'},                            -- 0C
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
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='Category'},                              -- 0A
    {ctype='unsigned short',    label='Param'},                                 -- 0C
    {ctype='unsigned short',    label='_unknown1'},                             -- 0E
}

-- Drop Item
fields.outgoing[0x028] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04
    {ctype='unsigned char',     label='Current Bag ID',     fn=bag},            -- 08
    {ctype='unsigned char',     label='Inventory Index'},                       -- 09 -- For the item being dropped
    {ctype='unsigned short',    label='_unknown2'},                             -- 10
}

-- Move Item
fields.outgoing[0x029] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04 -- 1 has been observed
    {ctype='unsigned char',     label='Current Bag ID',     fn=bag},            -- 08
    {ctype='unsigned char',     label='Target Bag ID',      fn=bag},            -- 09
    {ctype='unsigned char',     label='Inventory Index'},                       -- 10 -- For the item being moved
    {ctype='unsigned char',     label='_unknown2'},                             -- 11 -- Has taken the value 52. Unclear purpose.
}

-- Menu Item
fields.outgoing[0x036] = L{
-- Item order is Gil -> top row left-to-right -> bottom row left-to-right, but
-- they slide up and fill empty slots
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned int',      label='Item 1 Quantity'},                       -- 08
    {ctype='unsigned int',      label='Item 2 Quantity'},                       -- 0C
    {ctype='unsigned int',      label='Item 3 Quantity'},                       -- 10
    {ctype='unsigned int',      label='Item 4 Quantity'},                       -- 14
    {ctype='unsigned int',      label='Item 5 Quantity'},                       -- 18
    {ctype='unsigned int',      label='Item 6 Quantity'},                       -- 1C
    {ctype='unsigned int',      label='Item 7 Quantity'},                       -- 20
    {ctype='unsigned int',      label='Item 8 Quantity'},                       -- 24
    {ctype='unsigned int',      label='Item 9 Quantity'},                       -- 28
    {ctype='unsigned int',      label='_unknown1'},                             -- 2C
    {ctype='unsigned char',     label='Item 1 Index',       fn=inv+{0}},        -- 30   Gil has an Inventory Index of 0
    {ctype='unsigned char',     label='Item 2 Index',       fn=inv+{0}},        -- 31
    {ctype='unsigned char',     label='Item 3 Index',       fn=inv+{0}},        -- 32
    {ctype='unsigned char',     label='Item 4 Index',       fn=inv+{0}},        -- 33
    {ctype='unsigned char',     label='Item 5 Index',       fn=inv+{0}},        -- 34
    {ctype='unsigned char',     label='Item 6 Index',       fn=inv+{0}},        -- 35
    {ctype='unsigned char',     label='Item 7 Index',       fn=inv+{0}},        -- 36
    {ctype='unsigned char',     label='Item 8 Index',       fn=inv+{0}},        -- 37
    {ctype='unsigned char',     label='Item 9 Index',       fn=inv+{0}},        -- 38
    {ctype='unsigned char',     label='_unknown2'},                             -- 39
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 3A
    {ctype='unsigned char',     label='Number of Items'},                       -- 3C
}

-- Use Item
fields.outgoing[0x037] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned int',      label='_unknown1'},                             -- 08   00 00 00 00 observed
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned char',     label='Item Index',         fn=inv+{0}},        -- 0E
    {ctype='unsigned char',     label='_unknown2'},                             -- 0F   Takes values
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 10
}

-- Sort Item
fields.outgoing[0x03A] = L{
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
}

-- Delivery Box
fields.outgoing[0x04D] = L{
    {ctype='unsigned char',     label='Manipulation Type'},                     -- 04
	-- 
	
	-- Removing an item from the d-box sends type 0x08
	-- It then responds to the server's 0x4B (id=0x08) with a 0x0A type packet.
	-- Their assignment is the same, as far as I can see.
    {ctype='unsigned char',     label='_unknown1'},                             -- 05   01 observed
    {ctype='unsigned char',     label='Slot ID'},                               -- 06
    {ctype='char[5]',           label='_unknown2'},                             -- 07   FF FF FF FF FF observed
    {ctype='char[20]',          label='_unknown3'},                             -- 0C   All 00 observed
}

-- Equip
fields.outgoing[0x050] = L{
    {ctype='unsigned char',     label='Item Index',         fn=inv+{0}},        -- 04
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           -- 05
}

-- Conquest
fields.outgoing[0x05A] = L{
}

-- Dialogue options
fields.outgoing[0x05B] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned char',     label='Option index'},                          -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 09
    {ctype='unsigned char',     label='_unknown2'},                             -- 0B
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned short',    label='_unknown3'},                             -- 0E
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           -- 10
    {ctype='unsigned char',     label='_unknown4'},                             -- 12
    {ctype='unsigned char',     label='_unknown5'},                             -- 13
}

-- Equipment Screen (0x02 length) -- Also observed when zoning
fields.outgoing[0x061] = L{
}

-- Party invite
fields.outgoing[0x06E] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04   This is so weird. The client only knows IDs from searching for people or running into them. So if neither has happened, the manual invite will fail, as the ID cannot be retrieved.
    {ctype='unsigned short',    label='Target index',       fn=index},          -- 08   00 if target not in zone
    {ctype='unsigned char',     label='Alliance'},                              -- 0A   02 for alliance, 00 for party or if invalid alliance target (the client somehow knows..)
    {ctype='unsigned char',     label='_const1',            const=0x041},       -- 0B
}

-- Party leaving
fields.outgoing[0x06F] = L{
    {ctype='unsigned char',     label='_const1',            const=0x00},        -- 04   02 for alliance, 00 for party
}

-- Party breakup
fields.outgoing[0x070] = L{
    {ctype='unsigned char',     label='Alliance'},                              -- 04   02 for alliance, 00 for party
}

-- Party invite response
fields.outgoing[0x074] = L{
    {ctype='bool',              label='Join',               fn=bool},           -- 04
}

-- Party change leader
fields.outgoing[0x077] = L{
    {ctype='char[16]',          label='Target Name'},                           -- 04   Name of the person to give leader to
    {ctype='unsigned short',    label='Alliance'},                              -- 14   02 01 for alliance, 00 00 for party
    {ctype='unsigned short',    label='_unknown1'},                             -- 16
}

-- Synth
fields.outgoing[0x096] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04   Crystal ID? Earth = 0x02, Wind-break = 0x19?, Wind no-break = 0x2D?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05
    {ctype='unsigned short',    label='Crystal Item ID'},                       -- 06
    {ctype='unsigned char',     label='Crystal Inventory Index'},               -- 08
    {ctype='unsigned char',     label='Number of Ingredients'},                 -- 09
    {ctype='unsigned short',    label='Ingredient 1 ID'},                       -- 0A
    {ctype='unsigned short',    label='Ingredient 2 ID'},                       -- 0C
    {ctype='unsigned short',    label='Ingredient 3 ID'},                       -- 0E
    {ctype='unsigned short',    label='Ingredient 4 ID'},                       -- 10
    {ctype='unsigned short',    label='Ingredient 5 ID'},                       -- 12
    {ctype='unsigned short',    label='Ingredient 6 ID'},                       -- 14
    {ctype='unsigned short',    label='Ingredient 7 ID'},                       -- 16
    {ctype='unsigned short',    label='Ingredient 8 ID'},                       -- 18
    {ctype='unsigned char',     label='Ingredient 1 Index'},                    -- 1A
    {ctype='unsigned char',     label='Ingredient 2 Index'},                    -- 1B
    {ctype='unsigned char',     label='Ingredient 3 Index'},                    -- 1C
    {ctype='unsigned char',     label='Ingredient 4 Index'},                    -- 1D
    {ctype='unsigned char',     label='Ingredient 5 Index'},                    -- 1E
    {ctype='unsigned char',     label='Ingredient 6 Index'},                    -- 1F
    {ctype='unsigned char',     label='Ingredient 7 Index'},                    -- 20
    {ctype='unsigned char',     label='Ingredient 8 Index'},                    -- 21
    {ctype='unsigned short',    label='_unknown3'},                             -- 22
}

-- Speech
fields.outgoing[0x0B5] = L{
    {ctype='unsigned char',     label='Mode'},                                  -- 04   05 for LS chat?
    {ctype='unsigned char',     label='GM'},                                    -- 05   01 for GM
    {ctype='char[255]',         label='Message'},                               -- 06   Message, occasionally terminated by spare 00 bytes.
}

-- Tell
fields.outgoing[0x0B6] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 04   00 for a normal tell -- Varying this does nothing.
    {ctype='char[15]',          label='Target Name'},                           -- 05   Name of the person to send a tell to
    {ctype='char*',             label='Message'},                               -- 14   Message, occasionally terminated by spare 00 bytes.
}

-- Set LS Message
fields.outgoing[0x0E2] = L{
    {ctype='unsigned int',      label='_unknown1',          const=0x00000040},  -- 04
    {ctype='unsigned int',      label='_unknown2'},                             -- 08   Usually 0, but sometimes contains some junk
    {ctype='char[128]',         label='Message'}                                -- 0C
}

-- Logout
fields.outgoing[0x0E7] = L{
    {ctype='unsigned char',      label='_unknown1'},                            -- 04 -- Observed to be 00
    {ctype='unsigned char',      label='_unknown2'},                            -- 05 -- Observed to be 00
    {ctype='unsigned char',      label='Logout Type'},                          -- 06 -- /logout = 01, /pol == 02 (removed), /shutdown = 03
    {ctype='unsigned char',      label='_unknown3'},                            -- 07 -- Observed to be 00
}

-- Sit
fields.outgoing[0x0EA] = L{
    {ctype='unsigned char',     label='Movement'},                              -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned char',     label='_unknown2'},                             -- 06
    {ctype='unsigned char',     label='_unknown3'},                             -- 07
}

-- Cancel
fields.outgoing[0x0F1] = L{
    {ctype='unsigned char',     label='Buff ID'},                               -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned char',     label='_unknown2'},                             -- 06
    {ctype='unsigned char',     label='_unknown3'},                             -- 07
}

-- Widescan
fields.outgoing[0x0F4] = L{
    {ctype='unsigned char',     label='Flags'},                                 -- 04   1 when requesting widescan information. No other values observed.
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
}

-- Widescan Track
fields.outgoing[0x0F5] = L{
    {ctype='unsigned short',    label='Index',                  fn=index},      -- 04 Setting an index of 0 stops tracking
}

-- Job Change
fields.outgoing[0x100] = L{
    {ctype='unsigned char',     label='Main Job ID'},                           -- 04
    {ctype='unsigned char',     label='Sub Job ID'},                            -- 05
    {ctype='unsigned char',     label='_unknown1'},                             -- 06
    {ctype='unsigned char',     label='_unknown2'},                             -- 07
}

-- Untraditional Equip
-- Currently only commented for changing instincts in Monstrosity. Refer to the doku wiki for information on Autos/BLUs.
-- http://dev.windower.net/doku.php?id=packets:outgoing:0x102_blue_magic_pup_attachment_equip
fields.outgoing[0x102] = L{
    {ctype='unsigned short',    label='_unknown1'},                             -- 04  -- 00 00 for Monsters
    {ctype='unsigned short',    label='_unknown1'},                             -- 06  -- Varies by Monster family for the species change packet. Monsters that share the same tnl seem to have the same value. 00 00 for instinct changing.
    {ctype='unsigned char',     label='Main Job ID'},                           -- 08  -- 00x17 for Monsters
    {ctype='unsigned char',     label='Sub Job ID'},                            -- 09  -- 00x00 for Monsters
    {ctype='unsigned short',    label='Flag'},                                  -- 0A  -- 04 00 for Monsters changing instincts. 01 00 for changing Monsters
    {ctype='unsigned short',    label='Species ID'},                            -- 0C  -- True both for species change and instinct change packets
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E  -- 00 00 for Monsters
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
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='char[38]',          label='_unknown1'},                             -- 0A
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           -- 30
    {ctype='char[6]',           label='_unknown2'},                             -- 32
    {ctype='unsigned int',      label='Timestamp 1',        fn=time},           -- 38
    {ctype='unsigned int',      label='Timestamp 2',        fn=time},           -- 3C
    {ctype='unsigned short',    label='Zone ID MH',         fn=zone},           -- 40   Zone ID when zoning out of MH, otherwise 0
    {ctype='unsigned short',    label='_dupe_Zone ID',      fn=zone},           -- 42
    {ctype='unsigned char',     label='Race'},                                  -- 44
    {ctype='unsigned char',     label='Face'},                                  -- 45
    {ctype='unsigned short',    label='Head'},                                  -- 46
    {ctype='unsigned short',    label='Body'},                                  -- 48
    {ctype='unsigned short',    label='Hands'},                                 -- 4A
    {ctype='unsigned short',    label='Legs'},                                  -- 4C
    {ctype='unsigned short',    label='Feet'},                                  -- 4E
    {ctype='unsigned short',    label='Main'},                                  -- 50
    {ctype='unsigned short',    label='Sub'},                                   -- 52
    {ctype='unsigned short',    label='Ranged'},                                -- 54
    {ctype='char[18]',          label='_unknown3'},                             -- 56
    {ctype='unsigned short',    label='Weather ID',         fn=weather},        -- 68
    {ctype='unsigned short',    label='_unknown4',          fn=weather},        -- 6A
    {ctype='char[24]',          label='_unknown5'},                             -- 6C
    {ctype='char[16]',          label='Player Name'},                           -- 84
    {ctype='char[12]',          label='_unknown6'},                             -- 94
    {ctype='unsigned int',      label='Abyssea Timestamp',  fn=time},           -- A0
    {ctype='char[16]',          label='_unknown7'},                             -- A4   0xAC is 2 for some zones, 0 for others
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- B4
    {ctype='unsigned char',     label='_unknown7'},                             -- B5
    {ctype='unsigned char',     label='_unknown8'},                             -- B6
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- B7
    {ctype='unsigned int',      label='_unknown9'},                             -- B8
    {ctype='unsigned char',     label='(None) Level'},                          -- BC
    {ctype='unsigned char',     label='WAR Level'},                             -- BD
    {ctype='unsigned char',     label='MNK Level'},                             -- BE
    {ctype='unsigned char',     label='WHM Level'},                             -- BF
    {ctype='unsigned char',     label='BLM Level'},                             -- C0
    {ctype='unsigned char',     label='RDM Level'},                             -- C1
    {ctype='unsigned char',     label='THF Level'},                             -- C2
    {ctype='unsigned char',     label='PLD Level'},                             -- C3
    {ctype='unsigned char',     label='DRK Level'},                             -- C4
    {ctype='unsigned char',     label='BST Level'},                             -- C5
    {ctype='unsigned char',     label='BRD Level'},                             -- C6
    {ctype='unsigned char',     label='RNG Level'},                             -- C7
    {ctype='unsigned char',     label='SAM Level'},                             -- C8
    {ctype='unsigned char',     label='NIN Level'},                             -- C9
    {ctype='unsigned char',     label='DRG Level'},                             -- CA
    {ctype='unsigned char',     label='SMN Level'},                             -- CB
    {ctype='signed short',      label='STR'},                                   -- CC
    {ctype='signed short',      label='DEX'},                                   -- CE
    {ctype='signed short',      label='VIT'},                                   -- D0
    {ctype='signed short',      label='AGI'},                                   -- D2
    {ctype='signed short',      label='IND'},                                   -- F4
    {ctype='signed short',      label='MND'},                                   -- D6
    {ctype='signed short',      label='CHR'},                                   -- D8
    {ctype='signed short',      label='STR Bonus'},                             -- DA
    {ctype='signed short',      label='DEX Bonus'},                             -- DC
    {ctype='signed short',      label='VIT Bonus'},                             -- DE
    {ctype='signed short',      label='AGI Bonus'},                             -- E0
    {ctype='signed short',      label='INT Bonus'},                             -- E2
    {ctype='signed short',      label='MND Bonus'},                             -- E4
    {ctype='signed short',      label='CHR Bonus'},                             -- E6
    {ctype='unsigned int',      label='Max HP'},                                -- E8
    {ctype='unsigned int',      label='Max MP'},                                -- EC
    {ctype='char[20]',          label='_unknown10'},                            -- F0
}

-- Zone Response
fields.incoming[0x00B] = L{
    {ctype='unsigned int',      label='Type'},                                  -- 04 Logout: 1, Teleport/Warp: 2, Regular zone: 3
    {ctype='unsigned int',      label='IP',                 fn=ip},             -- 08
    {ctype='unsigned short',    label='Port'},                                  -- 0C
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
	-- 01 = None
	-- 02 = Deletes everyone
	-- 04 = Deletes everyone
	-- 08 = None
	-- 16 = None
	-- 32 = None
	-- 64 = None
	-- 128 = None
	
	
	-- Byte 33:
	-- 01 = None
	-- 02 = None
	-- 04 = None
	-- 08 = LFG
	-- 16 = Anon
	-- 32 = Turns your name orange
	-- 64 = Away
	-- 128 = None
	
	-- Byte 34:
	-- 01 = POL Icon, can target?
	-- 02 = no notable effect
	-- 04 = DCing
	-- 08 = Untargettable
	-- 16 = No linkshell
	-- 32 = No Linkshell again
	-- 64 = No linkshell again
	-- 128 = No linkshell again
	
	-- Byte 35:
	-- 01 = Trial Account
	-- 02 = Trial Account
	-- 04 = GM Mode
	-- 08 = None
	-- 16 = None
	-- 32 = Invisible models
	-- 64 = None
	-- 128 = Bazaar
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='Mask',               fn=bin-{1}},        -- 0A
    {ctype='unsigned char',     label='Body Rotation',      fn=dir},            -- 0B
    {ctype='float',             label='X Position'},                            -- 0C
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
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='Mask',               fn=bin-{1}},        -- 0A   Mask with bit 4 set updates NPC status
    {ctype='unsigned char',     label='Rotation',           fn=dir},            -- 0B
    {ctype='float',             label='X Position'},                            -- 0C
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
    {ctype='unsigned char',     label='Mode'},                                  -- 04   Chat mode.
    {ctype='bool',              label='GM'},                                    -- 05   1 for GM or 0 for not
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           -- 06   Zone ID, used for Yell
    {ctype='char[16]',          label='Sender Name'},                           -- 08   Name
    {ctype='char*',             label='Message'},                               -- 17   Message, occasionally terminated by spare 00 bytes. Max of 150 characters.
}

-- Job Info
fields.incoming[0x01B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Observed value of 05
    {ctype='unsigned char',     label='Main Job ID'},                           -- 08
    {ctype='unsigned char',     label='Flag or Main Job Level?'},               -- 09
    {ctype='unsigned char',     label='Flag or Sub Job Level?'},                -- 0A
    {ctype='unsigned char',     label='Sub Job ID'},                            -- 0B
    {ctype='unsigned int',      label='_unknown2'},                             -- 0C   Flags -- FF FF FF 00 observed
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
    {ctype='unsigned int',      label='_unknown1',          const=0x00000001},  -- 04
    {ctype='unsigned short',    label='Item ID',            fn=item},           -- 08
    {ctype='unsigned char',     label='_padding1',          const=0x00},        -- 0A
    {ctype='unsigned char',     label='Inventory ID'},                          -- 0B
    {ctype='unsigned char',     label='Inventory Status'},                      -- 0C
    {ctype='char[3]',           label='_junk1'},                                -- 0D
}

-- Count to 80
fields.incoming[0x026] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 04
    {ctype='unsigned char',     label='Counter'},                               -- 05   Varies sequentially between 0x01 and 0x50
    {ctype='char[22]',          label='_unknown2',          const=0},           -- 06
}

-- Encumbrance Release
fields.incoming[0x027] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Player index',       fn=index},          -- 08
    {ctype='unsigned char',     label='Slot or Stat ID'},                       -- 0A  -- 85 = DEX Down, 87 = AGI Down, 8A = CHR Down, 8B = HP Down, 7A = Head/Neck restriction, 7D = Leg/Foot Restriction
    {ctype='unsigned char',     label='_unknown1'},                             -- 0B  -- 09C
    {ctype='unsigned int',      label='_unknown2'},                             -- 0C  -- 04 00 00 00
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
    {ctype='unsigned int',      label='Actor ID',           fn=id},             -- 04
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 08
    {ctype='unsigned int',      label='param_1'},                               -- 0C
    {ctype='unsigned char',     label='param_2'},                               -- 10  -- 06 bits of byte 16
    {ctype='char[3]',           label='param_3'},                               -- 11  -- Also includes the last 2 bits of byte 16.
    {ctype='unsigned short',    label='Actor Index',        fn=index},          -- 14  -- B6 E3 39 00
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16  -- 01 or 04?
    {ctype='unsigned short',    label='Message ID'},                            -- 18
    {ctype='unsigned short',    label='_unknown1'},                             -- 1A
}

-- Item Assign
fields.incoming[0x02A] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned int',      label='Param 1'},                               -- 08
    {ctype='unsigned int',      label='Param 2'},                               -- 0C
    {ctype='unsigned int',      label='Param 3'},                               -- 10
    {ctype='unsigned int',      label='Param 4'},                               -- 14
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 18
    {ctype='unsigned short',    label='Message ID'},                            -- 1A   The high bit is occasionally set, though the reason for it is unclear.
    {ctype='unsigned int',      label='_unknown1',          const=0x06000000},  -- 1C
}

-- Synth Animation
fields.incoming[0x030] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned short',    label='Effect'},                                -- 0A  -- 10 00 is water, 11 00 is wind, 12 00 is fire, 13 00 is earth, 14 00 is lightning, 15 00 is ice, 16 00 is light, 17 00 is dark
    {ctype='unsigned char',     label='Param'},                                 -- 0C  -- 00 is NQ, 01 is break, 02 is HQ
    {ctype='unsigned char',     label='Animation'},                             -- 0D  -- Always C2 for me.
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 0E  -- Appears to just be trash.
}

-- Shop
fields.incoming[0x03C] = L{
    {ctype='unsigned short',    label='_zero1',             const=0x0000},      -- 04
    {ctype='unsigned short',    label='_padding1'},                             -- 06
    {ref=types.shop_item,       label='Item',               count='*'},         -- 08 -   *
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

    {ctype='unsigned char',     label='Job ID'},                                -- 04
    {ctype='bool',              label='Subjob Flag'},                           -- 05
    {ctype='unsigned char',     label='_unknown'},                              -- 06
    {ctype='unsigned char',     label='_unknown'},                              -- 07
    {ctype='unsigned char',     label='Automaton Head'},                        -- 08   Harlequinn 1, Valoredge 2, Sharpshot 3, Stormwaker 4, Soulsoother 5, Spiritreaver 6
    {ctype='unsigned char',     label='Automaton Frame'},                       -- 09   Harlequinn 20, Valoredge 21, Sharpshot 22, Stormwaker 23
    {ctype='unsigned char',     label='Slot 1'},                                -- 0A   Attachment assignments are based off their position in the equipment list.
    {ctype='unsigned char',     label='Slot 2'},                                -- 0B   Strobe is 01, etc.
    {ctype='unsigned char',     label='Slot 3'},                                -- 0C
    {ctype='unsigned char',     label='Slot 4'},                                -- 0D
    {ctype='unsigned char',     label='Slot 5'},                                -- 0E
    {ctype='unsigned char',     label='Slot 6'},                                -- 0F
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
    {ctype='unsigned char',     label='Packet Type'},                           -- 04

	-- 00x01: (Length is 88 bytes)
	-- Seems to occur when refreshing the d-box after any change (or before changes).
    {ctype='unsigned char',     label='_unknown2'},                             -- 05
    {ctype='unsigned char',     label='Delivery Slot ID'},                      -- 06   This goes left to right and then drops down a row and left to right again. Value is 0 to 7.
    {ctype='char[5]',           label='_unknown3'},                             -- 07   All FF values observed
    {ctype='unsigned char',     label='_unknown4'},                             -- 0C   01 observed
    {ctype='unsigned char',     label='_unknown5'},                             -- 0D   02 observed
    {ctype='unsigned short',    label='_unknown6'},                             -- 0E   FF FF observed
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
	
	-- 00x02: (Length is 88 bytes)
	-- Seems to occur when placing items into the d-box.
	
	-- 00x03: (Length is 88 bytes)
	-- Two occur per item that is actually sent (hitting okay to send).
	
	-- 00x04: (Length is 88 bytes)
	-- Two occur per sent item that is Canceled.
	
	-- 00x05 (Length is 20 bytes)
	-- Seems to occur quasi-randomly. Can be seen following spells.
    {ctype='unsigned char',     label='_unknown2'},                             -- 05
    {ctype='char[6]',           label='_unknown3'},                             -- 06   All FF values observed
    {ctype='unsigned char',     label='_unknown4'},                             -- 0C   01 and 02 observed
    {ctype='unsigned char',     label='_unknown5'},                             -- 0D   FF observed
    {ctype='unsigned char',     label='_unknown6'},                             -- 0E   00 and FF observed
    {ctype='unsigned char',     label='_unknown7'},                             -- 0F   FF observed
    {ctype='unsigned int',      label='_unknown8'},                             -- 10   00 00 00 00 observed
	
	-- 00x06: (Length is 88 bytes)
	-- Occurs for new items.
	-- Two of these are sent sequentially. The first one doesn't seem to contain much/any
	-- information and the second one is very similar to a type 0x01 packet
	-- First packet's frst line:   4B 58 xx xx 06 01 00 01 FF FF FF FF 02 02 FF FF
	-- Second packet's first line: 4B 58 xx xx 06 01 00 FF FF FF FF FF 01 02 FF FF
    {ctype='unsigned char',     label='_unknown2'},                             -- 05   01 Observed
    {ctype='unsigned char',     label='Delivery Slot ID'},                      -- 06
    {ctype='char[5]',           label='_unknown3'},                             -- 07   01 FF FF FF FF and FF FF FF FF FF observed
    {ctype='unsigned char',     label='_unknown4'},                             -- 0C   01 observed
    {ctype='unsigned char',     label='Packet Number'},                         -- 0D   02 and 03 observed
    {ctype='unsigned short',    label='_unknown6'},                             -- 0E   FF FF observed
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

	-- 00x07: Length is 20 or 88 bytes
	-- Sent when something is being removed from the outbox. 20 byte packet is followed by an 88 byte packet for each item removed.
	
	-- 00x08: (Length is 88 bytes)
	-- Occur as the first packet when removing or dropping something from the d-box.
	
	-- 00x09: (Length is 88 bytes)
	-- Occur when someone returns something from the d-box.
	
	-- 00x0A: (Length is 88 bytes)
	-- Occurs as the second packet when removing something from the d-box or outbox.
	
	-- 00x0B: (Length is 88 bytes)
	-- Occurs as the second packet when dropping something from the d-box.
	
	-- 00x0C: (Length is 20 bytes)
	-- Sent after entering a name and hitting "OK" in the outbox.
	
	-- 00x0F: (Length is 20 bytes)
	-- One is sent after closing the d-box or outbox.
}

-- Data Download 2
fields.incoming[0x04F] = L{
--   This packet's contents are nonessential. They are often leftovers from other outgoing
--   packets. It is common to see things like inventory size, equipment information, and
--   character ID in this packet. They do not appear to be meaningful and the client functions 
--   normally even if they are blocked.
    {ctype='unsigned int',     label='_unknown1'},                              -- 04
}

-- Equip
fields.incoming[0x050] = L{
    {ctype='unsigned char',     label='Item Index',         fn=inv+{0}},        -- 04
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           -- 05
}

-- Model Change
fields.incoming[0x051] = L{
    {ctype='unsigned char',     label='Face'},                                  -- 04
    {ctype='unsigned char',     label='Race'},                                  -- 05
    {ctype='unsigned short',    label='Head'},                                  -- 06
    {ctype='unsigned short',    label='Body'},                                  -- 08
    {ctype='unsigned short',    label='Hands'},                                 -- 0A
    {ctype='unsigned short',    label='Legs'},                                  -- 0C
    {ctype='unsigned short',    label='Feet'},                                  -- 0E
    {ctype='unsigned short',    label='Main'},                                  -- 10
    {ctype='unsigned short',    label='Sub'},                                   -- 12
    {ctype='unsigned short',    label='Ranged'},                                -- 14
    {ctype='unsigned short',    label='_unknown1'},                             -- 16   May varying meaningfully, but it's unclear
}

-- Logout Time - This packet is likely used for an entire class of system messages,
-- but the only one commonly encountered is the logout counter.
fields.incoming[0x053] = L{
    {ctype='unsigned int',      label='param'},                                 -- 04   Parameter
    {ctype='unsigned int',      label='_unknown1'},                             -- 08   00 00 00 00 observed
    {ctype='unsigned short',    label='Message ID'},                            -- 0C   It is unclear which dialogue table this corresponds to
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E   Probably junk.
}

-- Key Item Log
--[[fields.incoming[0x055] = L{
	-- There are 6 of these packets sent on zone, which likely corresponds to the 6 categories of key items.
	-- FFing these packets between bytes 0x14 and 0x82 gives you access to all (or almost all) key items.
}]]

-- Weather Change
fields.incoming[0x057] = L{
    {ctype='unsigned int',      label='Vanadiel Time',      fn=vtime},          -- 04   Units of minutes.
    {ctype='unsigned char',     label='Weather ID',         fn=weather},        -- 08
    {ctype='unsigned char',     label='_unknown1'},                             -- 09
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A
}

-- NPC Spawn
fields.incoming[0x05B] = L{
    {ctype='float',             label='X Position'},                            -- 04
    {ctype='float',             label='Z Position'},                            -- 08
    {ctype='float',             label='Y Position'},                            -- 0C
    {ctype='unsigned int',      label='Mob ID',             fn=id},             -- 10
    {ctype='unsigned short',    label='Mob Index',          fn=index},          -- 14
    {ctype='unsigned char',     label='Type'},                                  -- 16   3 for regular Monsters, 0 for Treasure Caskets and NPCs
    {ctype='unsigned char',     label='_unknown1'},                             -- 17   Always 0 if Type is 3, otherwise a seemingly random non-zero number
    {ctype='unsigned int',      label='_unknown2'},                             -- 18
}

-- Char Stats
fields.incoming[0x061] = L{
    {ctype='unsigned int',      label='Maximum HP'},                            -- 04
    {ctype='unsigned int',      label='Maximum MP'},                            -- 08
    {ctype='unsigned char',     label='Main Job ID',        fn=job},            -- 0C
    {ctype='unsigned char',     label='Main Job Level'},                        -- 0D
    {ctype='unsigned char',     label='Sub Job ID',         fn=job},            -- 0E
    {ctype='unsigned char',     label='Sub Job Level'},                         -- 0F
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
    {ctype='char[126]',         label='_unknown1'},                             -- 04
    {ctype='unsigned short',    label='Hand-to-Hand',       fn=cskill},         -- 82
    {ctype='unsigned short',    label='Dagger',             fn=cskill},         -- 84
    {ctype='unsigned short',    label='Sword',              fn=cskill},         -- 86
    {ctype='unsigned short',    label='Great Sword',        fn=cskill},         -- 88
    {ctype='unsigned short',    label='Axe',                fn=cskill},         -- 8A
    {ctype='unsigned short',    label='Great Axe',          fn=cskill},         -- 8C
    {ctype='unsigned short',    label='Scythe',             fn=cskill},         -- 8E
    {ctype='unsigned short',    label='Polearm',            fn=cskill},         -- 90
    {ctype='unsigned short',    label='Katana',             fn=cskill},         -- 92
    {ctype='unsigned short',    label='Great Katana',       fn=cskill},         -- 94
    {ctype='unsigned short',    label='Club',               fn=cskill},         -- 96
    {ctype='unsigned short',    label='Staff',              fn=cskill},         -- 98
    {ctype='char[24]',          label='_dummy1'},                               -- 9A
    {ctype='unsigned short',    label='Archery',            fn=cskill},         -- B2
    {ctype='unsigned short',    label='Marksmanship',       fn=cskill},         -- B4
    {ctype='unsigned short',    label='Throwing',           fn=cskill},         -- B6
    {ctype='unsigned short',    label='Guarding',           fn=cskill},         -- B8
    {ctype='unsigned short',    label='Evasion',            fn=cskill},         -- BA
    {ctype='unsigned short',    label='Shield',             fn=cskill},         -- BC
    {ctype='unsigned short',    label='Parrying',           fn=cskill},         -- BE
    {ctype='unsigned short',    label='DivineMagic',        fn=cskill},         -- C0
    {ctype='unsigned short',    label='HealingMagic',       fn=cskill},         -- C2
    {ctype='unsigned short',    label='EnhancingMagic',     fn=cskill},         -- C4
    {ctype='unsigned short',    label='EnfeeblingMagic',    fn=cskill},         -- C6
    {ctype='unsigned short',    label='ElementalMagic',     fn=cskill},         -- C8
    {ctype='unsigned short',    label='DarkMagic',          fn=cskill},         -- CA
    {ctype='unsigned short',    label='SummoningMagic',     fn=cskill},         -- CC
    {ctype='unsigned short',    label='Ninjitsu',           fn=cskill},         -- CE
    {ctype='unsigned short',    label='Singing',            fn=cskill},         -- D0
    {ctype='unsigned short',    label='StringInstrument',   fn=cskill},         -- D2
    {ctype='unsigned short',    label='WindInstrument',     fn=cskill},         -- D4
    {ctype='unsigned short',    label='BlueMagic',          fn=cskill},         -- D6
    {ctype='char[8]',           label='_dummy2'},                               -- D8
    {ctype='unsigned short',    label='Fishing',            fn=sskill},         -- E0
    {ctype='unsigned short',    label='Woodworking',        fn=sskill},         -- E2
    {ctype='unsigned short',    label='Smithing',           fn=sskill},         -- E4
    {ctype='unsigned short',    label='Goldsmithing',       fn=sskill},         -- E6
    {ctype='unsigned short',    label='Clothcraft',         fn=sskill},         -- E8
    {ctype='unsigned short',    label='Leathercraft',       fn=sskill},         -- EA
    {ctype='unsigned short',    label='Bonecraft',          fn=sskill},         -- EC
    {ctype='unsigned short',    label='Alchemy',            fn=sskill},         -- EE
    {ctype='unsigned short',    label='Cooking',            fn=sskill},         -- F0
    {ctype='unsigned short',    label='Synergy',            fn=sskill},         -- F2
    {ctype='char*',             label='_padding',           const=0xFF},        -- F4
}

-- Unnamed 0x067
fields.incoming[0x067] = L{
-- The length of this packet is 24, 28, 36 or 40 bytes. The latter two seem to feature a 16 char
-- name field. 24/28 appears to be for NPCs/monsters. When summoning pets, their name appear in 
-- the 16 byte name field. 40 Appears to be for players, although it's 36 when summoning a pet.
-- _unknown1 is 02 09 for players and 03 05 for NPCs, unless players summon a pet, then it's
-- 44 07. The use of this packet is unclear.
    {ctype='unsigned short',    label='_unknown1'},                             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 06
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 08
    {ctype='unsigned short',    label='Other Index',        fn=index},          -- 0C
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E
    {ctype='unsigned int',      label='_unknown3'},                             -- 10   Always 0?
    {ctype='char*',             label='Other Name'},                            -- 14
}

-- LS Message
fields.incoming[0x0CC] = L{
    {ctype='int',               label='_unknown1'},                             -- 04
    {ctype='char[128]',         label='Message'},                               -- 08
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 88
    {ctype='char[16]',          label='Player Name'},                           -- 8C
    {ctype='unsigned int',      label='Permissions'},                           -- 98
    {ctype='char[16]',          label='Linkshell Name',     enc=ls_name_msg},   -- 9C   6-bit packed
}

-- Bazaar Message
fields.incoming[0x0CA] = L{
    {ctype='int',               label='_unknown1'},                             -- 04   Could be characters starting the line - FD 02 02 18 observed
    {ctype='unsigned short',    label='_unknown2'},                             -- 08   Could also be characters starting the line - 01 FD observed
    {ctype='char[118]',         label='Bazaar Message'},                        -- 0A   Terminated with a vertical tab
    {ctype='char[16]',          label='Player Name'},                           -- 80
    {ctype='unsigned short',    label='_unknown3'},                             -- 90   C6 01 observed. Not player index.
    {ctype='unsigned short',    label='_unknown4'},                             -- 92   00 00 observed.
}

-- Found Item
fields.incoming[0x0D2] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Could be characters starting the line - FD 02 02 18 observed
                                                                                -- 04   Arcon: Only ever observed 0x00000001 for this
    {ctype='unsigned int',      label='Dropper ID',         fn=id},             -- 08
    {ctype='unsigned int',      label='Quantity'},                              -- 0C   Takes values greater than 1 in the case of gil
    {ctype='unsigned short',    label='Item ID',            fn=item},           -- 10
    {ctype='unsigned short',    label='Dropper Index',      fn=index},          -- 12
    {ctype='unsigned short',    label='Pool Index'},                            -- 14   This is the internal index in memory, not the one it appears in in the menu
    {ctype='unsigned short',    label='_unknown4'},                             -- 16   First byte seems to always be 00, second seemingly random, both 00 and FF observed
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 18
    {ctype='char[28]',          label='_unknown6'},                             -- AC   Always 0 it seems?
    {ctype='unsigned int',      label='_junk1'},                                -- 38
}

-- Item lot/drop
fields.incoming[0x0D3] = L{
    {ctype='unsigned int',      label='Highest Lot ID',     fn=id},             -- 04
    {ctype='unsigned int',      label='Current Lot ID',     fn=id},             -- 08
    {ctype='unsigned short',    label='Highest Lot Index',  fn=index},          -- 0C
    {ctype='unsigned short',    label='Highest Lot'},                           -- 0E
    {ctype='unsigned short',    label='Current Lot Index',  fn=index..s-{1,15}},-- 10   The highest bit is set
    {ctype='unsigned short',    label='Current Lot'},                           -- 12
    {ctype='unsigned char',     label='_unknown1'},                             -- 14
    {ctype='unsigned char',     label='Drop'},                                  -- 15   1 if the item dropped, 0 otherwise
    {ctype='char[16]',          label='Highest Lot Name'},                      -- 16
    {ctype='char[16]',          label='Current Lot Name'},                      -- 26
    {ctype='char[6]',           label='_junk1'},                                -- 36
}

-- Char Update
fields.incoming[0x0DF] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0C
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10   Truncated, does not include the decimal value.
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 14
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 16
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 17
    {ctype='unsigned short',    label='_unknown1'},                             -- 18
    {ctype='unsigned short',    label='_unknown2'},                             -- 1A
}

-- Char Info
fields.incoming[0x0E2] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0A
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
    {ctype='unsigned char',     label='Movement'},                              -- 04   02 if caused by movement
    {ctype='unsigned char',     label='_unknown2'},                             -- 05   00 observed
    {ctype='unsigned char',     label='_unknown3'},                             -- 06   00 observed
    {ctype='unsigned char',     label='_unknown4'},                             -- 07   00 observed
}

-- Widescan Mob
fields.incoming[0x0F4] = L{
    {ctype='unsigned short',    label='Index',              fn=index},          -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 06
    {ctype='unsigned char',     label='Type'},                                  -- 07   1 = NPC (green), 2 = Enemy (red), 0 = Other (blue)
    {ctype='short',             label='X Offset'},                              -- 08   Offset on the map
    {ctype='short',             label='Y Offset'},                              -- 0A
    {ctype='char[16]',          label='Name'},                                  -- 0C   Slugged, may not extend all the way to 27. Up to 25 has been observed. This will be used if Type == 0
}

-- Widescan Track
fields.incoming[0x0F5] = L{
    {ctype='float',             label='X Position'},                            -- 04
    {ctype='float',             label='Z Position'},                            -- 08
    {ctype='float',             label='Y Position'},                            -- 0C
    {ctype='unsigned char',     label='_unknown1'},                             -- 10 Same value as _unknown1 of 0x0F4
    {ctype='unsigned char',     label='_padding1'},                             -- 11
    {ctype='unsigned short',    label='Index',              fn=index},          -- 12
    {ctype='unsigned int',      label='Status'},                                -- 14 1 for regular data, 2 when zoning (resets tracker), 3 when resetting (new wide scan)
}

-- Widescan Mark
fields.incoming[0x0F6] = L{
    {ctype='unsigned int',      label='Type'},                                  -- 04   1 for the start of a widescan list. 2 for the end of the list.
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='_unknown1'},                             -- 0A
    {ctype='unsigned char',     label='_unknown2'},                             -- 0B
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
