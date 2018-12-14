local URL = "google.com"

local loc = fs.combine(shell.getRunningProgram(), "../../source")
local l, h = term.getSize()

if not fs.getBackgroundColor then _G._ENV = _G end
local Browser, new = loadfile(
    fs.combine(loc, "browser.lua"), _G)()
local browser = new(Browser)("Webicity", loc)
browser.rclocation = fs.combine(shell.getRunningProgram(), "../../resource")

local handler, browserFrame
local running = true
handler = {
	["URL-nav"] = function(info)
		local url = info.url
		if not string.find(url, ":") then
			url = "https://google.com/"
		end
		browserFrame = browser:CreateFrame(
			term, url, l, h, handler)
	end,
	["close"] = function(info)
		if info.bF == browserFrame then
			running = false
		end
	end
}

browserFrame = browser:CreateFrame(
    term, URL, l, h, handler)
	
while running do
	local e = {os.pullEvent()}--coroutine.yield()}
	browserFrame:resume(e)
end