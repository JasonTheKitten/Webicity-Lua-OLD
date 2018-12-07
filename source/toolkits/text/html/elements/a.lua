local AElement = {}
function AElement:__call(parent, bo)
    eclass.Element.__call(self, parent, bo)
	self.textC1 = new(eclass.TextElement)(parent, bo)
	self.textC1.value = "_"
	self.textC2 = new(eclass.TextElement)(parent, bo)
	self.textC2.value = "_"
	
	return self
end

function AElement:calcSize(queue, stack)
	if not (self.finalizeSize or self:getShared("underline"))  then
		queue:push(self.textC2)
	end
	self.parent.calcSize(self, queue, stack)
	if self.finalizeSize then return end
	if not self:getShared("underline") then
		queue:push(self.textC1)
	end
	self.shared = {
		textColor = colors.blue,
		underline = true
	}
end
function AElement:placeProposals(queue)
	self.textC1:placeProposals(queue)
	self.textC2:placeProposals(queue)
	eclass.Element.placeProposals(self, queue)
end

return AElement, function()
    AElement.cparents = {eclass.Element}
end