local ribbon = require()

local class = ribbon.require("class")

local mimetype = ...

local MimeType = {}
mimetype.MimeType = MimeType

MimeType.cparents = {class.Class}
function MimeType:submit(response)
    error("This method should be overriden")
end