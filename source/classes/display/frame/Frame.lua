local Frame = {}
function Frame:__call(parent, x, y, l, h)
    self:setBounds(parent, x, y, l, h)
    self.scrollX, self.scrollY = 0, 0
    
    self.buffer = {}
	self.visible = true
    
    return self
end
function Frame:setBounds(parent, x, y, l, h)
    self.parent = parent
	self.x, self.y, self.l, self.h = x, y, l, h
end
function Frame:showPix(x, y, txt, bg, fg)
    local rtn, tx, ty = self:getPixInfo(x, y) 
	if not rtn then return end
    self.parent:draw(tx+self.x-1, ty+self.y-1, txt, bg, fg)
end
function Frame:redraw()
	for y, row in pairs(self.buffer) do
		for x, column in pairs(row) do
			local txt, bg, fg = 
				(type(column.text) == "function" and column.text()) 
					or column.text or " ",
				(type(column.background) == "function" and column.background()) 
					or column.background or colors.white,
				(type(column.foreground) == "function" and column.foreground()) 
					or column.foreground or colors.black
			self:showPix(x, y, txt, bg, fg)
		end
	end
end
    
function Frame:scroll(y, x)
    self.buffer.scrollX = self.buffer.scrollX+(x or 0)
    self.buffer.scrollY = self.buffer.scrollY+(y or 0)
end
    
function Frame:getPixInfo(x, y)
    x = x-self.scrollX
    y = y-self.scrollY
    return
        (self.visible and not ((x<1 or x>self.l) or (y<1 or y>self.h))), x, y
end

function Frame:genBufferPos(x, y)
    self.buffer[y] = self.buffer[y] or {}
    self.buffer[y][x] = self.buffer[y][x] or {}
end

function Frame:proposeClickHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[y][x].onclick = func
end
function Frame:proposeFGHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[y][x].foreground = func
end
function Frame:proposeBGHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[y][x].background = func
end
function Frame:proposeTextHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[y][x].text = func
end
function Frame:click(x, y)
    
end

return Frame, function()
    Frame.cparents = {class.Class}
end