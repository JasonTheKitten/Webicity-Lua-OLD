local HTMLAPI = {}
HTMLAPI:__call = function(data)
    
end

return HTMLAPI, function()
    HTMLAPI.cparents = {class.API}
end