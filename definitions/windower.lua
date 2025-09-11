---@meta

---@class windower
---@field pol_path string Absolute path to the POL installation directory.
---@field ffxi_path string Absolute path to the FFXI installation directory.
---@field windower_path string Absolute path to the running Windower instance directory.
---@field addon_path string Absolute path to the current addon directory.
windower = {

    ---Outputs a message to the chatlog.
    ---The chatmode argument roughly corresponds to color.
    ---@param mode integer Chat mode to use.
    ---@param msg string Message to write.
    ---@return nil
    add_to_chat = function(mode, msg) end,

    ---Creates the final directory in the path. Will error if an intermediate directory does not exist.
    ---@param path string The path to the folder.
    ---@return boolean, string|nil #Status and error message.
    create_dir = function(path) end,

    ---Evaluates all auto-translate blocks in a string with the text for the current language of the game.
    ---@param str string Input string.
    ---@return string #Input string with auto-translate blocks replaced with plain text equivalents.
    convert_auto_trans = function(str) end,

    ---Copies the provided string to the clipboard.
    ---@param str string String to copy.
    ---@return nil
    copy_to_clipboard = function(str) end,

    ---Prints all arguments to the debug log, prepended by thread ID and addon name.
    ---@param ... any Any number/type of arguments to be printed.
    ---@return nil
    debug = function(...) end,

    ---Checks if a path is a valid directory.
    ---@param path string Absolute path to check.
    ---@return boolean #Whether or not the directory exists.
    dir_exists = function(path) end,

    ---Checks if a path is a valid a file.
    ---@param path string Absolute path to check.
    ---@return boolean #Whether or not the file exists.
    file_exists = function(path) end,

    ---Executes a file on the system. Activity remains on the current window.
    ---@param file string The path to the file.
    ---@param arguments table List of arguments to pass.
    ---@return nil
    execute = function(file, arguments) end,

    ---Converts a Shift_JIS (FFXI flavor) string to UTF-8.
    ---@param str string The string to convert.
    ---@return string #UTF-8 string.
    from_shift_jis = function(str) end,

    ---Returns a table of files and directories within one directory.
    ---@param path string The path to the directory.
    ---@return table #List of file/directory names.
    get_dir = function(path) end,

    ---Returns the contents of the clipboard, or `nil` if the clipboard is empty or contains non-text content.
    ---@return string | nil #Clipboard contents.
    get_from_clipboard = function() end,

    ---Returns the currently set in-game chat filters.
    ---@return table #Chat filter settings.
    get_chat_filters = function() end,

    ---Returns a table of the user's Windower settings.
    ---@return windower.windower_settings
    get_windower_settings = function() end,

    ---Plays a sound file. Only .wav is supported.
    ---@param path string The path to the file.
    ---@return nil
    play_sound = function(path) end,

    ---Executes a Windower command.
    ---@param command string Command to execute. Separate multiple commands with `;` inside the string.
    ---@return nil
    send_command = function(command) end,

    ---Registers a function to run on the provided event.
    ---@param ... any Any number of event names, followed by a function to execute.
    ---@return integer ... Handles to registered functions.
    register_event = function(...) end,

    ---Sends an IPC message to all other Windower instances that have the same addon loaded.
    ---This message is handled by the ipc message event.
    ---@param msg string Message to send.
    ---@return nil
    send_ipc_message = function(msg) end,

    ---Changes the name of a mob. Can cause crashes.
    ---@param id integer ID of the mob.
    ---@param name string New name to set for the mob.
    ---@return nil
    set_mob_name = function(id, name) end,

    ---Converts a UTF-8 string to Shift_JIS (FFXI flavor).
    ---@param str string The string to convert.
    ---@return string #Shift_JIS string.
    to_shift_jis = function(str) end,

    ---Unregisters a previously registered event handler.
    ---@param ... integer IDs of the event handlers to unregister.
    ---@return nil
    unregister_event = function(...) end,

    ---Opens a URL in the default browser.
    ---@param url string URL to open.
    ---@return nil
    open_url = function(url) end,

    ---Checks a string for a pattern match with wildcard support. Allowed tokens:<br>
    ---`?` matches any one character<br>
    ---`*` matches arbitrary many characters<br>
    ---`|` alternation, matches either the left or right side of it
    ---@param str string Input string to match.
    ---@param pattern string Pattern to match against.
    ---@return boolean #Whether or not the string matches the pattern.
    wc_match = function(str, pattern) end,

    ---Checks if the Windower instance has focus.
    ---@return boolean #Whether the instance has focus.
    has_focus = function() end,

    ---Takes focus from any application (does nothing if already focused).
    ---@return nil
    take_focus = function() end,

    ---FFXI in-game related functions.
    ---@class windower.ffxi
    ffxi = {
        ---Returns information about the current player.
        ---@return windower.player | nil #The current player information, or `nil`, if not logged in.
        get_player = function() end,

        ---Returns information about the current game state.
        ---@return windower.info #The current game state information.
        get_info = function() end,
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

	---@class windower.player
	---@field name string The current player's name.
	---@field main_job string The current player's main job (three-letter abbreviation, e.g. `WAR`).
	---@field sub_job string The current player's sub (three-letter abbreviation, e.g. `WAR`).
	player = {},

	---@class windower.info
	---@field logged_in boolean Whether or not the player is currently logged in, i.e. not on the character selection screen.
	---@field language "Japanese" | "English" The current client language..
	---@field server integer | nil The current server ID, if logged in, otherwise `nil`.
	---@field chat_open boolean | nil Whether or not the chat is currently open, if logged in, otherwise `nil`.
	---@field menu_open boolean | nil Whether or not any game menu is currently open, if logged in, otherwise `nil`.
	---@field zone integer The current zone ID as specified in the [zone resources](https://github.com/Windower/Resources/blob/master/resources_data/zones.lua), if logged in, `0` otherwise.
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

	---@class windower.windower_settings
	---@field profile_name string Name of the selected Windower profile.
	---@field branch string Name of the current branch of the Windower installation (stable or dev).
	---@field ffxi_version string FFXI version.
	---@field launcher_version string Windower launcher version.
	---@field hook_version string Windower hook version.
	---@field x_res integer Horizontal rendering resolution.
	---@field y_res integer Vertical rendering resolution.
	---@field ui_x_res integer Horizontal user interface resolution.
	---@field ui_y_res integer Vertical user interface resolution.
	---@field window_x_pos integer Horizontal window position.
	---@field window_y_pos integer Vertical window position.
	windower_settings = {}
}
