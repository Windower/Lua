--[[
    A collection of detailed packet field information.
]]

require('pack')
require('functions')
require('strings')
require('maths')
require('lists')
require('sets')
local bit = require('bit')

local fields = {}
fields.outgoing = {}
fields.incoming = {}

local func = {
    incoming = {},
    outgoing = {},
}

-- String decoding definitions
local ls_enc = {
    charset = T('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ':split()):update({
        [0] = '`',
        [60] = 0:char(),
        [63] = 0:char(),
    }),
    bits = 6,
    terminator = function(str)
        return (#str % 4 == 2 and 60 or 63):binary()
    end
}
local sign_enc = {
    charset = T('0123456798ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{':split()):update({
        [0] = 0:char(),
    }),
    bits = 6,
}

-- Function definitions. Used to display packet field information.
local res = require('resources')

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

local function invbool(val)
    return val == 0
end

local function div(denom, val)
    return val/denom
end

local function add(amount, val)
    return val + amount
end

local function sub(amount, val)
    return val - amount
end

local time
local utime
do
    local now = os.time()
    local h, m = (os.difftime(now, os.time(os.date('!*t', now))) / 3600):modf()

    local timezone = '%+.2d:%.2d':format(h, 60 * m)

    local fn = function(ts)
        return os.date('%Y-%m-%dT%H:%M:%S' .. timezone, ts)
    end

    time = function(ts)
        return fn(os.time() - ts)
    end

    utime = function(ts)
        return fn(ts)
    end

    bufftime = function(ts)
        return fn((ts / 60) + 572662306 + 1009810800)
    end
end

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

local function buff(val)
    return val ~= 0xFF and res.buffs[val].name or '-'
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

local function statuses(val)
    return res.statuses[val].name
end

local function srank(val)
    return res.synth_ranks[val].name
end

local function arecast(val)
    return res.ability_recasts[val].name
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
    return type(val) == 'string' and val:binary(' ') or val:binary():zfill(8*fill):chunks(8):reverse():concat(' ')
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
        [0x0F] = 'Synthing',
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

local e = function(t, val)
    return enums[t][val] or 'Unknown value for \'%s\': %s':format(t, tostring(val))
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
    {ctype='data[32]',          label='_unknown1'},                             -- 04   Always 00s?
}

-- Zone In 3
-- Likely triggers specific incoming packets.
-- Does not trigger any packets when randomly injected.
fields.outgoing[0x011] = L{
    {ctype='int',               label='_unknown1'},                             -- 04   Always 02 00 00 00?
}


-- Standard Client
fields.outgoing[0x015] = L{
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned short',    label='_junk1'},                                -- 10
    {ctype='unsigned short',    label='Run Count'},                             -- 12   Counter that indicates how long you've been running?
    {ctype='unsigned char',     label='Rotation',           fn=dir},            -- 14
    {ctype='unsigned char',     label='_flags1'},                               -- 15   Bit 0x04 indicates that maintenance mode is activated
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 16
    {ctype='unsigned int',      label='Timestamp',          fn=time_ms},        -- 18   Milliseconds
    {ctype='unsigned int',      label='_unknown3'},                             -- 1C
}

-- Update Request
fields.outgoing[0x016] = L{
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 04
    {ctype='unsigned short',    label='_junk1'},                                -- 06
}

-- NPC Race Error
fields.outgoing[0x017] = L{
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 04
    {ctype='unsigned short',    label='_unknown1'},                             -- 06
    {ctype='unsigned int',      label='NPC ID',                fn=id},          -- 08
    {ctype='data[6]',           label='_unknown2'},                             -- 0C
    {ctype='unsigned char',     label='Reported NPC type'},                     -- 12
    {ctype='unsigned char',     label='_unknown3'},                             -- 13
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
    [0x0E] = 'Cast Fishing Rod',
    [0x0F] = 'Switch target',
    [0x10] = 'Ranged attack',
    [0x12] = 'Dismount Chocobo',
    [0x13] = 'Tractor Dialogue',
    [0x14] = 'Zoning/Appear', -- I think, the resource for this is ambiguous.
    [0x19] = 'Monsterskill',
    [0x1A] = 'Mount',
}

-- Action
fields.outgoing[0x01A] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='Category',           fn=e+{'action'}},   -- 0A
    {ctype='unsigned short',    label='Param'},                                 -- 0C
    {ctype='unsigned short',    label='_unknown1',          const=0},           -- 0E
    {ctype='float',             label='X Offset'},                              -- 10 -- non-zero values only observed for geo spells cast using a repositioned subtarget
    {ctype='float',             label='Z Offset'},                              -- 14
    {ctype='float',             label='Y Offset'},                              -- 18
}

-- /volunteer
fields.outgoing[0x01E] = L{
    {ctype='char*',             label='Target Name'},                           -- 04  null terminated string. Length of name to the nearest 4 bytes.
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
    {ctype='unsigned char',     label='Current Index',      fn=invp+{0x08}},    -- 0A
    {ctype='unsigned char',     label='Target Index'},                          -- 0B  This byte is 0x52 when moving items between bags. It takes other values when manually sorting.
}

-- Translate
-- German and French translations appear to no longer be supported.
fields.outgoing[0x02B] = L{
    {ctype='unsigned char',     label='Starting Language'},                     -- 04   0 == JP, 1 == EN
    {ctype='unsigned char',     label='Ending Language'},                       -- 05   0 == JP, 1 == EN
    {ctype='unsigned short',    label='_unknown1',          const=0x0000},      -- 06   
    {ctype='char[64]',          label='Phrase'},                                -- 08   Quotation marks are removed. Phrase is truncated at 64 characters.
}

-- Trade request
fields.outgoing[0x032] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='data[2]',           label='_junk1'}                                 -- 0A
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
    {ctype='unsigned int',      label='Trade Count'}                            -- 08   Necessary to set if you are receiving items, comes from incoming packet 0x023
}

-- Trade offer
fields.outgoing[0x034] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned char',     label='Inventory Index',    fn=inv+{0}},        -- 0A
    {ctype='unsigned char',     label='Slot'},                                  -- 0F
}

-- Menu Item
fields.outgoing[0x036] = L{
-- Item order is Gil -> top row left-to-right -> bottom row left-to-right, but
-- they slide up and fill empty slots
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned int[9]',   label='Item Count'},                            -- 08
    {ctype='unsigned int',      label='_unknown1'},                             -- 2C
    {ctype='unsigned char[9]',  label='Item Index',       fn=inv+{0}},          -- 30   Gil has an Inventory Index of 0
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
    {ctype='data[3]',           label='_unknown3'}                              -- 11
}

-- Sort Item
fields.outgoing[0x03A] = L{
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
}

-- Blacklist (add/delete)
fields.outgoing[0x03D] = L{
    {ctype='int',               label='_unknown1'},                             -- 04  Looks like a player ID, but does not match the sender or the receiver.
    {ctype='char[16]',          label='Name'},                                  -- 08  Character name
    {ctype='bool',              label='Add/Remove'},                            -- 18  0 = add, 1 = remove
    {ctype='data[3]',           label='_unknown2'},                             -- 19  Values observed on adding but not deleting.
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
    {ctype='data[12]',          label='_unknown5'},                             -- 08  All 00s
    {ctype='unsigned int',      label='_unknown5'},                             -- 14  EC 00 00 00 observed. May be junk.
}

-- Delivery Box
fields.outgoing[0x04D] = L{
    {ctype='unsigned char',     label='Type'},                                  -- 04
    --

    -- Removing an item from the d-box sends type 0x08
    -- It then responds to the server's 0x4B (id=0x08) with a 0x0A type packet.
    -- Their assignment is the same, as far as I can see.
    {ctype='unsigned char',     label='_unknown1'},                             -- 05   01 observed
    {ctype='unsigned char',     label='Slot'},                                  -- 06
    {ctype='data[5]',           label='_unknown2'},                             -- 07   FF FF FF FF FF observed
    {ctype='data[20]',          label='_unknown3'},                             -- 0C   All 00 observed
}

enums['ah otype'] = {
    [0x04] = 'Sell item request',
    [0x05] = 'Check sales',
    [0x0A] = 'Open AH menu',
    [0x0B] = 'Sell item confirmation',
    [0x0C] = 'Stop sale',
    [0x0D] = 'Sale status confirmation',
    [0x0E] = 'Place bid',
    [0x10] = 'Item sold',
}

func.outgoing[0x04E] = {}
func.outgoing[0x04E].base = L{
    {ctype='unsigned char',     label='Type',               fn=e+{'ah otype'}}, -- 04
}

-- Sent when putting an item up for auction (request)
func.outgoing[0x04E][0x04] = L{
    {ctype='data[3]',           label='_unknown1'},                             -- 05
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 08
    {ctype='unsigned short',    label='Inventory Index',    fn=inv+{0}},        -- 0C
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0E
    {ctype='unsigned char',     label='Stack',              fn=invbool},        -- 10
    {ctype='char*',             label='_junk'},                                 -- 11
}

-- Sent when checking your sale status
func.outgoing[0x04E][0x05] = L{
    {ctype='char*',             label='_junk'},                                 -- 05
}

-- Sent when initially opening the AH menu
func.outgoing[0x04E][0x0A] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0xFF},        -- 05
    {ctype='char*',             label='_junk'},                                 -- 06
}

-- Sent when putting an item up for auction (confirmation)
func.outgoing[0x04E][0x0B] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='data[2]',           label='_unknown1'},                             -- 06
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 08
    {ctype='unsigned short',    label='Inventory Index',    fn=inv+{0}},        -- 0C
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E
    {ctype='unsigned char',     label='Stack',              fn=invbool},        -- 10
    {ctype='char*',             label='_junk'},                                 -- 11
}

-- Sent when stopping an item from sale
func.outgoing[0x04E][0x0C] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='char*',             label='_junk'},                                 -- 06
}

-- Sent after receiving the sale status list for each item
func.outgoing[0x04E][0x0D] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='char*',             label='_junk'},                                 -- 06
}

-- Sent when bidding on an item
func.outgoing[0x04E][0x0E] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='unsigned short',    label='_unknown3'},                             -- 06
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 08
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0C
    {ctype='unsigned short',    label='_unknown4'},                             -- 0E
    {ctype='bool',              label='Stack',              fn=invbool},        -- 10
    {ctype='char*',             label='_junk'},                                 -- 11
}

-- Sent when taking a sold item from the list
func.outgoing[0x04E][0x10] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='char*',             label='_junk'},                                 -- 06
}

-- Auction Interaction
fields.outgoing[0x04E] = function(data, type)
    type = type or data and data:byte(5)
    return func.outgoing[0x04E].base  + (func.outgoing[0x04E][type] or L{})
end

-- Equip
fields.outgoing[0x050] = L{
    {ctype='unsigned char',     label='Item Index',         fn=invp+{0x06}},    -- 04
    {ctype='unsigned char',     label='Equip Slot',         fn=slot},           -- 05
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 06
    {ctype='data[1]',           label='_junk1'}                                 -- 07
}

types.equipset = L{
    {ctype='unsigned char',     label='Inventory Index',    fn=invp+{0x0A}},    -- 00
    {ctype='unsigned char',     label='Equipment Slot',     fn=slot},           -- 01
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 02
    {ctype='unsigned char',     label='_padding1'},                             -- 03
}

func.outgoing[0x051] = {}
func.outgoing[0x051].base = L{
    {ctype='unsigned char',     label='Count'},                                 -- 04
    {ctype='unsigned char[3]',  label='_unknown1'},                             -- 05   Same as _unknown1 in outgoing 0x052
}

-- Equipset
fields.outgoing[0x051] = function(data, count)
    count = count or data:byte(5)

    return func.outgoing[0x051].base + L{
        -- Only the number given in Count will be properly populated, the rest is junk
        {ref=types.equipset,        count=count},                                   -- 08
        {ctype='data[%u]':format((16 - count) * 4), label='_junk1'},                -- 08 + 4 * count
    }
end

types.equipset_build = L{
    {ctype='boolbit',           label='Active'},                                -- 00
    {ctype='bit',               label='_unknown1'},                             -- 00
    {ctype='bit[6]',            label='Bag',                fn=bag},            -- 00
    {ctype='unsigned char',     label='Inventory Index'},                       -- 01
    {ctype='unsigned short',    label='Item',               fn=item},           -- 02
}

-- Equipset Build
fields.outgoing[0x052] = L{
    -- First 8 bytes are for the newly changed item
    {ctype='unsigned char',     label='New Equipment Slot', fn=slot},           -- 04
    {ctype='unsigned char[3]',  label='_unknown1'},                             -- 05
    {ref=types.equipset_build,  count=1},                                       -- 08
    -- The next 16 are the entire current equipset, excluding the newly changed item
    {ref=types.equipset_build,  lookup={res.slots, 0x00},   count=0x10},        -- 0C
}

types.lockstyleset = L{
    {ctype='unsigned char',     label='Inventory Index'},                       -- 00
    {ctype='unsigned char',     label='Equipment Slot',     fn=slot},           -- 01
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 02
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 03
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04
    {ctype='unsigned short',    label='_unknown3',          const=0x0000},      -- 06
}

-- lockstyleset
fields.outgoing[0x53] = L{
        -- First 4 bytes are a header for the set
        {ctype='unsigned char',     label='Count'},                             -- 04
        {ctype='unsigned char',     label='Type'},                              -- 05   0 = "Stop locking style", 1 = "Continue locking style", 3 = "Lock style in this way". Might be flags?
        {ctype='unsigned short',    label='_unknown1',      const=0x0000},      -- 06
        {ref=types.lockstyleset,    count=16},                                  -- 08
    }


-- End Synth
-- This packet is sent after receiving a result when synthesizing.
fields.outgoing[0x059] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Often 00 00 00 00, but 01 00 00 00 observed.
    {ctype='data[8]',           label='_junk1'}                                 -- 08   Often 00 00 00 00, likely junk from a non-zero'd buffer.
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
    {ctype='bool',              label='Automated Message'},                     -- 0E   1 if the response packet is automatically generated, 0 if it was selected by you
    {ctype='unsigned char',     label='_unknown2'},                             -- 0F
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 10
    {ctype='unsigned short',    label='Menu ID'},                               -- 12
}

-- Warp Request
fields.outgoing[0x05C] = L{
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 10   NPC that you are requesting a warp from
    {ctype='unsigned int',      label='_unknown1'},                             -- 14   01 00 00 00 observed
    {ctype='unsigned short',    label='Zone'},                                  -- 18
    {ctype='unsigned short',    label='Menu ID'},                               -- 1A
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 1C
    {ctype='unsigned char',     label='_unknown2',          const=1},           -- 1E
    {ctype='unsigned char',     label='Rotation'},                              -- 1F
}

-- Outgoing emote
fields.outgoing[0x05D] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08                      
    {ctype='unsigned char',     label='Emote',              fn=emote},          -- 0A
    {ctype='unsigned char',     label='Type'},                                  -- 0B  2 for motion, 0 otherwise
    {ctype='unsigned int',      label='_unknown1',          const=0},           -- 0C
}

-- Zone request
-- Sent when crossing a zone line.
fields.outgoing[0x05E] = L{
    {ctype='unsigned int',      label='Zone Line'},                             -- 04   This seems to be a fourCC consisting of the following chars:
                                                                                --      'z' (apparently constant)
                                                                                --      Region-specific char ('6' for Jeuno, '3' for Qufim, etc.)
                                                                                --      Zone-specific char ('u' for Port Jeuno, 't' for Lower Jeuno, 's' for Upper Jeuno, etc.)
                                                                                --      Zone line identifier ('4' for Port Jeuno > Qufim Island, '2' for Port Jeuno > Lower Jeuno, etc.)
    {ctype='data[12]',          label='_unknown1',          const=''},          -- 08
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

--"New" Key Item examination packet
fields.outgoing[0x064] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='byte[0x40]',        label='flags'},                                 -- 08  These correspond to a particular section of the 0x55 incoming packet
    {ctype='unsigned int',      label='_unknown1'},                             -- 48  This field somehow denotes which half-0x55-packet the flags corresponds to
}

-- Party invite
fields.outgoing[0x06E] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04   This is so weird. The client only knows IDs from searching for people or running into them. So if neither has happened, the manual invite will fail, as the ID cannot be retrieved.
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08   00 if target not in zone
    {ctype='unsigned char',     label='Alliance'},                              -- 0A   05 for alliance, 00 for party or if invalid alliance target (the client somehow knows..)
    {ctype='unsigned char',     label='_const1',            const=0x041},       -- 0B
}

-- Party leaving
fields.outgoing[0x06F] = L{
    {ctype='unsigned char',     label='Alliance'},                              -- 04   05 for alliance, 00 for party
    {ctype='data[3]',           label='_junk1'}                                 -- 05
}

-- Party breakup
fields.outgoing[0x070] = L{
    {ctype='unsigned char',     label='Alliance'},                              -- 04   02 for alliance, 00 for party
    {ctype='data[3]',           label='_junk1'}                                 -- 05
}

-- Kick
fields.outgoing[0x071] = L{
    {ctype='data[6]',           label='_unknown1'},                             -- 04  
    {ctype='unsigned char',     label='Kick Type'},                             -- 0A   0 for party, 1 for linkshell, 2 for alliance (maybe)
    {ctype='unsigned char',     label='_unknown2'},                             -- 0B
    {ctype='data[16]',          label='Member Name'}                            -- 0C   Null terminated string
}

-- Party invite response
fields.outgoing[0x074] = L{
    {ctype='bool',              label='Join',               fn=bool},           -- 04
    {ctype='data[3]',           label='_junk1'}                                 -- 05
}

--[[ -- Unnamed 0x76
-- Observed when zoning (sometimes). Probably triggers some information to be sent (perhaps about linkshells?)
fields.outgoing[0x076] = L{
    {ctype='unsigned char',     label='flag'},                                  -- 04   Only 01 observed
    {ctype='data[3]',           label='_junk1'},                                -- 05   Only 00 00 00 observed.
}]]

-- Change Permissions
fields.outgoing[0x077] = L{
    {ctype='char[16]',          label='Target Name'},                           -- 04   Name of the person to give leader to
    {ctype='unsigned char',     label='Party Type'},                            -- 14   00 = party, 01 = linkshell, 02 = alliance
    {ctype='unsigned short',    label='Permissions'},                           -- 15   01 for alliance leader, 00 for party leader, 03 for linkshell "to sack", 02 for linkshell "to pearl"
    {ctype='unsigned short',    label='_unknown1'},                             -- 16
}

-- Party list request (4 byte packet)
fields.outgoing[0x078] = L{
}

-- Guild NPC Buy
-- Sent when buying an item from a guild NPC
fields.outgoing[0x082] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08   
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 0A   
    {ctype='unsigned char',     label='Count'},                                 -- 0B   Number you are buying
}

-- NPC Buy Item
-- Sent when buying an item from a generic NPC vendor
fields.outgoing[0x083] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned short',    label='_unknown2'},                             -- 08   Redirection Index? When buying from a guild helper, this was the index of the real guild NPC.
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
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned char',     label='Inventory Index',    fn=inv+{0}},        -- 09   Inventory index of the same item
    {ctype='unsigned char',     label='_unknown3'},                             -- 0A   Always 0? Likely padding
}

-- NPC Sell confirm
-- Sent when confirming a sell of an item to an NPC
fields.outgoing[0x085] = L{
    {ctype='unsigned int',      label='_unknown1',          const=1},           -- 04   Always 1? Possibly a type
}

-- Synth
fields.outgoing[0x096] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04   Crystal ID? Earth = 0x02, Wind-break = 0x19?, Wind no-break = 0x2D?
    {ctype='unsigned char',     label='_unknown2'},                             -- 05
    {ctype='unsigned short',    label='Crystal',            fn=item},           -- 06
    {ctype='unsigned char',     label='Crystal Index',      fn=inv+{0}},        -- 08
    {ctype='unsigned char',     label='Ingredient count'},                      -- 09
    {ctype='unsigned short[8]', label='Ingredient',         fn=item},           -- 0A
    {ctype='unsigned char[8]',  label='Ingredient Index',   fn=inv+{0}},        -- 1A
    {ctype='unsigned short',    label='_junk1'},                                -- 22
}

-- /nominate or /proposal
fields.outgoing[0x0A0] = L{
    {ctype='unsigned char',     label='Packet Type'},                           -- 04  Not typical mapping. 0=Open poll (say), 1 = Open poll (party), 3 = conclude poll
    -- Just padding if the poll is being concluded.
    {ctype='char*',             label='Proposal'},                              -- 05  Proposal exactly as written. Space delimited with quotes and all. Null terminated.
}

-- /vote
fields.outgoing[0x0A1] = L{
    {ctype='unsigned char',     label='Option'},                                -- 04  Voting option
    {ctype='char*',             label='Character Name'},                        -- 05  Character name. Null terminated.
}

-- /random
fields.outgoing[0x0A2] = L{
    {ctype='int',               label='_unknown1'},                             -- 04  No clear purpose
}

-- Guild Buy Item
-- Sent when buying an item from a guild NPC
fields.outgoing[0x0AA] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04   
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 06   
    {ctype='unsigned char',     label='Count'},                                 -- 07   Number you are buying
}

-- Get Guild Inv List
-- It's unclear how the server figures out which guild you're asking about, but this triggers 0x83 Incoming.
fields.outgoing[0x0AB] = L{
}

-- Guild Sell Item
-- Sent when selling an item to a guild NPC
fields.outgoing[0x0AC] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04  
    {ctype='unsigned char',     label='_unknown1'},                             -- 06   
    {ctype='unsigned char',     label='Count'},                                 -- 07   Number you are selling
}

-- Get Guild Sale List
-- It's unclear how the server figures out which guild you're asking about, but this triggers 0x85 Incoming.
fields.outgoing[0x0AD] = L{
}

-- Speech
fields.outgoing[0x0B5] = L{
    {ctype='unsigned char',     label='Mode',               fn=chat},           -- 04
    {ctype='unsigned char',     label='GM',                 fn=bool},           -- 05
    {ctype='char*',             label='Message'},                               -- 06
}

-- Tell
fields.outgoing[0x0B6] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 04   00 for a normal tell -- Varying this does nothing.
    {ctype='char[15]',          label='Target Name'},                           -- 05
    {ctype='char*',             label='Message'},                               -- 14
}

-- Merit Point Increase
fields.outgoing[0x0BE] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x03},        -- 04   No idea what it is, but it's always 0x03 for me
    {ctype='unsigned char',     label='Flag'},                                  -- 05   1 when you're increasing a merit point. 0 when you're decreasing it.
    {ctype='unsigned short',    label='Merit Point'},                           -- 06   No known mapping, but unique to each merit point. Could be an int.
    {ctype='unsigned int',      label='_unknown2',          const=0x00000000},  -- 08
}

-- Job Point Increase
fields.outgoing[0x0BF] = L{
    {ctype='bit[5]',            label='Type'},                                  -- 04
    {ctype='bit[11]',           label='Job',                fn=job},            -- 04
    {ctype='unsigned short',    label='_junk1',             const=0x0000},      -- 06   No values seen so far
}

-- Job Point Menu
-- This packet has no content bytes
fields.outgoing[0x0C0] = L{
}

-- /makelinkshell
fields.outgoing[0x0C3] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04  
    {ctype='unsigned char',     label='Linkshell Number'},                      -- 05  
    {ctype='data[2]',           label='_junk1'}                                 -- 05
}

-- Equip Linkshell
fields.outgoing[0x0C4] = L{
    {ctype='unsigned short',    label='_unknown1'},                             -- 04  0x00 0x0F for me
    {ctype='unsigned char',     label='Inventory Slot ID'},                     -- 06  Inventory Slot that holds the linkshell
    {ctype='unsigned char',     label='Linkshell Number'},                      -- 07  Inventory Slot that holds the linkshell
    {ctype='data[16]',          label='String of unclear purpose'}              -- 08  Probably going to be used in the future system somehow. Currently "dummy"..string.char(0,0,0).."%s %s "..string.char(0,1)
}

-- Open Mog
fields.outgoing[0x0CB] = L{
    {ctype='unsigned char',     label='type'},                                  -- 04  1 = open mog, 2 = close mog
    {ctype='data[3]',           label='_junk1'}                                 -- 05
}

-- Party Marker Request
fields.outgoing[0x0D2] = L{
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 04
    {ctype='unsigned short',    label='_junk1'}                                 -- 06
}

-- Open Help Submenu
fields.outgoing[0x0D4] = L{
    {ctype='unsigned int',      label='Number of Opens'},                       -- 04  Number of times you've opened the submenu.
}

-- Check
fields.outgoing[0x0DD] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 0A
    {ctype='unsigned char',     label='Check Type'},                            -- 0C   00 = Normal /check, 01 = /checkname, 02 = /checkparam
    {ctype='data[3]',           label='_junk1'}                                 -- 0D
}

-- Search Comment
fields.outgoing[0x0E0] = L{
    {ctype='char[40]',          label='Line 1'},                                -- 04  Spaces (0x20) fill out any empty characters.
    {ctype='char[40]',          label='Line 2'},                                -- 2C  Spaces (0x20) fill out any empty characters.
    {ctype='char[40]',          label='Line 3'},                                -- 54  Spaces (0x20) fill out any empty characters.
    {ctype='data[4]',           label='_unknown1'},                             -- 7C  20 20 20 00 observed.
    {ctype='data[24]',          label='_unknown2'},                             -- 80  Likely contains information about the flags.
}

-- Get LS Message
fields.outgoing[0x0E1] = L{
    {ctype='data[136]',         label='_unknown1',          const=0x0},         -- 04
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

-- Declare Subregion
fields.outgoing[0x0F2] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x01},        -- 04
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 05
    {ctype='unsigned short',    label='Subregion Index'},                       -- 06
}

-- Unknown packet 0xF2
--[[fields.outgoing[0x0F2] = L{
    {ctype='unsigned char',     label='type'},                                  -- 04  Was always 01 for me
    {ctype='unsigned char',     label='_unknown1'},                             -- 05  Was always 00 for me
    {ctype='unsigned short',    label='Index',                  fn=index},      -- 07  Has always been the index of a synergy enthusiast or furnace for me
}]]

-- Widescan
fields.outgoing[0x0F4] = L{
    {ctype='unsigned char',     label='Flags'},                                 -- 04   1 when requesting widescan information. No other values observed.
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned short',    label='_unknown2'},                             -- 06
}

-- Widescan Track
fields.outgoing[0x0F5] = L{
    {ctype='unsigned short',    label='Index',                  fn=index},      -- 04 Setting an index of 0 stops tracking
    {ctype='unsigned short',    label='_junk1'},                                -- 06
}

-- Widescan Cancel
fields.outgoing[0x0F6] = L{
    {ctype='unsigned int',      label='_junk1'},                                -- 04 Always observed as 00 00 00 00
}

-- Place/Move Furniture
fields.outgoing[0x0FA] = L{
    {ctype='unsigned short',    label='Item',                   fn=item},       -- 04  00 00 just gives the general update
    {ctype='unsigned char',     label='Safe Index',             fn=inv+{1}},    -- 06
    {ctype='unsigned char',     label='X'},                                     -- 07  0 to 0x12
    {ctype='unsigned char',     label='Z'},                                     -- 08  0 to ?
    {ctype='unsigned char',     label='Y'},                                     -- 09  0 to 0x17
    {ctype='unsigned short',    label='_junk1'},                                -- 0A  00 00 observed
}

-- Remove Furniture
fields.outgoing[0x0FB] = L{
    {ctype='unsigned short',    label='Item',                   fn=item},       -- 04
    {ctype='unsigned char',     label='Safe Index',             fn=inv+{1}},    -- 06
    {ctype='unsigned char',     label='_junk1'},                                -- 07
}

-- Plant Flowerpot
fields.outgoing[0x0FC] = L{
    {ctype='unsigned short',    label='Flowerpot Item',         fn=item},       -- 04
    {ctype='unsigned short',    label='Seed Item',              fn=item},       -- 06
    {ctype='unsigned char',     label='Flowerpot Safe Index',   fn=inv+{1}},    -- 08
    {ctype='unsigned char',     label='Seed Safe Index',        fn=inv+{1}},    -- 09
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
    {ctype='unsigned short',    label='Flowerpot Item',         fn=item},       -- 04
    {ctype='unsigned char',     label='Flowerpot Safe Index',   fn=inv+{1}},    -- 06
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
    {ctype='unsigned short[12]',label='Instinct'},                              -- 10
    {ctype='unsigned char',     label='Name 1'},                                -- 28
    {ctype='unsigned char',     label='Name 2'},                                -- 29
    {ctype='char*',             label='_unknown'},                              -- 2A  -- All 00s for Monsters
}

-- Open Bazaar
-- Sent when you open someone's bazaar from the /check window
fields.outgoing[0x105] = L{
    {ctype='unsigned int',      label='Target',             fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
}

-- Bid Bazaar
-- Sent when you bid on an item in someone's bazaar
fields.outgoing[0x106] = L{
    {ctype='unsigned char',     label='Inventory Index'},                       -- 04   The seller's inventory index of the wanted item
    {ctype='data[3]',           label='_junk1'},                                -- 05
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
    {ctype='data[3]',           label='_junk1'},                                -- 05
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

-- Accept RoE Quest reward that was denied due to a full inventory
fields.outgoing[0x10E] = L{
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
    {ctype='data[3]',           label='_junk1'},                                -- 05
}

-- ROE quest log request
fields.outgoing[0x112] = L{
    {ctype='int',               label='_unknown1'},                             -- 04
}

-- Homepoint Map Trigger :: 4 bytes, sent when entering a specific zone's homepoint list to cause maps to appear.
fields.outgoing[0x114] = L{
}

-- Currency 2 Menu
fields.outgoing[0x115] = L{
}

-- Open Unity Menu :: Two of these are sent whenever I open my unity menu. The first one has a bool of 0 and the second of 1.
fields.outgoing[0x116] = L{
    {ctype='bool',              label='_unknown1'},                             -- 04
    {ctype='char[3]',           label='_unknown2'},                             -- 05   
}

-- Unity Ranking Results  :: Sent when I open my Unity Ranking Results menu. Triggers a Sparks Update packet and may trigger ranking packets that I could not record.
fields.outgoing[0x117] = L{
    {ctype='int',               label='_unknown2'},                             -- 04
}

-- Open Chat status
fields.outgoing[0x118] = L{
    {ctype='bool',              label='Chat Status'},                           -- 04   0 for Inactive and 1 for Active
    {ctype='char[3]',           label='_unknown2'},                             -- 05   
}

types.job_level = L{
    {ctype='unsigned char',     label='Level'},                                 -- 00
}

-- Zone update
fields.incoming[0x00A] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='_padding'},                              -- 0A     
    {ctype='unsigned char',     label='Heading',            fn=dir},            -- 0B -- 0B to 
    {ctype='float',             label='X'},                                     -- 0C
    {ctype='float',             label='Z'},                                     -- 10
    {ctype='float',             label='Y'},                                     -- 14
    {ctype='unsigned short',    label='Run Count'},                             -- 18
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 1A
    {ctype='unsigned char',     label='Movement Speed'},                        -- 1C   32 represents 100%
    {ctype='unsigned char',     label='Animation Speed'},                       -- 1D   32 represents 100%
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Status',             fn=statuses},       -- 1F
    {ctype='data[16]',          label='_unknown1'},                             -- 20
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 30
    {ctype='data[6]',           label='_unknown2'},                             -- 32
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
    {ctype='unsigned short',    label='Day Music'},                             -- 56
    {ctype='unsigned short',    label='Night Music'},                           -- 58
    {ctype='unsigned short',    label='Solo Combat Music'},                     -- 5A
    {ctype='unsigned short',    label='Party Combat Music'},                    -- 5C
    {ctype='data[4]',           label='_unknown4'},                             -- 5E
    {ctype='unsigned short',    label='Menu Zone'},                             -- 62   Only set if the menu ID is sent, used as the zone for menu responses (0x5b, 0x5c)
    {ctype='unsigned short',    label='Menu ID'},                               -- 64
    {ctype='unsigned short',    label='_unknown5'},                             -- 66
    {ctype='unsigned short',    label='Weather',            fn=weather},        -- 68
    {ctype='unsigned short',    label='_unknown6'},                             -- 6A
    {ctype='data[24]',          label='_unknown7'},                             -- 6C
    {ctype='char[16]',          label='Player Name'},                           -- 84
    {ctype='data[12]',          label='_unknown8'},                             -- 94
    {ctype='unsigned int',      label='Abyssea Timestamp',  fn=time},           -- A0
    {ctype='unsigned int',      label='_unknown9',          const=0x0003A020},  -- A4
    {ctype='data[2]',           label='_unknown10'},                            -- A8
    {ctype='unsigned short',    label='Zone model'},                            -- AA
    {ctype='data[8]',           label='_unknown11'},                            -- AC   0xAC is 2 for some zones, 0 for others
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- B4
    {ctype='unsigned char',     label='_unknown12'},                            -- B5
    {ctype='unsigned char',     label='_unknown13'},                            -- B6
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- B7
    {ctype='unsigned int',      label='_unknown14'},                            -- B8
    {ref=types.job_level,       lookup={res.jobs, 0x00},    count=0x10},        -- BC
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
    {ctype='data[20]',          label='_unknown15'},                            -- F0
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
    -- Byte 0x20: -- Mentor is somewhere in this byte
    -- 01 = None
    -- 02 = Deletes everyone
    -- 04 = Deletes everyone
    -- 08 = None
    -- 16 = None
    -- 32 = None
    -- 64 = None
    -- 128 = None


    -- Byte 0x21:
    -- 01 = None
    -- 02 = None
    -- 04 = None
    -- 08 = LFG
    -- 16 = Anon
    -- 32 = Turns your name orange
    -- 64 = Away
    -- 128 = None

    -- Byte 0x22:
    -- 01 = POL Icon, can target?
    -- 02 = no notable effect
    -- 04 = DCing
    -- 08 = Untargettable
    -- 16 = No linkshell
    -- 32 = No Linkshell again
    -- 64 = No linkshell again
    -- 128 = No linkshell again

    -- Byte 0x23:
    -- 01 = Trial Account
    -- 02 = Trial Account
    -- 04 = GM Mode
    -- 08 = None
    -- 16 = None
    -- 32 = Invisible models
    -- 64 = None
    -- 128 = Bazaar

    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='boolbit',           label='Update Position'},                       -- 0A:0 Position, Rotation, Target, Speed  
    {ctype='boolbit',           label='Update Status'},                         -- 1A:1 Not used for 0x00D
    {ctype='boolbit',           label='Update Vitals'},                         -- 0A:2 HP%, Status, Flags, LS color, "Face Flags"
    {ctype='boolbit',           label='Update Name'},                           -- 0A:3 Name
    {ctype='boolbit',           label='Update Model'},                          -- 0A:4 Race, Face, Gear models
    {ctype='boolbit',           label='Despawn'},                               -- 0A:5 Only set if player runs out of range or zones
    {ctype='boolbit',           label='_unknown1'},                             -- 0A:6
    {ctype='boolbit',           label='_unknown2'},                             -- 0A:6
    {ctype='unsigned char',     label='Heading',            fn=dir},            -- 0B
    {ctype='float',             label='X'},                                     -- 0C
    {ctype='float',             label='Z'},                                     -- 10
    {ctype='float',             label='Y'},                                     -- 14
    {ctype='bit[13]',           label='Run Count'},                             -- 18:0 Analogue to Run Count from outgoing 0x015
    {ctype='bit[3]',            label='_unknown3'},                             -- 19:5 Analogue to Run Count from outgoing 0x015
    {ctype='boolbit',           label='_unknown4'},                             -- 1A:0
    {ctype='bit[15]',           label='Target Index',       fn=index},          -- 1A:1
    {ctype='unsigned char',     label='Movement Speed'},                        -- 1C   32 represents 100%
    {ctype='unsigned char',     label='Animation Speed'},                       -- 1D   32 represents 100%
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Status',             fn=statuses},       -- 1F
    {ctype='unsigned int',      label='Flags',              fn=bin+{4}},        -- 20
    {ctype='unsigned char',     label='Linkshell Red'},                         -- 24
    {ctype='unsigned char',     label='Linkshell Green'},                       -- 25
    {ctype='unsigned char',     label='Linkshell Blue'},                        -- 26
    {ctype='unsigned char',     label='_unknown5'},                             -- 27   Probably junk from the LS color dword
    {ctype='data[0x1A]',        label='_unknown6'},                             -- 28   DSP notes that the 6th bit of byte 54 is the Ballista flag
    {ctype='unsigned char',     label='Indi Bubble'},                           -- 42   Geomancer (GEO) Indi spell effect on players. 0 is no effect.
    {ctype='unsigned char',     label='Face Flags'},                            -- 43   0, 3, 4, or 8
    {ctype='data[4]',           label='_unknown7'},                             -- 44
    {ctype='unsigned char',     label='Face'},                                  -- 48
    {ctype='unsigned char',     label='Race'},                                  -- 49
    {ctype='unsigned short',    label='Head'},                                  -- 4A
    {ctype='unsigned short',    label='Body'},                                  -- 4C
    {ctype='unsigned short',    label='Hands'},                                 -- 4E
    {ctype='unsigned short',    label='Legs'},                                  -- 50
    {ctype='unsigned short',    label='Feet'},                                  -- 52
    {ctype='unsigned short',    label='Main'},                                  -- 54
    {ctype='unsigned short',    label='Sub'},                                   -- 56
    {ctype='unsigned short',    label='Ranged'},                                -- 58
    {ctype='char*',             label='Character Name'},                        -- 5A -   *
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
    {ctype='float',             label='X'},                                     -- 0C
    {ctype='float',             label='Z'},                                     -- 10
    {ctype='float',             label='Y'},                                     -- 14
    {ctype='unsigned int',      label='Walk Count'},                            -- 18   Steadily increases until rotation changes. Does not reset while the mob isn't walking. Only goes until 0xFF1F.
    {ctype='unsigned short',    label='_unknown1',          fn=bin+{2}},        -- 1A
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 1E
    {ctype='unsigned char',     label='Status',             fn=statuses},       -- 1F   Status used to be 0x20
    {ctype='unsigned int',      label='_unknown2',          fn=bin+{4}},        -- 20
    {ctype='unsigned int',      label='_unknown3',          fn=bin+{4}},        -- 24
    {ctype='unsigned int',      label='_unknown4',          fn=bin+{4}},        -- 28   In Dynamis - Divergence statue's eye colors
    {ctype='unsigned int',      label='Claimer',            fn=id},             -- 2C
    {ctype='unsigned short',    label='_unknown5'},                             -- 30
    {ctype='unsigned short',    label='Model'},                                 -- 32
    {ctype='char*',             label='Name'},                                  -- 34 -   *
}

-- Incoming Chat
fields.incoming[0x017] = L{
    {ctype='unsigned char',     label='Mode',               fn=chat},           -- 04
    {ctype='bool',              label='GM'},                                    -- 05
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 06   Set only for Yell
    {ctype='char[0x10]',        label='Sender Name'},                           -- 08
    {ctype='char*',             label='Message'},                               -- 18   Max of 150 characters
}

-- Job Info
fields.incoming[0x01B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04   Observed value of 05
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 08
    {ctype='unsigned char',     label='Flag or Main Job Level?'},               -- 09
    {ctype='unsigned char',     label='Flag or Sub Job Level?'},                -- 0A
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 0B
    {ctype='bit[32]',           label='Sub/Job Unlock Flags'},                  -- 0C   Indicate whether subjob is unlocked and which jobs are unlocked. lsb of 0x0C indicates subjob unlock.
    {ctype='unsigned char',     label='_unknown3'},                             -- 10   Flag or List Start
    {ref=types.job_level,       lookup={res.jobs, 0x01},    count=0x0F},        -- 11
    {ctype='unsigned short',    label='Base STR'},                              -- 20  -- Altering these stat values has no impact on your equipment menu.
    {ctype='unsigned short',    label='Base DEX'},                              -- 22
    {ctype='unsigned short',    label='Base VIT'},                              -- 24
    {ctype='unsigned short',    label='Base AGI'},                              -- 26
    {ctype='unsigned short',    label='Base INT'},                              -- 28
    {ctype='unsigned short',    label='Base MND'},                              -- 2A
    {ctype='unsigned short',    label='Base CHR'},                              -- 2C
    {ctype='data[14]',          label='_unknown4'},                             -- 2E   Flags and junk? Hard to say. All 0s observed.
    {ctype='unsigned int',      label='Maximum HP'},                            -- 3C
    {ctype='unsigned int',      label='Maximum MP'},                            -- 40
    {ctype='unsigned int',      label='Flags'},                                 -- 44   Looks like a bunch of flags. Observed value if 01 00 00 00
    {ctype='unsigned char',     label='_unknown5'},                             -- 48   Potential flag to signal the list start. Observed value of 01
    {ref=types.job_level,       lookup={res.jobs, 0x01},    count=0x16},        -- 49
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
    {ctype='unsigned char',     label='Safe 2 Size'},                           -- 0D
    {ctype='unsigned char',     label='Wardrobe 2 Size'},                       -- 0E
    {ctype='unsigned char',     label='Wardrobe 3 Size'},                       -- 0F
    {ctype='unsigned char',     label='Wardrobe 4 Size'},                       -- 10
    {ctype='data[3]',           label='_padding1',          const=''},          -- 11
    {ctype='unsigned short',    label='_dupeInventory Size'},                   -- 14   These "dupe" sizes are set to 0 if the inventory disabled.
    {ctype='unsigned short',    label='_dupeSafe Size'},                        -- 16
    {ctype='unsigned short',    label='_dupeStorage Size'},                     -- 18   The accumulated storage from all items (uncapped) -1
    {ctype='unsigned short',    label='_dupeTemporary Size'},                   -- 1A
    {ctype='unsigned short',    label='_dupeLocker Size'},                      -- 1C
    {ctype='unsigned short',    label='_dupeSatchel Size'},                     -- 2E
    {ctype='unsigned short',    label='_dupeSack Size'},                        -- 20
    {ctype='unsigned short',    label='_dupeCase Size'},                        -- 22
    {ctype='unsigned short',    label='_dupeWardrobe Size'},                    -- 24
    {ctype='unsigned short',    label='_dupeSafe 2 Size'},                      -- 26
    {ctype='unsigned short',    label='_dupeWardrobe 2 Size'},                  -- 28
    {ctype='unsigned short',    label='_dupeWardrobe 3 Size'},                  -- 2A   This is not set to 0 despite being disabled for whatever reason
    {ctype='unsigned short',    label='_dupeWardrobe 4 Size'},                  -- 2C   This is not set to 0 despite being disabled for whatever reason
    {ctype='data[6]',          label='_padding2',          const=''},           -- 2E
}

-- Finish Inventory
fields.incoming[0x01D] = L{
    {ctype='unsigned char',     label='Flag',               const=0x01},        -- 04
    {ctype='data[3]',           label='_junk1'},                                -- 06
}

-- Modify Inventory
fields.incoming[0x01E] = L{
    {ctype='unsigned int',      label='Count'},                                 -- 04
    {ctype='unsigned char',     label='Bag',                fn=bag},            -- 08
    {ctype='unsigned char',     label='Index',              fn=inv+{0}},        -- 09
    {ctype='unsigned char',     label='Status',             fn=e+{'itemstat'}}, -- 0A
    {ctype='unsigned char',     label='_junk1'},                                -- 0B
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
    {ctype='data[24]',          label='ExtData',            fn='...':fn()},     -- 11
    {ctype='data[3]',           label='_junk1'},                                -- 29
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
    {ctype='data[24]',          label='ExtData'},                               -- 0E
    {ctype='data[2]',           label='_junk1'},                                -- 26
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
    {ctype='data[1]',           label='_unknown1',          const=0x00},        -- 04
    {ctype='unsigned char',     label='Slot'},                                  -- 05   Corresponds to the slot IDs of the previous incoming packet's Item Update chunks for active Inventory.
    {ctype='data[22]',          label='_unknown2',          const=0},           -- 06
}

-- String Message
fields.incoming[0x027] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04   0x0112413A in Omen, 0x010B7083 in Legion, Layer Reserve ID for Ambuscade queue, 0x01046062 for Chocobo circuit
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 08   0x013A in Omen, 0x0083 in Legion , Layer Reserve Index for Ambuscade queue, 0x0062 for Chocobo circuit
    {ctype='unsigned short',    label='Message ID',         fn=sub+{0x8000}},            -- 0A   -0x8000
    {ctype='unsigned int',      label='Type'},                                  -- 0C   0x04 for Fishing/Salvage, 0x05 for Omen/Legion/Ambuscade queue/Chocobo Circuit
    {ctype='unsigned int',      label='Param 1'},                               -- 10   Parameter 0 on the display messages dat files
    {ctype='unsigned int',      label='Param 2'},                               -- 14   Parameter 1 on the display messages dat files
    {ctype='unsigned int',      label='Param 3'},                               -- 18   Parameter 2 on the display messages dat files
    {ctype='unsigned int',      label='Param 4'},                               -- 1C   Parameter 3 on the display messages dat files
    {ctype='char[16]',          label='Player Name'},                           -- 20
    {ctype='data[16]',          label='_unknown6'},                             -- 30
    {ctype='char[16]',          label='_dupePlayer Name'},                      -- 40
    {ctype='data[32]',          label='_unknown7'},                             -- 50
}

-- Action
func.incoming[0x028] = {}
fields.incoming[0x028] = function()
    local self = func.incoming[0x028]

    -- start and length are both in bits
    local extract = function(data, start, length)
        return data:unpack('b' .. length, (start / 8):floor() + 1, start % 8 + 1)
    end

    -- All values here are in bits
    local add_effect_offset = 85
    local add_effect_size = 37
    local spike_effect_size = 34
    local add_action = function(data, pos)
        action = L{}
        action:extend(self.action_base)

        action:extend(self.add_effect_base)
        pos = pos + add_effect_offset
        local has_add_effect = extract(data, pos, 1) == 1
        pos = pos + 1
        if has_add_effect then
            action:extend(self.add_effect_body)
            pos = pos + add_effect_size
        end

        action:extend(self.spike_effect_base)
        local has_spike_effect = extract(data, pos, 1) == 1
        pos = pos + 1
        if has_spike_effect then
            action:extend(self.spike_effect_body)
            pos = pos + spike_effect_size
        end

        return action, pos
    end

    local action_count_offset = 32;
    local add_target = function(data, pos)
        local target = L{}
        target:extend(self.target_base:copy())

        pos = pos + action_count_offset
        local action_count = extract(data, pos, 4)
        pos = pos + 4
        for i = 1, action_count do
            local action
            action, pos = add_action(data, pos)

            action = action:copy():map(function(field)
                field.label = 'Action %u %s':format(i, field.label)
                return field
            end)
            target:extend(action)
        end

        return target, pos
    end

    local target_count_offset = 72
    local first_target_offset = 150
    return function(data)
        local fields = self.base:copy()
        local target_count = extract(data, target_count_offset, 10)
        pos = first_target_offset
        for i = 1, target_count do
            local target
            target, pos = add_target(data, pos)

            target = target:copy():map(function(field)
                field.label = 'Target %u %s':format(i, field.label)
                return field
            end)
            fields:extend(target)
        end

        return fields
    end
end()

enums.action_in = {
    [1] = 'Melee attack',
    [2] = 'Ranged attack finish',
    [3] = 'Weapon Skill finish',
    [4] = 'Casting finish',
    [5] = 'Item finish',
    [6] = 'Job Ability',
    [7] = 'Weapon Skill start',
    [8] = 'Casting start',
    [9] = 'Item start',
    [11] = 'NPC TP finish',
    [12] = 'Ranged attack start',
    [13] = 'Avatar TP finish',
    [14] = 'Job Ability DNC',
    [15] = 'Job Ability RUN',
}

func.incoming[0x028].base = L{
    {ctype='unsigned char',     label='Size'},                                  -- 04
    {ctype='unsigned int',      label='Actor',              fn=id},             -- 05
    {ctype='bit[10]',           label='Target Count'},                          -- 09:0
    {ctype='bit[4]',            label='Category',           fn=e+{'action_in'}},-- 0A:2
    {ctype='bit[16]',           label='Param'},                                 -- 0C:6
    {ctype='bit[16]',           label='_unknown1'},                             -- 0E:6
    {ctype='bit[32]',           label='Recast'},                                -- 10:6
}

func.incoming[0x028].target_base = L{
    {ctype='bit[32]',           label='ID',                 fn=id},             -- 00:0
    {ctype='bit[4]',            label='Action Count'},                          -- 04:0
}

func.incoming[0x028].action_base = L{
    {ctype='bit[5]',            label='Reaction'},                              -- 00:0
    {ctype='bit[11]',           label='Animation'},                             -- 00:5
    {ctype='bit[5]',            label='Effect'},                                -- 02:0
    {ctype='bit[6]',            label='Stagger'},                               -- 02:5
    {ctype='bit[17]',           label='Param'},                                 -- 03:3
    {ctype='bit[10]',           label='Message'},                               -- 06:2
    {ctype='bit[31]',           label='_unknown'},                              -- 07:4 --Message Modifier? If you get a complete (Resist!) this is set to 2 otherwise a regular Resist is 0.
}

func.incoming[0x028].add_effect_base = L{
    {ctype='boolbit',           label='Has Added Effect'},                      -- 00:0
}

func.incoming[0x028].add_effect_body = L{
    {ctype='bit[6]',            label='Added Effect Animation'},                -- 00:0
    {ctype='bit[4]',            label='Added Effect Effect'},                   -- 00:6
    {ctype='bit[17]',           label='Added Effect Param'},                    -- 01:2
    {ctype='bit[10]',           label='Added Effect Message'},                  -- 04:1
}

func.incoming[0x028].spike_effect_base = L{
    {ctype='boolbit',           label='Has Spike Effect'},                      -- 00:0
}

func.incoming[0x028].spike_effect_body = L{
    {ctype='bit[6]',            label='Spike Effect Animation'},                -- 00:0
    {ctype='bit[4]',            label='Spike Effect Effect'},                   -- 00:6
    {ctype='bit[14]',           label='Spike Effect Param'},                    -- 01:2
    {ctype='bit[10]',           label='Spike Effect Message'},                  -- 03:0
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


--[[ 0x2A can be triggered by knealing in the right areas while in the possession of a VWNM KI:
    Field1 will be lights level:
    0 = 'Tier 1', -- faintly/feebly depending on whether it's outside of inside Abyssea
    1 = 'Tier 2', -- softly
    2 = 'Tier 3', -- solidly. Highest Tier in Abyssea
    3 = 'Tier 4', --- strongly
    4 = 'Tier 5', -- very strongly.  Unused currently
    5 = 'Tier 6', --- furiously.  Unused currently
    - But if there are no mobs left in area, or no mobs nearby, field1 will be the KeyItem#
    1253 = 'Clear Abyssite'
    1254 = 'Colorful Abyssite'
    1564 = 'Clear Demilune Abyssite'
    etc.

    Field2 will be direction:
    0 = 'East'
    1 = 'Southeast'
    2 = 'South'
    3 = 'Southwest'
    4 = 'West'
    5 = 'Northwest'
    6 = 'North'
    7 = 'Northeast'

    Field3 will be distance. When there are no mobs, this value is set to 300000

    Field4 will be KI# of the abyssite used. Ex:
    1253 = 'Clear Abyssite'
    1254 = 'Colorful Abyssite'
    1564 = 'Clear Demilune Abyssite'
    etc.
]]

--[[  0x2A can also be triggered by buying/disposing of a VWNM KI from an NPC:
      Index/ID field will be those of the NPC
      Field1 will be 1000 (gil) when acquiring in Jueno, 300 (cruor) when acquiring in Abyssea
      Field2 will be the KI# acquired
      Fields are used slighly different when dropping the KI using the NPC.
]]

--[[  0x2A can also be triggered by spending cruor by buying non-vwnm related items, or even activating/using Flux
      Field1 will be the amount of cruor spent
]]
      
     
--[[ 0x2A can also be triggered by zoning into Abyssea:
     Field1 will be set to your remaining time. 5 at first, then whatever new value when acquiring visiting status.
     0x2A will likely be triggered as well when extending your time limit. Needs verification.
]]


--[[ 0x2A can be triggered sometimes when zoning into non-Abyssea:
     Not sure what it means.
]]

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

-- Mog House Menu
fields.incoming[0x02E] = L{}                                                    -- Seems to contain no fields. Just needs to be sent to client to open.

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

-- Synth List / Synth Recipe
--[[ This packet is used for list of recipes, but also for details of a specific recipe.

   If you ask the guild NPC that provides regular Image Suppor for recipes, 
   s/he will give you a list of recipes, fields are as follows:
   Field1-2: NPC ID
   Field3: NPC Index
   Field4-6: Unknown
   Field7-22: Item ID of recipe
   Field23: Unknown
   Field24: Usually Item ID of the recipe on next page


   If you ask a guild NPC for a specific recipe, fields are as follows:   
   field1: item to make (item id)
   field2,3,4: sub-crafts needed. Note that main craft will not be listed.
      1 = woodworking
      2 = smithing
      3 = goldsmithing
      4 = clothcraft    
      5 = leatherworking
      6 = bonecraft
      7 = Alchemy
      8 = Cooking
   field5: crystal (item id)
   field6: KeyItem needed, if any (in Big Endian)
   field7-14: material required (item id)
   field15-22: qty for each material above.
   field23-24: Unknown   
 ]]
fields.incoming[0x031] = L{
    {ctype='unsigned short[24]',    label='Field'},                             -- 04    
}

-- NPC Interaction Type 1
fields.incoming[0x032] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 08
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 0A
    {ctype='unsigned short',    label='Menu ID'},                               -- 0C   Seems to select between menus within a zone
    {ctype='unsigned short',    label='_unknown1'},                             -- 0E   00 for me
    {ctype='unsigned char',     label='_dupeZone',          fn=zone},           -- 10
    {ctype='data[3]',           label='_junk1'},                                -- 11   Always 00s for me
}

-- String NPC Interaction
fields.incoming[0x033] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 08
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 0A
    {ctype='unsigned short',    label='Menu ID'},                               -- 0C   Seems to select between menus within a zone
    {ctype='unsigned short',    label='_unknown1'},                             -- 0E   00 00 or 08 00 for me
    {ctype='char[16]',          label='NPC Name'},                              -- 10
    {ctype='char[16]',          label='_dupeNPC Name1'},                        -- 20
    {ctype='char[16]',          label='_dupeNPC Name2'},                        -- 30
    {ctype='char[16]',          label='_dupeNPC Name3'},                        -- 40
    {ctype='char[32]',          label='Menu Parameters'},                       -- 50   The way this information is interpreted varies by menu.
}

-- NPC Interaction Type 2
fields.incoming[0x034] = L{
    {ctype='unsigned int',      label='NPC',                fn=id},             -- 04
    {ctype='data[32]',          label='Menu Parameters'},                       -- 08   
    {ctype='unsigned short',    label='NPC Index',          fn=index},          -- 28
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 2A
    {ctype='unsigned short',    label='Menu ID'},                               -- 2C   Seems to select between menus within a zone
    {ctype='unsigned short',    label='_unknown1'},                             -- 2E   Ususually 8, but often not for newer menus
    {ctype='unsigned short',    label='_dupeZone',          fn=zone},           -- 30
    {ctype='data[2]',           label='_junk1'},                                -- 31   Always 00s for me
}

--- When messages are fishing related, the player is the Actor.
--- For some areas, the most significant bit of the message ID is set sometimes.
-- NPC Chat
fields.incoming[0x036] = L{
    {ctype='unsigned int',      label='Actor',                fn=id},             -- 04
    {ctype='unsigned short',    label='Actor Index',          fn=index},          -- 08
    {ctype='bit[15]',           label='Message ID'},                              -- 0A
    {ctype='bit',               label='_unknown1'},                               -- 0B
    {ctype='unsigned int',      label='_unknown2'},                               -- 0C  Probably junk
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

--[[ _flags1: The structure here looks similar to byte 0x33 of 0x00D, but left shifted by 1 bit
    -- 0x0001 -- Despawns your character
    -- 0x0002 -- Also despawns your character, and may trigger an outgoing packet to the server (which triggers an incoming 0x037 packet)
    -- 0x0004 -- No obvious effect
    -- 0x0008 -- No obvious effect
    -- 0x0010 -- LFG flag
    -- 0x0020 -- /anon flag - blue name
    -- 0x0040 -- orange name?
    -- 0x0080 -- Away flag
    -- 0x0100 -- No obvious effect
    -- 0x0200 -- No obvious effect
    -- 0x0400 -- No obvious effect
    -- 0x0800 -- No obvious effect
    -- 0x1000 -- No obvious effect
    -- 0x2000 -- No obvious effect
    -- 0x4000 -- No obvious effect
    -- 0x8000 -- No obvious effect
    
    _flags2:
    -- 0x01 -- POL Icon :: Actually a flag, overrides everything else but does not affect name color
    -- 0x02 -- No obvious effect
    -- 0x04 -- Disconnection icon :: Actually a flag, overrides everything but POL Icon
    -- 0x08 -- No linkshell
    -- 0x0A -- No obvious effect
    
    -- 0x10 -- No linkshell
    -- 0x20 -- Trial account icon
    -- 0x40 -- Trial account icon
    -- 0x60 -- POL Icon (lets you walk through NPCs/PCs)
    -- 0x80 -- GM mode
    -- 0xA0 -- GM mode
    -- 0xC0 -- GM mode
    -- 0xE0 -- SGM mode
    -- No statuses differentiate based on 0x10
    -- Bit 0x20 + 0x40 makes 0x60, which is different.
    -- Bit 0x80 overpowers those bits
    -- Bit 0x80 combines with 0x04 and 0x02 to make SGM.
    -- These are basically flags, but they can be combined to mean different things sometimes.
    
    _flags3:
    -- 0x10 -- No obvious effect
    -- 0x20 -- Event mode? Can't activate the targeting cursor but can still spin the camera
    -- 0x40 -- No obvious effect
    -- 0x80 -- Invisible model
    
    _flags4:
    -- 0x02 -- No obvious effect
    -- 0x04 -- No obvious effect
    -- 0x08 -- No obvious effect
    -- 0x10 -- No obvious effect
    -- 0x20 -- Bazaar icon
    -- 0x40 -- Event status again? Can't activate the targeting cursor but can move the camera.
    -- 0x80 -- No obvious effects
    
    _flags5:
    -- 0x01 -- No obvious effect
    -- 0x02 -- No obvious effect
    -- 0x04 -- Autoinvite icon
    
    _flags6:
    -- 0x08 -- Terror flag
    -- 0x10 -- No obvious effect
    
    Ballista stuff:
    -- 0x0020 -- No obvious effect
    -- 0x0040 -- San d'Oria ballista flag
    -- 0x0060 -- Bastok ballista flag
    -- 0x0080 -- Windurst Ballista flag
    -- 0x0100 -- Participation icon?
    -- 0x0200 -- Has some effect
    -- 0x0400 -- I don't know anything about ballista
    -- 0x0800 -- and I still don't D:<
    -- 0x1000 -- and I still don't D:<
    
    _flags7:
    -- 0x0020 -- No obvious effect
    -- 0x0040 -- Individually, this bit has no effect. When combined with 0x20, it prevents you from returning to a walking animation after you stop (sliding along the ground while bound)
    -- 0x0080 -- No obvious effect
    -- 0x0100 -- No obvious effect
    -- 0x0200 -- Trial Account emblem
    -- 0x0400 -- No obvious effect
    -- 0x0800 -- Question mark icon
    -- 0x1000 -- Mentor icon
]]
fields.incoming[0x037] = L{
    {ctype='unsigned char[32]', label='Buff',               fn=buff},           -- 04
    {ctype='unsigned int',      label='Player',             fn=id},             -- 24
    {ctype='unsigned short',    label='_flags1'},                               -- 28   Called "Flags" on the old dev wiki. Second byte might not be part of the flags, actually.
    {ctype='unsigned char',     label='HP %',               fn=percent},        -- 2A   
    {ctype='bit[8]',            label='_flags2'},                               -- 2B   
    {ctype='bit[12]',           label='Movement Speed/2'},                      -- 2C   Player movement speed
    {ctype='bit[4]',            label='_flags3'},                               -- 2D
    {ctype='bit[9]',            label='Yalms per step'},                        -- 2E   Determines how quickly your animation walks
    {ctype='bit[7]',            label='_flags4'},                               -- 2F
    {ctype='unsigned char',     label='Status',             fn=statuses},       -- 30
    {ctype='unsigned char',     label='LS Color Red'},                          -- 31
    {ctype='unsigned char',     label='LS Color Green'},                        -- 32
    {ctype='unsigned char',     label='LS Color Blue'},                         -- 33
    {ctype='bit[3]',            label='_flags5'},                               -- 34
    {ctype='bit[16]',           label='Pet Index'},                             -- 34   From 0x08 of byte 0x34 to 0x04 of byte 0x36
    {ctype='bit[2]',            label='_flags6'},                               -- 36    
    {ctype='bit[9]',            label='Ballista Stuff'},                        -- 36   The first few bits seem to determine the icon, but the icon appears to be tied to the type of fight, so it's more than just an icon.
    {ctype='bit[8]',            label='_flags7'},                               -- 37   This is probably tied up in the Ballista stuff too
    {ctype='bit[26]',           label='_unknown1'},                             -- 38   No obvious effect from any of these
    {ctype='unsigned int',      label='Time offset?',       fn=time},           -- 3C   For me, this is the number of seconds in 66 hours
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 40   This is 32 years off of JST at the time the packet is sent.
    {ctype='data[8]',           label='_unknown3'},                             -- 44
    {ctype='data[8]',           label='Bit Mask'},                              -- 4C
    {ctype='data[4]',           label='_unknown4'},                             -- 54
    {ctype='bit[7]',            label='Indi Buff',          fn=e+{'indi'}},     -- 58
    {ctype='bit[9]',            label='_unknown5'},                             -- 58
    {ctype='unsigned short',    label='_junk1'},                                -- 5A
    {ctype='unsigned int',      label='_flags8'},                               -- 5C   Two least significant bits seem to indicate whether Wardrobes 3 and 4, respectively, are enabled
}

-- Entity Animation
-- Most frequently used for spawning ("deru") and despawning ("kesu")
-- Another example: "sp00" for Selh'teus making his spear of light appear
fields.incoming[0x038] = L{
    {ctype='unsigned int',      label='Mob',                fn=id},             -- 04
    {ctype='unsigned int',      label='_dupeMob',           fn=id},             -- 08
    {ctype='char[4]',           label='Type',               fn=e+{0x038}},      -- 0C   Four character animation name
    {ctype='unsigned short',    label='Mob Index',          fn=index},          -- 10
    {ctype='unsigned short',    label='_dupeMob Index',     fn=index},          -- 12
}

-- Env. Animation
-- Animations without entities will have zeroes for ID and Index
-- Example without IDs: Runic Gate/Runic Portal
-- Example with IDs: Diabolos floor tiles
fields.incoming[0x039] = L{
    {ctype='unsigned int',      label='ID',                fn=id},             -- 04
    {ctype='unsigned int',      label='_dupeID',           fn=id},             -- 08
    {ctype='char[4]',           label='Type',              fn=e+{0x038}},      -- 0C   Four character animation name
    {ctype='unsigned short',    label='Index',             fn=index},          -- 10
    {ctype='unsigned short',    label='_dupeIndex',        fn=index},          -- 10
}

-- Independent Animation
-- This is sometimes sent along with an Action Message packet, to provide an animation for an action message.
fields.incoming[0x03A] = L{
    {ctype='unsigned int',      label='Actor ID',          fn=id},             -- 04
    {ctype='unsigned int',      label='Target ID',         fn=id},             -- 08
    {ctype='unsigned short',    label='Actor Index',       fn=index},          -- 0C
    {ctype='unsigned short',    label='Target Index',      fn=index},          -- 0E
    {ctype='unsigned short',    label='Animation ID'},                         -- 10
    {ctype='unsigned char',     label='Animation type'},                       -- 12   0 = magic, 1 = item, 2 = JA, 3 = environmental animations, etc.
    {ctype='unsigned char',     label='_junk1'},                               -- 13   Deleting this has no effect
}

types.shop_item = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 00
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04
    {ctype='unsigned short',    label='Shop Slot'},                             -- 08
    {ctype='unsigned short',    label='Craft Skill'},                           -- 0A Zero on normal shops, has values that correlate to res\skills.
    {ctype='unsigned short',    label='Craft Rank'},                            -- 0C Correlates to Rank able to purchase product from GuildNPC  
}

-- Shop
fields.incoming[0x03C] = L{
    {ctype='unsigned short',    label='_zero1',             const=0x0000},      -- 04
    {ctype='unsigned short',    label='_padding1'},                             -- 06
    {ref=types.shop_item,       label='Item',               count='*'},         -- 08 -   *
}

-- Price/sale response
-- Sent in response to an outgoing price request for an NPC vendor (0x085), and in response to player finalizing a sale.
fields.incoming[0x03D] = L{
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 04
    {ctype='unsigned char',     label='Inventory Index',    fn=inv+{0}},        -- 08
    {ctype='unsigned char',     label='Type'},                                  -- 09 0 = on price check, 1 = when sale is finalized
    {ctype='unsigned short',    label='_junk1'},                                -- 0A
    {ctype='unsigned int',      label='Count'},                                 -- 0C Will be 1 on price check
}

-- Open Buy/Sell
fields.incoming[0x03E] = L{
    {ctype='unsigned char',     label='type'},                                  -- 04  Only 0x04 observed so far
    {ctype='data[3]',           label='_junk1'},                                -- 05
}

types.blacklist_entry = L{
    {ctype='unsigned int',      label='ID'},                                    -- 00
    {ctype='char[16]',          label='Name'},                                  -- 04
}

-- Shop Buy Response
fields.incoming[0x03F] = L{
    {ctype='unsigned short',    label='Shop Slot'},                             -- 04
    {ctype='unsigned short',    label='_unknown1'},                             -- 06   First byte always seems to be 1, second byte varies between 0 and 1? Unclear correlation to anything.
    {ctype='unsigned int',      label='Count'},                                 -- 08
}

-- Blacklist
fields.incoming[0x041] = L{
    {ref=types.blacklist_entry, count=12},                                      -- 08
    {ctype='unsigned char',     label='_unknown3',          const=3},           -- F4   Always 3
    {ctype='unsigned char',     label='Size'},                                  -- F5   Blacklist entries
}

-- Blacklist (add/delete)
fields.incoming[0x042] = L{
    {ctype='int',               label='_unknown1'},                             -- 04  Looks like a player ID, but does not match the sender or the receiver.
    {ctype='char[16]',          label='Name'},                                  -- 08  Character name
    {ctype='bool',              label='Add/Remove'},                            -- 18  0 = add, 1 = remove
    {ctype='data[3]',           label='_unknown2'},                             -- 19  Values observed on adding but not deleting.
}

-- Pet Stat
-- This packet varies and is indexed by job ID (byte 4)
-- Packet 0x044 is sent twice in sequence when stats could change. This can be caused by anything from
-- using a Maneuver on PUP to changing job. The two packets are the same length. The first
-- contains information about your main job. The second contains information about your
-- subjob and has the Subjob flag flipped.
func.incoming[0x044] = {}
fields.incoming[0x044] = function(data, type)
    return func.incoming[0x044].base + (func.incoming[0x044][type or data:byte(5)] or L{})
end

-- Base, shared by all jobs
func.incoming[0x044].base = L{
    {ctype='unsigned char',     label='Job',                fn=job},            -- 04
    {ctype='bool',              label='Subjob'},                                -- 05
    {ctype='unsigned short',    label='_unknown1'},                             -- 06
}

-- PUP
func.incoming[0x044][0x12] = L{
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
    {ctype='unsigned short',    label='Current HP'},                            -- 68
    {ctype='unsigned short',    label='Max HP'},                                -- 6A
    {ctype='unsigned short',    label='Current MP'},                            -- 6C
    {ctype='unsigned short',    label='Max MP'},                                -- 6E
    {ctype='unsigned short',    label='Current Melee Skill'},                   -- 70
    {ctype='unsigned short',    label='Max Melee Skill'},                       -- 72
    {ctype='unsigned short',    label='Current Ranged Skill'},                  -- 74
    {ctype='unsigned short',    label='Max Ranged Skill'},                      -- 76
    {ctype='unsigned short',    label='Current Magic Skill'},                   -- 78
    {ctype='unsigned short',    label='Max Magic Skill'},                       -- 7A
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
func.incoming[0x044][0x17] = L{
    {ctype='unsigned short',    label='Species'},                               -- 08
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A
    {ctype='unsigned short[12]',label='Instinct'},                              -- 0C   Instinct assignments are based off their position in the equipment list.
    {ctype='unsigned short',    label='_unknown3'},                             -- 24
    {ctype='data[118]',         label='_unknown4'},                             -- 26   Zeroing everything beyond this point has no notable effect.
}

-- Translate Response
fields.incoming[0x047] = L{
    {ctype='unsigned short',    label='Autotranslate Code'},                    -- 04   In a 6 byte autotranslate code, these are the 5th and 4 bytes respectively.
    {ctype='unsigned char',     label='Starting Language'},                     -- 06   0 == JP, 1 == EN
    {ctype='unsigned char',     label='Ending Language'},                       -- 07   0 == JP, 1 == EN
    {ctype='char[64]',          label='Initial Phrase'},                        -- 08
    {ctype='char[64]',          label='Translated Phrase'},                     -- 48   Will be 00'd if no match was found.
}


-- Unknown 0x048 incoming :: Sent when loading linkshell information from the Linkshell Concierge
-- One per entry, 128 bytes long, mostly empty, does not contain name as far as I can see.
-- Likely contributes to that information.

-- Delivery Item
func.incoming[0x04B] = {}
fields.incoming[0x04B] = function()
    local full = S{0x01, 0x04, 0x06, 0x08, 0x0A} -- This might not catch all packets with 'slot-info' (extra 68 bytes)
    return function(data, type)
        return full:contains(type or data:byte(5)) and func.incoming[0x04B].slot or func.incoming[0x04B].base
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
func.incoming[0x04B].base = L{
    {ctype='unsigned char',     label='Type',               fn=e+{'delivery'}}, -- 04
    {ctype='unsigned char',     label='_unknown1'},                             -- 05   FF if Type is 05, otherwise 01
    {ctype='signed char',       label='Delivery Slot'},                         -- 06   This goes left to right and then drops down a row and left to right again. Value is 00 through 07
                                                                                --    01 if Type is 06, otherwise FF
                                                                                --    06 Type always seems to come in a pair, this field is only 01 for the first packet
    {ctype='signed char',       label='_unknown2'},                             -- 07   Always FF FF FF FF?  
    {ctype='signed int',        label='_unknown3',          const=-1},          -- 0C   When in a 0x0D/0x0E type, 01 grants request to open inbox/outbox. With FA you get "Please try again later"
    {ctype='signed char',       label='_unknown4'},                             -- 0D   02 and 03 observed
    {ctype='signed char',       label='Packet Number'},                         -- 0E   FF FF observed
    {ctype='signed char',       label='_unknown5'},                             -- 0F   FF FF observed
    {ctype='signed char',       label='_unknown6'},                             -- 10   06 00 00 00 and 07 00 00 00 observed - (06 was for the first packet and 07 was for the second)
    {ctype='unsigned int',      label='_unknown7'},                             -- 10   00 00 00 00 also observed
}

-- If the type is 0x01, 0x04, 0x06, 0x08 or 0x0A, these fields appear in the packet in addition to the base. Maybe more
func.incoming[0x04B].slot = L{
    {ref=func.incoming[0x04B].base, count=1},                           -- 04
    {ctype='char[16]',          label='Player Name'},                           -- 14 This is used for sender (in inbox) and recipient (in outbox)
    {ctype='unsigned int',      label='_unknown8'},                             -- 24   46 32 00 00 and 42 32 00 00 observed - Possibly flags. Rare vs. Rare/Ex.?
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 28
    {ctype='unsigned int',      label='_unknown9'},                             -- 2C   00 00 00 00 observed
    {ctype='unsigned short',    label='Item',               fn=item},           -- 30
    {ctype='unsigned short',    label='_unknown10'},                            -- 32   Fiendish Tome: Chapter 11 had it, but Oneiros Pebble was just 00 00
                                                                                -- 32   May well be junked, 38 38 observed
    {ctype='unsigned int',      label='Flags?'},                                -- 34   01/04 00 00 00 observed
    {ctype='unsigned short',    label='Count'},                                 -- 38
    {ctype='unsigned short',    label='_unknown11'},                            -- 3A
    {ctype='data[28]',          label='_unknown12'},                            -- 3C   All 00 observed, ext data? Doesn't seem to be the case, but same size
}

enums['ah itype'] = {
    [0x02] = 'Open menu response',
    [0x03] = 'Unknown Logout',
    [0x04] = 'Sell item confirmation',
    [0x05] = 'Open sales status menu',
    [0x0A] = 'Open menu confirmation',
    [0x0B] = 'Sell item confirmation',
    [0x0D] = 'Sales item status',
    [0x0E] = 'Purchase item result',
}

func.incoming[0x04C] = {}
func.incoming[0x04C].base = L{
    {ctype='unsigned char',     label='Type',               fn=e+{'ah itype'}}, -- 04
}

func.incoming[0x04C][0x02] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0xFF},        -- 05
    {ctype='unsigned char',     label='Success',            fn=bool},           -- 06
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='char*',             label='_junk'},                                 -- 08
}

-- Sent when initating logout
func.incoming[0x04C][0x03] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0xFF},        -- 05
    {ctype='unsigned char',     label='Success',            fn=bool},           -- 06
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='char*',             label='_junk'},                                 -- 08
}

func.incoming[0x04C][0x04] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0xFF},        -- 05
    {ctype='unsigned char',     label='Success',            fn=bool},           -- 06
    {ctype='unsigned char',     label='_unknown2'},                             -- 07
    {ctype='unsigned int',      label='Fee',                fn=gil},            -- 08
    {ctype='unsigned short',    label='Inventory Index',    fn=inv+{0}},        -- 0C
    {ctype='unsigned short',    label='Item',               fn=item},           -- 0E
    {ctype='unsigned char',     label='Stack',              fn=invbool},        -- 10
    {ctype='char*',             label='_junk'},                                 -- 11
}

func.incoming[0x04C][0x05] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0xFF},        -- 05
    {ctype='unsigned char',     label='Success',            fn=bool},           -- 06
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='char*',             label='_junk'},                                 -- 08
}

enums['sale stat'] = {
    [0x00] = '-',
    [0x02] = 'Placing',
    [0x03] = 'On auction',
    [0x0A] = 'Sold',
    [0x0B] = 'Not sold',
    [0x10] = 'Checking',
}
enums['buy stat'] = {
    [0x01] = 'Success',
    [0x02] = 'Placing',
    [0xC5] = 'Failed',
}

-- 0x0A, 0x0B and 0x0D could probably be combined, the fields seem the same.
-- However, they're populated a bit differently. Both 0x0B and 0x0D are sent twice
-- on action completion, the second seems to contain updated information.
func.incoming[0x04C][0x0A] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='unsigned char',     label='_unknown1',          const=0x01},        -- 06
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='data[12]',          label='_junk1'},                                -- 08
    {ctype='unsigned char',     label='Sale status',        fn=e+{'sale stat'}},-- 14
    {ctype='unsigned char',     label='_unknown3'},                             -- 15
    {ctype='unsigned char',     label='Inventory Index'},                       -- 16   From when the item was put on auction
    {ctype='unsigned char',     label='_unknown4',          const=0x00},        -- 17   Possibly padding
    {ctype='char[16]',          label='Name'},                                  -- 18   Seems to always be the player's name
    {ctype='unsigned short',    label='Item',               fn=item},           -- 28
    {ctype='unsigned char',     label='Count'},                                 -- 2A
    {ctype='unsigned char',     label='AH Category'},                           -- 2B
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 2C
    {ctype='unsigned int',      label='_unknown6'},                             -- 30
    {ctype='unsigned int',      label='_unknown7'},                             -- 34
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 38
}

func.incoming[0x04C][0x0B] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='unsigned char',     label='_unknown1'},                             -- 06   This packet, like 0x0D, is sent twice, the first one always has 0x02 here, the second one 0x01
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='data[12]',          label='_junk1'},                                -- 08
    {ctype='unsigned char',     label='Sale status',        fn=e+{'sale stat'}},-- 14
    {ctype='unsigned char',     label='_unknown3'},                             -- 15
    {ctype='unsigned char',     label='Inventory Index'},                       -- 16   From when the item was put on auction
    {ctype='unsigned char',     label='_unknown4',          const=0x00},        -- 17   Possibly padding
    {ctype='char[16]',          label='Name'},                                  -- 18   Seems to always be the player's name
    {ctype='unsigned short',    label='Item',               fn=item},           -- 28
    {ctype='unsigned char',     label='Count'},                                 -- 2A
    {ctype='unsigned char',     label='AH Category'},                           -- 2B
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 2C
    {ctype='unsigned int',      label='_unknown6'},                             -- 30   Only populated in the second packet
    {ctype='unsigned int',      label='_unknown7'},                             -- 34   Only populated in the second packet
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 38
}

func.incoming[0x04C][0x0D] = L{
    {ctype='unsigned char',     label='Slot'},                                  -- 05
    {ctype='unsigned char',     label='_unknown1'},                             -- 06   Some sort of type... the packet seems to always be sent twice, once with this value as 0x02, followed by 0x01
    {ctype='unsigned char',     label='_unknown2'},                             -- 07   If 0x06 is 0x01 this seems to be 0x01 as well, otherwise 0x00
    {ctype='data[12]',          label='_junk1'},                                -- 08
    {ctype='unsigned char',     label='Sale status',        fn=e+{'sale stat'}},-- 14
    {ctype='unsigned char',     label='_unknown3'},                             -- 15
    {ctype='unsigned char',     label='Inventory Index'},                       -- 16   From when the item was put on auction
    {ctype='unsigned char',     label='_unknown4',          const=0x00},        -- 17   Possibly padding
    {ctype='char[16]',          label='Name'},                                  -- 18   Seems to always be the player's name
    {ctype='unsigned short',    label='Item',               fn=item},           -- 28
    {ctype='unsigned char',     label='Count'},                                 -- 2A
    {ctype='unsigned char',     label='AH Category'},                           -- 2B
    {ctype='unsigned int',      label='Price',              fn=gil},            -- 2C
    {ctype='unsigned int',      label='_unknown6'},                             -- 30
    {ctype='unsigned int',      label='_unknown7'},                             -- 34
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 38
}

func.incoming[0x04C][0x0E] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 05
    {ctype='unsigned char',     label='Buy Status',      fn=e+{'buy stat'}},    -- 06
    {ctype='unsigned char',     label='_unknown2'},                             -- 07   
    {ctype='unsigned int',      label='Price',           fn=gil},               -- 08   
    {ctype='unsigned short',    label='Item ID',         fn=item},              -- 0C
    {ctype='unsigned short',    label='_unknown3'},                             -- 0E
    {ctype='unsigned short',    label='Count'},                                 -- 10
    {ctype='unsigned int',      label='_unknown4'},                             -- 12
    {ctype='unsigned short',    label='_unknown5'},                             -- 16
    {ctype='char[16]',          label='Name'},                                  -- 18   Character name (pending buy only)
    {ctype='unsigned short',    label='Pending Item ID', fn=item},              -- 28   Only filled out during pending packets
    {ctype='unsigned short',    label='Pending Count'},                         -- 2A   Only filled out during pending packets
    {ctype='unsigned int',      label='Pending Price',   fn=gil},               -- 2C   Only filled out during pending packets
    {ctype='unsigned int',      label='_unknown6'},                             -- 30
    {ctype='unsigned int',      label='_unknown7'},                             -- 34
    {ctype='unsigned int',      label='Timestamp',          fn=utime},          -- 38   Only filled out during pending packets
}

func.incoming[0x04C][0x10] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 05
    {ctype='unsigned char',     label='Success',            fn=bool},           -- 06
    {ctype='unsigned char',     label='_unknown2',          const=0x00},        -- 07
    {ctype='char*',             label='_junk'},                                 -- 08
}

-- Auction Interaction
-- All types in here are server responses to the equivalent type in 0x04E
-- The only exception is type 0x02, which is sent to initiate the AH menu
fields.incoming[0x04C] = function()
    local fields = func.incoming[0x04C]

    return function(data, type)
        return fields.base + (fields[type or data:byte(5)] or L{})
    end
end()

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
    {ctype='char*',             label='Message'},                               -- 18  Currently prefixed with 0x81, 0xA1 - A custom shift-jis character that translates to a square.
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
    {ctype='data[1]',           label='_junk1'}                                 -- 07
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

enums[0x052] = {
    [0x00] = 'Standard',
    [0x01] = 'Event',
    [0x02] = 'Event Skipped',
    [0x03] = 'String Event',
    [0x04] = 'Fishing',
}

func.incoming[0x052] = {}
func.incoming[0x052].base = L{
    {ctype='unsigned char',     label='Type',               fn=e+{0x052}},      -- 04
}

func.incoming[0x052][0x02] = L{
    {ctype='unsigned short',    label='Menu ID'},                               -- 05
}

-- NPC Release
fields.incoming[0x052] = function(data, type)
    return func.incoming[0x052].base + (func.incoming[0x052][type or data:byte(5)] or L{})
end

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
    {ctype='data[0x40]',        label='Key item available', fn=hex+{0x40}},     -- 04
    {ctype='data[0x40]',        label='Key item examined',  fn=hex+{0x40}},     -- 44   Bit field correlating to the previous, 1 if KI has been examined, 0 otherwise
    {ctype='unsigned int',      label='Type'},                                  -- 84   Goes from 0 to 5, determines which KI are being sent
}

enums.quest_mission_log = {
    [0x0030] = 'Completed Campaign Missions',
    [0x0038] = 'Completed Campaign Missions (2)',       -- Starts at index 256
    [0x0050] = 'Current San d\'Oria Quests',
    [0x0058] = 'Current Bastok Quests',
    [0x0060] = 'Current Windurst Quests',
    [0x0068] = 'Current Jeuno Quests',
    [0x0070] = 'Current Other Quests',
    [0x0078] = 'Current Outlands Quests',
    [0x0080] = 'Current TOAU Quests and Missions (TOAU, WOTG, Assault, Campaign)',
    [0x0088] = 'Current WOTG Quests',
    [0x0090] = 'Completed San d\'Oria Quests',
    [0x0098] = 'Completed Bastok Quests',
    [0x00A0] = 'Completed Windurst Quests',
    [0x00A8] = 'Completed Jeuno Quests',
    [0x00B0] = 'Completed Other Quests',
    [0x00B8] = 'Completed Outlands Quests',
    [0x00C0] = 'Completed TOAU Quests and Assaults',
    [0x00C8] = 'Completed WOTG Quests',
    [0x00D0] = 'Completed Missions (Nations, Zilart)',
    [0x00D8] = 'Completed Missions (TOAU, WOTG)',
    [0x00E0] = 'Current Abyssea Quests',
    [0x00E8] = 'Completed Abyssea Quests',
    [0x00F0] = 'Current Adoulin Quests',
    [0x00F8] = 'Completed Adoulin Quests',
    [0x0100] = 'Current Coalition Quests', 
    [0x0108] = 'Completed Coalition Quests', 
    [0xFFFF] = 'Current Missions',               
}

-- There are 27 variations of this packet to populate different quest information.
-- Current quests, completed quests, and completed missions (where applicable) are represented by bit flags where the position
-- corresponds to the quest index in the respective DAT.
-- "Current Mission" fields refer to the mission ID, except COP, SOA, and ROV, which represent a mapping of some sort(?)
-- Additionally, COP, SOA, and ROV do not have a "completed" missions packet, they are instead updated with the current mission.
-- Quests will remain in your 'current' list after they are completed unless they are repeatable.

func.incoming[0x056] = {}
fields.incoming[0x056] = function (data, type)
    return (func.incoming[0x056][type or data and data:unpack('H',0x25)] or L{{ctype='data[32]', label='Quest Flags'}}) + func.incoming[0x056].type
end

func.incoming[0x056].type = L{ 
    {ctype='short',         label='Type',       fn=e+{'quest_mission_log'}}     -- 24
}

func.incoming[0x056][0x0080] = L{
    {ctype='data[16]',      label='Current TOAU Quests'},                       -- 04
    {ctype='int',           label='Current Assault Mission'},                   -- 14
    {ctype='int',           label='Current TOAU Mission'},                      -- 18
    {ctype='int',           label='Current WOTG Mission'},                      -- 1C
    {ctype='int',           label='Current Campaign Mission'},                  -- 20
}

func.incoming[0x056][0x00C0] = L{
    {ctype='data[16]',      label='Completed TOAU Quests'},                     -- 04
    {ctype='data[16]',      label='Completed Assaults'},                        -- 14
}

func.incoming[0x056][0x00D0] = L{
    {ctype='data[8]',       label='Completed San d\'Oria Missions'},            -- 04
    {ctype='data[8]',       label='Completed Bastok Missions'},                 -- 0C
    {ctype='data[8]',       label='Completed Windurst Missions'},               -- 14
    {ctype='data[8]',       label='Completed Zilart Missions'},                 -- 1C
}

func.incoming[0x056][0x00D8] = L{
    {ctype='data[8]',       label='Completed TOAU Missions'},                   -- 04
    {ctype='data[8]',       label='Completed WOTG Missions'},                   -- 0C
    {ctype='data[16]',      label='_junk'},                                     -- 14
}

func.incoming[0x056][0xFFFF] = L{
    {ctype='int',           label='Nation'},                                    -- 04
    {ctype='int',           label='Current Nation Mission'},                    -- 08
    {ctype='int',           label='Current ROZ Mission'},                       -- 0C
    {ctype='int',           label='Current COP Mission'},                       -- 10 Doesn't correspond directly to DAT
    {ctype='int',           label='_unknown1'},                                 -- 14
    {ctype='bit[4]',        label='Current ACP Mission'},                       -- 18 lower 4
    {ctype='bit[4]',        label='Current MKD Mission'},                       -- 18 upper 4
    {ctype='bit[4]',        label='Current ASA Mission'},                       -- 19 lower 4
    {ctype='bit[4]',        label='_junk1'},                                    -- 19 upper 4
    {ctype='short',         label='_junk2'},                                    -- 1A
    {ctype='int',           label='Current SOA Mission'},                       -- 1C Doesn't correspond directly to DAT
    {ctype='int',           label='Current ROV Mission'},                       -- 20 Doesn't correspond directly to DAT
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

-- Assist Response
fields.incoming[0x058] = L{
    {ctype='unsigned int',      label='Player',             fn=id},             -- 04
    {ctype='unsigned int',      label='Target',             fn=id},             -- 08
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
}

-- Emote
fields.incoming[0x05A] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             -- 04 
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 08
    {ctype='unsigned short',    label='Player Index',       fn=index},          -- 0C
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 0E
    {ctype='unsigned short',    label='Emote',              fn=emote},          -- 10
    {ctype='unsigned short',    label='_unknown1'},                             -- 12
    {ctype='unsigned short',    label='_unknown2'},                             -- 14
    {ctype='unsigned char',     label='Type'},                                  -- 16   2 for motion, 0 otherwise
    {ctype='unsigned char',     label='_unknown3'},                             -- 17
    {ctype='data[32]',          label='_unknown4'},                             -- 18
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

-- Dialogue Information
fields.incoming[0x05C] = L{
    {ctype='data[32]',          label='Menu Parameters'},                       -- 04   How information is packed in this region depends on the particular dialogue exchange.
}

-- Campaign/Besieged Map information

-- Bitpacked Campaign Info:
-- First Byte: Influence ranking including Beastmen
-- Second Byte: Influence ranking excluding Beastmen

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
    {ctype='unsigned char',     label='Alliance Indicator'},                    -- 05   Indicates whether two nations are allied (always the bottom two).
    {ctype='data[20]',          label='_unknown1'},                             -- 06   All Zeros, and changed nothing when 0xFF'd.
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
    {ctype='data[32]',          label='_unknown2'},                             -- 66   All Zeros, and changed nothing when 0xFF'd.
    {ctype='unsigned char',     label="San d'Oria region bar"},                 -- 86   These indicate how full the current region's bar is (in percent).
    {ctype='unsigned char',     label="Bastok region bar"},                     -- 87
    {ctype='unsigned char',     label="Windurst region bar"},                   -- 88
    {ctype='unsigned char',     label="San d'Oria region bar without beastmen"},-- 86   Unsure of the purpose of the without beastman indicators
    {ctype='unsigned char',     label="Bastok region bar without beastmen"},    -- 87
    {ctype='unsigned char',     label="Windurst region bar without beastmen"},  -- 88
    {ctype='unsigned char',     label="Days to tally"},                         -- 8C   Number of days to the next conquest tally
    {ctype='data[3]',           label="_unknown4"},                             -- 8D   All Zeros, and changed nothing when 0xFF'd.
    {ctype='int',               label='Conquest Points'},                       -- 90
    {ctype='unsigned char',     label="Beastmen region bar"},                   -- 94   
    {ctype='data[12]',          label="_unknown5"},                             -- 95   Mostly zeros and noticed no change when 0xFF'd.

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

-- Music Change
fields.incoming[0x05F] = L{
    {ctype='unsigned short',    label='BGM Type'},                              -- 04   01 = idle music, 06 = mog house music. 00, 02, and 03 are fight musics and some other stuff.
    {ctype='unsigned short',    label='Song ID'},                               -- 06   See the setBGM addon for more information
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
    {ctype='unsigned char',     label='Nation'},                                -- 50   0 = sandy, 1 = bastok, 2 = windy
    {ctype='unsigned char',     label='_unknown3'},                             -- 51   Possibly Unity ID (always 7 for me, I'm in Aldo's unity)
    {ctype='unsigned char',     label='Su Level'},                              -- 52   
    {ctype='unsigned char',     label='_unknown4'},                             -- 53   Always 00 for me
    {ctype='unsigned char',     label='Maximum iLevel'},                        -- 54   
    {ctype='unsigned char',     label='iLevel over 99'},                        -- 55   0x10 would be an iLevel of 115
    {ctype='unsigned char',     label='Main Hand iLevel'},                      -- 56   
    {ctype='unsigned char',     label='_unknown5'},                             -- 57   Always 00 for me
    {ctype='bit[5]',            label='Unity ID'},                              -- 58   0=None, 1=Pieuje, 2=Ayame, 3=Invincible Shield, 4=Apururu, 5=Maat, 6=Aldo, 7=Jakoh Wahcondalo, 8=Naja Salaheem, 9=Flavira
    {ctype='bit[5]',            label='Unity Rank'},                            -- 58   Danger, 00ing caused my client to crash
    {ctype='bit[16]',           label='Unity Points'},                          -- 59   
    {ctype='bit[6]',            label='_unknown6'},                             -- 5A   No obvious function
    {ctype='unsigned int',      label='_junk1'},                                -- 5B   
}

types.combat_skill = L{
    {ctype='bit[15]',           label='Level'},                                 -- 00
    {ctype='boolbit',           label='Capped'},                                -- 01
}

types.craft_skill = L{
    {ctype='bit[5]',            label='Rank',               fn=srank},          -- 00
    {ctype='bit[10]',           label='Level'},                                 -- 00
    {ctype='boolbit',           label='Capped'},                                -- 01
}

-- Skills Update
fields.incoming[0x062] = L{
    {ctype='char[124]',         label='_junk1'},
    {ref=types.combat_skill,    lookup={res.skills,0x00},   count=0x30},        -- 80
    {ref=types.craft_skill,     lookup={res.skills,0x30},   count=0x0A},        -- E0
    {ctype='unsigned short[6]', label='_junk2'},                                -- F4
}

-- Set Update
-- This packet likely varies based on jobs, but currently I only have it worked out for Monstrosity.
-- It also appears in three chunks, so it's double-varying.
-- Packet was expanded in the March 2014 update and now includes a fourth packet, which contains CP values.

func.incoming[0x063] = {}
fields.incoming[0x063] = function(data, type)
    return func.incoming[0x063].base + (func.incoming[0x063][type or data:byte(5)] or L{})
end

func.incoming[0x063].base = L{
    {ctype='unsigned short',    label='Order'},                                 -- 04
}

func.incoming[0x063][0x02] = L{
    {ctype='data[7]',           label='_flags1',            fn=bin+{7}},        -- 06   The 3rd bit of the last byte is the flag that indicates whether or not you are xp capped (blue levels)
}

func.incoming[0x063][0x03] = L{
    {ctype='unsigned short',    label='_flags1'},                               -- 06   Consistently D8 for me
    {ctype='unsigned short',    label='_flags2'},                               -- 08   Vary when I change species
    {ctype='unsigned short',    label='_flags3'},                               -- 0A   Consistent across species
    {ctype='unsigned char',     label='Mon. Rank'},                             -- 0C   00 = Mon, 01 = NM, 02 = HNM
    {ctype='unsigned char',     label='_unknown1'},                             -- 0D   00
    {ctype='unsigned short',    label='_unknown2'},                             -- 0E   00 00
    {ctype='unsigned short',    label='_unknown3'},                             -- 10   76 00
    {ctype='unsigned short',    label='Infamy'},                                -- 12
    {ctype='unsigned int',      label='_unknown4'},                             -- 14   00s
    {ctype='unsigned int',      label='_unknown5'},                             -- 18   00s
    {ctype='data[64]',          label='Instinct Bitfield 1'},                   -- 1C   See below
    -- Bitpacked 2-bit values. 0 = no instincts from that species, 1 == first instinct, 2 == first and second instinct, 3 == first, second, and third instinct.
    {ctype='data[128]',         label='Monster Level Char field'},              -- 5C   Mapped onto the item ID for these creatures. (00 doesn't exist, 01 is rabbit, 02 is behemoth, etc.)
}

func.incoming[0x063][0x04] = L{
    {ctype='unsigned short',    label='_unknown1'},                             -- 06   B0 00
    {ctype='data[126]',         label='_unknown2'},                             -- 08   FF-ing has no effect.
    {ctype='unsigned char',     label='Slime Level'},                           -- 86
    {ctype='unsigned char',     label='Spriggan Level'},                        -- 87
    {ctype='data[12]',          label='Instinct Bitfield 3'},                   -- 88   Contains job/race instincts from the 0x03 set. Has 8 unused bytes. This is a 1:1 mapping.
    {ctype='data[32]',          label='Variants Bitfield'},                     -- 94   Does not show normal monsters, only variants. Bit is 1 if the variant is owned. Length is an estimation including the possible padding.
}

types.job_point_info = L{
    {ctype='unsigned short',    label='Capacity Points'},                       -- 00
    {ctype='unsigned short',    label='Job Points'},                            -- 02
    {ctype='unsigned short',    label='Spent Job Points'},                      -- 04
}

func.incoming[0x063][0x05] = L{
    {ctype='unsigned short',    label='_unknown1',          const=0x0098},      -- 06
    {ctype='unsigned short',    label='_unknown2'},                             -- 08   Lowest bit of this might indicate JP availability
    {ctype='unsigned short',    label='_unknown3'},                             -- 0A
    {ref=types.job_point_info,  lookup={res.jobs, 0x00},    count=24},          -- 0C
}

func.incoming[0x063][0x09] = L{
    {ctype='unsigned short',    label='_unknown1',          const=0x00C4},      -- 06
    {ctype='unsigned short[32]',label='Buffs',              fn=buff},           -- 08
    {ctype='unsigned int[32]',  label='Time',               fn=bufftime},       -- 48
}

-- Repositioning
fields.incoming[0x065] = L{
-- This is identical to the spawn packet, but has 4 more unused bytes.
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 10
    {ctype='unsigned short',    label='Index',              fn=index},          -- 14
    {ctype='unsigned char',     label='Animation'},                             -- 16
    {ctype='unsigned char',     label='Rotation'},                              -- 17
    {ctype='data[6]',           label='_unknown3'},                             -- 18   All zeros observed.
}

-- Pet Info
fields.incoming[0x067] = L{
-- The length of this packet is 24, 28, 36 or 40 bytes, featuring a 0, 4, 8, 12, or 16 byte name field.

-- The Mask is a bitpacked combination of a number indicating the type of information in the packet and
--    a field indicating the length of the packet.

-- The lower 6 bits of the Mask is the type of packet:
-- 2 occurs often even with no pet, contains player index, id and main job level
-- 3 identifies (potential) pets and who owns them
-- 4 gives status information about your pet

-- The upper 10 bits of the Mask is the length in bytes of the data excluding the header and any padding
--    after the pet name.

    {ctype='bit[6]',            label='Message Type'},                          -- 04
    {ctype='bit[10]',           label='Message Length'},                        -- 05
    {ctype='unsigned short',    label='Pet Index',          fn=index},          -- 06
    {ctype='unsigned int',      label='Pet ID',             fn=id},             -- 08
    {ctype='unsigned short',    label='Owner Index',        fn=index},          -- 0C
    {ctype='unsigned char',     label='Current HP%',        fn=percent},        -- 0E
    {ctype='unsigned char',     label='Current MP%',        fn=percent},        -- 0F
    {ctype='unsigned int',      label='Pet TP'},                                -- 10
    {ctype='unsigned int',      label='_unknown1'},                             -- 14
    {ctype='char*',             label='Pet Name'},                              -- 18
}

-- Pet Status
-- It is sent every time a pet performs an action, every time anything about its vitals changes (HP, MP, TP) and every time its target changes
fields.incoming[0x068] = L{
    {ctype='bit[6]',            label='Message Type',       const=0x04},        -- 04   Seems to always be 4
    {ctype='bit[10]',           label='Message Length'},                        -- 05   Number of bytes from the start of the packet (including header) until the last non-null character in the name
    {ctype='unsigned short',    label='Owner Index',        fn=index},          -- 06
    {ctype='unsigned int',      label='Owner ID',           fn=id},             -- 08
    {ctype='unsigned short',    label='Pet Index',          fn=index},          -- 0C
    {ctype='unsigned char',     label='Current HP%',        fn=percent},        -- 0E
    {ctype='unsigned char',     label='Current MP%',        fn=percent},        -- 0F
    {ctype='unsigned int',      label='Pet TP'},                                -- 10
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 14
    {ctype='char*',             label='Pet Name'},                              -- 18
}

-- Self Synth Result
fields.incoming[0x06F] = L{
    {ctype='unsigned char',     label='Result',             fn=e+{'synth'}},    -- 04
    {ctype='signed char',       label='Quality'},                               -- 05
    {ctype='unsigned char',     label='Count'},                                 -- 06   Even set for fail (set as the NQ amount in that case)
    {ctype='unsigned char',     label='_junk1'},                                -- 07
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned short[8]', label='Lost Item',          fn=item},           -- 0A
    {ctype='unsigned char[4]',  label='Skill',              fn=skill},          -- 1A
    {ctype='unsigned char[4]',  label='Skillup',            fn=div+{10}},       -- 1E
    {ctype='unsigned short',    label='Crystal',            fn=item},           -- 22
}

-- Others Synth Result
fields.incoming[0x070] = L{
    {ctype='unsigned char',     label='Result',             fn=e+{'synth'}},    -- 04
    {ctype='signed char',       label='Quality'},                               -- 05
    {ctype='unsigned char',     label='Count'},                                 -- 06
    {ctype='unsigned char',     label='_junk1'},                                -- 07
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08
    {ctype='unsigned short[8]', label='Lost Item',          fn=item},           -- 0A
    {ctype='unsigned char[4]',  label='Skill',              fn=skill},          -- 1A   Unsure about this
    {ctype='char*',             label='Player Name'},                           -- 1E   Name of the player
}

-- Unity Start
-- Only observed being used for Unity fights.
fields.incoming[0x075] = L{
    {ctype='unsigned int',      label='Fight Designation'},                     -- 04   Anything other than 0 makes a timer. 0 deletes the timer.
    {ctype='unsigned int',      label='Timestamp Offset',   fn=time},           -- 08   Number of seconds since 15:00:00 GMT 31/12/2002 (0x3C307D70)
    {ctype='unsigned int',      label='Fight Duration',     fn=time},           -- 0C
    {ctype='byte[12]',          label='_unknown1'},                             -- 10   This packet clearly needs position information, but it's unclear how these bytes carry it
    {ctype='unsigned int',      label='Battlefield Radius'},                    -- 1C   Yalms*1000, so a 50 yalm battlefield would have 50,000 for this field
    {ctype='unsigned int',      label='Render Radius'},                         -- 20   Yalms*1000, so a fence that renders when you're 25 yalms away would have 25,000 for this field
}

-- Party status icon update
-- Buff IDs go can over 0xFF, but in the packet each buff only takes up one byte.
-- To address that there's a 8 byte bitmask starting at 0x4C where each 2 bits
-- represent how much to add to the value in the respective byte.
types.party_buff_entry = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 00
    {ctype='unsigned short',    label='Index',              fn=index},          -- 04
    {ctype='unsigned short',    label='_unknown1'},                             -- 06
    {ctype='data[8]',           label='Bit Mask'},                              -- 08
    {ctype='data[32]',          label='Buffs'},                                 -- 10
}

fields.incoming[0x076] = L{
    {ref=types.party_buff_entry,label='Party Buffs',        count=5},           -- 04  This is 00'd out for absent party members.
}

-- Proposal
fields.incoming[0x078] = L{
    {ctype='unsigned int',      label='Proposer ID',        fn=id},             -- 04
    {ctype='unsigned int',      label='_unknown1'},                             -- 08  Proposal ID?
    {ctype='unsigned short',    label='Proposer Index'},                        -- 0C
    {ctype='char[15]',          label='Proposer Name'},                         -- 0E
    {ctype='unsigned char',     label='Chat mode'},                             -- 1D  Not typical chat mode mapping. 1 = Party
    {ctype='char*',             label='Proposal'},                              -- 1E  Proposal text, complete with special characters
}

-- Proposal Update
fields.incoming[0x079] = L{
    {ctype='unsigned int',      label='_unknown1'},                             -- 04
    {ctype='data[21]',          label='_unknown2'},                             -- 08  Likely contains information about the current chat mode and vote count
    {ctype='char[16]',          label='Proposer Name'},                         -- 1D
    {ctype='data[3]',           label='_junk1'},                                -- 1E  All 00s
}

-- Guild Buy Response
-- Sent when buying an item from a guild NPC
fields.incoming[0x082] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08   
    {ctype='unsigned char',     label='_junk1'},                                -- 0A   No obvious purpose
    {ctype='unsigned char',     label='Count'},                                 -- 0B   Number you bought
}

types.guild_entry = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 00
    {ctype='unsigned char',     label='Current Stock'},                         -- 02   Number in stock
    {ctype='unsigned char',     label='Max Stock'},                             -- 03   Max stock can hold
    {ctype='unsigned int',      label='Price'},                                 -- 04
}
-- Guild Inv List
fields.incoming[0x083] = L{
    {ref=types.guild_entry,     label='Item',               count='30'},        -- 04
    {ctype='unsigned char',     label='Item Count'},                            -- F4
    {ctype='bit[4]',            label='Order'},                                 -- F5
    {ctype='bit[4]',            label='_unknown'},                              
    {ctype='unsigned short',    label='_padding'}                               -- F6
}

-- Guild Sell Response
-- Sent when selling an item to a guild NPC
fields.incoming[0x084] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 08   
    {ctype='unsigned char',     label='_junk1'},                                -- 0A   No obvious purpose
    {ctype='unsigned char',     label='Count'},                                 -- 0B   Number you bought. If 0, the transaction failed.
}

-- Guild Sale List
fields.incoming[0x085] = L{
    {ref=types.guild_entry,     label='Item',               count='30'},        -- 04
    {ctype='unsigned char',     label='Item Count'},                            -- F4
    {ctype='bit[4]',            label='Order'},                                 -- F5
    {ctype='bit[4]',            label='_unknown'},                              
    {ctype='unsigned short',    label='_padding'}                               -- F6
}
-- Guild Open
-- Sent to update guild status or open the guild menu.
fields.incoming[0x086] = L{
    {ctype='unsigned char',     label='Open Menu'},                             -- 04   0x00 = Open guild menu, 0x01 = Guild is closed, 0x03 = nothing, so this is treated as an unsigned char
    {ctype='data[3]',           label='_junk1'},                                -- 05   Does not seem to matter in any permutation of this packet
    {ctype='data[3]',           label='Guild Hours'},                           -- 08   First 1 indicates the opening hour. First 0 after that indicates the closing hour. In the event that there are no 0s, 91022244 is used.
    {ctype='unsigned char',     label='_flags1'},                               -- 0B   Most significant bit (0x80) indicates whether the "close guild" message should be displayed.
}


types.merit_entry = L{
    {ctype='unsigned short',    label='Merit'},                                 -- 00
    {ctype='unsigned char',     label='Next Cost'},                             -- 02
    {ctype='unsigned char',     label='Value'},                                 -- 03
}

-- Merits
fields.incoming[0x08C] = function(data, merits)
    return L{
        {ctype='unsigned char', label='Count'},                                 -- 04   Number of merits entries in this packet (possibly a short, although it wouldn't make sense)
        {ctype='data[3]',       label='_unknown1'},                             -- 05   Always 00 0F 01?
        {ref=types.merit_entry, count=merits or data:byte(5)},                  -- 08
        {ctype='unsigned int',  label='_unknown2',          const=0x00000000},  ---04
    }
end

types.job_point = L{
    {ctype='unsigned short',    label='Job Point ID'},                          -- 00   32 potential values for every job, which means you could decompose this into a value bitpacked with job ID if you wanted
    {ctype='bit[10]',           label='_unknown1'},                             -- 02   Always 1 in cases where the ID is set at the moment. Zeroing this has no effect.
    {ctype='bit[6]',            label='Current Level'},                         -- 03   Current enhancement for this job point ID
}

-- Job Points
-- These packets are currently not used by the client in any detectable way.
-- The below pattern repeats itself for the entirety of the packet. There are 2 jobs per packet,
-- and 11 of these packets are sent at the moment in response to the first 0x0C0 outgoing packet since zoning.
-- This is how it works as of 3-19-14, and it is safe to assume that it will change in the future.
fields.incoming[0x08D] = L{
    {ref=types.job_point,       count='*'},                                     -- 04
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
    {ctype='unsigned short',    label='_unknown2'},                             -- 0A    Always 0?
}

-- Party Map Marker
-- This packet is ignored if your party member is within 50' of you.
fields.incoming[0x0A0] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Zone',               fn=zone},           -- 08
    {ctype='unsigned short',    label='_unknown1'},                             -- 0A   Look like junk
    {ctype='float',             label='X'},                                     -- 0C
    {ctype='float',             label='Z'},                                     -- 10
    {ctype='float',             label='Y'},                                     -- 14
}

--0x0AA, 0x0AC, and 0x0AE are all bitfields where the lsb indicates whether you have index 0 of the related resource.

-- Help Desk submenu open
fields.incoming[0x0B5] = L{
    {ctype='data[0x14]',        label='_unknown1'},                             -- 04
    {ctype='unsigned int',      label='Number of Opens'},                       -- 18
    {ctype='unsigned int',      label='_unknown2'},                             -- 1C
}

-- Alliance status update
fields.incoming[0x0C8] = L{
    {ctype='unsigned char',     label='_unknown1'},                             -- 04
    {ctype='data[3]',           label='_junk1'},                                -- 05
    {ref=types.alliance_member, count=18},                                      -- 08
    {ctype='data[0x18]',        label='_unknown3',          const=''},          -- E0   Always 0?
}

types.check_item = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 00
    {ctype='unsigned char',     label='Slot',               fn=slot},           -- 02
    {ctype='unsigned char',     label='_unknown1'},                             -- 03
    {ctype='data[0x18]',        label='ExtData',            fn=hex+{0x18}},     -- 04
}

-- Check data
func.incoming[0x0C9] = {}
fields.incoming[0x0C9] = function(data, type)
    return func.incoming[0x0C9].base + func.incoming[0x0C9][type or data:byte(0x0B)]
end

enums[0x0C9] = {
    [0x01] = 'Metadata',
    [0x03] = 'Equipment',
}

-- Common to all messages
func.incoming[0x0C9].base = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             -- 04
    {ctype='unsigned short',    label='Target Index',       fn=index},          -- 08
    {ctype='unsigned char',     label='Type',               fn=e+{0x0C9}},      -- 0A
}

-- Equipment listing
func.incoming[0x0C9][0x03] = L{
    {ctype='unsigned char',     label='Count'},                                 -- 0B
    {ref=types.check_item,      count_ref=0x0B},                                -- 0C
}

-- Metadata
-- The title needs to be somewhere in here, but not sure where, maybe bit packed?
func.incoming[0x0C9][0x01] = L{
    {ctype='data[3]',           label='_junk1'},                                -- 0B
    {ctype='unsigned char',     label='Icon Set Subtype'},                      -- 0E   0 = Unopened Linkshell?, 1 = Linkshell, 2 = Pearlsack, 3 = Linkpearl, 4 = Ripped Pearlsack (I think), 5 = Broken Linkpearl?
    {ctype='unsigned char',     label='Icon Set ID'},                           -- 0F   This identifies the icon set, always 2 for linkshells.
    {ctype='bit[4]',            label='Linkshell Red'},                         -- 10   0xGR, 0x-B
    {ctype='bit[4]',            label='Linkshell Green'},                       -- 10   
    {ctype='bit[4]',            label='Linkshell Blue'},                        -- 11   
    {ctype='bit[4]',            label='_junk1'},                                -- 11   
    {ctype='unsigned char',     label='Main Job',           fn=job},            -- 12
    {ctype='unsigned char',     label='Sub Job',            fn=job},            -- 13
    {ctype='data[15]',          label='Linkshell',          enc=ls_enc},        -- 14   6-bit packed
    {ctype='unsigned char',     label='_padding1'},                             -- 23
    {ctype='unsigned char',     label='Main Job Level'},                        -- 24
    {ctype='unsigned char',     label='Sub Job Level'},                         -- 25
    {ctype='data[42]',          label='_unknown5'},                             -- 26   At least the first two bytes and the last twelve bytes are junk, possibly more
}

-- Bazaar Message
fields.incoming[0x0CA] = L{
    {ctype='char[124]',         label='Bazaar Message'},                        -- 04   Terminated with a vertical tab
    {ctype='char[16]',          label='Player Name'},                           -- 80
    {ctype='unsigned short',    label='Player Title ID'},                       -- 90   
    {ctype='unsigned short',    label='_unknown4'},                             -- 92   00 00 observed.
}

-- LS Message
fields.incoming[0x0CC] = L{
    {ctype='int',               label='_unknown1'},                             -- 04
    {ctype='char[128]',         label='Message'},                               -- 08
    {ctype='unsigned int',      label='Timestamp',          fn=time},           -- 88
    {ctype='char[16]',          label='Player Name'},                           -- 8C
    {ctype='unsigned int',      label='Permissions'},                           -- 98
    {ctype='data[15]',          label='Linkshell',          enc=ls_enc},        -- 9C   6-bit packed
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
    {ctype='data[28]',          label='_unknown6'},                             -- AC   Always 0 it seems?
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
    {ctype='data[6]',           label='_junk1'},                                -- 36
}

-- Party Invite
fields.incoming[0x0DC] = L{
    {ctype='unsigned int',      label='Inviter ID',         fn=id},             -- 04
    {ctype='unsigned int',      label='Flags'},                                 -- 08   This may also contain the type of invite (alliance vs. party)
    {ctype='char[16]',          label='Inviter Name'},                          -- 0C
    {ctype='unsigned short',    label='_unknown1'},                             -- 1C
    {ctype='unsigned short',    label='_junk1'},                                -- 1E
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
    {ctype='unsigned char',     label='Main job',           fn=job},            -- 22
    {ctype='unsigned char',     label='Main job level'},                        -- 23
    {ctype='unsigned char',     label='Sub job',            fn=job},            -- 24
    {ctype='unsigned char',     label='Sub job level'},                         -- 25
    {ctype='char*',             label='Name'},                                  -- 26
}

-- Unnamed 0xDE packet
-- 8 bytes long, sent in response to opening/closing mog house. Occasionally sent when zoning.
-- Injecting it with different values has no obvious effect.
--[[fields.incoming[0x0DE] = L{
    {ctype='unsigned char',     label='type'},                                  -- 04  Was always 0x4 for opening/closing mog house
    {ctype='data[3]',           label='_junk1'},                                -- 05  Looked like junk
}]]

-- Char Update
fields.incoming[0x0DF] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned int',      label='HP'},                                    -- 08
    {ctype='unsigned int',      label='MP'},                                    -- 0C
    {ctype='unsigned int',      label='TP',                 fn=percent},        -- 10
    {ctype='unsigned short',    label='Index',              fn=index},          -- 14
    {ctype='unsigned char',     label='HPP',                fn=percent},        -- 16
    {ctype='unsigned char',     label='MPP',                fn=percent},        -- 17
    {ctype='unsigned short',    label='_unknown1'},                             -- 18
    {ctype='unsigned short',    label='_unknown2'},                             -- 1A
    {ctype='unsigned int',      label='_unknown3'},                             -- 1C
    {ctype='unsigned char',     label='Main job',           fn=job},            -- 20
    {ctype='unsigned char',     label='Main job level'},                        -- 21
    {ctype='unsigned char',     label='Sub job',            fn=job},            -- 22
    {ctype='unsigned char',     label='Sub job level'},                         -- 23
}

-- Unknown packet 0x0E0: I still can't make heads or tails of the content. The packet is always 8 bytes long.


-- Linkshell Equip
fields.incoming[0x0E0] = L{
    {ctype='unsigned char',     label='Linkshell Number'},                      -- 04
    {ctype='unsigned char',     label='Inventory Slot'},                        -- 05
    {ctype='unsigned short',    label='_junk1'},                                -- 06
}

-- Party Member List
fields.incoming[0x0E1] = L{
    {ctype='unsigned short',    label='Party ID'},                              -- 04 For whatever reason, this is always valid ASCII in my captured packets.
    {ctype='unsigned short',    label='_unknown1',          const=0x8000},      -- 06  Likely contains information about the current chat mode and vote count
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
    {ctype='unsigned char',     label='Level'},                                 -- 06
    {ctype='unsigned char',     label='Type',               fn=e+{'ws mob'}},   -- 07
    {ctype='short',             label='X Offset',           fn=pixel},          -- 08   Offset on the map
    {ctype='short',             label='Y Offset',           fn=pixel},          -- 0A
    {ctype='char[16]',          label='Name'},                                  -- 0C   Slugged, may not extend all the way to 27. Up to 25 has been observed. This will be used if Type == 0
}

-- Widescan Track
fields.incoming[0x0F5] = L{
    {ctype='float',             label='X'},                                     -- 04
    {ctype='float',             label='Z'},                                     -- 08
    {ctype='float',             label='Y'},                                     -- 0C
    {ctype='unsigned char',     label='Level'},                                 -- 10
    {ctype='unsigned char',     label='_padding1'},                             -- 11
    {ctype='unsigned short',    label='Index',              fn=index},          -- 12
    {ctype='unsigned int',      label='Status',             fn=e+{'ws track'}}, -- 14
}

-- Widescan Mark
fields.incoming[0x0F6] = L{
    {ctype='unsigned int',      label='Type',               fn=e+{'ws mark'}},  -- 04
}

enums['reraise'] = {
    [0x01] = 'Raise dialogue',
    [0x02] = 'Tractor dialogue',
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             -- 04
    {ctype='unsigned short',    label='Index',              fn=index},          -- 08
    {ctype='unsigned char',     label='Category',           fn=e+{'reraise'}},  -- 0A
    {ctype='unsigned char',     label='_unknown1'},                             -- 0B
}

-- Furniture Interaction
fields.incoming[0x0FA] = L{
    {ctype='unsigned short',    label='Item',               fn=item},           -- 04
    {ctype='data[6]',           label='_unknown1'},                             -- 06  Always 00s for me
    {ctype='unsigned char',     label='Safe Slot'},                             -- 0C  Safe slot for the furniture being interacted with
    {ctype='data[3]',           label='_unknown2'},                             -- 0D  Takes values, but doesn't look particularly meaningful
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
    {ctype='unsigned int',      label='Sparks Total'},                          -- 04
    {ctype='unsigned char',     label='Unity (Shared) designator'},             -- 08   Unity (Shared) designator (0=A, 1=B, 2=C, etc.)
    {ctype='unsigned char',     label='Unity (Person) designator '},            -- 09   The game does not distinguish these
    {ctype='char[6]',           label='_unknown2'},                             -- 0A   Currently all 0xFF'd, never seen it change.
}

types.roe_quest = L{
    {ctype='bit[12]',           label='RoE Quest ID'},                          -- 00
    {ctype='bit[20]',           label='RoE Quest Progress'},                    -- 01
}

-- Eminence Update
fields.incoming[0x111] = L{
    {ref=types.roe_quest,       count=30},                                      -- 04
    {ctype='data[132]',         label='_junk'},                                 -- 7C   All 0s observed. Likely reserved in case they decide to expand allowed objectives.
    {ctype='bit[12]',           label='Limited Time RoE Quest ID'},             -- 100
    {ctype='bit[20]',           label='Limited Time RoE Quest Progress'},       -- 101 upper 4
}


-- RoE Quest Log
fields.incoming[0x112] = L{
    {ctype='data[128]',         label='RoE Quest Bitfield'},                    -- 04   See next line
    -- Bitpacked quest completion flags. The position of the bit is the quest ID.
    -- Data regarding available quests and repeatability is handled client side or
    -- somewhere else
    {ctype='unsigned int',      label='Order'},                                 -- 84   0,1,2,3
}

--Currency Info (Currencies I)
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
    {ctype='unsigned char',     label='Synergy Fewell (Fire)'},                 -- 48
    {ctype='unsigned char',     label='Synergy Fewell (Ice)'},                  -- 49
    {ctype='unsigned char',     label='Synergy Fewell (Wind)'},                 -- 4A
    {ctype='unsigned char',     label='Synergy Fewell (Earth)'},                -- 4B
    {ctype='unsigned char',     label='Synergy Fewell (Lightning)'},            -- 4C
    {ctype='unsigned char',     label='Synergy Fewell (Water)'},                -- 4D
    {ctype='unsigned char',     label='Synergy Fewell (Light)'},                -- 4E
    {ctype='unsigned char',     label='Synergy Fewell (Dark)'},                 -- 4F
    {ctype='signed int',        label='Ballista Points'},                       -- 50
    {ctype='signed int',        label='Fellow Points'},                         -- 54
    {ctype='unsigned short',    label='Chocobucks (San d\'Oria)'},              -- 58
    {ctype='unsigned short',    label='Chocobucks (Bastok)'},                   -- 5A
    {ctype='unsigned short',    label='Chocobucks (Windurst)'},                 -- 5C
    {ctype='unsigned short',    label='Daily Tally'},                           -- 5E
    {ctype='signed int',        label='Research Marks'},                        -- 60
    {ctype='unsigned char',     label='Wizened Tunnel Worms'},                  -- 64
    {ctype='unsigned char',     label='Wizened Morion Worms'},                  -- 65
    {ctype='unsigned char',     label='Wizened Phantom Worms'},                 -- 66
    {ctype='char',              label='_unknown1'},                             -- 67   Currently holds no value
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
    {ctype='unsigned short',    label='A.M.A.N. Vouchers Stored'},              -- A8
    {ctype='unsigned short',    label="Login Points"},                          -- AA
    {ctype='signed int',        label='Cruor'},                                 -- AC
    {ctype='signed int',        label='Resistance Credits'},                    -- B0
    {ctype='signed int',        label='Dominion Notes'},                        -- B4
    {ctype='unsigned char',     label='5th Echelon Battle Trophies'},           -- B8
    {ctype='unsigned char',     label='4th Echelon Battle Trophies'},           -- B9
    {ctype='unsigned char',     label='3rd Echelon Battle Trophies'},           -- BA
    {ctype='unsigned char',     label='2nd Echelon Battle Trophies'},           -- BB
    {ctype='unsigned char',     label='1st Echelon Battle Trophies'},           -- BC
    {ctype='unsigned char',     label='Cave Conservation Points'},              -- BD
    {ctype='unsigned char',     label='Imperial Army ID Tags'},                 -- BE
    {ctype='unsigned char',     label='Op Credits'},                            -- BF
    {ctype='signed int',        label='Traverser Stones'},                      -- C0
    {ctype='signed int',        label='Voidstones'},                            -- C4
    {ctype='signed int',        label='Kupofried\'s Corundums'},                -- C8
    {ctype='unsigned char',     label='Moblin Pheromone Sacks'},                -- CC
    {ctype='data[1]',           label='_unknown2'},                             -- CD
    {ctype='unsigned char',     label="Rems Tale Chapter 1"},                   -- CE
    {ctype='unsigned char',     label="Rems Tale Chapter 2"},                   -- CF
    {ctype='unsigned char',     label="Rems Tale Chapter 3"},                   -- D0
    {ctype='unsigned char',     label="Rems Tale Chapter 4"},                   -- D1
    {ctype='unsigned char',     label="Rems Tale Chapter 5"},                   -- D2
    {ctype='unsigned char',     label="Rems Tale Chapter 6"},                   -- D3
    {ctype='unsigned char',     label="Rems Tale Chapter 7"},                   -- D4
    {ctype='unsigned char',     label="Rems Tale Chapter 8"},                   -- D5
    {ctype='unsigned char',     label="Rems Tale Chapter 9"},                   -- D6
    {ctype='unsigned char',     label="Rems Tale Chapter 10"},                  -- D7
    {ctype='data[8]',           label="_unknown3"},                             -- D8
    {ctype='signed int',        label="Reclamation Marks"},                     -- E0
    {ctype='signed int',        label='Unity Accolades'},                       -- E4
    {ctype='unsigned short',    label="Fire Crystals"},                         -- E8
    {ctype='unsigned short',    label="Ice Crystals"},                          -- EA
    {ctype='unsigned short',    label="Wind Crystals"},                         -- EC
    {ctype='unsigned short',    label="Earth Crystals"},                        -- EE
    {ctype='unsigned short',    label="Lightning Crystals"},                    -- E0
    {ctype='unsigned short',    label="Water Crystals"},                        -- F2
    {ctype='unsigned short',    label="Light Crystals"},                        -- F4
    {ctype='unsigned short',    label="Dark Crystals"},                         -- F6
    {ctype='signed int',        label="Deeds"},                                 -- F8
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

-- Equipset Build Response
fields.incoming[0x116] = L{
    {ref=types.equipset_build,  lookup={res.slots, 0x00},   count=0x10},
}

func.incoming[0x117] = {}
func.incoming[0x117].base = L{
    {ctype='unsigned char',     label='Count'},                                 -- 04
    {ctype='unsigned char[3]',  label='_unknown1'},                             -- 05
}

-- Equipset
fields.incoming[0x117] = function(data, count)
    count = count or data:byte(5)

    return func.incoming[0x117].base + L{
        -- Only the number given in Count will be properly populated, the rest is junk
        {ref=types.equipset,        count=count},                                   -- 08
        {ctype='data[%u]':format((16 - count) * 4), label='_junk1'},                -- 08 + 4 * count
        {ref=types.equipset,        lookup={res.slots, 0x00},   count=0x10},        -- 48
    }
end

-- Currency Info (Currencies2)
fields.incoming[0x118] = L{
    {ctype='signed int',        label='Bayld'},                                     -- 04
    {ctype='unsigned short',    label='Kinetic Units'},                             -- 08
    {ctype='unsigned char',     label='Coalition Imprimaturs'},                     -- 0A
    {ctype='unsigned char',     label='Mystical Canteens'},                         -- 0B
    {ctype='signed int',        label='Obsidian Fragments'},                        -- 0C
    {ctype='unsigned short',    label='Lebondopt Wings Stored'},                    -- 10
    {ctype='unsigned short',    label='Pulchridopt Wings Stored'},                  -- 12
    {ctype='signed int',        label='Mweya Plasm Corpuscles'},                    -- 14
    {ctype='unsigned char',     label='Ghastly Stones Stored'},                     -- 18
    {ctype='unsigned char',     label='Ghastly Stones +1 Stored'},                  -- 19
    {ctype='unsigned char',     label='Ghastly Stones +2 Stored'},                  -- 1A
    {ctype='unsigned char',     label='Verdigris Stones Stored'},                   -- 1B
    {ctype='unsigned char',     label='Verdigris Stones +1 Stored'},                -- 1C
    {ctype='unsigned char',     label='Verdigris Stones +2 Stored'},                -- 1D
    {ctype='unsigned char',     label='Wailing Stones Stored'},                     -- 1E
    {ctype='unsigned char',     label='Wailing Stones +1 Stored'},                  -- 1F
    {ctype='unsigned char',     label='Wailing Stones +2 Stored'},                  -- 20
    {ctype='unsigned char',     label='Snowslit Stones Stored'},                    -- 21
    {ctype='unsigned char',     label='Snowslit Stones +1 Stored'},                 -- 22
    {ctype='unsigned char',     label='Snowslit Stones +2 Stored'},                 -- 23
    {ctype='unsigned char',     label='Snowtip Stones Stored'},                     -- 24
    {ctype='unsigned char',     label='Snowtip Stones +1 Stored'},                  -- 25
    {ctype='unsigned char',     label='Snowtip Stones +2 Stored'},                  -- 26
    {ctype='unsigned char',     label='Snowdim Stones Stored'},                     -- 27
    {ctype='unsigned char',     label='Snowdim Stones +1 Stored'},                  -- 28
    {ctype='unsigned char',     label='Snowdim Stones +2 Stored'},                  -- 29
    {ctype='unsigned char',     label='Snoworb Stones Stored'},                     -- 2A
    {ctype='unsigned char',     label='Snoworb Stones +1 Stored'},                  -- 2B
    {ctype='unsigned char',     label='Snoworb Stones +2 Stored'},                  -- 2C
    {ctype='unsigned char',     label='Leafslit Stones Stored'},                    -- 2D
    {ctype='unsigned char',     label='Leafslit Stones +1 Stored'},                 -- 2E
    {ctype='unsigned char',     label='Leafslit Stones +2 Stored'},                 -- 2F
    {ctype='unsigned char',     label='Leaftip Stones Stored'},                     -- 30
    {ctype='unsigned char',     label='Leaftip Stones +1 Stored'},                  -- 31
    {ctype='unsigned char',     label='Leaftip Stones +2 Stored'},                  -- 32
    {ctype='unsigned char',     label='Leafdim Stones Stored'},                     -- 33
    {ctype='unsigned char',     label='Leafdim Stones +1 Stored'},                  -- 34
    {ctype='unsigned char',     label='Leafdim Stones +2 Stored'},                  -- 35
    {ctype='unsigned char',     label='Leaforb Stones Stored'},                     -- 36
    {ctype='unsigned char',     label='Leaforb Stones +1 Stored'},                  -- 37
    {ctype='unsigned char',     label='Leaforb Stones +2 Stored'},                  -- 38
    {ctype='unsigned char',     label='Duskslit Stones Stored'},                    -- 39
    {ctype='unsigned char',     label='Duskslit Stones +1 Stored'},                 -- 3A
    {ctype='unsigned char',     label='Duskslit Stones +2 Stored'},                 -- 3B
    {ctype='unsigned char',     label='Dusktip Stones Stored'},                     -- 3C
    {ctype='unsigned char',     label='Dusktip Stones +1 Stored'},                  -- 3D
    {ctype='unsigned char',     label='Dusktip Stones +2 Stored'},                  -- 3E
    {ctype='unsigned char',     label='Duskdim Stones Stored'},                     -- 3F
    {ctype='unsigned char',     label='Duskdim Stones +1 Stored'},                  -- 40
    {ctype='unsigned char',     label='Duskdim Stones +2 Stored'},                  -- 41
    {ctype='unsigned char',     label='Duskorb Stones Stored'},                     -- 42
    {ctype='unsigned char',     label='Duskorb Stones +1 Stored'},                  -- 43
    {ctype='unsigned char',     label='Duskorb Stones +2 Stored'},                  -- 44
    {ctype='unsigned char',     label='Pellucid Stones Stored'},                    -- 45
    {ctype='unsigned char',     label='Fern Stones Stored'},                        -- 46
    {ctype='unsigned char',     label='Taupe Stones Stored'},                       -- 47
    {ctype='unsigned short',    label='Mellidopt Wings Stored'},                    -- 48
    {ctype='unsigned short',    label='Escha Beads'},                               -- 4A
    {ctype='signed int',        label='Escha Silt'},                                -- 4C
    {ctype='signed int',        label='Potpourri'},                                 -- 50
    {ctype='signed int',        label='Hallmarks'},                                 -- 54
    {ctype='signed int',        label='Total Hallmarks'},                           -- 58
    {ctype='signed int',        label='Badges of Gallantry'},                       -- 5C
    {ctype='signed int',        label='Crafter Points'},                            -- 60
    {ctype='unsigned char',     label='Fire Crystals Set'},                         -- 64
    {ctype='unsigned char',     label='Ice Crystals Set'},                          -- 65
    {ctype='unsigned char',     label='Wind Crystals Set'},                         -- 66
    {ctype='unsigned char',     label='Earth Crystals Set'},                        -- 67
    {ctype='unsigned char',     label='Lightning Crystals Set'},                    -- 68
    {ctype='unsigned char',     label='Water Crystals Set'},                        -- 69
    {ctype='unsigned char',     label='Light Crystals Set'},                        -- 6A
    {ctype='unsigned char',     label='Dark Crystals Set'},                         -- 6B
    {ctype='unsigned char',     label='MC-S-SR01s Set'},                            -- 6C
    {ctype='unsigned char',     label='MC-S-SR02s Set'},                            -- 6D
    {ctype='unsigned char',     label='MC-S-SR03s Set'},                            -- 6E
    {ctype='unsigned char',     label='Liquefaction Spheres Set'},                  -- 6F
    {ctype='unsigned char',     label='Induration Spheres Set'},                    -- 70
    {ctype='unsigned char',     label='Detonation Spheres Set'},                    -- 71
    {ctype='unsigned char',     label='Scission Spheres Set'},                      -- 72
    {ctype='unsigned char',     label='Impaction Spheres Set'},                     -- 73
    {ctype='unsigned char',     label='Reverberation Spheres Set'},                 -- 74
    {ctype='unsigned char',     label='Transfixion Spheres Set'},                   -- 75
    {ctype='unsigned char',     label='Compression Spheres Set'},                   -- 76
    {ctype='unsigned char',     label='Fusion Spheres Set'},                        -- 77
    {ctype='unsigned char',     label='Distortion Spheres Set'},                    -- 78
    {ctype='unsigned char',     label='Fragmentation Spheres Set'},                 -- 79
    {ctype='unsigned char',     label='Gravitation Spheres Set'},                   -- 7A
    {ctype='unsigned char',     label='Light Spheres Set'},                         -- 7B
    {ctype='unsigned char',     label='Darkness Spheres Set'},                      -- 7C
    {ctype='data[0x03]',        label='_unknown1'},                                 -- 7D   Presumably Unused Padding
    {ctype='signed int',        label='Silver A.M.A.N. Vouchers Stored'},           -- 80
}

types.ability_recast = L{
    {ctype='unsigned short',    label='Duration',           fn=div+{1}},        -- 00
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        -- 02
    {ctype='unsigned char',     label='Recast',             fn=arecast},        -- 03
    {ctype='unsigned int',      label='_unknown2'}                              -- 04
}

-- Ability timers
fields.incoming[0x119] = L{
    {ref=types.ability_recast,                              count=0x1F},        -- 04
}

return fields

--[[
Copyright © 2013-2015, Windower
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Windower nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Windower BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
