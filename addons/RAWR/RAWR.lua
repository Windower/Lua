_addon.name = 'RAWR'
_addon.author = 'Genoxd'
_addon.version = '1.0.0.0'
_addon.commands = {'rawr'}

require 'lists'

unity_leaders = 
T{
'{Pieuje}',
'{Ayame}',
'{Invincible Shield}', --galka suck.
'{Apururu}',
'{Maat}',
'{Aldo}',
'{Jakoh Wahcondalo}',
'{Naja Salaheem}',
'{Flaviria}',
'{Sylvie}',
'{Yoran-Oran}'
}

dragons = 
T{
'Azi Dahaka',
'Naga Raja',
'Quetzalcoatl'
}

windower.register_event("incoming text", function(original,modified,original_mode,modified_mode, blocked)
    if original_mode == 212 or original_mode == 211 then --Unity chat = 211/212, 211 might be outgoing
        for i,dragon in pairs(dragons) do
            if(windower.wc_match(original, "*"..dragon.."*")) then
                for i2,leader in pairs(unity_leaders) do
                    if(windower.wc_match(original, leader.."*"..dragon.."*")) then
                        windower.play_sound(windower.addon_path..'data/RAWR.wav')
                        return
                    end
                end
            end
        end
    end
end)