local _chars = require('json').read('../libs/ffxidata.json').chat.chars

function event_load()
    send_command('alias chars lua c chars')
end

function event_unload()
    send_command('alias chars lua c chars')
end

function event_addon_command(...)
	for code, char in pairs(_chars) do
		add_to_chat(55, '<'..code..'>: '..char)
	end
end

function event_outgoing_text(original, modified)
    for char in modified:gmatch('<([%a%d]+)>') do
        if type(_chars[char]) ~= 'nil' then
            modified = modified:gsub('<'..char..'>', _chars[char])
        end
    end
    
    return modified
end