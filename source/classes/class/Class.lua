--Class
local Class = {}
Class.cparents = {}
Class.__eq = rawequal
function Class:isA(class)
	local queue = {self}
	while #queue>0 do
		if queue[1] == class then
			return true
		end
		for i=#queue[1].cparents, 1, -1 do
			table.insert(queue, 2, queue[1].cparents[i])
		end
		table.remove(queue, 1)
	end
	return false
end


return Class