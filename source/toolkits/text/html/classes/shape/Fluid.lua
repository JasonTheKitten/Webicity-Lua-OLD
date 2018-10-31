local Fluid = {}
function Fluid:__call(container, position)
    self.length, self.height = 0, 0
    self.container, self.position = container, position
    
    return self
end
function Fluid:flow(times)
    local curPos = new(class.Pointer)(self.position)
    local function incPosY()
        if curPos.x>self.container.length then
            curPos.x = 0
            curPos.y = curPos.y+1
            self.height = self.height+1
            self.length = 0
        end
    end
    incPosY()
    local i = 0
    while i < times do --For loops make me uneasy
        curPos.x = curPos.x+1
        self.length = self.length+1
        incPosY()
        i = i+1
    end
end
function Fluid:reset()
    self.length, self.height = 0, 0
end

return Fluid, function()
    Fluid.cparents = {class.Class}
end