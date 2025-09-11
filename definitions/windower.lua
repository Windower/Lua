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

    ---Creates the final directory in the path.
    ---Will error if a middle directory does not exist.
    ---@param path string The path to the folder.
    ---@return boolean, string|nil #Status and error message.
    create_dir = function(path) end,

    ---Removes all auto-translate formatting, if present, from the input string.
    ---@param str string Input string optionally containing auto-translated blocks.
    ---@return string Input string with auto translate blocks replace with plain text equivalents.
    convert_auto_trans = function(str) end,

    ---Copies the provided string to the clipboard.
    ---@param str string String to copy.
    ---@return nil
    copy_to_clipboard = function(str) end,

    ---Prints all arguments to the debug log, prepended by thread ID and addon name.
    ---@param ... any Any number/type of arguments to be printed.
    ---@return nil
    debug = function(...) end,

    ---Checks if the path is a valid directory.
    ---@param path string The path to the folder.
    ---@return boolean #True if directory exists.
    dir_exists = function(path) end,

    ---Executes a file on the system. Activity remains on the current window.
    ---@param file string The path to the file.
    ---@param arguments table List of arguments to pass.
    ---@return nil
    execute = function(file, arguments) end,

    ---Checks if the path is a valid file address.
    ---@param path string The path to the file.
    ---@return boolean #True if the provided path exists.
    file_exists = function(path) end,

    ---Takes a string and replaces all occurrences of %-variables (%area, %target, etc.).
    ---@param str string Input string optionally containing `%`-variables.
    ---@return string #Formatted string.
    format_variables = function(str) end,

    ---Converts a Shift_JIS (FFXI flavor) string to UTF-8.
    ---@param str string The string to convert.
    ---@return string #UTF-8 string.
    from_shift_jis = function(str) end,

    ---Returns a table of files and directories within one directory.
    ---@param path string The path to the directory.
    ---@return table #List of file/directory names.
    get_dir = function(path) end,

    ---Returns the contents of the clipboard, or nil.
    ---@return string|nil #Clipboard contents.
    get_from_clipboard = function() end,

    ---Returns the currently set in-game chat filters.
    ---@return table #Chat filter settings.
    get_chat_filters = function() end,

    ---Returns a table of the user's Windower settings.
    ---@return windower_settings
    get_windower_settings = function() end,

    ---Plays a sound file. Only .wav is supported.
    ---@param path string The path to the file.
    ---@return nil
    play_sound = function(path) end,

    ---Registers a function to run on the provided event.
    ---@param ... any Any number of event names, followed by a function to execute.
    ---@return integer ... Handles to registered functions.
    register_event = function(...) end,

    ---Executes a Windower command.
    ---@param command string Command to execute. Separate multiple commands with ';'.
    ---@return nil
    send_command = function(command) end,

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
    ---@return string #Shift_JIS formatted string.
    to_shift_jis = function(str) end,

    ---Unregisters a previously registered event handler.
    ---@param ... integer IDs of the event handlers to unregister.
    ---@return nil
    unregister_event = function(...) end,

    ---This function opens a URL in the default browser.
    ---@param url string - URL to open.
    open_url = function(url) end,

    ---Searches str for pattern. Allowed tokens:
    ---* \? matches any one character;
    ---* \* matches arbitrary many characters;
    ---* \| alternation, matches either the left of it or the right of it
    ---@param str string Input string to match
    ---@param pattern string Pattern to match against
    ---@return boolean #True if str matches pattern
    wc_match = function(str, pattern) end,

    ---Returns true if the Windower instance has focus.
    ---@return boolean #Whether the instance has focus.
    has_focus = function() end,

    ---Takes focus from any application (does nothing if already focused).
    ---@return nil
    take_focus = function() end,

    ---FFXI in-game related functions.
    ---@class windower.ffxi
    ffxi = {
        ---Returns information about the current player.
        ---@return player | nil #The current player information, or `nil`, if not logged in.
        get_player = function() end,

        ---Returns information about the current game state.
        ---@return info #The current game state information.
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

        ---Toggles fitting the primitive to its texture.
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

        ---Sets the repetition of a primitive’s texture.
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
}

---@class player
---@field name string The current player's name.
---@field main_job string The current player's main job (three-letter abbreviation, e.g. `WAR`).
---@field sub_job string The current player's sub (three-letter abbreviation, e.g. `WAR`).
local player = {}

---@class info
---@field logged_in boolean Whether or not the player is currently logged in, i.e. not on the character selection screen.
---@field chat_open boolean Whether or not the chat is currently open.
local info = {}

---@class windower_settings
---@field x_res integer game x resolution.
---@field y_res integer game y resolution.
---@field ui_x_res integer user interface x resolution.
---@field ui_y_res integer user interface y resolution.
---@field launcher_version number windower launcher version.
---@field window_x_pos integer window x position.
---@field window_y_pos integer window y position.
local windower_settings = {}
