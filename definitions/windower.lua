---@meta

---@class windower
---@field pol_path string Absolute path to the POL installation directory.
---@field ffxi_path string Absolute path to the FFXI installation directory.
---@field windower_path string Absolute path to the running Windower instance directory.
---@field addon_path string Absolute path to the current addon directory.
windower = {
    ---Checks if the Windower instance has focus.
    ---@return boolean #Whether the instance has focus.
    has_focus = function() end,

    ---Takes focus from any application (does nothing if already focused).
    ---@return nil
    take_focus = function() end,

    ---Copies the provided string to the clipboard.
    ---@param str string String to copy.
    ---@return nil
    copy_to_clipboard = function(str) end,

    ---Returns the contents of the clipboard, or `nil` if the clipboard is empty or contains non-text content.
    ---@return string | nil #Clipboard contents.
    get_from_clipboard = function() end,

    ---Executes a Windower command.
    ---@param command string Command to execute. Separate multiple commands with `;` inside the string.
    ---@return nil
    send_command = function(command) end,

    ---Outputs a message to the chatlog. The chatmode argument roughly corresponds to color.
    ---@param mode integer Chat mode to use.
    ---@param msg string Message to write.
    ---@return nil
    add_to_chat = function(mode, msg) end,

    ---Returns the currently set in-game chat filters.
    ---@return (0|1)[] #Chat filter settings.
    get_chat_filters = function() end,

    ---Gets information on the current camera.
    ---@return windower.camera #Camera data.
    get_camera = function() end,

    ---Sends an IPC message to all other Windower instances that have the same addon loaded. This message is handled by the `"ipc message"` event.
    ---@param msg string Message to send.
    ---@return nil
    send_ipc_message = function(msg) end,

    ---Executes a file on the system. Activity remains on the current window.
    ---@param file string The path to the file.
    ---@param arguments string[] List of arguments to pass.
    ---@return nil
    execute = function(file, arguments) end,

    ---Opens a URL in the default browser.
    ---@param url string URL to open.
    ---@return nil
    open_url = function(url) end,

    ---Plays a sound file. Only .wav is supported.
    ---@param path string The path to the file.
    ---@return nil
    play_sound = function(path) end,

    ---Checks if a path is a valid a file.
    ---@param path string Absolute path to check.
    ---@return boolean #Whether or not the file exists.
    file_exists = function(path) end,

    ---Checks if a path is a valid directory.
    ---@param path string Absolute path to check.
    ---@return boolean #Whether or not the directory exists.
    dir_exists = function(path) end,

    ---Returns names of file and directory within one directory.
    ---@param path string The path to the directory.
    ---@return string[] #List of file and directory names.
    get_dir = function(path) end,

    ---Creates the final directory in the path. Will error if an intermediate directory does not exist.
    ---@param path string The path to the folder.
    ---@return boolean, string|nil #Status and error message.
    create_dir = function(path) end,

    ---Returns a table of the user's Windower settings.
    ---@return windower.windower_settings
    get_windower_settings = function() end,

    ---Changes the name of a mob. Can cause crashes.
    ---@param id integer ID of the mob.
    ---@param name string New name to set for the mob.
    ---@return nil
    set_mob_name = function(id, name) end,

    ---Evaluates all auto-translate blocks in a string with the text for the current language of the game.
    ---@param str string Input string.
    ---@return string #Input string with auto-translate blocks replaced with plain text equivalents.
    convert_auto_trans = function(str) end,

    ---Checks a string for a pattern match with wildcard support. Allowed tokens:<br>
    ---`?` matches any one character<br>
    ---`*` matches arbitrary many characters<br>
    ---`|` alternation, matches either the left or right side of it
    ---@param str string Input string to match.
    ---@param pattern string Pattern to match against.
    ---@return boolean #Whether or not the string matches the pattern.
    wc_match = function(str, pattern) end,

    ---Registers a function to run on the provided event.
    ---@param ... any Any number of event names, followed by a function to execute.
    ---@return integer ... Handles to registered functions.
    register_event = function(...) end,

    ---Unregisters a previously registered event handler.
    ---@param ... integer IDs of the event handlers to unregister.
    ---@return nil
    unregister_event = function(...) end,

    ---Prints all arguments to the debug log, prepended by thread ID and addon name.
    ---@param ... any Any number/type of arguments to be printed.
    ---@return nil
    debug = function(...) end,

    ---Converts a Shift_JIS (FFXI flavor) string to UTF-8.
    ---@param str string The string to convert.
    ---@return string #UTF-8 string.
    from_shift_jis = function(str) end,

    ---Converts a UTF-8 string to Shift_JIS (FFXI flavor).
    ---@param str string The string to convert.
    ---@return string #Shift_JIS string.
    to_shift_jis = function(str) end,

    ---Gets information on the item currently displayed on-screen.
    ---@return windower.item_display | nil #The displayed item, if any is being displayed, otherwise `nil`.
    get_item_display = function() end,

    ---FFXI in-game related functions.
    ---@class windower.ffxi
    ffxi = {
        ---Returns information about the current player.
        ---@return windower.ffxi.player | nil #The current player information, or `nil`, if not logged in.
        get_player = function() end,

        ---Returns information about the current game state.
        ---@return windower.ffxi.info #The current game state information.
        get_info = function() end,

        ---@class windower.ffxi.player
        ---@field name string Name.
        ---@field id integer Unique character ID.
        ---@field index integer Entity array index.
        ---@field main_job_id string Main job ID as specified in the [jobs resources](https://github.com/Windower/Resources/blob/master/resources_data/jobs.lua).
        ---@field main_job string Main job three-letter abbreviation, e.g. `WAR`.
        ---@field main_job_full string Main job full name, e.g. Warrior.
        ---@field main_job_level integer Main job level.
        ---@field sub_job_id string Sub job ID as specified in the [jobs resources](https://github.com/Windower/Resources/blob/master/resources_data/jobs.lua), if it exists, otherwise `nil`.
        ---@field sub_job string Sub job three-letter abbreviation, e.g. `WAR`, if it exists, otherwise `nil`.
        ---@field sub_job_full string Sub job full name, e.g. Warrior, if it exists, otherwise `nil`.
        ---@field sub_job_level integer Sub job level, if it exists, otherwise `nil`.
        ---@field buffs integer[] Active buff IDs as specified in the [buffs resources](https://github.com/Windower/Resources/blob/master/resources_data/buffs.lua).
        ---@field skills windower.ffxi.player.skills Skill levels.
        ---@field vitals windower.ffxi.player.vitals Vitals.
        ---@field jobs table<job_short, integer> Levels, indexed by job three-letter abbreviation, e.g. `WAR`.
        ---@field merits windower.ffxi.player.merits Merits.
        ---@field job_points windower.ffxi.player.job_points Job points.
        ---@field linkshell string Equipped main linkshell's name.
        ---@field linkshell_slot integer Equipped main linkshell's slot.
        ---@field nation 0 | 1 | 2 Nation ID as specified in the [regions resources](https://github.com/Windower/Resources/blob/master/resources_data/regions.lua).
        ---@field status integer Status ID as specified in the [statuses resources](https://github.com/Windower/Resources/blob/master/resources_data/statuses.lua).
        ---TODO add more
        player = {
            ---@class windower.ffxi.player.skills
            ---@field hand_to_hand integer Hand-to-Hand skill level.
            ---@field dagger integer Dagger skill level.
            ---@field sword integer Sword skill level.
            ---@field great_sword integer Great Sword skill level.
            ---@field axe integer Axe skill level.
            ---@field great_axe integer Great Axe skill level.
            ---@field scythe integer Scythe skill level.
            ---@field polearm integer Polearm skill level.
            ---@field katana integer Katana skill level.
            ---@field great_katana integer Great Katana skill level.
            ---@field club integer Club skill level.
            ---@field staff integer Staff skill level.
            ---@field archery integer Archery skill level.
            ---@field marksmanship integer Marksmanship skill level.
            ---@field throwing integer Throwing skill level.
            ---@field guard integer Guard skill level.
            ---@field evasion integer Evasion skill level.
            ---@field shield integer Shield skill level.
            ---@field parrying integer Parrying skill level.
            ---@field divine_magic integer Divine Magic skill level.
            ---@field healing_magic integer Healing Magic skill level.
            ---@field enhancing_magic integer Enhancing Magic skill level.
            ---@field enfeebling_magic integer Enfeebling Magic skill level.
            ---@field elemental_magic integer Elemental Magic skill level.
            ---@field dark_magic integer Dark Magic skill level.
            ---@field summoning_magic integer Summoning Magic skill level.
            ---@field ninjutsu integer Ninjutsu skill level.
            ---@field singing integer Singing skill level.
            ---@field stringed_instrument integer String Instrument skill level.
            ---@field wind_instrument integer Wind Instrument skill level.
            ---@field blue_magic integer Blue Magic skill level.
            ---@field geomancy integer Geomancy skill level.
            ---@field handbell integer Handbell skill level.
            ---@field alchemy integer Alchemy skill level.
            ---@field bonecraft integer Bonecraft skill level.
            ---@field clothcraft integer Clothcraft skill level.
            ---@field cooking integer Cooking skill level.
            ---@field fishing integer Fishing skill level.
            ---@field goldsmithing integer Goldsmithing skill level.
            ---@field leathercraft integer Leathercraft skill level.
            ---@field smithing integer Smithing skill level.
            ---@field woodworking integer Woodworking skill level.
            ---@field synergy integer Synergy skill level.
            skills = {},

            ---@class windower.ffxi.player.vitals
            ---@field hp integer The current HP.
            ---@field max_hp integer The current maximum HP.
            ---@field hpp integer The current HP percentage.
            ---@field mp integer The current MP.
            ---@field max_mp integer The current maximum MP.
            ---@field mpp integer The current MP percentage.
            ---@field tp integer The current TP.
            vitals = {},

            ---@class windower.ffxi.player.merits
            ---@field max_hp integer Max HP
            ---@field max_mp integer Max MP
            ---@field maximum_merit_points integer Maximum merit points
            ---@field str integer STR
            ---@field dex integer DEX
            ---@field vit integer VIT
            ---@field int integer INT
            ---@field mnd integer MND
            ---@field agi integer AGI
            ---@field chr integer CHR
            ---@field hand_to_hand integer Hand-to-Hand Skill
            ---@field dagger integer Dagger Skill
            ---@field sword integer Sword Skill
            ---@field great_sword integer Great Sword Skill
            ---@field axe integer Axe Skill
            ---@field great_axe integer Great Axe Skill
            ---@field scythe integer Scythe Skill
            ---@field polearm integer Polearm Skill
            ---@field katana integer Katana Skill
            ---@field great_katana integer Great Katana Skill
            ---@field club integer Club Skill
            ---@field staff integer Staff Skill
            ---@field archery integer Archery Skill
            ---@field marksmanship integer Marksmanship Skill
            ---@field throwing integer Throwing Skill
            ---@field guarding integer Guarding Skill
            ---@field evasion integer Evasion Skill
            ---@field shield integer Shield Skill
            ---@field parrying integer Parrying Skill
            ---@field divine integer Divine Magic Skill
            ---@field healing integer Healing Magic Skill
            ---@field enhancing integer Enhancing Magic Skill
            ---@field enfeebling integer Enfeebling Magic Skill
            ---@field elemental integer Elemental Magic Skill
            ---@field dark integer Dark Magic Skill
            ---@field summoning integer Summoning Magic Skill
            ---@field ninjutsu integer Ninjutsu Skill
            ---@field singing integer Singing Skill
            ---@field string integer String Instrument Skill
            ---@field wind integer Wind Instrument Skill
            ---@field blue integer Blue Magic Skill
            ---@field enmity_increase integer Enmity Increase
            ---@field enmity_decrease integer Enmity Decrease
            ---@field critical_hit_rate integer Critical Hit Rate
            ---@field enemy_critical_hit_rate integer Enemey Critical Hit Rate
            ---@field spell_interruption_rate integer Spell Interruption Rate
            ---@field berserk_recast integer Berserk Recast
            ---@field defender_recast integer Defender Recast
            ---@field warcry_recast integer Warcry Recast
            ---@field aggressor_recast integer Aggressor Recast
            ---@field double_attack_rate integer Double Attack Rate
            ---@field focus_recast integer Focus Recast
            ---@field dodge_recast integer Dodge Recast
            ---@field chakra_recast integer Chakra Recast
            ---@field counter_rate integer Counter Rate
            ---@field kick_attack_rate integer Kick Attack Rate
            ---@field divine_seal_recast integer Divine Seal Recast
            ---@field cure_cast_time integer Cure Cast Time
            ---@field bar_spell_effect integer Bar Spell Effect
            ---@field banish_effect integer Banish Effect
            ---@field regen_effect integer Regen Effect
            ---@field elemental_seal_recast integer Elemental Seal Recast
            ---@field fire_magic_potency integer Fire Magic Potency
            ---@field ice_magic_potency integer Ice Magic Potency
            ---@field wind_magic_potency integer Wind Magic Potency
            ---@field earth_magic_potency integer Earth Magic Potency
            ---@field lightning_magic_potency integer Lightning Magic Potency
            ---@field water_magic_potency integer Water Magic Potency
            ---@field convert_recast integer Convert Recast
            ---@field fire_magic_accuracy integer Fire Magic Accuracy
            ---@field ice_magic_accuracy integer Ice Magic Accuracy
            ---@field wind_magic_accuracy integer Wind Magic Accuracy
            ---@field earth_magic_accuracy integer Earth Magic Accuracy
            ---@field lightning_magic_accuracy integer Lightning Magic Accuracy
            ---@field water_magic_accuracy integer Water Magic Accuracy
            ---@field flee_recast integer Flee Recast
            ---@field hide_recast integer Hide Recast
            ---@field sneak_attack_recast integer Sneak Attack Recast
            ---@field trick_attack_recast integer Trick Attack Recast
            ---@field triple_attack_rate integer Triple Attack Rate
            ---@field shield_bash_recast integer Shield Bash Recast
            ---@field holy_circle_recast integer Holy Circle Recast
            ---@field sentinel_recast integer Sentinel Recast
            ---@field cover_effect_length integer Cover Effect Length
            ---@field rampart_recast integer Rampart Recast
            ---@field souleater_recast integer Souleater Recast
            ---@field arcane_circle_recast integer Arcane Circle Recast
            ---@field last_resort_recast integer Last Resort Recast
            ---@field last_resort_effect integer Last Resort Effect
            ---@field weapon_bash_effect integer Weapon Bash Effect
            ---@field killer_effects integer Killer Effects
            ---@field reward_recast integer Reward Recast
            ---@field call_beast_recast integer Call Beast Recast
            ---@field sic_recast integer Sic Recast
            ---@field tame_recast integer Tame Recast
            ---@field lullaby_recast integer Lullaby Recast
            ---@field finale_recast integer Finale Recast
            ---@field minne_effect integer Minne Effect
            ---@field minuet_effect integer Minuet Effect
            ---@field madrigal_effect integer Madrigal Effect
            ---@field scavenge_effect integer Scavenge Effect
            ---@field camouflage_recast integer Camouflage Recast
            ---@field sharpshot_recast integer Sharpshot Recast
            ---@field unlimited_shot_recast integer Unlimited Shot Recast
            ---@field rapid_shot_rate integer Rapid Shot Rate
            ---@field third_eye_recast integer Third Eye Recast
            ---@field warding_circle_recast integer Warding Circle Recast
            ---@field store_tp_effect integer Store TP Effect
            ---@field meditate_recast integer Meditate Recast
            ---@field zanshin_attack_rate integer Zanshin Attack Rate
            ---@field subtle_blow_effect integer Subtle Blow Effect
            ---@field katon_effect integer Katon Effect
            ---@field hyoton_effect integer Hyoton Effect
            ---@field huton_effect integer Huton Effect
            ---@field doton_effect integer Doton Effect
            ---@field raiton_effect integer Raiton Effect
            ---@field suiton_effect integer Suiton Effect
            ---@field ancient_circle_recast integer Ancient Circle Recast
            ---@field jump_recast integer Jump Recast
            ---@field high_jump_recast integer High Jump Recast
            ---@field super_jump_recast integer Super Jump Recast
            ---@field spirit_link_recast integer Spirit Link Recast
            ---@field avatar_physical_accuracy integer Avatar Physical Accuracy
            ---@field avatar_physical_attack integer Avatar Physical Attack
            ---@field avatar_magical_accuracy integer Avatar Magical Accuracy
            ---@field avatar_magical_attack integer Avatar Magical Attack
            ---@field summoning_magic_cast_time integer Summoning Magic Cast Time
            ---@field chain_affinity_recast integer Chain Affinity Recast
            ---@field burst_affinity_recast integer Burst Affinity Recast
            ---@field monster_correlation integer Monster Correlation
            ---@field physical_accuracy integer Physical Potency
            ---@field magical_accuracy integer  Magical Accuracy
            ---@field phantom_roll_recast integer Phantom Roll Recast
            ---@field quick_draw_recast integer Quick Draw Recast
            ---@field quick_draw_accuracy integer Quick Draw Accuracy
            ---@field random_deal_recast integer Random Deal Recast
            ---@field bust_duration integer Bust Duration
            ---@field automaton_melee_skill integer Automaton Melee Skill
            ---@field automaton_ranged_skill integer Automaton Ranged Skill
            ---@field automaton_magic_skill integer Automaton Magic Skill
            ---@field activate_recast integer Activate Recast
            ---@field repair_recast integer Repair Recast
            ---@field step_accuracy integer Step Accuracy
            ---@field haste_samba_effect integer Haste Samba Effect
            ---@field reverse_flourish_effect integer Reverse Flourish Effect
            ---@field building_flourish_effect integer Building Flourish Effect
            ---@field grimoire_recast integer Grimoire Recast
            ---@field modus_veritas_duration integer Modus Veritas Duration
            ---@field helix_magic_attack integer Helix Magic Acc Att
            ---@field max_sublimation integer Max Sublimation
            ---@field shijin_spiral integer Shijin Spiral
            ---@field exenterator integer Exenterator
            ---@field requiescat integer Requiescat
            ---@field resolution integer Resolution
            ---@field ruinator integer Ruinator
            ---@field upheaval integer Upheaval
            ---@field entropy integer Entropy
            ---@field stardiver integer Stardiver
            ---@field blade_shun integer Blade: Shun
            ---@field tachi_shoha integer Tachi: Shoha
            ---@field realmrazer integer Realmrazer
            ---@field shattersoul integer Shattersoul
            ---@field apex_arrow integer Apex Arrow
            ---@field last_stand integer Last Stand
            ---@field warriors_charge integer Warriors Charge
            ---@field tomahawk integer Tomahawk
            ---@field savagery integer Savagery
            ---@field aggressive_aim integer Aggressive Aim
            ---@field mantra integer Mantra
            ---@field formless_strikes integer Formless Strikes
            ---@field invigorate integer Invigorate
            ---@field penance integer Penance
            ---@field martyr integer Martyr
            ---@field devotion integer Devotion
            ---@field animus_solace_effect integer Animus Solace Effect
            ---@field animus_misery_effect integer Animus Misery Effect
            ---@field ancient_magic_magic_attack_bonus integer Ancient Magic Magic Attack Bonus
            ---@field ancient_magic_magic_burst_damage integer Ancient Magic Magic Burst Damage
            ---@field elemental_magic_magic_accuracy integer Elemental Magic Magic Accuracy
            ---@field elemental_magic_debuff_duration integer Elemental Magic Debuff Duration
            ---@field elemental_magic_debuff_effect integer Elemental Magic Debuff Effect
            ---@field aspir_absorption_amount integer Aspir Absorption Amount
            ---@field enfeebling_magic_duration integer Enfeebling Magic Duration
            ---@field magic_accuracy integer  Magic Accuracy
            ---@field enhancing_magic_duration integer Enhancing Magic Duration
            ---@field immunobreak_chance integer Immunobreak Chance
            ---@field enspell_damage integer Enspell Damage
            ---@field accuracy integer  Accuracy
            ---@field assassins_charge integer Assassins Charge
            ---@field feint integer Feint
            ---@field aura_steal integer Aura Steal
            ---@field ambush integer Ambush
            ---@field fealty integer Fealty
            ---@field chivalry integer Chivalry
            ---@field iron_will integer Iron Will
            ---@field guardian integer Guardian
            ---@field dark_seal integer Dark Seal
            ---@field diabolic_eye integer Diabolic Eye
            ---@field muted_soul integer Muted Soul
            ---@field desperate_blows integer Desperate Blows
            ---@field feral_howl integer Feral Howl
            ---@field killer_instinct integer Killer Instinct
            ---@field beast_affinity integer Beast Affinity
            ---@field beast_healer integer Beast Healer
            ---@field nightingale integer Nightingale
            ---@field troubadour integer Troubadour
            ---@field con_anima integer Con Anima
            ---@field cont_brio integer Con Brio
            ---@field stealth_shot integer Stealth Shot
            ---@field flashy_shot integer Flashy Shot
            ---@field snapshot integer Snapshot
            ---@field recycle integer Recycle
            ---@field shikikoyo integer Shikikoyo
            ---@field blade_bash integer Blade Bash
            ---@field ikishoten integer Ikishoten
            ---@field overwhelm integer Overwhelm
            ---@field sange integer Sange
            ---@field ninja_tool_expertise integer Ninja Tool Expertise
            ---@field yonin_effect integer Yonin Effect
            ---@field innin_effect integer Innin Effect
            ---@field ninjutsu_magic_accuracy integer Ninjutsu Magic Accuracy
            ---@field ninjutsu_magic_attack_bonus integer Ninjutsu Magic Attack Bonus
            ---@field deep_breathing integer Deep Breathing
            ---@field angon integer Angon
            ---@field empathy integer Empathy
            ---@field strafe integer Strafe
            ---@field meteor_strike integer Meteor Strike
            ---@field heavenly_strike integer Heavenly Strike
            ---@field wind_blade integer Wind Blade
            ---@field geocrush integer Geocrush
            ---@field thunderstorm integer Thunderstorm
            ---@field grand_fall integer Grand Fall
            ---@field convergence integer Convergence
            ---@field diffusion integer Diffusion
            ---@field enchainment integer Enchainment
            ---@field assimilation integer Assimilation
            ---@field snake_eye integer Snake Eye
            ---@field fold integer Fold
            ---@field winning_streak integer Winning Streak
            ---@field loaded_deck integer Loaded Deck
            ---@field role_reversal integer Role Reversal
            ---@field ventriloquy integer Ventriloquy
            ---@field fine_tuning integer Fine Tuning
            ---@field optimization integer Optimization
            ---@field saber_dance integer Saber Dance
            ---@field fan_dance integer Fan Dance
            ---@field no_foot_rise integer No Foot Rise
            ---@field closed_position integer Closed Position
            ---@field altruism integer Altruism
            ---@field focalization integer Focalization
            ---@field tranquility integer Tranquility
            ---@field equanimity integer Equanimity
            ---@field enlightenment integer Enlightenment
            ---@field stormsurge integer Stormsurge
            ---@field full_circle_effect integer Full Circle Effect
            ---@field ecliptic_attrition_effect integer Ecliptic Attrition Recast
            ---@field blaze_of_glory_recast integer Blaze Of Glory Recast
            ---@field dematerialize_recast integer Dematerialize Recast
            ---@field mending_hallation integer Mending Halation
            ---@field radial_arcana integer Radial Arcana
            ---@field curative_recantation integer Curative Recantation
            ---@field primeval_zeal integer Primeval Zeal
            ---@field rune_enchantment_effect integer Rune Enchantment Effect
            ---@field vallation_effect integer Vallation Effect
            ---@field lunge_effect integer Lunge Effect
            ---@field pflug_effect integer Pflug Effect
            ---@field gambit_recast integer Gambit Recast
            ---@field battuta integer Battuta
            ---@field rayke integer Rayke
            ---@field inspiration integer Inspiration
            ---@field sleight_of_sword integer Sleight Of Sword
            merits = {},

            ---@class windower.ffxi.player.job_points
            job_points = {
                ---@class windower.ffxi.player.job_points.war
                ---@field mighty_strikes_effect integer Mighty Strikes Effect
                ---@field berserk_effect integer Berserk Effect
                ---@field brazen_rush_effect integer Brazen Rush Effect
                ---@field defender_effect integer Defender Effect
                ---@field warcry_effect integer Warcry Effect
                ---@field aggressor_effect integer Aggressor Effect
                ---@field retaliation_effect integer Retaliation Effect
                ---@field restraint_effect integer Restraint Effect
                ---@field blood_rage_effect integer Blood Rage Effect
                ---@field double_attack_effect integer Double Attack Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                war = {},

                ---@class windower.ffxi.player.job_points.mnk
                ---@field hundred_fists_effect integer Hundred Fists Effect
                ---@field dodge_effect integer Dodge Effect
                ---@field inner_strength_effect integer Inner Strength Effect
                ---@field focus_effect integer Focus Effect
                ---@field chakra_effect integer Chakra Effect
                ---@field counterstance_effect integer Counterstance Effect
                ---@field footwork_effect integer Footwork Effect
                ---@field perfect_counter_effect integer Perfect Counter Effect
                ---@field impetus_effect integer Impetus Effect
                ---@field kick_attack_effect integer Kick Attacks Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                mnk = {},

                ---@class windower.ffxi.player.job_points.whm
                ---@field benediction_effect integer Benediction Effect
                ---@field divine_seal_effect integer Divine Seal Effect
                ---@field asylum_effect integer Asylum Effect
                ---@field magic_accuracy_bonus integer Magic Accuracy Bonus
                ---@field afflatus_solace_effect integer Afflatus Solace Effect
                ---@field afflatus_misery_effect integer Afflatus Misery Effect
                ---@field divine_caress_duration integer Divine Caress Duration
                ---@field sacrosanctity_effect integer Sacrosanctity Effect
                ---@field regen_duration integer Regen Duration
                ---@field bar_spell_effect integer Bar Spell Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                whm = {},

                ---@class windower.ffxi.player.job_points.blm
                ---@field manafont_effect integer Manafont Effect
                ---@field elemental_seal_effect integer Elemental Seal Effect
                ---@field subtle_sorcery_effect integer Subtle Sorcery Effect
                ---@field magic_burst_damage_bonus integer Magic Burst Damage Bonus
                ---@field mana_wall_effect integer Manawall Effect
                ---@field magic_accuracy_bonus integer Magic Accuracy Bonus
                ---@field enmity_douse_recast integer Enmity Douse Recast
                ---@field manawell_effect integer Manawell Effect
                ---@field magic_burst_enmity_decrease integer Magic Burst Enmity Decrease
                ---@field magic_damage_bonus integer Magic Damage Bonus
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                blm = {},

                ---@class windower.ffxi.player.job_points.rdm
                ---@field chainspell_effect integer Chainspell Effect
                ---@field convert_effect integer Convert Effect
                ---@field stymie_effect integer Stymie Effect
                ---@field magic_accuracy_bonus integer Magic Accuracy Bonus
                ---@field composure_effect integer Composure Effect
                ---@field magic_attack_bonus integer Magic Attack Bonus
                ---@field saboteur_effect integer Saboteur Effect
                ---@field enfeebling_magic_duration integer Enfeebling Magic Duration
                ---@field quick_magic_effect integer Quick Magic Effect
                ---@field enhancing_magic_duration integer Enhancing Magic Duration
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                rdm = {},

                ---@class windower.ffxi.player.job_points.thf
                ---@field perfect_dodge_effect integer Perfect Dodge Effect
                ---@field sneak_attack_effect integer Sneak Attack Effect
                ---@field larceny_duration integer Larceny Duration
                ---@field trick_attack_effect integer Trick Attack Effect
                ---@field steal_recast integer Steal Recast
                ---@field mug_effect integer Mug Effect
                ---@field despoil_effect integer Despoil Effect
                ---@field conspirator_effect integer Conspirator Effect
                ---@field bully_effect integer Bully Effect
                ---@field triple_attack_effect integer Triple Attack Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                thf = {},

                ---@class windower.ffxi.player.job_points.pld
                ---@field invincible_effect integer Invincible Effect
                ---@field holy_circle_effect integer Holy Circle Effect
                ---@field intervene_effect integer Intervene Effect
                ---@field sentinel_effect integer Sentinel Effect
                ---@field shield_bash_effect integer Shield Bash Effect
                ---@field cover_duration integer Cover Duration
                ---@field divine_emblem_effect integer Divine Emblem Effect
                ---@field sepulcher_duration integer Sepulcher Duration
                ---@field palisade_effect integer Palisade Effect
                ---@field enlight_effect integer Enlight Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                pld = {},

                ---@class windower.ffxi.player.job_points.drk
                ---@field blood_weapon_effect integer Blood Weapon Effect
                ---@field arcane_circle_effect integer Arcane Circle Effect
                ---@field soul_enslavement_effect integer Soul Enslavement Effect
                ---@field last_resort_effect integer Last Resort Effect
                ---@field souleater_duration integer Souleater Duration
                ---@field weapon_bash_effect integer Weapon Bash Effect
                ---@field nether_void_effect integer Nether Void Effect
                ---@field arcane_crest_duration integer Arcane Crest Duration
                ---@field scarlet_delirium_duration integer Scarlet Delirium Duration
                ---@field endark_effect integer Endark Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                drk = {},

                ---@class windower.ffxi.player.job_points.bst
                ---@field familiar_effect integer Familiar Effect
                ---@field pet_accuracy_bonus integer Pet Accuracy Bonus
                ---@field unleash_effect integer Unleash Effect
                ---@field charm_success_rate integer Charm Success Rate
                ---@field reward_effect integer Reward Effect
                ---@field pet_attack_speed integer Pet Attack Speed
                ---@field ready_effect integer Ready Effect
                ---@field spur_effect integer Spur Effect
                ---@field run_wild_duration integer Run Wild Duration
                ---@field pet_enmity integer Pet Enmity
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                bst = {},

                ---@class windower.ffxi.player.job_points.brd
                ---@field soul_voice_effect integer Soul Voice Effect
                ---@field minne_effect integer Minne Effect
                ---@field clarion_call_effect integer Clarion Call Effect
                ---@field minuet_effect integer Minuet Effect
                ---@field pianissimo_effect integer Pianissimo Effect
                ---@field song_accuracy_bonus integer Song Accuracy Bonus
                ---@field tenuto_effect integer Tenuto Effect
                ---@field lullaby_duration integer Lullaby Duration
                ---@field marcato_effect integer Marcato Effect
                ---@field requiem_effect integer Requiem Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                brd = {},

                ---@class windower.ffxi.player.job_points.rng
                ---@field eagle_eye_shot_effect integer Eagle Eye Shot Effect
                ---@field sharpshot_effect integer Sharpshot Effect
                ---@field overkill_effect integer Overkill Effect
                ---@field camouflage_effect integer Camouflage Effect
                ---@field barrage_effect integer Barrage Effect
                ---@field shadowbind_duration integer Shadowbind Duration
                ---@field velocity_shot_effect integer Velocity Shot Effect
                ---@field double_shot_effect integer Double Shot Effect
                ---@field decoy_shot_effect integer Decoy Shot Effect
                ---@field unlimited_shot_effect integer Unlimited Shot Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                rng = {},

                ---@class windower.ffxi.player.job_points.sam
                ---@field meikyo_shisui_effect integer Meikyo Shisui Effect
                ---@field warding_circle_effect integer Warding Circle Effect
                ---@field yaegasumi_effect integer Yaegasumi Effect
                ---@field hasso_effect integer Hasso Effect
                ---@field meditate_effect integer Meditate Effect
                ---@field seigan_effect integer Seigan Effect
                ---@field konzen-ittai_effect integer Konzenittai Effect
                ---@field hamanoha_duration integer Hamanoha Duration
                ---@field hagakure_effect integer Hagakure Effect
                ---@field zanshin_effect integer Zanshin Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                sam = {},

                ---@class windower.ffxi.player.job_points.nin
                ---@field mijin_gakure_effect integer Mijin Gakure Effect
                ---@field yonin_effect integer Yonin Effect
                ---@field mikage_effect integer Mikage Effect
                ---@field innin_effect integer Innin Effect
                ---@field ninjutsu_accuracy_bonus integer Ninjutsu Accuracy Bonus
                ---@field ninjutsu_cast_time integer Ninjutsu Cast Time
                ---@field futae_effect integer Futae Effect
                ---@field elemental_ninjutsu_effect integer Elemental Ninjutsu Effect
                ---@field issekigan_effect integer Issekigan Effect
                ---@field tactical_parry_effect integer Tactical Parry Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                nin = {},

                ---@class windower.ffxi.player.job_points.drg
                ---@field spirit_surge_effect integer Spirit Surge Effect
                ---@field ancient_circle_effect integer Ancient Circle Effect
                ---@field fly_high_effect integer Fly High Effect
                ---@field jump_effect integer Jump Effect
                ---@field spirit_link_effect integer Spirit Link Effect
                ---@field wyvern_max_hp_bonus integer Wyvern Max HPBonus
                ---@field dragon_break_duration integer Dragon Break Duration
                ---@field wyvern_breath_effect integer Wyvern Breath Effect
                ---@field high_jump_effect integer High Jump Effect
                ---@field wyvern_attr_increase_effect integer Wyvern Attr Increase Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                drg = {},

                ---@class windower.ffxi.player.job_points.smn
                ---@field astral_flow_effect integer Astral Flow Effect
                ---@field avatar_spirit_accuracy_bonus integer Avatar Spirit Accuracy Bonus
                ---@field astral_conduit_effect integer Astral Conduit Effect
                ---@field avatar_spirit_magic_accuracy_bonus integer Avatar Spirit Mag Acc Bonus
                ---@field elemental_siphon_effect integer Elemental Siphon Effect
                ---@field avatar_spirit_physical_attack integer Avatar Spirit Physical Attack
                ---@field mana_code_effect integer Mana Code Effect
                ---@field avatars_favor_effect integer Avatars Favor Effect
                ---@field avatar_spirit_mag_damage integer Avatar Spirit Mag Damage
                ---@field blood_pact_damage integer Blood Pact Damage
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                smn = {},

                ---@class windower.ffxi.player.job_points.blu
                ---@field azure_lore_effect integer Azure Lore Effect
                ---@field blue_magic_point_bonus integer Blue Magic Point Bonus
                ---@field unbridled_wisdom_effect integer Unbridled Wisdom Effect
                ---@field burst_affinity_bonus integer Burst Affinity Bonus
                ---@field chain_affinity_effect integer Chain Affinity Effect
                ---@field learning_chance integer Learning Chance
                ---@field unbridled_learning_effect integer Unbridled Learning Effect
                ---@field unbridled_learning_effect_ii integer Unbridled Learning Effect II
                ---@field efflux_effect integer Efflux Effect
                ---@field magic_accuracy_bonus integer Magic Accuracy Bonus
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                blu = {},

                ---@class windower.ffxi.player.job_points.cor
                ---@field wild_card_effect integer Wild Card Effect
                ---@field phantom_roll_duration integer Phantom Roll Duration
                ---@field cut_card_effect integer Cut Card Effect
                ---@field bust_evasion integer Bust Evasion
                ---@field quick_draw_effect integer Quick Draw Effect
                ---@field ammo_consumption integer Ammo Consumption
                ---@field random_deal_effect integer Random Deal Effect
                ---@field ranged_accuracy_bonus integer Ranged Accuracy Bonus
                ---@field triple_shot_effect integer Triple Shot Effect
                ---@field optimal_range_effect integer Optimal Range Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                cor = {},

                ---@class windower.ffxi.player.job_points.pup
                ---@field overdrive_effect integer Overdrive Effect
                ---@field automaton_max_hp_bonus integer Automaton Max HPBonus
                ---@field heady_artifice_effect integer Heady Artifice Effect
                ---@field automaton_max_mp_boost integer Automaton Max MPBoost
                ---@field repair_effect integer Repair Effect
                ---@field deus_ex_automata_recast integer Deus Ex Automata Recast
                ---@field tactical_switch integer Tactical Switch
                ---@field cooldown_effect integer Cooldown Effect
                ---@field deactivate_effect integer Deactivate Effect
                ---@field martial_arts_effect integer Martial Arts Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                pup = {},

                ---@class windower.ffxi.player.job_points.dnc
                ---@field trance_effect integer Trance Effect
                ---@field step_duration integer Step Duration
                ---@field grand_pas_effect integer Grand Pas Effect
                ---@field samba_duration integer Samba Duration
                ---@field waltz_potency integer Waltz Potency
                ---@field jig_duration integer Jig Duration
                ---@field flourish_i_effect integer Flourish IEffect
                ---@field flourish_ii_effect integer Flourish IIEffect
                ---@field flourishes_iii_effect integer Flourishes IIIEffect
                ---@field contradance_effect integer Contradance Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                dnc = {},

                ---@class windower.ffxi.player.job_points.sch
                ---@field tabula_rasa_effect integer Tabula Rasa Effect
                ---@field light_arts_effect integer Light Arts Effect
                ---@field caper_emissarius_effect integer Caper Emissarius Effect
                ---@field dark_arts_effect integer Dark Arts Effect
                ---@field stratagem_effect_i integer Stratagem Effect I
                ---@field stratagem_effect_ii integer Stratagem Effect II
                ---@field stratagem_effect_iii integer Stratagem Effect III
                ---@field stratagem_effect_iv integer Stratagem Effect IV
                ---@field modus_veritas_effect integer Modus Veritas Effect
                ---@field sublimation_effect integer Sublimation Effect
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                sch = {},

                ---@class windower.ffxi.player.job_points.geo
                ---@field bolster_effect integer Bolster Effect
                ---@field life_cycle_effect integer Life Cycle Effect
                ---@field widened_compass_effect integer Widened Compass Effect
                ---@field blaze_of_glory_effect integer Blazeof Glory Effect
                ---@field magic_attack_bonus integer Magic Attack Bonus
                ---@field magic_accuracy_bonus integer Magic Accuracy Bonus
                ---@field dematerialize_duration integer Dematerialize Duration
                ---@field theurgic_focus_effect integer Theurgic Focus Effect
                ---@field concentric_pulse_effect integer Concentric Pulse Effect
                ---@field indocolure_spell_effect_dur integer Indicolure Spell Effect Dur
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                geo = {},

                ---@class windower.ffxi.player.job_points.run
                ---@field elemental_sforzo_effect integer Elemental Sforzo Effect
                ---@field rune_enchantment_effect integer Rune Enchantment Effect
                ---@field odyllic_subterfuge_effect integer Odyllic Subterfuge Effect
                ---@field vallation_duration integer Vallation Duration
                ---@field swordplay_effect integer Swordplay Effect
                ---@field swipe_effect integer Swipe Effect
                ---@field embolden_effect integer Embolden Effect
                ---@field vivacious_pulse integer Vivacious Pulse
                ---@field one_for_all_effect_duration integer Onefor All Effect Duration
                ---@field gambit_effect_duration integer Gambit Effect Duration
                ---@field cp integer Capacity points.
                ---@field jp integer Job points.
                ---@field jp_spent integer Job points spent.
                run = {},
            },
        },

        ---@class windower.ffxi.info
        ---@field logged_in boolean Whether or not the player is currently logged in, i.e. not on the character selection screen.
        ---@field language "Japanese" | "English" The current client language..
        ---@field server integer | nil The current server ID, if logged in, otherwise `nil`.
        ---@field chat_open boolean | nil Whether or not the chat is currently open, if logged in, otherwise `nil`.
        ---@field menu_open boolean | nil Whether or not any game menu is currently open, if logged in, otherwise `nil`.
        ---@field zone integer The current zone ID as specified in the [zone resources](https://github.com/Windower/Resources/blob/master/resources_data/zones.lua), if logged in, otherwise `0`.
        ---@field time integer The current in-game time in minutes, e.g. 19:44 would be `19 * 60 + 44`, so `1184`.
        ---@field moon integer The current in-game moon percentage, between 0 and 100.
        ---@field moon_phase integer The current in-game moon phase ID as specified in the [moon phase resources](https://github.com/Windower/Resources/blob/master/resources_data/moon_phases.lua).
        ---@field day integer The current in-game week day ID as specified in the [day resources](https://github.com/Windower/Resources/blob/master/resources_data/days.lua).
        ---@field weather integer The current in-game weather ID as specified in the [weather resources](https://github.com/Windower/Resources/blob/master/resources_data/weather.lua).
        ---@field target_arrow target_arrow Information on the current target, if logged in and a target is selected, otherwise `nil`.
        info = {
            ---@class target_arrow
            ---@field x number The X coordinate of the target arrow.
            ---@field y number The Y coordinate of the target arrow.
            ---@field z number The Z coordinate of the target arrow.
            target_arrow = {},
        },

        ---@alias job_short "WAR" | "MNK" | "WHM" | "BLM" | "RDM" | "THF" | "PLD" | "DRK" | "BST" | "BRD" | "RNG" | "SAM" | "NIN" | "DRG" | "SMN" | "BLU" | "COR" | "PUP" | "DNC" | "SCH" | "GEO" | "RUN"
    },

    ---These interface functions allow for the display and manipulation of images.
    ---@class windower.prim
    prim = {
        ---Creates a new primitive.
        ---@param prim_name string Name of the primitive to create (should be unique).
        ---@return nil
        create = function(prim_name) end,

        ---Deletes an existing primitive.
        ---@param prim_name string Name of the primitive to delete.
        ---@return nil
        delete = function(prim_name) end,

        ---Sets the color of a primitive.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param a integer Alpha component (0–255).
        ---@param r integer Red component (0–255).
        ---@param g integer Green component (0–255).
        ---@param b integer Blue component (0–255).
        ---@return nil
        set_color = function(prim_name, a, r, g, b) end,

        ---Sets whether or not to fit the primitive to its texture.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param fit boolean Whether to fit to texture.
        ---@return nil
        set_fit_to_texture = function(prim_name, fit) end,

        ---Sets the position of a primitive.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param x_pos number X position.
        ---@param y_pos number Y position.
        ---@return nil
        set_position = function(prim_name, x_pos, y_pos) end,

        ---Sets the size of a primitive.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param x number Width of the primitive.
        ---@param y number Height of the primitive.
        ---@return nil
        set_size = function(prim_name, x, y) end,

        ---Sets the texture of a primitive.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param texture string Absolute path to the texture file.
        ---@return nil
        set_texture = function(prim_name, texture) end,

        ---Sets the repetition of a primitive's texture.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param x_repeat number Horizontal repetition factor.
        ---@param y_repeat number Vertical repetition factor.
        ---@return nil
        set_repeat = function(prim_name, x_repeat, y_repeat) end,

        ---Sets the visibility of a primitive.
        ---@param prim_name string Name of the primitive to operate on.
        ---@param visible boolean Whether the primitive is visible.
        ---@return nil
        set_visibility = function(prim_name, visible) end,
    },

    ---Basic text object functions. For more advanced functionality (draggable, updatable, persistent properties), see the `texts` library.
    ---@class windower.text
    text = {
        ---Creates a text object.
        ---@param name string Identifier for the text object.
        ---@return nil
        create = function(name) end,

        ---Destroys a text object.
        ---@param name string Identifier for the text object.
        ---@return nil
        delete = function(name) end,

        ---Returns the width and height of the text object.
        ---@param name string Identifier for the text object.
        ---@return number x, number y #Size in pixels.
        get_extents = function(name) end,

        ---Returns the x and y coordinates of the top-left corner.
        ---@param name string Identifier for the text object.
        ---@return number x, number y #Position in pixels.
        get_location = function(name) end,

        ---Sets the background border size in pixels.
        ---@param name string Identifier for the text object.
        ---@param px integer Border size in pixels.
        ---@return nil
        set_bg_border_size = function(name, px) end,

        ---Sets the background color.
        ---@param name string Identifier for the text object.
        ---@param alpha integer Alpha value (0–255).
        ---@param red integer Red value (0–255).
        ---@param green integer Green value (0–255).
        ---@param blue integer Blue value (0–255).
        ---@return nil
        set_bg_color = function(name, alpha, red, green, blue) end,

        ---Toggles background visibility.
        ---@param name string Identifier for the text object.
        ---@param visible boolean Whether the background is visible.
        ---@return nil
        set_bg_visibility = function(name, visible) end,

        ---Enables or disables bold font.
        ---@param name string Identifier for the text object.
        ---@param bold boolean `true` for bold, `false` for normal.
        ---@return nil
        set_bold = function(name, bold) end,

        ---Sets the font color.
        ---@param name string Identifier for the text object.
        ---@param alpha integer Alpha value (0–255).
        ---@param red integer Red value (0–255).
        ---@param green integer Green value (0–255).
        ---@param blue integer Blue value (0–255).
        ---@return nil
        set_color = function(name, alpha, red, green, blue) end,

        ---Sets the font. Accepts multiple fonts as fallbacks if the previous is not installed
        ---@param name string Identifier for the text object.
        ---@param ... string Font names in order of preference.
        ---@return nil
        set_font = function(name, ...) end,

        ---Sets the font size.
        ---@param name string Identifier for the text object.
        ---@param size integer Font size in points.
        ---@return nil
        set_font_size = function(name, size) end,

        ---Enables or disables italic font style.
        ---@param name string Identifier for the text object.
        ---@param italic boolean `true` to enable and `false` to disable italic style.
        ---@return nil
        set_italic = function(name, italic) end,

        ---Moves the text object to the specified coordinates.
        ---@param name string Identifier for the text object.
        ---@param x integer X position in pixels.
        ---@param y integer Y position in pixels.
        ---@return nil
        set_location = function(name, x, y) end,

        ---Enables or disables right justification.
        ---@param name string Identifier for the text object.
        ---@param justified boolean `true` for right-justified, `false` for left.
        ---@return nil
        set_right_justified = function(name, justified) end,

        ---Sets the outline stroke color.
        ---@param name string Identifier for the text object.
        ---@param alpha integer Alpha value (0–255).
        ---@param red integer Red value (0–255).
        ---@param green integer Green value (0–255).
        ---@param blue integer Blue value (0–255).
        ---@return nil
        set_stroke_color = function(name, alpha, red, green, blue) end,

        ---Sets the outline stroke width in pixels.
        ---@param name string Identifier for the text object.
        ---@param width number Stroke width in pixels.
        ---@return nil
        set_stroke_width = function(name, width) end,

        ---Sets the displayed text.
        ---@param name string Identifier for the text object.
        ---@param text string The content to display.
        ---@return nil
        set_text = function(name, text) end,

        ---Toggles text object visibility.
        ---@param name string Identifier for the text object.
        ---@param visible boolean Whether the text is visible.
        ---@return nil
        set_visibility = function(name, visible) end,
    },

    ---Functions to manipulate the in-game chatbox.
    ---@class windower.chat
    chat = {
        ---Inserts text into the current chat input at a given position. If `position` is not specified it will add it at the current cursor position.
        ---@param text string The text to add to the input.
        ---@param position? number Cursor position to insert at.
        ---@return nil
        add_to_input = function(text, position) end,

        ---Retrieves the current chat input and cursor position.
        ---This will contain encoded auto-translate phrases.
        ---@return string text, number position #Current input and cursor position.
        get_input = function() end,

        ---Submits text as if typed and sent in chat.
        ---@param text string The text to input.
        ---@return nil
        input = function(text) end,

        ---Checks if the chat box is currently open.
        ---@return boolean #`true` if open, `false` otherwise.
        is_open = function() end,

        ---Pastes the clipboard contents into the chat input.
        ---@return nil
        paste = function() end,

        ---Replaces the current chat input and moves the cursor. The cursor is set to the provided value, or, if omitted, at the end of the new input text.
        ---@param text string The new input text.
        ---@param position [number] Optional new cursor position (defaults to end).
        ---@return nil
        set_input = function(text, position) end,
    },

    ---Functions to manipulate the Windower console.
    ---@class windower.console
    console = {
        ---Erases all text currently in the Windower console.
        ---@return nil
        clear = function() end,

        ---Closes the Windower console (same as pressing the console key).
        ---@return nil
        close = function() end,

        ---Opens the Windower console (same as pressing the console key).
        ---@return nil
        open = function() end,

        ---Moves the Windower console to the specified position.
        ---@param x number Horizontal position in pixels.
        ---@param y number Vertical position in pixels.
        ---@return nil
        set_position = function(x, y) end,

        ---Returns whether the console is currently open.
        ---@return boolean #`true` if visible, `false` otherwise.
        visible = function() end,

        ---Writes a string to the Windower console.
        ---@param text string The text to write.
        ---@return nil
        write = function(text) end,
    },

    ---Extended regular expression functions.
    ---@class windower.regex
    regex = {
        ---Searches a string for a pattern using full regex support.
        ---@param str string The string to search.
        ---@param pattern string The regular expression pattern.
        ---@return table? #Table of matches and capture groups, or nil if no match.
        match = function(str, pattern) end,

        ---Replaces all occurrences of a pattern in a string.
        ---@param str string The string to search.
        ---@param pattern string The regular expression pattern.
        ---@param replace string|table|function If string, the replacement text. If table, a lookup table keyed by match. If function, receives the match and returns replacement.
        ---@return string #The resulting string after replacements.
        replace = function(str, pattern, replace) end,

        ---Splits a string on a regex pattern.
        ---@param str string The string to split.
        ---@param pattern string The regular expression pattern.
        ---@return string[] #List of substrings.
        split = function(str, pattern) end,
    },

    ---@class windower.windower_settings
    ---@field profile_name string Name of the selected Windower profile.
    ---@field branch "stable" | "dev" Name of the current branch of the Windower installation.
    ---@field ffxi_version string FFXI version.
    ---@field launcher_version string Windower launcher version.
    ---@field hook_version string Windower hook version.
    ---@field x_res integer Horizontal rendering resolution.
    ---@field y_res integer Vertical rendering resolution.
    ---@field ui_x_res integer Horizontal user interface resolution.
    ---@field ui_y_res integer Vertical user interface resolution.
    ---@field window_x_pos integer Horizontal window position.
    ---@field window_y_pos integer Vertical window position.
    windower_settings = {},

    ---@class windower.camera
    ---@field matrix number[][] View matrix of the camera, a two-dimensional four-by-four 1-indexed array.
    ---@field matrix_inverse number[][] Inverse of the view matrix of the camera, a two-dimensional four-by-four 1-indexed array.
    ---@field projection_matrix number[][] Projection matrix of the camera, a two-dimensional four-by-four 1-indexed array.
    ---@field x number X position in world-space.
    ---@field y number Y position in world-space.
    ---@field z number Z position in world-space.
    ---@field orientation_x number X orientation in world-space.
    ---@field orientation_y number Y orientation in world-space.
    ---@field orientation_z number Z orientation in world-space.
    ---@field orientation_w number W orientation in world-space.
    ---@field aspect number Aspect ratio.
    ---@field fov_v number Vertical field of view.
    ---@field fov_h number Horizontal field of view.
    ---@field valid boolean Whether or not the data is valid (valid signatures and non-zero view matrix determinant).
    camera = {},

    ---@class windower.item_display
    ---@field id integer The item ID, as specified in the [items resources](https://github.com/Windower/Resources/blob/master/resources_data/items.lua).
    ---@field bag integer | nil The bag ID, as specified in the [bags resources](https://github.com/Windower/Resources/blob/master/resources_data/bags.lua), if the item is owned by the player, otherwise `nil`.
    ---@field index integer | nil The index within a bag, if the item is owned by the player, otherwise `nil`.
    ---@field signature string | nil The signature on the item, if the item is signed, otherwise `nil`.
    ---@field augment string | nil The augment data as a binary string, if the item is augmented, otherwise `nil`.
    item_display = {},
}
