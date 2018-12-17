local AElement = {}
function AElement:__call(parent, bo, api)
    eclass.Element.__call(self, parent, bo, api)
	
	return self
end

function AElement:calcSize(queue, stack, globals)
	if not self.finalizeGraphics then
		self.shared = self.shared or {
			textColor = colors.blue,
			underline = true
		}
	end
	eclass.Element.calcSize(self, queue, stack, globals)
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