local HTTPP = {}

function HTTPP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocol = req.URL.protocol
    }

    return protocol.browser(req)
end

return HTTPP, function()
    HTTPP.cparents = {class.Protocol}
end