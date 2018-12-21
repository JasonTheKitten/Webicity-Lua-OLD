local BrowserP = {}

function BrowserP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocol = req.URL.protocol,
        headers = {},
        contentType = "text/html" --By default
    }
    
    local h = req.browser:load(fs.combine("pages", fs.combine("/", req.URL.address))..".html")
	if not h then
		h = req.browser:load("pages/snr.html")
	end
	if h then
		res.content = h:readAll()
		h:close()
	else
		res.content = "IO Error"
	end
	
	if req.URL.address == "success" then res.content = "Success!" end
    
    return res
end

return BrowserP, function()
    BrowserP.cparent = class.Protocol
end