local ribbon = require()

local class = ribbon.require "class"
local filesystem = ribbon.require "filesystem"

local Protocol = ribbon.reqpath("${CLASS}/net/protocol").Protocol
local Response = ribbon.reqpath("${CLASS}/net/response").Response

local file = ...

local File = {}
file.File = File

File.cparents = {Protocol}
File.__call = Protocol.__call

function File:submit(request)
    if request.data.method:upper()~="GET" then
        error("Unsupported request method", 2)
    end
    
    local filepath = request.URL:getHost().."/"..request.URL:getPath()
    if filesystem.exists(filepath) then
        local response
        if filesystem.isDir(filepath) then
            
        elseif filesystem.isFile(filepath) then
            local file = filesystem.open(filepath, "r")
            local content = file.readAll()
            file.close()
            
            response = class.new(Response, content, {
                headers = {
					["Content-Type"] = "text/plain"
				},
                frame = request.data.frame
            })
        else
            error("Unsupported file type", 2)
        end
        
        return response
    else
        error("File Not Found", -1)
    end
end