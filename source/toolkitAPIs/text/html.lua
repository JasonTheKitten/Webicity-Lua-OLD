local HTMLAPI = {}

function HTMLAPI:__call(mode, bo)
	if mode~="document" then return end
	self.browserObject = bo
	
	local els = {elements = {}}
	self.classes = {}
	setmetatable(els, {__index = bo.browser.env})
	bo.browser:loadClassFolder(
        fs.combine(bo.browser.location, "toolkits/text/html/classes"),
        self.classes, nil, "class")
	bo.browser:loadClassFolder(
        fs.combine(bo.browser.location, "toolkits/text/html/elements"),
        els.elements, nil, "elements")
	self.compiler = bo.browser:getFile("toolkits/text/html/compile/compile.lua", true, els, self.classes, class)()
	
	self.document = self.compiler.parse(bo.response.content, bo)
	
	self:genDisplay()

	return self
end

function HTMLAPI:genDisplay()
	local queue, dqueue, stack = 
		new(self.classes.Queue)(self.document.element), 
		new(self.classes.Queue)(self.document.element),
		new(self.classes.Queue)(
			new(self.classes.ElementRect)(nil, self.browserObject.request.page.window))
	while queue:peek() do
		queue:pop():calcSize(queue, stack)
	end
	print(self.document.element.container.length)
	while dqueue:peek() do
		dqueue:pop():placeProposals(dqueue)
	end
end

function HTMLAPI:resume()

end

return HTMLAPI, function()
	HTMLAPI.cparents = {class.TAPI}
end