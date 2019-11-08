local ribbon = require()

local class = ribbon.require "class"

local request = ...

local Request = {}
request.Request = Request

Request.cparents = {class.Class}
function Request:__call(URL, data)
    self.URL = URL
    self.data = data
end