--[[Copyright © 2015, Kenshi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of BCTimer nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL KENSHI BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.]]

_addon.name = 'TreasurePool'
_addon.author = 'Kenshi'
_addon.version = '1.0'

require('luau')
texts = require('texts')
packets = require('packets')

-- Config

defaults = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.bg.visible = true
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

settings = config.load(defaults)
settings:save()

treasure = texts.new(settings.display, settings)

treasure:appendline('Treasure Pool:')
for i = 0, 9 do
    treasure:appendline(i .. ': ${index' .. i .. '|-}${lotting' .. i .. '}')
end

goals = {}

lotter = {}

lot = {}

windower.register_event('incoming chunk', function(id, data)

    if id == 0x0D2 then
 
    local packet = packets.parse('incoming', data)
    local time_check = packet.Timestamp + 300
    local diff = os.difftime(time_check, os.time())
        -- Ignore gil drop
        if packet.Item == 0xFFFF then
            return
        end
        if diff <= 300 then
            goals[packet.Index] = packet.Timestamp + 300
            lotter[packet.Index] = ' '
        else
            goals[packet.Index] = os.time() + 300
            lotter[packet.Index] = ' '
        end
    
    end
    
    if id == 0x0D3 then
 
    local lotpacket = packets.parse('incoming', data)
 
        -- Ignore drop to a player or floored
        if lotpacket.Drop ~= 0 then
            return
        else    
            lotter[lotpacket.Index] = lotpacket['Highest Lotter Name']
            lot[lotpacket.Index] = lotpacket['Highest Lot']
        end
    
    end
    
    -- Check to hide text box if zoning with treasure up
    if id == 0xB then
        zoning_bool = true
    elseif id == 0xA and zoning_bool then
        zoning_bool = nil
    end
    
end)

windower.register_event('prerender', function()
    local get_item = windower.ffxi.get_items()
    local remove = S{}
    local info = {}
    if zoning_bool or (not get_item.treasure[0] and not get_item.treasure[1] and not get_item.treasure[2] and not get_item.treasure[3] and not get_item.treasure[4] and not get_item.treasure[5] and not get_item.treasure[6] and not get_item.treasure[7] and not get_item.treasure[8] and not get_item.treasure[9]) then
        remove:add('index0') remove:add('index1') remove:add('index2') remove:add('index3') remove:add('index4') remove:add('index5') remove:add('index6') remove:add('index7') remove:add('index8') remove:add('index9')
        remove:add('lotting0') remove:add('lotting1') remove:add('lotting2') remove:add('lotting3') remove:add('lotting4') remove:add('lotting5') remove:add('lotting6') remove:add('lotting7') remove:add('lotting8') remove:add('lotting9')
        treasure:update(info)
        treasure:hide()
        return
    end
    for i,v in pairs(get_item.treasure) do
        for i = 0, 9 do
            if get_item.treasure[i] then
                if goals[i] then
                    local diff = os.difftime(goals[i], os.time())
                    local timer = {}
                    local item = {}
                    item[i] = res.items[get_item.treasure[i].item_id].name
                    timer[i] = os.date('!%M:%S', diff)
                    if diff < 0 then -- stop the timer when 00:00 so it don't show 59:59 for a brief moment
                        remove:add('index' .. i)
                        remove:add('lotting' .. i)
                    else
                        info['index' .. i] = (
                            diff < 60 and
                                '\\cs(255,0,0)' .. item[i] .. ' → ' .. timer[i]
                            or diff > 180 and
                                '\\cs(0,255,0)' .. item[i] .. ' → ' .. timer[i]
                            or
                                '\\cs(255,128,0)' .. item[i] .. ' → ' .. timer[i]) .. '\\cr'
                    
                    end
                else -- show item name in case the addon is loaded with items on tresure box
                    info['index' .. i] = res.items[get_item.treasure[i].item_id].name
                end
                if lotter[i] and lot[i] then
                    if lotter[i] == ' ' then
                        remove:add('lotting' .. i)
                    elseif lot[i] > 0 then
                        info['lotting' .. i] = (
                            '\\cs(0,255,255)' .. (' | ' .. lotter[i] .. ': ' .. lot[i])) .. '\\cr'
                    end
                end
                treasure:show()
            else
                remove:add('index' .. i)
                remove:add('lotting' .. i)
            end
        end
        treasure:update(info)
    end
    for entry in remove:it() do
        treasure[entry] = nil
    end
end)
