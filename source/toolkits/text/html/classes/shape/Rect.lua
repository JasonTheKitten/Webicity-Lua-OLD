local Rect = {}
function Rect:__call(...)
    --Parent, position, l, h, pointer, window
    local args = {...}
    if type(args[1]) == "table" then
        self.parent = args[1]
        self.pointer = self.parent.pointer
        self.x = (self.pointer and self.pointer.x) or 0
        self.y = (self.pointer and self.pointer.y) or 0
    else
        self.x, self.y = args[1], args[2]
        table.remove(args, 1)
    end
    if type(args[1]) == "table" then
        --Override parent vs position
        self.pointer = args[1]
        self.x = (self.pointer and self.pointer.x) or 0
        self.y = (self.pointer and self.pointer.y) or 0
        table.remove(args, 1)
    end
    table.remove(args, 1)
    
    --Default l/h
    self.length, self.height = args[1] or 0, args[2] or 0
    
    --Pointer and window
    self.pointer, self.window = args[3] or self.pointer, args[4]
        
    return self
end
function Rect:__add(aclass)
    if type(aclass) ~= "table" then
        error("Attempt to add non-class to Rect", 2)
    end
    if aclass:isA(Rect) then
        local sum = new(Rect)
        if aclass.window then 
            return self:copy()
        end
        if sum:willWrapOnAdd(aclass) then
            if sum.pointer then
                sum.pointer.x = self.x
                sum.pointer.y = sum.pointer.y+1
            end
            sum.height = sum.height+1
        end
        if sum.pointer then
            sum.pointer = sum.pointer+aclass
        end
        if sum.pointer.x-self.x>self.length then
            self.length = sum.pointer.x-self.x
        end
        self.height = sum.pointer.y-self.y
    elseif aclass:isA(class.Fluid) then
        return new(Rect)(
            self.x, self.y, 
            ((self.length > aclass.length) and self.length) or aclass.length,
            self.height + aclass.height)
    else
        error("Attempt to add incompatible class to Rect", 2)
    end
end
function Rect:getAtt(name)
    if self[name] then
        return self[name]
    elseif self.parent then
        return self.parent:getAtt(name)
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
        self.parent, 
        new(class.Pointer)(self.x, self.y),
        self.length, self.height,
        self.pointer, self.window)
end

return Rect, function()
    Rect.cparents = {class.Shape}
end