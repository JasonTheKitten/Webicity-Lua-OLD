local BRElement = {}

function BRElement:__call(parent, bo, api)
    eclass.Element.__call(self, parent, bo, api)
    self.container = new(eclass.Fluid)(parent.container, bo, api, 1, 1)
	
	return self
end

function BRElement:calcSize(queue, stack)
	self.parent.container:add(self.container)
end
function BRElement:placeProposals(queue) end

return BRElement, function()
	BRElement.cparents = {eclass.Element}
end