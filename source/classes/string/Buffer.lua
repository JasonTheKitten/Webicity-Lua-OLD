local Buffer = {}

function Buffer:__call(arg)
	if type(arg) == "table" then
		self.buffer = ""
		self.handle = arg
		self.done = false
	else
		self.buffer = arg
	end
	
	return self
end
function Buffer:isDone()
	if not self.handle then 
		return self.buffer == "" end
	return self.done
end
function Buffer:eat(n)
	n = n or 1
	local str = ""
	if self.handle then
		return
	end
	str = self.buffer:sub(1, n)
	self.buffer = self.buffer:sub(n+1, #self.buffer)
	return str
end
function Buffer:peek(sn, en)
	if not en then
		en = sn or 1
		sn = 1
	end
	if self.handle then
		return
	end
	return self.buffer:sub(sn, en)
end

return Buffer, function()
    Buffer.cparents = {class.Class}
end