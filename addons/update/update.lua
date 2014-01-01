_addon.name = 'Update'
_addon.author = 'Arcon'
_addon.version = '0.0.0.0'
_addon.command = 'update'

require('functions')

windower.register_event('addon command', os.execute:apply(windower.addon_path .. '../../Windower.exe -u'))
