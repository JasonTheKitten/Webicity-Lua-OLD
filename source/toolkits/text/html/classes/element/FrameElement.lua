local FrameElement = {}
function FrameElement:__call(parent)
    class.Element.__call(self, parent)
    self.window = new(class.Frame)()
    
    return self
end

return FrameElement, function()
    FrameElement.cparents = {class.Element}
end