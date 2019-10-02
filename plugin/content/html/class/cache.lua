local ribbon = require()

local class = ribbon.require "class"

local cache = ...

local Cache = {}
cache.Cache = Cache

Cache.cparents = {class.Class}
function Cache:__call()
    self.cache = {}
end

function Cache:get(type, default)
    if not self.cache[type] then
        self.cache = class.new(default) --Not a todo, but we might add args later
    end
    return self.cache[type]
end