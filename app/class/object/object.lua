--TODO: Consider FunctionObjects and NumberObjects and Stuff
local ribbon = require()

local class = ribbon.require "class"

local object = ...

local Object = {}
object.Object = Object

Object.cparents = {class.Class}
function Object:__call(prototype)
    self.fields = {}
	self.info = {}
    self.readonly = {}
    self.getters = {}
    self.setters = {}
    self.__proto__ = prototype
    self.iswritable = true
    
    self:installFields()
end

function Object:installFields()
    self.getters["__proto__"] = function()
        return self.__proto__
    end
end

function Object:setraw(get, set)
    self.fields[get] = set
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

function Object:field(get, set)
    if set then
        self:setraw(get, set)
    end
    return {
        readonly = function()
            Object:readonly(set)
        end,
        getter = function(f)
            Object:getter(set, f)
        end
    }
end
function Object:set(get, set)
    if self.readonly[get] or not self.isWritable then
    elseif self.setters[get] then
        self.setters[get](get, set)
    elseif self.defaultSetter then
        self.defaultSetter(get, set)
    end
end
function Object:get(get)
    if self.getters[get] then
        return self.getters[get]
    elseif self.fields[get] then
        return self.fields[get]
    elseif self.__proto__ then
        return self.__proto__:get(get)
    --[[elseif self.defaultGetter then
        return self.defaultGetter(get)]]
    else
        return UndefinedObject --TODO
    end
end

function Object:readonly(k)
    if k then
        self.readonly[k] = true
    else
        self.iswritable = false
    end
end
function Object:getter(k, f)
    
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
    return class.new(NaNObject)
end
function Object:toBoolean()
    return true
end

function Object:equals(obj)
    return self == obj
end
function Object:checklt()

end
function Object:checkgt()

end

function Object:add()
    error("Addition on object")
end
function Object:subtract()
    error("Subtraction on object")
end