--This file defines the Webicity-Core plugin (using code, of course!)
--When implemented, this file will:
--  Register all of the protocols in the protocol folder
--  Register all of the parsers in the content folder to their respective mime types
--  Define how resources are used
--  Define a variety of configurations
--This file will NOT:
--  Define how the browser starts
--  Load plugins

local ribbon = require()

local class = ribbon.require "class"

local plugin = ...

local Plugin = {}
plugin.Plugin = Plugin

Plugin.cparents = {class.Class}
function Plugin:__call(browser)
	
end