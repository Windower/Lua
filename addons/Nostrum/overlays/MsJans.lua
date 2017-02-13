overlay.name = 'MsJans'
overlay.author = 'trv'
overlay.version = '1.0.0'

require 'display_settings'
require 'helper_functions'
require 'macro_builder'

settings = config.load('overlays/MsJans/data/display_settings.xml', settings)

bg = {}
macro = {{}, {}, {}}
palette = {{}, {}, {}, buffs = {}, statuses = {}}
macro_grid = {}
palette_grid = {}
--specials_grid : This exists if the specials settings aren't empty
widget_lookup = {{}, {}, {}}
misc_bin = {}

function tp(bin, n)
	bin.tp:text(tostring(n))
end

function hp(bin, n)
	bin.hp:text(tostring(n))
end

function mp(bin, n)
	bin.mp:text(tostring(n))
end

function hpp(bin, n)
	bin.hpp:text(tostring(n))
end

function hpp_bar(bin, n)
	local obj = bin.phpp
	local color = settings.prim.hp[math.ceil(n/25)*25]

	obj:width(n/100 * settings.prim.bar_width)
	obj:argb(color.a, color.r, color.g, color.b)
end

function mpp_bar(bin, n)
	bin.pmpp:width(n/100 * settings.prim.bar_width)
end

function name(bin, s)
	bin.name:text(string.sub(s, 1, settings.text.name.truncate) .. '...')
end

register_event('load', function()
	palette_settings_parser()
	load_text_dimensions()
	measure_text_labels()
	--[[macro_builder.new_party(1)
	macro_builder.header()
	macro_builder.specials()--]]


	--[[for i = 1, alliance[1].count() do
		macro_builder.new_player(1, i)
	end--]]
	
	for i = 1, 3 do
		local count = alliance[i].count()
		
		if count > 0 then
			macro_builder.new_party(i)
			
			for j = 1, count do
				macro_builder.new_player(i, j)
			end
		end
	end
	
	macro_builder.header()
	macro_builder.specials()
end)

register_event('new party', function(position)
	macro_builder.new_party(position)
end)

register_event('disband party', function(position)

end)

register_event('member join', function(party, position, player)
	local bin = widget_lookup[party][position]
	
	if bin then
		update_all(bin, player)
		
		for _, obj in pairs(bin) do
			obj:show()
			-- check to see if they're in the zone
		end
	else
		macro_builder.new_player(party, position)	
	end
end)

register_event('member leave', function(party_number, position)
	local party = alliance[party_number]
	local count = party.count()
	local party_widget_bin = widget_lookup[party_number]
	
	for i = position, count do
		update_all(party_widget_bin[i], party[i])
	end

	for _, obj in pairs(party_widget_bin[count + 1]) do
		obj:hide()
	end
end)

register_event('hp change', function(party, position, new, old)
	local bin = widget_lookup[party][position]
	
	hp(bin, new)
end)

register_event('mp change', function(party, position, new, old)
	local bin = widget_lookup[party][position]
	
	mp(bin, new)
end)

register_event('tp change', function(party, position, new, old)
	local bin = widget_lookup[party][position]
	
	tp(bin, new)
end)

register_event('mpp change', function(party, position, new, old)
	local bin = widget_lookup[party][position]
	
	mpp_bar(bin, new)
end)

register_event('hpp change', function(party, position, new, old)
	local bin = widget_lookup[party][position]
	
	hpp(bin, new)
	hpp_bar(bin, new)
end)
