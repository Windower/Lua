--[[ 

Copyright © 2017-2024, Braden, Sechs, Sevu
All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Omen nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Braden OR Sechs OR Sevu BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--]]


_addon.name    = "Omen"
_addon.author  = "Braden, Sechs, Sevu"
_addon.version = "1.6"
_addon.commands = {"omen", "om"}

config = require('config')
texts = require('texts')

defaults = T{}
defaults.bg = {alpha = 50, blue = 0, green = 0, red = 0, visible = true}
defaults.flags = {bold = true, bottom = false, draggable = true, italic = false, right = false}
defaults.padding = 0
defaults.pos = {x = 200, y = 500}
defaults.text = {
    alpha = 255, blue = 255, green = 255, red = 255, size = 11,
    font = "Consolas", fonts = T{},
    stroke = {alpha = 255, blue = 0, green = 0, red = 0, width = 1},
    good_R = 0, good_G = 255, good_B = 0,
    bad_R = 255, bad_G = 0, bad_B = 0
}


settings = config.load(defaults)

----------------------------------------------------------------------------------------------
-- DO NOT EDIT BELOW THIS LINE
----------------------------------------------------------------------------------------------

function defineColor(r, g, b)
    return "\\cs("..tostring(r)..","..tostring(g)..","..tostring(b)..")"
end


good_col = defineColor(settings.text.good_R, settings.text.good_G, settings.text.good_B)
bad_col = defineColor(settings.text.bad_R, settings.text.bad_G, settings.text.bad_B)

omens = 0
obj_time = 0
floor_obj = "Waiting for objectives..."
floor_clear = ""
image = texts.new("image")

texts.color(image, settings.text.red, settings.text.green, settings.text.blue)
texts.font(image, settings.text.font)
texts.size(image, settings.text.size)
texts.pos_x(image, settings.pos.x)
texts.pos_y(image, settings.pos.y)
texts.bg_alpha(image, settings.bg.alpha)
texts.bg_visible(image, settings.bg.visible)
texts.stroke_width(image, settings.text.stroke.width)
texts.stroke_color(image, settings.text.stroke.red, settings.text.stroke.green, settings.text.stroke.blue)
texts.bold(image, settings.flags.bold)
texts.italic(image, settings.flags.italic)
texts.draggable(image, settings.flags.draggable)

function reset_objectives()
    objectives = {
        [1] = {id=1, mes=0, amt=0, req=0},
        [2] = {id=2, mes=0, amt=0, req=0},
        [3] = {id=3, mes=0, amt=0, req=0},
        [4] = {id=4, mes=0, amt=0, req=0},
        [5] = {id=5, mes=0, amt=0, req=0},
        [6] = {id=6, mes=0, amt=0, req=0},
        [7] = {id=7, mes=0, amt=0, req=0},
        [8] = {id=8, mes=0, amt=0, req=0},
        [9] = {id=9, mes=0, amt=0, req=0},
        [10] = {id=10, mes=0, amt=0, req=0}
    }
    obj_time = 0
    floor_clear = ""
end
reset_objectives()

function refresh()
    header = floor_clear..floor_obj.."\\cr     Omens: "..omens
    body = "\n Bonus Objectives    "..os.date('%M:%S', obj_time)
    for k, v in pairs(hide_timer) do
        if string.find(header, v) then
            body = ""
            texts.text(image, header)
            return
        end
    end
    for v, objective in ipairs(objectives) do
        if objective.mes ~= 0 then
            local msg = objective.mes
            local cur = objective.amt
            local fin = objective.req
            if cur == fin then
                body = body.."\n "..good_col..v..": "..messages[msg].short.." ["..cur.."/"..fin.."]\\cr"
            elseif obj_time < 1 and cur < fin then
                body = body.."\n "..bad_col..v..": "..messages[msg].short.." ["..cur.."/"..fin.."]\\cr"
            else
                body = body.."\n "..v..": "..messages[msg].short.." ["..cur.."/"..fin.."]"
            end
        end
    end
    body = string.gsub(body, "%-1", "%?%?%?")
    texts.text(image, header..body)
end

hide_timer = {"Kin", "Gin", "Kei", "Kyou", "Fu", "Ou", "Craver", "Gorger", "Thinker", "Treasure", "Waiting"}
refresh()

windower.register_event('prerender', function()
    if obj_time < 1 then return end
    if obj_time ~= (end_time - os.time()) then
        obj_time = end_time - os.time()
        refresh()
    end
end)

windower.register_event('zone change', function(zone)
    image:hide()
    floor_obj = "Waiting for objectives..."
    reset_objectives()
    if zone == 292 then -- Reisenjima Henge
        image:show()
    end
end)

image:hide()
if windower.ffxi.get_info().zone == 292 then -- 292 is the code for Reisenjima Henge
    image:show()
end

windower.register_event('incoming text', function(original, modified, mode)
    local objective = objectives[tonumber(original:match("^%d+"))]
    if mode == 161 then -- Omen messages are 161 color, except total time extension messages which are 121 and irrelevant
        if string.match(original, "^%d") then
            for k, v in pairs(messages) do
                if string.find(original, v.init) then
                    if objective.mes ~= tonumber(v.id) then -- New Objective
                        objective.amt = 0
                    end
                    objective.mes = tonumber(v.id)
                    objective.req = tonumber(string.sub(original:match(v.check), 1, -2))
                elseif string.find(original, v.eval) then
                    objective.amt = tonumber(string.sub(original:match(v.check), 1, -2))
                    if objective.mes == 0 then -- if loading mid-floor
                        objective.mes = tonumber(v.id)
                        objective.req = -1
                    end
                end
                refresh()
            end
        elseif string.find(original, "%d+ omen") then
            omens = original:match("%d+")
            refresh()
        elseif string.find(original, "You have %d+ seconds remaining.") then
            if obj_time == 0 then
                obj_time = tonumber(original:match("%d+"))
                end_time = os.time() + obj_time
                refresh()
            end
        elseif string.find(original, "A spectral light flares up.") then
            floor_clear = good_col
            refresh()
        elseif string.find(original, "A faint light twinkles into existence.") then
        elseif string.find(original, "Vanquish") or string.find(original, "Open %d treasure portent") then
            local str1 = string.gsub(original, string.char(0x7f) .. "1", "")
            local str1 = string.gsub(str1, "%p", "")
            local str1 = string.gsub(str1, "(%s%a)", string.upper)
            floor_obj = string.gsub(str1, "The", "the")
            if floor_clear == good_col then
                reset_objectives()
            end
            refresh()
        elseif string.find(original, "The light shall come even if you fail to obey.") then
            floor_obj = "Free Floor!"
            if floor_clear == good_col then
                reset_objectives()
            end
            refresh()
        end
    end
end)

function chatMessage(color, message)
    windower.add_to_chat(color, message)
end

windower.register_event('addon command', function(...)
    local args = {...}
    local command = args[1]

    if command then
        command = command:lower()

        if command == 'save' or command == 's' then
            settings.pos.x = texts.pos_x(image)
            settings.pos.y = texts.pos_y(image)
            settings.flags.draggable = texts.draggable(image)
            config.save(settings)
            chatMessage(7, 'Settings saved.')

        elseif command == 'hide' then
            if texts.visible(image) then
                image:hide()
                chatMessage(7, '[' .. _addon.name .. '] UI Hidden.')
            else
                chatMessage(7, '[' .. _addon.name .. '] UI already hidden.')
            end

        elseif command == 'show' then
            if not texts.visible(image) then
                image:show()
                chatMessage(7, '[' .. _addon.name .. '] UI Visible.')
            else
                chatMessage(7, '[' .. _addon.name .. '] UI already visible.')
            end

        elseif command == 'reload' or command == 'r' then
            windower.send_command('lua r omen')

        elseif command == 'help' or command == 'h' then 
            chatMessage(204, '--- Omen Addon ---')
            chatMessage(204, 'Command: //omen or om')
            chatMessage(204, '//omen help/h -- This message')
            chatMessage(204, '//omen hide/show -- Hide/Show UI box')
            chatMessage(204, '//omen reload/r -- Reload the addon')
            chatMessage(204, '//omen save/s -- Save current settings')

        else
            chatMessage(7, 'Incorrect command. See //omen help')
        end
    end
end)

