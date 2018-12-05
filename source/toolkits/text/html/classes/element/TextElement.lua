local TextElement = {}
function TextElement:__call(parent, bo)
    class.Element.__call(self, parent)
    
    self.value = ""
    self.container = new(class.Fluid)
	self.browserObject = bo
	
	return self
end
function TextElement:calcSize(queue, stack)
	self.pcont = stack:peek()
    self.container(self.pcont, self.browserObject)
	self.pointer = new(class.Pointer)(self.container.pointer)
    self.container:flow(#self.value)
	
	self.parent.container:add(self.container)
end
function TextElement:placeProposals(queue)
	local window = self.pcont.window
	local tFlow = new(class.Fluid)(self.pcont, self.browserObject)
	for i=1, #self.value do
		tFlow:flow(1)
		window:proposeTextHandler(
			fluid.length, fluid.height+self.pointer.y, 
			string.sub(self.value, i, i))
	end
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end