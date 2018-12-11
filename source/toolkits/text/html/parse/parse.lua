local HTMLP = {cparents = {class.Class}}

--SETUP HTMLP
do
	local whitespace = " \n\t"
	HTMLP.whitespace = {}
	for i=1, #whitespace do
		HTMLP.whitespace[string.sub(whitespace, i, i)] = true
	end
	
	local strstart = "\"'`"
	HTMLP.strstart = {}
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
	self.buffer = new(class.Buffer)(data)
	self.curTag = self.mainTag
	self.mode = "default"
	self.stack = {}
	self.browserObject = browserObject
	self.tmp = nil
	
	return self
end

function HTMLP:continue()
	if self:isDone() then return end
	if self.mode == "default" then
		local char = self.buffer:peek()
		if (self.buffer:peek(9):lower() == "<!doctype") 
			and self.whitespace[self.buffer:peek(10,10)] then
			self.buffer:eat(10)
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
					element = new(class.TextElement)(self.curTag.element, self.browserObject)
				}})
				self.curTag.tree[#self.curTag.tree][2].element.value = char
			end
		end
	elseif self.mode == "doctype" then
		local char
		for i=1, self.loops do
			char = self.buffer:peek()
			if self:isDone() or self.whitespace[char] or char == ">" then 
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
				self.tmp.closing = true
			elseif not self.whitespace[char] then
				self.tmp.name = (self.tmp.name or "")..char
			end
        end
	elseif self.mode == "tagattrs" then
		self.tmp.attrs = {}
        for i=1, self.loops do
			local char = self.buffer:eat()
			if char==">" then
				self.mode = "default"
				if self.tmp.sc or not self.tmp.closing then
					self.curTag = self:createTag(self.tmp.name, self.curTag)
					self.curTag.attrs = self.tmp.attrs
				end
				if self.tmp.closing then
					self:unwindTo(self.tmp.name)
				elseif self.escList[self.tmp.name] then
					self.mode = "escaped"
					self.esc = self.tmp.name
				end
				self.tmp = nil
				break
			elseif self.whitespace[char] then
				if self.tmp.attr then
					self.curTag.attrs[self.tmp.attr] = true
					self.tmp.attr = nil
				end
			elseif char == "/" then
				self.tmp.sc = self.tmp.sc or not self.tmp.closing
				self.tmp.closing = true
			elseif char == "=" and self.tmp.attr then
				self.mode = "value"
			else
				self.tmp.attr = (self.tmp.attr or "")..char
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
			if self:isDone() or (self.buffer:peek(2+#self.esc) == ("</"..self.esc)) then
				self.curTag.value = self.tmp
				self.tmp = nil
				self.mode = "default"
				self.esc = nil
				break 
			end
			self.tmp = self.tmp..self.buffer:eat()
		end
	elseif self.mode == "value" then
		for i=1, self.loops do
			local char = self.buffer:peek()
			if not self.echar then
				if self.strstart[char] then
					self.echar = char
				else
					self.mode = "tagattrs"
					self.tmp.attr = nil
					break
				end
			end
			self.buffer:eat()
			if char == self.echar then
				self.mode = "tagattrs"
				self.echar = nil
				self.curTag.attrs[self.tmp.attr] = self.tmp.attrv
				break
			end
			self.tmp.attrv = (self.tmp.attr or "")..char
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
    if tagtype then table.insert(self.stack, tagtype) end
	
	return tag
end

function HTMLP:unwindTo(tag)
	local pos
	for i=#self.stack, 1, -1 do
		if self.stack[i] == tag then
			pos = i
		end
	end
	if pos then
		while self.curTag.type ~= tag do
			self.curTag = self.curTag.parent
		end
		self.curTag = self.curTag.parent
		while self.stack[pos] do
			table.remove(self.stack, pos)
		end
	end
end

function HTMLP:isDone()
	return self.buffer:isDone()
end

return HTMLP