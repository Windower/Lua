
-- Meta class
bars = {x_res = windower.get_windower_settings().x_res,y_res = windower.get_windower_settings().y_res}

-- Base class method new

function bars.new(o, bar_settings)
   o = o or {}
   o.width = bar_settings.width 
   o.color = bar_settings.color 
   o.font = bar_settings.font
   o.font_size = bar_settings.font_size
   o.show_dist = bar_settings.show_dist
   o.show_target = bar_settings.show_target
   o.show_target_icon = bar_settings.show_target_icon
   o.show_action = bar_settings.show_action
   o.show_debuff = bar_settings.show_debuff
   bars.initialize(o)
   bars.move(o, bar_settings.pos.x, bar_settings.pos.y)
   return o
end

function bars.destroy(o)
	if not o then return end
	o.tbut:destroy()
	o.lcap:destroy()
	o.bg_body:destroy()
	o.fg_body:destroy()
	o.rcap:destroy()
	o.ntext:destroy()
	o.atext:destroy()
	o.atar:destroy()
	o.ttext:destroy()
	o.dtext:destroy()
	o.tstat:destroy()
end

-- Base class method printArea

function bars.initialize(o)
	o.tbut = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=255,green=50,blue=50},
			size = {width=12,height=12},
			texture = {path=windower.addon_path.. 'target.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false
		})
	o.lcap = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red/2,green=o.color.green/2,blue=o.color.blue/2},
			size = {width=1,height=12},
			texture = {path=windower.addon_path.. 'bg_cap.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false
		})
	o.bg_body = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red/2,green=o.color.green/2,blue=o.color.blue/2},
			size = {width=o.width,height=12},
			texture = {path=windower.addon_path.. 'bg_body.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false		
		})
	o.fg_body = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
			size = {width=o.width,height=12},
			texture = {path=windower.addon_path.. 'fg_body.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false		
		})
	o.rcap = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red/2,green=o.color.green/2,blue=o.color.blue/2},
			size = {width=1,height=12},
			texture = {path=windower.addon_path.. 'bg_cap.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false		
		})
	o.ntext = texts.new('${name|(Name)}: ${hpp|(100)}%', {
			pos = {x=0,y=0},
			text = { size=o.font_size,font=o.font,stroke={width=2,alpha=180,red=50,green=50,blue=50}},
			flags = {bold=true,draggable=false,italic=true},
			bg = {visible=false}
		})
	o.atext = texts.new('${action|(Action)}', {
			pos = {x=0,y=0},
			text = { size=o.font_size*0.8,font=o.font,stroke={width=2,alpha=180,red=50,green=50,blue=50}},
			flags = {bold=true,draggable=false,right=true},
			bg = {visible=false}
		})
	o.atar = images.new({
			pos = {x=0,y=0},
			visible = true,
			color = {alpha=o.color.alpha,red=o.color.red,green=o.color.green,blue=o.color.blue},
			size = {width=12,height=12},
			texture = {path=windower.addon_path.. 'attention.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false		
		})
	o.ttext = texts.new('${pc|(Target)}', {
			pos = {x=0,y=0},
			text = { size=o.font_size,font=o.font,stroke={width=2,alpha=180,red=50,green=50,blue=50}},
			flags = {bold=true,draggable=false},
			bg = {visible=false}
		})
	o.dtext = texts.new('${dist|(0.0)}\'', {
			pos = {x=0,y=0},
			text = { size=o.font_size*0.8,font=o.font,stroke={width=2,alpha=180,red=50,green=50,blue=50}},
			flags = {bold=true,draggable=false,right=true},
			bg = {visible=false}
		})
	o.tstat = images.new({
			pos = {x=0,y=0},
			visible = true,
			size = {width=18,height=12},
			texture = {path=windower.addon_path.. 'icons/sleep.png',fit=true},
			repeatable = {x=1,y=1},
			draggable = false		
		})
    --windower.add_to_chat(1,'initialized: w:'..o.width)
end

function bars.move(o,x,y)
	if not o then return end
	o.x = x
	o.y = y
	o.tbut:pos(x-16,y)
	o.lcap:pos(x,y)
	o.bg_body:pos(x+1,y)
	o.fg_body:pos(x+1,y)
	o.rcap:pos(x+1+o.width,y)
	--o.ntext:pos(x+math.floor(o.width/100), y+2+(14-o.font_size)/2)
	o.ntext:pos(x+math.floor(o.width/100), y+3+(14-o.font_size)/4)
	o.atext:pos(-(bars.x_res-(x+o.width-math.floor(o.width/100))),y-o.font_size+2)
	o.atar:pos(x+o.width+8, y)
	o.ttext:pos(x+o.width+24,y-math.floor(o.font_size/2)+2)
	o.dtext:pos(-(bars.x_res-(x-20)),y-math.floor(o.font_size/2)+4)
	o.tstat:pos(x+o.width + 4, y)
    --windower.add_to_chat(1,'moved: x:'..self.x..', y:'..self.y)
end

function bars.show(o)
	if not o then return end
	if o.show_dist then	o.dtext:show() end
	o.lcap:show()
	o.bg_body:show()
	o.fg_body:show()
	o.rcap:show()
	o.ntext:show()
end

function bars.hide(o)
	if not o then return end
	o.dtext:hide()
	o.tbut:hide()
	o.lcap:hide()
	o.bg_body:hide()
	o.fg_body:hide()
	o.rcap:hide()
	o.ntext:hide()
	o.atext:hide()
	o.atar:hide()
	o.ttext:hide()
	o.tstat:hide()
end

function bars.set_value(o, v)
	if not o then return end
	o.fg_body:width(v*o.width)
	o.bg_body:width(o.width)
end

function bars.set_name_color(o, color)
	if not o then return end
	o.ntext:color(color.red, color.green, color.blue)
	o.atext:color(color.red, color.green, color.blue)
end

function bars.update_target(o, name, hpp, dist, target_type)
	if not o then return end
	o.ntext.name = name
	o.ntext.hpp = hpp
	bars.set_value(o, hpp/100)

	o.dtext.dist = string.format('%.1f', dist)

	if target_type == 1 and o.show_target_icon then
		o.tbut:color(255,100,100,255)
		o.tbut:show()
	elseif target_type == 2 and o.show_target_icon then
		o.tbut:color(100,100,255,255)
		o.tbut:show()
	else
		o.tbut:hide()
	end
end

function bars.update_action(o, a, debug)
	if not o then return end
	if a and o.show_action then
    	--windower.add_to_chat(1,'a: '..a)
		o.atext.action = a
		o.atext:show()
	else
		-- hide action text
		o.atext:hide()
	end
end

function bars.update_enmity(o, name, color)
	if not o then return end
	if name and o.show_target then
		if color then
			o.atar:color(color.red, color.green, color.blue)
			o.ttext:color(color.red, color.green, color.blue)
		end
		o.ttext.pc = name
		o.ttext:show()
		o.atar:show()
	else
		o.ttext:hide()
		o.atar:hide()
	end
end

function bars.update_status(o, status)
	if not o then return end
	if status and o.show_debuff then
		for id,effect in pairs(status) do
			if S{2,19}:contains(id) then
				--sleep
				o.tstat:path(windower.addon_path.. 'icons/sleep.png')
				o.tstat:show()
				o.atar:hide()
				o.ttext:hide()
				return
			elseif id == 7 then
				-- petrification
				o.tstat:path(windower.addon_path.. 'icons/petrified.png')
				o.tstat:show()
				o.atar:hide()
				o.ttext:hide()
				return
			elseif id == 11 then
				--bind
				o.tstat:path(windower.addon_path.. 'icons/bound.png')
				o.tstat:show()
				o.atar:hide()
				o.ttext:hide()
				return
			elseif id == 28 then
				-- terror
				o.tstat:path(windower.addon_path.. 'icons/terror.png')
				o.tstat:show()
				o.atar:hide()
				o.ttext:hide()
				return
			end
		end
	end
	o.tstat:hide()
end