--[[
        Copyright © 2021, Lili
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of diagnostics nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Lili BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name = 'diagnostics'
_addon.author = 'Lili'
_addon.version = '1.1.2'
_addon.command = 'diag'

require('logger')

local get_dir = windower.get_dir
local windower_path = windower.windower_path
local ffxi_path = windower.ffxi_path
local pol_path = windower.pol_path

local patterns = { 'd3d8%.dll', 'dxgi%.dll', 'ddraw%.dll', 'd3dimm%.dll', 'd3d9%.dll', '.*%.conf' }

windower.register_event('addon command', function(...)
    local args = S{...}

    if args:contains('help') then
        log('//diag <flags>')
        log('  Available flags: log console copy file help')
        log('  log: prints the output to chatlog (default)')
        log('  console: prints the output to console')
        log('  copy: copies the output to clipboard')
        log('  file: saves the output to file')
        log('  help: prints this message')
        log('  no flags provided: prints output to chatlog')
        return
    end

    local windower_settings = windower.get_windower_settings()

    local report = L{}

    report:append('Windower path: %s':format(windower_path))
    report:append(' Launcher version: %s (%s)':format(windower_settings.launcher_version, windower_settings.branch))
    report:append(' Hook version: %s':format(windower_settings.hook_version))
    report:append('FFXI path: %s':format(ffxi_path))
    report:append(' Client version: %s':format(windower_settings.ffxi_version))

    -- Look for cases of mismatched foldername\addonname.lua
    local addons_path = windower_path .. 'addons\\'
    local addons = get_dir(addons_path)
    for _, name in pairs(addons) do
        if name ~= 'libs' then
            if not windower.file_exists('%s%s\\%s.lua':format(addons_path, name, name)) then
                report:append('Mismatched addon folder: ' .. name)
            end
        end
    end

    -- Look for graphics enhancement dlls and config files
    for i, folder in ipairs({ ffxi_path, pol_path, launcher_path }) do
        local files = get_dir(folder)

        for _, name in pairs(files) do
            local name = name:lower()
            for _, pattern in ipairs(patterns) do
                if name:match(pattern) then
                    report:append('%s found in %s':format(name, folder))
                end
            end
        end
    end

    local msg = report:concat('\n')

    if args:contains('copy') then
        windower.copy_to_clipboard('```\n' .. msg .. '\n```')
        log('Output copied to clipboard.')
    end

    if args:contains('file') then
        local outputfile = 'debug' .. os.date(' %Y-%m-%d %H-%M-%S')
        flog(outputfile, '\n' .. msg)
        log('Output saved to', outputfile)
    end

    if args:contains('console') or (args:contains('log') and not windower.ffxi.get_info().logged_in) then
        print(msg)
    end

    if args:contains('log') or args:length() == 0 then
        log(msg)
    end
end)
