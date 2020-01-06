local ribbon = require()

local class = ribbon.require "class"
local util = ribbon.require "util"

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
	self.pointer = self.pointer + n
	return self.buffer:sub(self.pointer-n, self.pointer-1)
end
function Buffer:peek(l)
	return self.buffer:sub(self.pointer, self.pointer+l-1)
end
function Buffer:find(pattern)
    return self.buffer:find(pattern, self.pointer)
end
function Buffer:findAny(pattern)
	local r = util.stringFindAny(self.buffer, pattern, self.pointer)
    if r then return r-self.pointer+1 end
end