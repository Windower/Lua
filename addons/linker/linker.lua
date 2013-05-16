require 'tablehelper'
require 'debug'

-- Interpreter

function event_addon_command(site, ...)
	local args = T{...}
	term = args:concat(' ')
	if((term == '') or (searchURLs[site] == nil and rawURLs[site] ~= nil)) then
		link = rawURLs[site]
	elseif(searchURLs[site] ~= nil) then
		link = searchURLs[site]:gsub('QUERYTERM', term)
	else
		log('Linker error:', 'Command', site, 'not found.')
	end
	if link ~= nil then
		open_url(link)
	end
end

-- Constructor

function event_load()
	searchURLs = {}
	-- FFXI info sites
	searchURLs['db'] = 'http://ffxidb.com/search?q=QUERYTERM'
	searchURLs['ah'] = 'http://ffxiah.com/search/item?q=QUERYTERM'
	searchURLs['bg'] = 'http://wiki.bluegartr.com/index.php?title=Special:Search&search=QUERYTERM'
	searchURLs['ge'] = 'http://ffxi.gamerescape.com/wiki/Special:Search?search=QUERYTERM'
	searchURLs['wikia'] = 'http://wiki.ffxiclopedia.org/wiki/index.php?search=QUERYTERM&fulltext=Search'
	-- Miscallenous sites
	searchURLs['g'] = 'http://google.com/?q=QUERYTERM'
	searchURLs['wa'] = 'http://wolframalpha.com/?i=QUERYTERM'
	
	rawURLs = {}
	-- FFXI info sites
	rawURLs['db'] = 'http://ffxidb.com/'
	rawURLs['ah'] = 'http://ffxiah.com/'
	rawURLs['bg'] = 'http://wiki.bluegartr.com/bg/Main_Page'
	rawURLs['ge'] = 'http://ffxi.gamerescape.com/wiki/Main_Page'
	rawURLs['wikia'] = 'http://wiki.ffxiclopedia.org/wiki/Main_Page'
	-- FFXI community sites
	rawURLs['of'] = 'http://forum.square-enix.com/ffxi/forum.php'
	rawURLs['bgf'] = 'http://www.bluegartr.com/forum.php'
	rawURLs['ahf'] = 'http://www.ffxiah.com/forum'
	rawURLs['gw'] = 'http://guildwork.com'
	-- Miscallenous sites
	rawURLs['g'] = 'http://google.com'
	rawURLs['wa'] = 'http://wolframalpha.com'
	
	send_command('alias web lua c Linker')
end

-- Destructor

function event_unload()
	send_command('unalias web')
end.
