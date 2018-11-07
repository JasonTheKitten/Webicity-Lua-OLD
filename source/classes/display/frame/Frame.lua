local Frame = {}
function Frame:__call(parent, x, y, l, h)
    self:setBounds(parent, x, y, l, h)
    self.scrollX, self.scrollY = 0, 0
    
    self.buffer = {}
    
    return self
end
function Frame:setBounds(parent, x, y, l, h)
    self.parent = parent
end
function Frame:showPix(x, y, txt, bg, fg)
    local rtn, tx, ty = self:shouldShowPix(x, y, txt, bg, fg) 
	if not rtn then return end
    parent:draw(tx+x-1, ty+y-1, txt, bg, fg)
end
function Frame:redraw()
	for x, row in ipairs(self.buffer) do
		for y, column in ipairs(row) do
			local txt, bg, fg = 
				(type(column.text) == "function" and column.text()) or column.text,
				(type(column.background) == "function" and column.background()) or column.background,
				(type(column.foreground) == "function" and column.foreground()) or column.foreground
			self:showPix(x, y, txt, bg, fg)
		end
	end
end
    
function Frame:scroll(x, y)
    self.buffer.scrollX = self.buffer.scrollX+x
    self.buffer.scrollY = self.buffer.scrollY+y
end
    
function Frame:getPixInfo(x, y, txt, bg, fg)
    x = x-self.scrollX
    y = y-self.scrollY
    return
        (self.visible and not ((x<1 or x>l) or (y<1 or y>h))), x, y
end

function Frame:genBufferPos(api, x, y)
    self.buffer[y] = self.buffer[y] or {}
    self.buffer[y][x] = self.buffer[y][x] or {}
end

function Frame:proposeClickHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[x][y].onclick = func
end
function Frame:proposeFGHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[x][y].foreground = func
end
function Frame:proposeBGHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[x][y].background = func
end
function Frame:proposeTextHandler(x, y, func)
    self:genBufferPos(x, y)
    self.buffer[x][y].text = func
end
function Frame:click(x, y)
    
end

return Frame, function()
    Frame.cparents = {class.Class}
end