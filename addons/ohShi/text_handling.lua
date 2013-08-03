texts = require 'texts'

--Create the textbox
function initText()
    ohShi_tb = texts.new(settings)
    tracking:append('ohShi initialized ')
    textUpdate()
    send_command('@wait '..settings.duration..'; lua i ohshi remText')
end

--Removes first line of a textbox
function remText()
    if #tracking > 0 then
        table.remove(tracking,1)
        textUpdate()
    end
end

--Add text to textbox. Anytime text is added this is called.
function addText(name,abtype,abil,dMob,dangerous)
    if abtype == 'ws' then
        doit = true
        abilname = mAbils[abil-256]['english']
    elseif abtype == 'spell' then
        doit = true
        abilname = spells[abil]['english']
    elseif abtype == 'roll' then
        doit = true
        abilname = jAbils[abil]['english']..' ['..dMob..']'
        dMob = nil
        dangerous = nil
    elseif name == 'vulnerable' then
        if dMob == ' extremely ' then
            tracking:append(' \\cs(255,100,100)Weakness 5: '..dangerous:capitalize()..'\\cr')
        elseif dMob == ' highly ' then
            tracking:append(' \\cs(255,100,100)Weakness 3: '..dangerous:capitalize()..'\\cr')
        else
            tracking:append(' Weakness 1: '..dangerous:capitalize())
        end
    elseif name == 'bluered' then
        tracking:append(' Blue: '..dMob..'% Red: '..dangerous..'%')
    elseif name == 'red' then
        tracking:append(' Red: '..dMob..'%')
    elseif name == 'blue' then
        tracking:append(' Blue: '..dMob..'%')
    elseif name == 'devastates' then
        tracking:append(' Fiend devastated by: '..dMob)
    else
        tracking:append(' '..name)
    end
    if doit then
        local str = name..': '..abilname
        if dangerous or dMob then
            tracking:append(' \\cs(255,100,100)'..str..'\\cr')
            flashImage()
        else
            tracking:append(' '..str)
        end
    end
    send_command('@wait '..settings.duration..'; lua i ohshinew remText')
    textUpdate()
end

--Called anytime text is added to the tracking table
--Refreshes the textbox and hides/shows it if needed.
function textUpdate()
    if #tracking > 0 then
        local txt = ''
        for inc = 1, #tracking do
            txt = txt..tracking[inc]
            if inc < #tracking then
                txt = txt..'\n'
            end
        end
        ohShi_tb:text(txt)
        ohShi_tb:show()
    else
        ohShi_tb:text('')
        ohShi_tb:hide()
    end
end

--image handling
--This function is used to flash the warning image
--when a danger tp/spell is used.
function flashImage()
    local name = 'ohShi'..tostring(math.random(10000000,99999999))
    prims:add(name)
    prim_create(name)
    prim_set_color(name,255,255,255,255)
    prim_set_fit_to_texture(name,false)
    prim_set_texture(name,lua_base_path..'data/warning.png')
    prim_set_repeat(name,1,1)
    prim_set_visibility(name,true)
    prim_set_position(name,settings.pos.x-30,settings.pos.y-10)
    prim_set_size(name,30,30)
    send_command('@wait '..settings['duration']..';lua i ohshinew deleteImage '..name)
end

--Called to delete the image after it's time is up.
function deleteImage(str)
    prims:remove(str)
    prim_delete(str)
end