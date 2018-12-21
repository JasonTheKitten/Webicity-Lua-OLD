local JSP = {cparents = {class.Class}}

--SETUP JSP
do
	local whitespace = " \n\t"
	JSP.whitespace = {}
	for i=1, #whitespace do
		JSP.whitespace[string.sub(whitespace, i, i)] = true
	end
	
	local strstart = "\"'`"
	JSP.strstart = {}
	for i=1, #strstart do
		JSP.strstart[string.sub(strstart, i, i)] = true
	end
	
	local charstr = "abcdefghijklmnopqrstuvwxyz"
	JSP.chars = {}
	for i=1, #charstr do
		local c = charstr:sub(i, i)
		JSP.chars[c] = true
		JSP.chars[c:upper()] = true
	end
end

--JSP
JSP.loops = 50
function JSP:__call(data, env)
	self.buffer = ((type(data) == "string") and new(class.Buffer)(data)) or data
	self.mode = "default"
	self.rootCMD = {
		env = env
	}
	self.cmd = self.rootCMD
	self.rmw = true
	self.tmp = nil
	
	return self
end

function JSP:continue()
    if self.mode == "default" then
    	if self.buffer:peek(3) == "var" 
    		and self.whitespace[self.buffer:peek(4, 4)] then
    		self.buffer:eat(3)
    		self:rmw()
    		self.tmp = {
    			varname = ""
    		}
    		self.mode = "var-name"
    	end
    elseif self.mode == "var-name" then
    	local char = self.buffer:eat()
    end
end

function JSP:rmw()
	while self.whitespace[self.buffer:peek()] do
		self.buffer:eat()
	end
end

function JSP:continueExec()
	
end

function JSP:createCMD()
	
end


function JSP:isDone()
	return self.buffer:isDone()
end

function JSP:isExecDone()
	return false
end

return JSP