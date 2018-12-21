local HTTPP = {}

function HTTPP:submit(req)
    return protocols.http:submit(req)
end

return HTTPP, function()
    HTTPP.cparent = class.Protocol
end