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
    * Neither the name of Battle Stations nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Sjshovan (Apogee) BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

_addon.name     = 'Battle Stations'
_addon.description = 'Change or remove the default battle music.'
_addon.author   = 'Sjshovan (Apogee) sjshovan@gmail.com'
_addon.version  = '0.9.1'
_addon.commands = {'battlestations', 'stations', 'bs'}

local _logger = require('logger')
local _config  = require('config')
local _packets = require('packets')

require('functions')
require('constants')
require('helpers')

local defaults = {
    stations = {
        solo = 107.3,
        party = 107.3
    }
}

local settings = _config.load(defaults)

local help = {
    commands = {
        buildHelpSeperator('=', 28),
        buildHelpTitle('Commands'),
        buildHelpSeperator('=', 28),
        buildHelpCommandEntry('list [radios|stations] [category#]', 'Display the available radios and or stations.'),
        buildHelpCommandEntry('set <station> [radio]', 'Set radio(s) to the given station.'),
        buildHelpCommandEntry('get [radio]', 'Display currently set station on the given radio(s).'),
        buildHelpCommandEntry('default [radio]', 'Set radio(s) to the default station (Current Zone Music).'),
        buildHelpCommandEntry('normal [radio]', 'Set radio(s) to the original game music.'),
        buildHelpCommandEntry('reload', 'Reload Battle Stations.'),
        buildHelpCommandEntry('about', 'Display information about Battle Stations.'),
        buildHelpCommandEntry('help', 'Display Battle Stations commands.'),
        buildHelpSeperator('=', 28),
    },

    radios = {
        buildHelpSeperator('=', 25),
        buildHelpTitle('Radios'),
        buildHelpSeperator('=', 25),
        buildHelpRadioEntry(stations.receivers.solo:ucfirst(), 'Plays Solo Battle Music'),
        buildHelpRadioEntry(stations.receivers.party:ucfirst(), 'Plays Party Battle Music'),
        buildHelpSeperator('=', 25),
    },
    
     about = {
        buildHelpSeperator('=', 23),
        buildHelpTitle('About'),
        buildHelpSeperator('=', 23),
        buildHelpTypeEntry('Name', _addon.name),
        buildHelpTypeEntry('Description', _addon.description),
        buildHelpTypeEntry('Author', _addon.author),
        buildHelpTypeEntry('Version', _addon.version),
        buildHelpSeperator('=', 23),
    },
    
    aliases = {
        list = {
            stations = T{
                's', 
                'station',
                'stations',
            },
            radios = T{
                'r',
                'radio', 
                'radios',
                'receiver',
                'receivers'
            },
            categories = T{
                'c',
                'cat',
                'category',
                'categories'
            },
            all = T{
                '*',
                'a',
                'all',
            }
        } 
    }
}

function displayHelp(table_help)
    for index, command in pairs(table_help) do
        displayResponse(command)
    end
end

function displayStations(range)
    displayResponse(buildHelpSeperator('=', 27))
    displayResponse(buildHelpTitle('Stations'))
    displayResponse(buildHelpSeperator('=', 27))
    
    if range ~= nil then 
        if categoryValid(range) then
            displayRangeFrequencies(range)
        end
    else
        for i=100, 107, 1 do
            range = tostring(i)
            displayRangeFrequencies(range)
       end
    end
    displayResponse(buildHelpSeperator('=', 26))    
end

function displayRangeFrequencies(range, name)
    local categories = stations.categories
    
    if categoryValid(range) then
        local name = categories[range]
        displayResponse(buildHelpStationCategoryEntry(range, name))
        displayFrequencies(range)
    end
end

function displayFrequencies(range)
    for i=1, 9, 1 do
        local frequency = range .. '.%s':format(tostring(i))
        if frequencyValid(frequency) then 
            local frequencyObj = getFrequencyObjByValue(frequency)
            local response = buildHelpStationEntry(frequency, frequencyObj.callSign)
            displayResponse(response)
        end
    end
end

function displayCategories()
    displayResponse(buildHelpSeperator('=', 27))
    displayResponse(buildHelpTitle('Categories'))
    displayResponse(buildHelpSeperator('=', 27))
    for i=100, 107, 1 do
        local range = tostring(i)
        if categoryValid(range) then
            local name = stations.categories[range]
            displayResponse(buildHelpStationCategoryEntry(range, name))
        end
    end
    displayResponse(buildHelpSeperator('=', 27))  
end 

function getStations()
    return settings.stations
end

function setStation(radio, frequency)
    if radio == stations.receivers.solo then
        settings.stations.solo = frequency
    elseif radio == stations.receivers.party then
        settings.stations.party = frequency
    else
        settings.stations.solo = frequency
        settings.stations.party = frequency
    end
        
    settings:save()
end

function resolveCurrentStations()
    local current_stations = getStations()
    local radio = 'solo'
    local frequency = tostring(defaults.stations.solo)
    local message_template = '%s station found in settings was not valid and was set to the default %s (%s).'
    
    if not frequencyValid(current_stations.solo) then
        current_stations.solo = frequency
        setStation(radio, frequency)
        
        displayResponse(
            buildWarningMessage(
                message_template:format(
                    radio:ucfirst():color(colors.secondary),
                    frequency:color(colors.primary), 
                    getFrequencyObjByValue(frequency).callSign
                )
            )
        )
    end
    
    if not frequencyValid(current_stations.party) then
        radio = 'party'
        frequency = tostring(defaults.stations.party)
        current_stations.party = party_default
        
        setStation(radio, frequency)
        
        displayResponse(
            buildWarningMessage(
                message_template:format(
                    radio:ucfirst():color(colors.secondary),
                    frequency:color(colors.primary), 
                    getFrequencyObjByValue(frequency).callSign
                )
            )
        )
    end
    
    return current_stations
end

function injectBattleMusic()
    local current_stations = resolveCurrentStations()
    local song = getFrequencyObjByValue(current_stations.solo).song
    local music_type = music.types.battle_solo
    
    if playerInParty() then 
        music_type = music.types.battle_party
        song = getFrequencyObjByValue(current_stations.party).song
    end
    
    song = getConditionalSongTranslation(song)
    
    _packets.inject(_packets.new('incoming', packets.inbound.music_change.id, {
        ['BGM Type'] = music_type,
        ['Song ID'] = song
    }))
end

function getFrequencyObjByValue(frequency)
    return stations.frequencies[tostring(frequency)]
end

function getCurrentTime(formatted)
    local timestamp = tostring(windower.ffxi.get_info().time)
    local hours = (timestamp / 60):floor()
    local minutes = timestamp % 60
    if formatted then 
        return "%s:%s":format(hours, minutes)
    end
    return timestamp
end

function getZoneBGMTable() 
    local data = windower.packets.last_incoming(packets.inbound.zone_update.id)
    local packet = _packets.parse('incoming', data)
    return {
        day = packet['Day Music'],
        night = packet['Night Music'],
        solo = packet['Solo Combat Music'],
        party = packet['Party Combat Music']
    }
end

function getConditionalSongTranslation(song)
    local zone_bgm_table = getZoneBGMTable()
    if song == music.songs.others.zone then    
        if timeIsDaytime() then
            song = zone_bgm_table.day
        else 
            song = zone_bgm_table.night
        end
       
        if playerInReive() then
            song = music.songs.seekers_of_adoulin.breaking_ground
        end
          
    elseif song == music.songs.others.normal then
        if playerInParty() then
            song = zone_bgm_table.party
        else 
            song = zone_bgm_table.solo
        end
    end
    return song 
end

function getPlayerBuffs()
    return T(windower.ffxi.get_player().buffs)
end

function timeIsDaytime()
    local current_time = tonumber(getCurrentTime())
    return current_time >= 6*60 and current_time <= 18*60
end

function playerIsFighting()
    return windower.ffxi.get_player().status == player.statuses.fighting
end

function playerInParty() 
    return windower.ffxi.get_party().alliance_count > 1
end

function playerInReive()
    return getPlayerBuffs():contains(player.buffs.reiveMark)
end

function frequencyValid(frequency)
    return stations.frequencies[tostring(frequency)] ~= nil
end

function radioValid(radio)
    return stations.receivers[radio] ~= nil or radio == '*'
end

function categoryValid(category) 
    return stations.categories[category] ~= nil
end

function listTypeValid(list_type) 
    return help.lists[list_type] ~= nil
end

function handleInjectionNeeds() 
    if needs_inject then
        injectBattleMusic()
        needs_inject = false;
    end
end

windower.register_event('load', function () 
    injectBattleMusic()
end)

windower.register_event('unload', function() 
    local music_type = music.types.battle_solo
    local zone_bgm_table = getZoneBGMTable()
    local song = zone_bgm_table.solo
    
    if playerInParty() then
       music_type = music.types.battle_party
       song = zone_bgm_table.solo
    end
                   
    _packets.inject(_packets.new('incoming', packets.inbound.music_change.id, {
        ['BGM Type'] = music_type,
        ['Song ID'] = song,
    }))
end)

windower.register_event('action', function(act)
    if act.actor_id == windower.ffxi.get_player().id then
        if act.category == 4 and act.recast == 225 and act.targets[1].actions[1].animation == 939 then
            if not playerInParty() then
                functions.loop(injectBattleMusic, 1, 5)          
            end    
        end
    end
end)

windower.register_event('outgoing chunk', function(id, data)
    if id == packets.outbound.action.id then
        local packet = _packets.parse('outgoing', data)
        if packet.Category == packets.outbound.action.categories.engage then
            injectBattleMusic()
        end
    end
end) 

windower.register_event('addon command', function(command, ...)
    if command then
        command = command:lower()
    else 
        displayHelp(help.commands)
        return
    end
  
    local command_args = {...}
    
    local respond = false
    local response_message = ''
    local success = true

    if command == 'list' or command == 'l' then
        local list_type = (command_args[1] or '*'):lower()
        local category = command_args[2]
        
        if help.aliases.list.stations:contains(list_type) then
            if category then
                if categoryValid(category) then
                    displayStations(category)
                
                else
                   respond = true
                   success = false
                   response_message = 'Category not recognized.'
                end
            else 
                displayStations()
            end       
        
        elseif help.aliases.list.radios:contains(list_type) then 
            displayHelp(help.radios)
            
        elseif help.aliases.list.categories:contains(list_type) then
            displayCategories()
        
        elseif help.aliases.list.all:contains(list_type) then
            displayHelp(help.radios)
            displayStations()
        
        else 
            respond = true
            success = false
            response_message = 'List type not recognized.'
        end
        
    elseif command == 'set' or command == 's' then
        respond = true
        
        local frequency = command_args[1]:lower()
     
        local radio = (command_args[2] or '*'):lower()
        
        if not frequencyValid(frequency) then
            success = false
            response_message = 'Frequency not recognized.'
        
        elseif not radioValid(radio) then
            success = false
            response_message = 'Radio not recognized.'           
        else 
            needs_inject = true
            
            local context = 'radio'
            
            setStation(radio, tonumber(frequency))
            
            if radio == '*' then
                context = 'radios'
                radio = 'Solo and Party'
            end
            
            response_message = buildSetResponseMessage(
                radio:ucfirst(), 
                context, 
                frequency, 
                getFrequencyObjByValue(frequency).callSign
            )..'.'
        end

    elseif command == 'get' or command == 'g' then
        respond = true
        
        local current_stations = resolveCurrentStations()
        local radio = (command_args[1] or '*'):lower()
        local frequency = current_stations[radio]
        local frequency2 = current_stations.party
        local individual = false
        
        if not radioValid(radio) then
            success = false
            response_message = 'Radio not recognized.'
        else
            local context = 'radio is'
            
            if radio == '*' then
                frequency = current_stations.solo
                
                if current_stations.party ~= current_stations.solo then
                   individual = true
                else 
                   context = 'radios are'
                   radio = 'Solo and Party'    
                end  
            end
            
            if not individual then
                response_message = buildGetResponseMessage(
                    radio:ucfirst(), 
                    context, 
                    frequency, 
                    getFrequencyObjByValue(frequency).callSign
                )..'.'
   
            else
                local solo_message = buildGetResponseMessage(
                    stations.receivers.solo:ucfirst(), 
                    context, 
                    frequency, 
                    getFrequencyObjByValue(frequency).callSign
                )
                
                local party_message = buildGetResponseMessage(
                   stations.receivers.party:ucfirst(), 
                   context, 
                   frequency2, 
                   getFrequencyObjByValue(frequency2).callSign
                )
                
                response_message = solo_message..' and '..party_message..'.'
            end    
        end

    elseif command == 'default' or command == 'd' then
        respond = true 
        
        local radio = (command_args[1] or '*'):lower()
        
        if not radioValid(radio) then
            success = false
            response_message = 'Radio not recognized.'           
        else 
            needs_inject = true
            
            local frequency = defaults.stations.solo
            local context = 'radio'
            
            setStation(radio, tonumber(frequency))
            
            if radio == '*' then
                context = 'radios'
                radio = 'Solo and Party'
            end
            
            response_message = buildSetResponseMessage(
                radio:ucfirst(), 
                context, 
                frequency, 
                getFrequencyObjByValue(frequency).callSign
            )..'.'
        end
       
    elseif command == 'normal' or command == 'n' then
        respond = true 
        
        local radio = (command_args[1] or '*'):lower()
        
        if not radioValid(radio) then
            success = false
            response_message = 'Radio not recognized.'           
        else
            needs_inject = true
        
            local frequency = '107.2'
            local context = 'radio'
            
            setStation(radio, tonumber(frequency))
            
            if radio == '*' then
                context = 'radios'
                radio = 'Solo and Party'
            end
            
            response_message = buildSetResponseMessage(
                radio:ucfirst(), 
                context, 
                frequency, 
                getFrequencyObjByValue(frequency).callSign
            )..'.'
        end
        
    elseif command == 'reload' or command == 'r' then
        windower.send_command('lua r battlestations')
        
    elseif command == 'about' or command == 'a' then
        displayHelp(help.about)

    elseif command == 'help' or command == 'h' then
        displayHelp(help.commands)
             
    else
        displayHelp(help.commands)
    end

    if respond then
        displayResponse(
            buildCommandResponse(response_message, success)
        )
    end
    
    handleInjectionNeeds()
end)  