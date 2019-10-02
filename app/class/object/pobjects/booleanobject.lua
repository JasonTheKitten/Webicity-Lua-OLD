local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")
local Object = object.Object

local booleanobject = ...

local BooleanObject = {}
booleanobject.BooleanObject = {}

BooleanObject.cparents = {Object}
BooleanObject.__call = Object.__call

function BooleanObject:installFields()
    self:setraw("__proto__", Object:getStatic("Object"))
end

booleanobject.valueof = function(value)
    return value~=nil --and value~=object.getstatic("null") and value~=false and stuff
end