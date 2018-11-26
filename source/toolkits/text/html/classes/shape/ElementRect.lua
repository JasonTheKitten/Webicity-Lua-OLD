local ElementRect = {}

function ElementRect:__call(parent, window, pointer, x, y, l, h)
	local ppointer = (parent and parent.pointer) or new(class.Pointer)(0,0)
	self.pointer = new(class.Pointer)(x or ppointer.x or 0, y or ppointer.y or 0)
    class.BoundRect.__call(self, window or parent.window, 
        self.pointer.x, self.pointer.y, 
        l or 0, h or 0)

	return self
end
function ElementRect:__add(obj)
	local sum = new(ElementRect)(
		nil, self.window, nil,
		self.x, self.y, self.length, self.height)
    if (obj.window and obj.window~=self.window) then-- or (obj.pointer and obj.pointer ~= self.pointer) then
        return sum end
    if obj:isA(class.Rect) and self:willWrapOnAdd(obj) then
        sum.pointer.y = sum.pointer.y+1
        sum.pointer.x = 0
    end
    sum.pointer = sum.pointer+obj
	if sum.pointer.x > sum.length then
		sum.length = sum.pointer.x
	end
	if sum.pointer.y > sum.height then
		sum.height = sum.pointer.y
	end
    return sum
end

return ElementRect, function()
    ElementRect.cparents = {class.BoundRect}
end