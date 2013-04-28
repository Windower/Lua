require 'luau'

-- Config

_addon = {}
_addon.name = 'TargetInfo'
_addon.command = 'targetinfo'
_addon.shortcommand = 'ti'
_addon.ver = 0.9

defaults = {}
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

function setID(index)
	local mob = get_mob_by_index(index)
	local id = mob['id']
	if id and id > 0 then
		tb_set_visibility('targetid', true)
		if mob['is_npc'] then
			tb_set_text('targetid', id:tohex():slice(-3))
		else
			tb_set_visibility('targetid', false)
		end
	else
		tb_set_visibility('targetid', false)
	end
end

-- Events

function event_target_change(target_index)
	setID(target_index)
end

-- Constructor

function event_load()
	settings = config.load(defaults)

	tb_create('targetid')
	tb_set_location('targetid', settings.pos.x, settings.pos.y)
	tb_set_bg_color('targetid', settings.bg.alpha, settings.bg.red, settings.bg.green, settings.bg.blue)
	tb_set_bg_visibility('targetid', true)
	tb_set_color('targetid', settings.text.alpha, settings.text.red, settings.text.green, settings.text.blue)
	tb_set_font('targetid', settings.text.font, settings.text.size)

	setID(get_player()['target_index'])
end

-- Destructor

function event_unload()
	tb_delete('targetid')
	send_command('unalias targetidpos')
end