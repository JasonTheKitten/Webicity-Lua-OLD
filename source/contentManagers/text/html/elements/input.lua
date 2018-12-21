local AElement = {}
function AElement:__call(parent, bo, api)
    class.Element.__call(self, parent, bo, api)
	self.textC = new(class.TextElement)(self, bo, true)
	self.textC.value = " :INPUT: "
	
	return self
end

function AElement:calcSize(queue, stack, globals)
	class.Element.calcSize(self, queue, stack, globals)
	if self.finalizeGraphics then
		queue:push(self.textC)
	end
end

return AElement, function()
    AElement.cparent = class.Element
end