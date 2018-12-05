local Rect = {}
function Rect:__call(...)
    --<parent/x,y>, [position], l, h, pointer, window
    local args = {...}
    if type(args[1]) == "table" then
		if args[1]:isA(class.Pointer) then
			self.pointer = args[1]
		else
			self.parent = args[1]
			self.pointer = self.parent.pointer
		end
        self.x = (self.pointer and self.pointer.x) or 0
        self.y = (self.pointer and self.pointer.y) or 0
    else
        self.x, self.y = args[1], args[2]
        table.remove(args, 1)
    end
	table.remove(args, 1)
    if type(args[1]) == "table" then
        --Override parent vs position
        self.pointer = args[1]
        self.x = (self.pointer and self.pointer.x) or 0
        self.y = (self.pointer and self.pointer.y) or 0
		table.remove(args, 1)
    end
    
    --Default l/h
    self.length, self.height = args[1] or 0, args[2] or 0
    
    --Pointer and window
    self.pointer, self.window = args[3] or self.pointer, args[4] 
		
    return self
end
function Rect:__add(aclass)
	error("", 2)
	return self:copy()+aclass
end
function Rect:add(aclass)
    if type(aclass) ~= "table" then
        error("Attempt to add non-class to Rect", 2)
    end
    if aclass:isA(Rect) then
        if aclass.window then return end
        if self:willWrapOnAdd(aclass) then
            if self.pointer then
                self.pointer.x = self.x
                self.pointer.y = self.pointer.y+1
            end
            self.height = self.height+1
        end
        if self.pointer then
            self.pointer = self.pointer+aclass
        end
        if aclass.length>self.length then
            self.length = aclass.length
        end
        self.height = self.height+aclass.height
    elseif aclass:isA(class.Fluid) then
		self.pointer = self.pointer+aclass
		self.length = ((self.length > aclass.length) and self.length) or aclass.length
		self.height = self.height + aclass.height
    else
        error("Attempt to add incompatible class to Rect", 2)
    end
end
function Rect:willWrapOnAdd(aclass)
    return 
        (type(aclass) == "table") and 
        aclass:isA(Rect) and 
        (not aclass.window) and 
        (aclass.x+aclass.length > self.length)
end

function Rect:copy()
    return new(Rect)(
        self.parent or (new(class.Pointer)(0,0)), 
        new(class.Pointer)(self.x, self.y),
        self.length, self.height,
        self.pointer, self.window)
end

return Rect, function()
    Rect.cparents = {class.Shape}
end