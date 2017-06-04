--No copyright... use at your own discretion

_addon.version = '0.9'
_addon.name = 'autogm'
_addon.command = 'autogm'
_addon.author = 'Vetrebond'

addonPath = windower.addon_path

--alert vars
alertStatus = 'On'
alert = 1

--log vars
logStatus = 'On'
log = {}
logC = 1


--Menu functions
windower.register_event('addon command',function (...)
	--converts input to lower case, or gives options if no input detected
	if ... ~= nil then
		userInput = string.lower(...)
	else
		windower.add_to_chat(8, 'Thank you for using autogm!  Type //autogm help for more info.')
	end--end convert if

	--help
	if userInput == 'help' then
		windower.add_to_chat(8, '//autogm [alert/alerttypes/log] for more info on each function (ex. //autogm alert)')
	end --end help if

	--*************
	--ALERT OPTIONS
	--*************

	--alert/alerton/alertoff
	if userInput == 'alert' then
		windower.add_to_chat(8, 'Alerts are currently: '..alertStatus)
		windower.add_to_chat(8, 'alert(on/off/#): enable/disable alerts or set alert # (ex. //autogm alert1)')
	elseif userInput == 'alerton' then
		if alertStatus ~= 'On' then
			windower.add_to_chat(8, 'Alerts turned on.')
			alertStatus = 'On'
		else
			windower.add_to_chat(8, 'Alerts are already on.')
		end --end alerton check if
	elseif userInput == 'alertoff' then
		if alertStatus ~= 'Off' then
			windower.add_to_chat(8, 'Alerts turned off.')
			alertStatus = 'Off'
		else
			windower.add_to_chat(8, 'Alerts are already off.')
		end --end alertoff check
	end --end alert/alerton/alertoff if

	--alert types
	if userInput == 'alerttypes' then
		windower.add_to_chat(8, 'Alert Types: 1-Beep | 2-Boing | 3-Hammer | 4-Klaxon | 5-Toot (//autogm alert#)')
	end--end alerttypes if

	--set alert#
	if userInput == 'alert1' then
		alert = 1
		windower.add_to_chat(8, 'Alert set to 1-Beep.')
	elseif userInput == 'alert2' then
		alert = 2
		windower.add_to_chat(8, 'Alert set to 2-Boing.')
	elseif userInput == 'alert3' then
		alert = 3
		windower.add_to_chat(8, 'Alert set to 3-Hammer.')
	elseif userInput == 'alert4' then
		alert = 4
		windower.add_to_chat(8, 'Alert set to 4-Klaxon.')
	elseif userInput == 'alert5' then
		alert = 5
		windower.add_to_chat(8, 'Alert set to 5-Toot.')
	end --end alert# if

	--***************
	--LOGGING OPTIONS
	--***************

	--log/logon/logoff
	if userInput == 'log' then
		windower.add_to_chat(8, 'Logging is currently: '..logStatus)
		windower.add_to_chat(8, 'log(on/off): enable/disable logging. showlog/clearlog to show or clear the log. (ex. //autogm logon)')
	elseif userInput == 'logon' then
		if logStatus ~= 'On' then
			windower.add_to_chat(8, 'Logging turned on.')
			logStatus = 'On'
		else
			windower.add_to_chat(8, 'Logging is already on.')
		end--end logon check if
	elseif userInput == 'logoff' then
		if alertStatus ~= 'Off' then
			windower.add_to_chat(8, 'Logging turned off.')
			alertStatus = 'Off'
		else
			windower.add_to_chat(8, 'Logging is already off.')
		end --end logoff check
	end --end log/logon/logoff if

	--showlog
	if userInput == 'showlog' then
		if next(log) ~= nil then
			windower.add_to_chat(8, '********** GM LOG **********')
			for i,log in ipairs(log) do 
			windower.add_to_chat(8, log) 
			end
		else
			windower.add_to_chat(8, 'The log is clear.')
		end --end nil check
	end --end showlog if

	--clearlog
	if userInput == 'clearlog' then
		if next(log) ~= nil then
			log = {}
			logC = 1
			windower.add_to_chat(8, 'The log has been cleared.')
		else
			windower.add_to_chat(8, 'The log is already clear.')
		end --end nil check
	end --end clearlog if
end)--end windower 'addon command' event

--If "GM" is detected in chat, play the alert tone and record the message (if applicable)
windower.register_event('chat message',function(message, player, mode, isGM)
		local gameMsg = string.lower(message)

		--handles alerts
		if alertStatus == 'On' then
			if string.match(gameMsg, 'gm') ~= nil then
				windower.play_sound(addonPath..'alerts/'..alert..'.wav')
				windower.add_to_chat(8, '******** ^GM Detected in chat^ ********')
			end --end GM detection
		end --end alert

		--handles logging
		if logStatus == 'On' then
			if string.match(gameMsg, 'gm') ~= nil then
				log[logC] = player..': '..message
				logC = logC + 1
			end --end GM detection
		end --end logging
end)
