local Colorizer = {}

function Colorizer:getColor(color, isText)
    return color
end

return Colorizer, function()
	Colorizer.cparents = {class.Class}
end