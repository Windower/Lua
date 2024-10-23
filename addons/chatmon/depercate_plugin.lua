
if not windower.file_exists(windower.windower_path .. 'plugins\\ChatMon.dll') then
    return false
end
windower.send_command('unload chatmon')

local function read_all_lines(file_name)
    local f = assert(io.open(file_name, "r"))
    local text = f:read("*all")
    f:close()
    return text
end

local function parse_from(from)
    if from == nil then
        return ''
    end

    local output = ''

    for match in string.gmatch(from:lower(), '[^|/\\,%s]+') do
        output = output .. ' "'.. match ..'",'
    end

    return output
end

local file = windower.windower_path .. 'plugins\\ChatMon.xml'
local text = read_all_lines(file)

if text ~= '' then

    text = string.gsub(text, '%<%?xml version%="1%.0" %?%>%s*', '')
    text = string.gsub(text, '<ChatMon>', 'return {')
    text = string.gsub(text, '(="[^"]+")', '%1,')
    text = string.gsub(text, '<settings', 'settings = {')
    text = string.gsub(text, '<%!%-%-[^\n]+%-%->%s*', '')
    text = string.gsub(text, '<trigger', '{')
    text = string.gsub(text, '/>', '},')
    text = string.gsub(text, '</ChatMon>', '}')

    local sounds = {
        ['tell'] = 'IncomingTell.wav',
        ['talk'] = 'IncomingTalk.wav',
        ['emote'] = 'IncomingEmote.wav',
        ['invite'] = 'PartyInvitation.wav',
        ['examine'] = 'IncomingExamine.wav',
    }

    local chatmon_plugin_xml = loadstring(text)()
    local trigger_text = 'return {\n'

    local tell_trigger = '{ from = S{ "tell" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingTell.wav"},\n'
    if chatmon_plugin_xml.settings.TellSound:lower() ~= 'none' then
        trigger_text = trigger_text .. '    ' .. tell_trigger
    else
        trigger_text = trigger_text .. '    --' .. tell_trigger
    end

    local emote_trigger = '{ from = S{ "emote" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingEmote.wav"},\n'
    if chatmon_plugin_xml.settings.EmoteSound:lower() ~= 'none' then
        trigger_text = trigger_text .. '    ' .. emote_trigger
    else
        trigger_text = trigger_text .. '    --' .. emote_trigger
    end

    local invite_trigger = '{ from = S{ "invite" }, notFrom = S{}, match = "*", notMatch = "", sound = "PartyInvitation.wav"},\n'
    if chatmon_plugin_xml.settings.InviteSound:lower() ~= 'none' then
        trigger_text = trigger_text .. '    ' .. invite_trigger
    else
        trigger_text = trigger_text .. '    --' .. invite_trigger
    end

    local examine_trigger = '{ from = S{ "examine" }, notFrom = S{}, match = "*", notMatch = "", sound = "IncomingExamine.wav"},\n'
    if chatmon_plugin_xml.settings.ExamineSound:lower() ~= 'none' then
        trigger_text = trigger_text .. '    ' .. examine_trigger
    else
        trigger_text = trigger_text .. '    --' .. examine_trigger
    end

    local talk_trigger = '{ from = S{ "say", "shout", "party", "linkshell" }, notFrom = S{}, match = "<name>", notMatch = "", sound = "IncomingTalk.wav"},\n'
    if chatmon_plugin_xml.settings.TalkSound:lower() ~= 'none' then
        trigger_text = trigger_text .. '    '.. talk_trigger
    else
        trigger_text = trigger_text .. '    --' .. talk_trigger
    end

    for key, trigger in pairs(chatmon_plugin_xml) do
        if key ~= 'settings' then
            local from = parse_from(trigger.from)
            local not_from = parse_from(trigger.notFrom)
            local match = trigger.match or '*'
            local not_match = trigger.notMatch or ''
            local sound = trigger.sound and (sounds[trigger.sound:lower()] or trigger.sound) or 'IncomingTalk.wav'
            trigger_text = trigger_text .. string.format('    { from = S{%s }, notFrom = S{%s }, match = "%s", notMatch = "%s", sound = "%s"},\n', from, not_from, match, not_match, sound)
        end
    end
    trigger_text = trigger_text .. '}\n'

    local global = assert(io.open(windower.addon_path .. "/data/triggers/global.lua", "w"))
    global:write(trigger_text)
    global:close()

    local truthy_set = S{'true', 't', 'yes', 'y', 'on', 'o'}
    chatmon_plugin_xml.settings.DisableOnFocus = truthy_set:contains(string.lower(chatmon_plugin_xml.settings.DisableOnFocus)) ~= nil
    chatmon_plugin_xml.settings.SoundInterval = tonumber(chatmon_plugin_xml.settings.SoundInterval)

    coroutine.schedule(function()
        windower.create_dir(windower.windower_path .. 'plugins\\depercated')
        os.rename(windower.windower_path .. 'plugins\\ChatMon.xml', windower.windower_path .. 'plugins\\depercated\\ChatMon.xml')
        os.rename(windower.windower_path .. 'plugins\\ChatMon.dll', windower.windower_path .. 'plugins\\depercated\\ChatMon.dll')
    end, 0)

    return chatmon_plugin_xml.settings
end
