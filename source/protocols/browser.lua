local BrowserP = {}

function BrowserP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocol = req.URL.protocol,
        headers = {},
        type = req.defType or "text/html" --By default
    }
    
    --req.browser:getResource
    res.content = "test"
    
    return res
end

return BrowserP