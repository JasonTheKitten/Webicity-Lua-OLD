local ribbon = require()

local class = ribbon.require "class"
local debugger = ribbon.require "debugger"
local process = ribbon.require "process"
local statics = ribbon.require "statics"

local BufferedComponent = ribbon.require("component/bufferedcomponent").BufferedComponent
local BlockComponent = ribbon.require("component/blockcomponent").BlockComponent

local Buffer = ribbon.reqpath("${CLASS}/string/buffer").Buffer
local MimeType = ribbon.reqpath("${CLASS}/net/mimetype").MimeType

local HTMLParser = pluginapi.load("content/html/parser").HTMLParser


local KEYS = statics.get("KEYS")

local html = ...

local HTML = {}
html.HTML = HTML

HTML.cparents = {MimeType}
function HTML:submit(response)
    local frame = response.data.frame
    frame:removeChildren()
    
	HTMLParser.parse(class.new(Buffer, response.content))
end