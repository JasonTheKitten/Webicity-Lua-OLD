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
	local pg = self.browserObject.request.page
	local owin = pg.window
	local win = new(class.Frame)(owin, 1, 1, owin.lm, owin.lm)
	pg.rl, pg.rh = pg.rld, pg.rhd
	win.l, win.h = pg.rl, pg.rh
	win.lm, win.lh = pg.rl, pg.rh
	self:genDisplayContent(win)
	if win.h>pg.rhd then
		pg.rl = pg.rld-1
		win.l = pg.rl
		win.lm = win.l
		self:genDisplayContent(win)
	end
	if win.l>pg.rld then
		pg.rh = pg.rhd-1
		win.h = pg.rh
		win.hm = win.h
		self:genDisplayContent(win)
	end
	if win.h>pg.rh and pg.rl==pg.rld then
		pg.rl = pg.rld-1
		win.l = pg.rl
		win.lm = win.l
		self:genDisplayContent(win)
	end
	win:redraw()
	owin:redraw()
end

function HTMLAPI:genDisplayContent(win)
	local queue, dqueue, stack = 
		new(self.classes.Queue)(self.document.element), 
		new(self.classes.Queue)(self.document.element),
		new(self.classes.Queue)(
			new(self.classes.Rect)(
				1, 1,
				new(self.classes.Pointer)(1, 1), 
				0, 0,
				new(self.classes.Pointer)(1, 1), 
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
			self.browserObject.request.page.window:onClick(event[3], event[4])
		end
	end
end

return HTMLAPI, function()
	HTMLAPI.cparent = class.Class
end