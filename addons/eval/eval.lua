
_addon.name = 'Eval'
_addon.author = 'Aureus'
_addon.command = 'eval'
_addon.version = '1.0.0.0'

require('data/bootstrap')

windower.register_event('addon command', function(...)
	assert(loadstring(table.concat({...}, ' ')))()
end)
