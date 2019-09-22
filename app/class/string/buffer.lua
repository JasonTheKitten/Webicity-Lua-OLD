local ribbon = require()

local class = ribbon.require "class"

--Buffer
--TODO: Optimize for memory
local buffer = ...

local Buffer = {}
buffer.Buffer = Buffer

Buffer.cparents = {class.Class}
function Buffer:__call(arg) --init
    self.pointer = 1
	self.buffer = arg
	self.buffersize = #arg
end

function Buffer:isEmpty(pos) --Checks if all data has been read
	return self.pointer-1+(pos or 1) > self.buffersize
end
function Buffer:length()
	return self.buffersize - self.pointer + 1
end
function Buffer:eat(n) --TODO: Buffer:eatChunks()
	--Removes first n characters from stream 
	--and returns them
	n = n or 1
	local str = self.buffer:sub(self.pointer, self.pointer+n-1)
	self.pointer = self.pointer + n
	while self.pointer > self.chunksize do
	   self.buffer = self.buffer:sub(self.chunksize+1, self.buffersize)
	   self.pointer, self.buffersize = self.pointer - self.chunksize, self.buffersize - self.chunksize
	end
	return str
end
function Buffer:peek(l)
	return self.buffer:sub(self.pointer, self.pointer+l-1)
end

Buffer.chunksize = 2^16