require 'debug'

windower.register_event('load',function ()
	log("Loaded EventTester.")
end)

windower.register_event('unload',function ()
	log("Unloaded EventTester.")
end)

windower.register_event('gain status',function (id, name)
	log("Gain status, Id: "..id..", Name: "..name)
end)

windower.register_event('lose status',function (id, name)
	log("Lose status, Id: "..id..", Name: "..name)
end)

windower.register_event('logout',function (name)
	windower.send_command("echo Logout, Name: "..name)
end)

windower.register_event('login',function (name)
	windower.send_command("echo Login, Name: "..name)
end)

windower.register_event('levelup',function (level)
	log("Level up, Level: "..level)
end)

windower.register_event('leveldown',function (level)
	log("Level down, Level: "..level)
end)

windower.register_event('gain experience',function (isLimit, experience, chainNr)
	log("Gain EXP, IsLimit: "..tostring(isLimit)..", Experience: "..experience..", Chain #: "..chainNr)
end)

windower.register_event('lose experience',function (experience)
	log("Lose EXP, experience: "..experience)
end)

windower.register_event('job change',function (mjobId, mjob, mjobLvl, sjobId, sjob, sjobLvl)
	log("Job change, MainJobID: "..mjobId..", MainJob: "..mjob..", MainJobLvl: "..mjobLvl..", SubJobID: "..sjobId..", SubJob: "..sjob..", SubJobLvl: "..sjobLvl)
end)

windower.register_event('target change',function (targId)
	log("Target change, TargID: "..targId)
end)

windower.register_event('weather change',function (id, name)
	log("Weather change, ID: "..id..", Name: "..name)
end)

windower.register_event('status change',function (old, new)
	log("Status change, Old: "..old..", New: "..new)
end)

windower.register_event('hp change',function (old, new)
	log("HP change, Old: "..old..", New: "..new)
end)

windower.register_event('mp change',function (old, new)
	log("MP change, Old: "..old..", New: "..new)
end)

windower.register_event('tp change',function (old, new)
	log("TP change, Old: "..old..", New: "..new)
end)

windower.register_event('hpp change',function (old, new)
	log("HP% change, Old: "..old..", New: "..new)
end)

windower.register_event('mpp change',function (old, new)
	log("MP% change, Old: "..old..", New: "..new)
end)

windower.register_event('hpmax change',function (old, new)
	log("MaxHP change, Old: "..old..", New: "..new)
end)

windower.register_event('mpmax change',function (old, new)
	log("MaxMP change, Old: "..old..", New: "..new)
end)

windower.register_event('chat message',function (isGM, mode, player, message)
	log("Chat message, GM: "..tostring(isGM)..", Mode: "..mode..", Player: "..player..", Message: "..message)
end)

windower.register_event('emote',function (senderId, targetId, emoteId, motionOnly)
	log("Emote, SenderID: "..senderId..", TargetID: "..targetId..", EmoteID: "..emoteId.." MotionOnly: "..tostring(motionOnly))
end)

windower.register_event('party invite',function (senderId, sender, region)
	log("Party invite, SenderID: "..senderId..", Sender: "..sender..", Region: "..region)
end)

windower.register_event('examined',function (examiner)
	log("Examined, Examiner: "..examiner)
end)

windower.register_event('time change',function (old, new)
	log("Time change, Old: "..old..", New: "..new)
end)

windower.register_event('day change',function (day)
	log("Day change, Day: "..day)
end)

windower.register_event('moon change',function (moon)
	log("Moon change, Moon: "..moon)
end)

windower.register_event('moon pct change',function (pct)
	log("Moon% change, Percentage: "..pct)
end)

windower.register_event('linkshell change',function (linkshell)
	log("Linkshell change, Linkshell: "..linkshell)
end)

windower.register_event('zone change',function (fromId, from, toId, to)
	log("Zone change, FromID: "..fromId..", From: "..from..", ToID: "..toId..", To: "..to)
end)
