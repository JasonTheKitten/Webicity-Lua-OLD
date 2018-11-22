local TextElement = {}
function TextElement:__call(parent, bo)
    class.Element.__call(self, parent)
    
    self.value = ""
    self.container = new(class.Fluid)
	self.browserObject = bo
	
	return self
end
function TextElement:calcSize(queue, stack)
	print(class.ElementRect:isA(stack:peek()))
    self.container(stack:peek(), stack:peek().pointer, nil, nil, self.browserObject)
    self.container:flow(#self.value)
	
	self.parent.container = self.parent.container + self.container
end
function TextElement:placeProposals(queue)
    
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end