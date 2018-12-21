--HTTP Protocol
--Loads info from the computer
local HTTPP = {}

function HTTPP:resolvePost(tbl)
    local str = "?"
    for k, v in pairs(tbl) do
        str=str..k.."="..v
    end
    return str
end

function HTTPP:submit(req)
	local URL = req.URLObj.fURL
    local res = {
        URL = URL,
        protocol = req.URLObj.protocol
    }
    if http and http.checkURL(URL) then
        local handle
        if req.method == "post" then
            handle = http.post(URL, self:resolvePost(req.post), req.headers)
        else
            handle = http.get(URL, req.headers)
        end
        if handle then
            res.content = handle:readAll() --TODO: just pass the buffer
            res.headers = (handle.getResponseHeaders and handle:getResponseHeaders()) or {}
            res.responseCode = handle:getResponseCode()
            res.contentType = res.headers["Content-Type"] or req.defType or "text/html"
            handle:close()
        end
    end
    if res.content then
        if req.defType and (res.type ~= req.defType) and req.parentPage then
            req.parentPage:fireEvent("warn", "Resource loaded with mismatched MIME type")
        end
        return res
    end
    req.URL = new(class.URL)(
        "browser://snr/?"..
            "rc="..tostring(req.responseCode or "")..
            "url="..URL)
    return protocols.browser:submit(req)
end

return HTTPP, function()
    HTTPP.cparent = class.Protocol
end