local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")
local Object = object.Object

local functionobject = {...}

local FunctionObject = {}
functionobject.FunctionObject = FunctionObject

FunctionObject.cparents = {Object}
function FunctionObject:__call(engine, frame, pointer)
    Object.__call(self)
    self.functionData = {engine = engine, frame=frame, pointer=pointer}
end

function FunctionObject:invoke(argstack, this)

end
function PFunctionObject:call(this, ...)
    return self:invoke(class.new(self.ArgumentStack, {...}), this)
end

function Object:getType()
    return "function"
end
function Object:getName()
    return self.name or "AnonymousFunction"
end

function Object:toString()
    return self:getType().." "..self:getName().."(){ [...] }"
end

local ArgumentStack = {}
FunctionObject.ArgumentStack = ArgumentStack

ArgumentStack.cparents = {class.Class}
function ArgumentStack:__call(args)
    self.arguments = args or {}
    self.depth = #self.arguments
end
function ArgumentStack:push(v)
    self.depth = self.depth+1
    self.arguments[depth] = v
end
function ArgumentStack:get(d)
    return self.arguments[d]
end
function ArgumentStack:depth(d)
    if d then self.depth = d else return self.depth end
end
function ArgumentStack:depthMin(d)
    if self.depth<d then self.depth = d end
end