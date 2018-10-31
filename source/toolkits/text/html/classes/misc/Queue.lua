local Queue = {}
function Queue:__call(window, x, y, l, h)
    self.table = {}
    
    return self
end
function Queue:pop()
    local rtn = self.table[1]
    table.remove(self.table, 1)
    
    return rtn
end
function Queue:push(item)
    table.insert(self.table, item)
end
function Queue:peek()
    return self.table[1]
end

return Queue, function()
    Queue.cparents = {class.Class}
end