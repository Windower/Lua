--[[
LuaU - A utility tool for making Lua usable within FFXI. Loads several libraries and makes them available within the global namespace.
]]

require 'logger'
require 'stringhelper'
require 'tablehelper'
require 'lists'
require 'sets'
require 'mathhelper'
require 'functools'
require 'colors'
require 'actionhelper'
ffxi = require 'ffxi'
files = require 'filehelper'
config = require 'config'
xml = require 'xml'
json = require 'json'
collectgarbage().
