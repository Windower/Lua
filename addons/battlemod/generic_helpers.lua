--Copyright © 2023, Byrthnoth
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
    local strnum = tonumber(str)
    if strnum >= 256 and strnum < 509 then
        strnum = strnum - 254
        if strnum == 4 then strnum = 3 end --color 258 can bug chatlog
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
    string.gsub(message,'{(.-)}', function(a) fieldarr[a] = true end)
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

function actor_noun(msg)
    if msg then
        msg = msg
            :gsub('${actor}', 'The ${actor}')
    end
    return msg
end

function plural_actor(msg, msg_id)
    if msg then
        if msg_id == 6 then
            msg = msg:gsub('${actor} defeats ', '${actor} defeat ')
        elseif msg_id == 9 then
            msg = msg:gsub('${actor} attains ', '${actor} attain ')
        elseif msg_id == 10 then
            msg = msg:gsub('${actor} loses ', '${actor} lose ')
        elseif msg_id == 11 then
            msg = msg:gsub('${actor} falls ', '${actor} fall ')
        elseif msg_id == 19 then
            msg = msg:gsub('${actor} calls ' , '${actor} call ')
        elseif msg_id == 35 then
            msg = msg:gsub('${actor} lacks ' , '${actor} lack ')
        elseif msg_id == 67 then
            msg = msg:gsub('${actor} scores ' , '${actor} score ')
        elseif msg_id == 124 then
            msg = msg:gsub('${actor} achieves ' , '${actor} achieve ')
        elseif msg_id == 129 then
            msg = msg:gsub('${actor} mugs ' , '${actor} mug ')
        elseif msg_id == 244 then
            msg = msg:gsub('${actor} fails ' , '${actor} fail ')
        elseif msg_id == 311 then
            msg = msg:gsub('${actor} covers ' , '${actor} cover ')
        elseif msg_id == 315 then
            msg = msg:gsub('${actor} already has ' , '${actor} already have ')
        elseif msg_id ==411 then
            msg = msg
                :gsub('${actor} attempts ' , '${actor} attempt ')
                :gsub(' but lacks ' , ' but lack ')
        elseif msg_id == 536 then
            msg = msg:gsub('${actor} takes ' , '${actor} take ')
        elseif msg_id == 563 then
            msg = msg:gsub('${actor} destroys ' , '${actor} destroy ')
        elseif msg_id == 772 then
            msg = msg:gsub('${actor} stands ', '${actor} stand ')
        elseif replacements_map.actor.hits:contains(msg_id) then
            msg = msg:gsub('${actor} hits ', '${actor} hit ')
        elseif replacements_map.actor.misses:contains(msg_id) then
            msg = msg:gsub('${actor} misses ' , '${actor} miss ')
        elseif replacements_map.actor.starts:contains(msg_id) then
            msg = msg:gsub('${actor} starts ', '${actor} start ')
        elseif replacements_map.actor.casts:contains(msg_id) then
            msg = msg:gsub('${actor} casts ', '${actor} cast ')
            if msg_id == 83 then
                msg = msg:gsub('${actor} successfully removes ' , '${actor} successfully remove ')
            elseif msg_id == 572 or msg_id == 642 then
                msg = msg:gsub('${actor} absorbs ' , '${actor} absorb ')
            end
        elseif replacements_map.actor.readies:contains(msg_id) then
            msg = msg:gsub('${actor} readies ' , '${actor} ready ')
        elseif replacements_map.actor.recovers:contains(msg_id) then
            msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
        elseif replacements_map.actor.gains:contains(msg_id) then
            msg = msg:gsub('${actor} gains ', '${actor} gain ')
        elseif replacements_map.actor.apos:contains(msg_id) then
            msg = msg:gsub('${actor}\'s ', '${actor}\' ')
            if msg_id == 33 then
                msg = msg:gsub('${actor} takes ' , '${actor} take ')
            elseif msg_id == 606 then
                msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
            elseif msg_id == 799 then
                msg = msg:gsub('${actor} is ' , '${actor} are ')
            end
        elseif replacements_map.actor.uses:contains(msg_id) then
            msg = msg:gsub('${actor} uses ' , '${actor} use ')
            if msg_id == 122 then
                msg = msg:gsub('${actor} recovers ' , '${actor} recover ')
            elseif msg_id == 123 then
                msg = msg:gsub('${actor} successfully removes ' , '${actor} successfully remove ')
            elseif msg_id == 126 or msg_id == 136 or msg_id == 528 then
                msg = msg:gsub('${actor}\'s ', '${actor}\' ')
            elseif msg_id == 137 or msg_id == 153 then
                msg = msg:gsub('${actor} fails ' , '${actor} fail ')
            elseif msg_id == 139 then
                msg = msg:gsub(' but finds nothing' , ' but find nothing')
            elseif msg_id == 140 then
                msg = msg:gsub(' and finds a ${item2}' , ' and find a ${item2}')
            elseif msg_id == 158 then
                msg = msg:gsub('${ability}, but misses' , '${ability}, but miss')
            elseif msg_id == 585 then
                msg = msg:gsub('${actor} is ' , '${actor} are ')
            elseif msg_id == 674 then
                msg = msg:gsub(' and finds ${number}' , ' and find ${number}')
            elseif msg_id == 780 then
                msg = msg:gsub('${actor} takes ' , '${actor} take ')
            elseif replacements_map.actor.steals:contains(msg_id) then
                msg = msg:gsub('${actor} steals ' , '${actor} steal ')
            elseif replacements_map.actor.butmissestarget:contains(msg_id) then
                msg = msg:gsub(' but misses ${target}' , ' but miss ${target}')
            end
        elseif replacements_map.actor.is:contains(msg_id) then
            msg = msg:gsub('${actor} is ' , '${actor} are ')
        elseif replacements_map.actor.learns:contains(msg_id) then
            msg = msg:gsub('${actor} learns ' , '${actor} learn ')
        elseif replacements_map.actor.has:contains(msg_id) then
            msg = msg:gsub('${actor} has ' , '${actor} have ')
        elseif replacements_map.actor.obtains:contains(msg_id) then
            msg = msg:gsub('${actor} obtains ' , '${actor} obtain ')
        elseif replacements_map.actor.does:contains(msg_id) then
            msg = msg:gsub('${actor} does ' , '${actor} do ')
        elseif replacements_map.actor.leads:contains(msg_id) then
            msg = msg:gsub('${actor} leads ' , '${actor} lead ')
        elseif replacements_map.actor.eats:contains(msg_id) then
            msg = msg:gsub('${actor} eats ' , '${actor} eat ')
            if msg_id == 604 then
                msg = msg:gsub(' but finds nothing' , ' but find nothing')
            end
        elseif replacements_map.actor.earns:contains(msg_id) then
            msg = msg:gsub('${actor} earns ' , '${actor} earn ')
        end
    end
    return msg
end

function plural_target(msg, msg_id)
    if msg then
        if msg_id == 282 then
            msg = msg:gsub('${target} evades', '${target} evade')
        elseif msg_id == 359 then
            msg = msg:gsub('${target} narrowly escapes ', '${target} narrowly escape ')
        elseif msg_id == 419 then
            msg = msg:gsub('${target} learns ', '${target} learn ')
        elseif msg_id == 671 then
            msg = msg:gsub('${target} now has ', '${target} now have ')
        elseif msg_id == 764 then
            msg = msg:gsub('${target} feels ', '${target} feel ')
        elseif replacements_map.target.takes:contains(msg_id) then
            msg = msg:gsub('${target} takes ', '${target} take ')
            if msg_id == 197 then
                msg = msg:gsub('${target} resists', '${target} resist')
            end
        elseif replacements_map.target.is:contains(msg_id) then
            msg = msg:gsub('${target} is ', '${target} are ')
        elseif replacements_map.target.recovers:contains(msg_id) then
            msg = msg:gsub('${target} recovers ', '${target} recover ')
        elseif replacements_map.target.apos:contains(msg_id) then --coincidence in 439 and 440
            msg = msg:gsub('${target}\'s ', targets_condensed and '${target} ' or '${target}\' ')
            if msg_id == 439 or msg_id == 440 then
                msg = msg:gsub('${target} regains ', '${target} regain ')
            end
        elseif replacements_map.target.falls:contains(msg_id) then
            msg = msg:gsub('${target} falls ', '${target} fall ')
        elseif replacements_map.target.uses:contains(msg_id) then
            msg = msg:gsub('${target} uses ', '${target} use ')
        elseif replacements_map.target.resists:contains(msg_id) then
            msg = msg:gsub('${target} resists', '${target} resist')
        elseif replacements_map.target.vanishes:contains(msg_id) then
            msg = msg:gsub('${target} vanishes', '${target} vanish')
        elseif replacements_map.target.receives:contains(msg_id) then
            msg = msg:gsub('${target} receives ', '${target} receive ')
        elseif replacements_map.target.seems:contains(msg_id) then
            msg = msg:gsub('${target} seems ${skill}', '${target} seem ${skill}')
            if msg_id ~= 174 then
                msg = msg:gsub('${lb}It seems to have ', '${lb}They seem to have ')
            end
        elseif replacements_map.target.gains:contains(msg_id) then
            msg = msg:gsub('${target} gains ', '${target} gain ')
        elseif replacements_map.target.regains:contains(msg_id) then
            msg = msg:gsub('${target} regains ', '${target} regain ')
        elseif replacements_map.target.obtains:contains(msg_id) then
            msg = msg:gsub('${target} obtains ', '${target} obtain ')
        elseif replacements_map.target.loses:contains(msg_id) then
            msg = msg:gsub('${target} loses ', '${target} lose ')
        elseif replacements_map.target.was:contains(msg_id) then
            msg = msg:gsub('${target} was ', '${target} were ')
        elseif replacements_map.target.has:contains(msg_id) then
            msg = msg:gsub('${target} has ', '${target} have ')
        elseif replacements_map.target.compresists:contains(msg_id) then
            msg = msg:gsub('${target} completely resists ', '${target} completely resist ')
        end
    end
    return msg
end

function clean_msg(msg, msg_id)
    if msg then
        msg = msg
            :gsub(' The ', ' the ')
            :gsub(': the ', ': The ')
            :gsub('! the ', '! The ')
        if replacements_map.the.point:contains(msg_id) then
            msg = msg:gsub('%. the ', '. The ')
        end
    end
    return msg
end

function grammatical_number_fix(msg, number, msg_id)
    if msg then
        if number == 1 then
            if replacements_map.number.points:contains(msg_id) then
                msg = msg:gsub(' points', ' point')
            elseif msg_id == 411 then
                msg = msg:gsub('${number} Ballista Points', '${number} Ballista Point')
            elseif msg_id == 589 then
                msg = msg:gsub('healed of ${number} status ailments', 'healed of ${number} status ailment')
            elseif msg_id == 778 then
                msg = msg:gsub('magical effects from', 'magical effect from')
            end
        else
            if replacements_map.number.absorbs:contains(msg_id) then
                msg = msg:gsub(' absorbs', ' absorb')
            elseif msg_id == 133 then
                msg = msg:gsub(' Petra', ' Petras')
            elseif replacements_map.number.attributes:contains(msg_id) then
                msg = msg:gsub('attributes is', 'attributes are')
            elseif replacements_map.number.status:contains(msg_id) then
                msg = msg:gsub('status effect is', 'status effects are')
            elseif msg_id == 557 then
                msg = msg:gsub('piece', 'pieces')
            elseif msg_id == 560 then
                msg = msg:gsub('Finishing move now ', 'Finishing moves now ')
            end
            if replacements_map.number.disappears:contains(msg_id) then
                msg = msg:gsub('disappears', 'disappear')
            end
        end
    end
    return msg
end

function item_article_fix(id,id2,msg)
    if id then
        if string.gmatch(msg, ' a ${item}') then
            local article = res.items_grammar[id] and res.items_grammar[id].article
            if article == 1 then
                msg = string.gsub(msg,' a ${item}',' an ${item}')
            end
        end
    end
    if id2 then
        if string.gmatch(msg, ' a ${item2}') then
            local article = res.items_grammar[id2] and res.items_grammar[id2].article
            if article == 1 then
                msg = string.gsub(msg,' a ${item2}',' an ${item2}')
            end
        end
    end
    return msg
end

function add_item_article(id)
    local article = ''
    local article_type = res.items_grammar[id] and res.items_grammar[id].article or nil
    if id then
        if article_type == 2 then
            article = 'pair of '
        elseif article_type == 3 then
            article = 'suit of '
        end
    end
    return article
end

function send_delayed_message(color,msg)
    local message = msg
        :gsub('${count}', item_quantity.count)
    windower.add_to_chat(color,message)
    item_quantity.id = 0
    item_quantity.count = ''
    parse_quantity = false
end
