local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")
local Object = object.Object

local numberobject = ...

local NumberObject = {}
numberobject.NumberObject = {}

NumberObject.cparents = {Object}
NumberObject.__call = Object.__call

function NumberObject:installFields()
    self:setraw("__proto__", Object:getStatic("Object"))
end

numberobject.valueof = function(n)
    if type(n) == "number" then
        return n
    elseif type(n) == "table" then
        return n:toNumber()
    else
        return 0/0
    end
end
numberobject.isNormal = function(n)
    return n~=1/0 and n~=0/0
end