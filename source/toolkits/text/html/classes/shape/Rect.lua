local Rect = {}
function Rect:__call(x, y, l, h)
    if (type(x) == table) and x:isA(aclass.Pointer) then
        self.x, self.y, self.length, self.height =
            x.x, x.y, y, l
			
		if not self.length then error("", 2) end
        
        return self
    end
    self.x, self.y, self.length, self.height =
        x, y, l, h
		
	if not self.length then error("", 2) end
        
    return self
end
function Rect:__add(aclass)
	if not self.length then error("", 3) end
    if type(aclass) ~= "table" then
        error("Attempt to add non-aclass to Rect", 2)
    end
    if aclass:isA(class.BoundRect) then
        return new(Rect)(self.x, self.y, self.length, self.height)
    elseif aclass:isA(Rect) then
        local x, y = aclass.x, aclass.y
        if aclass.x+aclass.length > self.length then
           x, y = 0, y+1
        end
        
        local length, height = self.length, self.height
        if x+aclass.length > self.length then length = x+aclass.length end
        if y+aclass.height > self.height then heigth = y+aclass.height end
        
        return new(Rect)(x, y, length, height)
    elseif aclass:isA(class.Fluid) then
        return new(Rect)(
            self.x, self.y, 
            ((self.length > aclass.length) and self.length) or aclass.length,
            self.height + aclass.height)
    else
        error("Attempt to add incompatible aclass to Rect", 2)
    end
    
    return self
end
function Rect:willWrapOnAdd(aclass)
    if type(aclass) ~= "table" then return false end
    if aclass:isA(aclass.BoundRect) then
        return false
    elseif aclass:isA(Rect) then
        if aclass.x+aclass.length > self.length then
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