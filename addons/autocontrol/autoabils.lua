autoabils = {
    [1688] = {name = 'Shield Bash', recast = 180, icon = "00210"},
    [1689] = {name = 'Strobe', recast = 30, icon = "00210"},
    [1690] = {name = 'Shock Absorber', recast = 180, icon = "00210"},
    [1691] = {name = 'Flashbulb', recast = 45, icon = "00210"},
    [1692] = {name = 'Mana Converter', recast = 180, icon = "00210"},
    [1755] = {name = 'Reactive Shield', recast = 65, icon = "00210"},
    [1765] = {name = 'Eraser', recast = 30, icon = "00210"},
    [1812] = {name = 'Economizer', recast = 180, icon = "00210"},
    [1876] = {name = 'Replicator', recast = 60, icon = "00210"},
    [2489] = {name = 'Heat Capacitator', recast = 90, icon = "00210"},
    [2490] = {name = 'Barrage Turbine', recast = 180, icon = "00210"},
    [2491] = {name = 'Disruptor', recast = 60, icon = "00210"},
    [3485] = {name = 'Regulator', recast = 60, icon = "00210" }
}
attachments_to_abilities = {
    [8225] = 1688,
    [8449] = 1689,
    [8454] = 1755,
    [8456] = 2489,
    [8457] = 1689,
    [8461] = 2489,
    [8519] = 1876,
    [8520] = 2490,
    [8545] = 1690,
    [8553] = 1690,
    [8557] = 1690,
    [8642] = 1691,
    [8645] = 1765,
    [8674] = 1692,
    [8678] = 1812,
    [8680] = 2491,
    [8682] = 3485,
}

local player_id

windower.register_event("login", function()
    player_id = windower.ffxi.get_player().id
end)

windower.register_event("load", function()
    local player = windower.ffxi.get_player()
    player_id = player and player.id
end)

windower.register_event("action", function(act)
    local abil_ID = act['param']
    local actor_id = act['actor_id']
    local pet_index = windower.ffxi.get_mob_by_id(player_id)['pet_index']

    if act['category'] == 6 and actor_id == player_id and (abil_ID == 136 or abil_ID == 310 or abil_ID == 139) then
        local avalible_abilities = {}
        local automaton = windower.ffxi.get_mjob_data()

        if attachments_to_abilities[automaton.frame] then
            table.insert(avalible_abilities, autoabils[attachments_to_abilities[automaton.frame]])
        end

        for _, id in pairs(automaton.attachments) do
            if attachments_to_abilities[id] then
                table.insert(avalible_abilities, autoabils[attachments_to_abilities[id]])
            end
        end

        for _, ability in pairs(avalible_abilities) do -- if abil_ID is deactivate delete ability timers, otherwise create them.
            windower.send_command('timers '.. (abil_ID == 139 and "d" or "c") .. ' "'..ability.name..'" ' ..  (abil_ID == 139 and "" or ability.recast..' up abilities/' .. ability.icon))
        end
    elseif autoabils[abil_ID-256] and windower.ffxi.get_mob_by_id(actor_id)['index'] == pet_index and pet_index ~= nil then
        local abil = abil_ID - 256
        windower.send_command('@timers c "'..autoabils[abil].name..'" '..autoabils[abil].recast..' up')
    end
end)
