local ElementRect = {}

function ElementRect:__call(parent, window, pointer, x, y, l, h)
    local ppointer = parent.pointer
    x = x or (window and 0)
    y = y or (window and 0)
    class.BoundRect.__call(self, window or parent.window, 
        x or ppointer.x, y or ppointer.y, 
        l or 0, h or 0)
    self.pointer = pointer or new(class.Pointer)(0, 0)
end
function ElementRect:__add(obj)
    if obj:isA(class.Rect) then
        if (obj.window and obj.window~=self.window) then
            return end
        if obj.pointer ~= self.pointer then
            return class.BoundRect.__add(self, obj) 
        end
        if self:willWrapOnAdd(obj) then
            self.pointer.y = self.pointer.y+1
            self.pointer.x = 0
        end
        self.pointer = self.pointer+obj
        class.BoundRect.__add(obj)
    elseif obj:isA(class.Fluid) then
        self.pointer = self.pointer+obj
        class.BoundRect.__add(obj)
    end
end

return ElementRect, function()
    ElementRect.cparents = {class.BoundRect}
end