--[[
A library to facilitate text primitive creation and manipulation.
]]

_libs = _libs or {}
_libs.texts = true

local texts = {}

math.randomseed(os.clock())

-- Returns a new text object.
-- settings: If provided, it will overwrite the defaults with those. The structure needs to be similar
-- str:      Formatting string, if provided, will set it as default text. Supports named variables:
--           ${name|default}
--           If those are found, they will initially be set to default. They can later be adjusted by simply setting the values. Example usage:
--
--           t = texts.new('The target\'s name is ${name|(None)}, its ID is ${id|0}.')
--           -- At this point the text reads:
--           -- The target's name is (None), its ID is 0.
--           -- Now, assume the player is currently targeting its Moogle in the Port Jeuno MH (ID 17784938).
--
--           mob = get_mob_by_index(get_player()['target_index'])
--
--           t.name = mob['name']
--           -- This will instantly change the text to include the mob's name:
--           -- The target's name is Moogle, its ID is 0.
--
--           t.id = mob['id']
--           -- This instantly changes the ID part of the text, so it all reads:
--           -- The target's name is Moogle, its ID is 17784938.
--
--           t.name = nil
--           -- This unsets the name and returns it to its default:
--           -- The target's name is (None), its ID is 17784938.
--
--           -- To avoid mismatched attributes, like the name and ID in this case, you can also pass it a table:
--           t:update(mob)
--           -- Since the mob object contains both a "name" and "id" attribute, and both are used in the text object, it will update those with the respective values. The extra values are ignored.
function texts.new(settings, str)
	if type(settings) == 'string' then
		settings, str = str, settings
	end

	t = {}
	t._name = 'text_gensym_'..tostring(math.random()):sub(3)
	t._data = {}
	t._data.pos = {}
	t._data.pos.x = 0
	t._data.pos.y = 0
	t._data.bg = {}
	t._data.bg.alpha = 255
	t._data.bg.red = 0
	t._data.bg.green = 0
	t._data.bg.blue = 0
	t._data.visible = false
	t._data.text = {}
	t._data.text.size = 12
	t._data.text.font = 'Arial'
	t._data.text.alpha = 255
	t._data.text.red = 255
	t._data.text.green = 255
	t._data.text.blue = 255
	t._data.text.content = ''
	t._texts = {}
	t._defaults = {}
	t._textorder = {}
	
	local function update(t1, t2)
		if t2 == nil then
			return
		end
		
		for key, val in pairs(t1) do
			if t2[key] ~= nil then
				if type(val) == 'table' then
					update(val, t2[key])
				else
					t1[key] = t2[key]
				end
			end
		end
	end
	
	update(t._data, settings)
	
	tb_create(t._name)
	tb_set_location(t._name, t._data.pos.x, t._data.pos.y)
	tb_set_bg_color(t._name, t._data.bg.alpha, t._data.bg.red, t._data.bg.green, t._data.bg.blue)
	tb_set_bg_visibility(t._name, true)
	tb_set_color(t._name, t._data.text.alpha, t._data.text.red, t._data.text.green, t._data.text.blue)
	tb_set_font(t._name, t._data.text.font, t._data.text.size)
	tb_set_visibility(t._name, t._data.visible)
	
	if str then
		local i = 1
		local startpos, endpos
		local match
		local rndname
		local key = 1
		local innerstart, innerend
		local defaultmatch
		while i <= #str do
			startpos, endpos = str:find('%${.-}', i)
			if startpos then
				-- Match before the tag.
				match = str:sub(i, startpos - 1)
				rndname = t._name..'_'..key
				t._textorder[key] = rndname
				t._texts[rndname] = match
				key = key + 1
				
				-- Match the tag.
				match = str:sub(startpos + 2, endpos - 1)
				innerstart, innerend = match:find('^.-|')
				if innerstart then
					defaultmatch = match:sub(innerend + 1)
					match = match:sub(1, innerend - 1)
				else
					defaultmatch = ''
				end
				t._textorder[key] = match
				t._texts[match] = defaultmatch
				t._defaults[match] = defaultmatch
				key = key + 1
				
				i = endpos + 1
			else
				match = str:sub(i)
				rndname = t._name..'_'..key
				t._textorder[key] = rndname
				t._texts[rndname] = match
				break
			end
		end

		texts.update(t)
	else
		tb_set_text(t._name, '')
	end
	
	return setmetatable(t, {
		__index = texts,
		__newindex = function(t, k, v)
			local l = #t._textorder
			for key, val in ipairs(t._textorder) do
				if val == k then
					break
				end
				
				if key == l then
					t._textorder[l + 1] = k
					t._defaults[k] = ''
				end
			end
			t._texts[k] = v ~= nil and tostring(v) or nil
			t:update()
		end
	})
end

-- Sets string values based on the provided attributes.
function texts.update(t, attr)
	attr = attr or {}
	local str = ''
	for _, key in ipairs(t._textorder) do
		if attr[key] ~= nil then
			t._texts[key] = tostring(attr[key])
		end
		if t._texts[key] ~= nil then
			str = str..t._texts[key]
		else
			str = str..t._defaults[key]
		end
	end
	
	tb_set_text(t._name, str)
	t._data.text.content = str
end

-- Makes the primitive visible.
function texts.show(t)
	tb_set_visibility(t._name, true)
	t._data.visible = true
end

-- Makes the primitive invisible.
function texts.hide(t)
	tb_set_visibility(t._name, false)
	t._data.visible = false
end

-- Returns whether or not the text object is visible.
function texts.visible(t)
	return t._data.visible
end

-- Sets the text. This will ignore the defined text patterns.
function texts.text(t, str)
	if not str then
		return t._data.text.content
	end
	str = tostring(str)
	tb_set_text(t._name, str)
	t._data.text.content = str
end

--[[
	The following methods all either set the respective values or return them, if no arguments to set them are provided.
]]

function texts.pos(t, x, y)
	if not x then
		return t._data.pos.x, t._data.pos.y
	end
	tb_set_location(t._name, x, y)
	t._data.pos.x = x
	t._data.pos.y = y
end

function texts.x_pos(t, x)
	if not x then
		return t._data.pos.x
	end
	t:pos(x, t._data.pos.y)
end

function texts.y_pos(t, y)
	if not y then
		return t._data.pos.y
	end
	t:pos(t._data.pos.x, y)
end

function texts.font(t, font)
	if not font then
		return t._data.text.font
	end
	tb_set_font(t._name, font, t._data.text.size)
	t._data.text.font = font
end

function texts.size(t, size)
	if not size then
		return t._data.text.size
	end
	tb_set_font(t._name, t._data.text.font, size)
	t._data.text.size = size
end

function texts.color(red, green, blue)
	if not red then
		return t._data.text.red, t._data.text.green, t._data.text.blue
	end
	tb_set_color(t._name, t._data.text.alpha, red, green, blue)
	t._data.text.red = red
	t._data.text.green = green
	t._data.text.blue = blue
end

function texts.alpha(t, alpha)
	if not alpha then
		return t._data.text.alpha
	end
	tb_set_color(t._name, alpha, t._data.text.red, t._data.text.green, t._data.text.blue)
	t._data.text.alpha = alpha
end

-- Sets/returns text transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function texts.transparency(t, alpha)
	if not alpha then
		return 1 - t._data.text.alpha/255
	end
	alpha = math.floor(255*(1-alpha))
	tb_set_color(t._name, alpha, t._data.text.red, t._data.text.green, t._data.text.blue)
	t._data.text.alpha = alpha
end

function texts.bg_color(red, green, blue)
	if not red then
		return t._data.bg.red, t._data.bg.green, t._data.bg.blue
	end
	tb_set_bg_color(t._name, t._data.bg.alpha, red, green, blue)
	t._data.bg.red = red
	t._data.bg.green = green
	t._data.bg.blue = blue
end

function texts.bg_alpha(t, alpha)
	if not alpha then
		return t._data.bg.alpha
	end
	tb_set_bg_color(t._name, alpha, t._data.bg.red, t._data.bg.green, t._data.bg.blue)
	t._data.bg.alpha = alpha
end

-- Sets/returns background transparency. Based on percentage values, with 1 being fully transparent, while 0 is fully opaque.
function texts.bg_transparency(t, alpha)
	if not alpha then
		return 1 - t._data.bg.alpha/255
	end
	alpha = math.floor(255*(1-alpha))
	tb_set_bg_color(t._name, alpha, t._data.bg.red, t._data.bg.green, t._data.bg.blue)
	t._data.bg.alpha = alpha
end

function texts.destroy(t)
	tb_delete(t._name)
	t = nil
	collectgarbage()
end

return texts
