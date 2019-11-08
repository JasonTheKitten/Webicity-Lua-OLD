local ribbon = require()

local class = ribbon.require "class"

local response = ...

local Response = {}
response.Response = Response

Response.cparents = {class.Class}
function Response:__call(content, data)
    self.content = content
    self.data = data
end