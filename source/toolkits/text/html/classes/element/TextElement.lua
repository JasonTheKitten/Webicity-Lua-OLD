local TextElement = {}
function TextElement:__call(parent)
    class.Element.__call(self, parent, false)
    
    self.value = ""
    self.container = new(class.Fluid)
	
	return self
end
function TextElement:calcSize(queue, stack)
    self.container(stack:peek(), stack:peek().pointer)
    self.container:flow(#self.value)
	
	self.parent.container = self.parent.container + self.container
end
function TextElement:placeProposals(queue)
    
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end