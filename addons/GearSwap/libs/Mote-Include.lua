-------------------------------------------------------------------------------------------------------------------
-- Common variables and functions to be included in job scripts, for general default handling.
--
-- Include this file in the get_sets() function with the command:
-- include('Mote-Include.lua')
--
-- It will then automatically run its own init_include() function.
--
-- IMPORTANT: This include requires supporting include files:
-- Mote-Utility
-- Mote-Mappings
-- Mote-SelfCommands
-- Mote-Globals
--
-- Place the include() directive at the start of a job's get_sets() function.
--
-- Included variables and functions are considered to be at the same scope level as
-- the job script itself, and can be used as such.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines variables to be used.
-- These are accessible at the including job lua script's scope.
--
-- Auto-initialize after defining this function.
-------------------------------------------------------------------------------------------------------------------


function init_include()
	-- Used to define various types of data mappings.  These may be used in the initialization,
	-- so load it up front.
	include('Mote-Mappings')

	-- Var for tracking misc info
	info = {}

	-- Var for tracking state values
	state = {}

	-- General melee offense/defense modes, allowing for hybrid set builds, as well as idle/resting/weaponskill.
	state.OffenseMode     = 'Normal'
	state.DefenseMode     = 'Normal'
	state.RangedMode      = 'Normal'
	state.WeaponskillMode = 'Normal'
	state.CastingMode     = 'Normal'
	state.IdleMode        = 'Normal'
	state.RestingMode     = 'Normal'

	-- All-out defense state, either physical or magical
	state.Defense = {}
	state.Defense.Active       = false
	state.Defense.Type         = 'Physical'
	state.Defense.PhysicalMode = 'PDT'
	state.Defense.MagicalMode  = 'MDT'

	state.Kiting               = false
	state.MaxWeaponskillDistance = 0

	state.SelectNPCTargets     = false
	state.PCTargetMode         = 'default'

	state.CombatWeapon = nil
	state.CombatForm = nil

	state.Buff = {}


	-- Vars for specifying valid mode values.
	-- Defaults here are just for example. Set them properly in each job file.
	options = {}
	options.OffenseModes = {'Normal'}
	options.DefenseModes = {'Normal'}
	options.RangedModes = {'Normal'}
	options.WeaponskillModes = {'Normal'}
	options.CastingModes = {'Normal'}
	options.IdleModes = {'Normal'}
	options.RestingModes = {'Normal'}
	options.PhysicalDefenseModes = {'PDT'}
	options.MagicalDefenseModes = {'MDT'}

	options.TargetModes = {'default', 'stpc', 'stpt', 'stal'}


	-- Spell mappings to describe a 'type' of spell.  Used when searching for valid sets.
	classes = {}
	-- Basic spell mappings are based on common spell series.
	-- EG: 'Cure' for Cure, Cure II, Cure III, Cure IV, Cure V, or Cure VI.
	classes.SpellMaps = spell_maps
	-- List of spells and spell maps that don't benefit from greater skill (though
	-- they may benefit from spell-specific augments, such as improved regen or refresh).
	-- Spells that fall under this category will be skipped when searching for
	-- spell.skill sets.
	classes.NoSkillSpells = no_skill_spells_list
	-- Custom, job-defined class, like the generic spell mappings.
	-- Takes precedence over default spell maps.
	-- Is reset at the end of each spell casting cycle (ie: at the end of aftercast).
	classes.CustomClass = nil
	classes.JAMode = nil
	-- Custom groups used for defining melee and idle sets.  Persists long-term.
	classes.CustomMeleeGroups = L{}
	classes.CustomRangedGroups = L{}
	classes.CustomIdleGroups = L{}
	classes.CustomDefenseGroups = L{}

	-- Class variables for time-based flags
	classes.Daytime = false
	classes.DuskToDawn = false


	-- Special control flags.
	mote_flags = {}
	mote_flags.show_set = nil

	-- Display text mapping.
	on_off_names = {[true] = 'on', [false] = 'off'}
	on_off_values = T{'on', 'off', 'true', 'false'}
	true_values = T{'on', 'true'}


	-- Subtables within the sets table that we expect to exist, and are annoying to have to
	-- define within each individual job file.  We can define them here to make sure we don't
	-- have to check for existence.  The job file should be including this before defining
	-- any sets, so any changes it makes will override these anyway.
	sets.precast = {}
	sets.precast.FC = {}
	sets.precast.JA = {}
	sets.precast.WS = {}
	sets.precast.RA = {}
	sets.midcast = {}
	sets.midcast.RA = {}
	sets.midcast.Pet = {}
	sets.idle = {}
	sets.resting = {}
	sets.engaged = {}
	sets.defense = {}
	sets.buff = {}

	gear = {}
	gear.default = {}

	gear.ElementalGorget = {name=""}
	gear.ElementalBelt = {name=""}
	gear.ElementalObi = {name=""}
	gear.ElementalCape = {name=""}
	gear.ElementalRing = {name=""}
	gear.FastcastStaff = {name=""}
	gear.RecastStaff = {name=""}


	-- Load externally-defined information (info that we don't want to change every time this file is updated).

	-- Used to define misc utility functions that may be useful for this include or any job files.
	include('Mote-Utility')

	-- Used for all self-command handling.
	include('Mote-SelfCommands')

	-- Include general user globals, such as custom binds or gear tables.
	-- If the user defined their own globals (user-globals.lua), use that; otherwise use Mote-Globals.
	if not load_user_globals() then
		include('Mote-Globals')
	end

	-- user-globals.lua may define additional sets to be added to the local ones.
	if define_global_sets then
		define_global_sets()
	end

	-- Global default binds (either from Mote-Globals or user-globals)
	binds_on_load()

	-- Load a sidecar file for the job (if it exists) that may re-define init_gear_sets and file_unload.
	load_user_gear(player.main_job)

	-- General var initialization and setup.
	if job_setup then
		job_setup()
	end

	-- User-specific var initialization and setup.
	if user_setup then
		user_setup()
	end

	-- Load up all the gear sets.
	init_gear_sets()
end

-- Auto-initialize the include
init_include()


-------------------------------------------------------------------------------------------------------------------
-- Generalized functions for handling precast/midcast/aftercast for player-initiated actions.
-- This depends on proper set naming.
-- Each job can override any amount of these general functions using job_xxx() hooks.
-------------------------------------------------------------------------------------------------------------------

-- Pretarget is called when GearSwap intercepts the original text input, but
-- before the game has done any processing on it.  In particular, it hasn't
-- initiated target selection for <st*> target types.
-- This is the only function where it will be valid to use change_target().
function pretarget(spell,action)
	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init an eventArgs that allows cancelling.
	local eventArgs = {handled = false, cancel = false}

	-- Call the job file first, if it has a function to handle this.
	if job_pretarget then
		job_pretarget(spell, action, spellMap, eventArgs)
	end

	-- If a cancel is requested, cancel_spell and finish.
	if eventArgs.cancel then
		cancel_spell()
		return
	end

	-- If the job didn't handle things themselves, continue.
	if not eventArgs.handled then
		-- Handle optional target conversion.
		auto_change_target(spell, action, spellMap)
	end
end


-- Called after the text command has been processed (and target selected), but
-- before the packet gets pushed out.
-- Equip any gear that should be on before the spell or ability is used.
function precast(spell, action)
	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init an eventArgs that allows cancelling.
	local eventArgs = {handled = false, cancel = false}

	-- Call the job file first, if it has a function to handle this.
	if job_precast then
		job_precast(spell, action, spellMap, eventArgs)
	end

	-- If a cancel is requested, cancel_spell and finish.
	if eventArgs.cancel then
		cancel_spell()
		return
	end

	-- Equip default precast gear if the job didn't mark this as handled.
	if not eventArgs.handled then
		equip(get_default_precast_set(spell, action, spellMap, eventArgs))
	end

	-- Allow the job to add additional gear on top of the default set.
	if job_post_precast then
		job_post_precast(spell, action, spellMap, eventArgs)
	end

	-- If show_set is flagged for precast, notify that we won't try to equip later gear.
	if mote_flags.show_set == 'precast' then
		add_to_chat(104, 'Show Sets: Stopping at precast.')
	end
end


-- Called immediately after precast() so that we can build the midcast gear set which
-- will be sent out at the same time (packet contains precastgear:action:midcastgear).
-- Midcast gear selected should be for potency, recast, etc.  It should take effect
-- regardless of the spell cast speed.
function midcast(spell,action)
	-- If show_set is flagged for precast, don't try to equip midcast gear.
	if mote_flags.show_set == 'precast' then
		return
	end

	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Call the job file first, if it has a function to handle this.
	if job_midcast then
		job_midcast(spell, action, spellMap, eventArgs)
	end

	-- Equip default midcast gear if the job didn't mark this as handled.
	if not eventArgs.handled then
		equip(get_default_midcast_set(spell, action, spellMap, eventArgs))
	end

	-- Allow the job to add additional gear on top of the default set.
	if job_post_midcast then
		job_post_midcast(spell, action, spellMap, eventArgs)
	end

	-- If show_set is flagged for midcast, notify that we won't try to equip later gear.
	if mote_flags.show_set == 'midcast' then
		add_to_chat(104, 'Show Sets: Stopping at midcast.')
	end
end


-- Called when an action has been completed (ie: spell finished casting, weaponskill
-- did damage, spell was interrupted, etc).
function aftercast(spell,action)
	-- If show_set is flagged for precast or midcast, don't try to equip aftercast gear.
	if mote_flags.show_set == 'precast' or mote_flags.show_set == 'midcast' or mote_flags.show_set == 'pet_midcast' then
		if not pet_midaction() then
			reset_transitory_classes()
		end
		return
	end

	-- Ignore the Unknown Interrupt
	if spell.name == 'Unknown Interrupt' then
		--add_to_chat(123, 'aftercast trace: Unknown Interrupt.  interrupted='..tostring(spell.interrupted))
		return
	end

	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Call the job file first, if it has a function to handle this.
	if job_aftercast then
		job_aftercast(spell, action, spellMap, eventArgs)
	end

	-- Handle equipping default gear if the job didn't mark this as handled, and
	-- if the pet isn't in mid-action (thus triggering calls to pet_midcast before
	-- this and pet_aftercast after this).
	if not eventArgs.handled and not pet_midaction() then
		if spell.interrupted then
			-- Wait a half-second to update so that aftercast equip will actually be worn.
			send_command('wait 0.6;gs c update')
		else
			handle_equipping_gear(player.status)
		end
	end

	-- Allow the job to take additional actions after the default gear handling.
	if job_post_aftercast then
		job_post_aftercast(spell, action, spellMap, eventArgs)
	end

	-- Reset after all possible precast/midcast/aftercast/job-specific usage of the value,
	-- if we're not in the middle of a pet action.  If so, pet_aftercast will handle
	-- clearing it.
	if not pet_midaction() then
		reset_transitory_classes()
	end
end


-- Called when the pet readies an action.
function pet_midcast(spell,action)
	-- If we have show_set active for precast or midcast, don't try to equip pet midcast gear.
	if mote_flags.show_set == 'precast' or mote_flags.show_set == 'midcast' then
		add_to_chat(104, 'Show Sets: Pet midcast not equipped.')
		return
	end

	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Call the job file first, if it has a function to handle this.
	if job_pet_midcast then
		job_pet_midcast(spell, action, spellMap, eventArgs)
	end

	-- Perform default equips if the job didn't handle it.
	if not eventArgs.handled then
		equip(get_default_pet_midcast_set(spell, action, spellMap, eventArgs))
	end

	-- Allow the job to add additional gear on top of the default set.
	if job_post_pet_midcast then
		job_post_pet_midcast(spell, action, spellMap, eventArgs)
	end

	-- If show_set is flagged for pet midcast, notify that we won't try to equip later gear.
	if mote_flags.show_set == 'pet_midcast' then
		add_to_chat(104, 'Show Sets: Stopping at pet midcast.')
	end
end


-- Called when the pet's action is complete.
function pet_aftercast(spell,action)
	-- If show_set is flagged for precast or midcast, don't try to equip aftercast gear.
	if mote_flags.show_set == 'precast' or mote_flags.show_set == 'midcast' or mote_flags.show_set == 'pet_midcast' then
		reset_transitory_classes()
		return
	end

	-- Get the spell mapping, since we'll be passing it to various functions and checks.
	local spellMap = get_spell_map(spell)

	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Call the job file first, if it has a function to handle this.
	if job_pet_aftercast then
		job_pet_aftercast(spell, action, spellMap, eventArgs)
	end

	if not eventArgs.handled then
		if spell.interrupted then
			-- Wait a half-second to update so that aftercast equip will actually be worn.
			send_command('wait 0.6;gs c update')
		else
			handle_equipping_gear(player.status)
		end
	end

	-- Allow the job to take additional actions after the default gear handling.
	if job_post_pet_aftercast then
		job_post_pet_aftercast(spell, action, spellMap, eventArgs)
	end

	-- Reset after all possible precast/midcast/aftercast/job-specific usage of the value.
	reset_transitory_classes()
end


-------------------------------------------------------------------------------------------------------------------
-- Hooks for non-action events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's subjob changes.
function sub_job_change(newSubjob, oldSubjob)
	if user_setup then
		user_setup()
	end
	
	if job_sub_job_change then
		job_sub_job_change(newSubjob, oldSubjob)
	end
end



-- Called when the player's status changes.
function status_change(newStatus, oldStatus)
	-- init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to handle status change events.
	if job_status_change then
		job_status_change(newStatus, oldStatus, eventArgs)
	end

	-- Allow a global function (ie: UserGlobals.lua) to be called on status change,
	-- if the individual job didn't mark it as handled.
	if not eventArgs.handled then
		if user_status_change then
			user_status_change(newStatus, oldStatus, eventArgs)
		end
	end

	-- Handle equipping default gear if the job didn't mark this as handled.
	if not eventArgs.handled then
		handle_equipping_gear(newStatus)
	end
end


-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function buff_change(buff, gain)
	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to handle buff change events.
	if job_buff_change then
		job_buff_change(buff, gain, eventArgs)
	end

	-- Allow a global function (ie: UserGlobals.lua) to be called on buff change,
	-- if the individual job didn't mark it as handled.
	if not eventArgs.handled then
		if user_buff_change then
			user_buff_change(buff, gain, eventArgs)
		end
	end
end


-- Called when a player gains or loses a pet.
-- pet == pet gained or lost
-- gain == true if the pet was gained, false if it was lost.
function pet_change(pet, gain)
	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to handle pet change events.
	if job_pet_change then
		job_pet_change(pet, gain, eventArgs)
	end

	-- Equip default gear if not handled by the job.
	if not eventArgs.handled then
		handle_equipping_gear(player.status)
	end
end


-- Called when the player's pet's status changes.
-- Note that this is also called after pet_change when the pet is released.
-- As such, don't automatically handle gear equips.  Only do so if directed
-- to do so by the job.
function pet_status_change(newStatus, oldStatus)
	-- Init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to override this code
	if job_pet_status_change then
		job_pet_status_change(newStatus, oldStatus, eventArgs)
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Generalized functions for selecting and equipping gear sets.
-------------------------------------------------------------------------------------------------------------------

-- Central point to call to equip gear based on status.
-- Status - Player status that we're using to define what gear to equip.
function handle_equipping_gear(playerStatus, petStatus)
	-- init a new eventArgs
	local eventArgs = {handled = false}

	-- Allow jobs to override this code
	if job_handle_equipping_gear then
		job_handle_equipping_gear(playerStatus, eventArgs)
	end

	-- Equip default gear if job didn't handle it.
	if not eventArgs.handled then
		equip_gear_by_status(playerStatus)
	end
end


-- Function to wrap logic for equipping gear on aftercast, status change, or user update.
-- @param status : The current or new player status that determines what sort of gear to equip.
function equip_gear_by_status(status)
	if _global.debug_mode then add_to_chat(123,'Debug: Equip gear for status ['..tostring(status)..'], HP='..tostring(player.hp)) end

	-- If status not defined, treat as idle.
	-- Be sure to check for positive HP to make sure they're not dead.
	if (status == nil or status == '') and player.hp > 0 then
		equip(get_current_idle_set())
	elseif status == 'Idle' then
		equip(get_current_idle_set())
	elseif status == 'Engaged' then
		equip(get_current_melee_set())
	elseif status == 'Resting' then
		equip(get_current_resting_set())
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for constructing default sets.
-------------------------------------------------------------------------------------------------------------------

-- Get a spell mapping for the spell.
function get_spell_map(spell)
	local defaultSpellMap = classes.SpellMaps[spell.english]
	local jobSpellMap
	
	if job_get_spell_map then
		jobSpellMap = job_get_spell_map(spell, defaultSpellMap)
	end

	if jobSpellMap then
		return jobSpellMap
	else
		return defaultSpellMap
	end
end


-- Simple utility function to handle a portion of the equipment set determination.
-- It attempts to select a sub-table of the provided equipment set based on the
-- standard search order of custom class, spell name, and spell map.
-- If no such set is found, it returns the original base set (equipSet) provided.
function get_named_set(equipSet, spell, spellMap)
	if equipSet then
		return  (classes.CustomClass and equipSet[classes.CustomClass]) or
			 equipSet[spell.english] or
			(spellMap and equipSet[spellMap]) or
			 equipSet
	end
end


-- Select the equipment set to equip from a given starting table, based on standard
-- selection order: custom class, spell name, spell map, spell skill, and spell type.
-- Spell skill and spell type may further refine their selections based on
-- custom class, spell name and spell map.
function select_specific_set(equipSet, spell, spellMap)
	-- Take the determined base equipment set and try to get the simple naming extensions that
	-- may apply to it (class, spell name, spell map).
	local namedSet = get_named_set(equipSet, spell, spellMap)
	
	-- If no simple naming sub-tables were found, and we simply got back the original equip set,
	-- check for spell.skill and spell.type, and check the simple naming extensions again.
	if namedSet == equipSet then
		namedSet = (spell.skill and equipSet[spell.skill]) or
			   (spell.type and equipSet[spell.type])

		-- If namedSet is nil at this point, we end up returning to equipSet
		namedSet = get_named_set(namedSet, spell, spellMap) or equipSet
	end

	return namedSet
end


-- Get the default precast gear set.
function get_default_precast_set(spell, action, spellMap, eventArgs)
	-- If there are no precast sets defined, bail out.
	if not sets.precast then
		return {}
	end
	
	local equipSet = sets.precast

	-- Determine base sub-table from type of action being performed.
	
	if spell.action_type == 'Magic' then
		equipSet = sets.precast.FC
	elseif spell.action_type == 'Ranged Attack' then
		equipSet = sets.precast.RA or sets.precast.RangedAttack
	elseif spell.action_type == 'Ability' then
		if spell.type == 'WeaponSkill' then
			equipSet = sets.precast.WS
		elseif spell.type == 'JobAbility' then
			equipSet = sets.precast.JA
		else
			-- Allow fallback to .JA table if spell.type isn't found, for all non-weaponskill abilities.
			equipSet = sets.precast[spell.type] or sets.precast.JA
		end
	elseif spell.action_type == 'Item' then
		equipSet = sets.precast.Item
	end
	
	-- If no proper sub-category is defined in the job file, bail out.
	if not equipSet then
		return {}
	end

	-- Handle automatic selection of set based on spell class/name/map/skill/type.
	equipSet = select_specific_set(equipSet, spell, spellMap)

	
	-- Once we have a named base set, do checks for specialized modes (casting mode, weaponskill mode, etc).
	
	if spell.action_type == 'Magic' then
		if equipSet[state.CastingMode] then
			equipSet = equipSet[state.CastingMode]
		end
	elseif spell.type == 'WeaponSkill' then
		-- Custom handling for weaponskills
		local ws_mode = state.WeaponskillMode
		
		if ws_mode == 'Normal' then
			-- If a particular weaponskill mode isn't specified, see if we have a weaponskill mode
			-- corresponding to the current offense mode.  If so, use that.
			if state.OffenseMode ~= 'Normal' and S(options.WeaponskillModes):contains(state.OffenseMode) then
				ws_mode = state.OffenseMode
			end
		end

		local custom_wsmode

		-- Allow the job file to specify a preferred weaponskill mode
		if get_custom_wsmode then
			custom_wsmode = get_custom_wsmode(spell, spellMap, ws_mode)
		end

		-- If the job file returned a weaponskill mode, use that.
		if custom_wsmode then
			ws_mode = custom_wsmode
		end

		if equipSet[ws_mode] then
			equipSet = equipSet[ws_mode]
		end
	elseif spell.action_type == 'Ability' then
		if classes.JAMode and equipSet[classes.JAMode] then
			equipSet = equipSet[classes.JAMode]
		end
	elseif spell.action_type == 'Ranged Attack' then
		-- Check for specific mode for ranged attacks (eg: Acc, Att, etc)
		if equipSet[state.RangedMode] then
			equipSet = equipSet[state.RangedMode]
		end

		-- Tack on any additionally specified custom groups, if the sets are defined.
		for _,group in ipairs(classes.CustomRangedGroups) do
			if equipSet[group] then
				equipSet = equipSet[group]
			end
		end
	end

	-- Update defintions for element-specific gear that may be used.
	set_elemental_gear(spell)
	
	-- Return whatever we've constructed.
	return equipSet
end


-- Get the default midcast gear set.
-- This builds on sets.midcast.
function get_default_midcast_set(spell, action, spellMap, eventArgs)
	local equipSet

	-- If there are no midcast sets defined, bail out.
	if not sets.midcast then
		return {}
	end
	
	-- Determine base sub-table from type of action being performed.
	-- Only ranged attacks and items get specific sub-categories here.
	
	if spell.action_type == 'Ranged Attack' then
		equipSet = sets.midcast.RA or sets.midcast.RangedAttack
	elseif spell.action_type == 'Item' then
		equipSet = sets.midcast.Item
	else
		equipSet = sets.midcast
	end
	
	-- If no proper sub-category is defined in the job file, bail out.
	if not equipSet then
		return {}
	end

	-- Handle automatic selection of set based on spell class/name/map/skill/type.
	equipSet = select_specific_set(equipSet, spell, spellMap)

	
	-- After the default checks, do checks for specialized modes (casting mode, etc).
	
	if spell.action_type == 'Magic' then
		if equipSet[state.CastingMode] then
			equipSet = equipSet[state.CastingMode]
		end
	elseif spell.action_type == 'Ranged Attack' then
		-- Check for specific mode for ranged attacks (eg: Acc, Att, etc)
		if equipSet[state.RangedMode] then
			equipSet = equipSet[state.RangedMode]
		end

		-- Tack on any additionally specified custom groups, if the sets are defined.
		for _,group in ipairs(classes.CustomRangedGroups) do
			if equipSet[group] then
				equipSet = equipSet[group]
			end
		end
	end
	
	-- Return whatever we've constructed.
	return equipSet
end


-- Get the default pet midcast gear set.
-- This is built in sets.midcast.Pet.
function get_default_pet_midcast_set(spell, action, spellMap, eventArgs)
	local equipSet = {}

	if sets.midcast and sets.midcast.Pet then
		equipSet = sets.midcast.Pet

		equipSet = select_specific_set(equipSet, spell, spellMap)

		-- We can only generally be certain about whether the pet's action is
		-- Magic (ie: it cast a spell of its own volition) or Ability (it performed
		-- an action at the request of the player).  Allow CastinMode and
		-- OffenseMode to refine whatever set was selected above.
		if spell.action_type == 'Magic' then
			if equipSet[state.CastingMode] then
				equipSet = equipSet[state.CastingMode]
			end
		elseif spell.action_type == 'Ability' then
			if equipSet[state.OffenseMode] then
				equipSet = equipSet[state.OffenseMode]
			end
		end
	end

	return equipSet
end


-- Returns the appropriate idle set based on current state.
-- Set construction order (all of which are optional):
-- sets.idle[idleScope][state.IdleMode][Pet[.Engaged]][CustomIdleGroups]
function get_current_idle_set()
	local idleSet = sets.idle
	local idleScope

	if buffactive.weakness then
		idleScope = 'Weak'
	elseif areas.Cities:contains(world.area) then
		idleScope = 'Town'
	else
		idleScope = 'Field'
	end

	if idleSet[idleScope] then
		idleSet = idleSet[idleScope]
	end

	if idleSet[state.IdleMode] then
		idleSet = idleSet[state.IdleMode]
	end

	if (pet.isvalid or state.Buff.Pet) and idleSet.Pet then
		idleSet = idleSet.Pet

		if pet.status == 'Engaged' and idleSet.Engaged then
			idleSet = idleSet.Engaged
		end
	end

	for _,group in ipairs(classes.CustomIdleGroups) do
		if idleSet[group] then
			idleSet = idleSet[group]
		end
	end

	idleSet = apply_defense(idleSet)
	idleSet = apply_kiting(idleSet)

	if customize_idle_set then
		idleSet = customize_idle_set(idleSet)
	end

	return idleSet
end


-- Returns the appropriate melee set based on current state.
-- Set construction order (all sets after sets.engaged are optional):
--   sets.engaged[state.CombatForm][state.CombatWeapon][state.OffenseMode][state.DefenseMode][classes.CustomMeleeGroups (any number)]
function get_current_melee_set()
	local meleeSet = sets.engaged

	if state.CombatForm and meleeSet[state.CombatForm] then
		meleeSet = meleeSet[state.CombatForm]
	end

	if state.CombatWeapon and meleeSet[state.CombatWeapon] then
		meleeSet = meleeSet[state.CombatWeapon]
	end

	if meleeSet[state.OffenseMode] then
		meleeSet = meleeSet[state.OffenseMode]
	end

	if meleeSet[state.DefenseMode] then
		meleeSet = meleeSet[state.DefenseMode]
	end

	for _,group in ipairs(classes.CustomMeleeGroups) do
		if meleeSet[group] then
			meleeSet = meleeSet[group]
		end
	end

	meleeSet = apply_defense(meleeSet)
	meleeSet = apply_kiting(meleeSet)

	if customize_melee_set then
		meleeSet = customize_melee_set(meleeSet)
	end

	return meleeSet
end


-- Returns the appropriate resting set based on current state.
function get_current_resting_set()
	local restingSet = {}

	if sets.resting then
		restingSet = sets.resting

		if restingSet[state.RestingMode] then
			restingSet = restingSet[state.RestingMode]
		end
	end

	return restingSet
end

-------------------------------------------------------------------------------------------------------------------
-- Functions for optional supplemental gear overriding the default sets defined above.
-------------------------------------------------------------------------------------------------------------------

-- Function to apply any active defense set on top of the supplied set
-- @param baseSet : The set that any currently active defense set will be applied on top of. (gear set table)
function apply_defense(baseSet)
	if state.Defense.Active then
		local defenseSet

		if state.Defense.Type == 'Physical' then
			if sets.defense[state.Defense.PhysicalMode] then
				defenseSet = sets.defense[state.Defense.PhysicalMode]
			else
				defenseSet = sets.defense
			end
		else
			if sets.defense[state.Defense.MagicalMode] then
				defenseSet = sets.defense[state.Defense.MagicalMode]
			else
				defenseSet = sets.defense
			end
		end

		for _,group in ipairs(classes.CustomDefenseGroups) do
			if defenseSet[group] then
				defenseSet = defenseSet[group]
			end
		end

		baseSet = set_combine(baseSet, defenseSet)
	end

	return baseSet
end


-- Function to add kiting gear on top of the base set if kiting state is true.
-- @param baseSet : The gear set that the kiting gear will be applied on top of.
function apply_kiting(baseSet)
	if state.Kiting then
		if sets.Kiting then
			baseSet = set_combine(baseSet, sets.Kiting)
		end
	end

	return baseSet
end


-------------------------------------------------------------------------------------------------------------------
-- Functions for refactoring code.
-------------------------------------------------------------------------------------------------------------------

-- Clears the values from classes that only exist til the action is complete.
function reset_transitory_classes()
	classes.CustomClass = nil
	classes.JAMode = nil
end



