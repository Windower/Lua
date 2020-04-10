--Copyright © 2013, Byrthnoth
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

function nf(field,subfield)
    if field ~= nil then
        return field[subfield]
    else
        return nil
    end
end

function flip(p1,p1t,p2,p2t,cond)
    return p2,p2t,p1,p1t,not cond
end

function colconv(str,key)
    -- Used in the options_load() function
    local out
    strnum = tonumber(str)
    if strnum >= 256 and strnum < 509 then
        strnum = strnum - 254
        out = string.char(0x1E,strnum)
    elseif strnum >0 then
        out = string.char(0x1F,strnum)
    elseif strnum == 0 then
        out = rcol
    else
        print('You have an invalid color '..key)
        out = string.char(0x1F,1)
    end
    return out
end


function color_it(to_color,color)
    if not color and debugging then windower.add_to_chat(8,'Color was invalid.') end
    if not color or color == 0 then return to_color end
    
    if to_color then
        local colarr = string.split(to_color,' ')
        colarr.n = nil
        return color..table.concat(colarr,rcol..' '..color)..rcol
    end
end


function conjunctions(pre,post,target_count,current)
    if current < target_count or commamode then
        pre = pre..', '
    else
        if oxford and target_count >2 then
            pre = pre..','
        end
        pre = pre..' and '
    end
    return pre..post
end



function fieldsearch(message)
    local fieldarr = {}
    string.gsub(message,"{(.-)}", function(a) fieldarr[a] = true end)
    return fieldarr
end


function check_filter(actor,target,category,msg)
    -- This determines whether the message should be displayed or filtered
    -- Returns true (don't filter) or false (filter), boolean
    if not actor.filter or not target.filter then return false end
    
    if not filter[actor.filter] and debugging then windower.add_to_chat(8,'Battlemod - Filter Not Recognized: '..tostring(actor.filter)) end
    
    local filtertab = (filter[actor.filter] and filter[actor.filter][target.filter]) or filter[actor.filter]

    if filtertab['all']
    or category == 1 and filtertab['melee']
    or category == 2 and filtertab['ranged']
    or category == 12 and filtertab['ranged']
    or category == 5 and filtertab['items']
    or category == 9 and filtertab['uses']
    or nf(res.action_messages[msg],'color')=='D' and filtertab['damage']
    or nf(res.action_messages[msg],'color')=='M' and filtertab['misses']
    or nf(res.action_messages[msg],'color')=='H' and filtertab['healing']
    or (msg == 43 or msg == 326) and filtertab['readies']
    or (msg == 3 or msg==327) and filtertab['casting']
    then
        return false
    end

    return true
end
