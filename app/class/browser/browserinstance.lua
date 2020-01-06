local ribbon = require()

local class = ribbon.require "class"
local debugger = ribbon.require "debugger"
local task = ribbon.require "task"
local util = ribbon.require "util"

local PluginAPI = ribbon.reqpath("${CLASS}/browser/plugin/pluginapi").PluginAPI
local Protocol = ribbon.reqpath("${CLASS}/net/protocol").Protocol

local browserinstance = ...

local BrowserInstance = {}
browserinstance.BrowserInstance = BrowserInstance

BrowserInstance.cparents = {class.Class}
function BrowserInstance:__call()
    self.tasks = task.createTaskSystem()
	self.plugins = {}
    self.protocols = {}
    self.mimes = {}
    
    self.specialProtocols = util.reverse {"webicity", "about"}
    self.actionSchemes = util.reverse {"javascript"}
end

function BrowserInstance:loadplugins(pluginc)
	for k, v in pairs(pluginc) do --TODO: Preload all plugins before init
		local pluginfile = ribbon.resolvePath(v.plugin)
		local ok, err = pcall(function()
			--Temp system
			local papi = class.new(PluginAPI, pluginfile).api
			local plugin = papi.load("plugin")
			local Plugin = class.new(plugin.Plugin, self)
		end)
		if not ok then
			debugger.error("Error loading plugin at '"..pluginfile.."'")
			debugger.error(err)
		end
	end
end

function BrowserInstance:addTask(f)
    self.tasks.register(f)
end

function BrowserInstance:registerProtocol(protocol, c)
    --class.checkType(c, Protocol, 2, "Protocol")
    self.protocols[protocol] = c
end
function BrowserInstance:getProtocol(protocol)
    return self.protocols[protocol]
end
function BrowserInstance:getDefaultProtocol()
	return self.protocols["http"]
end

function BrowserInstance:registerMimeType(mimetype, c)
	--TODO: Check type
	self.mimes[mimetype] = c
end
function BrowserInstance:getMimeType(mimetype)
	return self.mimes[mimetype]
end

function BrowserInstance:continue()
	self.tasks.purgeDead()
	self.tasks.continueAll()
	return not self.tasks.checkEmpty()
end