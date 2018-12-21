local HTTPSP = {}

function HTTPSP:submit(req)
    return protocols.http:submit(req)
end

return HTTPSP, function()
    HTTPSP.cparent = protocols.http
end