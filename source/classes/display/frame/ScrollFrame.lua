--ScrollFrame
--A scrollable graphics buffer
local ScrollFrame = {}

function ScrollFrame:__call(parent, x, y, l, h) --init
	self.wrapper = new(class.Frame)(parent, x, y, l, h)
	class.Frame.__call(self, self.wrapper, x, y, l, h)
	self.scrollX, self.scrollY = 0, 0
	self.lbx, self.lby = 0, 0
	
	return self
end

--Methods
function ScrollFrame:scroll(y, x)
    self.buffer.scrollX = self.buffer.scrollX+(x or 0)
    self.buffer.scrollY = self.buffer.scrollY+(y or 0)
end
function ScrollFrame:getPixInfo(x, y)
    x = x-self.scrollX
    y = y-self.scrollY
    return class.Frame.getPixInfo(self, x, y)
	    --[[return
        (self.visible and not ((x<1 or x>self.lm) or (y<1 or y>self.hm))), x, y]]
end
function ScrollFrame:genBufferPos(x, y)
	if x>self.lbx then self.lbx = x end
	if y>self.lby then self.lby = y end
	class.Frame.genBufferPos(self, x, y)
end
function ScrollFrame:clearBuff()
	self.lbx, self.lby = 0, 0
	class.Frame.clearBuff(self)
end
function ScrollFrame:setEnabled(ybar, xbar)
	
end
function ScrollFrame:redraw()
	class.Frame.redraw(self)
	self.wrapper:redraw()
end

--ret/inh
return ScrollFrame, function()
	ScrollFrame.cparent = class.Frame
end