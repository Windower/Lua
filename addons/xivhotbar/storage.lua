--[[
        Copyright © 2017, SirEdeonX
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of xivhotbar nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local storage = {}

storage.filename = ''
storage.directory = ''
storage.file = nil

-- setup storage for current player
function storage:setup(player)
    self.filename = player.main_job .. '-' .. player.sub_job
    self.directory = player.server .. '/' .. player.name

    self.file = file.new('data/hotbar/' .. self.directory .. '/' .. self.filename .. '.xml')
end

-- store an hotbar in a new file
function storage:store_new_hotbar(new_hotbar)
    self.file:create()
    self.file:write(table.to_xml(new_hotbar))
end

-- update filename according to jobs
function storage:update_filename(main, sub)
    self.filename = main .. '-' .. sub
    self.file = file.new('data/hotbar/' .. self.directory .. '/' .. self.filename .. '.xml')
end

-- update file with hotbar
function storage:save_hotbar(new_hotbar)
    if not self.file:exists() then
        error('Hotbar file could not be found!')
        return
    end

    self.file:write(table.to_xml(new_hotbar))
end

return storage