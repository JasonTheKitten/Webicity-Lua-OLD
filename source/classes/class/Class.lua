--Class
local Class = {}

function Class:isA(class)--Checks if is inherited
	local nxt = self
	while nxt do
		if nxt == class then
			return true
		end
		nxt = nxt.cparent
	end
	return false
end


return Class