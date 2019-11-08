local ribbon = require()

local class = ribbon.require "class"
local process = ribbon.require "process"
local statics = ribbon.require "statics"

local BufferedComponent = ribbon.require("component/bufferedcomponent").BufferedComponent
local Label = ribbon.require("component/label").Label

local MimeType = ribbon.reqpath("${CLASS}/net/mimetype").MimeType

local KEYS = statics.get("KEYS")

local text = ...

local Text = {}
text.Text = Text

Text.cparents = {MimeType}
function Text:submit(response)
    local frame = response.data.frame
    frame:removeChildren()
    
	local bc = class.new(BufferedComponent, frame):attribute(
		"height", {1}, "width", {1},
		"children", {
			class.new(Label, nil, response.content)
		}
	)
	process.addEventListener("key_down", function(n, e)
		if e.code == KEYS.DOWN then
			bc:scroll(1)
		elseif e.code == KEYS.UP then
			bc:scroll(-1)
		end
	end)
end