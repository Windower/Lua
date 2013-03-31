--[[
LuaU - A utility tool for making Lua usable within FFXI. Loads several libraries and makes them available within the global namespace.
]]

require 'logger'
require 'stringhelper'
require 'tablehelper'
require 'mathhelper'
require 'functools'
require 'colors'
ffxi = require 'ffxi'
files = require 'filehelper'
config = require 'config'
