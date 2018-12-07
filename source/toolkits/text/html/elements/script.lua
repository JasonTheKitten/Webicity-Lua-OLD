local TextElement = {}
function TextElement:__call(parent, bo)
    eclass.Element.__call(self, parent, bo)
	
	return self
end

--Override for the sake of speed
function TextElement:calcSize(queue, stack) end
function TextElement:placeProposals(queue) end
function TextElement:addChild(child) end

return TextElement, function()
    TextElement.cparents = {eclass.Element}
end