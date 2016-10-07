--[[

Please edit the ./data/settings.xml to set username and password.

This is a very early version of a IRC based Linkshell chat addon.
It currently works fine with most IRC servers even those that require authentification.
It was aminly developed to talk with people on twitch.tv that watch your stream without
the need to have a second monitor to view the chat.

Suggestions are very welcome.
Skyrant

]]

socket = require "socket"

_addon.version = '0.1'
_addon.name = 'irc'
_addon.author = 'Skyrant, maintainer: Skyrant'
_addon.commands = {'i','irc'}

require('chat')
require('logger')
require('strings')
require('maths')
require('tables')

config = require('config')
settings = config.load(defaults)

ircconnect = function()

	connecttime = os.time()

	serveraddr = settings.server.serveraddr
	serverport = settings.server.serverport

	if serveraddr and serverport then
		-- eventually do something here
	else
		log("setting default twitch server and port")
		serveraddr = 'irc.twitch.tv'
		serverport = '6667'
	end
	serverport = tonumber(serverport)
	server = socket.tcp()
	status = server:connect(serveraddr, serverport)
	-- twitch irc servers
	-- irc.twitch.tv:6667 -- use this for your twitch channel
	-- server:send(perform)
	server:send("TWITCHCLIENT 2\r\n")
	server:send("PASS "..settings.login.password.."\r\n")
	server:send("NICK "..settings.login.nick.."\r\n")
	server:send("JOIN "..settings.login.channel.."\r\n")
	server:settimeout(0.001)
end

tensecwait = function()
	waittime = os.time()
	while os.difftime(os.time(),waittime) < 10 do
		-- waiting...
	end
end

checkstatus = function()
	if not status then
		log("Not connected to an IRC server.")
	else
		log('You are curently connected to')
		log('Server : '..settings.server.serveraddr..":"..settings.server.serverport)
		log('Channel: '..settings.login.channel)
		--server:send("NAMES\r\n")
	end
end

if settings.login.autoconnect == "yes" then
	ircconnect()
	if not status then log("Reconnecting...") end
	while not status do
		if os.difftime(os.time(),connecttime) < 10 then
			log("Waiting 10 seconds...")
			tensecwait()
		end
		ircconnect()
		if not status then
			log("Connection error. Trying again in 10 seconds...")
			tensecwait()
		end
	end
end

windower.register_event('time change', function(new, old)
    if not status then
    	--do nothing
    	--log("WARNING: Not connected to a server.")
    	return
    else
		local data, error = server:receive("*l")
		if data then
			pingdata = string.match(data, '^PING (.+)')
			if pingdata then
				server:send("PONG "..pingdata.."\r\n")
			end
			nick,msg = string.match(data, '^:([^ ]+) NOTICE .+ :(.+)')
			if nick and msg then
				log("NOTICE from "..nick..":",msg)
			end
			nick,msg = string.match(data, '^:[^ ]+ (00.) .+ :(.+)')
			if nick and msg then
				log("<> "..nick.." <>:",msg)
			end
			nick,msg = string.match(data, '^:[^ ]+ 001 (.+) :(.+)')
			if nick and msg then
				mynick = nick
			end
			nick,msg = string.match(data, '^:([^!]+).+ JOIN (.+)')
			if nick and msg and nick == mynick then
				log("<> You have joined "..msg.." <>")
			end
			channel,names = string.match(data, '^:[^ ]+ 353 (.+) :(.+)')
			if channel and names then
				log("<> Online Users :"..names)
				--log(topic)
			end
			nick,msg = string.match(data, '^:([^!]+).+ PRIVMSG #.+ :(.+)')
			if nick and msg then
				windower.add_to_chat(settings.chat.color,"<"..nick.."> "..msg)
			end
		end
	end
end)

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	if args[1] == nil or args[1] == "help" then
		log('IRC addon by Skyrant')
		log('-- //i or //irc to send a message to the irc channel')
		log('General commands:')
		log('-- //irc checkstatus :: check connection status.')
		log('-- //irc connect :: connect to the IRC server.')
		log('-- //irc disconnect :: disconnect from the irc server.')
		log('Settings:')
		log('-- //irc chatcolor [colornumber: 001-256] :: change the chatcolor.')
		log('-- //irc server [servername] :: set the server to connect to.')
		log('-- //irc port [portnumber] :: set the irc server port.')
		log('-- //irc channel [channelname] :: switch to a channel (will part current channel).')
		log("Don't forget to save your settings:")
		log('-- //irc save')

	elseif args[1] == "chatcolor" and args[2] ~= nil then
		settings.chat.color = tonumber(args[2])
		log("chatcolor set to:"..settings.chat.color)

	elseif args[1] == "checkstatus" and args[2] == nil then
		checkstatus()

	elseif args[1] == "connect" and args[2] == nil then
		ircconnect()

	elseif args[1] == "disconnect" and args[2] == nil then
		server:send("PARTALL\r\n")
		server:send("QUIT\r\n")
		log('Disconnected from '..settings.server.servername)
		status = false

	elseif args[1] == "server" and args[2] ~= nil then
		settings.server.servername = args[2]
		log("Server changed to "..settings.server.servername)

	elseif args[1] == "port" and args[2] ~= nil then
		settings.server.serverport = args[3]
		log("Port changed to "..settings.server.serverport)

	elseif args[1] == "channel" and args[2] ~= nil then
		settings.login.channel = args[2]
		server:send("PARTALL\r\n")
		server:send("JOIN "..settings.login.channel.."\r\n")
		log("Channel changed to "..settings.login.channel)

	elseif args[1] == 'save' and args[2] == nil then
		config.save(settings, 'all')
		log('Settings saved.')

	else
		message = table.concat( args, " ", 1 )
		server:send("PRIVMSG "..settings.login.channel.." :"..message.."\r\n")
		windower.add_to_chat(settings.chat.color,"<"..settings.login.nick.."> "..message)

	end
end)

windower.register_event('unload',function ()
 	server:send("PARTALL\r\n")
 	server:send("QUIT\r\n")
end)
