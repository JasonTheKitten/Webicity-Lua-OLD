local RootFrame = {}
function RootFrame:__call(parent, x, y, l, h)
    class.Frame.__call(self, parent, x, y, l, h)
    self.colorizer = new(class.display.Colorizer)()
    
    return self
end

function RootFrame:showPix(x, y, txt, bg, fg)
    local rtn, tx, ty = self:shouldShowPix(x, y, txt, bg, fg) 
	if not rtn then return end
    self.parent.setCursorPos(tx+self.x-1, ty+self.y-1)
    self.parent.setBackgroundColor(
        self.colorizer:getColor((type(bg) == "function" and bg()) or bg, false))
    self.parent.setTextColor(
        self.colorizer:getColor((type(fg) == "function" and fg()) or fg, false))
    self.parent.write((type(txt) == "function" and txt()) or txt or "")
end

--[[function RootFrame:getColor(color, useMonotone, isText)
    local mon = ((isText and colors.white) or colors.black)
    return ((useMonotone or not color) and 
        ((isText and colors.white) or colors.black)) or color
end]]

return RootFrame, function()
    RootFrame.cparents = {class.Frame}
end