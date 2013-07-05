require 'debug'

function event_load()
	log("Loaded EventTester.")
end

function event_unload()
	log("Unloaded EventTester.")
end

function event_gain_status(id, name)
	log("Gain status, Id: "..id..", Name: "..name)
end

function event_lose_status(id, name)
	log("Lose status, Id: "..id..", Name: "..name)
end

function event_logout(name)
	send_command("echo Logout, Name: "..name)
end

function event_login(name)
	send_command("echo Login, Name: "..name)
end

function event_levelup(level)
	log("Level up, Level: "..level)
end

function event_leveldown(level)
	log("Level down, Level: "..level)
end

function event_gain_experience(isLimit, experience, chainNr)
	log("Gain EXP, IsLimit: "..tostring(isLimit)..", Experience: "..experience..", Chain #: "..chainNr)
end

function event_lose_experience(experience)
	log("Lose EXP, experience: "..experience)
end

function event_job_change(mjobId, mjob, mjobLvl, sjobId, sjob, sjobLvl)
	log("Job change, MainJobID: "..mjobId..", MainJob: "..mjob..", MainJobLvl: "..mjobLvl..", SubJobID: "..sjobId..", SubJob: "..sjob..", SubJobLvl: "..sjobLvl)
end

function event_target_change(targId)
	log("Target change, TargID: "..targId)
end

function event_weather_change(id, name)
	log("Weather change, ID: "..id..", Name: "..name)
end

function event_status_change(old, new)
	log("Status change, Old: "..old..", New: "..new)
end

function event_hp_change(old, new)
	log("HP change, Old: "..old..", New: "..new)
end

function event_mp_change(old, new)
	log("MP change, Old: "..old..", New: "..new)
end

function event_tp_change(old, new)
	log("TP change, Old: "..old..", New: "..new)
end

function event_hpp_change(old, new)
	log("HP% change, Old: "..old..", New: "..new)
end

function event_mpp_change(old, new)
	log("MP% change, Old: "..old..", New: "..new)
end

function event_hpmax_change(old, new)
	log("MaxHP change, Old: "..old..", New: "..new)
end

function event_mpmax_change(old, new)
	log("MaxMP change, Old: "..old..", New: "..new)
end

function event_chat_message(isGM, mode, player, message)
	log("Chat message, GM: "..tostring(isGM)..", Mode: "..mode..", Player: "..player..", Message: "..message)
end

function event_emote(senderId, targetId, emoteId, motionOnly)
	log("Emote, SenderID: "..senderId..", TargetID: "..targetId..", EmoteID: "..emoteId.." MotionOnly: "..tostring(motionOnly))
end

function event_party_invite(senderId, sender, region)
	log("Party invite, SenderID: "..senderId..", Sender: "..sender..", Region: "..region)
end

function event_examined(examiner)
	log("Examined, Examiner: "..examiner)
end

function event_time_change(old, new)
	log("Time change, Old: "..old..", New: "..new)
end

function event_day_change(day)
	log("Day change, Day: "..day)
end

function event_moon_change(moon)
	log("Moon change, Moon: "..moon)
end

function event_moon_pct_change(pct)
	log("Moon% change, Percentage: "..pct)
end

function event_linkshell_change(linkshell)
	log("Linkshell change, Linkshell: "..linkshell)
end

function event_zone_change(fromId, from, toId, to)
	log("Zone change, FromID: "..fromId..", From: "..from..", ToID: "..toId..", To: "..to)
end
