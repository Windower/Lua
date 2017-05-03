--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

-- Bind Events
-- ON LOAD
windower.register_event('load', function()
    if windower.ffxi.get_info().logged_in then
        initialize()
        show()
    end
end)

-- ON LOGIN
windower.register_event('login', function()
    show()
end)

-- ON LOGOUT
windower.register_event('logout', function()
    hide()
end)

-- BIND EVENTS
windower.register_event('hp change', function(new, old)
    current_hp = new
    hp_update = true
end)

windower.register_event('hpp change', function(new, old)
    hpp = new
    hp_update = true
end)

windower.register_event('mp change', function(new, old)
    current_mp = new
    mp_update = true
end)

windower.register_event('mpp change', function(new, old)
    mpp = new
    mp_update = true
end)

windower.register_event('tp change', function(new, old)
    current_tp = new

    tpp = current_tp

    if current_tp ~= 0 then
        tpp = current_tp / 10

        if tpp > 100 then tpp = 100 end
    end

    tp_update = true
end)

windower.register_event('prerender', function()
    if ready == false then
        return
    end

    if hp_update then
        update_bar(hp_foreground, hp_bar_width, hp_text, current_hp, hpp, 1)
    end

    if mp_update then
        update_bar(mp_foreground, mp_bar_width, mp_text, current_mp, mpp, 2)
    end

    if tp_update then
        update_bar(tp_foreground, tp_bar_width, tp_text, current_tp, tpp, 3)
    end
end)

windower.register_event('status change', function(new_status_id)
    if hide_bars == false and (new_status_id == 4) then
        hide_bars = true
        hide()
    elseif hide_bars and new_status_id ~= 4 then
        hide_bars = false
        show()
    end
end)