local TextElement = {}
function TextElement:__call(parent, bo, skipAddC)
    class.Element.__call(self, parent, bo, skipAddC)
    
    self.value = ""
    self.container = new(class.Fluid)
	
	return self
end

TextElement.whitespace = {
    ["\n"] = true, [" "] = true, ["\t"] = true
}
function TextElement:setTag(t) end--Override for speed
function TextElement:calcSize(queue, stack, globals)
	self.pcont = stack:peek()
	print(self.pcont)
    self.container(self.pcont, self.browserObject)
	self.pointer = new(class.Pointer)(self.container.pointer)
	self.fValue = self.value
	if self.whitespace[string.sub(self.fValue, 1, 1)] and not globals.enableSpace then
		self.fValue = string.sub(self.fValue, 2)
	end
	globals.enableSpace = (not self.whitespace[string.sub(self.value, #self.value)]) 
		and (self.value~="" or globals.enableSpace)
    self.container:flow(#self.fValue)
	
	self.parent.container:add(self.container)
end
function TextElement:placeProposals(queue)
	local window = self.pcont.window
	local tFlow = new(class.Fluid)(self.pcont, self.browserObject, self.pointer)
	for i=1, #self.fValue do
		window:proposeTextHandler(
			tFlow.length, tFlow.height+self.pointer.y, 
			string.sub(self.fValue, i, i))
		window:proposeFGHandler(
			tFlow.length, tFlow.height+self.pointer.y, 
			self:getShared("textColor") or colors.black)
		window:proposeClickHandler(
			tFlow.length, tFlow.height+self.pointer.y, 
			function(x, y) self:handleClick(x, y) end)
		tFlow:flow(1)
	end
end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {class.Element}
end