--[[
Copyright (c) 2013, Sebastien Gomez
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
    * Neither the name of MobCompass nor the
    names of its contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sebastien Gomez BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'MobCompass'
_addon.version = '2.0.1'

texts = require('texts')
config = require('config')

do
    local s_arrows={
        pos = {},
        bg = {visible=false},
        flags = {draggable=false},
        text = {size=33,font='Wingdings'}
    }

    circle = texts.new('l',s_arrows)
    circle2 = texts.new('l',s_arrows)

    n = texts.new('Ù',s_arrows)
    s = texts.new('Ú',s_arrows)
    w = texts.new('×',s_arrows)
    e = texts.new('Ø',s_arrows)

    s_arrows.text.size = 20

    ne = texts.new('w',s_arrows)
    nw = texts.new('w',s_arrows)
    sw = texts.new('w',s_arrows)
    se = texts.new('w',s_arrows)

    _defaults = config.load({
        x_pos = 0,
        y_pos = 0,
    })
    x_pos = _defaults.x_pos
    y_pos = _defaults.y_pos
    
    config.register(_defaults, function(settings_table)
        local x_pos = settings_table.x_pos
        local y_pos = settings_table.y_pos
            
        n:pos(x_pos+29,y_pos)
        s:pos(x_pos+29,y_pos+58)
        e:pos(x_pos+62,y_pos+29)
        w:pos(x_pos,y_pos+29)

        circle:pos(x_pos+22,y_pos+14)
        circle2:pos(x_pos-8,y_pos-27)

        sw:pos(x_pos+19,y_pos+60)
        se:pos(x_pos+64,y_pos+60)
        nw:pos(x_pos+19,y_pos+17)
        ne:pos(x_pos+64,y_pos+17)
        sas:pos(x_pos+32,y_pos+40)
        labels:pos(x_pos-22,y_pos-18)

    end)

    sas = texts.new('360',{
        pos = {x=x_pos+32,y=y_pos+40},
        bg = {visible=false},
        flags = {draggable=false},
        text = {size=15,font='Consolas',}
    })

    labels = texts.new('       Crit\n\n\n\nMB               Att\n\n\n\n        Acc',{
        pos = {x=x_pos-22,y=y_pos-18},
        bg = {visible=false},
        flags = {draggable=false},
        text = {size=10,font='Consolas',}
    })

    n:pos(x_pos+29,y_pos)
    s:pos(x_pos+29,y_pos+58)
    e:pos(x_pos+62,y_pos+29)
    w:pos(x_pos,y_pos+29)

    circle:pos(x_pos+22,y_pos+14)
    circle2:pos(x_pos-8,y_pos-27)

    sw:pos(x_pos+19,y_pos+60)
    se:pos(x_pos+64,y_pos+60)
    nw:pos(x_pos+19,y_pos+17)
    ne:pos(x_pos+64,y_pos+17)

    circle:size(53)
    circle:alpha(100)
    circle2:size(111)
    circle2:color(0,0,165)
    circle2:alpha(28)

    s_arrows.text.alpha = 255
end

do
    local drag_and_drop
    
    windower.register_event('mouse', function(type, x, y, delta, blocked)
        if blocked then return end
        if type == 0 then
            if drag_and_drop then
                sas:pos(x-drag_and_drop[1]+32,y-drag_and_drop[2]+40)
                n:pos(x-drag_and_drop[1]+29,y-drag_and_drop[2])
                s:pos(x-drag_and_drop[1]+29,y-drag_and_drop[2]+58)
                e:pos(x-drag_and_drop[1]+62,y-drag_and_drop[2]+29)
                w:pos(x-drag_and_drop[1],y-drag_and_drop[2]+29)
                sw:pos(x-drag_and_drop[1]+19,y-drag_and_drop[2]+60)
                se:pos(x-drag_and_drop[1]+64,y-drag_and_drop[2]+60)
                nw:pos(x-drag_and_drop[1]+19,y-drag_and_drop[2]+17)
                ne:pos(x-drag_and_drop[1]+64,y-drag_and_drop[2]+17)
                circle:pos(x-drag_and_drop[1]+22,y-drag_and_drop[2]+14)
                circle2:pos(x-drag_and_drop[1]-8,y-drag_and_drop[2]-27)
                labels:pos(x-drag_and_drop[1]-22,y-drag_and_drop[2]-18)
                return true
            end
        elseif type == 1 then
            if (x-x_pos-45)^2 + (y-y_pos-45)^2 < 2025 then
                drag_and_drop = {x-x_pos,y-y_pos}
                return true
            end
        elseif type == 2 then
            if drag_and_drop then
                x_pos,y_pos = x-drag_and_drop[1],y-drag_and_drop[2]
                _defaults.x_pos = x_pos
                _defaults.y_pos = y_pos
                config.save(_defaults)
                drag_and_drop = nil
                return true
            end
        end
    end)
end

do
    local is_labels_visible = false
    windower.register_event('job change', function(main_job_id,_,sub_job_id)
        is_labels_visible = main_job_id == 21 or sub_job_id == 21
        labels:visible(is_labels_visible and w:visible())
    end)
    
    local player_index
    if windower.ffxi.get_info().logged_in then
        local player = windower.ffxi.get_player()
        player_index = player.index
        is_labels_visible = player.main_job_id == 21 or player.sub_job_id == 21
    end
    
    windower.register_event('zone change', function()
        player_index = windower.ffxi.get_player().index
    end)
    
    windower.register_event('login', function()
        player_index = windower.ffxi.get_player().index
    end)
    
    local target = 0
        
    windower.register_event('target change', function(n)
        target = n ~= player_index and n or 0
        if target == 0 then
            for i=1,#windower.text.saved_texts do
                windower.text.saved_texts[i]:hide()
            end
        elseif not w:visible() then
            for i=1,#windower.text.saved_texts do
                windower.text.saved_texts[i]:show()
            end
            labels:visible(is_labels_visible)
        end
    end)
    
    local atan = math.atan
    local pi = math.pi
    local last45angle = 10
    local last16angle
    local direction = {
        [0]=' N ', ' N ', 'NNE', 'N E', 'ENE', ' E ', 'ESE', 'S E', 'SSE', ' S ', 'SSW', 'S W', 'WSW', 
        ' W ', 'WNW', 'N W', 'NNW', [-7]='SSW', [-6]='S W', [-5]='WSW', [-4]=' W ', [-3]='WNW', [-2]='N W', [-1]='NNW',
    }
    local arrow_map = {[0]=e,e,ne,n,nw,w,sw,s,se,e,sas}
    
    windower.register_event('prerender', function()
        if target ~= 0 then
            local player = windower.ffxi.get_mob_by_index(player_index)
            if not player then 
                target = 0 
                return 
            end
            local mob = windower.ffxi.get_mob_by_index(target)
            local x,y = player.x-mob.x,player.y-mob.y
            local angle = atan(y/x)
            if x < 0 then
                angle = angle+pi
            elseif y < 0 then
                angle = angle+2*pi
            end
            local next45angle = math.ceil((angle+pi/8)/(pi/4))
            if next45angle ~= last45angle then
                if next45angle ~= nil and last45angle ~=nil then
                    arrow_map[last45angle]:color(255,255,255)
                    arrow_map[next45angle]:color(255,0,0)
                    last45angle = next45angle
                end
            end
            local heading = mob.facing
            if heading < 0 then
                heading = -heading
            else
                heading = 2*pi-heading
            end
            
            heading = heading - angle
            
            local next16angle = math.ceil((heading+pi/16)/(pi/8))
            if next16angle ~= last16angle then
                sas:text(direction[next16angle])
                last16angle = next16angle
            end
        end
    end)
end
