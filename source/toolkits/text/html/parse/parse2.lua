local function falseYield()
    os.queueEvent('')
    coroutine.yield()
end

local whitespace = {
    ["\n"] = true, [" "] = true, ["\t"] = true
}

local tSct = {"br", "meta", "input"}
local sct = {}
for i=1, #tSct do sct[tSct[i]] = true end

local tEscList = {"script", "style", "title", "textarea"}
local escList = {}
for i=1, #tEscList do escList[tEscList[i]] = true end

local charstr = "abcdefghijklmnopqrstuvwxyz"
local chars = {}
for i=1, #charstr do
    local c = charstr:sub(i, i)
    chars[c] = true
    chars[c:upper()] = true
end

local function parse(str, bo, styling)
    styling = styling or {}
    
    local function parseStr(echar)
        local done, esc, s = false, false, ""
        str = string.sub(str, 2, #str)
        for i=1, #str do
            local char = string.sub(str, 1, 1)
            str = string.sub(str, 2, #str)
            if ((char == echar) and not esc) or (char == "") then
                break
            elseif not esc and (char=="\\") then
                esc = true
            else
                esc = false
                s = s..char
            end
        end
        return s
    end
    
    local function parseVal()
    	local val
        local char = string.sub(str, 1, 1)
        
        if tonumber(char) then
        	local s = ""
        	for i=1, #str do
        		char = string.sub(str, 1, 1)
        		if tonumber(char) or (char=="-") then
        			s = s..char
				else
					break
        		end
        	end
			val = tonumber(s)
			str = string.sub(str, #s+1, #str)
        elseif char == "'" then
        	val = parseStr("'")
        elseif char == '"' then
            val = parseStr('"')
        end
        
        return val
    end
    
    local stack = {}
    local function createTag(n, p)
        local t = {
			tree = {},
            styling = styling[n] or {},
            attrs = {},
            type = n,
            parent = p,
			element = new(elements[n] or class.Element)(p and p.element, bo)
        }
        t.element:setTag(t)
        
        if p then 
			table.insert(p.tree, {"tag", t})
		end
        if n then table.insert(stack, n) end
        
        return t
    end
    
    local d = createTag()
    d.docattr = {}
    d.doctype = "html"
    
    local mode, curtree, esc = "d", d, nil
    
    local unwindTo = function(tag)
        local pos
        for i=#stack, 1, -1 do
        	if stack[i] == tag then
        		pos = i
        	end
    	end
    	if pos then
    		while curtree.type ~= tag do
    			curtree = curtree.parent
    		end
    		curtree = curtree.parent
    		while stack[pos] do
    			table.remove(stack, pos)
    		end
    	end
    end

    while #str>0 do
        falseYield()
        if mode == "d" then
        	local char = string.sub(str, 1, 1)
            if string.lower(string.sub(str, 1, 9)) == "<!doctype" then
                mode = "doc"
                str = string.sub(str, 11, #str)
            elseif (string.sub(str, 1, 4) == "<!--") then
                local i2
                for i=5, #str do
                    if string.sub(str, i, i+2) == "-->" then 
                    	i2 = i
                    	break 
                    end
                end
                str = string.sub(str, i2+1, #str)
            elseif char == "<" then
                mode = "tagname"
                str = string.sub(str, 2, #str)
            --[[elseif schar == "#" then
                str = string.sub(str, 2, #str)
            elseif char == "&" then
            	str = string.sub(str, 2, #str)]]
            else
                str = string.sub(str, 2, #str)
                if (curtree.tree[#curtree.tree] or {})[1] == "text" then
                    local str2 = curtree.tree[#curtree.tree][2].element.value
                    if not (whitespace[string.sub(str2, #str2, #str2)] and whitespace[char]) then
                        curtree.tree[#curtree.tree][2].element.value = 
                            str2..char
                    end
                else
                    table.insert(curtree.tree, {"text", {
						parent = curtree,
						element = new(class.TextElement)(curtree.element, bo)
					}})
					curtree.tree[#curtree.tree][2].element.value = char
                end
            end
        elseif mode == "doc" then
            mode = "dattrs"
            local s = nil
            while true do
                local char = string.sub(str, 1, 1)
                if (whitespace[char] and s) or (char == ">") then
                    break
                end
                str = string.sub(str, 2, #str)
                if not whitespace[char] then
                    s = (s or "")..char
                end
            end
            d.doctype = s or "html"
        elseif mode == "dattrs" then
            mode = "d"
            local s
            while true do
                local char = string.sub(str, 1, 1)
                str = string.sub(str, 2, #str)
                if whitespace[char] and s then
                    table.insert(d.docattr, s)
                    s = ""
                elseif char == ">" then 
                    break
                else
                    s = (s or "")..char
                end
            end
        elseif mode == "tagname" then
            mode = "tagattrs"
            local s, closing = nil, false
            while true do
                local char = string.sub(str, 1, 1)
                str = string.sub(str, 2, #str)
                if (whitespace[char] and s) or (char == ">") then
                	str = char..str
                    break
                elseif char == "/" then
                    if not s then 
                        closing = true
                    end
                elseif chars[char] then
                    s = (s or "")..char
                elseif not whitespace[char] then
                    break
                end
            end
            if (char == "/") or sct[(s or "")] then str = "/"..str end
            if not closing then
                curtree = createTag(s, curtree)
            else
                if closing and s then
                    unwindTo(s)
                end
                while true do
                    local char = string.sub(str, 1, 1)
                    str = string.sub(str, 2, #str)
                    if (char == ">") or (char == "") then
                    	break 
                    end
                end
                mode = "d"
            end
        elseif mode == "tagattrs" then
            local i, closing, s = 0, false, nil
            while true do
                local char = string.sub(str, 1, 1)
                str = string.sub(str, 2, #str)
                if (char == ">") or (char == "") then
                    local t = curtree.parent.tree[#curtree.parent.tree]
                    if (t[1] == "tag") and (escList[t[2].type]) then
                    	esc = t[2].type
                        mode = "escaped"
                    else
                        mode = "d"
                    end
                    break
                elseif char == "/" then
                    closing = true
                elseif char == "=" and s then
                    curtree.attrs[s]=parseVal()
                    s = nil
                elseif not whitespace[char] then
                    s = (s or "")..char
                else
                    if s then curtree.attrs[s]=true end
                end
            end
            if closing then
                unwindTo(curtree.type)
                mode = "d"
            end
    	elseif mode == "escaped" then
    		mode = "d"
    		local s = ""
    		while true do
    			if (str == "") or (string.sub(str, 1, 2+#esc) == ("</"..esc)) then break end
    			s = s..string.sub(str, 1, 1)
    			str = string.sub(str, 2, #str)
    		end
    	end
        
    end
    
    return d
end

return {
    parse = parse
}