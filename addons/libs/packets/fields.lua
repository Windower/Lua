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
local ls_name_msg = T('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ':split())
ls_name_msg[0] = 0:char()
local item_inscr = T('0123456798ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{':split())
item_inscr[0] = 0:char()
local ls_name_ext = T(('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' .. 0:char():rep(11)):split())
ls_name_ext[0] = '`'

-- Function definitions. Used to display packet field information.
res = require('resources')

local function s(val, from, to)
    from = from - 1
    to = to
    return bit.band(bit.rshift(val, from), 2^(to - from) - 1)
end

local function id(val)
    local mob = windower.ffxi.get_mob_by_id(val)
    return mob and mob.name or '-'
end

local function index(val)
    local mob = windower.ffxi.get_mob_by_index(val)
    return mob and mob.name or '-'
end

local function ip(val)
    return '%d.%d.%d.%d':format('I':pack(val):unpack('CCCC'))
end

local function gil(val)
    return tostring(val):reverse():chunks(3):concat(','):reverse() .. ' G'
end

local function bool(val)
    return val ~= 0
end

local function div(denom, val)
    return val/denom
end

local time = function()
    local now = os.time()
    local h, m = (os.difftime(now, os.time(os.date('!*t', now))) / 3600):modf()

    local timezone = '%+.2d:%.2d':format(h, 60 * m)
    now, h, m = nil, nil, nil
    return function(ts)
        return os.date('%Y-%m-%dT%H:%M:%S' .. timezone, os.time() - ts)
    end
end()

local utime = function()
    local now = os.time()
    local h, m = (os.difftime(now, os.time(os.date('!*t', now))) / 3600):modf()

    local timezone = '%+.2d:%.2d':format(h, 60 * m)
    now, h, m = nil, nil, nil
    return function(ts)
        return os.date('%Y-%m-%dT%H:%M:%S' .. timezone, ts)
    end
end()

local time_ms = time .. function(val) return val/1000 end

local dir = function()
    local dir_sets = L{'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW', 'N', 'NNE', 'NE', 'ENE', 'E'}
    return function(val)
        return dir_sets[((val + 8)/16):floor() + 1]
    end
end()

local function cap(max, val)
    return '%.1f':format(100*val/max)..'%'
end

local function zone(val)
    return res.zones[val] and res.zones[val].name or '- (Unknown zone ID: %d)':format(val)
end

local function item(val)
    return val ~= 0 and res.items[val]
            and res.items[val].name
        or '-'
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
    return '/' .. res.emotes[val].command
end

local function bag(val)
    return res.bags[val].name
end

local function race(val)
    return res.races[val].name
end

local function slot(val)
    return res.slots[val].name
end

local function srank(val)
    return res.synth_ranks[val].name
end

local function inv(bag, val)
    if val == 0 or not res.bags[bag] then
        return '-'
    end

    local items = windower.ffxi.get_items()[res.bags[bag].english:lower()]
    if not items[val] then
        return '-'
    end

    return item(items[val].id)
end

local function invp(index, val, data)
    return inv(data[index + 1]:byte(), val)
end

local function hex(fill, val)
    return val:hex():zfill(2*fill):chunks(2):reverse():concat(' ')
end

local function bin(fill, val)
    return val:binary():zfill(8*fill):chunks(8):reverse():concat(' ')
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

local enums = {
    ['synth'] = {
        [0] = 'Success',
        [1] = 'Fail',
        [2] = 'Fail, interrupted',
        [3] = 'Cancel, invalid recipe',
        [4] = 'Cancel',
        [5] = 'Fail, crystal lost',
        [6] = 'Cancel, skill too low',
        [7] = 'Cancel, rare',
    },
    ['logout'] = {
        [1] = '/loguot',
        [2] = '/pol',
        [3] = '/shutdown',
    },
    ['zone'] = {
        [1] = 'Logout',
        [2] = 'Teleport',
        [3] = 'Zone line',
    },
    [0x038] = {
        deru = 'Appear',
        kesu = 'Disappear',
    },
    ['itemstat'] = {
        [0x00] = 'None',
        [0x05] = 'Equipped',
        [0x13] = 'Active linkshell',
        [0x19] = 'Bazaaring',
    },
    ['ws track'] = {
        [1] = 'Update',
        [2] = 'Reset (zone)',
        [3] = 'Reset (new scan)',
    },
    ['ws mob'] = {
        [0] = 'Other',
        [1] = 'Friendly',
        [2] = 'Enemy',
    },
    ['ws mark'] = {
        [1] = 'Start',
        [2] = 'End',
    },
    ['bazaar'] = {
        [0] = 'Open',
        [1] = 'Close',
    },
    ['try'] = {
        [0] = 'Succeeded',
        [1] = 'Failed',
    },
}

local function e(t, val)
    return enums[t][val] or 'Unknown value for \'%s\': %i':format(t, val)
end

--[[
    Outgoing packets
]]

-- Zone In 1
-- Likely triggers specific incoming packets.
-- Does not trigger any packets when randomly injected.
fields.outgoing[0x00C] = L{
    {ctype='int',               label='_unknown1'},                             -- 04   Always 00s?
    {ctype='int',               label='_unknown2'},                             -- 04   Always 00s?
}

-- Client Leave
-- Last packet sent when zoning. Disconnects from the zone server.
fields.outgoing[0x00D] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04   Always 00?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05   Always 00?
    {ctype='unsigned char',     label='_unknown3'},                             -- 06   Always 00?
    {ctype='unsigned char',     label='_unknown4'},                             -- 07   Always 00?
}

-- Zone In 2
-- Likely triggers specific incoming packets.
-- Does not trigger any packets when randomly injected.
fields.outgoing[0x00F] = L{
    {ctype='char[32]',          label='_unknown1'},                             -- 04   Always 00s?
}

-- Zone In 3
-- Likely triggers specific incoming packets.
-- Does not trigger any packets when randomly injected.
fields.outgoing[0x011] = L{
    {ctype='int',               label='_unknown1'},                             -- 04   Always 02 00 00 00?
}

-- Standard Client
fields.outgoing[0x015] = L{
    {ctype='float',             label='X Position'},                            -- 04
    {ctype='float',             label='Y Position'},                            -- 08
    {ctype='float',             label='Z Position'},                            -- 0C
    {ctype='unsigned short',    label='_junk1'},                                -- 10
    {ctype='unsigned short',    label='Run Count'},                             -- 12   Counter that indicates how long you've been running?
    {ctype='unsigned char',     label='Rotation',           fn=dir},            -- 14
    {ctype='unsigned char',     label='_unknown2'},                             -- 15
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16
    {ctype='unsigned int',      label='Timestamp',          fn=time_ms},        -- 18   Milliseconds
    {ctype='unsigned int',      label='_unknown3'},                             -- 1A
}

-- Update Request
fields.outgoing[0x016] = L{
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 04
    {ctype='unsigned short',    label='_junk1'},                                -- 06
}

enums['action'] = {
    [0x00] = 'NPC Interaction',
    [0x02] = 'Engage monster',
    [0x03] = 'Magic cast',
    [0x04] = 'Disengage',
    [0x05] = 'Call for Help',
    [0x07] = 'Weaponskill usage',
    [0x09] = 'Job ability usage',
    [0x0C] = 'Assist',
    [0x0D] = 'Reraise dialogue',
    [0x0F] = 'Switch target',
    [0x10] = 'Ranged attack',
    [0x14] = 'Zoning/Appear', -- I think, the resource for this is ambiguous.
    [0x19] = 'Monsterskill',
}

-- Action
fields.outgoing[0x01A] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='Category',           fn=e+{'action'}},   -- 0A
    {ctype='unsigned short',    label='Param'},                                 -- 0C
    {ctype='unsigned short',    label='_unknown1'},                             -- 0E
}

-- Drop Item
fields.outgoing[0x028] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 08
    {ctype='unsigned char',     label='Inventory Index',    fn=invp+{0x08}},    -- 09
    {ctype='unsigned short',    label='_junk1'},                                -- 0A
}

-- Move Item
fields.outgoing[0x029] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 08
    {ctype='unsigned char',     label='Target Bag',         fn=bag},            -- 09
    {ctype='unsigned char',     label='Inventory Index',    fn=invp+{0x08}},    -- 0A
    {ctype='unsigned char',     label='_junk1'},                                -- 0B   Has taken the value 52. Unclear purpose.
}

-- Trade request
fields.outgoing[0x032] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='char[2]',           label='_junk1'}                                 -- 0A
}

enums[0x033] = {
    [0] = 'Accept trade',
    [1] = 'Cancel trade',
    [2] = 'Confirm trade',
}

-- Trade confirm
-- Sent when accepting, confirming or canceling a trade
fields.outgoing[0x033] = L{
    {ctype='unsigned int',      label='Type',               fn=e+{0x033}},      -- 04
    {ctype='char[4]',           label='_unknown1'}                              -- 08
}

-- Menu Item
fields.outgoing[0x036] = L{
-- Item order is Gil -> top row left-to-right -> bottom row left-to-right, but
-- they slide up and fill empty slots
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned int',      label='Item 1 Count'},                          -- 08
    {ctype='unsigned int',      label='Item 2 Count'},                          -- 0C
    {ctype='unsigned int',      label='Item 3 Count'},                          -- 10
    {ctype='unsigned int',      label='Item 4 Count'},                          -- 14
    {ctype='unsigned int',      label='Item 5 Count'},                          -- 18
    {ctype='unsigned int',      label='Item 6 Count'},                          -- 1C
    {ctype='unsigned int',      label='Item 7 Count'},                          -- 20
    {ctype='unsigned int',      label='Item 8 Count'},                          -- 24
    {ctype='unsigned int',      label='Item 9 Count'},                          -- 28
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
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='_unknown1'},                             -- 08   00 00 00 00 observed
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned char',     label='Slot',               fn=inv+{0}},        -- 0E
    {ctype='unsigned char',     label='_unknown2'},                             -- 0F   Takes values
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 10
    {ctype='char[3]',           label='_unknown2'}                              -- 11
}

-- Sort Item
fields.outgoing[0x03A] = L{
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
}

-- Lot item
fields.outgoing[0x041] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 04
}

-- Pass item
fields.outgoing[0x042] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 04
}

-- Servmes
-- First 4 bytes resemble the first 4 bytes of the incoming servmessage packet
fields.outgoing[0x04B] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04  Always 1?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05  Can be 1 or 0
    {ctype='unsigned char',     label='_unknown3'},                             -- 06  Always 1?
    {ctype='unsigned char',     label='_unknown4'},                             -- 07  Always 2?
    {ctype='char[12]',          label='_unknown5'},                             -- 08  All 00s
    {ctype='unsigned int',      label='_unknown5'},                             -- 14  EC 00 00 00 observed. May be junk.
}

-- Delivery Box
fields.outgoing[0x04D] = L{
    {ctype='unsigned char',     label='Manipulation Type'},                     -- 04
    --

    -- Removing an item from the d-box sends type 0x08
    -- It then responds to the server's 0x4B (id=0x08) with a 0x0A type packet.
    -- Their assignment is the same, as far as I can see.
    {ctype='unsigned char',     label='_unknown1'},                             -- 05   01 observed
    {ctype='unsigned char',     label='Slot'},                                  -- 06
    {ctype='char[5]',           label='_unknown2'},                             -- 07   FF FF FF FF FF observed
    {ctype='char[20]',          label='_unknown3'},                             -- 0C   All 00 observed
}

-- Equip
fields.outgoing[0x050] = L{
    {ctype='unsigned char',     label='Item Index',         fn=invp+{0x06}},    -- 04
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           -- 05
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 06
    {ctype='char[1]',           label='_junk1'}                                 -- 07
}

-- Conquest
fields.outgoing[0x05A] = L{
}

-- Dialogue options
fields.outgoing[0x05B] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Option Index'},                          -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 0A
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 0C
    {ctype='bool',              label='Begin dialogue'},                        -- 0E   Seems to be 1 when initiating conversion, 0 otherwise, unsure
    {ctype='unsigned char',     label='_unknown2'},                             -- 0F
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 10
    {ctype='unsigned char',     label='_unknown3'},                             -- 12   Might be a short, some parameter for the dialogue option, sometimes related to Index (Index + 0x5C0)
    {ctype='unsigned char',     label='_unknown4'},                             -- 13
}

-- Zone request
-- Sent when crossing a zone line.
fields.outgoing[0x05E] = L{
    {ctype='unsigned int',      label='Zone Line'},                             -- 04   This seems to be a fourCC consisting of the following chars:
                                                                                --      'z' (apparently constant)
                                                                                --      Region-specific char ('6' for Jeuno, '3' for Qufim, etc.)
                                                                                --      Zone-specific char ('u' for Port Jeuno, 't' for Lower Jeuno, 's' for Upper Jeuno, etc.)
                                                                                --      Zone line identifier ('4' for Port Jeuno > Qufim Island, '2' for Port Jeuno > Lower Jeuno, etc.)
    {ctype='char[12]',          label='_unknown1',          const=''},          -- 08
    {ctype='unsigned short',    label='_unknown2',          const=0},           -- 14
    {ctype='unsigned char',     label='_unknown3',          const=0x04},        -- 16   Seemed to never vary for me
    {ctype='unsigned char',     label='Type'},                                  -- 17   03 for leaving the MH, 00 otherwise
}

-- Equipment Screen (0x02 length) -- Also observed when zoning
fields.outgoing[0x061] = L{
}

-- Digging Finished
-- This packet alone is responsible for generating the digging result, meaning that anyone that can inject
-- this packet is capable of digging with 0 delay.
fields.outgoing[0x063] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='_unknown1'},                             -- 08
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned char',     label='Action?'},                               -- 0E   Changing it to anything other than 0x11 causes the packet to fail
    {ctype='unsigned char',     label='_junk1'},                                -- 0F   Likely junk. Has no effect on anything notable.
}

-- Party invite
fields.outgoing[0x06E] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04   This is so weird. The client only knows IDs from searching for people or running into them. So if neither has happened, the manual invite will fail, as the ID cannot be retrieved.
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08   00 if target not in zone
    {ctype='unsigned char',     label='Alliance'},                              -- 0A   02 for alliance, 00 for party or if invalid alliance target (the client somehow knows..)
    {ctype='unsigned char',     label='_const1',            const=0x041},       -- 0B
}

-- Party leaving
fields.outgoing[0x06F] = L{
    {ctype='unsigned char',     label='Alliance'},                              -- 04   02 for alliance, 00 for party
    {ctype='char[3]',           label='_junk1'}                                 -- 05
}

-- Party breakup
fields.outgoing[0x070] = L{
    {ctype='unsigned char',     label='Alliance'},                              -- 04   02 for alliance, 00 for party
    {ctype='char[3]',           label='_junk1'}                                 -- 05
}

-- Party invite response
fields.outgoing[0x074] = L{
    {ctype='bool',              label='Join',               fn=bool},           -- 04
    {ctype='char[3]',           label='_junk1'}                                 -- 05
}

-- Party change leader
fields.outgoing[0x077] = L{
    {ctype='char[16]',          label='Target Name'},                           -- 04   Name of the person to give leader to
    {ctype='unsigned short',    label='Alliance'},                              -- 14   02 01 for alliance, 00 00 for party
    {ctype='unsigned short',    label='_unknown1'},                             -- 16
}

-- NPC buy
-- Sent when buying an item from an NPC vendor
fields.outgoing[0x083] = L{
    {ctype='unsigned char',     label='Count'},                                 -- 04
    {ctype='char[3]',           label='_unknown1'},                             -- 05   Always 0? Possibly padding
    {ctype='unsigned short',    label='_unknown2'},                             -- 08   Always 0?
    {ctype='unsigned char',     label='Shop Slot'},                             -- 0A   The same index sent in incoming packet 0x03C
    {ctype='unsigned char',     label='_unknown3'},                             -- 0B   Always 0? Possibly padding
    {ctype='unsigned int',      label='_unknown4'},                             -- 0C   Always 0?
}

-- NPC Sell price query
-- Sent when trying to sell an item to an NPC
-- Clicking on the item the first time will determine the price
-- Also sent automatically when finalizing a sale, immediately preceeding packet 0x085
fields.outgoing[0x084] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='Item',                   fn=item},       -- 08
    {ctype='unsigned char',     label='Inventory Index',        fn=inv+{0}},    -- 09   Inventory index of the same item
    {ctype='unsigned char',     label='_unknown3'},                             -- 0A   Always 0? Likely padding
}

-- NPC Sell confirm
-- Sent when confirming a sell of an item to an NPC
fields.outgoing[0x085] = L{
    {ctype='unsigned int',      label='_unknown1',              const=1},       -- 04   Always 1? Possibly a type
}

-- Synth
fields.outgoing[0x096] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04   Crystal ID? Earth = 0x02, Wind-break = 0x19?, Wind no-break = 0x2D?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05
    {ctype='unsigned short',    label='Crystal',                fn=item},       -- 06
    {ctype='unsigned char',     label='Crystal Index',          fn=inv+{0}},    -- 08
    {ctype='unsigned char',     label='Number of Ingredients'},                 -- 09
    {ctype='unsigned short',    label='Ingredient 1',           fn=item},       -- 0A
    {ctype='unsigned short',    label='Ingredient 2',           fn=item},       -- 0C
    {ctype='unsigned short',    label='Ingredient 3',           fn=item},       -- 0E
    {ctype='unsigned short',    label='Ingredient 4',           fn=item},       -- 10
    {ctype='unsigned short',    label='Ingredient 5',           fn=item},       -- 12
    {ctype='unsigned short',    label='Ingredient 6',           fn=item},       -- 14
    {ctype='unsigned short',    label='Ingredient 7',           fn=item},       -- 16
    {ctype='unsigned short',    label='Ingredient 8',           fn=item},       -- 18
    {ctype='unsigned char',     label='Ingredient 1 Index',     fn=inv+{0}},    -- 1A
    {ctype='unsigned char',     label='Ingredient 2 Index',     fn=inv+{0}},    -- 1B
    {ctype='unsigned char',     label='Ingredient 3 Index',     fn=inv+{0}},    -- 1C
    {ctype='unsigned char',     label='Ingredient 4 Index',     fn=inv+{0}},    -- 1D
    {ctype='unsigned char',     label='Ingredient 5 Index',     fn=inv+{0}},    -- 1E
    {ctype='unsigned char',     label='Ingredient 6 Index',     fn=inv+{0}},    -- 1F
    {ctype='unsigned char',     label='Ingredient 7 Index',     fn=inv+{0}},    -- 20
    {ctype='unsigned char',     label='Ingredient 8 Index',     fn=inv+{0}},    -- 21
    {ctype='unsigned short',    label='_junk1'},                                -- 22
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

-- Merit Point Increase
fields.outgoing[0x0BE] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x03},        -- 04   No idea what it is, but it's always 0x03 for me
    {ctype='unsigned char',     label='Flag'},                                  -- 05   1 when you're increasing a merit point. 0 when you're decreasing it.
    {ctype='unsigned short',    label='Merit Point'},                           -- 06   No known mapping, but unique to each merit point. Could be an int.
    {ctype='unsigned int',      label='_unknown2',          const=0x00000000},  -- 08
}

-- Job Point Increase
-- This chunk was sent on three consecutive outgoing packets the only time I've used it
fields.outgoing[0x0BF] = L{
    {ctype='unsigned short',    label='Job Point'},                             -- 04
    {ctype='unsigned short',    label='_junk1',             const=0x0000},      -- 06   No values seen so far
}

-- Job Point Menu
-- This packet has no content bytes
fields.outgoing[0x0C0] = L{
}

-- Check
fields.outgoing[0x0DD] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 0A
    {ctype='unsigned char',     label='Check Type'},                            -- 0C   00 = Normal /check, 01 = /checkname, 02 = /checkparam
    {ctype='char[3]',           label='_junk1'}                                 -- 0D
}

-- Set LS Message
fields.outgoing[0x0E2] = L{
    {ctype='unsigned int',      label='_unknown1',          const=0x00000040},  -- 04
    {ctype='unsigned int',      label='_unknown2'},                             -- 08   Usually 0, but sometimes contains some junk
    {ctype='char[128]',         label='Message'}                                -- 0C
}

-- Logout
fields.outgoing[0x0E7] = L{
    {ctype='unsigned char',      label='_unknown1'},                            -- 04   Observed to be 00
    {ctype='unsigned char',      label='_unknown2'},                            -- 05   Observed to be 00
    {ctype='unsigned char',      label='Logout Type',       fn=e+{'logout'}},   -- 06   /logout = 01, /pol == 02 (removed), /shutdown = 03
    {ctype='unsigned char',      label='_unknown3'},                            -- 07   Observed to be 00
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
    {ctype='unsigned char',     label='Buff'},                                  -- 04
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

-- Place/Move Furniture
fields.outgoing[0x0FA] = L{
    {ctype='unsigned short',    label='Item ID'},                               -- 04  00 00 just gives the general update
    {ctype='unsigned char',     label='Safe Slot'},                             -- 06
    {ctype='unsigned char',     label='X Position'},                            -- 07  0 to 0x12
    {ctype='unsigned char',     label='Z Position'},                            -- 08  0 to ?
    {ctype='unsigned char',     label='Y Position'},                            -- 09  0 to 0x17
    {ctype='unsigned short',    label='_junk1'},                                -- 0A  00 00 observed
}

-- Remove Furniture
fields.outgoing[0x0FB] = L{
    {ctype='unsigned short',    label='Item ID'},                               -- 04
    {ctype='unsigned char',     label='Safe Slot'},                             -- 06
    {ctype='unsigned char',     label='_junk1'},                                -- 07
}

-- Plant Flowerpot
fields.outgoing[0x0FC] = L{
    {ctype='unsigned short',    label='Flowerpot Item ID'},                     -- 04
    {ctype='unsigned short',    label='Seed Item ID'},                          -- 06
    {ctype='unsigned char',     label='Flowerpot Safe Slot'},                   -- 08
    {ctype='unsigned char',     label='Seed Safe Slot'},                        -- 09
    {ctype='unsigned short',    label='_junk1'},                                -- 0A  00 00 observed
}

-- Examine Flowerpot
fields.outgoing[0x0FD] = L{
    {ctype='unsigned short',    label='Flowerpot Item ID'},                     -- 04
    {ctype='unsigned char',     label='Flowerpot Safe Slot'},                   -- 06
    {ctype='unsigned char',     label='_junk1'},                                -- 07
}

-- Uproot Flowerpot
fields.outgoing[0x0FE] = L{
    {ctype='unsigned short',    label='Flowerpot Item ID'},                     -- 04
    {ctype='unsigned char',     label='Flowerpot Safe Slot'},                   -- 06
    {ctype='unsigned char',     label='_unknown1'},                             -- 07  Value of 1 observed.
}

-- Job Change
fields.outgoing[0x100] = L{
    {ctype='unsigned char',     label='Main Job'},                              -- 04
    {ctype='unsigned char',     label='Sub Job'},                               -- 05
    {ctype='unsigned char',     label='_unknown1'},                             -- 06
    {ctype='unsigned char',     label='_unknown2'},                             -- 07
}

-- Untraditional Equip
-- Currently only commented for changing instincts in Monstrosity. Refer to the doku wiki for information on Autos/BLUs.
-- https://gist.github.com/nitrous24/baf9980df69b3dc7d3cf
fields.outgoing[0x102] = L{
    {ctype='unsigned short',    label='_unknown1'},                             -- 04  -- 00 00 for Monsters
    {ctype='unsigned short',    label='_unknown1'},                             -- 06  -- Varies by Monster family for the species change packet. Monsters that share the same tnl seem to have the same value. 00 00 for instinct changing.
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 08  -- 00x17 for Monsters
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 09  -- 00x00 for Monsters
    {ctype='unsigned short',    label='Flag'},                                  -- 0A  -- 04 00 for Monsters changing instincts. 01 00 for changing Monsters
    {ctype='unsigned short',    label='Species'},                               -- 0C  -- True both for species change and instinct change packets
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E  -- 00 00 for Monsters
    {ctype='unsigned short',    label='Instinct 1'},                            -- 10
    {ctype='unsigned short',    label='Instinct 2'},                            -- 12
    {ctype='unsigned short',    label='Instinct 3'},                            -- 14
    {ctype='unsigned short',    label='Instinct 4'},                            -- 16
    {ctype='unsigned short',    label='Instinct 5'},                            -- 18
    {ctype='unsigned short',    label='Instinct 6'},                            -- 1A
    {ctype='unsigned short',    label='Instinct 7'},                            -- 1C
    {ctype='unsigned short',    label='Instinct 8'},                            -- 1E
    {ctype='unsigned short',    label='Instinct 9'},                            -- 20
    {ctype='unsigned short',    label='Instinct 10'},                           -- 22
    {ctype='unsigned short',    label='Instinct 11'},                           -- 24
    {ctype='unsigned short',    label='Instinct 12'},                           -- 26
    {ctype='unsigned char',     label='Name 1'},                                -- 28
    {ctype='unsigned char',     label='Name 2'},                                -- 29
    {ctype='char*',             label='_unknown'},                              -- 2A  -- All 00s for Monsters
}

-- Open Bazaar
-- Sent when you open someone's bazaar from the /check window
fields.outgoing[0x105] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
}

-- Bid Bazaar
-- Sent when you bid on an item in someone's bazaar
fields.outgoing[0x106] = L{
    {ctype='unsigned char',     label='Inventory Index'},                       -- 04   The seller's inventory index of the wanted item
    {ctype='char[3]',           label='_junk1'},                                -- 05
    {ctype='unsigned int',      label='Count'},                                 -- 08
}

-- Close own Bazaar
-- Sent when you close your bazaar window
fields.outgoing[0x109] = L{
}

-- Bazaar price set
-- Sent when you set the price of an item in your bazaar
fields.outgoing[0x10A] = L{
    {ctype='unsigned char',     label='Inventory Index',    fn=inv+{0}},        -- 04
    {ctype='char[3]',           label='_junk1'},                                -- 05
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 08
}

-- Open own Bazaar
-- Sent when you attempt to open your bazaar to set prices
fields.outgoing[0x10B] = L{
    {ctype='unsigned int',      label='_unknown1',          const=0x00000000},  -- 04   00 00 00 00 for me
}

-- Start RoE Quest
fields.outgoing[0x10C] = L{
    {ctype='unsigned short',    label='RoE Quest'},                             -- 04   This field is likely actually 12 bits
}

-- Cancel RoE Quest
fields.outgoing[0x10D] = L{
    {ctype='unsigned short',    label='RoE Quest'},                             -- 04   This field is likely actually 12 bits
}

-- Currency Menu
fields.outgoing[0x10F] = L{
}

enums['fishing'] = {
    [2] = 'Cast rod',
    [3] = 'Release/catch',
    [4] = 'Put away rod',
}

-- Fishing Action
fields.outgoing[0x110] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='Fish HP'},                               -- 08   Always 200 when releasing, zero when casting and putting away rod
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned char',     label='Action',             fn=e+{'fishing'}},  -- 0E
    {ctype='unsigned char',     label='_unknown1'},                             -- 0F   Always zero (pre-March fishing update this value would increase over time, probably zone fatigue)
    {ctype='unsigned int',      label='Catch Key'},                             -- 10   When catching this matches the catch key from the 0x115 packet, otherwise zero
}

-- Lockstyle
fields.outgoing[0x111] = L{
    {ctype='bool',              label='Lock'},                                  -- 04   0 = unlock, 1 = lock
    {ctype='char[3]',           label='_junk1'},                                -- 05
}

-- Zone update
fields.incoming[0x00A] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='char[38]',          label='_unknown1'},                             -- 0A
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 30
    {ctype='char[6]',           label='_unknown2'},                             -- 32
    {ctype='unsigned int',      label='Timestamp 1',        fn=time},           -- 38
    {ctype='unsigned int',      label='Timestamp 2',        fn=time},           -- 3C
    {ctype='unsigned short',    label='_unknown3'},                             -- 40
    {ctype='unsigned short',    label='_dupeZone',          fn=zone},           -- 42
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
    {ctype='char[18]',          label='_unknown4'},                             -- 56
    {ctype='unsigned short',    label='Weather',            fn=weather},        -- 68
    {ctype='unsigned short',    label='_unknown5'},                             -- 6A
    {ctype='char[24]',          label='_unknown6'},                             -- 6C
    {ctype='char[16]',          label='Player Name'},                           -- 84
    {ctype='char[12]',          label='_unknown7'},                             -- 94
    {ctype='unsigned int',      label='Abyssea Timestamp',  fn=time},           -- A0
    {ctype='unsigned int',      label='_unknown8',          const=0x0003A020},  -- A4
    {ctype='char[2]',           label='_unknown9'},                             -- A8
    {ctype='unsigned short',    label='Zone model'},                            -- AA
    {ctype='char[8]',           label='_unknown10'},                            -- AC   0xAC is 2 for some zones, 0 for others
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- B4
    {ctype='unsigned char',     label='_unknown11'},                            -- B5
    {ctype='unsigned char',     label='_unknown12'},                            -- B6
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- B7
    {ctype='unsigned int',      label='_unknown13'},                            -- B8
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
    {ctype='char[20]',          label='_unknown14'},                            -- F0
}

-- Zone Response
fields.incoming[0x00B] = L{
    {ctype='unsigned int',      label='Type',               fn=e+{'zone'}},     -- 04
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

    ---- Mask bits, from antiquity:
    -- 0x01: "Basic"
    -- 0x02: "Bit 1"
    -- 0x04: Status
    -- 0x08: Name
    -- 0x10: Gear
    -- 0x20: Bit 5
    -- 0x40: Bit 6
    -- 0x80: Bit 7
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='Mask',               fn=bin+{1}},        -- 0A
    {ctype='unsigned char',     label='Body Rotation',      fn=dir},            -- 0B
    {ctype='float',             label='X Position'},                            -- 0C
    {ctype='float',             label='Z Position'},                            -- 10
    {ctype='float',             label='Y Position'},                            -- 14
    {ctype='unsigned short',    label='Head Rotation',      fn=dir},            -- 18
    {ctype='unsigned short',    label='Target Index *2',    fn=index..s+{2,15}},-- 1A
    {ctype='unsigned char',     label='Current Speed'},                         -- 1C
    {ctype='unsigned char',     label='Base Speed'},                            -- 1D
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Animation'},                             -- 1F
    {ctype='unsigned char',     label='Status'},                                -- 20
    {ctype='unsigned char',     label='_unknown1'},                             -- 21
    {ctype='unsigned short',    label='Flags',              fn=bin+{2}},        -- 22
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

-- Mask values (from antiquity):
-- 0x01: "Basic"
-- 0x02: Status
-- 0x04: HP
-- 0x08: Name
-- 0x10: "Bit 4"
-- 0x20: "Bit 5"
-- 0x40: "Bit 6"
-- 0x80: "Bit 7"


-- Status flags (from antiquity):
-- 0b00100000 = CFH Bit
-- 0b10000101 = "Normal_Status?"
fields.incoming[0x00E] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='Mask',               fn=bin+{1}},        -- 0A   Bits that control which parts of the packet are actual updates (rest is zeroed). Model is always sent
                                                                                -- 0A   Bit 0: Position, Rotation, Walk Count
                                                                                -- 0A   Bit 1: Claimer ID
                                                                                -- 0A   Bit 2: HP, Status
                                                                                -- 0A   Bit 3: Name
                                                                                -- 0A   Bit 4:
                                                                                -- 0A   Bit 5: The client stops displaying the mob when this bit is set (dead, out of range, etc.)
                                                                                -- 0A   Bit 6:
                                                                                -- 0A   Bit 7:
    {ctype='unsigned char',     label='Rotation',           fn=dir},            -- 0B
    {ctype='float',             label='X Position'},                            -- 0C
    {ctype='float',             label='Z Position'},                            -- 10
    {ctype='float',             label='Y Position'},                            -- 14
    {ctype='unsigned int',      label='Walk Count'},                            -- 18   Steadily increases until rotation changes. Does not reset while the mob isn't walking. Only goes until 0xFF1F.
    {ctype='unsigned short',    label='_unknown1',          fn=bin+{2}},        -- 1A
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Status',             fn=status},         -- 1F   Status used to be 0x20
    {ctype='unsigned int',      label='_unknown2',          fn=bin+{4}},        -- 20
    {ctype='unsigned int',      label='_unknown3',          fn=bin+{4}},        -- 24
    {ctype='unsigned int',      label='_unknown4',          fn=bin+{4}},        -- 28
    {ctype='unsigned int',      label='Claimer',            fn=id},             -- 2C
    {ctype='unsigned short',    label='_unknown5'},                             -- 30
    {ctype='unsigned short',    label='Model'},                                 -- 32
    {ctype='char*',             label='Name'},                                  -- 34 -   *
}

-- Incoming Chat
fields.incoming[0x017] = L{
    {ctype='unsigned char',     label='Mode'},                                  -- 04
    {ctype='bool',              label='GM'},                                    -- 05
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 06   Set only for Yell
    {ctype='char[16]',          label='Sender Name'},                           -- 08
    {ctype='char*',             label='Message'},                               -- 18   Max of 150 characters
}

-- Job Info
fields.incoming[0x01B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Observed value of 05
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 08
    {ctype='unsigned char',     label='Flag or Main Job Level?'},               -- 09
    {ctype='unsigned char',     label='Flag or Sub Job Level?'},                -- 0A
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 0B
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

-- Inventory Count
-- It is unclear why there are two representations of the size for this.
-- I have manipulated my inventory size on a mule after the item update packets have
-- all arrived and still did not see any change in the second set of sizes, so they
-- may not be max size/used size chars as I initially assumed. Adding them as shorts
-- for now.
-- There appears to be space for another 8 bags.
fields.incoming[0x01C] = L{
    {ctype='unsigned char',     label='Inventory Size'},                        -- 04
    {ctype='unsigned char',     label='Safe Size'},                             -- 05
    {ctype='unsigned char',     label='Storage Size'},                          -- 06
    {ctype='unsigned char',     label='Temporary Size'},                        -- 07
    {ctype='unsigned char',     label='Locker Size'},                           -- 08
    {ctype='unsigned char',     label='Satchel Size'},                          -- 09
    {ctype='unsigned char',     label='Sack Size'},                             -- 0A
    {ctype='unsigned char',     label='Case Size'},                             -- 0B
    {ctype='unsigned char',     label='Wardrobe Size'},                         -- 0C
    {ctype='char[7]',           label='_padding1',          const=''},          -- 0D
    {ctype='unsigned short',    label='_dupeInventory Size'},                   -- 14
    {ctype='unsigned short',    label='_dupeSafe Size'},                        -- 16
    {ctype='unsigned short',    label='_dupeStorage Size'},                     -- 1A   The accumulated storage from all items (uncapped) -1
    {ctype='unsigned short',    label='_dupeTemporary Size'},                   -- 1C
    {ctype='unsigned short',    label='_dupeLocker Size'},                      -- 1E
    {ctype='unsigned short',    label='_dupeSatchel Size'},                     -- 20
    {ctype='unsigned short',    label='_dupeSack Size'},                        -- 22
    {ctype='unsigned short',    label='_dupeCase Size'},                        -- 24
    {ctype='unsigned short',    label='_dupeWardrobe Size'},                    -- 26
    {ctype='char[16]',          label='_padding2',          const=''},          -- 28
}

-- Finish Inventory
fields.incoming[0x01D] = L{
    {ctype='unsigned int',      label='Flag',               const=0x01},        -- 04
}

-- Modify Inventory
fields.incoming[0x01E] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 08
    {ctype='unsigned char',     label='Index',              fn=inv+{0}},        -- 09
    {ctype='unsigned short',    label='_junk1'},                                -- 10
}

-- Item Assign
fields.incoming[0x01F] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 0A
    {ctype='unsigned char',     label='Index',              fn=invp+{0x0A}},    -- 0B
    {ctype='unsigned char',     label='Status',             fn=e+{'itemstat'}}, -- 0C
}

-- Item Updates
fields.incoming[0x020] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned int',      label='Bazaar',             fn=gil},            -- 08
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0C
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 0E
    {ctype='unsigned char',     label='Index',              fn=invp+{0x0E}},    -- 0F
    {ctype='unsigned char',     label='Status',             fn=e+{'itemstat'}}, -- 10
    {ctype='char[24]',          label='ExtData',            fn='...':fn()},     -- 11
    {ctype='char[3]',           label='_junk1'},                                -- 29
}

-- Trade request received
fields.incoming[0x021] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned short',    label='_junk1'},                                -- 0A
}

-- Trade request sent
enums['trade'] = {
    [0] = 'Trade started',
    [1] = 'Trade canceled',
    [2] = 'Trade accepted by other party',
    [9] = 'Trade successful',
}
fields.incoming[0x022] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='Type',               fn=e+{'trade'}},    -- 08
    {ctype='unsigned short',    label='Index',              fn=index},          -- 0C
    {ctype='unsigned short',    label='_junk1'},                                -- 0E
}

-- Trade item, other party
fields.incoming[0x023] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='Trade Count'},                           -- 08   Seems to increment every time packet 0x023 comes in, i.e. every trade action performed by the other party
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0A   If the item is removed, gil is used with a count of zero
    {ctype='unsigned char',     label='_unknown1',          const=0x05},        -- 0C   Possibly junk?
    {ctype='unsigned char',     label='Slot'},                                  -- 0D   Gil itself is in slot 0, whereas the other slots start at 1 and count up horizontally
    {ctype='char[24]',          label='ExtData'},                               -- 0E
    {ctype='char[2]',           label='_junk1'},                                -- 26
}

-- Trade item, self
fields.incoming[0x025] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08   If the item is removed, gil is used with a count of zero
    {ctype='unsigned char',     label='Slot'},                                  -- 0A   Gil itself is in slot 0, whereas the other slots start at 1 and count up horizontally
    {ctype='unsigned char',     label='Inventory Index',    fn=inv+{0}},        -- 0B
}

-- Count to 80
-- Sent after Item Update chunks for active inventory (sometimes) when zoning.
fields.incoming[0x026] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 04
    {ctype='unsigned char',     label='Slot ID'},                               -- 05   Corresponds to the slot IDs of the previous incoming packet's Item Update chunks for active Inventory.
    {ctype='char[22]',          label='_unknown2',          const=0},           -- 06
}

-- Encumbrance Release
fields.incoming[0x027] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='Slot or Stat ID'},                       -- 0A   85 = DEX Down, 87 = AGI Down, 8A = CHR Down, 8B = HP Down, 7A = Head/Neck restriction, 7D = Leg/Foot Restriction
    {ctype='unsigned char',     label='_unknown1'},                             -- 0B   9C
    {ctype='unsigned int',      label='_unknown2'},                             -- 0C   04 00 00 00
    {ctype='unsigned int',      label='_unknown3'},                             -- 10
    {ctype='unsigned char',     label='_unknown4'},                             -- 14
    {ctype='char[11]',          label='_unknown5'},                             -- 15
    {ctype='char[16]',          label='Player Name'},                           -- 20
    {ctype='char[16]',          label='_unknown6'},                             -- 30
    {ctype='char[16]',          label='_dupePlayer Name'},                      -- 40
    {ctype='char[32]',          label='_unknown7'},                             -- 50
}

-- Action
fields.incoming._mult[0x028] = {}
fields.incoming[0x028] = function(data)
    return fields.incoming._mult[0x028].base
end

enums.action_in = {
    [4] = 'Casting finish',
    [6] = 'Job Ability use',
    [8] = 'Casting start',
}

fields.incoming._mult[0x028].base = L{
    {ctype='unsigned char',     label='Size'},                                  -- 04
    {ctype='unsigned int',      label='Actor',              fn=id},             -- 05
    {ctype='bit[10]',           label='Target Count'},                          -- 09
    {ctype='bit[4]',            label='Category',           fn=e+{'action_in'}},-- 0A
    {ctype='bit[16]',           label='Param'},                                 -- 0C
    {ctype='bit[16]',           label='_unknown1'},                             -- 0E
    {ctype='bit[32]',           label='Recast'},                                -- 10
}

-- Action Message
fields.incoming[0x029] = L{
    {ctype='unsigned int',      label='Actor',              fn=id},             -- 04
    {ctype='unsigned int',      label='Target',             fn=id},             -- 08
    {ctype='unsigned int',      label='Param 1'},                               -- 0C
    {ctype='unsigned int',      label='Param 2'},                               -- 10
    {ctype='unsigned short',    label='Actor Index',        fn=index},          -- 14
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16
    {ctype='unsigned short',    label='Message'},                               -- 18
    {ctype='unsigned short',    label='_unknown1'},                             -- 1A
}

-- Resting Message
fields.incoming[0x02A] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='Param 1'},                               -- 08
    {ctype='unsigned int',      label='Param 2'},                               -- 0C
    {ctype='unsigned int',      label='Param 3'},                               -- 10
    {ctype='unsigned int',      label='Param 4'},                               -- 14
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 18
    {ctype='unsigned short',    label='Message ID'},                            -- 1A   The high bit is occasionally set, though the reason for it is unclear.
    {ctype='unsigned int',      label='_unknown1'},                             -- 1C   Possibly flags, 0x06000000 and 0x02000000 observed
}

-- Kill Message
-- Updates EXP gained, RoE messages, Limit Points, and Capacity Points
fields.incoming[0x02D] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='Target',             fn=id},             -- 08   Player ID in the case of RoE log updates
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 0E   Player Index in the case of RoE log updates
    {ctype='unsigned int',      label='Param 1'},                               -- 10   EXP gained, etc. Numerator for RoE objectives
    {ctype='unsigned int',      label='Param 2'},                               -- 14   Denominator for RoE objectives
    {ctype='unsigned short',    label='Message'},                               -- 18
    {ctype='unsigned short',    label='_flags1'},                               -- 1A   This could also be a third parameter, but I suspect it is flags because I have only ever seen one bit set.
}

-- Digging Animation
fields.incoming[0x02F] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='Animation'},                             -- 0A   Changing it to anything other than 1 eliminates the animation
    {ctype='unsigned char',     label='_junk1'},                                -- 0B   Likely junk. Has no effect on anything notable.
}

-- Synth Animation
fields.incoming[0x030] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='Effect'},                                -- 0A  -- 10 00 is water, 11 00 is wind, 12 00 is fire, 13 00 is earth, 14 00 is lightning, 15 00 is ice, 16 00 is light, 17 00 is dark
    {ctype='unsigned char',     label='Param'},                                 -- 0C  -- 00 is NQ, 01 is break, 02 is HQ
    {ctype='unsigned char',     label='Animation'},                             -- 0D  -- Always C2 for me.
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 0E  -- Appears to just be trash.
}

-- NPC Interaction Type 1
fields.incoming[0x032] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 08
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 0A
    {ctype='unsigned short',    label='Menu ID'},                               -- 0C   Seems to select between menus within a zone
    {ctype='unsigned short',    label='_unknown1'},                             -- 0E   00 for me
    {ctype='unsigned char',     label='_dupeZone',          fn=zone},           -- 10
    {ctype='char[3]',           label='_junk1'},                                -- 11   Always 00s for me
}

-- NPC Interaction Type 2
fields.incoming[0x034] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='unsigned short[16]',label='Menu Parameter'},                        -- 08
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 28
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 2A
    {ctype='unsigned short',    label='Menu ID'},                               -- 2C   Seems to select between menus within a zone
    {ctype='unsigned short',    label='_unknown1',          const=0x08},        -- 2E   08 for me, but FFing did nothing
    {ctype='unsigned short',    label='_dupeZone',          fn=zone},           -- 30
    {ctype='char[2]',           label='_junk1'},                                -- 31   Always 00s for me
}

enums.indi = {
    [0x5F] = 'Enemy Dark',
    [0x5E] = 'Enemy Light',
    [0x5D] = 'Enemy Water',
    [0x5C] = 'Enemy Lightning',
    [0x5B] = 'Enemy Earth',
    [0x5A] = 'Enemy Wind',
    [0x59] = 'Enemy Ice',
    [0x58] = 'Enemy Fire',
    [0x57] = 'Party Dark',
    [0x56] = 'Party Light',
    [0x55] = 'Party Water',
    [0x54] = 'Party Lightning',
    [0x53] = 'Party Earth',
    [0x52] = 'Party Wind',
    [0x51] = 'Party Ice',
    [0x50] = 'Party Fire',
    [0x00] = 'None',
}

-- Player update
-- Buff IDs go can over 0xFF, but in the packet each buff only takes up one byte.
-- To address that there's a 8 byte bitmask starting at 0x4C where each 2 bits
-- represent how much to add to the value in the respective byte.
fields.incoming[0x037] = L{
    {ctype='unsigned char[32]', label='Buff',               fn=buff},           -- 04
    {ctype='unsigned int',      label='Player',             fn=id},             -- 24
    {ctype='unsigned short',    label='_unknown1'},                             -- 28   Called "Flags" on the old dev wiki
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 29
    {ctype='unsigned char',     label='_unknown2'},                             -- 2A   May somehow be tied to current animation (old dev wiki)
    {ctype='unsigned char',     label='_unknown3'},                             -- 2B
    {ctype='unsigned char',     label='_unknown4'},                             -- 2C
    {ctype='unsigned char',     label='_unknown5'},                             -- 2D
    {ctype='unsigned char',     label='_unknown6'},                             -- 2E
    {ctype='unsigned char',     label='Status',             fn=status},         -- 30
    {ctype='unsigned char',     label='LS Color Red'},                          -- 31
    {ctype='unsigned char',     label='LS Color Green'},                        -- 32
    {ctype='unsigned char',     label='LS Color Blue'},                         -- 33
    {ctype='char[8]',           label='_unknown7'},                             -- 34   Player's pet index * 8?
    {ctype='unsigned int',      label='_unknown8'},                             -- 3C
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 40
    {ctype='char[8]',           label='_unknown9'},                             -- 44
    {ctype='char[8]',           label='Bit Mask'},                              -- 4C
    {ctype='char[4]',           label='_unknown10'},                            -- 54
    {ctype='unsigned char',     label='Indi Buff',          fn=e+{'indi'}},     -- 58
    {ctype='char[3]',           label='_unknown11'},                            -- 59
}

-- Model DisAppear
fields.incoming[0x038] = L{
    {ctype='unsigned int',      label='Mob',                fn=id},             -- 04
    {ctype='unsigned int',      label='_dupeMob',           fn=id},             -- 08
    {ctype='char[4]',           label='Type',               fn=e+{0x038}},      -- 0C   "kesu" for disappearing, "deru" for appearing, "deru" only seems to work, "ef96" -- These are all probably animation IDs
    {ctype='unsigned short',    label='Mob Index',          fn=index},          -- 10
    {ctype='unsigned short',    label='_dupeMob Index',     fn=index},          -- 12
}

-- Env. Animation 2
fields.incoming[0x039] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   00 00 00 00 observed
    {ctype='unsigned int',      label='_unknown2'},                             -- 08   00 00 00 00 observed
    {ctype='char[4]',           label='Type',               fn=e+{0x038}},      -- 0C   "nbof" or "nbon" observed
    {ctype='unsigned int',      label='_unknown3'},                             -- 10   00 00 00 00 observed
}

types.shop_item = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 00
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04
    {ctype='unsigned short',    label='Shop Slot'},                             -- 08
}

-- Shop
fields.incoming[0x03C] = L{
    {ctype='unsigned short',    label='_zero1',             const=0x0000},      -- 04
    {ctype='unsigned short',    label='_padding1'},                             -- 06
    {ref=types.shop_item,       label='Item',               count='*'},         -- 08 -   *
}

-- Price response
-- Sent after an outgoing price request for an NPC vendor (0x085)
fields.incoming[0x03D] = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 04
    {ctype='unsigned char',     label='Inventory Index',    fn=invp+{0x09}},    -- 08
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 09
    {ctype='unsigned short',    label='_junk1'},                                -- 0A
    {ctype='unsigned int',      label='_unknown1',          const=1},           -- 0C
}

-- Pet Stat
-- This packet varies and is indexed by job ID (byte 4)
-- Packet 0x044 is sent twice in sequence when stats could change. This can be caused by anything from
-- using a Maneuver on PUP to changing job. The two packets are the same length. The first
-- contains information about your main job. The second contains information about your
-- subjob and has the Subjob flag flipped.
fields.incoming._mult[0x044] = {}
fields.incoming[0x044] = function(data)
    return fields.incoming._mult[0x044].base + fields.incoming._mult[0x044][data:sub(5,5):byte()]
end

-- Base, shared by all jobs
fields.incoming._mult[0x044].base = L{
    {ctype='unsigned char',     label='Job'},                                   -- 04
    {ctype='bool',              label='Subjob'},                                -- 05
    {ctype='unsigned short',    label='_unknown1'},                             -- 06
}

-- PUP
fields.incoming._mult[0x044][0x12] = L{
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
    {ctype='unsigned short',    label='_unknown2'},                             -- 16
    {ctype='unsigned int',      label='Available Heads'},                       -- 18   Flags for the available heads (Position corresponds to Item ID shifted down by 8192)
    {ctype='unsigned int',      label='Available Bodies'},                      -- 1C   Flags for the available bodies (Position corresponds to Item ID)
    {ctype='unsigned int',      label='_unknown3'},                             -- 20
    {ctype='unsigned int',      label='_unknown4'},                             -- 24
    {ctype='unsigned int',      label='_unknown5'},                             -- 28
    {ctype='unsigned int',      label='_unknown6'},                             -- 2C
    {ctype='unsigned int',      label='_unknown7'},                             -- 30
    {ctype='unsigned int',      label='_unknown8'},                             -- 34
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
    {ctype='unsigned int',      label='_unknown9'},                             -- 7C
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
}

-- For BLM, 0x29 to 0x43 appear to represent the black magic that you know

-- MON
fields.incoming._mult[0x044][0x17] = L{
    {ctype='unsigned short',    label='Species'},                               -- 08
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A
    {ctype='unsigned short[12]',label='Instinct'},                              -- 0C   Instinct assignments are based off their position in the equipment list.
    {ctype='unsigned short',    label='_unknown3'},                             -- 24
    {ctype='char[118]',         label='_unknown4'},                             -- 26   Zeroing everything beyond this point has no notable effect.
}

-- Delivery Item
fields.incoming._mult[0x04B] = {}
fields.incoming[0x04B] = function()
    local full = S{0x01, 0x06, 0x08, 0x0A}
    return function(data)
        return full:contains(data:byte(5, 5)) and fields.incoming._mult[0x04B].slot or fields.incoming._mult[0x04B].base
    end
end()

enums.delivery = {
    -- Seems to occur when refreshing the d-box after any change (or before changes).
    [0x01] = 'Slot info',
    -- Seems to occur when placing items into the d-box.
    [0x02] = 'Place item',
    -- Two occur per item that is actually sent (hitting "OK" to send).
    [0x03] = 'Send confirm',
    -- Two occur per sent item that is Canceled.
    [0x04] = 'Send cancel',
    -- Seems to occur quasi-randomly. Can be seen following spells.
    [0x05] = 'Unknown 0x05',
    -- Occurs for new items.
    -- Two of these are sent sequentially. The first one doesn't seem to contain much/any
    -- information and the second one is very similar to a type 0x01 packet
    -- First packet's frst line:   4B 58 xx xx 06 01 00 01 FF FF FF FF 02 02 FF FF
    -- Second packet's first line: 4B 58 xx xx 06 01 00 FF FF FF FF FF 01 02 FF FF
    [0x06] = 'New item',
    -- Occurs as the first packet when removing something from the send box.
    [0x07] = 'Remove item (send)',
    -- Occurs as the first packet when removing or dropping something from the delivery box.
    [0x08] = 'Remove/drop item (delivery)',
    -- Occurs when someone returns something from the delivery box.
    [0x09] = 'Return item',
    -- Occurs as the second packet when removing something from the delivery box or send box.
    [0x0A] = 'Remove item confirm',
    -- Occurs as the second packet when dropping something from the delivery box.
    [0x0B] = 'Drop item (delivery)',
    -- Sent after entering a name and hitting "OK" in the outbox.
    [0x0C] = 'Send request',
    -- Sent after requesting the send box, causes the client to open the send box dialogue.
    [0x0D] = 'Send dialogue start',
    -- Sent after requesting the delivery box, causes the client to open the delivery box dialogue.
    [0x0E] = 'Delivery dialogue start',
    -- Sent after closing the delivery box or send box.
    [0x0F] = 'Delivery/send dialogue finish',
}

-- This is always sent for every packet of this ID
fields.incoming._mult[0x04B].base = L{
    {ctype='unsigned char',     label='Type',               fn=e+{'delivery'}}, -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05   FF if Type is 05, otherwise 01
    {ctype='signed char',       label='Delivery Slot'},                         -- 06   This goes left to right and then drops down a row and left to right again. Value is 00 through 07
    {ctype='signed char',       label='_unknown2'},                             -- 0C   01 if Type is 06, otherwise FF
                                                                                -- 0C   06 Type always seems to come in a pair, this field is only 01 for the first packet
    {ctype='signed int',        label='_unknown3',          const=-1},          -- 07   Always FF FF FF FF?
    {ctype='signed char',       label='_unknown4'},                             -- 0C   01 observed
    {ctype='signed char',       label='Packet Number'},                         -- 0D   02 and 03 observed
    {ctype='signed char',       label='_unknown5'},                             -- 0E   FF FF observed
    {ctype='signed char',       label='_unknown5'},                             -- 0E   FF FF observed
    {ctype='unsigned int',      label='_unknown6'},                             -- 10   06 00 00 00 and 07 00 00 00 observed - (06 was for the first packet and 07 was for the second)
}

-- If the type is 0x01, 0x06, 0x08 or 0x0A, these fields appear in the packet in addition to the base
fields.incoming._mult[0x04B].slot = L{
    {ref=fields.incoming._mult[0x04B].base},                                    -- 04
    {ctype='char[16]',          label='Sender Name'},                           -- 14
    {ctype='unsigned int',      label='_unknown7'},                             -- 24   46 32 00 00 and 42 32 00 00 observed - Possibly flags. Rare vs. Rare/Ex.?
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 28
    {ctype='unsigned int',      label='_unknown8'},                             -- 2C   00 00 00 00 observed
    {ctype='unsigned short',    label='Item',               fn=item},           -- 30
    {ctype='unsigned short',    label='_unknown9'},                             -- 32   Fiendish Tome: Chapter 11 had it, but Oneiros Pebble was just 00 00
                                                                                -- 32   May well be junked, 38 38 observed
    {ctype='unsigned int',      label='Flags?'},                                -- 34   01/04 00 00 00 observed
    {ctype='unsigned short',    label='Count'},                                 -- 38
    {ctype='unsigned short',    label='_unknown10'},                            -- 3A
    {ctype='char[28]',          label='_unknown11'},                            -- 3C   All 00 observed, ext data? Doesn't seem to be the case, but same size
}

-- Auction house open
-- The server sends this when the player clicks on an AH NPC, it starts the AH dialogue
fields.incoming[0x04C] = L{
    {ctype='unsigned char',     label='Type'},                                  --  0x02 for AH, 0x0A for... something, related to AH
    {ctype='unsigned char',     label='Index?'},                                --  Counts up when Type is 0x0A
    {ctype='unsigned char',     label='Response'},                              --  Disambiguation when Type is 0x02. Everything but 0x01 seems to result in:
                                                                                --  "Auction house is temporarily closed for trading."
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        --  Possibly padding
    {ctype='char[52]',          label='_unknown2'},                             --
}

-- Servmes Resp
-- Length of the packet may vary based on message length? Kind of hard to test.
-- The server message appears to generate some kind of feedback to the server based on the flags?
-- If you set the first byte to 0 in incoming chunk with eval and do /smes, the message will not display until you unload eval.
fields.incoming[0x4D] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04  01  Message does not appear without this
    {ctype='unsigned char',     label='_unknown2'},                             -- 05  01  Nonessential to message appearance
    {ctype='unsigned char',     label='_unknown3'},                             -- 06  01  Message does not appear without this
    {ctype='unsigned char',     label='_unknown4'},                             -- 07  02  Message does not appear without this
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 08  UTC Timestamp
    {ctype='unsigned int',      label='Message Length 1'},                      -- 0A  Number of characters in the message
    {ctype='unsigned int',      label='_unknown2'},                             -- 10  00 00 00 00 observed
    {ctype='unsigned int',      label='Message Length 2'},                      -- 14  Same as Message Length 1. Not sure why this needs to be an int or in here twice.
    {ctype='char[148]',         label='Message'},                               -- 18  Currently prefixed with 0x81, 0xA1 - A custom shift-jis character that translates to a square.
}

-- Data Download 2
fields.incoming[0x04F] = L{
--   This packet's contents are nonessential. They are often leftovers from other outgoing
--   packets. It is common to see things like inventory size, equipment information, and
--   character ID in this packet. They do not appear to be meaningful and the client functions
--   normally even if they are blocked.
--   Tends to bookend model change packets (0x51), though blocking it, zeroing it, etc. affects nothing.
    {ctype='unsigned int',      label='_unknown1'},                             -- 04
}

-- Equip
fields.incoming[0x050] = L{
    {ctype='unsigned char',     label='Inventory Index',    fn=invp+{0x06}},    -- 04
    {ctype='unsigned char',     label='Equipment Slot',     fn=slot},           -- 05
    {ctype='unsigned char',     label='Inventory Bag',      fn=bag},            -- 06
    {ctype='char[1]',           label='_junk1'}                                 -- 07
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

-- Logout Time
-- This packet is likely used for an entire class of system messages,
-- but the only one commonly encountered is the logout counter.
fields.incoming[0x053] = L{
    {ctype='unsigned int',      label='param'},                                 -- 04   Parameter
    {ctype='unsigned int',      label='_unknown1'},                             -- 08   00 00 00 00 observed
    {ctype='unsigned short',    label='Message ID'},                            -- 0C   It is unclear which dialogue table this corresponds to
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E   Probably junk.
}

-- Key Item Log
fields.incoming[0x055] = L{
    -- There are 6 of these packets sent on zone, which likely corresponds to the 6 categories of key items.
    -- FFing these packets between bytes 0x14 and 0x82 gives you access to all (or almost all) key items.
    {ctype='char[0x40]',        label='Key item available', fn=hex},            -- 04
    {ctype='char[0x40]',        label='Key item examined',  fn=hex},            -- 44   Bit field correlating to the previous, 1 if KI has been examined, 0 otherwise
    {ctype='unsigned int',      label='Type'},                                  -- 84   Goes from 0 to 5, determines which KI are being sent
    -- The type describes which KI that particular chunk contains:
    -- 0:
    --      Temporary: Ferry ticket, whispers, tuning forks
    --      Permanent: Airship passes, Shard of <Apathy, Arrogance, etc.>, Hydra corps crap, gate crystals, misc crap
    --      Abyssea: Traverser stones
    --      Voidwatch: Crimson/Indigo/Jade stratum abyssites
    --      Magical Maps: Regular, RotZ, CoP
    -- 1:
    --      Temporary: Assault, Einherjar, Salvage, Campaign medals, misc crap
    --      Permanent: Random CoP, ToAU and WotG KIs, WotG gate crystals
    --      Claim Slips: AF1 armor slips
    -- 2:
    --      Temporary: Luminous fragments, VNM abyssites, ACP KIs
    --      Permannet: Delkfutt key, synergy, magian log
    --      Abyssea: Traverser stones, NM trigger KI, battle trophies 1/2/3, Abyssites (including Lunar, cosmos/discernment), regular Atma (including Apoc)
    --      Voidwatch: White/Ashen stratum abyssites
    -- 3:
    --      Temporary: Grey abyssite, Moonshade earring
    --      Permanent: Prismatic hourglass, Miasmal counteragent recipe, pouch of weighted stones, job gestures
    --      Abyssea: Crimson bloodstone, battle trophies 4/5, synthetic Atma
    --      Voidwatch: Voidstones, Petrifacts, Periapts, Atmacites
    --      Magical Maps: ToAU, WotG, Abyssea, Dynamis
    -- 4:
    --      Temporary: Grimoire page
    --      Permanent: Loadstone, Heart of the bushin, Prototype attuner, Geomagnetron, Adoulinian charter permit, Ring of supernal disjunction
    --      Voidwatch: Hyacinth/Amber stratum abyssite, VW emblem: Jeuno
    -- 5:
}

-- Weather Change
fields.incoming[0x057] = L{
    {ctype='unsigned int',      label='Vanadiel Time',      fn=vtime},          -- 04   Units of minutes.
    {ctype='unsigned char',     label='Weather',            fn=weather},        -- 08
    {ctype='unsigned char',     label='_unknown1'},                             -- 09
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A
}

enums.spawntype = {
    [0x03] = 'Monster',
    [0x00] = 'Casket or NPC',
    [0x0A] = 'Self',
}

-- Spawn
fields.incoming[0x05B] = L{
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 10
    {ctype='unsigned short',    label='Index',              fn=index},          -- 14
    {ctype='unsigned char',     label='Type',               fn=e+{'spawntype'}},-- 16   3 for regular Monsters, 0 for Treasure Caskets and NPCs
    {ctype='unsigned char',     label='_unknown1'},                             -- 17   Always 0 if Type is 3, otherwise a seemingly random non-zero number
    {ctype='unsigned int',      label='_unknown2'},                             -- 18
}

-- Campaign/Besieged Map information

-- Bitpacked Campaign Info:
-- First/Second Byte -- I could see no change when I FF'd these.

-- Third Byte (bitpacked xxww bbss -- First two bits are for beastmen)
    -- 0 = Minimal
    -- 1 = Minor
    -- 2 = Major
    -- 3 = Dominant

-- Fourth Byte: Ownership (value)
    -- 0 = Neutral
    -- 1 = Sandy
    -- 2 = Bastok
    -- 3 = Windurst
    -- 4 = Beastmen
    -- 0xFF = Jeuno




-- Bitpacked Besieged Info:

-- Candescence Owners:
    -- 0 = Whitegate
    -- 1 = MMJ
    -- 2 = Halvung
    -- 3 = Arrapago
    
-- Orders:
    -- 0 = Defend Al Zahbi
    -- 1 = Intercept Enemy
    -- 2 = Invade Enemy Base
    -- 3 = Recover the Orb
    
-- Beastman Status
    -- 0 = Training
    -- 1 = Advancing
    -- 2 = Attacking
    -- 3 = Retreating
    -- 4 = Defending
    -- 5 = Preparing

-- Bitpacked region int (for the actual locations on the map, not the overview)
    -- 3 Least Significant Bits -- Beastman Status for that region
    -- 8 following bits -- Number of Forces
    -- 4 following bits -- Level
    -- 4 following bits -- Number of Archaic Mirrors
    -- 4 following bits -- Number of Prisoners
    -- 9 following bits -- No clear purpose

fields.incoming[0x05E] = L{
    {ctype='unsigned char',     label='Balance of Power'},                      -- 04   Bitpacked: xxww bbss  -- Unclear what the first two bits are for. Number stored is ranking (0-3)
    {ctype='unsigned char',     label='Tie Indicator'},                         -- 05   Not really sure how this works, but it gives the ] that indicate a tie. It always gives them between position 2 and 3 for me.
    {ctype='char[20]',          label='_unknown1'},                             -- 06   All Zeros, and changed nothing when 0xFF'd.
    {ctype='unsigned int',      label='Bitpacked Ronfaure Info'},               -- 1A
    {ctype='unsigned int',      label='Bitpacked Zulkheim Info'},               -- 1E   
    {ctype='unsigned int',      label='Bitpacked Norvallen Info'},              -- 22   
    {ctype='unsigned int',      label='Bitpacked Gustaberg Info'},              -- 26   
    {ctype='unsigned int',      label='Bitpacked Derfland Info'},               -- 2A   
    {ctype='unsigned int',      label='Bitpacked Sarutabaruta Info'},           -- 2E   
    {ctype='unsigned int',      label='Bitpacked Kolshushu Info'},              -- 32   
    {ctype='unsigned int',      label='Bitpacked Aragoneu Info'},               -- 36   
    {ctype='unsigned int',      label='Bitpacked Fauregandi Info'},             -- 3A   
    {ctype='unsigned int',      label='Bitpacked Valdeaunia Info'},             -- 3E   
    {ctype='unsigned int',      label='Bitpacked Qufim Info'},                  -- 42   
    {ctype='unsigned int',      label="Bitpacked Li'Telor Info"},               -- 46   
    {ctype='unsigned int',      label='Bitpacked Kuzotz Info'},                 -- 4A   
    {ctype='unsigned int',      label='Bitpacked Vollbow Info'},                -- 4E   
    {ctype='unsigned int',      label='Bitpacked Elshimo Lowlands Info'},       -- 52   
    {ctype='unsigned int',      label="Bitpacked Elshimo Uplands Info"},        -- 56   
    {ctype='unsigned int',      label="Bitpacked Tu'Lia Info"},                 -- 5A   
    {ctype='unsigned int',      label='Bitpacked Movapolos Info'},              -- 5E   
    {ctype='unsigned int',      label='Bitpacked Tavnazian Archipelago Info'},  -- 62   
    {ctype='char[32]',          label='_unknown2'},                             -- 66   All Zeros, and changed nothing when 0xFF'd.
    {ctype='unsigned char',     label="San d'Oria region bar"},                 -- 86   These indicate how full the current region's bar is (in percent).
    {ctype='unsigned char',     label="Bastok region bar"},                     -- 87   The Beastmen are assigned all leftover percentage points.
    {ctype='unsigned char',     label="Windurst region bar"},                   -- 88
    {ctype='char[3]',           label="_unknown3"},                             -- 89   Takes values, but altering them has no obvious impact
    {ctype='unsigned char',     label="Days to talley"},                        -- 8C   Number of days to the next conquest talley
    {ctype='char[3]',           label="_unknown4"},                             -- 8D   All Zeros, and changed nothing when 0xFF'd.
    {ctype='int',               label='Conquest Points'},                       -- 90
    {ctype='char[12]',          label="_unknown5"},                             -- 94   Mostly zeros and noticed no change when 0xFF'd.
    
-- These bytes are for the overview summary on the map.
    -- The two least significant bits code for the owner of the Astral Candescence.
    -- The next two bits indicate the current orders.
    -- The four most significant bits indicate the MMJ level.
    {ctype='unsigned char',     label="MMJ Level, Orders, and AC"},             -- A0
    
    -- Halvung is the 4 least significant bits.
    -- Arrapago is the 4 most significant bits.
    {ctype='unsigned char',     label="Halvung and Arrapago Level"},            -- A1
    {ctype='unsigned char',     label="Beastman Status (1) "},                  -- A2   The 3 LS bits are the MMJ Orders, next 3 bits are the Halvung Orders, top 2 bits are part of the Arrapago Orders
    {ctype='unsigned char',     label="Beastman Status (2) "},                  -- A3   The Least Significant bit is the top bit of the Arrapago orders. Rest of the byte doesn't seem to do anything?

-- These bytes are for the individual stronghold displays. See above!
    {ctype='unsigned int',      label='Bitpacked MMJ Info'},                    -- A4
    {ctype='unsigned int',      label='Bitpacked Halvung Info'},                -- A8
    {ctype='unsigned int',      label='Bitpacked Arrapago Info'},               -- AC
    
    {ctype='int',               label='Imperial Standing'},                     -- B0
}

-- Char Stats
fields.incoming[0x061] = L{
    {ctype='unsigned int',      label='Maximum HP'},                            -- 04
    {ctype='unsigned int',      label='Maximum MP'},                            -- 08
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 0C
    {ctype='unsigned char',     label='Main Job Level'},                        -- 0D
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 0E
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
    {ctype='signed short',      label='Lightning Resistance'},                  -- 38
    {ctype='signed short',      label='Light Resistance'},                      -- 3A
    {ctype='signed short',      label='Ice Resistance'},                        -- 3C
    {ctype='signed short',      label='Earth Resistance'},                      -- 3E
    {ctype='signed short',      label='Water Resistance'},                      -- 40
    {ctype='signed short',      label='Dark Resistance'},                       -- 42
    {ctype='unsigned short',    label='Title',           fn=title},             -- 44
    {ctype='unsigned short',    label='Nation rank'},                           -- 46
    {ctype='unsigned short',    label='Rank points',        fn=cap+{0xFFF}},    -- 48
    {ctype='unsigned short',    label='Home point',         fn=zone},           -- 4A
    {ctype='unsigned short',    label='_unknown1'},                             -- 4C   0xFF-ing this last region has no notable effect.
    {ctype='unsigned short',    label='_unknown2'},                             -- 4E
    {ctype='unsigned short',    label='_unknown3'},                             -- 50
    {ctype='unsigned short',    label='_unknown4'},                             -- 52   00 00 observed.
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
    {ctype='unsigned short',    label='Divine Magic',       fn=cskill},         -- C0
    {ctype='unsigned short',    label='Healing Magic',      fn=cskill},         -- C2
    {ctype='unsigned short',    label='Enhancing Magic',    fn=cskill},         -- C4
    {ctype='unsigned short',    label='Enfeebling Magic',   fn=cskill},         -- C6
    {ctype='unsigned short',    label='Elemental Magic',    fn=cskill},         -- C8
    {ctype='unsigned short',    label='Dark Magic',         fn=cskill},         -- CA
    {ctype='unsigned short',    label='Summoning Magic',    fn=cskill},         -- CC
    {ctype='unsigned short',    label='Ninjutsu',           fn=cskill},         -- CE
    {ctype='unsigned short',    label='Singing',            fn=cskill},         -- D0
    {ctype='unsigned short',    label='Stringed Instrument',fn=cskill},         -- D2
    {ctype='unsigned short',    label='Wind Instrument',    fn=cskill},         -- D4
    {ctype='unsigned short',    label='Blue Magic',         fn=cskill},         -- D6
    {ctype='unsigned short',    label='Geomancy',           fn=cskill},         -- D8
    {ctype='unsigned short',    label='Handbell',           fn=cskill},         -- DA
    {ctype='char[4]',           label='_dummy2'},                               -- DC
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

-- Set Update
-- This packet likely varies based on jobs, but currently I only have it worked out for Monstrosity.
-- It also appears in three chunks, so it's double-varying.
-- Packet was expanded in the March 2014 update and now includes a fourth packet, which contains CP values.

fields.incoming._mult[0x063] = {}
fields.incoming[0x063] = function(data)
    return fields.incoming._mult[0x063][data:sub(5,5):byte()]
end

fields.incoming._mult[0x063][0x02] = L{
    {ctype='unsigned short',    label='Order'},                                 -- 04
    {ctype='unsigned int',      label='_flags1'},                               -- 06
    {ctype='unsigned int',      label='_flags2'},                               -- 08   The 3rd bit of the last byte is the flag that indicates whether or not you are xp capped (blue levels)
}

fields.incoming._mult[0x063][0x03] = L{
    {ctype='unsigned short',    label='Order'},                                 -- 04
    {ctype='unsigned short',    label='_flags1'},                               -- 06   Consistently D8 for me
    {ctype='unsigned short',    label='_flags2'},                               -- 08   Vary when I change species
    {ctype='unsigned short',    label='_flags3'},                               -- 0A   Consistent across species
    {ctype='unsigned char',     label='Mon. Rank'},                             -- 0C   00 = Mon, 01 = NM, 02 = HNM
    {ctype='unsigned char',     label='_unknown1'},                             -- 0D   00
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E   00 00
    {ctype='unsigned short',    label='_unknown3'},                             -- 10   76 00
    {ctype='unsigned short',    label='Infamy'},                                -- 12
    {ctype='unsigned int',      label='_unknown2'},                             -- 14   00s
    {ctype='unsigned int',      label='_unknown3'},                             -- 18   00s
    {ctype='char[64]',          label='Instinct Bitfield 1'},                   -- 1C   See below
    -- Bitpacked 2-bit values. 0 = no instincts from that species, 1 == first instinct, 2 == first and second instinct, 3 == first, second, and third instinct.
    {ctype='char[128]',         label='Monster Level Char field'},              -- 5C   Mapped onto the item ID for these creatures. (00 doesn't exist, 01 is rabbit, 02 is behemoth, etc.)
}

fields.incoming._mult[0x063][0x04] = L{
    {ctype='unsigned short',    label='Order'},                                 -- 04
    {ctype='unsigned short',    label='_unknown1'},                             -- 06   B0 00
    {ctype='char[126]',         label='_unknown2'},                             -- 08   FF-ing has no effect.
    {ctype='unsigned char',     label='Slime Level'},                           -- 86
    {ctype='unsigned char',     label='Spriggan Level'},                        -- 87
    {ctype='char[12]',          label='Instinct Bitfield 3'},                   -- 88   Contains job/race instincts from the 0x03 set. Has 8 unused bytes. This is a 1:1 mapping.
    {ctype='char[32]',          label='Variants Bitfield'},                     -- 94   Does not show normal monsters, only variants. Bit is 1 if the variant is owned. Length is an estimation including the possible padding.
}

-- Repositioning
fields.incoming[0x065] = L{
-- This is identical to the spawn packet, but has 4 more unused bytes.
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 10
    {ctype='unsigned short',    label='Index',              fn=index},          -- 14
    {ctype='unsigned char',     label='_unknown1'},                             -- 16   1 observed. May indicate repositoning type.
    {ctype='unsigned char',     label='_unknown2'},                             -- 17   Unknown, but matches the same byte of a matching spawn packet
    {ctype='char[6]',           label='_unknown3'},                             -- 18   All zeros observed.
}

-- Pet Info
fields.incoming[0x067] = L{
-- The length of this packet is 24, 28, 36 or 40 bytes, featuring a 0, 4, 8, 12, or 16 byte name field.

-- The Mask seem to be a bitpacked combination of a mask indicating which information is updated and
--    a field indicating the length of the name in the packet.

-- The information below should probably be re-verified, but:
-- 44 07 is used for pets with names that are 4-7 characters (8 character field). It updates pet TP but not Owner Index.
-- 84 07 is used for pets with names that are 8-11 characters (12 character field). It updates pet TP but not Owner Index.
-- C4 07 is used for pets with even longer names (>11 characters, 16 character field). It updates pet TP but not Owner Index.
-- 44 08 is used for pets with extremely long names. It updates pet TP but not Owner Index.

-- 02 09 is sent regularly to update owner information (about yourself). This might contain information if you are charmed.
-- 03 05 is sent when summoning pets, Trust NPCs, etc.
-- 04 05 is sent when releasing pets (unknown for Trust NPCs)

    {ctype='unsigned short',    label='Mask'},                                  -- 04
    {ctype='unsigned short',    label='Pet Index',          fn=index},          -- 06
    {ctype='unsigned int',      label='Pet ID',             fn=id},             -- 08
    {ctype='unsigned short',    label='Owner Index',        fn=index},          -- 0C
    {ctype='unsigned char',     label='Current HP%',        fn=percent},        -- 0E
    {ctype='unsigned char',     label='Current MP%',        fn=percent},        -- 0F
    {ctype='unsigned short',    label='Pet TP%',            fn=percent},        -- 10   Multiplied by 10
    {ctype='unsigned short',    label='_unknown1'},                             -- 12
    {ctype='char*',             label='Pet Name'},                              -- 14   Packet expands to accommodate pet name length.
}

-- Synth Result
fields.incoming[0x06F] = L{
    {ctype='unsigned char',     label='Result',             fn=e+{'synth'}},    -- 04
    {ctype='signed char',       label='Quality'},                               -- 05
    {ctype='unsigned char',     label='Count'},                                 -- 06   Even set for fail (set as the NQ amount in that case)
    {ctype='unsigned char',     label='_junk1'},                                -- 07
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned short[8]', label='Lost Item',          fn=item},           -- 0A
    {ctype='unsigned char[4]',  label='Skill',              fn=skill},          -- 1A
    {ctype='unsigned char[4]',  label='Skillup',            fn=div+{10}},       -- 1E
    {ctype='unsigned short',    label='_junk2'},                                -- 22
}

-- Job Points
-- These packets are currently not used by the client in any detectable way.
-- The below pattern repeats itself for the entirety of the packet. There are 2 jobs per packet,
-- and 11 of these packets are sent at the moment in response to the first 0x0C0 outgoing packet since zoning.
-- This is how it works as of 3-19-14, and it is safe to assume that it will change in the future.
fields.incoming[0x08D] = L{
    {ctype='unsigned short',    label='Job Point ID'},                          -- 04   32 potential values for every job, which means you could decompose this into a value bitpacked with job ID if you wanted
    {ctype='bit[10]',           label='_unknown1'},                             -- 06   Always 1 in cases where the ID is set at the moment. Zeroing this has no effect.
    {ctype='bit[6]',            label='Current Level'},                         -- 07   Current enhancement for this job point ID
}

-- Campaign Map Info
-- fields.incoming[0x071]
-- Perhaps it's my lack of interest, but this (triple-ish) packet is nearly incomprehensible to me.
-- Does not appear to contain zone IDs. It's probably bitpacked or something.
-- Has a byte that seems to be either 02 or 03, but the packet is sent three times. There are two 02s.
-- The second 02 packet contains different information after the ~48th content byte.

types.alliance_member = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 00
    {ctype='unsigned short',    label='Index',              fn=index},          -- 04
    {ctype='unsigned short',    label='Flags',              fn=bin+{2}},        -- 06
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 08
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A
}

-- Alliance status update
fields.incoming[0x0C8] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04
    {ctype='char[3]',           label='_junk1'},                                -- 05
    {ref=types.alliance_member, count=18},                                      -- 08
    {ctype='char[24]',          label='_unknown2',          const=''},          -- E0   Always 0?
}

types.check_item = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 00
    {ctype='unsigned char',     label='Slot',               fn=slot},           -- 02
    {ctype='unsigned char',     label='_unknown1'},                             -- 03
    {ctype='char[24]',          label='ExtData',            fn=hex+{24}},       -- 04
}

-- Check data
fields.incoming._mult[0x0C9] = {}
fields.incoming[0x0C9] = function(data)
    return fields.incoming._mult[0x0C9].base + fields.incoming._mult[0x0C9][data:byte(0x0B, 0x0B)]
end

enums[0x0C9] = {
    [0x01] = 'Metadata',
    [0x03] = 'Equipment',
}

-- Common to all messages
fields.incoming._mult[0x0C9].base = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='Type',               fn=e+{0x0C9}},      -- 0A
}

-- Equipment listing
fields.incoming._mult[0x0C9][0x03] = L{
    {ctype='unsigned char',     label='Count'},                                 -- 0B
    {ref=types.check_item,      count_ref=0x0B},                                -- 0C
}

-- Metadata
-- The title needs to be somewhere in here, but not sure where, maybe bit packed?
fields.incoming._mult[0x0C9][0x01] = L{
    {ctype='char[3]',           label='_junk1'},                                -- 0B
    {ctype='unsigned char',     label='_unknown2'},                             -- 0E
    {ctype='unsigned char',     label='_unknown3'},                             -- 0F
    {ctype='unsigned short',    label='_unknown4'},                             -- 10
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 12
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 13
    {ctype='char[15]',          label='Linkshell',          enc=ls_name_msg},   -- 14   6-bit packed
    {ctype='unsigned char',     label='Main Job Level'},                        -- 23
    {ctype='unsigned char',     label='Sub Job Level'},                         -- 24
    {ctype='char[43]',          label='_unknown5'},                             -- 25   At least the first two bytes and the last twelve bytes are junk, possibly more
}

-- Bazaar Message
fields.incoming[0x0CA] = L{
    {ctype='int',               label='_unknown1'},                             -- 04   Could be characters starting the line - FD 02 02 18 observed
    {ctype='unsigned short',    label='_unknown2'},                             -- 08   Could also be characters starting the line - 01 FD observed
    {ctype='char[118]',         label='Bazaar Message'},                        -- 0A   Terminated with a vertical tab
    {ctype='char[16]',          label='Player Name'},                           -- 80
    {ctype='unsigned short',    label='_unknown3'},                             -- 90   C6 01 and 63 02 observed. Not player index.
    {ctype='unsigned short',    label='_unknown4'},                             -- 92   00 00 observed.
}

-- LS Message
fields.incoming[0x0CC] = L{
    {ctype='int',               label='_unknown1'},                             -- 04
    {ctype='char[128]',         label='Message'},                               -- 08
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 88
    {ctype='char[16]',          label='Player Name'},                           -- 8C
    {ctype='unsigned int',      label='Permissions'},                           -- 98
    {ctype='char[16]',          label='Linkshell',          enc=ls_name_msg},   -- 9C   6-bit packed
}

-- Found Item
fields.incoming[0x0D2] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Could be characters starting the line - FD 02 02 18 observed
                                                                                -- 04   Arcon: Only ever observed 0x00000001 for this
    {ctype='unsigned int',      label='Dropper',            fn=id},             -- 08
    {ctype='unsigned int',      label='Count'},                                 -- 0C   Takes values greater than 1 in the case of gil
    {ctype='unsigned short',    label='Item',               fn=item},           -- 10
    {ctype='unsigned short',    label='Dropper Index',      fn=index},          -- 12
    {ctype='unsigned char',     label='Index'},                                 -- 14   This is the internal index in memory, not the one it appears in in the menu
    {ctype='bool',              label='Old'},                                   -- 15   This is true if it's not a new drop, but appeared in the pool before you joined a party
    {ctype='unsigned char',     label='_unknown4',          const=0x00},        -- 16   Seems to always be 00
    {ctype='unsigned char',     label='_unknown5'},                             -- 17   Seemingly random, both 00 and FF observed, as well as many values in between
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 18
    {ctype='char[28]',          label='_unknown6'},                             -- AC   Always 0 it seems?
    {ctype='unsigned int',      label='_junk1'},                                -- 38
}

-- Item lot/drop
fields.incoming[0x0D3] = L{
    {ctype='unsigned int',      label='Highest Lotter',     fn=id},             -- 04
    {ctype='unsigned int',      label='Current Lotter',     fn=id},             -- 08
    {ctype='unsigned short',    label='Highest Lotter Index',fn=index},         -- 0C
    {ctype='unsigned short',    label='Highest Lot'},                           -- 0E
    {ctype='bit[15]',           label='Current Lotter Index',fn=index},         -- 10
    {ctype='bit[1]',            label='_unknown1'},                             -- 11   Always seems set
    {ctype='unsigned short',    label='Current Lot'},                           -- 12   0xFF FF if passing
    {ctype='unsigned char',     label='Index'},                                 -- 14
    {ctype='unsigned char',     label='Drop'},                                  -- 15   0 if no drop, 1 if dropped to player, 3 if floored
    {ctype='char[16]',          label='Highest Lotter Name'},                   -- 16
    {ctype='char[16]',          label='Current Lotter Name'},                   -- 26
    {ctype='char[6]',           label='_junk1'},                                -- 36
}

-- Party member update
fields.incoming[0x0DD] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0C
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10
    {ctype='unsigned short',    label='Flags',              fn=bin+{2}},        -- 14
    {ctype='unsigned short',    label='_unknown1'},                             -- 16
    {ctype='unsigned short',    label='Index',              fn=index},          -- 18
    {ctype='unsigned short',    label='_unknown2'},                             -- 1A
    {ctype='unsigned char',     label='_unknown3'},                             -- 1C
    {ctype='unsigned char',     label='HP%',                fn=percent},        -- 1D
    {ctype='unsigned char',     label='MP%',                fn=percent},        -- 1E
    {ctype='unsigned char',     label='_unknown4'},                             -- 1F
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 20
    {ctype='char*',             label='Name'},                                  -- 22
}

-- Char Update
fields.incoming[0x0DF] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0C
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10   Truncated, does not include the decimal value.
    {ctype='unsigned short',    label='Index',              fn=index},          -- 14
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 16
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 17
    {ctype='unsigned short',    label='_unknown1'},                             -- 18
    {ctype='unsigned short',    label='_unknown2'},                             -- 1A
    {ctype='unsigned int',      label='_unknown3'},                             -- 1C
}

-- Char Info
fields.incoming[0x0E2] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0A
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10
    {ctype='unsigned int',      label='_unknown1'},                             -- 14   Looks like it could be flags for something.
    {ctype='unsigned short',    label='Index',              fn=index},          -- 18
    {ctype='unsigned char',     label='_unknown2'},                             -- 1A
    {ctype='unsigned char',     label='_unknown3'},                             -- 1B
    {ctype='unsigned char',     label='_unknown4'},                             -- 1C
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 1D
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 1E
    {ctype='unsigned char',     label='_unknown5'},                             -- 1F
    {ctype='unsigned char',     label='_unknown6'},                             -- 20
    {ctype='unsigned char',     label='_unknown7'},                             -- 21   Could be an initialization for the name. 0x01 observed.
    {ctype='char*',             label='Name'},                                  -- 22   *   Maybe a base stat
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
    {ctype='unsigned char',     label='Type',               fn=e+{'ws mob'}},   -- 07
    {ctype='short',             label='X Offset',           fn=pixel},          -- 08   Offset on the map
    {ctype='short',             label='Y Offset',           fn=pixel},          -- 0A
    {ctype='char[16]',          label='Name'},                                  -- 0C   Slugged, may not extend all the way to 27. Up to 25 has been observed. This will be used if Type == 0
}

-- Widescan Track
fields.incoming[0x0F5] = L{
    {ctype='float',             label='X Position'},                            -- 04
    {ctype='float',             label='Z Position'},                            -- 08
    {ctype='float',             label='Y Position'},                            -- 0C
    {ctype='unsigned char',     label='_unknown1'},                             -- 10   Same value as _unknown1 of 0x0F4
    {ctype='unsigned char',     label='_padding1'},                             -- 11
    {ctype='unsigned short',    label='Index',              fn=index},          -- 12
    {ctype='unsigned int',      label='Status',             fn=e+{'ws track'}}, -- 14
}

-- Widescan Mark
fields.incoming[0x0F6] = L{
    {ctype='unsigned int',      label='Type',               fn=e+{'ws mark'}},  -- 04
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='_unknown1'},                             -- 0A
    {ctype='unsigned char',     label='_unknown2'},                             -- 0B
}

-- Furniture Interaction
fields.incoming[0x0FA] = L{
    {ctype='unsigned short',    label='Item ID'},                               -- 04
    {ctype='char[6]',           label='_unknown1'},                             -- 06  Always 00s for me
    {ctype='unsigned char',     label='Safe Slot'},                             -- 0C  Safe slot for the furniture being interacted with
    {ctype='char[3]',           label='_unknown2'},                             -- 0D  Takes values, but doesn't look particularly meaningful
}

-- Bazaar item listing
fields.incoming[0x105] = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 04
    {ctype='unsigned int',      label='Count'},                                 -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 0C
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0E
    {ctype='unsigned char',     label='Inventory Index'},                       -- 10   This is the seller's inventory index of the item
}

-- Bazaar Seller Info Packet
-- Information on the purchase sent to the buyer when they attempt to buy
-- something from a bazaar (whether or not they are successful)
fields.incoming[0x106] = L{
    {ctype='unsigned int',      label='Type',               fn=e+{'try'}},      -- 04
    {ctype='char[16]',          label='Name'},                                  -- 08
}

-- Bazaar closed
-- Sent when the bazaar closes while you're browsing it
-- This includes you buying the last item which leads to the message:
-- "Player's bazaar was closed midway through your transaction"
fields.incoming[0x107] = L{
    {ctype='char[16]',          label='Name'},                                  -- 04
}

-- Bazaar visitor
-- Sent when someone opens your bazaar
fields.incoming[0x108] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='Type',               fn=e+{'bazaar'}},   -- 08
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 0C   Always zero?
    {ctype='unsigned char',     label='_unknown2'},                             -- 0D   Possibly junk, often zero, sometimes random
    {ctype='unsigned short',    label='Index',              fn=index},          -- 0E
    {ctype='char[16]',          label='Name'},                                  -- 10
}

-- Bazaar Purchase Info Packet
-- Information on the purchase sent to the buyer when the purchase is successful.
fields.incoming[0x109] = L{
    {ctype='unsigned int',      label='Buyer ID',           fn=id},             -- 04
    {ctype='unsigned int',      label='Quantity'},                              -- 08
    {ctype='unsigned short',    label='Buyer Index',        fn=index},          -- 0C
    {ctype='unsigned short',    label='Bazaar Index',       fn=index},          -- 0E
    {ctype='char[16]',          label='Buyer Name'},                            -- 10
    {ctype='unsigned int',      label='_unknown1'},                             -- 20   Was 05 00 02 00 for me
}

-- Bazaar Buyer Info Packet
-- Information on the purchase sent to the seller when a sale is successful.
fields.incoming[0x10A] = L{
    {ctype='unsigned int',      label='Quantity'},                              -- 04
    {ctype='unsigned short',    label='Item ID'},                               -- 08
    {ctype='char[16]',          label='Buyer Name'},                            -- 0A
    {ctype='unsigned int',      label='_unknown1'},                             -- 1A   Was 00 00 00 00 for me
    {ctype='unsigned short',    label='_unknown2'},                             -- 1C   Was 64 00 for me. Seems to be variable length? Also got 32 32 00 00 00 00 00 00 once.
}

-- Bazaar Open Packet
-- Packet sent when you open your bazaar.
fields.incoming[0x10B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Was 00 00 00 00 for me
}

-- Sparks update packet
fields.incoming[0x110] = L{
    {ctype='unsigned short',    label='Sparks Total'},                          -- 04
    {ctype='unsigned short',    label='_unknown1'},                             -- 06   Sparks are currently capped at 50,000
}

types.roe_quest = L{
    {ctype='bit[12]',           label='RoE Quest ID'},                          -- 00:00
    {ctype='bit[20]',           label='RoE Quest Progress'},                    -- 01:04
}

-- Eminence Update
fields.incoming[0x111] = L{
    {ref=types.roe_quest,       count=16},                                      -- 04
}

-- RoE Quest Log
fields.incoming[0x112] = L{
    {ctype='char[128]',         label='RoE Quest Bitfield'},                    -- 04   See next line
    -- There's probably one bit to indicate that a quest can be undertaken and another
    --  that indicates whether it has been completed once. The meaning of the individual
    --  bits obviously varies with Order. RoE quests with storyline are in the Packet
    --  with Order == 3. Most normal quests are in Order == 0
    {ctype='unsigned int',      label='Order'},                                 -- 84   0,1,2,3
}

--Currency Info
fields.incoming[0x113] = L{
    {ctype='signed int',        label='Conquest Points (San d\'Oria)'},         -- 04
    {ctype='signed int',        label='Conquest Points (Bastok)'},              -- 08
    {ctype='signed int',        label='Conquest Points (Windurst)'},            -- 0C
    {ctype='unsigned short',    label='Beastman Seals'},                        -- 10
    {ctype='unsigned short',    label='Kindred Seals'},                         -- 12
    {ctype='unsigned short',    label='Kindred Crests'},                        -- 14
    {ctype='unsigned short',    label='High Kindred Crests'},                   -- 16
    {ctype='unsigned short',    label='Sacred Kindred Crests'},                 -- 18
    {ctype='unsigned short',    label='Ancient Beastcoins'},                    -- 1A
    {ctype='unsigned short',    label='Valor Points'},                          -- 1C
    {ctype='unsigned short',    label='Scylds'},                                -- 1E
    {ctype='signed int',        label='Guild Points (Fishing)'},                -- 20
    {ctype='signed int',        label='Guild Points (Woodworking)'},            -- 24
    {ctype='signed int',        label='Guild Points (Smithing)'},               -- 28
    {ctype='signed int',        label='Guild Points (Goldsmithing)'},           -- 2C
    {ctype='signed int',        label='Guild Points (Weaving)'},                -- 30
    {ctype='signed int',        label='Guild Points (Leathercraft)'},           -- 34
    {ctype='signed int',        label='Guild Points (Bonecraft)'},              -- 38
    {ctype='signed int',        label='Guild Points (Alchemy)'},                -- 3C
    {ctype='signed int',        label='Guild Points (Cooking)'},                -- 40
    {ctype='signed int',        label='Cinders'},                               -- 44
    {ctype='unsigned char',     label='Syngery Fewell (Fire)'},                 -- 48
    {ctype='unsigned char',     label='Syngery Fewell (Ice)'},                  -- 49
    {ctype='unsigned char',     label='Syngery Fewell (Wind)'},                 -- 4A
    {ctype='unsigned char',     label='Syngery Fewell (Earth)'},                -- 4B
    {ctype='unsigned char',     label='Syngery Fewell (Lightning)'},            -- 4C
    {ctype='unsigned char',     label='Syngery Fewell (Water)'},                -- 4D
    {ctype='unsigned char',     label='Syngery Fewell (Light)'},                -- 4E
    {ctype='unsigned char',     label='Syngery Fewell (Dark)'},                 -- 4F
    {ctype='signed int',        label='Ballista Points'},                       -- 50
    {ctype='signed int',        label='Fellow Points'},                         -- 54
    {ctype='unsigned short',    label='Chocobucks (San d\'Oria)'},              -- 58
    {ctype='unsigned short',    label='Chocobucks (Bastok)'},                   -- 5A
    {ctype='unsigned short',    label='Chocobucks (Windurst)'},                 -- 5C
    {ctype='short',             label='_unknown1'},                             -- 5E
    {ctype='signed int',        label='Research Marks'},                        -- 60
    {ctype='unsigned char',     label='Wizened Tunnel Worms'},                  -- 64
    {ctype='unsigned char',     label='Wizened Morion Worms'},                  -- 65
    {ctype='unsigned char',     label='Wizened Phantom Worms'},                 -- 66
    {ctype='char',              label='_unknown2'},                             -- 67
    {ctype='signed int',        label='Moblin Marbles'},                        -- 68
    {ctype='unsigned short',    label='Infamy'},                                -- 6C
    {ctype='unsigned short',    label='Prestige'},                              -- 6E
    {ctype='signed int',        label='Legion Points'},                         -- 70
    {ctype='signed int',        label='Sparks of Eminence'},                    -- 74
    {ctype='signed int',        label='Shining Stars'},                         -- 78
    {ctype='signed int',        label='Imperial Standing'},                     -- 7C
    {ctype='signed int',        label='Assault Points (Leujaoam Sanctum)'},     -- 80
    {ctype='signed int',        label='Assault Points (M.J.T.G.)'},             -- 84
    {ctype='signed int',        label='Assault Points (Lebros Cavern)'},        -- 88
    {ctype='signed int',        label='Assault Points (Periqia)'},              -- 8C
    {ctype='signed int',        label='Assault Points (Ilrusi Atoll)'},         -- 90
    {ctype='signed int',        label='Nyzul Tokens'},                          -- 94
    {ctype='signed int',        label='Zeni'},                                  -- 98
    {ctype='signed int',        label='Jettons'},                               -- 9C
    {ctype='signed int',        label='Therion Ichor'},                         -- A0
    {ctype='signed int',        label='Allied Notes'},                          -- A4
    {ctype='signed int',        label='Bayld'},                                 -- A8
    {ctype='unsigned short',    label='Kinetic Units'},                         -- AC
    {ctype='short',             label='_unknown3'},                             -- AE
    {ctype='unsigned short',    label='Obsidian Fragments'},                    -- B0
    {ctype='short',             label='_unknown4'},                             -- B2
    {ctype='signed int',        label='Lebondopt Wings'},                       -- B4
    {ctype='signed int',        label='Mweya Plasm Corpuscles'},                -- B8
    {ctype='signed int',        label='Cruor'},                                 -- BC
    {ctype='signed int',        label='Resistance Credits'},                    -- C0
    {ctype='signed int',        label='Dominion Notes'},                        -- C4
    {ctype='unsigned char',     label='5th Echelon Battle Trophies'},           -- C8
    {ctype='unsigned char',     label='4th Echelon Battle Trophies'},           -- C9
    {ctype='unsigned char',     label='3rd Echelon Battle Trophies'},           -- CA
    {ctype='unsigned char',     label='2nd Echelon Battle Trophies'},           -- CB
    {ctype='unsigned char',     label='1st Echelon Battle Trophies'},           -- CC
    {ctype='unsigned char',     label='Cave Conservation Points'},              -- CD
    {ctype='unsigned char',     label='Imperial Army ID Tags'},                 -- CE
    {ctype='unsigned char',     label='Op Credits'},                            -- CF
    {ctype='signed int',        label='Traverser Stones'},                      -- D0
    {ctype='signed int',        label='Voidstones'},                            -- D4
    {ctype='signed int',        label='Kupofried\'s Corundums'},                -- D8
    {ctype='unsigned char',     label='Coalition Imprimaturs'},                 -- DC
    {ctype='unsigned char',     label='Moblin Pheromone Sacks'},                -- DD
    {ctype='short',             label='_unknown5'},                             -- DE
    {ctype='int',               label='_unknown6'},                             -- F0
}

-- Fish Bite Info
fields.incoming[0x115] = L{
    {ctype='unsigned short',    label='_unknown1'},                             -- 04
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
    {ctype='unsigned short',    label='_unknown3'},                             -- 08
    {ctype='unsigned int',      label='Fish Bite ID'},                          -- 0A   Unique to the type of fish that bit
    {ctype='unsigned short',    label='_unknown4'},                             -- 0E
    {ctype='unsigned short',    label='_unknown5'},                             -- 10
    {ctype='unsigned short',    label='_unknown6'},                             -- 12
    {ctype='unsigned int',      label='Catch Key'},                             -- 14   This value is used in the catch key of the 0x110 packet when catching a fish
}

local sizes = {}
sizes.bool = 1
sizes.char = 1
sizes.short = 2
sizes.int = 4
sizes.long = 8
sizes.float = 4
sizes.double = 8

local function parse(fs, data, index, max)
    max = max == '*' and 0 or max or 1
    index = index or 4

    local res = L{}
    local count = 0
    local bitoffset = 0
    while index < #data do
        count = count + 1
        for field in fs:it() do
            if field.ctype then
                field = table.copy(field)
                local ctype, count_str = field.ctype:match('(.*)%[(%d+)%]')
                if count_str and ctype ~= 'char' and ctype ~= 'bit' then
                    field.ctype = ctype
                    local ext, size = parse(L{field}, data, index, count_str:number())
                    res = res + ext
                    index = index + size
                else
                    if max ~= 1 then
                        field.label = field.label .. ' ' .. count:string()
                    end

                    res:append(field)
                    if ctype == 'bit' then
                        local bits = count_str:number()
                        bitoffset = (bitoffset + bits) % 8
                        index = index + ((bitoffset + bits) / 8):floor()
                    else
                        index = index + sizes[field.ctype:match('(%a+)[^%a]*$')]
                    end
                end
            else
                local type_count = field.count
                if not type_count then
                    local byte_index = field.count_ref + 1
                    type_count = data:byte(byte_index, byte_index)
                end
                local ext, size = parse(field.ref, data, index, type_count)
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
    if type(f) == 'function' then
        f = f(data)
    end
    return f and data and parse(f, data) or f
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
