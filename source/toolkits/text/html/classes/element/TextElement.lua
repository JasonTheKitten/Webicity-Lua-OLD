local TextElement = {}
function TextElement:__call(parent, text)
    class.Element.__call(self, parent, false)
    
    self.text = text
    self.Rect = new(class.Fluid)
end
function Element:calcSize(queue, stack)
    self.fluid(stack:peek().Rect, stack:peek().Pointer)
    self.fluid:flow(#self.text)
end
function Element:placeProposals(queue)
    
end
function Element:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end