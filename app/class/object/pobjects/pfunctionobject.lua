local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")

local FunctionObject = ribbon.reqpath("${CLASS}/object/pobjects/functionobject").FunctionObject
local Object = object.Object

local pfunctionobject = ...

local PFunctionObject = {}
pfunctionobject.PFunctionObject = PFunctionObject

PFunctionObject.cparents = {FunctionObject}
local function PFunctionObject:__call(nativefunc)
    FunctionObject.__call(self)
    self.functionData = nativefunc
end

function PFunctionObject:installFields()
    self:setraw("__proto__", object.getstatic("Object"))
end

function PFunctionObject:invoke(argstack, this)
    return self.functionData(argstack, this)
end

function Object:toString()
    return self:getType().." "..self:getName().."(){ [native code] }"
end