
local texts = require('texts')

local buttons = {}
local buttonlist = {}

function buttons.new(label, settings)
	label = label or ""
	settings = settings or {}
	
	settings.flags = settings.flags or {}
	settings.flags.draggable = false
	
	local button = {}
	
	button.left_click = settings.left_click 
	button.hover_on = settings.hover_on
	button.hover_off = settings.hover_off
	
	button.text = texts.new(label, settings)
	button.destroy = function() buttons.destroy(button) end
	
	setmetatable(button, {__index = function(t, k) 
			if t.text[k] ~= nil then 
				return function(...)
					return t.text[k](t.text, ...) 
				end 
			end 
		end })
	
	buttonlist[#buttonlist +1] = button
	return button
end

function buttons.destroy(me) 
	for k, v in pairs(buttonlist) do
		if v == me then
			buttonlist[k] = nil
		end
	end
	me.text.destroy(me.text)
end

local mousemoved = true
local ignorerelease = false

windower.register_event('mouse', function(eventtype, x, y, delta, blocked)
	if blocked then
        return
    end

    -- Mouse drag
    if eventtype == 0 then
        mousemoved = true
		
		for _, button in pairs(buttonlist) do
			if type(button.hover_on) == "function" and type(button.hover_off) == "function" then
				if button.text:hover(x, y) then
					button:hover_on()
				else
					button:hover_off()
				end
			end
		end

    -- Mouse left click
    elseif eventtype == 1 then
		mousemoved = false
		for _, button in pairs(buttonlist) do
			if button.text:hover(x, y) then 
				ignorerelease = true
				return true
			end
		end
		ignorerelease = false
		
	-- Mouse left release
    elseif eventtype == 2 then
		for _, button in pairs(buttonlist) do
			if button.text:hover(x, y) and button.text:visible() and not mousemoved and type(button.left_click) == "function" then
				button:left_click()
				return true
			end
		end
		
		if ignorerelease then
			return true
		end
    end

    return false
end)

return buttons