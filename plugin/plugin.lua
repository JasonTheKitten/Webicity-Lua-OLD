--This file defines the Webicity-Core plugin (using code, of course!)
--When implemented, this file will:
--  Register all of the protocols in the protocols folder
--  Register all of the parsers in the content folder to their respective mime types
--  Define how resources are used
--  Define a variety of configurations
--This file will NOT:
--  Define how the browser starts
--  Load plugins

--TODO: Set plugin paths
local ribbon = require()

local class = ribbon.require "class"

local FileProtocol = ribbon.reqpath("${DIR}/plugin/protocols/file").File
local TextMime = ribbon.reqpath("${DIR}/plugin/content/text/text").Text

local plugin = ...

local Plugin = {}
plugin.Plugin = Plugin

Plugin.cparents = {class.Class}
function Plugin:__call(browser)
	browser:registerProtocol("file", FileProtocol)
	browser:registerMimeType("text/plain", TextMime)
end