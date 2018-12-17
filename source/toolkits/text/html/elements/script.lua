local ScriptElement = {}
function ScriptElement:__call(parent, bo)
    eclass.Element.__call(self, parent, bo)
	
	return self
end

--Override for the sake of speed
function ScriptElement:calcSize(queue, stack) end
function ScriptElement:placeProposals(queue) end
function ScriptElement:addChild(child) end

return ScriptElement, function()
    ScriptElement.cparents = {eclass.Element}
end