local ribbon = require()

local class = ribbon.require "class"

local PFunctionObject = ribbon.reqpath("${CLASS}/object/pobjects/pfunctionobject").PFunctionObject

local property = ...

local Property = {}
property.Property = property

property.cparents = {class.Class}
function Property:__call(data)
    local value = data.value
    if type(value) == "function" then
        value = class.new(PFunctionObject, value)
    end
    self.value = value
    self.immutable = data.configurable
    self.enumerable = data.enumerable
    self.writable = data.writable
    self.getter = data.getter
    self.setter = data.setter
end