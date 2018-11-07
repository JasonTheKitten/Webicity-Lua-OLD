local Protocoll = {}

function Protocoll:submit()
    error()
end

return Protocoll, function()
    Protocoll.cparents = {class.Class}
end