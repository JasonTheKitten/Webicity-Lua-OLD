local Element = {}
function Element:__call(parent)
    self.children = {}
    self.attributeContainer = 
        new(class.AttributesContainer)(parent.AttributesContainer)
    self.container = new(class.ElementRect)
    if parent then
        parent:addChild(self)
        self.parent = parent
    end
    
    return self
end
function Element:calcSize(queue, stack)
    self.container(self.parent)
    
    stack.push(self.container)
    if self.window then
        stack.push(new(class.ElementRect)(self.container,
            self.window))
    end
    for i=#self.children, 1, -1 do
        queue.push(self.children[i])
    end
end
function Element:placeProposals(queue)
    for i=#self.children, 1, -1 do
        queue.push(self.children[i])
    end
end
function Element:addChild(child)
    table.insert(self.children, child)
end

return Element, function()
    Element.cparents = {class.Class}
end