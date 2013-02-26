-- Interpreter

function event_addon_command(command, ...)
    term = table.concat({...}, ' ')
	if(term == '') then
		os.execute('start '..rawURLs[command])
	else
		os.execute('start '..string.gsub(searchURLs[command], 'QUERYTERM', term))
	end
end

-- Constructor

function event_load()
	searchURLs = {}
	-- FFXI info sites
	searchURLs['db'] = 'http://ffxidb.com/search?q=QUERYTERM'
	searchURLs['ah'] = 'http://ffxiah.com/search/item?q=QUERYTERM'
	searchURLs['bgw'] = 'http://wiki.bluegartr.com/index.php?title=Special:Search&search=QUERYTERM'
	searchURLs['ge'] = 'http://ffxi.gamerescape.com/wiki/Special:Search?search=QUERYTERM'
	searchURLs['wikia'] = 'http://wiki.ffxiclopedia.org/wiki/index.php?search=QUERYTERM&fulltext=Search'
	-- Miscallenous sites
	searchURLs['g'] = 'http://google.com/?q=QUERYTERM'
	searchURLs['wa'] = 'http://wolframalpha.com/?i=QUERYTERM'
	
	rawURLs = {}
	-- FFXI info sites
	rawURLs['db'] = 'http://ffxidb.com/'
	rawURLs['ah'] = 'http://ffxiah.com/'
	rawURLs['bgw'] = 'http://wiki.bluegartr.com/bg/Main_Page'
	rawURLs['ge'] = 'http://ffxi.gamerescape.com/wiki/Main_Page'
	rawURLs['wikia'] = 'http://wiki.ffxiclopedia.org/wiki/Main_Page'
	-- FFXI community sites
	rawURLs['of'] = 'http://forum.square-enix.com/ffxi/forum.php'
	rawURLs['bgf'] = 'http://www.bluegartr.com/forum.php'
	rawURLs['ahf'] = 'http://www.ffxiah.com/forum'
	rawURLs['gwc'] = 'http://guildwork.com'
	-- Miscallenous sites
	rawURLs['g'] = 'http://google.com'
	rawURLs['wa'] = 'http://wolframalpha.com'
	
	send_command('alias db lua c Linker db')
	send_command('alias ah lua c Linker ah')
	send_command('alias bgw lua c Linker bgw')
	send_command('alias ge lua c Linker ge')
	send_command('alias wikia lua c Linker wikia')
	send_command('alias g lua c Linker g')
	send_command('alias wa lua c Linker wa')
	send_command('alias of lua c Linker of')
	send_command('alias bgf lua c Linker bgf')
	send_command('alias ahf lua c Linker ahf')
	send_command('alias gwc lua c Linker gwo')
end

-- Destructor

function event_unload()
	searchURLs = nil
	rawURLs = nil
	send_command('unalias db')
	send_command('unalias ah')
	send_command('unalias bgw')
	send_command('unalias ge')
	send_command('unalias wikia')
	send_command('unalias g')
	send_command('unalias wa')
	send_command('unalias of')
	send_command('unalias bgf')
	send_command('unalias ahf')
	send_command('unalias gwc')
end