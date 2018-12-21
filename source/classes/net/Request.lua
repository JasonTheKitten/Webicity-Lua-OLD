--Request
--This class represents a request to a resource
--As well as data for the resource
local Request = {}

function Request:__call(browser, URL, method, frame, handlers) --init
	self.browser = browser
	self.URL = URL
	self.URLObj = new(class.URL)(URL)
	self.handlers = handlers
	self.frame = frame
	
	return self
end

--ret/inh
return Request, function()
	Request.cparent = class.Class
end