--Copyright (c) 2014~2020, Byrthnoth
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
_addon.version = '2.0.0.0'
_addon.author = 'Byrth'
_addon.commands = {'trans','translate'}


language = 'english'
trans_list = {}
res = require 'resources'
packets = require('packets')
require 'sets'
require 'lists'
require 'pack'
require 'strings'
require 'katakana_to_romanji'
search_comment = {ts = 0, reg = L{}, translated = false}

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
    -- 0xFD,2,2,8,37,0xFD :: 37 = %
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

function load_dict(dict)
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

load_dict(katakana_to_romanji)

for res_name in pairs(handled_resources) do
    local resource = res[res_name] or {}
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
    elseif res_name == 'jobs' then
        for _,res_line in pairs(resource) do
            local jp = windower.to_shift_jis(res_line.ja or ''):escape()
            local jps = windower.to_shift_jis(res_line.jas or ''):escape()
            if sanity_check(jp) and sanity_check(res_line.en) and jp ~= res_line.en:escape() then
                trans_list[jp] = green_col..res_line.en..rcol:escape()
            end
            if sanity_check(jps) and sanity_check(res_line.ens) and jp ~= res_line.en:escape() and jps ~= res_line.ens:escape() and res_line.ens ~= 'PUP' then
                trans_list[jps] = green_col..res_line.ens..rcol:escape()
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
        load_dict(dict)
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
        local packet = packets.parse('incoming', modi)
        local out_text = packet.Message
        
        out_text = translate_phrase(out_text)
        
        if not out_text then return end
        
        if show_original then windower.add_to_chat(8, '[Original]: '..packet.Message) end
        
        packet.Message = out_text
        local rebuilt = packets.build(packet)
        return rebuilt
    end
end)

function translate_phrase(out_text)
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
    
    local order = {}
    for len,_ in pairs(matches) do
        local c,found = 1,false
        while c <= #order do
            if len > order[c] then
                table.insert(order,c,len)
                found = true
                break
            end
            c = c + 1
        end
        if c > #order then order[c] = len end
    end
    
    for _,ind in ipairs(order) do
        for _,option in ipairs(matches[ind]) do
            out_text = sjis_gsub(out_text,unescape(option),unescape(trans_list[option]))
        end
    end
    return out_text
end

function get_boundary_length(str,limit)
    -- If it is already short enough, return it
    if #str <= limit then return #str end
    
    local lim = 0
    for i= 1,#str do
        local c_byte = str:byte(i)
        if c_byte == 0xFD then
            i = i + 6
        elseif ( (c_byte > 0x7F and c_byte <= 0xA0) or c_byte >= 0xE0) then
            i = i + 2
        else
            i = i + 1
        end
        if i > limit then
            return lim
        else
            lim = i
        end
    end
    
    -- Otherwise, try to pick a spot to split that will not interfere with command codes and such
--[[    local boundary = limit
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
    return boundary]]
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
    elseif commands[1]:lower() == 'eval' and commands[2] then
        table.remove(commands,1)
        assert(loadstring(table.concat(commands, ' ')))()
    end
end)

windower.register_event('incoming text',function(org,mod,ocol,mcol,blk)
    if not blk and ocol == 204 then
        local ret = translate_phrase(org)
        if os.clock()-search_comment.ts>0.4 then
            search_comment = {ts = os.clock(), reg = L{}, translated = false}
        end
        if ret then
            if not search_comment.reg:contains(ret) then
                search_comment.translated = true
                search_comment.reg:append(ret)
                windower.add_to_chat(204,ret)
                coroutine.yield(true)
                if show_original then
                    coroutine.sleep(0.3)
                    if search_comment.translated then windower.add_to_chat(8,'[Original]: '..org) end
                end
            end
        elseif not search_comment.reg:contains(org) then
            search_comment.reg:append(org)
            windower.add_to_chat(204,org)
            coroutine.yield(true)
            if show_original then
                coroutine.sleep(0.3)
                if search_comment.translated then windower.add_to_chat(8,'[Original]: '..org) end
            end
        end
    end
end)

function unescape(str)
    return (str:gsub('%%([%%%%^%$%*%(%)%.%+%?%-%]%[])','%1'))
end


-- Two problems with how I currently do this:
-- 1: It is possible to have something like 0x94, (0x92, 0x8B,) 0xE1, which are two JP characters that contain a third.
-- 2: It is possible to have a gsub replace something with an autotranslate code, which then causes a later dictionary
--    option to match part of the replacement.
-- If I solve #1, will #2 be an issue? No, it should not be.

function sjis_gsub(str,pattern,rep)
    if not (type(rep) == 'function' or type(rep) == 'string') then return str end
    local str_len,pat_len,ret_str = string.len(str),string.len(pattern),str
    local i = 1
    while i<=str_len-pat_len+1 do
        local c_byte = str:byte(i)
        if str:sub(i,i+pat_len-1) == pattern then
            if type(rep) == 'function' then
                ret_str = rep(pattern) or str
                -- No recursion for functions at the moment, because this addon doesn't need it
                return
            elseif type(rep) == 'string' then
                if i ~= 1 then
                    -- Not the beginning
                    ret_str = str:sub(1,i-1)..rep
                else
                    -- The beginning
                    ret_str = rep
                end
                if i+pat_len <= str_len-pat_len+1 then
                    -- i == 13, pat_len == 2, str_len == 16
                    -- Match is characters 13 and 14. Could conceivably match again to characters 15 and 16.
                    
                    -- Send the remainder of the string back through recursively.
                    return ret_str..sjis_gsub(str:sub(i+pat_len),pattern,rep)
                elseif i+pat_len <= str_len then
                    -- i == 14, pat_len == 2, str_len == 16
                    -- Match is characters 14 and 15, so 16 can't possibly be a match but needs to be stuck on there
                    return ret_str..str:sub(i+pat_len)
                else
                    -- i == 15, pat_len == 2, str_len == 16
                    -- Match is characters 15 and 16, so no further addition is necessary
                    return ret_str
                end
            end
        elseif c_byte == 0xFD then
            i = i + 6
        elseif ( (c_byte > 0x7F and c_byte <= 0xA0) or c_byte >= 0xE0) then
            i = i + 2
        else
            i = i + 1
        end
    end
    return ret_str
end
