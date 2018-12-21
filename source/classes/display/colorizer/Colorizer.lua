--Colorizer
--Returns a color based of of given info
local Colorizer = {}

function Colorizer:getColor(color, isText)
    return color or (isText and colors.black) or colors.white
end

return Colorizer, function()
	Colorizer.cparent = class.Class
end