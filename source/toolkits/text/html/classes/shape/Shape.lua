local Shape = {}

function Shape:getAtt(name)
    if self[name] then
        return self[name]
    elseif self.parent then
        return self.parent:getAtt(name)
    end
end

return Shape, function()
    Shape.cparents = {class.Class}
end