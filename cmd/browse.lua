local URL = "google.com"

local loc = fs.combine(shell.getRunningProgram(), "../../source")
local l, h = term.getSize()

if not fs.getBackgroundColor then _G._ENV = _G end
local Browser, new = loadfile(
    fs.combine(loc, "browser.lua"), _G)()
local browser = new(Browser)("Webicity", loc)

local handler, browserFrame
local running = true
handler = {
	["URL-nav"] = function(info)
		browserFrame = browser:CreateFrame(
			term, info.url, l, h, handler)
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
	local e = {coroutine.yield()}
	browserFrame:resume(e)
end