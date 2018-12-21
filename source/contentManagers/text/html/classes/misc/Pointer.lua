--Pointer
--Represents a postion
local Pointer = {}
function Pointer:__call(x, y) --init
    if (type(x) == "table") and x:isA(Pointer) then
        self.x, self.y = x.x, x.y
    else
        self.x, self.y = x, y
    end
    
    return self
end

function Pointer:__add(obj) --Invoked on +
	return new(Pointer)(self.x, self.y):add(obj)
end

function Pointer:add(obj, y)
	if type(obj) == "number" then
		self.x = self.x+obj
		self.y = self.y+y
		return self
	end
	if obj:isA(class.Rect) then
        self.x = self.x + obj.length
        self.y = self.y + obj.height-1
    elseif obj:isA(class.Fluid) then
        self.x = obj.length
        self.y = self.y + obj.height
    end
	return self
end

function Pointer:__eq(obj)
    return ((self.x == obj.x) and (self.y == obj.y))
end

return Pointer, function()
    Pointer.cparent = class.Class
end