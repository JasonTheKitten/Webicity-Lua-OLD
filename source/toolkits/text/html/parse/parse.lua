local HTMLP, Buffer = {cparents = {class.Class}}, {cparents = {class.Class}}

--SETUP HTMLP
do
	local whitespace = " \n\t"
	HTMLP.whitespace = {}
	for i=1, #whitespace do
		HTMLP.whitespace[string.sub(whitespace, i, i)] = true
	end

	local tSct = {"br", "meta", "input"}
	HTMLP.sct = {}
	for i=1, #tSct do HTMLP.sct[tSct[i]] = true end

	local tEscList = {"script", "style", "title", "textarea"}
	HTMLP.escList = {}
	for i=1, #tEscList do HTMLP.escList[tEscList[i]] = true end
	
	local charstr = "abcdefghijklmnopqrstuvwxyz"
	HTMLP.chars = {}
	for i=1, #charstr do
		local c = charstr:sub(i, i)
		HTMLP.chars[c] = true
		HTMLP.chars[c:upper()] = true
	end
end

--HTMLP
HTMLP.loops = 50
function HTMLP:__call(data, browserObject)
	self.mainTag = self:createTag(nil, nil, 
		{doctype = "html", docinfo = {}})
	self.buffer = new(Buffer)(data)
	self.curTag = self.mainTag
	self.mode, submode = "default", nil
	self.tmp = nil
	
	return self
end

function HTMLP:continue()
	if self:isDone() then return end
	if self.mode == "default" then
		local char = self.buffer:peek()
		if (self.buffer:peek(10):lower() == "<!doctype") 
			and self.whitespace[self.buffer:peek(11,11)] then
			self.buffer:eat(11)
			self.mainTag.info.doctype = ""
			self.mode = "doctype"
		elseif self.buffer:peek(4)=="<!--" then
			self.buffer:eat(4)
			self.mode = "comment"
		elseif char == "<" then
			self.buffer:eat(1)
			self.mode = "tagstart"
		else
			self.buffer:eat()
			if (self.curTag.tree[#self.curTag.tree] or {})[1] == "text" then
				local str2 = self.curTag.tree[#self.curTag.tree][2].element.value
				if not (self.whitespace[string.sub(str2, #str2, #str2)] and self.whitespace[char]) then
					self.curTag.tree[#self.curTag.tree][2].element.value = 
						str2..char
				end
			else
				table.insert(self.curTag.tree, {"text", {
					parent = self.curTag,
					element = new(class.TextElement)(self.curTag.element, bo)
				}})
				self.curTag.tree[#self.curTag.tree][2].element.value = char
			end
		end
	elseif self.mode == "doctype" then
		local char
		for i=1, self.loops do
			char = self.buffer:peek()
			if self:isDone() or whitespace[char] or char == ">" then 
				self.mode = "docinfo"
				break 
			end
			self.buffer:eat()
			self.mainTag.info.doctype = self.mainTag.info.doctype..char
		end
	elseif self.mode == "docinfo" then
		for i=1, self.loops do
            local char = self.buffer:eat()
            if self.whitespace[char] and self.tmp then
				table.insert(self.mainTag.info.docinfo, s)
				self.tmp = nil
			elseif char == ">" then 
				self.mode = "default"
				self.tmp = nil
				break
			else
				self.tmp = (self.tmp or "")..char
			end
		end
	elseif self.mode == "tagstart" then
		self.tmp = self.tmp or {}
		for i=1, self.loops do
			local char = self.buffer:peek()
			if not self.chars[char] and ((not (self.whitespace[char] or char=="/")) or self.tmp.name) then
				self.mode = "tagattrs"
				break
			end
			self.buffer:eat()
			if char == "/" then 
				self.tmp.sc = true
				self.tmp.closing = true
			elseif not whitespace[char] then
				self.tmp.name = (self.tmp.name or "")..char
			end
        end
	elseif self.mode == "tagattrs" then
		self.tmp.attrs = {}
        for i=1, self.loops do
			local char = self.buffer:eat()
			if char==">" then
				if self.tmp.sc or not self.tmp.closing then
					self.curTag = self:createTag(self.tmp.name, self.curTag)
					self.curTag.attrs = self.tmp.attrs
				end
				if self.tmp.closing then
					self:unwindTo(self.tmp.name)
				end
				self.tmp = nil
				self.mode = "default"
				break
			end
		end
	elseif self.mode == "comment" then
		for i=1, self.loops do
			if self.buffer:peek(3) == "-->" then 
				self.mode = "default"
				break 
			end
			self.buffer:eat()
		end
	elseif self.mode == "escaped" then
		self.tmp = self.tmp or ""
		for i=1, self.loops do
			if self:isDone() or (self.buffer:peek(2+#esc) == ("</"..esc)) then
				self.tmp = nil
				self.mode = "default"
				break 
			end
			self.tmp = self.tmp..self.buffer:eat()
		end
	end
end

function HTMLP:createTag(tagtype, parent, info)
	if tagtype then tagtype = tagtype:lower() end
	local tag = {
		tree = {}, attrs = {}, info = info or {},
		type = tagtype, parent = parent
	}
	
	tag.element = new(elements[n] or class.Element
		)(parent and parent.element, self.browserObject) --ambig synnx ):
	tag.element:setTag(tag)
		
	if parent then 
		table.insert(parent.tree, {"tag", t})
	end
    if tagtype then table.insert(stack, tagtype) end
	
	return tag
end

function HTMLP:isDone()
	return self.buffer:isDone()
end

--BUFFER
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
	self.buffer = self.buffer:sub(1, n)
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

return HTMLP