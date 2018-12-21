xpcall(function()
--Vars
local URL = "google.com"
local x, y, l, h = 1, 1, term.getSize()

--Resolve vars
local sloc = fs.combine(shell.getRunningProgram(), "../../source")
local rsloc = fs.combine(shell.getRunningProgram(), "../../resource")

--Load Webicity
local browser = loadfile(fs.combine(sloc, "browser.lua"), _G)({
	sourceLocation = sloc, 
	resourceLocation = rsloc,
	name = "Webicity"})

local handler, browserFrame
local running = true
handler = {
	["URL-nav"] = function(info)
		browserFrame = browser:CreateFrame(
			info.url, "GET", term, 1, 1, l, h, handler)
	end,
	["close"] = function(info)
		running = false
	end
}
handler["URL-nav"]({url=URL})
	
while running do
	local e = {os.pullEvent()}--coroutine.yield()}
	browserFrame:resume(e)
end
end, function(err)
	printError(err)
	for i=4, 10 do
		local o, e = pcall(error, "", i)
		printError(" at "..e)
	end
end)