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
    if obj:isA(class.Rect) then
        self.x = self.x + obj.length
        self.y = self.y + obj.height-1
    elseif obj:isA(class.Fluid) then
        self.x = obj.length
        self.y = self.y + obj.height
    end
end

function Pointer:__eq(obj)
    return ((self.x == obj.x) and (self.y == obj.y))
end

return Pointer, function()
    Pointer.cparents = {class.Class}
end