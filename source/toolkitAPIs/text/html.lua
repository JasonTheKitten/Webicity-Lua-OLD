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
        els.elements, nil, "elements", nil, {eclass = self.classes})
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
			new(self.classes.Rect)(
<<<<<<< HEAD
				1, 1,
				new(self.classes.Pointer)(1, 1), 
				0, 0,
				new(self.classes.Pointer)(1, 1), 
=======
				0, 0,
				new(self.classes.Pointer)(0, 0), 
				0, 0,
				new(self.classes.Pointer)(0, 0), 
>>>>>>> 5e31b6e3e8c69ea390214d1d6c76189af8e4946d
				self.browserObject.request.page.window))
	local globals = {}
	while queue:peek() do
		queue:pop():calcSize(queue, stack, globals)
	end
	while dqueue:peek() do
		dqueue:pop():placeProposals(dqueue)
	end
<<<<<<< HEAD
	self.browserObject.request.page.window:redraw()
=======
	--self.browserObject.request.page.window:redraw()
>>>>>>> 5e31b6e3e8c69ea390214d1d6c76189af8e4946d
end

function HTMLAPI:resume()

end

return HTMLAPI, function()
	HTMLAPI.cparents = {class.TAPI}
end