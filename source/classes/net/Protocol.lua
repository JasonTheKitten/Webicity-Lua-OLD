--Protocol
local Protocol = {} --Abstract

function Protocol:submit() --Abstract
    error()
end

return Protocol, function()
    Protocol.cparent = class.Class
end