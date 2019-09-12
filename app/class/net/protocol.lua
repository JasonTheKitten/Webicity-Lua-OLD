local ribbon = require()

local class = ribbon.require("class")

local protocol = ...

local Protocol = {}
protocol.Protocol = Protocol

Protocol.cparents = {class.Class}
function Protocol:submit(data)
    error("This method should be overriden")
end