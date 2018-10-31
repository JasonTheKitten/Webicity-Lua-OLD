local Document = {}
function Document:__new()
    
end

return Document, function()
    Document.cparents = {class.Class}
end