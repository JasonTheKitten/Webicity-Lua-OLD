--Buffer
local Buffer = {}

function Buffer:__call(arg) --init
	if type(arg) == "table" then
		self.buffer = ""
		self.handle = arg
		self.done = false
	else
		self.buffer = arg
	end
	
	return self
end

function Buffer:isDone() --Checks if all data has been read
	if not self.handle then 
		return self.buffer == "" end
	return self.done
end
function Buffer:eat(n) 
	--Removes first n characters from stream 
	--and returns them
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
	--Returns the string inside the buffer 
	--beginning at sn and ending at en
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
    Buffer.cparent = class.Class
end