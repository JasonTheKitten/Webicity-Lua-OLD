local ribbon = require()

local class = ribbon.require "class"
local rhttp = ribbon.require "http"
local process = ribbon.require "process"
local debugger = ribbon.require "debugger"

local Protocol = ribbon.reqpath("${CLASS}/net/protocol").Protocol
local Response = ribbon.reqpath("${CLASS}/net/response").Response

local http = ...

local HTTP = {}
http.HTTP = HTTP

HTTP.cparents = {Protocol}
HTTP.__call = Protocol.__call

function HTTP:submit(request)
    if request.data.method:upper()~="GET" and request.data.method:upper()~="POST" then
        error("Unsupported request method", 2)
    end
	
	local handle, reason;
	local lid; lid = process.addEventListener("http_response", function(e, d)
		process.removeEventListener(lid)
		handle = d.handle;
		reason = d.error or "<?>";
	end)
	
	local cookies = {
		["User-Agent"] = "Webicity/1.0 (Lua;) Ribbon/1.0 (Lua; tty;)",
		["Accept-Language"] = "en,en-US",
		["Cookie"] = "",
		["Host"] = request.URL:getHost(),
		["Upgrade-Insecure-Requests"] = "1",
    	--["Referer"] = nil,
    	--["Sec-Fetch-Mode"] = "navigate",
    	--["Sec-Fetch-Site"] = "none",	
    	--["Accept"] = "text/plain,text/html",
	}
	for k, v in pairs(request.cookies or {}) do
	   cookies[k] = v
	end
	rhttp.request(request.URL:toString(), nil, cookies)
	
	while not (handle or reason) do coroutine.yield() end
	if not handle then error(reason) end
    
    response = class.new(Response, handle.readAll(), {
		headers = handle.getResponseHeaders(),
		frame = request.data.frame
	})
	handle.close()
	
	return response
end