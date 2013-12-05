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

windower.register_event('load',function ()
	version = '1.0.0'
	globaldisable = 0
	WAR_Book = ''
	WAR_Page = ''
	MNK_BOOK = ''
	MNK_Page = ''
	WHM_Book = ''
	WHM_Page = ''
	BLM_Book = ''
	BLM_Page = ''
	RDM_Book = ''
	RDM_Page = ''
	THF_Book = ''
	THF_Page = ''
	PLD_Book = ''
	PLD_Page = ''
	DRK_Book = ''
	DRK_Page = ''
	BST_Book = ''
	BST_Page = ''
	BRD_Book = ''
	BRD_Page = ''
	RNG_Book = ''
	RNG_Page = ''
	SAM_Book = ''
	SAM_Page = ''
	NIN_Book = ''
	NIN_Page = ''
	DRG_Book = ''
	DRG_Page = ''
	SMN_Book = ''
	SMN_Page = ''
	BLU_Book = ''
	BLU_Page = ''
	COR_Book = ''
	COR_Page = ''
	PUP_Book = ''
	PUP_Page = ''
	DNC_Book = ''
	DNC_Page = ''
	SCH_Book = ''
	SCH_Page = ''
	GEO_Book = ''
	GEO_Page = ''
	RUN_Book = ''
	RUN_Page = ''
	send_command('alias mc lua c macrochanger cmd')
	send_command('alias macrochanger lua c macrochanger cmd')
	add_to_chat(17, 'MacroChanger v' .. version .. ' loaded.     Author:  Banggugyangu')
	add_to_chat(17, 'Attempting to load settings from file.')
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
		WAR_Book = '1'
		WAR_Page = '1'
		MNK_BOOK = '2'
		MNK_Page = '1'
		WHM_Book = '3'
		WHM_Page = '1'
		BLM_Book = '4'
		BLM_Page = '1'
		RDM_Book = '5'
		RDM_Page = '1'
		THF_Book = '6'
		THF_Page = '1'
		PLD_Book = '7'
		PLD_Page = '1'
		DRK_Book = '8'
		DRK_Page = '1'
		BST_Book = '9'
		BST_Page = '1'
		BRD_Book = '10'
		BRD_Page = '1'
		RNG_Book = '11'
		RNG_Page = '1'
		SAM_Book = '12'
		SAM_Page = '1'
		NIN_Book = '13'
		NIN_Page = '1'
		DRG_Book = '14'
		DRG_Page = '1'
		SMN_Book = '15'
		SMN_Page = '1'
		BLU_Book = '16'
		BLU_Page = '1'
		COR_Book = '17'
		COR_Page = '1'
		PUP_Book = '18'
		PUP_Page = '1'
		DNC_Book = '19'
		DNC_Page = '1'
		SCH_Book = '20'
		SCH_Page = '1'
		GEO_Book = '20'
		GEO_Page = '1'
		RUN_Book = '20'
		RUN_Page = '1'
		write('Default settings file created')
		add_to_chat(12,'MacroChanger created a settings file and loaded!')
	else
		f:close()
		for curline in io.lines(windower.addon_path..'data/settings.txt') do
			local splat = split(curline,' ')
			local cmd = ''
			if splat[2] ~=nil then
				cmd = (splat[1]..' '..splat[2]):gsub(':',''):lower()
			end
			if cmd == 'war book' then
				WAR_Book = splat[3]
			elseif cmd == 'war page' then
				WAR_Page = splat[3]
			elseif cmd == 'mnk book' then
				MNK_Book = splat[3]
			elseif cmd == 'mnk page' then
				MNK_Page = splat[3]
			elseif cmd == 'whm book' then
				WHM_Book = splat[3]
			elseif cmd == 'whm page' then
				WHM_Page = splat[3]
			elseif cmd == 'blm book' then
				BLM_Book = splat[3]
			elseif cmd == 'blm page' then
				BLM_Page = splat[3]
			elseif cmd == 'rdm book' then
				RDM_Book = splat[3]
			elseif cmd == 'rdm page' then
				RDM_Page = splat[3]
			elseif cmd == 'thf book' then
				THF_Book = splat[3]
			elseif cmd == 'thf page' then
				THF_Page = splat[3]
			elseif cmd == 'pld book' then
				PLD_Book = splat[3]
			elseif cmd == 'pld page' then
				PLD_Page = splat[3]
			elseif cmd == 'drk book' then
				DRK_Book = splat[3]
			elseif cmd == 'drk page' then
				DRK_Page = splat[3]
			elseif cmd == 'bst book' then
				BST_Book = splat[3]
			elseif cmd == 'bst page' then
				BST_Page = splat[3]
			elseif cmd == 'brd book' then
				BRD_Book = splat[3]
			elseif cmd == 'brd page' then
				BRD_Page = splat[3]
			elseif cmd == 'rng book' then
				RNG_Book = splat[3]
			elseif cmd == 'rng page' then
				RNG_Page = splat[3]
			elseif cmd == 'sam book' then
				SAM_Book = splat[3]
			elseif cmd == 'sam page' then
				SAM_Page = splat[3]
			elseif cmd == 'nin book' then
				NIN_Book = splat[3]
			elseif cmd == 'nin page' then
				NIN_Page = splat[3]
			elseif cmd == 'drg book' then
				DRG_Book = splat[3]
			elseif cmd == 'drg page' then
				DRG_Page = splat[3]
			elseif cmd == 'smn book' then
				SMN_Book = splat[3]
			elseif cmd == 'smn page' then
				SMN_Page = splat[3]
			elseif cmd == 'blu book' then
				BLU_Book = splat[3]
			elseif cmd == 'blu page' then
				BLU_Page = splat[3]
			elseif cmd == 'cor book' then
				COR_Book = splat[3]
			elseif cmd == 'cor page' then
				COR_Page = splat[3]
			elseif cmd == 'pup book' then
				PUP_Book = splat[3]
			elseif cmd == 'pup page' then
				PUP_Page = splat[3]
			elseif cmd == 'dnc book' then
				DNC_Book = splat[3]
			elseif cmd == 'dnc page' then
				DNC_Page = splat[3]
			elseif cmd == 'sch book' then
				SCH_Book = splat[3]
			elseif cmd == 'sch page' then
				SCH_Page = splat[3]
			elseif cmd == 'geo book' then
				GEO_Book = splat[3]
			elseif cmd == 'geo page' then
				GEO_Page = splat[3]
			elseif cmd == 'run book' then
				RUN_Book = splat[3]
			elseif cmd == 'run page' then
				RUN_Page = splat[3]
			elseif cmd == 'disable all' then
				globaldisable = tonumber(splat[3])
			end
		end
		add_to_chat(12,'MacroChanger read from a settings file and loaded!')
	end
end

function split(msg, match)
	local length = msg:len()
	local splitarr = {}
	local u = 1
	while u <= length do
		local nextanch = msg:find(match,u)
		if nextanch ~= nil then
			splitarr[#splitarr+1] = msg:sub(u,nextanch-match:len())
			if nextanch~=length then
				u = nextanch+match:len()
			else
				u = lengthlua 
			end
		else
			splitarr[#splitarr+1] = msg:sub(u,length)
			u = length+1
		end
	end
	return splitarr
end

windower.register_event('job change',function (mjobId, mjob)
	local player = get_player()
	local job = player.main_job
	local book = ''
	local page = ''
	if globaldisable == 0 then
		if job == 'WAR' then
			book = WAR_Book
			page = WAR_Page
		elseif job == 'MNK' then
			book = MNK_Book
			page = MNK_Page
		elseif job == 'WHM' then
			book = WHM_Book
			page = WHM_Page
		elseif job == 'BLM' then
			book = BLM_Book
			page = BLM_Page
		elseif job == 'RDM' then
			book = RDM_Book
			page = RDM_Page
		elseif job == 'THF' then
			book = THF_Book
			page = THF_Page
		elseif job == 'PLD' then
			book = PLD_Book
			page = PLD_Page
		elseif job == 'DRK' then
			book = DRK_Book
			page = DRK_Page
		elseif job == 'BST' then
			book = BST_Book
			page = BST_Page
		elseif job == 'BRD' then
			book = BRD_Book
			page = BRD_Page
		elseif job == 'RNG' then
			book = RNG_Book
			page = RNG_Page
		elseif job == 'SAM' then
			book = SAM_Book
			page = SAM_Page
		elseif job == 'NIN' then
			book = NIN_Book
			page = NIN_Page
		elseif job == 'DRG' then
			book = DRG_Book
			page = DRG_Page
		elseif job == 'SMN' then
			book = SMN_Book
			page = SMN_Page
		elseif job == 'BLU' then
			book = BLU_Book
			page = BLU_Page
		elseif job == 'COR' then
			book = COR_Book
			page = COR_Page
		elseif job == 'PUP' then
			book = PUP_Book
			page = PUP_Page
		elseif job == 'DNC' then
			book = DNC_Book
			page = DNC_Page
		elseif job == 'SCH' then
			book = SCH_Book
			page = SCH_Page
		elseif job == 'GEO' then
			book = GEO_Book
			page = GEO_Page
		elseif job == 'RUN' then
			book = RUN_Book
			page = RUN_Page
		end
	
		if ((book == 'disabled') or (page == 'disabled')) then
			add_to_chat(17, '                             Auto Macro Switching Disabled for ' .. job ..'.')
		else	
			add_to_chat(17, '                             Changing macros to Book: ' .. book .. ' and Page: ' .. page .. '.  Job Changed to ' .. job)
			send_command('input /macro book ' .. book)
			send_command('input /macro set ' .. page)
		end
	elseif globaldisable == 1 then
	
		add_to_chat(17, '                             Auto Macro Switching Disabled for All Jobs.')
		
	end
end)

windower.register_event('unload',function ()
	send_command('unalias mc')
end)

windower.register_event('addon command',function (...)
    local term = table.concat({...}, ' ')
    local splitarr = split(term,' ')
	local mjob = get_player()['main_job']
	if splitarr[1] == 'cmd' then
		if splitarr[2] == 'disableall' then
			if splitarr[3] == 'on' then
				globaldisable = 1
				add_to_chat(17, 'All automated macro switching disabled.')
			elseif splitarr[3] == 'off' then
				globaldisable = 0
				add_to_chat(17, 'Automated macro switching enabled.')
			end
		elseif splitarr[2]:lower() == 'help' then
			add_to_chat(17, 'MacroChanger Commands:')
			add_to_chat(17, 'disableall [on|off]')
			add_to_chat(17, '   on - Disables all automated macro switching')
			add_to_chat(17, '   off - Enables all automated macro switching not disabled individually')
			add_to_chat(17, '   Resets to what is stored in settings upon unloading of addon.  To Permanently change, please change the option in the settings file.')
		end
	end
end)
