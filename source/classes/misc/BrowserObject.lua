--BrowserObject
--Represents a loaded site
local BrowserObject = {}

function BrowserObject:__call(req) --init
    self.request = req
    if protocols[req.URLObj.protocol] then
        self.response = protocols[req.URLObj.protocol]:submit(req)
    end
    if not self.response then return end
	local cm = req.browser:getContentHandler(self.response.contentType)
	if not cm then return end
	self.contentManager = new(cm)
	self.data = {
		URL = req.URL,
		URLObj = req.URLObj,
		browser = req.browser,
		contentManager = self.contentManager
	}
	self.contentManager("document", self)
	
	return self
end

--Methods
function BrowserObject:resume(args) 
	--Resumes the site with given arguments
    if self.contentManager.resume then
		self.contentManager:resume(args)
	end
end

--Ret/inh
return BrowserObject, function()
    BrowserObject.cparent = class.Class
end