local ribbon = require()

local class = ribbon.require "class"

local object = ribbon.reqpath("${CLASS}/object/object")
local Object = object.Object

local ObjectObject = ...

local ObjectObject = {}
objectobject.ObjectObject = ObjectObject

--We need to import/require other objects *after* we define our object
--local FunctionObject = ribbon.reqpath("${CLASS}/object/pobjects/functionobject").FunctionObject

ObjectObject.cparents = {Object}
ObjectObject.__call = Object.__call

function ObjectObject:installFields()
    self:setraw("__proto__", Object.null)
    
    self.cache.get("Object", self)
end