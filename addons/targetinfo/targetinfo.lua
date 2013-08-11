require 'luau'
texts = require 'texts'

-- Config

_addon = {}
_addon.name = 'TargetInfo'
_addon.command = 'targetinfo'
_addon.shortcommand = 'ti'
_addon.ver = '1.0.0.0'

defaults = {}
defaults.showhexid = true
defaults.showfullid = true
defaults.showspeed = true
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.bg = {}
defaults.display.bg.red = 0
defaults.display.bg.green = 0
defaults.display.bg.blue = 0
defaults.display.bg.alpha = 102
defaults.display.text = {}
defaults.display.text.font = 'Consolas'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 12

text = {}

-- Events

function render_box()
	local mob = get_mob_by_target('t')
	if mob and mob.id > 0 and mob.is_npc then
        local info = {}
        info.hex = mob.id:hex():slice(-3)
        info.full = mob.id
        local speed = math.round(100*(mob.speed/4 - 1), 2)
        info.speed = (
            speed > 0 and
                '\\cs(0,255,0)+'..speed
            or speed < 0 and
                '\\cs(255,0,0)'..speed
            or
                speed)..'%\\cr'
        text_box:update(info)
        text_box:show()
	else
		text_box:hide()
	end
end

-- Constructor

register_event('load', function()
	settings = config.load(defaults)
	settings:save()

    local properties = L{}
    if settings.showhexid then
        properties:append('Hex ID:  ${hex|-}')
    end
    if settings.showfullid then
        properties:append('Full ID: ${full|-}')
    end
    if settings.showspeed then
        properties:append('Speed:   ${speed|-}')
    end
	text_box = texts.new(properties:concat('\n'), settings.display, settings)

    register_event('prerender', render_box)
end)
