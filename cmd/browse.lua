local URL = "browser://welcome"

local loc = fs.combine(shell.getRunningProgram(), "../../source")

if not fs.getBackgroundColor then _G._ENV = _G end
local Browser, new = loadfile(
    fs.combine(loc, "browser.lua"), _G)()

local browser = new(Browser)("Webicity", loc)
local browserFrame = browser:CreateFrame(
    new(browser.classes.RootFrame)(term), URL)