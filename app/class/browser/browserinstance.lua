local ribbon = require()

local class = ribbon.require "class"
local debugger = ribbon.require "debugger"
local filesystem = ribbon.require "filesystem"
local task = ribbon.require "task"

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
end

function BrowserInstance:loadplugins(pluginc)
	for k, v in pairs(pluginc) do
		local pluginfile = filesystem.combine(ribbon.resolvePath(v.plugin), "plugin")
		local ok, err = pcall(function()
			local plugin = ribbon.reqpath(pluginfile)
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
    class.checkType(c, Protocol, 2, "Protocol")
    self.protocols[protocol] = c
end
function BrowserInstance:getProtocol(protocol)
    return self.protocols[protocol]
end
function BrowserInstance:getDefaultProtocol()
	
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