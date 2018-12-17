local AElement = {}
function AElement:__call(parent, bo, api)
    eclass.Element.__call(self, parent, bo, api)
	self.textC = new(eclass.TextElement)(self, bo, true)
	self.textC.value = " :INPUT: "
	
	return self
end

function AElement:calcSize(queue, stack, globals)
	eclass.Element.calcSize(self, queue, stack, globals)
	if self.finalizeGraphics then
		queue:push(self.textC)
	end
end

return AElement, function()
    AElement.cparents = {eclass.Element}
end