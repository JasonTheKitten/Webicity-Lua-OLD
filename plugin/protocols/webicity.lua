local ribbon = require()

local Protocol = ribbon.require("${CLASS}/net/protocol.lua").Protocol

local webicity = ...

local Webicity = {}
webicity.Webicity = Webicity

Webicity.cparents = {Protocol}
Webicity.__call = Protocol.__call

function Webicity:submit()

end