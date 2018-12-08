local Colorizer = {}

function Colorizer:getColor(color, isText)
    return color or (isText and colors.black) or colors.white
end

return Colorizer, function()
	Colorizer.cparents = {class.Class}
end