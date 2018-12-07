--[[browser:regiProto("file", function(data)
    local ok, handle = pcall(fs.open, data.url, "r")
    if not ok then
        ok, handle = pcall(fs.open, data.url, "r")
        if not ok then
            data.content = "Webicity<br>An IO error has occured."
        end
    end
    if ok then 
        data.content = handle.readAll()
        handle.close()
    end
    
    if not blah then
        data.type = "text/html"
    else
        blah(data) --If _ENV.blah exists, execute it
    end
    
    return data
end)]]