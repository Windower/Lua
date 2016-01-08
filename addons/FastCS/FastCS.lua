_addon.name = "FastCS"
_addon.author = "Cairthenn"
_addon.version = "1.0"
_addon.commands = {"FastCS","FCS"}

helptext = [[FastCS - Command List:
1. help - Displays this help menu.
2a. fps [30|60|uncapped]
2b. frameratedivisor [2|1|0]
	- Changes the default FPS after exiting a cutscene.
	- The prefix can be used interchangeably. For example, "fastcs fps 2" will set the default to 30 FPS.

 ]]

require("luau")

defaults = {}
defaults.frame_rate_divisor = 2

settings = config.load(defaults)

windower.register_event("status change", function(new,old)
    local fps_divisor = settings.frame_rate_divisor or 2
    
    if new == 4 then
        windower.send_command("config FrameRateDivisor 0")
    else
        windower.send_command("config FrameRateDivisor ".. fps_divisor)
    end

end)

windower.register_event("addon command", function (command,...)
    command = command and command:lower() or "help"
    local args = T{...}:map(string.lower)
    
    if command == "help" then
        print(helptext)
    elseif command == "fps" or command == "frameratedivisor" then
        if #args == 0 then
            settings.frame_rate_divisor = (settings.frame_rate_divisor + 1) % 3
            local help_message = (settings.frame_rate_divisor == 0) and "Uncapped" or (settings.frame_rate_divisor == 1) and "60 FPS" or (settings.frame_rate_divisor == 2) and "30 FPS"
            notice("Default frame rate divisor is now: " .. settings.frame_rate_divisor .. " (" .. help_message .. ")" )
        elseif #args == 1 then
            if args[1] == "60" or args[1] == "1" then
                settings.frame_rate_divisor = 1
            elseif args[1] == "30" or args[1] == "2" then
                settings.frame_rate_divisor = 2
            elseif args[1] == "uncapped" or args[1] == "0" then
                settings.frame_rate_divisor = 0
            end
            local help_message = (settings.frame_rate_divisor == 0) and "Uncapped" or (settings.frame_rate_divisor == 1) and "60 FPS" or (settings.frame_rate_divisor == 2) and "30 FPS"
            notice("Default frame rate divisor is now: " .. settings.frame_rate_divisor .. " (" .. help_message .. ")" )
        else
            error("The command syntax was invalid.")
        end
        settings:save()
    else
        error("The command syntax was invalid.")
    end
end)
