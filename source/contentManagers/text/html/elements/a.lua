local AElement = {}
function AElement:__call(parent, bo, api)
    class.Element.__call(self, parent, bo, api)
	
	return self
end

function AElement:calcSize(queue, stack, globals)
	if not self.finalizeGraphics then
		self.shared = self.shared or {
			textColor = colors.blue,
			underline = true
		}
	end
	class.Element.calcSize(self, queue, stack, globals)
end
function AElement:handleClick(x, y)
	class.Element.handleClick(self, x, y)
	self.shared.textColor = colors.purple
	self.api:genDisplay()
	if self.tag.attrs.href and self.tag.attrs.href~="" 
		and self.browserObject.request.handlers["URL-nav"] then
		local mURL = self.browserObject.data.URLObj:createFromExisting(self.tag.attrs.href)
		self.browserObject.request.handlers["URL-nav"]({url = mURL.fURL})
	end
end

return AElement, function()
    AElement.cparent = class.Element
end