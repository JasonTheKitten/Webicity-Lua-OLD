local ribbon = require()

local class = ribbon.require "class"
local filesystem = ribbon.require("filesystem")

local pluginapi = ...

local PluginAPI = {}
pluginapi.PluginAPI = PluginAPI

PluginAPI.cparents = {class.Class}
function PluginAPI:__call(mpath)
	local api, cache = {}, {}
	
	--TODO: api.id(papiID)
	
	api.load = function(path)
		if resolve~=false then
			resolve = (type(resolve)=="table" and resolve) or {}
			local indexf = ribbon.resolvePath(path, resolve)..(useLua~=false and ".lua" or "")
			path = filesystem.combine(mpath, indexf)
		end
		path = filesystem.getFullPath(path) --TODO: Support relative paths
		if not cache[path] then
			local env = {}
			for k, v in pairs(_ENV) do env[k] = v end
			env._ENV = env; env._G = env;
			env.pluginapi = api
		
			cache[path] = {}
			local m, err = loadfile(path, "tb", env)
			if not m then error("Failed to require path \""..path.."\" because:\n"..err, 2) end
			local extramethods=m(cache[path])
			setmetatable(cache[path], {
				__index=extramethods
			})
		end
		return cache[path]
	end
	api.resolve = function(path, resolve)
		local indexf = ribbon.resolvePath(path, resolve)
		return filesystem.combine(mpath, indexf or ".")
	end
	api.path = mpath
	
	self.api = api
end