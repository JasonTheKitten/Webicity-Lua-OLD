local TAPI = {}

function TAPI:fireEvent(...)
    if self.onEvent then
        self.onEvent(...)
    elseif self.parent then
        self.parent:fireEvent(...)
    end
end

return TAPI, function()
    TAPI.cparents = {class.Class}
end