local ribbon = require()

local Protocol = ribbon.reqpath()



local api = ...
api.registerProtocol = function(browser)
    browser:registerProtocol("webicity", protocol)
end