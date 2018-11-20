local ElementRect = {}

function ElementRect:__call(parent, window, pointer, x, y, l, h)
    local ppointer = (parent and parent.pointer)
    x = x or ((not parent) and 0)
    y = y or ((not parent) and 0)
    class.BoundRect.__call(self, window or parent.window, 
        x or ppointer.x, y or ppointer.y, 
        l or 0, h or 0)
    self.pointer = pointer or new(class.Pointer)(0, 0)
	
	return self
end
function ElementRect:__add(obj)
	print("ADD")
    if obj:isA(class.Rect) then
        if (obj.window and obj.window~=self.window) then
            return self end
        if obj.pointer ~= self.pointer then
            return class.BoundRect.__add(self, obj) 
        end
        if self:willWrapOnAdd(obj) then
            self.pointer.y = self.pointer.y+1
            self.pointer.x = 0
        end
        self.pointer = self.pointer+obj
        return class.BoundRect.__add(self, obj)
    elseif obj:isA(class.Fluid) then
        self.pointer = self.pointer+obj
        return class.BoundRect.__add(self, obj)
    end
end

return ElementRect, function()
    ElementRect.cparents = {class.BoundRect}
end