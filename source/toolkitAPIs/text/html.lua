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
	local _, e = bo.browser:getFile("toolkits/text/html/parse/parse.lua", true)
	self.parser = 
		new(bo.browser:getFile("toolkits/text/html/parse/parse.lua", true, els, self.classes, class)()
			)(bo.response.content, bo) --Ambig snyx ):
	
	while not self.parser:isDone() do
		os.queueEvent("")
		os.pullEvent()
		self.parser:continue()
	end
	
	self.document = self.parser.mainTag
	
	self:genDisplay()

	return self
end

function HTMLAPI:genDisplay()
	local queue, dqueue, stack = 
		new(self.classes.Queue)(self.document.element), 
		new(self.classes.Queue)(self.document.element),
		new(self.classes.Queue)(
			new(self.classes.Rect)(
				1, 1,
				new(self.classes.Pointer)(1, 1), 
				0, 0,
				new(self.classes.Pointer)(1, 1), 
				self.browserObject.request.page.window))
	local globals = {}
	while queue:peek() do
		queue:pop():calcSize(queue, stack, globals)
	end
	while dqueue:peek() do
		dqueue:pop():placeProposals(dqueue)
	end
	self.browserObject.request.page.window:redraw()
end

function HTMLAPI:resume(event)
	if event[1] == "mouse_click" then
		if event[2] == 1 then
			self.browserObject.request.page.window:onClick(event[3], event[4])
		end
	end
end

return HTMLAPI, function()
	HTMLAPI.cparents = {class.TAPI}
end