local BrowserP = {}

function BrowserP:submit(req)
    local URL = req.URL.fURL
    local res = {
        URL = URL,
        protocol = req.URL.protocol,
        headers = {},
        type = req.defType or "text/html" --By default
    }
    
    --req.browser:getResource
    res.content = [[<!DOCTYPE html>
<html>
	<head>
		<title>Test</title>
	</head>
	<body>
		This is a test page. Click <a href="browser://success">here</a> to test.
	</body>
</html>
	]]
	
	if req.URL.address == "success" then res.content = "Success!" end
    
    return res
end

return BrowserP