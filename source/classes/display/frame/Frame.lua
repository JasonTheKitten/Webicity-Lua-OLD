--Frame
--A buffer for graphics
local Frame = {}
function Frame:__call(parent, x, y, l, h) --init
    self:setBounds(parent, x, y, l, h)
	
	if not parent.showPix then
		self.colorizer = new(class.Colorizer)
	end
    
	self.visible = true
    self:clearBuff()
    
    return self
end

--Methods
function Frame:setBounds(parent, x, y, l, h)
    self.parent = parent
	self.x, self.y, self.l, self.h = x, y, l, h
end
function Frame:showPix(x, y, txt, bg, fg)
	if not self.parent.showPix then
		local rtn, tx, ty = self:getPixInfo(x, y, txt) 
		if not rtn then return end
		self.parent.setCursorPos(tx+self.x-1, ty+self.y-1)
		self.parent.setBackgroundColor(
			self.colorizer:getColor(bg, false) or colors.white)
		self.parent.setTextColor(
			self.colorizer:getColor(fg, false) or colors.black)
		xpcall(
			function() self.parent.write(txt) end, 
			function() self.parent.write(" ") end)
	else
		local rtn, tx, ty = self:getPixInfo(x, y)
		if not rtn then return end
		self.parent:proposeFGHandler(tx+self.x-1, ty+self.y-1, fg)
		self.parent:proposeBGHandler(tx+self.x-1, ty+self.y-1, bg)
		self.parent:proposeTextHandler(tx+self.x-1, ty+self.y-1, txt)
	end
end
function Frame:redraw()
	self:clearFrame()
	for y, row in pairs(self.buffer) do
		for x, column in pairs(row) do
			local txt, bg, fg = 
				(type(column.text) == "function" and column.text()) 
					or column.text or " ",
				(type(column.background) == "function" and column.background()) 
					or column.background, --or colors.white,
				(type(column.foreground) == "function" and column.foreground()) 
					or column.foreground --or colors.black
			self:showPix(x, y, txt, bg, fg)
		end
	end
end
function Frame:clearBuff()
	self.buffer = {}
end
function Frame:clearFrame()
	if not self.parent.showPix then --This is quicker
		self.parent.setBackgroundColor(
			self.colorizer:getColor(nil, false))
		local txt = string.rep(" ", self.l)
		for y=1, self.h do
			self.parent.setCursorPos(self.x, self.y+y-1)
			self.parent.write(txt)
		end
	end
	for x=1, self.l do --Too slow, fix
		for y=1, self.h do
			self:showPix(x, y, " ")
		end
	end
end
    
function Frame:getPixInfo(x, y)
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
function Frame:onClick(x, y)
    if self.buffer[y] and self.buffer[y][x] and self.buffer[y][x].onclick then
		self.buffer[y][x].onclick(x, y)
	end
end

--ret/inh
return Frame, function()
    Frame.cparent = class.Class
end