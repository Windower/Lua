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
