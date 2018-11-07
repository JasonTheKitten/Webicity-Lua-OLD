local Element = {}
function Element:__call(parent, bo)
	self.children = {}
	self.browserObject = bo
    --[[self.attributeContainer = 
        new(class.AttributesContainer)(parent.AttributesContainer)]]
    if parent then
        parent:addChild(self)
        self.parent = parent
	end
    
    return self
end
function Element:calcSize(queue, stack)
	if self.finalizeSize then
		self.parent.container = self.parent.container + self.container
		self.finalizeSize = nil
	
		return
	end
	
    if self.parent then
		self.container = new(class.ElementRect)(self.parent.container)
		self.finalizeSize = true
	else
		self.container = new(class.ElementRect)(nil, self.browserObject.request.page.window, nil, 0, 0)
    end
    
    stack:push(self.container)
    if self.window then
        stack:push(new(class.ElementRect)(self.container,
            self.window))
    end
	
	if self.parent then queue:push(self) end
    for i=#self.children, 1, -1 do
        queue:push(self.children[i])
    end
end
function Element:placeProposals(queue)
    for i=#self.children, 1, -1 do
        queue:push(self.children[i])
    end
end
function Element:addChild(child)
    table.insert(self.children, child)
end

return Element, function()
    Element.cparents = {class.Class}
end