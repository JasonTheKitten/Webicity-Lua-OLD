local URL = {}
function URL:__call(loc)
    self.proto = "https://"
    
    local parts = {}
    for item in string.gmatch(loc, "[^:]+") do
        table.insert(parts, item)
    end
	parts[#parts] = string.match(parts[#parts], "[^/].*")
	local ext = ""
	if string.find(parts[#parts], "[?/]") then
		ext = string.sub(
			parts[#parts],
			string.find(parts[#parts], "[?/]"))
		parts[#parts] = string.sub(
			parts[#parts], 1,
			string.find(parts[#parts], "[?/]")-1)
	end
    
    if tonumber(parts[2]) then 
        table.insert(parts, 1, "http")
    end
    if #parts == 1 then 
        table.insert(parts, 1, "http")
    end
    self.protocoll = parts[1]
    self.address = parts[2]
    self.port = parts[3]
    self.path = ext
    self.fURL = parts[1].."://"..parts[2]..
        ((parts[3] and ":"..parts[3]) or "")..ext
    
    return self
end

return URL, function()
    URL.cparents = {class.Class}
end