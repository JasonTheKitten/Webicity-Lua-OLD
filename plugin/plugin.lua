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

local FileProtocol = pluginapi.load("protocols/file").File
local HTTPProtocol = pluginapi.load("protocols/http").HTTP
local TextMimetype = pluginapi.load("content/text/text").Text
local HTMLMimetype = pluginapi.load("content/html/html").HTML

local plugin = ...

local Plugin = {}
plugin.Plugin = Plugin

Plugin.cparents = {class.Class}
function Plugin:__call(browser)
	browser:registerProtocol("file", FileProtocol)
	browser:registerProtocol("http", HTTPProtocol)
	browser:registerProtocol("https", HTTPProtocol)
	browser:registerMimeType("text/plain", TextMimetype)
	browser:registerMimeType("text/html", HTMLMimetype)
end