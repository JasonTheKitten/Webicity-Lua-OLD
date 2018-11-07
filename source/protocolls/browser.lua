local BrowserP = {}

function BrowserP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocoll = req.URL.protocoll,
        headers = {},
        type = req.defType or "text/html" --By default
    }
    
    --req.browser:getResource
    res.content = "test"
    
    return res
end

--[[browser:regiProto("about", function(data)
    if data.url == "blank" then
        data.content = ""
        data.type = "text/html"
    else
        data.proto = browser.name
    end
    return data
end)]]

return BrowserP