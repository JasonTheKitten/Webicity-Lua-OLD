local BrowserObject = {}
function BrowserObject:__call(frame, compiler)
    
end

return BrowserObject, function()
    BrowserObject.cparents = {class.Class}
end