require('tablehelper')

function log(...)
	local args = T{...}
	local strtable = T(args:map(tostring))
	add_to_chat(160, strtable:concat(' '))
end

function table.print(t)
	log(unpack(t))
end
