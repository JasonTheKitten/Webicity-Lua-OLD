local ribbon = require()

local class = ribbon.require "class"

local BlockComponent = ribbon.require("component/blockcomponent").BlockComponent
local Component = ribbon.require("component/component").Component
local Label = ribbon.require("component/label").Label

local URL = ribbon.reqpath("${CLASS}/net/url").URL

local browserframe = ...

local BrowserFrame = {}
browserframe.BrowserFrame = BrowserFrame

BrowserFrame.cparents = {BlockComponent}
function BrowserFrame:__call(parent, browser)
    if parent then class.checkType(parent, Component, 3, "Component") end
    BlockComponent.__call(self, parent)
	
	self.running = true
	
	self:attribute("display-title", "Untitled BrowserFrame")
    
    self.browser = browser
	browser:addTask(function()
		while self.running do coroutine.yield() end
	end)
end

function BrowserFrame:processAttributes(updated)
    Component.processAttributes(self, updated)
    
    if updated["browser"] then
        self.browser = self.attributes["browser"]
    end
    if updated["URL"] and self.browser then
		local special = {webicity = true, about=true}
        self.browser:addTask(function()
            if type(self.attributes["URL"]) == "string" then
                local url = URL.create(self.attributes["URL"], nil, special)
				if not url or url.cannotBeABaseURL then
					url = URL.create("https://"..self.attributes["URL"], nil, special)
				end
				if url and not url.cannotBeABaseURL then
					self.attributes["URL"] = url
				end
            end
            self.URL = self.attributes["URL"]
			
			if not updated["display-title"] then
				self.attributes["display-title"] = self.URL:toString()
				if self.attributes["ondisplaytitleupdate"] then
					self.attributes["ondisplaytitleupdate"](self.attributes["display-title"])
				end
			end
			
			local protocol = self.browser:getProtocol(self.URL.scheme) or self.browser:getDefaultProtocol()
			if not pcall(protocol, self.URL, self) then
				self:attribute("children", {
					class.new(Label, nil, "Your browser failed to load the requested resource")
				})
			end
        end)
    end
	if updated["display-title"] and self.attributes["ondisplaytitleupdate"] then
		self.attributes["ondisplaytitleupdate"]()
	end
end