local BrowserObject = {}
function BrowserObject:__call(browser, req)
    self.request = req
	self.browser = browser
    req.browser = browser
    if protocolls[req.URL.protocoll] then
        self.response = protocolls[req.URL.protocoll]:submit(req)
    end
    local resp = self.response
	for k, v in pairs(ctypes) do print(k) end
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