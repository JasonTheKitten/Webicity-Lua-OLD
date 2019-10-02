--TODO: Consider FunctionObjects and Stuff
local ribbon = require()

local class = ribbon.require "class"

local property = ribbon.reqpath("${CLASS}/object/property").Property

local object = ...

local Object = {}
object.Object = Object

--Defered imports
local ObjectObject = ribbon.reqpath("${CLASS}/object/pobjects/objectobject").ObjectObject

Object.cparents = {class.Class}
function Object:__call(cache)
    self.fields = {}
    self.properties = {}
	self.info = {}
    self.frozen = false
    
    self.cache = cache
    
    self:installFields()
end

function Object:installFields()
    self:setraw("__proto__", object.getstatic("Object", ObjectObject))
end

function Object:setraw(get, set)
    self.fields[get] = set
end
function Object:setrawm(...)
    local args = ...
    for i=1, #args, 2 do
        self.fields[args[i]] = args[i+1]
    end
end
function Object:getraw(get)
    return self.fields[get]
end

function Object:setinfo(get, set)
    self.info[get] = set
end
function Object:getinfo(get)
    return self.info[get]
end

function Object:set(get, set)
    if self.frozen then return end
    if self.properties[get] then
        if not self.properties[get].writable then return end
        if self.properties[get].set then self.properties[get].set(set) end
    end
    self.fields[get] = set
end
function Object:get(get)
    if self.properties[get] then
        if self.properties[get].get then
            local func = self.properties[get].get
            if type(func) == "function" then
                return func()
            else
                return func:invoke()
            end
        end
        if self.properties[get].value then return self.properties[get].value end
    end
    if self.fields[get] then
        return self.fields[get]
    elseif self.fields["__proto__"] then
        return self.fields["__proto__"]:get(get)
    end
end

function Object:setproperty(get, set)
    if self.properties[get] and not self.properties[get].configurable then return end
    self.properties[get] = class.new(Property, set)
end

function Object:freeze()
    self.frozen = true
end

function Object:getType()
    return "object"
end
function Object:getName()
    return self.name or "Object"
end

function Object:toString()
    return "["..self:getObjectType().." "..self:getName().."]"
end
function Object:toNumber()
    return 0/0
end