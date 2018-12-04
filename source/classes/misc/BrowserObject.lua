local BrowserObject = {}
function BrowserObject:__call(browser, req)
    self.request = req
	self.browser = browser
    req.browser = browser
    if protocols[req.URL.protocol] then
        self.response = protocols[req.URL.protocol]:submit(req)
    end
    local resp = self.response
    if resp and ctypes[resp.type] then
        self.contentManager = new(ctypes[resp.type])(req.mode or "document", self)
		req.page.window:redraw()
    end
    return self.contentManager and self
end

function BrowserObject:resume(args)
    if self.contentManager.resume then
		self.contentManager:resume(args)
	end
end

return BrowserObject, function()
    BrowserObject.cparents = {class.Class}
end