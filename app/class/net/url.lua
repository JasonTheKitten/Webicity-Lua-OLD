local ribbon = require()

local class = ribbon.require "class"
local util = ribbon.require "util"

local url = ...

local URL = {}
url.URL = URL

URL.cparents = {class.Class}
function URL:__call(data)
    if data then
        --TODO:
    else
        self.passwordTokenSeen = false
        self.atflag = false
        self.brackflag = false
        --TODO: Above variables should be defined in URL.create; should not be fields.
        
        self.cannotBeABaseURL = false
        self.path = {}
    end
end

function URL:getHost()
	return self.host
end
function URL:getPath()
	local path = ""
	for i=1, #self.path do
		path=path.."/"..self.path[i]
	end
	return path
end

function URL:toString()
	local rtn = ""
	if self.scheme then rtn = self.scheme..":" end
	if self.host then
		rtn=rtn.."//"
		if self.username or self.password then
			rtn=rtn..self.username
			if self.password then
				rtn=rtn..":"..self.password
			end
			rtn = rtn.."@"
		end
		rtn=rtn..self.host
		if self.port then
			rtn=rtn..":"..tostring(self.port)
		end
	elseif self.scheme == "file" then
		rtn = rtn.."//"
	end
	if self.cannotBeABaseURL then
		rtn = rtn..self.path[1]
	else
		for i=1, #self.path do
			rtn=rtn.."/"..self.path[i]
		end
	end
	if self.query then rtn=rtn.."?"..self.query end
	if self.fragment then rtn=rtn.."#"..self.fragment end
	return rtn
end

--https://url.spec.whatwg.org/#concept-basic-url-parser
function URL.create(input, base, special)
    local abc = "abcdefghijklmnopqrstuvwxyz"
	local characters = util.stringToTable(abc..abc:upper(), true)
	
	special = special or {}
	local dspecial = {
	    ftp = 21,
	    file = true,
	    gopher = 70,
	    http = 80,
	    https = 443,
	    ws = 80,
	    wss = 443
	}
	for k, v in pairs(dspecial) do
		special[k] = special[k] or v
	end
	
	local url = class.new(URL)
	input = input:gsub("^[ \n\t]+", ""):gsub("[ \n\t]+$", ""):gsub("[\n\t]", "")
	
	local buffer, pointer = "", 0
	
	local function isWinDrive() end
	
	local function utf(char)
	   if char:find("[^%s%z%c]") then return char end
	   return "%"..("%02X"):format(string.byte(char))
	end
	
	local state
	local STATE_LOOKUP; STATE_LOOKUP = {
	   ["SCHEME_START"] = function(char)
            if characters[char] then
                buffer = buffer..char:lower()
                state = STATE_LOOKUP.SCHEME
            else
                pointer = pointer - 1
                state = STATE_LOOKUP.NO_SCHEME
            end
	   end,
	   ["SCHEME"] = function(char)
	       if characters[char] or char:find("[%+%-%.]") then
	           buffer = buffer..char:lower()
	       elseif char == ":" then
				url.scheme = buffer
				buffer = ""
				if url.scheme == "file" then
	               state = STATE_LOOKUP.FILE
				elseif base and special[url.scheme] and base.scheme == url.scheme then
	               state = STATE_LOOKUP.SPECIAL_RELATIVE_OR_AUTHORITY
				elseif special[url.scheme] then
					state = STATE_LOOKUP.SPECIAL_AUTHORITY_SLASHES
				elseif input:sub(pointer+1, pointer+1) == "/" then
	               pointer = pointer+1
	               state = STATE_LOOKUP.PATH_OR_AUTHORITY
				else
					url.cannotBeABaseURL = true
					state = STATE_LOOKUP.CANNOT_BE_A_BASE_URL_PATH
				end
	       else
	           buffer, pointer = "", 0
	           state = STATE_LOOKUP.NO_SCHEME
	       end
	   end,
	   ["NO_SCHEME"] = function(char)
	       if not base or (base.cannotBeABaseURL and char~="#") then
	           return false
	       elseif base.cannotBeABaseURL then
	           url.scheme = base.scheme
	           url.path = base.path
	           url.query = base.query
	           url.fragment = ""
	           url.cannotBeABaseURL = true
	           state = STATE_LOOKUP.FRAGMENT
	       else
	           pointer = pointer - 1
	           state = (url.scheme == "file" and STATE_LOOKUP.FILE) or STATE_LOOKUP.RELATIVE
	       end
	   end,
	   ["SPECIAL_RELATIVE_OR_AUTHORITY"] = function(char)
	       if char == "/" and input:sub(pointer+1, pointer+1) == "/" then
	           pointer = pointer+1
	           state = STATE_LOOKUP.SPECIAL_AUTHORITY_IGNORE_SLASHES
	       else
	           pointer = pointer - 1
	           state = STATE_LOOKUP.RELATIVE
	       end
	   end,
	   ["PATH_OR_AUTHORITY"] = function(char)
	       if char == "/" then
	           state = STATE_LOOKUP.AUTHORITY
	       else
	           pointer = pointer-1
	           state = STATE_LOOKUP.PATH
	       end
	   end,
	   ["RELATIVE"] = function(char)
	       url.scheme = base.scheme
	       if char == "/" then
	           state = STATE_LOOKUP.RELATIVE_SLASH
	       elseif char == "?" then
	           url.username, url.password, url.host, url.port, url.query =
	               base.username, base.password, base.host, base.port, ""
	           state = STATE_LOOKUP.FRAGMENT
	       elseif char == "#" then
	           url.username, url.password, url.host, url.port, url.query, url.fragment =
	               base.username, base.password, base.host, base.port, base.query, ""
	           state = STATE_LOOKUP.FRAGMENT
	       elseif special[url.scheme] and char == "\\" then
	           state = STATE_LOOKUP.RELATIVE_SLASH
	       else
	           pointer = pointer - 1
	           url.username, url.password, url.host, url.port, url.path =
	               base.username, base.password, base.host, base.port, base.path
	           url.path[#url.path] = nil
	           state = STATE_LOOKUP.PATH
	       end
	   end,
	   ["RELATIVE_SLASH"] = function(char)
	       if special[url.scheme] and (char == "/" or char == "\\") then
	           state = STATE_LOOKUP.SPECIAL_AUTHORITY_IGNORE_SLASHES
	       elseif char == "/" then
	           state = STATE_LOOKUP.AUTHORITY
	       else
	           pointer = pointer - 1
	           url.username, url.password, url.host, url.port, url.path =
	               base.username, base.password, base.host, base.port, base.path
	       end
	   end,
	   ["SPECIAL_AUTHORITY_SLASHES"] = function(char)
			if char=="/" and input:sub(pointer+1, pointer+1) == "/" then
	           pointer = pointer+1
			else
				pointer = pointer-1
			end
	       state = STATE_LOOKUP.SPECIAL_AUTHORITY_IGNORE_SLASHES
	   end,
	   ["SPECIAL_AUTHORITY_IGNORE_SLASHES"] = function(char)
	       if char~="\\" and char~="/" then
	           pointer = pointer-1
	           state = STATE_LOOKUP.AUTHORITY
	       end
	   end,
	   ["AUTHORITY"] = function(char)
            if char == "@" then
                if self.atflag then buffer = buffer.."%40" end
                atflag = true
                for cp in buffer:gsub(".") do
                    if cp == ":" and not url.passwordTokenSeen then
                        url.passwordTokenSeen = true
                    else
                        local encoded = "%"..string.format("%x", string.byte(cp))
                        if url.passwordTokenSeen then
                            url.password = url.password..encoded
                        else
                            url.username = url.username..encoded
                        end
                    end
                end
            elseif char == "" or char:find("[/%?#]") or (special[url.scheme] and char == "\\") then
                if buffer == "" and url.atflag then return false end
                pointer = pointer - #buffer - 1
                buffer = ""
                state = STATE_LOOKUP.HOST
            else
                buffer = buffer..char
            end
	   end,
	   ["HOST"] = function()
	   		pointer = pointer-1
			state = STATE_LOOKUP.HOSTNAME
		end,
	   ["HOSTNAME"] = function(char)
	       if char == ":" and not url.brackflag then
				url.host = buffer --TODO: Not be lazy
				buffer = ""
				state = STATE_LOOKUP.PORT
	       elseif char == "" or char:find("[/%?#]")
				or (special[url.scheme] and char=="\\") then
		   
				pointer = pointer-1
				if special[url.scheme] and buffer == "" then return false end

				url.host = buffer --TODO: Not be lazy
				buffer = ""
				state = STATE_LOOKUP.PATH_START
	       else
	           if char == "[" then url.brackflag = true end
	           if char == "]" then url.brackflag = false end
	           buffer = buffer..char
	       end
	   end,
	   ["PORT"] = function(char)
	       if tonumber(char) then
	           buffer = buffer..char
	       elseif char == "" or (special[char] and char=="\\") or char:find("[/?#]") then
	           if buffer ~= "" then
	               local port = tonumber(buffer)
	               if port > 2^16-1 then return false end
	               url.port = (port ~= special[url.scheme] and port) or nil
	               buffer = ""
	           end
	           state = STATE_LOOKUP.PATH_START
	           pointer = pointer - 1
	       else return false end
	   end,
	   ["FILE"] = function(char)
	       url.scheme = "file"
	       if char == "/" or char == "\\" then
	           state = STATE_LOOKUP.FILE_SLASH
	       elseif base and base.scheme == "file" then
	           if char == "" then
	               url.host, url.path, url.query =
	                   base.host, base.path, base.query
	           elseif char == "?" then
	               url.host, url.path, url.query =
	                   base.host, base.path, ""
	               state = STATE_LOOKUP.QUERY
	           elseif char == "#" then
	               url.host, url.path, url.query, url.query =
	                   base.host, base.path, base.query, ""
	               state = STATE_LOOKUP.FRAGMENT
	           else
	               --TODO
	               url.host, url.path = base.host, util.copy(base.path)
	               url.path[#url.path] = nil
	               pointer = pointer-1
	               state = STATE_LOOKUP.PATH
	           end
	       else
	           pointer = pointer-1
	           state = STATE_LOOKUP.PATH
	       end
	   end,
	   ["FILE_SLASH"] = function(char)
	       if char == "/" or char == "\\" then
	           state = STATE_LOOKUP.FILE_HOST
	       else
	           if base and base.scheme == "file" then --TODO
	               
	           end
	           state = STATE_LOOKUP.PATH
	       end
	   end,
	   ["FILE_HOST"] = function(char)
	       if char == "" or char:find("[/\\?#]") then
	           pointer = pointer - 1
	           --TODO: WinDrive
	           if buffer == "" then
	               url.host = ""
	               state = STATE_LOOKUP.PATH_START
	           else
	               local host = buffer --TODO: Not be lazy
	               url.host = (host == "localhost" and "") or host
	               buffer = ""
	               state = STATE_LOOKUP.PATH_START
	           end
	       else
	           buffer = buffer..char
	       end
	   end,
        ["PATH_START"] = function(char)
            if special[url.scheme] then
                if char~="/" and char~="\\" then
                    pointer = pointer-1
                end
                state = STATE_LOOKUP.PATH
            elseif char == "?" then
                url.query = ""
                state = STATE_LOOKUP.QUERY
            elseif char == "#" then
                url.fragment = ""
                state = STATE_LOOKUP.FRAGMENT
            elseif char ~= "" then
                if char ~= "/" then pointer = pointer-1 end
                state = STATE_LOOKUP.PATH
            end
        end,
        ["PATH"] = function(char)
            if char == "" or (special[url.scheme] and char == "\\")
                or char:find("[%?#/]") then
                
                if buffer:gsub("%%2[eE]", ".") == ".." then
                    url.path[#url.path] = (char~="/" and not (special[url.scheme] and char=="\\") and "") or nil
                elseif buffer:gsub("%%2[eE]", ".") == "." 
                    and (char~="/" and not (special[url.scheme] and char=="\\")) then
                                       
                    url.path[#url.path+1] = ""
                elseif buffer:gsub("%%2[eE]", ".") ~= "." then
                	url.path[#url.path+1] = buffer
                end
                buffer = ""
                if url.scheme == "file" and char == "" then
                    while #url.path > 1 and url.path[1] == "" do
                        table.remove(url.path, 1)
                    end
                end
                if char == "?" then
                    url.query = ""
                    state = STATE_LOOKUP.QUERY
                end
                if char == "#" then
                    url.fragment = ""
                    state = STATE_LOOKUP.FRAGMENT
                end
            else
            	buffer = buffer..utf(char)
            end
        end,
        ["CANNOT_BE_A_BASE_URL_PATH"] = function(char)
            if char == "?" then
                url,query = ""
                state = STATE_LOOKUP.QUERY
            elseif char == "#" then
                url.fragment = ""
                state = STATE_LOOKUP.fragment
            elseif char ~= "" then
                url.path[1] = url.path[1]
            end
        end,
        ["QUERY"] = function(char)
            if char == "#" then
                url.fragment = ""
                state = STATE_LOOKUP.FRAGMENT
            elseif char ~= "" then
                url.query = url.query..utf(char)
            end
        end,
        ["FRAGMENT"] = function(char)
            if char == "" or char=="\0" then
            else
                url.fragment = url.fragment..utf(char)
            end
        end
	}
	
	state = STATE_LOOKUP.SCHEME_START
	repeat
        pointer = pointer+1
        if state(input:sub(pointer, pointer)) == false then return false end
	until (input:sub(pointer, pointer) == "" and pointer~=0)
	
	return url
end