--HTML Class
--Manages HTML pages
local HTMLAPI = {}

function HTMLAPI:__call(mode, bo)
	if mode~="document" then return end
	self.browserObject = bo
	local browser = bo.data.browser
	
	local els = {}
	els.class = browser:load(
        browser:load("contentManagers/text/html/classes", browser.SOURCE),
        "class", els, browser.env, _ENV)
	els.elements = browser:load(
        browser:load("contentManagers/text/html/elements", browser.SOURCE),
        "elements", els, browser.env, _ENV)
	self.parser = 
		new(browser:load(
			browser:load("contentManagers/text/html/parse/parse.lua", browser.SOURCE), 
			"class", els, browser.env, _ENV)
			)(bo.response.content, bo, self)
	
	self.class = els.class
	self.elements = els.elements
	
	while not self.parser:isDone() do
		os.queueEvent("")
		os.pullEvent()
		self.parser:continue()
	end
	
	self.document = self.parser.mainTag
	
	self:genDisplay()

	return self
end

function HTMLAPI:genDisplay() --Generates the page layout
	local req = self.browserObject.request
	local win = req.frame
	self:genDisplayContent(win)
	--Scrollbars
	if win.lby>win.h then
		
		self:genDisplayContent(win)
	end
	if win.lbx>win.l then
		self:genDisplayContent(win)
	end
	if win.lby>win.h then
		self:genDisplayContent(win)
	end
	win:redraw()
end

function HTMLAPI:genDisplayContent(win)
	local queue, dqueue, stack = 
		new(self.class.Queue)(self.document.element), 
		new(self.class.Queue)(self.document.element),
		new(self.class.Queue)(
			new(self.class.Rect)(
				1, 1,
				new(self.class.Pointer)(1, 1), 
				0, 0,
				new(self.class.Pointer)(1, 1), 
				win))
	local globals = {}
	while queue:peek() do
		queue:pop():calcSize(queue, stack, globals)
	end
	while dqueue:peek() do
		dqueue:pop():placeProposals(dqueue)
	end
end

function HTMLAPI:resume(event)
	if event[1] == "mouse_click" then
		if event[2] == 1 then
			self.browserObject.data.frame:onClick(event[3], event[4])
		end
	end
end

return HTMLAPI, function()
	HTMLAPI.cparent = class.Class
end