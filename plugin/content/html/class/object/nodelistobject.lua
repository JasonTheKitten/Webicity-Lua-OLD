local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath "${CLASS}/object/object"
local Object = object.Object

local numberobject = ribbon.reqpath "${CLASS}/object/pobjects/numberobject"

local NodeListObject = ...

local NodeListObject = {}
nodelistobject.NodeListObject = NodeListObject

NodeListObject.cparents = {Object}
function NodeListObject:__call(cache)
    self.nodes = {}
    Object.__call(self, cache)
end

function NodeListObject:installFields()
    self:setraw("__proto__", object.getstatic("Object"))
    
    self:setraw("item", class.new(PFunctionObject, function(argstack, this)
        argstack:depth(1)
        local index = numberobject.valueof(argstack:pop())
        if not numberobject.isNormal(index) then return end --TODO: Exception?
        
        return self.nodes[index] or cache.get("Null")
    end))
    
    self:setproperty("length", {
        get = function()
            return #self.nodes
        end
    })
    
    //TODO: Iterator
end