--[[local base = {}
base.new = function(self, browser, data)
    local cls = {}
    setmetatable(cls, {__index = base})
    
    if not (cls.content and cls.type) then 
        error("Content, type, or both missing", 2)
    end
    
    local toolkit = browser:loadfile("toolkits/"..cls.type.."/api.lua", true)
    if not toolkit then error() end
    
    return cls
end

base.setWindow = function(self, framewindow)
    self.window = window
    self:redraw()
end

base.redraw = function(self)
    
end

return base]]