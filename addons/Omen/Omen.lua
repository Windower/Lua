-- Copyright © 2017, Braden, Sechs
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of Omen nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Braden OR Sechs BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name    = 'Omen'
_addon.author  = 'Braden, Sechs'
_addon.version = '1.5'
_addon.command = 'omen'

config = require ('config')
texts = require('texts')
--require('omen_test')

defaults = T{}
defaults.text_R = 255 --Color values are in RGB, ranging from 0 to 255
defaults.text_G = 255
defaults.text_B = 255
defaults.good_R = 0
defaults.good_G = 255
defaults.good_B = 0
defaults.bad_R = 255
defaults.bad_G = 0
defaults.bad_B = 0
defaults.pos_x = 0
defaults.pos_y = 0
defaults.font_size = 11
defaults.bg_alpha = 255

settings = config.load(defaults)

good_col = "\\cs("..tostring(settings.good_R)..","..tostring(settings.good_G)..","..tostring(settings.good_B)..")"
bad_col = "\\cs("..tostring(settings.bad_R)..","..tostring(settings.bad_G)..","..tostring(settings.bad_B)..")"
omens = 0
obj_time = 0
floor_obj = "Waiting for objectives..."
floor_clear = ""
--image = texts.new("image", settings)
image = texts.new("image")

texts.color(image,settings.text_R,settings.text_G,settings.text_B)
texts.size(image,settings.font_size)
texts.pos_x(image,settings.pos_x)
texts.pos_y(image,settings.pos_y)
texts.bg_alpha(image,settings.bg_alpha)

function reset_objectives()
    objectives = {
    [1] = {id=1,mes=0,amt=0,req=0},
    [2] = {id=2,mes=0,amt=0,req=0},
    [3] = {id=3,mes=0,amt=0,req=0},
    [4] = {id=4,mes=0,amt=0,req=0},
    [5] = {id=5,mes=0,amt=0,req=0},
    [6] = {id=6,mes=0,amt=0,req=0},
    [7] = {id=7,mes=0,amt=0,req=0},
    [8] = {id=8,mes=0,amt=0,req=0},
    [9] = {id=9,mes=0,amt=0,req=0},
    [10] = {id=10,mes=0,amt=0,req=0}
    }
    obj_time = 0
    floor_clear = ""
end
reset_objectives()

function refresh()
    header = floor_clear..floor_obj.."\\cr     Omens: "..omens
    body = "\n Bonus Objectives    "..os.date('%M:%S', obj_time)
    for k,v in pairs (hide_timer) do
        if string.find(header,v) then
            body = ""
            texts.text(image,header)
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
    body = string.gsub(body,"%-1","%?%?%?")
    texts.text(image,header..body)
end

hide_timer = {"Kin","Gin","Kei","Kyou","Fu","Ou","Craver","Gorger","Thinker","Treasure","Waiting"}
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
        if string.match(original,"^%d") then
            for k,v in pairs (messages) do
                if string.find(original,v.init) then
                    if objective.mes ~= tonumber(v.id) then -- New Objective
                        objective.amt = 0
                    end
                    objective.mes = tonumber(v.id)
                    objective.req = tonumber(string.sub(original:match(v.check),1,-2))				
                elseif string.find(original,v.eval) then
                    objective.amt = tonumber(string.sub(original:match(v.check),1,-2))
                    if objective.mes == 0 then -- if loading mid-floor
                        objective.mes = tonumber(v.id)
                        objective.req = -1
                    end
                end
                refresh()
            end
        elseif string.find(original,"%d+ omen") then
            omens = original:match("%d+")
            refresh()
        elseif string.find(original,"You have %d+ seconds remaining.") then
            if obj_time == 0 then
                obj_time = tonumber(original:match("%d+"))
                end_time = os.time() + obj_time
                refresh()			
            end
        elseif string.find(original,"A spectral light flares up.") then
            floor_clear = good_col
            refresh()
            windower.play_sound(windower.addon_path..'big_clear.wav')
        elseif string.find(original,"A faint light twinkles into existence.") then
            windower.play_sound(windower.addon_path..'small_clear.wav')
        elseif string.find(original,"Vanquish") or string.find(original,"Open %d treasure portent") then
            local str1 = string.gsub(original,string.char(0x7f).."1","")
            local str1 = string.gsub(str1,"%p","")			
            local str1 = string.gsub(str1,"(%s%a)",string.upper)
            floor_obj = string.gsub(str1,"The","the")
            if floor_clear == good_col then
                reset_objectives()
            end
            refresh()
        elseif string.find(original,"The light shall come even if you fail to obey.") then
            floor_obj = "Free Floor!"
            if floor_clear == good_col then
                reset_objectives()
            end
            refresh()
        end		
    end
end)

windower.register_event('addon command',function(command)
    command = command and command:lower() or 'help'
    if texts.visible(image) then
        image:hide()
    else
        image:show()
    end
end)

messages = {
[1] = {id="1",long="Weapon Skill Damage",short="WS Damage",check="%d+%su",
init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill.",
eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill.",
fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single weapon skill."},
[2] = {id="2",long="Magic Burst Damage",short="MB Damage",check="%d+%su",
init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst.",
eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst.",
fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic burst."},
[3] = {id="3",long="Non-MB Nuke Damage",short="Non-MB Nuke",check="%d+%su",
init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst.",
eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst.",
fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ using a single magic attack without performing a magic burst."},
[4] = {id="4",long="Auto-attack Damage",short="Melee Round",check="%d+%si",
init="%d: Reduce your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack.",
eval="%d: You have reduced your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack.",
fail="%d: You have failed to reduce your foe's HP by %a*%s*%a*%s*%d+ in a single auto%-attack."},
[5] = {id="5",long="Kills",short="Kills",check="%d+%sf",
init="%d: Vanquish %d+ %a+.",
eval="%d: You have vanquished %d+ %a+.",
fail="%d: You have failed to vanquish %d+ %a+."},
[6] = {id="6",long="Critical Hits",short="Critical Hits",check="%d+%sc",
init="%d: Deal %d+ critical %a+ to your foes.",
eval="%d: You have dealt %d+ critical %a+ to your foes.",
fail="%d: You have failed to deal %d+ critical %a+ to your foes."},
[7] = {id="7",long="Abilities",short="Abilities",check="%d+%sa",
init="%d: Use %d+ %a+ on your foes.",
eval="%d: You have used %d+ %a+ on your foes.",
fail="%d: You have failed to use %d+ %a+ on your foes."},
[8] = {id="8",long="Spells",short="Spells",check="%d+%ss",
init="%d: Cast %d+ %a+ on your foes.",
eval="%d: You have cast %d+ %a+ on your foes.",
fail="%d: You have failed to cast %d+ %a+ on your foes."},
[9] = {id="9",long="Magic Bursts",short="Magic Bursts",check="%d+%sm",
init="%d: Perform %d+ magic %a+ on your foes.",
eval="%d: You have performed %d+ magic %a+ on your foes.",
fail="%d: You have failed to perform %d+ magic %a+ on your foes."},
[10] = {id="10",long="Consecutive SCs",short="Skillchains",check="%d+%ss",
init="%d: Execute %d+ %a+ using weapon %a+ on your foes!",
eval="%d: You have executed %d+ %a+ using weapon %a+ on your foes!",
fail="%d: You have failed to execute %d+ %a+ using weapon %a+ on your foes!"},
[11] = {id="11",long="All Weapon Skills",short="All WS",check="%d+%sw",
init="%d: Use %d+ weapon %a+ on your foes.",
eval="%d: You have used %d+ weapon %a+ on your foes.",
fail="%d: You have failed to use %d+ weapon %a+ on your foes."},
[12] = {id="12",long="Physical Weapon Skills",short="Physical WS",check="%d+%sp",
init="%d: Use %d+ physical weapon %a+ on your foes.",
eval="%d: You have used %d+ physical weapon %a+ on your foes.",
fail="%d: You have failed to use %d+ physical weapon %a+ on your foes."},
[13] = {id="13",long="Magical Weapon Skills",short="Magic WS",check="%d+%se",
init="%d: Use %d+ elemental weapon %a+ on your foes.",
eval="%d: You have used %d+ elemental weapon %a+ on your foes.",
fail="%d: You have failed to use %d+ elemental weapon %a+ on your foes."},
[14] = {id="14",long="Heals for 500 HP",short="500 HP Cures",check="%d+%st",
init="%d: Restore at least 500 HP %d+ %a+.",
eval="%d: You have restored at least 500 HP %d+ %a+.",
fail="%d: You have failed to restore at least 500 HP %d+ %a+."}
}
