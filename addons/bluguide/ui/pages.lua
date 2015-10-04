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