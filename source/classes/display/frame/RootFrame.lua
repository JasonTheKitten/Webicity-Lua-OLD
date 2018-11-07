local RootFrame = {}
function RootFrame:__call(parent, x, y, l, h)
    x, y = x or 1, y or 1
    if not (l and h) then
        l, h = parent.getSize()
    end
    class.Frame.__call(self, parent, x, y, l, h)
    self.colorizer = new(class.Colorizer)
    
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

return RootFrame, function()
    RootFrame.cparents = {class.Frame}
end