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

function actor_noun(msg)
    if msg then
        msg = msg
            :gsub('${actor}', 'The ${actor}')
    end
    return msg
end

function plural_actor(msg)
    if msg then
        msg = msg
            :gsub('${actor} hits ', '${actor} hit ')
            :gsub('${actor} casts ', '${actor} cast ')
            :gsub('${actor} starts ', '${actor} start ')
            :gsub('${actor} defeats ', '${actor} defeat ')
            :gsub('${actor} gains ', '${actor} gain ')
            :gsub('${actor} attains ', '${actor} attain ')
            :gsub('${actor} loses ', '${actor} lose ')
            :gsub('${actor} falls ', '${actor} fall ')
            :gsub("${actor}'s ", "${actor}' ")
            :gsub('${actor} misses ' , '${actor} miss ')
            :gsub('${actor} calls ' , '${actor} call ')
            :gsub('${actor} learns ' , '${actor} learn ')
            :gsub('${actor} uses ' , '${actor} use ')
            :gsub('${actor} is ' , '${actor} are ')
            :gsub('${actor} takes ' , '${actor} take ')
            :gsub('${actor} does ' , '${actor} do ')
            :gsub('${actor} lacks ' , '${actor} lack ')
            :gsub('${actor} redies ' , '${actor} ready ')
            :gsub('${actor} earns ' , '${actor} earn ')
            :gsub('${actor} scores ' , '${actor} score ')
            :gsub('${actor} successfully removes ' , '${actor} successfully remove ')
            :gsub('${actor} achieves ' , '${actor} achieve ')
            :gsub('${actor} mugs ' , '${actor} mug ')
            :gsub('${actor} steals ' , '${actor} steal ')
            :gsub('${actor} fails ' , '${actor} fail ')
            :gsub(' but finds nothing' , ' but find nothing')
            :gsub(' and finds ${item}' , ' and find ${item}')
            :gsub('${actor} recovers ' , '${actor} recover ')
            :gsub('${ability}, but misses' , '${ability}, but miss')
            :gsub(' but misses ${target}' , ' but miss ${target}')
            :gsub('${actor} covers ' , '${actor} cover ')
            :gsub('${actor} already has ' , '${actor} already have ')
            :gsub('${actor} attempts ' , '${actor} attempt ')
            :gsub(' but lacks ' , ' but lack ')
            :gsub('${actor} destroys ' , '${actor} destroy ')
            :gsub('${actor} absorbs ' , '${actor} absorb ')
            :gsub('${actor} eats ' , '${actor} eat ')
            :gsub('${actor} leads ' , '${actor} lead ')
            :gsub('${actor} has ' , '${actor} have ')
            :gsub('${actor} obtains ' , '${actor} obtain ')
            :gsub(' and finds ${number}' , ' and find ${number}')
    end
    return msg
end

function plural_target(msg)
    if msg then
        msg = msg
            :gsub('${target} takes ', '${target} take ')
            :gsub('${target} is ', '${target} are ')
            :gsub('${target} recovers ', '${target} recover ')
            :gsub("${target}'s ", targets_condensed and '${target} ' or "${target}' ")
            :gsub('${target} falls ', '${target} fall ')
            :gsub('${target} uses ', '${target} use ')
            :gsub('${target} resists', '${target} resist')
            :gsub('${target} vanishes', '${target} vanish')
            :gsub('${target} receives ', '${target} receive ')
            :gsub('${target} seems ${skill}', '${target} seem ${skill}')
            :gsub('${lb}It seems to have ', '${lb}They seem to have ')
            :gsub('${target} gains ', '${target} gain ')
            :gsub('${target} evades', '${target} evade')
            :gsub('${target} regains ', '${target} regain ')
            :gsub('${target} narrowly escapes ', '${target} narrowly escape ')
            :gsub('${target} obtains ', '${target} obtain ')
            :gsub('${target} learns ', '${target} learn ')
            :gsub('${target} loses ', '${target} lose ')
            :gsub('${target} was ', '${target} were ')
            :gsub('${target} has ', '${target} have ')
            :gsub('${target} completely resists ', '${target} completely resist ')
            :gsub('${target} now has ', '${target} now have ')
            :gsub('${target} feels ', '${target} feel ')
            :gsub('${target} stands ', '${target} stand ')
    end
    return msg
end

function clean_msg(msg)
    if msg then
        msg = msg
            :gsub(' The ', ' the ')
        msg = msg
            :gsub('%. the ', '. The ')
            :gsub(': the ', ': The ')
            :gsub('! the ', '! The ')
    end
    return msg
end

function grammatical_number_fix(msg, number)
    if msg then
        if number == 1 then
            msg = msg
                :gsub(' points', ' point')
                :gsub('${number} Ballista Points', '${number} Ballista Point')
                :gsub('healed of ${number} status ailments', 'healed of ${number} status ailment')
                :gsub('magical effects from', 'magical effect from')
        else
            msg = msg
                :gsub(' absorbs', ' absorb')
                :gsub(' Petra', ' Petras')
                :gsub('disappears', 'disappear')
                :gsub('attributes is', 'attributes are')
                :gsub('status effect is', 'status effects are')
                :gsub('piece', 'pieces')
                :gsub('Finishing move now ', 'Finishing moves now ')
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
