local Fluid = {}
function Fluid:__call(container, bo, position, l, h)
    self.length, self.height = l or 0, h or 0
    self.container, self.pointer = container, new(class.Pointer)(position or container.pointer)
	self.browserObject = bo
    
    return self
end
function Fluid:flow(times)
	self.length, self.height = self.pointer.x, 0
    local function incPosY()
        if self.length>self.browserObject.request.page.rl then
            self.length, self.height = self.container.x, self.height+1
        end
    end
    incPosY()
    for i=0, times-1 do
        self.length = self.length+1
        incPosY() 
        i = i+1
    end
	self.pointer.x, self.pointer.y = self.length, self.pointer.y+self.height
end
function Fluid:reset()
    self.length, self.height = 0, 0
end
function Fluid:__add()
    --return new(Fluid)(self.container, self.position)
end

return Fluid, function()
    Fluid.cparents = {class.Shape}
end