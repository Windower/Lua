options = {}
options.deprecated = function(opt)
    windower.add_to_chat(17, 'Parameter "'..opt..'" is deprecated and will be removed in a future version.')
end
options.disableall = function(opt)
    options.deprecated('disableall')
    switch = {}
    switch.on = function() options.enabled('false') end
    switch.off = function() options.enabled('true') end
    if switch[opt] then
        switch[opt]()
    else
        options.help()
    end
end
options.enabled = function(opt)
    switch = {}
    switch['false'] = function() 
        settings.enabled = false
        windower.add_to_chat(17, 'All automated macro switching disabled.')	
    end
    switch['true'] = function() 
        settings.enabled = true
        windower.add_to_chat(17, 'Automated macro switching enabled.')	
    end

    if switch[opt] then
        switch[opt]()
    else
        options.help()
    end
end
options.help = function()
    windower.add_to_chat(17, 'MacroChanger Commands:')
    windower.add_to_chat(17, 'enabled [true|false]')
    windower.add_to_chat(17, '  false - Disables all automated macro switching.')
    windower.add_to_chat(17, '  true  - Enables all automated macro switching (not disabled individually).')
    windower.add_to_chat(17, 'All settings are reset to what is stored in settings upon unloading the addon.')
    windower.add_to_chat(17, 'To Permanently change, please edit the settings in: ') 
    windower.add_to_chat(17, '  [windower]/addons/macrochanger/data/settings.xml')
end
options.notice = function()
    windower.add_to_chat(17, 'MacroChanger has been updated to use the Windower Config library.')
	windower.add_to_chat(17, '  Unfortunately, this means that the old configuration file is no longer')
	windower.add_to_chat(17, '  compatiable. Checkout the README.md in [windower]/addons/macrochanger/ for')
    windower.add_to_chat(17, '  more information.')
end
