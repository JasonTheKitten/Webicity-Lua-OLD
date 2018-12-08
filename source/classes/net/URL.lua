local URL = {}
function URL:__call(loc)
	local left = loc
    local parts = {
		"https",
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
    self.fURL = parts[1].."://"..parts[2]..
        ((parts[3] and ":"..parts[3]) or "")..parts[4]
		
    return self
end

return URL, function()
    URL.cparents = {class.Class}
end