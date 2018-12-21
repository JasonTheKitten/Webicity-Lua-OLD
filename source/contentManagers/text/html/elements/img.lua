local ImgElement = {}
function ImgElement:__call(parent, bo)
    class.Element.__call(self, parent, bo)
	self.textC = new(class.TextElement)(parent, bo)
	
	return self
end

function ImgElement:calcSize(queue, stack)
--[[    if not self.finalizeSize then
        self.textC.value = self.tag.attrs["alt"] or "Image"
    end
	self.parent.calcSize(self, queue, stack)
	if not self.finalizeSize then return end
	queue:push(self.textC)]]
end
function ImgElement:placeProposals(queue)
--[[	self.textC:placeProposals(queue)
	class.Element.placeProposals(self, queue)]]
end

return ImgElement, function()
    ImgElement.cparent = class.Element
end