require 'luau'
texts = require 'texts'

-- Config

_addon = {}
_addon.name = 'TargetInfo'
_addon.command = 'targetinfo'
_addon.shortcommand = 'ti'
_addon.ver = 0.9

defaults = {}
defaults.showhexid = true
defaults.showfullid = false
defaults.showspeed = false
defaults.pos = {}
defaults.pos.x = 0
defaults.pos.y = 0
defaults.bg = {}
defaults.bg.red = 0
defaults.bg.green = 0
defaults.bg.blue = 0
defaults.bg.alpha = 102
defaults.text = {}
defaults.text.font = 'Arial'
defaults.text.red = 0
defaults.text.green = 0
defaults.text.blue = 0
defaults.text.alpha = 255
defaults.text.size = 12

text = {}

function setID(index)
    if index == 0 then
        text:hide()        
        return
    end

    local mob = get_mob_by_index(index)
    local id = mob['id']

    if id and id > 0 then
        text:show()
        if mob['is_npc'] then
            text:text(id:tohex():slice(-3))
        else
            text:hide()
        end
    else
        text:hide()
    end
end

-- Events

function event_target_change(target_index)
    setID(target_index)
end

-- Constructor

function event_load()
    settings = config.load(defaults)
    settings:save()

    text = texts.new(settings)

    setID(get_player()['target_index'])
    
    send_command('alias targetinfo')
end

-- Destructor

function event_unload()
    text:destroy()
    send_command('unalias targetid')
end
