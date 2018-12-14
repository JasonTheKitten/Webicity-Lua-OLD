local BrowserP = {}

function BrowserP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocol = req.URL.protocol,
        headers = {},
        type = req.defType or "text/html" --By default
    }
    
    local h = req.browser:getResource(fs.combine("pages", fs.combine("/", req.URL.address))..".html")
	if not h then
		h = req.browser:getResource("pages/snr.html")
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

return BrowserP