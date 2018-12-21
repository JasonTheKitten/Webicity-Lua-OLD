local BRElement = {}

function BRElement:__call(parent, bo, api)
    class.Element.__call(self, parent, bo, api)
    self.container = new(class.Fluid)
	
	return self
end

function BRElement:calcSize(queue, stack, globals)
	self.container(stack:peek(), self.browserObject, nil, 1, 1)
	self.parent.container:add(self.container)
	globals.enableSpace = false
end
function BRElement:placeProposals(queue) end

return BRElement, function()
	BRElement.cparent = class.Element
end