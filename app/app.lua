local ribbon = require()

local basecomponent = ribbon.require "component/basecomponent"
local class = ribbon.require "class"
local statics = ribbon.require "statics"
local task = ribbon.require "task"
local process = ribbon.require "process"

local BlockComponent = ribbon.require("component/blockcomponent").BlockComponent
local Button = ribbon.require("component/button").Button
local HSpan = ribbon.require ("component/hspan").HSpan
local Label = ribbon.require("component/label").Label

local BrowserFrame = ribbon.reqpath("${CLASS}/component/browserframe").BrowserFrame
local BrowserInstance = ribbon.reqpath("${CLASS}/browser/browserinstance").BrowserInstance

local COLORS = statics.get("colors")

local running, doRefresh = true, false
basecomponent.execute(function(gd)
    local ctx = gd(0)
	
	local function refresh()
		doRefresh = true
	end
	local function quit()
		running = false
	end
	local function quitButton(e)
		if e.button == 1 then quit() end
	end
    
    local menubar = class.new(HSpan):attribute(
        "id", menubar
    )
    
	local browserInstance = class.new(BrowserInstance)
	
    local baseComponent = class.new(basecomponent.BaseComponent, ctx, process)
	local viewport = baseComponent:getDefaultComponent():attribute(
		"id", "viewport",
		"onupdate", refresh,
		"width", {1},
		"height", {1},
        "children", {
            class.new(HSpan):attribute(
                "id", "titlebar",
                "width", {1, 0},
                "background-color", COLORS.BLACK,
                "text-color", COLORS.ORANGE,
                "children", {
                    class.new(Button, nil, "="):attribute(
						"selected-text-color", COLORS.RED
					),
					class.new(Label, nil, " "),
                    class.new(Label, nil, "Webicity Web Browser"):attribute(
						"id", "title",
                        "text-color", COLORS.WHITE,
						"enable-wrap", false
                    ),
                    class.new(Button, nil, "x"):attribute(
						"selected-text-color", COLORS.RED,
                        "location", {1, -1, 0, 0},
                        "onrelease", quitButton
                    )
                }
            ),
            class.new(BlockComponent):attribute(
                "id", "content-pane",
				"width", {1}, "height", {1, -1}
            )
        }
    )
    
    local contentpane = viewport:getComponentByID("content-pane")
	
	class.new(BrowserFrame, contentpane, browserInstance):attribute(
		"width", {1}, "height", {1, -1},
		"URL", "google.com?q=Web Browsers",
		"ondisplaytitleupdate", function(title)
			viewport:getComponentByID("title"):attribute("text", title)
		end
	)
	
	--Main
	baseComponent:render()
	coroutine.yield()
	while running and browserInstance:continue() do
		coroutine.yield()
		if doRefresh or baseComponent:update() then 
			baseComponent:render()
			doRefresh = false
		end
	end
	
	ctx.clear(COLORS.BLACK)
end)