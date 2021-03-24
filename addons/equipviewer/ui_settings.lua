--[[
        Copyright © 2021, Rubenator
        All rights reserved.
        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:
            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of EquipViewer nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.
        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Rubenator BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
function refresh_ui_settings()
    --Image and text settings
    bg_image_settings = {
        color = {
            alpha = math.floor(80*settings.alpha/255),
            red = 0,
            blue = 0,
            green = 0
        }, 
        pos = {
            x = settings.pos.x,
            y = settings.pos.y,
        },
        size = {
            width = settings.size * 4,
            height = settings.size * 4,
        },
        draggable = false,
    }
    equipment_image_settings = {
        color = {
            alpha = settings.alpha,
            red = 255,
            blue = 255,
            green = 255,
        },
        texture = {
            fit = true,
        },
        size = {
            width = settings.size,
            height = settings.size,
        },
        draggable = false,
    }
    encumbrance_image_settings = {
        color = {
            alpha = settings.alpha*0.8,
            red = 255,
            blue = 255,
            green = 255,
        },
        texture = {
            fit = true,
        },
        size = {
            width = settings.size,
            height = settings.size,
        },
        draggable = false,
    }
    ammo_count_text_settings = {
        text = {
            size = settings.size*0.27,
            alpha = settings.alpha,
            red = 255,
            blue = 255,
            green = 255,
            stroke = {
                width = 1,
                alpha = 127,
                red = 0,
                green = 0,
                blue = 0,
            },
        },
        bg = {
            alpha = 0,
            red = 255,
            blue = 255, 
            green = 255,
        },
        pos = {
            x = (windower.get_windower_settings().ui_x_res - (settings.pos.x + settings.size*4))*-1,
            y = settings.pos.y + settings.size*0.58,
        },
        flags = {
            draggable = false,
            right = true,
            bold = true,
            italic = true,
        },
    }
    ammo_count_text_settings_left_justify = {
        text = {
            size = settings.size*0.27,
            alpha = settings.alpha,
            red = 255,
            blue = 255,
            green = 255,
            stroke = {
                width = 1,
                alpha = 127,
                red = 0,
                green = 0,
                blue = 0
            },
        },
        bg = {
            alpha = 0,
            red = 255,
            blue = 255,
            green = 255
        },
        pos = {
            x = settings.pos.x + settings.size*3,
            y = settings.pos.y + settings.size*0.58
        },
        flags = {
            draggable = false,
            right = false,
            bold = true,
            italic = true,
        },
    }
end
