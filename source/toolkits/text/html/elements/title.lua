local TitleElement = {}
function TitleElement:__call(parent, bo)
    eclass.Element.__call(self, parent, bo)
	
	return self
end

function TitleElement:calcSize(queue, stack) 
	if self.browserObject.request.handlers["title-set"] then
		self.browserObject.request.handlers["title-set"]({name = self.value})
	end
end

--Override for the sake of speed
function TitleElement:placeProposals(queue) end
function TitleElement:addChild(child) end

return TitleElement, function()
    TitleElement.cparents = {eclass.Element}
end