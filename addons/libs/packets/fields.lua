--[[
    A collection of detailed packet field information.
]]

require('pack')
require('functools')
require('stringhelper')
require('mathhelper')

local fields = {}
fields.outgoing = {_mult = {}}
fields.incoming = {_mult = {}}

local indices = {}
indices.outgoing = {}
indices.incoming = {}

-- String decoding definitions
local ls_name_msg = T(('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'):split())
ls_name_msg[0] = string.char(0)
local item_inscr = T(('0123456798ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{'):split())
item_inscr[0] = string.char(0)
local ls_name_ext = T(('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'..string.char(0):rep(11)):split())
ls_name_ext[0] = '`'

-- Function definitions. Used to display packet field information.

res = require('resources')

local function id(val)
    local mob = get_mob_by_id(val)
    return mob and mob.name
end

local function index(val)
    local mob = get_mob_by_index(val)
    return mob and mob.name
end

local function ip(val)
    return (val / 2^24):floor()..'.'..((val / 2^16):floor() % 0x100)..'.'..((val / 2^8):floor() % 0x100)..'.'..(val % 0x100)
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

-- Client Leave
fields.outgoing[0x00D] = L{
    {ctype='unsigned char',     label='_unknown1'},                             --    4 -   4 -- Always 00?
    {ctype='unsigned char',     label='_unknown2'},                             --    5 -   5 -- Always 00?
    {ctype='unsigned char',     label='_unknown3'},                             --    6 -   6 -- Always 00?
    {ctype='unsigned char',     label='_unknown4'},                             --    7 -   7 -- Always 00?
}

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

-- Action
fields.outgoing[0x01A] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             --    4 -   7
    {ctype='unsigned short',    label='Target Index',       fn=index},          --    8 -   9
    {ctype='unsigned short',    label='Category'},                              --   10 -  11
    {ctype='unsigned short',    label='Param'},                                 --   12 -  13
    {ctype='unsigned short',    label='_unknown1'},                             --   14 -  15
}

-- Sort Item
fields.outgoing[0x03A] = L{
    {ctype='unsigned char',     label='Storage ID'},                            --    4 -   4
    {ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
    {ctype='unsigned short',    label='_unknown2'},                             --    6 -   7
}

-- Equip
fields.outgoing[0x050] = L{
    {ctype='unsigned char',     label='Inventory ID'},                          --    4 -   4
    {ctype='unsigned char',     label='Equip Slot'},                            --    5 -   5
    {ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
    {ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Conquest
fields.outgoing[0x05A] = L{
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

-- Equipment Screen (0x02 length) -- Also observed when zoning
fields.outgoing[0x061] = L{
}

-- Party invite
fields.outgoing[0x06E] = L{
    {ctype='unsigned int',      label='Target ID',          fn=id},             --    4 -   7  This is so weird. The client only knows IDs from searching for people or running into them. So if neither has happened, the manual invite will fail, as the ID cannot be retrieved.
    {ctype='unsigned short',    label='Target index',       fn=index},          --    8 -   9  00 if target not in zone
    {ctype='unsigned char',     label='Alliance'},                              --   10 -  10  02 for alliance, 00 for party or if invalid alliance target (the client somehow knows..)
    {ctype='unsigned char',     label='_const1',            const=0x041},       --   11 -  11
}

-- Party leaving
fields.outgoing[0x06F] = L{
    {ctype='unsigned char',     label='_const1',            const=0x00},        --    4 -   4
    {ctype='unsigned char[3]',  label='_junk1'},                                --    5 -   7
}

-- Party breakup
fields.outgoing[0x070] = L{
    {ctype='unsigned char',     label='Alliance'},                              --    4 -   4  02 for alliance, 00 for party
    {ctype='unsigned char[3]',  label='_junk1'},                                --    5 -   7
}

-- Party invite response
fields.outgoing[0x074] = L{
    {ctype='unsigned char',     label='Join',               fn=bool},           --    4 -   4
    {ctype='unsigned char[3]',  label='_junk1'},                                --    5 -   7
}

-- Party change leader
fields.outgoing[0x077] = L{
    {ctype='char[16]',          label='Target name'},                           --    4 -  19  Name of the person to give leader to
    {ctype='unsigned short',    label='Alliance'},                              --   22 -  23  02 01 for alliance, 00 00 for party
    {ctype='unsigned short',    label='_unknown1'},                             --   22 -  23
}

-- Speech
fields.outgoing[0x0B5] = L{
    {ctype='unsigned short',    label='GM'},                                    --    4 -   5   05 00 for LS chat?
    {ctype='char[255]',         label='Message'},                               --    6 - 260   Message, occasionally terminated by spare 00 bytes.
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

-- Widescan
fields.outgoing[0x0F4] = L{
    {ctype='unsigned char',     label='Flags'},                                 --    4 -   4  -- 1 when requesting widescan information. No other values observed.
    {ctype='unsigned char',     label='_unknown1'},                             --    5 -   5
    {ctype='unsigned short',    label='_unknown2'},                             --    6 -   7
}

-- Job Change
fields.outgoing[0x100] = L{
    {ctype='unsigned char',     label='Main Job ID'},                           --    4 -   4
    {ctype='unsigned char',     label='Sub Job ID'},                            --    5 -   5
    {ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
    {ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Untraditional Equip
-- Currently only commented for changing instincts in Monstrosity. Refer to the doku wiki for information on Autos/BLUs.
-- http://dev.windower.net/doku.php?id=packets:outgoing:0x102_blue_magic_pup_attachment_equip
fields.outgoing[0x102] = L{
    {ctype='unsigned short',    label='_unknown1'},                             --    4 -   5  -- 00 00 for Monsters
    {ctype='unsigned short',    label='_unknown1'},                             --    6 -   7  -- Varies by Monster family for the species change packet. Monsters that share the same tnl seem to have the same value. 00 00 for instinct changing.
    {ctype='unsigned char',     label='Main Job ID'},                           --    8 -   8  -- 0x17 for Monsters
    {ctype='unsigned char',     label='Sub Job ID'},                            --    9 -   9  -- 0x00 for Monsters
    {ctype='unsigned short',    label='Flag'},                                  --   10 -  11  -- 04 00 for Monsters changing instincts. 01 00 for changing Monsters
    {ctype='unsigned short',    label='Species ID'},                            --   12 -  13  -- True both for species change and instinct change packets
    {ctype='unsigned short',    label='_unknown2'},                             --   14 -  15  -- 00 00 for Monsters
    {ctype='unsigned short',    label='Instinct ID 1'},                         --   16 -  17
    {ctype='unsigned short',    label='Instinct ID 2'},                         --   18 -  19
    {ctype='unsigned short',    label='Instinct ID 3'},                         --   20 -  21
    {ctype='unsigned short',    label='Instinct ID 4'},                         --   22 -  23
    {ctype='unsigned short',    label='Instinct ID 5'},                         --   24 -  25
    {ctype='unsigned short',    label='Instinct ID 6'},                         --   26 -  27
    {ctype='unsigned short',    label='Instinct ID 7'},                         --   28 -  29
    {ctype='unsigned short',    label='Instinct ID 8'},                         --   30 -  31
    {ctype='unsigned short',    label='Instinct ID 9'},                         --   32 -  33
    {ctype='unsigned short',    label='Instinct ID 10'},                        --   34 -  35
    {ctype='unsigned short',    label='Instinct ID 11'},                        --   36 -  37
    {ctype='unsigned short',    label='Instinct ID 12'},                        --   38 -  39
    {ctype='unsigned char',     label='Name ID 1'},                             --   40 -  40
    {ctype='unsigned char',     label='Name ID 2'},                             --   41 -  41
    {ctype='char*',             label='_unknown'},                              --   42 - 159  -- All 00s for Monsters
}

-- Login
fields.incoming[0x00A] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --    4 -   7
    {ctype='unsigned short',    label='Player index',       fn=index},          --    8 -   9
    {ctype='char[38]',          label='_unknown1'},                             --   10 -  47
    {ctype='unsigned char',     label='Zone ID',            fn=zone},           --   48 -  48
    {ctype='char[19]',          label='_unknown3'},                             --   49 -  67
    {ctype='unsigned char',     label='Weather ID'},                            --   68 -  68
    {ctype='char[63]',          label='_unknown4'},                             --   69 - 131
    {ctype='char[16]',          label='Player name'},                           --  132 - 147
    {ctype='char[113]',         label='_unknown5'},                             --  148 - 259
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
	-- The flags in this byte are complicated and may not strictly be flags. 
	-- Byte 32: -- Mentor is somewhere in this byte
	-- 1 = None
	-- 2 = Deletes everyone
	-- 4 = Deletes everyone
	-- 8 = None
	-- 16 = None
	-- 32 = None
	-- 64 = None
	-- 128 = None
	
	
	-- Byte 33:
	-- 1 = None
	-- 2 = None
	-- 4 = None
	-- 8 = LFG
	-- 16 = Anon
	-- 32 = Turns your name orange
	-- 64 = Away
	-- 128 = None
	
	-- Byte 34:
	-- 1 = POL Icon, can target?
	-- 2 = no notable effect
	-- 4 = DCing
	-- 8 = Untargettable
	-- 16 = No linkshell
	-- 32 = No Linkshell again
	-- 64 = No linkshell again
	-- 128 = No linkshell again
	
	-- Byte 35:
	-- 1 = Trial Account
	-- 2 = Trial Account
	-- 4 = GM Mode
	-- 8 = None
	-- 16 = None
	-- 32 = Invisible models
	-- 64 = None
	-- 128 = Bazaar
    {ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
    {ctype='unsigned short',    label='Index',              fn=index},          --    8 -   9
    {ctype='unsigned char',     label='Mask'},                                  --   10 -  10
    {ctype='unsigned char',     label='Body Rotation'},                         --   11 -  11
    {ctype='float',             label='X Position'},                            --   12 -  15
    {ctype='float',             label='Z Position'},                            --   16 -  19
    {ctype='float',             label='Y Position'},                            --   20 -  23
    {ctype='unsigned short',    label='Head Rotation'},                         --   24 -  25
    {ctype='unsigned short',    label='M_TID'},                                 --   26 -  27
    {ctype='unsigned char',     label='Current Speed'},                         --   28 -  28
    {ctype='unsigned char',     label='Base Speed'},                            --   29 -  29
    {ctype='unsigned char',     label='HP %',               fn=percent},        --   30 -  30
    {ctype='unsigned char',     label='Animation'},                             --   31 -  31
    {ctype='unsigned short',    label='Status'},                                --   32 -  33
    {ctype='unsigned short',    label='Flags'},                                 --   34 -  35
    {ctype='unsigned char',     label='Linkshell Red'},                         --   36 -  36
    {ctype='unsigned char',     label='Linkshell Green'},                       --   37 -  37
    {ctype='unsigned char',     label='Linkshell Blue'},                        --   38 -  38
    {ctype='unsigned char',     label='_unknown3'},                             --   39 -  42
    {ctype='unsigned int',      label='_unknown4'},                             --   43 -  46 -- Flags again
    {ctype='unsigned int',      label='_unknown5'},                             --   47 -  50
    {ctype='unsigned int',      label='_unknown6'},                             --   51 -  54 -- DSP notes that the 6th bit of byte 54 is the Ballista flag
    {ctype='unsigned int',      label='_unknown7'},                             --   55 -  58
    {ctype='unsigned int',      label='_unknown8'},                             --   59 -  62
    {ctype='unsigned int',      label='_unknown9'},                             --   63 -  66
    {ctype='unsigned char',     label='Face Flags'},                            --   67 -  67 -- 0, 3, 4, or 8
    {ctype='unsigned char',     label='Face'},                                  --   68 -  68
    {ctype='unsigned char',     label='Race'},                                  --   69 -  69
    {ctype='unsigned short',    label='Head'},                                  --   70 -  71
    {ctype='unsigned short',    label='Body'},                                  --   72 -  73
    {ctype='unsigned short',    label='Hands'},                                 --   74 -  75
    {ctype='unsigned short',    label='Legs'},                                  --   76 -  77
    {ctype='unsigned short',    label='Feet'},                                  --   78 -  79
    {ctype='unsigned short',    label='Main'},                                  --   80 -  81
    {ctype='unsigned short',    label='Sub'},                                   --   82 -  83
    {ctype='unsigned short',    label='Ranged'},                                --   84 -  85
    {ctype='char*',             label='Character Name'},                        --   86 -  95 -- Variable length, null terminated maybe
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
    {ctype='bool',              label='GM'},                                    --    5 -   5   1 for GM or 0 for not
    {ctype='unsigned short',    label='Zone ID',            fn=zone},           --    6 -   7   Zone ID, used for Yell
    {ctype='char[16]',          label='Sender Name'},                           --    8 -  22   Name
    {ctype='char*',             label='Message'},                               --   23 - 253   Message, occasionally terminated by spare 00 bytes.
}

-- Job Info
fields.incoming[0x01B] = L{
    {ctype='unsigned int',      label='_unknown1'},                             --    4 -   7   Observed value of 05
    {ctype='unsigned char',     label='Main Job ID'},                           --    8 -   8
    {ctype='unsigned char',     label='Flag or Main Job Level?'},               --    9 -   9
    {ctype='unsigned char',     label='Flag or Sub Job Level?'},                --   10 -  10
    {ctype='unsigned char',     label='Sub Job ID'},                            --   11 -  11
    {ctype='unsigned int',      label='_unknown2'},                             --   12 -  15   Flags -- FF FF FF 00 observed
    {ctype='unsigned char',     label='_unknown3'},                             --   16 -  16   Flag or List Start
    {ctype='unsigned char',     label='WAR Level'},                             --   17 -  17
    {ctype='unsigned char',     label='MNK Level'},                             --   18 -  18
    {ctype='unsigned char',     label='WHM Level'},                             --   19 -  19
    {ctype='unsigned char',     label='BLM Level'},                             --   20 -  20
    {ctype='unsigned char',     label='RDM Level'},                             --   21 -  21
    {ctype='unsigned char',     label='THF Level'},                             --   22 -  22
    {ctype='unsigned char',     label='PLD Level'},                             --   23 -  23
    {ctype='unsigned char',     label='DRK Level'},                             --   24 -  24
    {ctype='unsigned char',     label='BST Level'},                             --   25 -  25
    {ctype='unsigned char',     label='BRD Level'},                             --   26 -  26
    {ctype='unsigned char',     label='RNG Level'},                             --   27 -  27
    {ctype='unsigned char',     label='SAM Level'},                             --   28 -  28
    {ctype='unsigned char',     label='NIN Level'},                             --   29 -  29
    {ctype='unsigned char',     label='DRG Level'},                             --   30 -  30
    {ctype='unsigned char',     label='SMN Level'},                             --   31 -  31
    {ctype='unsigned short',    label='Base STR'},                              --   32 -  33
    {ctype='unsigned short',    label='Base DEX'},                              --   34 -  35
    {ctype='unsigned short',    label='Base VIT'},                              --   36 -  37
    {ctype='unsigned short',    label='Base AGI'},                              --   38 -  39
    {ctype='unsigned short',    label='Base INT'},                              --   40 -  41
    {ctype='unsigned short',    label='Base MND'},                              --   42 -  43
    {ctype='unsigned short',    label='Base CHR'},                              --   44 -  45
    {ctype='char[14]',          label='_unknown4'},                             --   46 -  59   Flags and junk? Hard to say. All 0s observed.
    {ctype='unsigned int',      label='Maximum HP'},                            --   60 -  63
    {ctype='unsigned int',      label='Maximum MP'},                            --   64 -  67
    {ctype='unsigned int',      label='Flags'},                                 --   68 -  71   Looks like a bunch of flags. Observed value if 01 00 00 00
    {ctype='unsigned char',     label='_unknown5'},                             --   72 -  72   Potential flag to signal the list start. Observed value of 01
    {ctype='unsigned char',     label='WAR Level'},                             --   73 -  73
    {ctype='unsigned char',     label='MNK Level'},                             --   74 -  74
    {ctype='unsigned char',     label='WHM Level'},                             --   75 -  75
    {ctype='unsigned char',     label='BLM Level'},                             --   76 -  76
    {ctype='unsigned char',     label='RDM Level'},                             --   77 -  77
    {ctype='unsigned char',     label='THF Level'},                             --   78 -  78
    {ctype='unsigned char',     label='PLD Level'},                             --   79 -  79
    {ctype='unsigned char',     label='DRK Level'},                             --   80 -  80
    {ctype='unsigned char',     label='BST Level'},                             --   81 -  81
    {ctype='unsigned char',     label='BRD Level'},                             --   82 -  82
    {ctype='unsigned char',     label='RNG Level'},                             --   83 -  83
    {ctype='unsigned char',     label='SAM Level'},                             --   84 -  84
    {ctype='unsigned char',     label='NIN Level'},                             --   85 -  85
    {ctype='unsigned char',     label='DRG Level'},                             --   86 -  86
    {ctype='unsigned char',     label='SMN Level'},                             --   87 -  87
    {ctype='unsigned char',     label='BLU Level'},                             --   88 -  88
    {ctype='unsigned char',     label='COR Level'},                             --   89 -  89
    {ctype='unsigned char',     label='PUP Level'},                             --   90 -  90
    {ctype='unsigned char',     label='DNC Level'},                             --   91 -  91
    {ctype='unsigned char',     label='SCH Level'},                             --   92 -  92
    {ctype='unsigned char',     label='GEO Level'},                             --   93 -  93
    {ctype='unsigned char',     label='RUN Level'},                             --   94 -  94
    {ctype='unsigned char',     label='Current Monster Level'},                 --   95 -  95
    {ctype='unsigned int',      label='_unknown6'},                             --   96 -  99   Observed value of 00 00 00 00
}

-- Item Assign
fields.incoming[0x01F] = L{
    {ctype='unsigned short',    label='_unknown1'},                             --    4 -   5
    {ctype='unsigned short',    label='_unknown2'},                             --    6 -   7
    {ctype='unsigned short',    label='Item ID',            fn=item},           --    8 -   9
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

-- Count to 80
fields.incoming[0x026] = L{
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        --    4 -   4
    {ctype='unsigned char',     label='Counter'},                               --    5 -   5   Varies sequentially between 0x01 and 0x50
    {ctype='char[22]',          label='_unknown2',          const=0},           --    6 -  27
}

-- Synth Animation
fields.incoming[0x030] = L{
    {ctype='unsigned int',      label='Player ID',          fn=id},             --    4 -  7
    {ctype='unsigned short',    label='Index',              fn=index},          --    8 -  9
    {ctype='unsigned short',    label='Effect'},                                --   10 -  11  -- 10 00 is water, 11 00 is wind, 12 00 is fire, 13 00 is earth, 14 00 is lightning, 15 00 is ice, 16 00 is light, 17 00 is dark
    {ctype='unsigned char',     label='Param'},                                 --   12 -  12  -- 00 is NQ, 01 is break, 02 is HQ
    {ctype='unsigned char',     label='Animation'},                             --   13 -  13  -- Always C2 for me.
    {ctype='unsigned char',     label='_unknown1',          const=0x00},        --   14 -  15  -- Appears to just be trash.
}

-- Pet Stat
-- This packet varies and is indexed by job ID (byte 4)
fields.incoming._mult[0x044] = {}
indices.incoming[0x044] = {byte = 4, length = 1}

fields.incoming._mult[0x044][0x12] = L{     -- PUP
-- Packet 0x044 is sent twice in sequence when stats could change. This can be caused by anything from
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
    {ctype='unsigned char',     label='_unknown1'},                             --    4 -   4   Can contain inventory size (0x51)
    {ctype='unsigned char',     label='_unknown2'},                             --    5 -   5   Can contain inventory size (0x51)
    {ctype='unsigned char',     label='_unknown3'},                             --    6 -   6   Can contain inventory size (0x51)
    {ctype='unsigned char',     label='_unknown4'},                             --    7 -   7
}

-- Equip
fields.incoming[0x050] = L{
    {ctype='unsigned char',     label='Inventory ID'},                          --    4 -   4
    {ctype='unsigned char',     label='Equip Slot'},                            --    5 -   5
    {ctype='unsigned char',     label='_unknown1'},                             --    6 -   6
    {ctype='unsigned char',     label='_unknown2'},                             --    7 -   7
}

-- Model Change
fields.incoming[0x051] = L{
    {ctype='unsigned char',     label='Face'},                                  --    4 -   4
    {ctype='unsigned char',     label='Race'},                                  --    5 -   5
    {ctype='unsigned short',    label='Head'},                                  --    6 -   7
    {ctype='unsigned short',    label='Body'},                                  --    8 -   9
    {ctype='unsigned short',    label='Hands'},                                 --   10 -  11
    {ctype='unsigned short',    label='Legs'},                                  --   12 -  13
    {ctype='unsigned short',    label='Feet'},                                  --   14 -  15
    {ctype='unsigned short',    label='Main'},                                  --   16 -  17
    {ctype='unsigned short',    label='Sub'},                                   --   18 -  19
    {ctype='unsigned short',    label='Ranged'},                                --   20 -  21
    {ctype='unsigned short',    label='_unknown1'},                             --   22 -  23   May varying meaningfully, but it's unclear
}

-- Weather Change
fields.incoming[0x057] = L{
    {ctype='unsigned int',      label='Vanadiel Time',      fn=vtime},          --    4 -   7   Units of minutes.
    {ctype='unsigned char',     label='Weather ID',         fn=weather},        --    8 -   8
    {ctype='unsigned char',     label='_unknown1'},                             --    9 -   9
    {ctype='unsigned short',    label='_unknown2'},                             --   10 -  11
}

-- Char Stats
fields.incoming[0x061] = L{
    {ctype='unsigned int',      label='Maximum HP'},                            --    4 -   7
    {ctype='unsigned int',      label='Maximum MP'},                            --    8 -  11
    {ctype='unsigned char',     label='Main Job ID',        fn=job},            --   12 -  12
    {ctype='unsigned char',     label='Main Job Level'},                        --   13 -  13
    {ctype='unsigned char',     label='Sub Job ID',         fn=job},            --   14 -  14
    {ctype='unsigned char',     label='Sub Job Level'},                         --   15 -  15
    {ctype='unsigned short',    label='Current EXP'},                           --   16 -  17
    {ctype='unsigned short',    label='Required EXP'},                          --   18 -  19
    {ctype='unsigned short',    label='Base STR'},                              --   20 -  21
    {ctype='unsigned short',    label='Base DEX'},                              --   22 -  23
    {ctype='unsigned short',    label='Base VIT'},                              --   24 -  25
    {ctype='unsigned short',    label='Base AGI'},                              --   26 -  27
    {ctype='unsigned short',    label='Base INT'},                              --   28 -  29
    {ctype='unsigned short',    label='Base MND'},                              --   30 -  31
    {ctype='unsigned short',    label='Base CHR'},                              --   32 -  33
    {ctype='signed short',      label='Added STR'},                             --   34 -  35
    {ctype='signed short',      label='Added DEX'},                             --   36 -  37
    {ctype='signed short',      label='Added VIT'},                             --   38 -  39
    {ctype='signed short',      label='Added AGI'},                             --   40 -  41
    {ctype='signed short',      label='Added INT'},                             --   42 -  43
    {ctype='signed short',      label='Added MND'},                             --   44 -  45
    {ctype='signed short',      label='Added CHR'},                             --   46 -  47
    {ctype='unsigned short',    label='Attack'},                                --   48 -  49
    {ctype='unsigned short',    label='Defense'},                               --   50 -  51
    {ctype='signed short',      label='Fire Resistance'},                       --   52 -  53
    {ctype='signed short',      label='Wind Resistance'},                       --   54 -  55
    {ctype='signed short',      label='Thunder Resistance'},                    --   56 -  57
    {ctype='signed short',      label='Light Resistance'},                      --   58 -  59
    {ctype='signed short',      label='Ice Resistance'},                        --   60 -  61
    {ctype='signed short',      label='Earth Resistance'},                      --   62 -  63
    {ctype='signed short',      label='Water Resistance'},                      --   64 -  65
    {ctype='signed short',      label='Dark Resistance'},                       --   66 -  67
    {ctype='unsigned short',    label='Title ID',           fn=title},          --   68 -  69
    {ctype='unsigned short',    label='Nation rank'},                           --   70 -  71
    {ctype='unsigned short',    label='Rank points',        fn=cap-{0xFFF}},    --   72 -  73
    {ctype='unsigned short',    label='Home point',         fn=zone},           --   74 -  75
    {ctype='unsigned short',    label='_unknown23'},                            --   76 -  77
    {ctype='unsigned short',    label='_unknown24'},                            --   78 -  79
    {ctype='unsigned short',    label='_unknown25'},                            --   80 -  81
    {ctype='unsigned short',    label='_unknown26'},                            --   82 -  83   00 00 observed.
}

-- Unnamed 0x067
fields.incoming[0x067] = L{
-- The length of this packet is 28 or 40 bytes. 28 appears to be for NPCs/monsters
-- and 40 appears to be for players. _unknown1 is 02 09 for players and 03 05 for
-- NPCs. The use of this packet is unclear.
    {ctype='unsigned short',    label='_unknown1'},                             --    4 -   5
    {ctype='unsigned short',    label='Player Index',       fn=index},          --    6 -   7
    {ctype='unsigned int',      label='Player ID',          fn=id},             --    8 -  11
}

-- LS Message
fields.incoming[0x0CC] = L{
    {ctype='int',               label='_unknown1'},                             --    4 -   7
    {ctype='char[128]',         label='Message'},                               --    8 - 135
    {ctype='unsigned int',      label='Timestamp',          fn=time},           --  136 - 139
    {ctype='char[16]',          label='Player Name'},                           --  140 - 155
    {ctype='unsigned int',      label='Permissions'},                           --  156 - 159
    {ctype='char[16]',          label='Linkshell Name',     enc=ls_name_msg},   --  160 - 175   6-bit packed
}

-- Bazaar Message
fields.incoming[0x0CA] = L{
    {ctype='int',               label='_unknown1'},                             --    4 -   7   Could be characters starting the line - FD 02 02 18 observed
    {ctype='unsigned short',    label='_unknown2'},                             --    8 -   9   Could also be characters starting the line - 01 FD observed
    {ctype='char[118]',         label='Bazaar Message'},                        --   10 - 127   Terminated with a vertical tab
    {ctype='char[16]',          label='Player Name'},                           --  128 - 143
    {ctype='unsigned short',    label='_unknown3'},                             --  144 - 145   C6 01 observed. Not player index.
    {ctype='unsigned short',    label='_unknown4'},                             --  146 - 147   00 00 observed.
}

-- Char Update
fields.incoming[0x0DF] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
    {ctype='unsigned int',      label='HP'},                                    --    8 -  11
    {ctype='unsigned int',      label='MP'},                                    --   12 -  15
    {ctype='unsigned int',      label='TP'},                                    --   16 -  19   Truncated, does not include the decimal value.
    {ctype='unsigned short',    label='Player Index',       fn=index},          --   20 -  21
    {ctype='unsigned char',     label='HPP'},                                   --   22 -  22
    {ctype='unsigned char',     label='MPP'},                                   --   23 -  23
    {ctype='unsigned short',    label='_unknown1'},                             --   24 -  25
    {ctype='unsigned short',    label='_unknown2'},                             --   26 -  27
}

-- Char Info
fields.incoming[0x0E2] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
    {ctype='unsigned int',      label='HP'},                                    --    8 -  11
    {ctype='unsigned int',      label='MP'},                                    --   12 -  15
    {ctype='unsigned int',      label='TP'},                                    --   16 -  19
    {ctype='unsigned int',      label='_unknown1'},                             --   20 -  23   Looks like it could be flags for something.
    {ctype='unsigned short',    label='Player Index',       fn=index},          --   24 -  25
    {ctype='unsigned char',     label='_unknown2'},                             --   26 -  26
    {ctype='unsigned char',     label='_unknown3'},                             --   27 -  27
    {ctype='unsigned char',     label='_unknown4'},                             --   28 -  28
    {ctype='unsigned char',     label='HPP'},                                   --   29 -  29
    {ctype='unsigned char',     label='MPP'},                                   --   30 -  30
    {ctype='unsigned char',     label='_unknown5'},                             --   31 -  31
    {ctype='unsigned char',     label='_unknown6'},                             --   32 -  32
    {ctype='unsigned char',     label='_unknown7'},                             --   32 -  33   Could be an initialization for the name. 0x01 observed.
    {ctype='char[10]',          label='Player Name'},                           --   34 -  34   Maybe a base stat
}

-- Widescan Mob
fields.incoming[0x0F4] = L{
    {ctype='unsigned float',    label='X Position'},                            --    4 -   7 -- May be reversed with Y position
    {ctype='unsigned float',    label='Y Position'},                            --    8 -  11
    {ctype='char[16]',          label='Name'},                                  --   12 -  27 -- May not extend all the way to 27. Up to 25 has been observed
}

-- Widescan Mark
fields.incoming[0x0F6] = L{
    {ctype='unsigned char',     label='flags'},                                 --    4 -   4 -- 1 for the start of a widescan list. 2 for the end of the list.
    {ctype='unsigned char',     label='_unknown1'},                             --    5 -   5 -- No observed non-0 values
    {ctype='unsigned short',    label='_unknown2'},                             --    6 -   7 -- No observed non-0 values
}

-- Reraise Activation
fields.incoming[0x0F9] = L{
    {ctype='unsigned int',      label='ID',                 fn=id},             --    4 -   7
    {ctype='unsigned short',    label='Player Index'},                          --    8 -   9
    {ctype='unsigned char',     label='_unknown1'},                             --   10 -  10
    {ctype='unsigned char',     label='_unknown2'},                             --   11 -  11
}

local pack_strs = {
    [1] = 'b',
    [2] = 'H',
    [4] = 'I',
}

function fields.get(dir, id, data)
    if fields[dir][id] then
        return fields[dir][id]
    end

    local index = indices[dir][id]
    if index then
        return (fields[dir]._mult[id][data:sub(index.byte + 1):unpack(pack_strs[index.length])])
    end
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
