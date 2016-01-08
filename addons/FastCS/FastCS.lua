_addon.name = "FastCS"
_addon.author = "Cairthenn"
_addon.version = "1.1"
_addon.commands = {"FastCS","FCS"}

--Requires:

require("luau")

-- Settings:

defaults = {}
defaults.frame_rate_divisor = 2
defaults.exclusions = S{"home point #1", "home point #2", "home point #3", "home point #4", "home point #5", "survival guide", "waypoint"}
settings = config.load(defaults)


-- Help text definition:

helptext = [[FastCS - Command List:
1. help - Displays this help menu.
2a. fps [30|60|uncapped]
2b. frameratedivisor [2|1|0]
	- Changes the default FPS after exiting a cutscene.
	- The prefix can be used interchangeably. For example, "fastcs fps 2" will set the default to 30 FPS.
3. exclusion [add|remove] <name>
    - Adds or removes a target from the exclusions list. Case insensitive.
 ]]
 

windower.register_event("status change", function(new,old)
    local fps_divisor = settings.frame_rate_divisor or 2
    local target = windower.ffxi.get_mob_by_target('t')
    
    if not target or target and not settings.exclusions:contains(target.name:lower()) then
    
        if new == 4 then
            windower.send_command("config FrameRateDivisor 0")
        elseif old == 4 then
            windower.send_command("config FrameRateDivisor ".. fps_divisor)
        end

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
    elseif command == "exclusion" then
        if #args == 2 then
            if args[1] == "add" then
                settings.exclusions:add(args[2]:lower())
                notice(args[2] .. " added to the exclusions list.")
            elseif args[1] == "remove" then
                settings.exclusions:remove(args[2]:lower())
                notice(args[2] .. " removed from the exclusions list.")
            else
                error("The command syntax was invalid.")
            end
        else
            error("The command syntax was invalid.")
        end
    else
        error("The command syntax was invalid.")
    end
end)
