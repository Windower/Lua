_addon.name = 'enemybar'
_addon.author = 'mmckee'
_addon.version = '0.2'
_addon.language = 'English'


require('gui_settings')

windower.register_event('load', function()
	if windower.ffxi.get_info().logged_in then
		init_images()
	end
end)

mob = nil
windower.register_event('prerender', function()
	if settings.global.visible == true then
		local mob = windower.ffxi.get_mob_by_target('t')
		local player = windower.ffxi.get_player()
		if mob ~= nil then
			local old_width = fg_image:width()
			local i = mob.hpp / 100
			local new_width = math.floor(settings.global.Width * i)
			
			if settings.global.style == 1 then
				--Animated Style 'borrowed' from Morath's barfiller
				if new_width ~= nil and new_width > 0 then
					if old_width > new_width then
						local last_update = 0
						local x = old_width + math.ceil(((new_width - old_width) * 0.1))
						fg_image:size(x, 10)
			
						local now = os.clock()
						if now - last_update > 0.5 then
							last_update = now
						end
					elseif old_width <= new_width then
						fg_image:size(new_width, 10)
					end
				end
			else
				--Classic Style
				fg_image:size(new_width, 10)
			end
			
			--Update the Text
			txtMain:text('  ' .. mob.name .. ' - HP ' .. mob.hpp .. '%')
			if player.in_combat == true then
				txtMain:color(255, 80, 80)
			else
				if mob.is_npc == false then
					txtMain:color(255, 255, 255)
				else
					if mob.claim_id == 0 then
						txtMain:color(230, 230, 138)
					else 
						if mob.hpp == 0 then
							txtMain:color(155, 155, 155)
						else
							txtMain:color(153, 102, 255)
						end
					end
				end
			end
		end
	end
end)

windower.register_event('target change', function(index)
	if index == 0 then
		bg_image:hide()
		fg_image:hide()
		txtMain:hide()
		settings.global.visible = false
	else
		bg_image:show()
		fg_image:show()
		txtMain:show()
		settings.global.visible = true
	end
end)