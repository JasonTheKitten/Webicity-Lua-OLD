local TextElement = {}
function TextElement:__call(parent, bo)
    class.Element.__call(self, parent)
    
    self.value = ""
    self.container = new(class.Fluid)
	self.browserObject = bo
	
	return self
end
function TextElement:calcSize(queue, stack)
    self.container(stack:peek(), self.browserObject)
	self.position = self.container.pointer
    self.container:flow(#self.value)
	
	self.parent.container:add(self.container)
end
function TextElement:placeProposals(queue)
    print(self.position.x, ",", self.position.y, ":", self.value)
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end