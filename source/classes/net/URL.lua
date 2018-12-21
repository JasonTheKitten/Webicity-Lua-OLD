--URL
--Represents a remote resource locator
local URL = {}

function URL:__call(loc)--init
	local left = loc
    local parts = {
		"https"
	}
	
    if string.find(left, ":") then
		parts[1] = string.match(left, ".-:")
		parts[1] = string.sub(parts[1], 1, #parts[1] - 1)
		left = string.sub(left, #parts[1]+2)
	end
	if string.find(left, "/*[^:/]+") == 1 then
		parts[2] = string.match(left, "/*[^:/?]+")
		left = string.sub(left, #parts[2]+1)
		parts[2] = string.match(parts[2], "[^:/?]+")
	end
	if string.sub(left, 1, 1) == ":" then
		parts[3] = string.match(left, "[^/?]+")
		left = string.sub(left, #parts[3]+1)
	end
	parts[4] = left
	
	if not parts[3] and tonumber(parts[2] or 0) then
		parts[3] = parts[2]
		parts[2] = parts[1]
		parts[1] = "http"
	end
	
    self.protocol = parts[1]
    self.address = parts[2]
    self.port = parts[3]
    self.path = parts[4]
    self.fURL = self.format(self.protocol, self.address, 
		self.port, self.path)
		
    return self
end

--Static methods
URL.format = function(p, a, n, e)
	--Formats a URL given info about said URL
	return p.."://"..a..
        ((n and ":"..n) or "")..e
end
URL.createFromExisting = function(existing, ext)
	--Creates a new URL given an old URL and a path
	--Useful for relative resources
	if ext:find(":") then
		return new(URL)(ext)
	end
	if type(existing) == "string" then
		existing = new(URL)(existing)
	end
	if string.sub(ext, 1, 1) == "/" then
		return new(URL)(URL.format(
			existing.protocol, existing.address,
			existing.port, ext))
	else
		local path = existing.path
		return new(URL)(URL.format(
			existing.protocol, existing.address,
			existing.port, path))
	end
end

--Return/inh
return URL, function()
    URL.cparents = {class.Class}
end