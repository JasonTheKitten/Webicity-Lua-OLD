local ribbon = require()

local class = ribbon.require "class"
local task = ribbon.require "task"

local Protocol = ribbon.reqpath("${CLASS}/net/protocol").Protocol

local browserinstance = ...

local BrowserInstance = {}
browserinstance.BrowserInstance = BrowserInstance

BrowserInstance.cparents = {class.Class}
function BrowserInstance:__call()
    self.tasks = task.createTaskSystem()
    self.protocols = {}
    self.contenthandlers = {}
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

function BrowserInstance:continue()
	self.tasks.purgeDead()
	self.tasks.continueAll()
	return not self.tasks.checkEmpty()
end