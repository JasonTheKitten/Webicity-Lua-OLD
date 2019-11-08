local ribbon = require()

local class = ribbon.require("class")

local protocol = ...

local Protocol = {}
protocol.Protocol = Protocol

Protocol.cparents = {class.Class}
function Protocol:__call(browser)
    this.browser = browser
end

function Protocol:submit(response)
    error("This method should be overriden")
end