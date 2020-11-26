traits = require ('res/traits')
buttons = require ('ui/buttons')
spellinfo = require ('res/spellinfo')
pages = require("ui/pages")
traitboxes = require("ui/traitboxes")
spellboxes = require("ui/spellboxes")
setspells = require("masterlist")

_addon.version = '1.2'
_addon.name = 'bluGuide'
_addon.author = 'Anissa of Cerberus'

local button_settings = {
    text = { size = 15, font = 'Arial',},
    bg = { alpha = 200, red = 0, green = 100, blue = 100, visible = false },
}

windower.register_event('load',function ()
    
    giftexempttraits = {
        ['Double/Triple Attack']        = true,
        ['Auto Refresh']                = true,
        ['Gilfinder/Treasure Hunter']    = true,
    }
    lineheight = 14
    updatelist = {}
    setspells.create(30, 50, update)
    build_columns()
    
    local player = windower.ffxi.get_player()
    job = player.main_job
    sub = player.sub_job
    
    traitsbutton = buttons.new("Traits", button_settings)
    traitsbutton.pos(80, 360)
    traitsbutton.show()
    traitsbutton.left_click = show_traits
    traitsbutton.hover_on = function() traitsbutton.bg_visible(true) end
    traitsbutton.hover_off = function() traitsbutton.bg_visible(false) end
    
    utilbutton = buttons.new("Utility", button_settings)
    utilbutton.pos(80, 390)
    utilbutton.show()
    utilbutton.left_click = show_utilities
    utilbutton.hover_on = function() utilbutton.bg_visible(true) end
    utilbutton.hover_off = function() utilbutton.bg_visible(false) end
    
    scbutton = buttons.new("Damage", button_settings)
    scbutton.pos(80, 420)
    scbutton.show()
    scbutton.left_click = show_skillchain
    scbutton.hover_on = function() scbutton.bg_visible(true) end
    scbutton.hover_off = function() scbutton.bg_visible(false) end
    
    procsbutton = buttons.new("Procs", button_settings)
    procsbutton.pos(80, 450)
    procsbutton.show()
    procsbutton.left_click = show_procs
    procsbutton.hover_on = function() procsbutton.bg_visible(true) end
    procsbutton.hover_off = function() procsbutton.bg_visible(false) end
     
    closebutton = buttons.new("Close", button_settings)
    closebutton.pos(80, 480)
    closebutton.show()
    closebutton.left_click = close
    closebutton.hover_on = function() closebutton.bg_visible(true) end
    closebutton.hover_off = function() closebutton.bg_visible(false) end
end)

function update()
    for _, v in pairs(updatelist) do
        v:update()
    end
end

windower.register_event('job change', function(new, old)
    jobchange = coroutine.schedule(check_job, 5)
end)

function check_job()
    local player = windower.ffxi.get_player()
    local t = {}
    if player.main_job == "BLU" then
        if job ~= "BLU" then
            print("Reloading bluGuide.  Changed job/subjob combo.")
            windower.send_command('lua reload bluguide')
        end
    elseif player.sub_job == "BLU" then
        if sub ~= "BLU" then
            print("Reloading bluGuide.  Changed job/subjob combo.")
            windower.send_command('lua reload bluguide')
        end
    else
        print("Unloading bluGuide.  Invalid job/subjob combo.")
        windower.send_command('lua unload bluguide')
    end
end

function build_columns()
    traitpage = pages.new(260, 50)
    
    traitpage:add(traitboxes.new(traits['Dual Wield']))
    traitpage:add(traitboxes.new(traits['Double/Triple Attack']))
    traitpage:add(traitboxes.new(traits['Attack Bonus']))
    traitpage:add(traitboxes.new(traits['Accuracy Bonus']))
    traitpage:add(traitboxes.new(traits['Store TP']))
    traitpage:add(traitboxes.new(traits['Skillchain Bonus']))
    traitpage:add(traitboxes.new(traits['Critical Attack Bonus']))
    traitpage:add(traitboxes.new(traits['Magic Attack Bonus']))
    traitpage:add(traitboxes.new(traits['Magic Accuracy Bonus']))
    traitpage:add(traitboxes.new(traits['Fast Cast']))
    traitpage:add(traitboxes.new(traits['Magic Burst Bonus']))
    traitpage:add(traitboxes.new(traits['Conserve MP']))
    traitpage:add(traitboxes.new(traits['Auto Refresh']))
    traitpage:add(traitboxes.new(traits['Clear Mind']))
    traitpage:add(traitboxes.new(traits['Max MP Boost']))
    traitpage:add(traitboxes.new(traits['Counter']))
    traitpage:add(traitboxes.new(traits['Defense Bonus']))
    traitpage:add(traitboxes.new(traits['Magic Defense Bonus']))
    traitpage:add(traitboxes.new(traits['Magic Evasion Bonus']))
    traitpage:add(traitboxes.new(traits['Evasion Bonus']))
    traitpage:add(traitboxes.new(traits['Inquartata']))
    traitpage:add(traitboxes.new(traits['Auto Regen']))
    traitpage:add(traitboxes.new(traits['Max HP Boost']))
    traitpage:add(traitboxes.new(traits['Tenacity']))
    traitpage:add(traitboxes.new(traits['Resist Gravity']))
    traitpage:add(traitboxes.new(traits['Resist Silence']))
    traitpage:add(traitboxes.new(traits['Resist Sleep']))
    traitpage:add(traitboxes.new(traits['Resist Slow']))
    traitpage:add(traitboxes.new(traits['Gilfinder/TH']))
    traitpage:add(traitboxes.new(traits['Beast Killer']))
    traitpage:add(traitboxes.new(traits['Lizard Killer']))
    traitpage:add(traitboxes.new(traits['Undead Killer']))
    traitpage:add(traitboxes.new(traits['Plantoid Killer']))
    traitpage:add(traitboxes.new(traits['Rapid Shot']))
    traitpage:add(traitboxes.new(traits['Zanshin']))
        
    updatelist[#updatelist+1] = traitpage
    traitpage:show()
    
    buffpage = pages.new(260, 50)
    buffpage:add(spellboxes.new('Cure', function(s) return s.effect['Cure'] end))
    buffpage:add(spellboxes.new('Erase', function(s) return s.effect['Erase'] end))
    buffpage:add(spellboxes.new('Haste', function(s) return s.effect['Haste'] end))
    buffpage:add(spellboxes.new('Attack Boost', function(s) return s.effect['Attack Boost'] end))
    buffpage:add(spellboxes.new('Refresh', function(s) return s.effect['Refresh'] end))
    buffpage:add(spellboxes.new('Accuracy Boost', function(s) return s.effect['Accuracy Boost'] end))
    buffpage:add(spellboxes.new('Magic Attack Boost', function(s) return s.effect['Magic Attack Boost'] end))
    
    buffpage:add(spellboxes.new('Blink', function(s) return s.effect['Blink'] end))
    buffpage:add(spellboxes.new('Defense Boost', function(s) return s.effect['Defense Boost'] end))
    buffpage:add(spellboxes.new('Phalanx', function(s) return s.effect['Phalanx'] end))
    buffpage:add(spellboxes.new('Stoneskin', function(s) return s.effect['Stoneskin'] end))
    buffpage:add(spellboxes.new('Spikes', function(s) return s.effect['Spikes'] end))
    buffpage:add(spellboxes.new('Magic Defense Boost', function(s) return s.effect['Magic Defense Boost'] end))
    buffpage:add(spellboxes.new('Evasion Boost', function(s) return s.effect['Evasion Boost'] end))
    buffpage:add(spellboxes.new('Regen', function(s) return s.effect['Regen'] end))
    buffpage:add(spellboxes.new('Counter', function(s) return s.effect['Counter'] end))
    
    buffpage:add(spellboxes.new('Sleep', function(s) return s.effect['Sleep'] end))
    buffpage:add(spellboxes.new('Dispel', function(s) return s.effect['Dispel'] end))
    buffpage:add(spellboxes.new('Defense Down', function(s) return s.effect['Defense Down'] end))
    buffpage:add(spellboxes.new('Evasion Down', function(s) return s.effect['Evasion Down'] end))
    buffpage:add(spellboxes.new('Magic Defense Down', function(s) return s.effect['Magic Defense Down'] end))

    buffpage:add(spellboxes.new('Aspir', function(s) return s.effect['Aspir'] end))
    buffpage:add(spellboxes.new('Drain', function(s) return s.effect['Drain'] end))
    buffpage:add(spellboxes.new('Poison', function(s) return s.effect['Poison'] end))
    buffpage:add(spellboxes.new('Stun', function(s) return s.effect['Stun'] end))
    buffpage:add(spellboxes.new('Terror', function(s) return s.effect['Terror'] end))
    
    buffpage:add(spellboxes.new('Silence', function(s) return s.effect['Silence'] end))
    buffpage:add(spellboxes.new('Slow', function(s) return s.effect['Slow'] end))
    buffpage:add(spellboxes.new('Paralyze', function(s) return s.effect['Paralyze'] end))
    buffpage:add(spellboxes.new('Reduce TP', function(s) return s.effect['Reduce TP'] end))
    buffpage:add(spellboxes.new('Plague', function(s) return s.effect['Plague'] end))
    
    buffpage:add(spellboxes.new('Bind', function(s) return s.effect['Bind'] end))
    buffpage:add(spellboxes.new('Gravity', function(s) return s.effect['Gravity'] end))
    buffpage:add(spellboxes.new('Petrify', function(s) return s.effect['Petrify'] end))
    buffpage:add(spellboxes.new('Flash', function(s) return s.effect['Flash'] end))
    buffpage:add(spellboxes.new('Blind', function(s) return s.effect['Blind'] end))
    buffpage:add(spellboxes.new('Accuracy Down', function(s) return s.effect['Accuracy Down'] end))
    
    buffpage:add(spellboxes.new('Bio', function(s) return s.effect['Bio'] end))
    buffpage:add(spellboxes.new('Doom', function(s) return s.effect['Doom'] end))
    buffpage:add(spellboxes.new('Frost', function(s) return s.effect['Frost'] end))
    buffpage:add(spellboxes.new('Burn', function(s) return s.effect['Burn'] end))
    buffpage:add(spellboxes.new('Drown', function(s) return s.effect['Drown'] end))
    buffpage:add(spellboxes.new('Vit Down', function(s) return s.effect['Vit Down'] end))
    buffpage:add(spellboxes.new('Int Down', function(s) return s.effect['Int Down'] end))
    buffpage:add(spellboxes.new('Str Down', function(s) return s.effect['Str Down'] end))
    buffpage:add(spellboxes.new('Dex Down', function(s) return s.effect['Dex Down'] end))
    
    updatelist[#updatelist+1] = buffpage
    
    procpage = pages.new(260, 50)
    procpage:add(spellboxes.new('Voidwatch - Fire', function(s) return s.Voidwatch ~= nil and s.element == 0 end))
    procpage:add(spellboxes.new('Voidwatch - Ice', function(s) return s.Voidwatch and s.element == 1 end))
    procpage:add(spellboxes.new('Voidwatch - Wind', function(s) return s.Voidwatch and s.element == 2 end))
    procpage:add(spellboxes.new('Voidwatch - Earth', function(s) return s.Voidwatch and s.element == 3 end))
    procpage:add(spellboxes.new('Voidwatch - Thunder', function(s) return s.Voidwatch and s.element == 4 end))
    procpage:add(spellboxes.new('Voidwatch - Water', function(s) return s.Voidwatch and s.element == 5 end))
    procpage:add(spellboxes.new('Voidwatch - Light', function(s) return s.Voidwatch and s.element == 6 end))
    procpage:add(spellboxes.new('Voidwatch - Dark', function(s) return s.Voidwatch and s.element == 7 end))
    procpage:add(spellboxes.new('Abyssea', function(s) return s.Abyssea end))
    updatelist[#updatelist+1] = procpage
    
    scpage = pages.new(260, 50)
    scpage:add(spellboxes.new('Gravitation', function(s) return s.SCA == "Gravitation" or s.SCB == "Gravitation" end, function(s) if s.SCB == "Gravitation" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Fusion', function(s) return s.SCA == "Fusion" or s.SCB == "Fusion" end, function(s) if s.SCB == "Fusion" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Distortion', function(s) return s.SCA == "Distortion" or s.SCB == "Distortion" end, function(s) if s.SCB == "Distortion" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Fragmentation', function(s) return s.SCA == "Fragmentation" or s.SCB == "Fragmentation" end, function(s) if s.SCB == "Fragmentation" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Transfixion', function(s) return s.SCA == "Transfixion" or s.SCB == "Transfixion" end, function(s) if s.SCB == "Transfixion" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Compression', function(s) return s.SCA == "Compression" or s.SCB == "Compression" end, function(s) if s.SCB == "Compression" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Reverberation', function(s) return s.SCA == "Reverberation" or s.SCB == "Reverberation" end, function(s) if s.SCB == "Reverberation" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Induration', function(s) return s.SCA == "Induration" or s.SCB == "Induration" end, function(s) if s.SCB == "Induration" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Impaction', function(s) return s.SCA == "Impaction" or s.SCB == "Impaction" end, function(s) if s.SCB == "Impaction" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Liquifaction', function(s) return s.SCA == "Liquifaction" or s.SCB == "Liquifaction" end, function(s) if s.SCB == "Liquifaction" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Detonation', function(s) return s.SCA == "Detonation" or s.SCB == "Detonation" end, function(s) if s.SCB == "Detonation" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    scpage:add(spellboxes.new('Scission', function(s) return s.SCA == "Scission" or s.SCB == "Scission" end, function(s) if s.SCB == "Scission" then return s.name.." ("..string.sub(s.SCA, 1, 3)..")" end end))
    
    scpage:add(spellboxes.new("Fire", function(s) return s.Nuke and s.element == 0 end))
    scpage:add(spellboxes.new("Ice", function(s) return s.Nuke and s.element == 1 end))
    scpage:add(spellboxes.new("Wind", function(s) return s.Nuke and s.element == 2 end))
    scpage:add(spellboxes.new("Earth", function(s) return s.Nuke and s.element == 3 end))
    scpage:add(spellboxes.new("Thunder", function(s) return s.Nuke and s.element == 4 end))
    scpage:add(spellboxes.new("Water", function(s) return s.Nuke and s.element == 5 end))
    scpage:add(spellboxes.new("Light", function(s) return s.Nuke and s.element == 6 end))
    scpage:add(spellboxes.new("Dark", function(s) return s.Nuke and s.element == 7 end))
    updatelist[#updatelist+1] = scpage
end

function show_traits()
    traitpage:show()
    buffpage:hide()
    procpage:hide()
    scpage:hide()
end

function show_utilities()
    traitpage:hide()
    buffpage:show()
    procpage:hide()
    scpage:hide()
end

function show_procs()
    traitpage:hide()
    buffpage:hide()
    procpage:show()
    scpage:hide()
end

function show_skillchain()
    traitpage:hide()
    buffpage:hide()
    procpage:hide()
    scpage:show()
end

function close()
    windower.send_command('lua unload bluguide')
end

--Copyright © 2015, Anissa
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of bluGuide nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL ANISSA BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
