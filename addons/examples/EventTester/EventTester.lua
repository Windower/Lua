add_to_chat(160, "Starting up EventTester.")

function event_load()
	add_to_chat(160, "Loaded EventTester.")
end

function event_unload()
	add_to_chat(160, "Unloaded EventTester.")
end

function event_gain_status(id, name)
	add_to_chat(160, "Gain status, Id: "..id..", Name: "..name)
end

function event_lose_status(id, name)
	add_to_chat(160, "Lose status, Id: "..id..", Name: "..name)
end

function event_logout(name)
	send_command("echo Logout, Name: "..name)
end

function event_login(name)
	send_command("echo Login, Name: "..name)
end

function event_levelup(level)
	add_to_chat(160, "Level up, Level: "..level)
end

function event_leveldown(level)
	add_to_chat(160, "Level down, Level: "..level)
end

function event_gain_experience(isLimit, experience, chainNr)
	add_to_chat(160, "Gain EXP, IsLimit: "..tostring(isLimit)..", Experience: "..experience..", Chain #: "..chainNr)
end

function event_lose_experience(experience)
	add_to_chat(160, "Lose EXP, experience: "..experience)
end

function event_job_change(mjobId, mjob, mjobLvl, sjobId, sjob, sjobLvl)
	add_to_chat(160, "Job change, MainJobID: "..mjobId..", MainJob: "..mjob..", MainJobLvl: "..mjobLvl..", SubJobID: "..sjobId..", SubJob: "..sjob..", SubJobLvl: "..sjobLvl)
end

function event_target_change(targId)
	add_to_chat(160, "Target change, TargID: "..targId)
end

function event_weather_change(id, name)
	add_to_chat(160, "Weather change, ID: "..id..", Name: "..name)
end

function event_status_change(old, new)
	add_to_chat(160, "Status change, Old: "..old..", New: "..new)
end

function event_hp_change(old, new)
	add_to_chat(160, "HP change, Old: "..old..", New: "..new)
end

function event_mp_change(old, new)
	add_to_chat(160, "MP change, Old: "..old..", New: "..new)
end

function event_tp_change(old, new)
	add_to_chat(160, "TP change, Old: "..old..", New: "..new)
end

function event_hpp_change(old, new)
	add_to_chat(160, "HP% change, Old: "..old..", New: "..new)
end

function event_mpp_change(old, new)
	add_to_chat(160, "MP% change, Old: "..old..", New: "..new)
end

function event_hpmax_change(old, new)
	add_to_chat(160, "MaxHP change, Old: "..old..", New: "..new)
end

function event_mpmax_change(old, new)
	add_to_chat(160, "MaxMP change, Old: "..old..", New: "..new)
end

function event_chat_message(isGM, mode, player, message)
	add_to_chat(160, "Chat message, GM: "..tostring(isGM)..", Mode: "..mode..", Player: "..player..", Message: "..message)
end

function event_emote(senderId, targetId, emoteId, motionOnly)
	add_to_chat(160, "Emote, SenderID: "..senderId..", TargetID: "..targetId..", EmoteID: "..emoteId.." MotionOnly: "..tostring(motionOnly))
end

function event_party_invite(senderId, sender, region)
	add_to_chat(160, "Party invite, SenderID: "..senderId..", Sender: "..sender..", Region: "..region)
end

function event_examined(examiner)
	add_to_chat(160, "Examined, Examiner: "..examiner)
end

function event_time_change(old, new)
	add_to_chat(160, "Time change, Old: "..old..", New: "..new)
end

function event_day_change(day)
	add_to_chat(160, "Day change, Day: "..day)
end

function event_moon_change(moon)
	add_to_chat(160, "Moon change, Moon: "..moon)
end

function event_moon_pct_change(pct)
	add_to_chat(160, "Moon% change, Percentage: "..pct)
end

function event_linkshell_change(linkshell)
	add_to_chat(160, "Linkshell change, Linkshell: "..linkshell)
end

function event_zone_change(fromId, from, toId, to)
	add_to_chat(160, "wot")
	--add_to_chat(160, "Zone change, FromID: "..fromId..", From: "..from..", ToID: "..toId..", To: "..to)
end