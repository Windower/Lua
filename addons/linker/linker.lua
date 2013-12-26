require 'tables'
require 'stringhelper'
require 'logger'
config = require 'config'

_addon = _addon or {}
_addon.name = 'Linker'
_addon.author = 'Arcon'
_addon.version = '1.0.0.0'
_addon.command = 'linker'
_addon.short_command = 'web'
_addon.language = 'English'

defaults = {}
defaults.raw = {}

-- FFXI info sites
defaults.raw.db = 'http://ffxidb.com/'
defaults.raw.ah = 'http://ffxiah.com/'
defaults.raw.bg = 'http://wiki.bluegartr.com/bg/Main_Page'
defaults.raw.ge = 'http://ffxi.gamerescape.com/wiki/Main_Page'
defaults.raw.wikia = 'http://wiki.ffxiclopedia.org/wiki/Main_Page'

-- FFXI community sites
defaults.raw.of = 'http://forum.square-enix.com/ffxi/forum.php'
defaults.raw.bgf = 'http://www.bluegartr.com/forum.php'
defaults.raw.ahf = 'http://www.ffxiah.com/forum'
defaults.raw.gw = 'http://guildwork.com'

-- Windower
defaults.raw.win = 'http://windower.net'
--[[ Add once the new forums/wiki go live
defaults.raw.winf = 'http://'
defaults.raw.winw = 'http://'
]]

-- Miscallenous sites
defaults.raw.g = 'http://google.com'
defaults.raw.wa = 'http://wolframalpha.com'

defaults.search = {}

-- FFXI info sites
defaults.search.db = 'http://ffxidb.com/search?q=${query}'
defaults.search.ah = 'http://ffxiah.com/search/item?q=${query}'
defaults.search.bg = 'http://wiki.bluegartr.com/index.php?title=Special:Search&search=${query}'
defaults.search.ge = 'http://ffxi.gamerescape.com/wiki/Special:Search?search=${query}'
defaults.search.wikia = 'http://wiki.ffxiclopedia.org/wiki/index.php?search=${query}&fulltext=Search'

-- Miscallenous sites
defaults.search.g = 'http://google.com/?q=${query}'
defaults.search.wa = 'http://wolframalpha.com/?i=${query}'

settings = config.load(defaults)
settings:save()

-- Interpreter

windower.register_event('addon command', function(site, ...)
	local term = L{...}:concat(' ')
	if((term == '') or (settings.search[site] == nil and settings.raw[site] ~= nil)) then
		windower.open_url(settings.raw[site])
	elseif(settings.search[site] ~= nil) then
		windower.open_url((settings.search[site]:gsub('${query}', term)))
	else
		error('Command', site, 'not found.')
	end
end)
