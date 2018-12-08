local Element = {}
function Element:__call(parent, bo, skipAddC)
	self.children = {}
	self.browserObject = bo
    --[[self.attributeContainer = 
        new(class.AttributesContainer)(parent.AttributesContainer)]]
    if parent then
        if not skipAddC then parent:addChild(self) end
        self.parent = parent
	end
    
    return self
end

function Element:setTag(t)
    self.tag = t
end
function Element:getShared(name)
	local el = self
	while el do
		if el.shared and el.shared[name] then
			return el.shared[name]
		end
		el = el.parent
	end
end
function Element:calcSize(queue, stack, globals)
	if self.finalizeSize then
		self.parent.container:add(self.container)
		self.finalizeSize = nil
	
		return
	end
	
	if not self.parent then
		self.shared = {}
	end
    
    self.container = stack:peek()
	self.position = self.container.pointer
	if self.parent and (self.container~=self.parent.container) then
		self.finalizeSize = true
	    queue:push(self)
    end
	
    for i=#self.children, 1, -1 do
        queue:push(self.children[i])
    end
end
function Element:placeProposals(queue)
    for i=#self.children, 1, -1 do
        queue:push(self.children[i])
    end
end
function Element:handleClick(x, y)
	if self.onClick then
		self:onClick(x, y)
	end
	if self.parent and self.parent.handleClick then
		self.parent:handleClick(x, y)
	end
end
function Element:addChild(child)
    table.insert(self.children, child)
end

return Element, function()
    Element.cparents = {class.Class}
end