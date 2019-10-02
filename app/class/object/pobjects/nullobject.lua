local ribbon = require()

local class = ribbon.require "class"

local nullobject = ...

local NullObject = {}
nullobject.NullObject = NullObject

NullObject.cparents = {class.Class}
NullObject.__call = Object.__call

function NullObject:installFields() end

