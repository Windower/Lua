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

	---Checks whether or not a file exists.
	---@param path string Absolute file path to check.
	---@return boolean #Whether or not the provided path exists
	file_exists = function(path) end,

	---Executes a Windower command.
	---@param command string Command to execute. Separate multiple commands with ';'.
	---@return nil
	send_command = function(command) end,

	---Registers a function to run on the provided event.
	---@param ... any Any number of event names, followed by a function to execute.
	---@return integer ... Handles to registered functions.
	register_event = function(...) end,


	---This function opens a URL in the default browser. Similar to chatmon, it suffers the same limitation of some incompatibility, particularly with Firefox.
	---@param url string - URL to open.
	open_url = function(url) end,

	---Searches str for pattern. Allowed tokens:
	---	      ? matches any one character;
	---       * matches arbitrary many characters;
	---      \| alternation, matches either the left of it or the right of it
	---@param str string Input string to match
	---@param pattern string Pattern to match against
	---@return boolean #True if str matches pattern
	wc_match = function(str, pattern) end,

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
