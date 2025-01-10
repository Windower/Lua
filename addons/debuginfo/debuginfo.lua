_addon.name = 'debuginfo'
_addon.author = 'Lili'
_addon.version = '1'
_addon.command = 'debuginfo'

require('logger')

local       get_dir = windower.get_dir
local windower_path = windower.windower_path
local     ffxi_path = windower.ffxi_path
local      pol_path = windower.pol_path
-- local launcher_path = windower.launcher_path 

local dlls = { 'd3d8.dll', 'dxgi.dll', 'ddraw.dll', 'd3dimm.dll', 'd3d9.dll', '.*%.conf' }

windower.register_event('addon command',function(arg)
    local arg = arg:lower()

    local windower_settings = windower.get_windower_settings()

    local str = ''

    str = str:append('\nWindower path: ' .. windower_path)
    str = str:append('\n Launcher version: ' .. windower_settings.launcher_version)
    str = str:append('\n Hook version: ' .. windower_settings.hook_version)
    str = str:append('\nFFXI path: ' .. ffxi_path)
    str = str:append('\n Client version: ' .. windower_settings.ffxi_version)

    -- Look for cases of mismatched foldername\addonname.lua
    local addons_path = windower_path .. 'addons\\'
    local addons = get_dir(addons_path)
    for _,name in pairs(addons) do
        if name:endswith('-master') then
            if not windower.file_exists('%s%s\\%s.lua':format(addons_path, name, name)) then
                str = str:append('\nWrong folder name: ' .. name)
            end
        end
    end

    -- Look for graphics enhancement dlls and config files
    for i, folder in pairs({ ffxi_path, pol_path, launcher_path }) do
        local files = get_dir(folder)

        for _, name in pairs(files) do
            for _, pattern in pairs(dlls) do
                local found = name:imatch(pattern)
                if found then
                    str = str:append('\n%s found in %s':format(found, folder))
                end
            end
        end
    end

    log(str)

    if arg == 'copy' or not windower.ffxi.get_info().logged_in then
        windower.copy_to_clipboard(str:enclose('```'))
    end
end)
