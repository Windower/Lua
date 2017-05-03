--Copyright (c) 2013, Banggugyangu
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of <addon name> nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'MacroChanger'
_addon.author = 'Banggugyangu'
_addon.version = '1.0.0.1'
_addon.commands = {'mc','macrochanger'}

require('strings')

windower.register_event('load', function()
	globaldisable = 0
    macros = {
        WAR = {Book = '', Page = ''},
        MNK = {Book = '', Page = ''},
        WHM = {Book = '', Page = ''},
        BLM = {Book = '', Page = ''},
        RDM = {Book = '', Page = ''},
        THF = {Book = '', Page = ''},
        PLD = {Book = '', Page = ''},
        DRK = {Book = '', Page = ''},
        BST = {Book = '', Page = ''},
        BRD = {Book = '', Page = ''},
        RNG = {Book = '', Page = ''},
        SAM = {Book = '', Page = ''},
        NIN = {Book = '', Page = ''},
        DRG = {Book = '', Page = ''},
        SMN = {Book = '', Page = ''},
        BLU = {Book = '', Page = ''},
        COR = {Book = '', Page = ''},
        PUP = {Book = '', Page = ''},
        DNC = {Book = '', Page = ''},
        SCH = {Book = '', Page = ''},
        GEO = {Book = '', Page = ''},
        RUN = {Book = '', Page = ''},
        }
	options_load()
end)

function options_load()
	local f = io.open(windower.addon_path..'data/settings.txt', "r")
	if f == nil then
		local g = io.open(windower.addon_path..'data/settings.txt', "w")
		g:write('Release Date: 9:00 PM, 4-01-13\46\n')
		g:write('Author Comment: This document is whitespace sensitive, which means that you need the same number of spaces between things as exist in this initial settings file\46\n')
		g:write('Author Comment: It looks at the first two words separated by spaces and then takes anything as the value in question if the first two words are relevant\46\n')
		g:write('Author Comment: If you ever mess it up so that it does not work, you can just delete it and MacroChanger will regenerate it upon reload\46\n')
		g:write('Author Comment: For the output customization lines, simply place the book and page number that you would like to change to upon a job change.\46\n')
		g:write('Author Comment: If 2 jobs share a book, you can place the same book number for each job, then put their individual pages.\46\n')
		g:write('Author Comment: Example:  BLM and SCH both use Macro Book 2:  BLM uses page 3. SCH uses page 1.\46\n')
		g:write('Author Comment: Put BLM Book: 2,  BLM Page: 3,  SCH Book: 2,  SCH Page: 1.\46\n')
		g:write('Author Comment: If you wish to disable auto-macro Changing for a specific job, type "disabled" instead of a book number.  (e.g. BLM Book: disabled)\n')
		g:write('Author Comment: The design of the settings file is credited to Byrthnoth as well as the creation of the settings file.\n\n\n')
		g:write('File Settings: Fill in below\n')
		g:write('Disable All: 0\n')
		g:write('WAR Book: 1\nWAR Page: 1\nMNK Book: 2\nMNK Page: 1\nWHM Book: 3\nWHM Page: 1\nBLM Book: 4\nBLM Page: 1\nRDM Book: 5\nRDM Page: 1\nTHF Book: 6\nTHF Page: 1\n')
		g:write('PLD Book: 7\nPLD Page: 1\nDRK Book: 8\nDRK Page: 1\nBST Book: 9\nBST Page: 1\nBRD Book: 10\nBRD Page: 1\nRNG Book: 11\nRNG Page: 1\nSAM Book: 12\nSAM Page: 1\n')
		g:write('NIN Book: 13\nNIN Page: 1\nDRG Book: 14\nDRG Page: 1\nSMN Book: 15\nSMN Page: 1\nBLU Book: 16\nBLU Page: 1\nCOR Book: 17\nCOR Page: 1\nPUP Book: 18\nPUP Page: 1\n')
		g:write('DNC Book: 19\nDNC Page: 1\nSCH Book: 20\nSCH Page: 1\nGEO Book: 20\nGEO Page: 1\nRUN Book: 20\nRUN Page: 1\n')
		g:close()
		DisableAll = 0
        macros = {
            WAR = {Book = '1', Page = '1'},
            MNK = {Book = '2', Page = '1'},
            WHM = {Book = '3', Page = '1'},
            BLM = {Book = '4', Page = '1'},
            RDM = {Book = '5', Page = '1'},
            THF = {Book = '6', Page = '1'},
            PLD = {Book = '7', Page = '1'},
            DRK = {Book = '8', Page = '1'},
            BST = {Book = '9', Page = '1'},
            BRD = {Book = '10', Page = '1'},
            RNG = {Book = '11', Page = '1'},
            SAM = {Book = '12', Page = '1'},
            NIN = {Book = '13', Page = '1'},
            DRG = {Book = '14', Page = '1'},
            SMN = {Book = '15', Page = '1'},
            BLU = {Book = '16', Page = '1'},
            COR = {Book = '17', Page = '1'},
            PUP = {Book = '18', Page = '1'},
            DNC = {Book = '19', Page = '1'},
            SCH = {Book = '20', Page = '1'},
            GEO = {Book = '20', Page = '1'},
            RUN = {Book = '20', Page = '1'},
            }
		print('Default settings file created')
		windower.add_to_chat(12,'MacroChanger created a settings file and loaded!')
	else
		f:close()
		for curline in io.lines(windower.addon_path..'data/settings.txt') do
			local splat = curline:gsub(':',''):split(' ')
			local cmd = ''
			if splat[1] and macros[splat[1]:upper()] and splat[2] ~=nil and (splat[2]:lower() == 'book' or splat[2]:lower() == 'page') and splat[3] then
				macros[splat[1]:upper()][splat[2]:ucfirst()] = splat[3] -- Instead of a number, this can also be 'disabled'
			elseif splat[1] and splat[2] and (splat[1]..' '..splat[2]) == 'disable all' and tonumber(splat[3]) then
				globaldisable = tonumber(splat[3])
			end
		end
		windower.add_to_chat(12,'MacroChanger read from a settings file and loaded!')
	end
end

windower.register_event('job change',function ()
-- Could use the job ID passed into this function, but the addon would have to include the resources library
	local job = windower.ffxi.get_player().main_job
	local book = ''
	local page = ''
	if globaldisable == 0 then
        if job and macros[job] then
			book = macros[job].Book
			page = macros[job].Page
		end

		if ((book == 'disabled') or (page == 'disabled')) then
			windower.add_to_chat(17, '                             Auto Macro Switching Disabled for ' .. job ..'.')
		else
			windower.add_to_chat(17, '                             Changing macros to Book: ' .. book .. ' and Page: ' .. page .. '.  Job Changed to ' .. job)
			windower.send_command('input /macro book '..book..';wait 0.2;input /macro set '..page..';')
		end
	elseif globaldisable == 1 then

		windower.add_to_chat(17, '                             Auto Macro Switching Disabled for All Jobs.')

	end
end)

windower.register_event('addon command', function(...)
    local args = {...}
	local mjob = windower.ffxi.get_player().main_job
	if args[1] == 'disableall' then
		if args[2] == 'on' then
			globaldisable = 1
			windower.add_to_chat(17, 'All automated macro switching disabled.')
		elseif args[2] == 'off' then
			globaldisable = 0
			windower.add_to_chat(17, 'Automated macro switching enabled.')
		end
	elseif args[1]:lower() == 'help' then
		windower.add_to_chat(17, 'MacroChanger Commands:')
		windower.add_to_chat(17, 'disableall [on|off]')
		windower.add_to_chat(17, '   on - Disables all automated macro switching')
		windower.add_to_chat(17, '   off - Enables all automated macro switching not disabled individually')
		windower.add_to_chat(17, '   Resets to what is stored in settings upon unloading of addon.  To Permanently change, please change the option in the settings file.')
	end
end)
