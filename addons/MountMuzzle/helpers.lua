--[[
Copyright © 2018, Sjshovan (Apogee)
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of MountMuzzle nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Patrick Finnigan BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

require("constants")

function ucFirst(str)
    return (str:gsub("^%l", string.upper))
end

function buildHelpCommandEntry(command, description)
    local short_name = "mm":color(colors.primary)
    local command = command:color(colors.secondary)
    local sep = "=>":color(colors.primary)
    local description = description:color(colors.info)
    return "%s %s %s %s":format(short_name, command, sep, description)
end

function buildHelpTypeEntry(name, description)
    local name = name:color(colors.secondary)
    local sep = "=>":color(colors.primary)
    local description = description:color(colors.info)
    return "%s %s %s":format(name, sep, description)
end

function buildHelpTitle(context)
    local context = context:color(colors.danger)
    return "%s Help: %s":color(colors.primary):format(_addon.name, context)
end

function buildHelpSeperator(character, count)
    local sep = ''
    for i = 1, count do
        sep = sep .. character
    end
    return sep:color(colors.warn)
end

function buildCommandResponse(message, success)
    local response_template = '%s: %s'
    local response_color = colors.success
    local response_type = 'Success'

    if not success then
        response_type = 'Error'
        response_color = colors.danger
    end
    return response_template:format(response_type:color(response_color), message)
end

function displayResponse(response, color)
    color = color or colors.info
    windower.add_to_chat(color, response)
    windower.console.write(response:strip_colors())
end

