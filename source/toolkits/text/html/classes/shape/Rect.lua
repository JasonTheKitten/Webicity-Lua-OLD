local Rect = {}
function Rect:__call(x, y, l, h)
    if (type(x) == table) and x:isA(class.Pointer) then
        self.x, self.y, self.length, self.height =
            x.x, x.y, y, l
        
        return self
    end
    self.x, self.y, self.length, self.height =
        x, y, l, h
        
    return self
end
function Rect:__add(class)
    if type(class) ~= "table" then
        error("Attempt to add non-Class to Rect", 2)
    end
    if class:isA(class.BoundRect) then
        return new(Rect)(self.x, self.y, self.length, self.height)
    elseif class:isA(Rect) then
        local x, y = class.x, class.y
        if class.x+class.length > self.length then
           x, y = 0, y+1
        end
        
        local length, height = self.length, self.height
        if x+class.length > self.length then length = x+class.length end
        if y+class.height > self.height then heigth = y+class.height end
        
        return new(Rect)(x, y, length, height)
    elseif class:isA(class.Fluid) then
        return new(Rect)(
            self.x, self.y, 
            ((self.length > class) and self.length) or Fluid.length,
            self.height + Fliud.height)
    else
        error("Attempt to add incompatible class to Rect", 2)
    end
    
    return self
end
function Rect:willWrapOnAdd(class)
    if type(class) ~= "table" then return false end
    if class:isA(class.BoundRect) then
        return false
    elseif class:isA(Rect) then
        if class.x+class.length > self.length then
           return true
        end
        return false
    else
        return false
    end
end

return Rect, function()
    Rect.cparents = {class.Class}
end