require 'tablehelper'
require 'stringhelper'
require 'logger'
config = require 'config'

_addon = _addon or {}
_addon.name = 'Linker'
_addon.verson = 1.0
_addon.command = 'linker'
_addon.short_command = 'web'

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

-- Interpreter

function open_site(site, ...)
	local term = L{...}:concat(' ')
	if((term == '') or (settings.search[site] == nil and settings.raw[site] ~= nil)) then
		open_url(settings.raw[site])
	elseif(settings.search[site] ~= nil) then
		open_url((settings.search[site]:gsub('${query}', term)))
	else
		error('Command', site, 'not found.')
	end
end

-- Constructor

function event_load()
	send_command('alias linker lua i Linker open_site')
	send_command('alias web lua i Linker open_site')
	
	if get_ffxi_info()['logged_in'] then
		initialize()
	end
end

function event_login()
	initialize()
end

function initialize()
	settings = config.load(defaults)
	settings:save()
end

-- Destructor

function event_unload()
	send_command('unalias linker')
	send_command('unalias web')
end