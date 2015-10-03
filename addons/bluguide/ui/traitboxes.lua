local tbx = {}
buttons = require("ui/buttons")
texts = require("texts")
spellbuttons = require("ui/spellbuttons")

local default_settings = {
    text = { size = 10, font = 'Lucida Console' },
    bg = { alpha = 120, red = 0, green = 0, blue = 0, visible = false },
    flags = {draggable = false}
}

local header_settings = {
    text = { size = 10, font = 'Lucida Console',},
    bg = { alpha = 200, red = 0, green = 100, blue = 100, visible = false },
}

function tbx.new(trait)
    local me = { trait = trait, x = 0, y = 0, splist = {}, collapsed = false}
    
    me.greybox = texts.new("", default_settings)
    me.greenbox = texts.new("", default_settings)
    me.greybox:color(190, 190, 190)
    me.greenbox:color(50, 255, 50)
    me.greenbox:bg_visible(true)
    me.greybox:bg_visible(false)
    
    me.header = buttons.new(string.format('- %-24s', trait.name), header_settings)
    me.header.bold(false)
    me.header.color(255, 255, 255)
    me.header.bg_color(0, 100, 100)
    me.header.left_click = function() collapsetrait(me) end
    me.header.hover_on = function() show_bg(me) end
    me.header.hover_off = function() hide_bg(me) end
    
    local linenum = 1
    local totalpoints = 0
    for k, v in pairs(trait.spells) do
        if spellinfo[v.id].level <= setspells.limits.level then
            me.splist[#me.splist+1] = spellbuttons.new(string.format('  %-20s %i %i', v.name, v.cost, v.points), v.id, v.cost, me.x, me.y + (linenum * lineheight))
            me.splist[#me.splist]:update()
            linenum = linenum + 1
            totalpoints = totalpoints + v.points
        end
    end
    
    if totalpoints >= 8 then return setmetatable(me, {__index = tbx}) end
    
    for _, v in pairs(me.splist) do
        v:destroy()
    end
    return nil
end

function tbx.update(me)
    local vspace = "                          \n  "
    for _, v in pairs(me.splist) do
        v:update()
        if not me.collapsed then
            vspace = vspace.."\n    "
        end
    end
        
    local traitpoints = 0
    for k, v in pairs(me.trait.spells) do
        if setspells[v.id] then
            traitpoints = traitpoints + v.points
        end
    end
    
    if traitpoints > 7 and giftexempttraits[me.trait.name] == nil then
        traitpoints = traitpoints + (8 * setspells.gifts)
    end
    
    me.greybox:text(vspace)
    me.greenbox:text(vspace)
    
    for v = 8, 48 do
        if me.trait.tiers[v] ~= nil then
            if me.trait.name == "Double/Triple Attack" then
                if v == 8 then
                    if traitpoints == 8 or traitpoints == 12 or sub == 'WAR' then
                        me.greenbox:append(string.format('%s ', me.trait.tiers[v]))
                        me.greybox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
                    else
                        me.greybox:append(string.format('%s ', me.trait.tiers[v]))
                        me.greenbox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
                    end
                elseif traitpoints >= 16 or sub == "THF" then
                    me.greenbox:append(string.format('%s ', me.trait.tiers[v]))
                    me.greybox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
                else
                    me.greybox:append(string.format('%s ', me.trait.tiers[v]))
                    me.greenbox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
                end
            elseif v <= traitpoints or (me.trait.subs[sub] and me.trait.subs[sub] >= v) then
                me.greenbox:append(string.format('%s ', me.trait.tiers[v]))
                me.greybox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
            else
                me.greybox:append(string.format('%s ', me.trait.tiers[v]))
                me.greenbox:append(string.gsub(me.trait.tiers[v], ".", " ").." ")
            end
        end
    end
end

function tbx.bottom(me)
    if not me.collapsed then
        return me.y + ((2 + #me.splist) * lineheight)
    else
        return me.y + (2 * lineheight)
    end
end

function tbx.left(me)
    return me.x 
end

function tbx.show(me)
    if not me.collapsed then
        for _, v in pairs(me.splist) do
            v:show()
        end
    end
    me.greenbox:show()
    me.greybox:show()
    me.header.show()
end

function tbx.pos(me, x, y)
    me.x = x
    me.y = y
    me.greybox:pos(x, y)
    me.greenbox:pos(x, y)
    me.header.pos(x, y)
    local by = 0
    for i = 1, #me.splist do
        by = by + lineheight
        me.splist[i]:pos(x, y+by)
    end
end

function tbx.hide(me)
    for _, v in pairs(me.splist) do
        v:hide()
    end
    me.greenbox:hide()
    me.greybox:hide()
    me.header.hide()
end

function show_bg(me)
    me.header.bg_visible(true)
end

function hide_bg(me)
    me.header.bg_visible(false)
end

function collapsetrait(me)
    me.collapsed = not me.collapsed
    if me.collapsed then
        me.header.text:text(string.format('+ %-24s', me.trait.name))
        me.header.bold(true)
        for _, v in pairs(me.splist) do
            v:hide()
        end
        me:update()
    else
        me.header.text:text(string.format('- %-24s', me.trait.name))
        me.header.bold(false)
        for _, v in pairs(me.splist) do
            v:show()
        end
    end
    update()
end

return tbx