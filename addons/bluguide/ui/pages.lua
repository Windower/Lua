local pgs = {}

function pgs.new(x, y)
    return setmetatable({ x = x, y = y, boxlist = {} }, {__index = pgs})
end

function pgs.add(me, newbox)
    if newbox then
        me.boxlist[#me.boxlist+1] = newbox
    end
    me:update()
end

function pgs.update(me)
    for i = 1, #me.boxlist do
        me.boxlist[i]:update()
        if i > 1 then 
            me.boxlist[i]:pos(me.boxlist[i - 1]:left(), me.boxlist[i - 1]:bottom() + lineheight)
            local info = windower.get_windower_settings()
            if me.boxlist[i]:bottom() > info.ui_y_res - 150 then
                me.boxlist[i]:pos(me.boxlist[i]:left() + 240, me.y)
            end
        else
            me.boxlist[i]:pos(me.x, me.y)
        end
    end
end

function pgs.show(me)
    for _, v in pairs(me.boxlist) do
        v:show()
    end
end

function pgs.hide(me)
    for _, v in pairs(me.boxlist) do
        v:hide()
    end
end

return pgs