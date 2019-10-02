local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")
local Object = object.Object

local stringobject = ...

local StringObject = {}
stringobject.StringObject = StringObject

StringObject.cparents = {Object}
function StringObject:__call()
    Object.__call(self)
    self.value = ""
end

function StringObject:installFields()
    self:setraw("__proto__", object.getstatic("Object"))
end

function Object:getType()
    return "string"
end
function Object:getName()
    return "StringObject"
end

function Object:toString()
    return self.value
end

stringobject.valueof = function(str)
    if type(str) == "string" then
        return str
    elseif type(str) == "table" then
        return str:toString()
    elseif str == nil then
        return "undefined"
    else
        return tostring(str) or "<?>"
    end
end