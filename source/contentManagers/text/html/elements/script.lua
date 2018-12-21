local ScriptElement = {}
function ScriptElement:__call(parent, bo)
    class.Element.__call(self, parent, bo)
	
	return self
end

--Override for the sake of speed
function ScriptElement:calcSize(queue, stack) end
function ScriptElement:placeProposals(queue) end
function ScriptElement:addChild(child) end

return ScriptElement, function()
    ScriptElement.cparent = class.Element
end