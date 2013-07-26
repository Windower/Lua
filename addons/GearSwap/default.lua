--------------------------------------------------------
-- Do not delete this or edit it.
--------------------------------------------------------
-- You should copy this and put it into addons/gearswap/data/
-- It needs to be renamed to <name>-<job>.lua
--------------------------------------------------------

function get_sets()
--------------------------------------------------------
----- This is where your set initialization goes. ------
--------------------------------------------------------
-- The outermost table has to be named "sets", but
-- otherwise there are no restrictions.
--------------------------------------------------------
	sets = {}
	sets.precast = {main="",sub="",range="",ammo="",
		head="",neck="",ear1="",ear2="",
		body="",hands="",lring="",rring="",
		back="",waist="",legs="",feet=""}
end

function precast(spell,action)
--------------------------------------------------------
-------- This is where precast processing goes. --------
--------------------------------------------------------
-- Precast phase occurs when you attempt the command.
-- The command you attempt will be interpreted and held
-- in memory while this precast function is run and the
-- resulting equip commands (when applicable) are sent
-- out. These equip commands will be bounced back by the
-- server to inform the client that the gear has changed.
-- At this point, the command will be sent.
-- 
-- Using ignore_verify() will cause the command to be
-- sent out immediately after the equip packets, ignoring
-- this verification step.
-- 
-- cast_delay(time) will add a 'wait' command in front of
-- the command. This can be useful in the case of
-- something like Twilight Cloak/Impact.
--------------------------------------------------------
-- spell: Resources line for the attempted spell.
-- action: Currently under/un-used. Intended to include
--        more information about the action in progress.
--------------------------------------------------------
end

function midcast(spell,action)
--------------------------------------------------------
-------- This is where midcast processing goes. --------
--------------------------------------------------------
-- Midcast phase occurs when you receive the "readies",
-- "casting", etc. message for your action. Specifically,
-- it is defined by the returning action packet from the
-- server following an action attempt. Be aware that some
-- spells and abilities (like Stun, Flash, Weapon Skills,
-- etc.) may have a midcast so short that equipment for
-- them effectively cannot be equipped here. You may need
-- to equip the gear for that in the precast phase.
--
-- It is useful to note that job abilities (because they 
-- do not have a "readies"-message equivalent) lack a
-- midcast phase.
--------------------------------------------------------
-- spell: Resources line for the attempted spell.
-- action: Currently under/un-used. Intended to include
--        more information about the action in progress.
--------------------------------------------------------
end

function aftercast(spell,action)
--------------------------------------------------------
------- This is where aftercast processing goes. -------
--------------------------------------------------------
-- Aftercast phase occurs when you receive the "result"
-- action packet from your action. For a weaponskill,
-- this would be the damage/miss message.
--------------------------------------------------------
-- spell: Resources line for the spell.
-- action: Currently under/un-used. Intended to include
--        more information about the action in progress.
--------------------------------------------------------
end

function status_change(old,new)
--------------------------------------------------------
-- This event will be called when your status changes --
--------------------------------------------------------
-- old: Previous status
-- new: Current status
-- Potential Statuses: "idle", "resting", "engaged", or
--                     "dead"
--------------------------------------------------------
end

function buff_change(status,gain_or_loss)
--------------------------------------------------------
----- This event will be called when buffs change ------
--------------------------------------------------------
-- status: Full name of the status changing
--   ie. "Sublimation: Charging"
-- gain_or_loss: "gain" or "loss"
--------------------------------------------------------
end

function pet_midcast(spell,action)
--------------------------------------------------------
---- This is where midcast processing goes for pets. ---
--------------------------------------------------------
-- Pet midcast phase occurs when you receive the
-- "readies", "casting", etc. message for your pet.
-- It is defined by the returning action packet from the
-- server following an action attempt. Be aware that some
-- pet abilities (like Shock Squall) may have a midcast
-- so short that equipment for them effectively cannot be
-- equipped here. You may need to equip the gear for that
-- in the player precast phase.
--
-- For some abilities, like most other BPs, this is the
-- phase where you would want to equip your BP damage
-- gear. For healing breath, this is where you'd equip
-- your potency gear
--------------------------------------------------------
-- spell: Resources line for the attempted spell.
-- action: Currently under/un-used. Intended to include
--        more information about the action in progress.
--------------------------------------------------------
end

function pet_aftercast(spell,action)
--------------------------------------------------------
--- This is where aftercast processing goes for pets. --
--------------------------------------------------------
-- Aftercast phase occurs when you receive the "result"
-- action packet from your action. For a BP or ready
-- move, this would be the damage/miss message.
--
-- If you were using BP damage gear, this would be when
-- you could swap your set back to idle.
--------------------------------------------------------
-- spell: Resources line for the spell.
-- action: Currently under/un-used. Intended to include
--        more information about the action in progress.
--------------------------------------------------------
end

function self_command(command)
--------------------------------------------------------
-- This is called whenever you input a //gs c <command>.
--------------------------------------------------------
-- This is designed to replace "dummy spells."
--------------------------------------------------------
-- command: a string with everything after "//gs c " in
--        it.
--------------------------------------------------------
end