local TextElement = {}
function TextElement:__call(parent, bo)
    class.Element.__call(self, parent, bo)
    
    self.value = ""
    self.container = new(class.Fluid)
	
	return self
end
<<<<<<< HEAD

function TextElement:setTag(t) end--Override for speed
function TextElement:calcSize(queue, stack, globals)
=======
function TextElement:calcSize(queue, stack)
>>>>>>> 5e31b6e3e8c69ea390214d1d6c76189af8e4946d
	self.pcont = stack:peek()
    self.container(self.pcont, self.browserObject)
	self.pointer = new(class.Pointer)(self.container.pointer)
    self.container:flow(#self.value)
	
	self.parent.container:add(self.container)
end
function TextElement:placeProposals(queue)
	local window = self.pcont.window
<<<<<<< HEAD
	local tFlow = new(class.Fluid)(self.pcont, self.browserObject, self.pointer)
	for i=1, #self.value do
		tFlow:flow(1)
		window:proposeTextHandler(
			tFlow.length, tFlow.height+self.pointer.y, 
			string.sub(self.value, i, i))
		window:proposeFGHandler(
			tFlow.length, tFlow.height+self.pointer.y, 
			self:getShared("textColor") or colors.black)
=======
	local tFlow = new(class.Fluid)(self.pcont, self.browserObject)
	for i=1, #self.value do
		tFlow:flow(1)
		window:proposeTextHandler(
			fluid.length, fluid.height+self.pointer.y, 
			string.sub(self.value, i, i))
>>>>>>> 5e31b6e3e8c69ea390214d1d6c76189af8e4946d
	end
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end