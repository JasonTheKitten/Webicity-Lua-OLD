local AElement = {}
function AElement:__call(parent, bo, api)
    eclass.Element.__call(self, parent, bo, api)
	self.textC1 = new(eclass.TextElement)(self, bo, true)
	self.textC1.value = "_"
	self.textC2 = new(eclass.TextElement)(self, bo, true)
	self.textC2.value = "_"
	
	return self
end

function AElement:calcSize(queue, stack)
	if not (self:getShared("underline", true) or self.finalizeSize) then
		queue:push(self.textC2)
	end
	eclass.Element.calcSize(self, queue, stack)
	--if not self.finalizeSize then return end
	if not self:getShared("underline", true) then
		queue:push(self.textC1)
	end
	self.shared = self.shared or {
		textColor = colors.blue,
		underline = true
	}
end
function AElement:placeProposals(queue)
	if not self:getShared("underline", true) then
		self.textC1:placeProposals(queue)
		self.textC2:placeProposals(queue)
	end
	eclass.Element.placeProposals(self, queue)
end
function AElement:handleClick(x, y)
	eclass.Element.handleClick(self, x, y)
	self.shared.textColor = colors.purple
	self.api:genDisplay()
	if self.tag.attrs.href and self.tag.attrs.href~="" 
		and self.browserObject.request.handlers["URL-nav"] then
		self.browserObject.request.handlers["URL-nav"]({url = self.tag.attrs.href})
	end
end

return AElement, function()
    AElement.cparents = {eclass.Element}
end