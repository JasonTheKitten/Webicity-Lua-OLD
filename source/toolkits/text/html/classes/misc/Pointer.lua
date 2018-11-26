local Pointer = {}
function Pointer:__call(x, y)
    if (type(x) == "table") and x:isA(Pointer) then
        self.x, self.y = x.x, x.y
    else
        self.x, self.y = x, y
    end
    
    return self
end

function Pointer:__add(obj)
	local sum = new(Pointer)(self.x, self.y)
    if obj:isA(class.Rect) then
        sum.x = sum.x + obj.length
        sum.y = sum.y + obj.height-1
    elseif obj:isA(class.Fluid) then
        sum.x = obj.length
        sum.y = sum.y + obj.height
    end
	return sum
end

function Pointer:__eq(obj)
    return ((self.x == obj.x) and (self.y == obj.y))
end

return Pointer, function()
    Pointer.cparents = {class.Class}
end