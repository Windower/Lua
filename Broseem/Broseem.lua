--[[
broseem v1.20161007

Copyright © 2016, Mojo
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of timestamp nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Giuliano Riccio BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'broseem'
_addon.author   = 'Mojo'
_addon.version  = '1.20161007'
_addon.commands = {'broseem'}

require('pack')
require('lists')
require('logger')
require('sets')

files = require('files')
extdata = require('extdata')
packets = require('packets')

local item = {}
local hook = false

local stones = {
    [0] = 'pellucid',
    [1] = 'fern',
    [2] = 'taupe',
    [3] = 'dark matter',
}

local paths = {
    [8] = 'melee',
    [264] = 'ranged',
    [520] = 'magic',
    [776] = 'familiar',
    [1032] = 'healing',
    [1290] = 'techniques',
}

local gear = {
    [27496] = 'Herculean Boots',
    [27140] = 'Herculean Gloves',
    [25642] = 'Herculean Helm',
    [25842] = 'Herculean Trousers',
    [25718] = 'Herculean Vest',
    [27497] = 'Merlinic Crackows',
    [27141] = 'Merlinic Dastanas',
    [25643] = 'Merlinic Hood',
    [25719] = 'Merlinic Jubbah',
    [25843] = 'Merlinic Shalwar',
    [25716] = 'Odyssean Chestplate',
    [25840] = 'Odyssean Cuisses',
    [27138] = 'Odyssean Gauntlets',
    [27494] = 'Odyssean Greaves',
    [25640] = 'Odyssean Helm',
    [25841] = 'Valorous Hose',
    [27495] = 'Valorous Greaves',
    [25717] = 'Valorous Mail',
    [25641] = 'Valorous Mask',
    [27139] = 'Valorous Mitts',
    [25720] = 'Chironic Doublet',
    [27142] = 'Chironic Gloves',
    [25644] = 'Chironic Hat',
    [25844] = 'Chironic Hose',
    [27498] = 'Chironic Slippers',
    [21754] = 'Aganoshe',
    [20677] = 'Colada',
    [20505] = 'Condemners',
    [21746] = 'Digirbalag',
    [21072] = 'Gada',
    [22054] = 'Grioavolr',
    [22134] = 'Holliday',
    [21904] = 'Kanaria',
    [21804] = 'Obschine',
    [21854] = 'Reienkyo',
    [20579] = 'Skinflayer',
    [22113] = 'Teller',
    [21021] = 'Umaru',
    [21686] = 'Zulfiqar',
}

function make_timestamp()
    return os.date('%Y:%m:%d %H:%M:%S')
end

local function save_augments()
    local fh
    local path = 'data/%s_augments.csv':format(windower.ffxi.get_player().name)
    if not files.exists(path) then
        files.create_path('data')
        fh = io.open(windower.addon_path .. path, 'w')
        local header = "timestamp,name,stone,path,augment 1,augment 2,augment 3,augment 4,augment 5\r"
        fh:write(header)
        fh:close()
    end
    fh = io.open(windower.addon_path .. path, 'a')
    local output = "%s,%s,%s,%s,":format(make_timestamp(),item.name, item.stone, item.path)
    for i = 1, 4 do
        output = output.."%s,":format(item.augments.augments[i])
    end
    output = output.."%s\r":format(item.augments.augments[5])
    local fh = io.open(windower.addon_path .. path, 'a')
    fh:write(output)
    fh:close()
end

local function watch_trade(id, org)
    if id == 0x36 then
        local p = packets.parse('outgoing', org)
        local name = (windower.ffxi.get_mob_by_id(p['Target']) or {}).name
        if (name == 'Oseem') and (p['Number of Items'] == 1) then
            item = windower.ffxi.get_items(0, p['Item Index 1'])
        end
    end
end

local function broseemify(id, org)
    if (id == 0x5B) and item.id then
        local p = packets.parse('outgoing', org)
        local name = (windower.ffxi.get_mob_by_id(p['Target']) or {}).name
        if name == 'Oseem' and paths[p['Option Index']] then
            item.stone = stones[p['_unknown1']]
            item.path = paths[p['Option Index']]
            hook = true
        end
    end
end

local function log_augments(id, data)
    if (id == 0x5c) and hook then
        local p = packets.parse('incoming', data)
        item.extdata = p['Menu Parameters']:sub(21)..item.extdata:sub(13)
        item.augments = extdata.decode(item)
        item.name = gear[item.id]
        save_augments()
        hook = false
    end
end

windower.register_event('outgoing chunk', watch_trade)
windower.register_event('incoming chunk', log_augments)
windower.register_event('outgoing chunk', broseemify)

windower.register_event('addon command', function (...)
    local args    = T{...}:map(string.lower)
    if args[1] == nil or args[1] == "help" then
        log('%s v%s':format(_addon.name, _addon.version))
        log('There are no commands for this add-on. You just have it on while your augmenting you Reisenjima Gear will log it.')
        log('Please just once in a while upload your augments.csv file located in the folder: broseem/data to')
        log('http://tinyurl.com/Broseem')
        log('Full Length URL: https://drive.google.com/drive/folders/0B8xuIyjPy66QYlJLRWt5ZVBQTnM?usp=sharing')
        log('There is no need for you to worry about clearing out old augments for us we can handle duplicates no problem!')

    else
        log('%s v%s':format(_addon.name, _addon.version))
        log('There are no commands for this add-on. You just have it on while your augmenting you Reisenjima Gear will log it.')
        log('Please just once in a while upload your data.csv file located in the folder: broseem/settings to')
        log('http://tinyurl.com/Broseem')
        log('Full Length URL: https://drive.google.com/drive/folders/0B8xuIyjPy66QYlJLRWt5ZVBQTnM?usp=sharing')
        log('There is no need for you to worry about clearing out old augments for us we can handle duplicates no problem!')

    end
end)
