---@meta

---@class windower
---@field pol_path string Absolute path to the POL installation directory.
---@field ffxi_path string Absolute path to the FFXI installation directory.
---@field windower_path string Absolute path to the running Windower instance directory.
---@field addon_path string Absolute path to the current addon directory.
windower = {
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
