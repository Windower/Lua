--Copyright (c) 2014, Byrthnoth
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'Translate'
_addon.version = '0.141005'
_addon.author = 'Byrth'
_addon.commands = {'trans','translate'}


language = 'english'
trans_list = {}
res = require 'resources'
require 'sets'
require 'pack'
require 'strings'

handled_resources = S{
    'ability_recasts',
    'auto_translates',
    'buffs',
    'days',
    'elements',
    'items',
    'job_abilities',
    'job_traits',
    'jobs',
    'key_items',
    'monster_abilities',
    'monstrosity',
    'moon_phases',
    'races',
    'regions',
    'skills',
    'spell_recasts',
    'spells',
    'titles',
    'weapon_skills',
    'weather',
    'zones'
    }

green_open = string.char(0xEF,0x27)
red_close = string.char(0xEF,0x28)

green_col = ''--string.char(0x1E,2)
rcol = ''--string.char(0x1E,1)

function to_a_code(num)
    local first_byte,second_byte = math.floor(num/256),num%256
    if first_byte == 0 or second_byte == 0 then return nil end
    return string.char(0xFD,2,2,first_byte,second_byte,0xFD):escape()
end

function to_item_code(id)
    local first_byte,second_byte = math.floor(id/256),id%256
    local t = 0x07
    if first_byte == 0 then
        t = 0x09
        first_byte = 0xFF
    elseif second_byte == 0 then
        t = 0x0A
        second_byte = 0xFF
    end
    return string.char(0xFD,t,2,first_byte,second_byte,0xFD):escape()
end

function to_ki_code(id)
    local first_byte,second_byte = math.floor(id/256),id%256
    local t = 0x13
    if first_byte == 0 then
        t = 0x15
        first_byte = 0xFF
    elseif second_byte == 0 then
        t = 0x16
        second_byte = 0xFF
    end
    return string.char(0xFD,t,2,first_byte,second_byte,0xFD):escape()
end

function sanity_check(ja)
    return (ja and string.len(ja) > 0 and ja ~= '%.')
end

for res_name in pairs(handled_resources) do
    local resource = res[res_name]
    if res_name == 'auto_translates' then
        for autotranslate_code,res_line in pairs(resource) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            if sanity_check(jp) and not trans_list[jp] and jp ~= res_line.en:escape() then
                trans_list[jp] = to_a_code(autotranslate_code)
            end
        end
    elseif res_name == 'items' then
        for id,res_line in pairs(resource) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            if sanity_check(jp) and not trans_list[jp] and jp ~= res_line.en:escape() then
                trans_list[jp] = to_item_code(id)
            end
        end
    elseif res_name == 'key_items' then
        for id,res_line in pairs(resource) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            if sanity_check(jp) and not trans_list[jp] and jp ~= res_line.en:escape() then
                trans_list[jp] = to_ki_code(id)
            end
        end
    else
        for _,res_line in pairs(resource) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            local jps = windower.to_shift_jis(res_line.jas or ''):escape()
            if sanity_check(jp) and not trans_list[jp] and sanity_check(res_line.en) and jp ~= res_line.en:escape() then
                trans_list[jp] = green_col..res_line.en..rcol:escape()
            end
            if sanity_check(jps) and not trans_list[jps] and sanity_check(res_line.ens) and jp ~= res_line.en:escape() and jps ~= res_line.ens:escape() then
                trans_list[jps] = green_col..res_line.ens..rcol:escape()
            end
        end
    end
end

local custom_dict_names = S(windower.get_dir(windower.addon_path..'dicts/')):filter(string.endswith-{'.lua'}):map(string.sub-{1, -5})
for dict_name in pairs(custom_dict_names) do
    local dict = dofile(windower.addon_path..'dicts/'..dict_name..'.lua')
    if dict then
        for _,res_line in pairs(dict) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            local jps = windower.to_shift_jis(res_line.jas or ''):escape()
            if sanity_check(jp) and sanity_check(res_line.en) and jp~= res_line.en:escape() then
                trans_list[jp] = green_col..res_line.en..rcol
            end
            if sanity_check(jps) and sanity_check(res_line.ens) and jps ~= res_line.ens:escape() then
                trans_list[jps] = green_col..res_line.ens..rcol
            end
        end
    end
end

function print_bytes(str)
    local c = ''
    local i = 1
    while i <= #str do
        c = c..' '..str:byte(i)
        i = i + 1
    end
    return c
end

trans_list[string.char(0x46)] = nil
trans_list['\.'] = nil


windower.register_event('incoming chunk',function(id,orgi,modi,is_injected,is_blocked)
    if id == 0x17 and not is_injected and not is_blocked then
        local out_text = modi:unpack('z',0x19)
        local matches,match_bool = {},false
        local function make_matches(catch)
            -- build a table of matches indexed by their length
            local esc = catch:escape()
            if not sanity_check(esc) then return end
            if not matches[#catch] then
                matches[#catch] = {}
            end
            matches[#catch][#matches[#catch]+1] = esc
            match_bool = true
        end
        for jp,en in pairs(trans_list) do
            out_text:gsub(jp,make_matches)
        end
        
        if not match_bool then return end
        
        if show_original then windower.add_to_chat(8,modi:sub(9,0x18):unpack('z',1)..'[Original]: '..out_text) end
        
        local order = {}
        for len,_ in pairs(matches) do
            if #order == 0 then
                order[1] = len
            else
                local c = 1
                while c <= #order do
                    if len > order[c] then
                        table.insert(order,c,len)
                        break
                    end
                    c = c + 1
                end
                if c > #order then order[c] = len end
            end
        end
        
        for _,ind in ipairs(order) do
            for _,option in ipairs(matches[ind]) do
                out_text = out_text:gsub(option,trans_list[option])
            end
        end
        
        while #out_text > 0 do
            local boundary = get_boundary_length(out_text,150)
            local len = math.ceil((boundary+1+24)/2) -- Make sure there is at least one nul after the string
            local out_pack = string.char(0x17,len)..modi:sub(3,0x18)..out_text:sub(1,boundary)
            -- zero pad it
            while #out_pack < len*2 do
                out_pack = out_pack..string.char(0)
            end
            windower.packets.inject_incoming(0x17,out_pack)
            out_text = out_text:sub(boundary+1)
        end        
        return true
    end
end)

function get_boundary_length(str,limit)
    -- If it is already short enough, return it
    if #str <= limit then return #str end
    
    -- Otherwise, try to pick a spot to split that will not interfere with command codes and such
    local boundary = limit
    for i=limit-5,limit do
        local c_byte = str:byte(i)
        if c_byte ==0xFD then
            -- 0xFD: Autotranslate code, 6 bytes
            boundary = i-1
            break
        elseif c_byte == 0xEF and str:byte(i+1) == 0x27 then
            -- Opening green (
            boundary = i-1
            break
        elseif i == limit and ( (c_byte > 0x7F and c_byte <= 0xA0) or c_byte >= 0xE0) then
            -- Double-byte shift_JIS character
            boundary = i-1
            break
        end
    end
    return boundary
end

windower.register_event('addon command', function(...)
    local commands = {...}
    if not commands[1] then return end
    if commands[1]:lower() == 'show' then
        if commands[2] and commands[2]:lower() == 'original' then
            show_original=not show_original
            if show_original then
                print('Translate: Showing the original text line.')
            else
                print('Translate: Hiding the original text line.')
            end
        end
    elseif commands[1]:lower() == 'eval' then
        assert(loadstring(table.concat({...}, ' ')))()
    end
end)


function print_set(set,title)
    if not set then
        if title then
            windower.add_to_chat(123,'GearSwap: print_set error '..title..' set is nil.')
        else
            windower.add_to_chat(123,'GearSwap: print_set error, set is nil.')
        end
        return
    end
    if title then
        windower.add_to_chat(1,'------------------------- '..tostring(title)..' -------------------------')
    else
        windower.add_to_chat(1,'----------------------------------------------------------------')
    end
    if #set == table.length(set) then
        for i,v in ipairs(set) do
            if type(v) == 'table' and v.name then
                windower.add_to_chat(8,tostring(i)..' '..tostring(v))
            else
                windower.add_to_chat(8,tostring(i)..' '..tostring(v))
            end
        end
    else
        for i,v in pairs(set) do
            if type(v) == 'table' and v.name then
                windower.add_to_chat(8,tostring(i)..' '..tostring(v))
            else
                windower.add_to_chat(8,tostring(i)..' '..tostring(v))
            end
        end
    end
    windower.add_to_chat(1,'----------------------------------------------------------------')
end