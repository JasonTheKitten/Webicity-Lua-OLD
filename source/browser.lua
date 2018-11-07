--New
local function new(class)
	function class:__index(key)
		local queue = {self}
		while #queue>0 do
			if rawget(queue[1], key) then
				return rawget(queue[1], key)
			end
			for i=#queue[1].cparents, 1, -1 do
				table.insert(queue, 2, queue[1].cparents[i])
			end
			table.remove(queue, 1)
		end
	end
	
	local rtn = {cparents = {class}}
	setmetatable(rtn, class)
	
	return rtn
end

--Browser
local Browser = {cparents = {}}
function Browser:__call(name, location)
    self.name = name
    self.location = location
    self.classes = {}
	self.protocolls = {}
	self.ctypes = {}
	self.env = {
		class = self.classes,
		protocolls = self.protocolls,
		ctypes = self.ctypes,
		new = new
	}
    self:loadClassFolder(
        fs.combine(self.location, "classes"),
        self.classes, self.env)
	self:loadClassFolder(
        fs.combine(self.location, "protocolls"),
        self.protocolls, self.env, "protocolls")
	self:loadClassFolder(
		fs.combine(self.location, "toolkitAPIs"),
        self.ctypes, self.env, "ctypes", true)
    
    if (#(getmetatable(self).cparents) == 0) then
        getmetatable(self).cparents = {self.classes.Class}
    end
    
    self.classes.Browser = Browser
    
    return self
end
function Browser:loadClassFolder(loc, tbl, env2, id, presN)
	id = id or "class"
    local env = {}
    for k, v in pairs(_G) do env[k] = v end
    env._G = env
    env._ENV = env
    env[id] = tbl
    setmetatable(env, {__index = env2 or self.env})
	if id == "class" then
		for k, v in pairs(self.classes) do
			env.class[k] = v
		end
	end
    local onL = {}
    local queue = {loc}
    while #queue>0 do
        if fs.isDir(queue[1]) then
            local n = queue[1]
            table.remove(queue, 1)
            for k, v in pairs(fs.list(n)) do
                table.insert(queue, fs.combine(n, v))
            end
        else
            local cls, lH =
                loadfile(queue[1], env)()
			local v = fs.getName(queue[1])
			if presN then
				v = string.sub(queue[1], #loc+2)
			end
            local clsn = string.sub(v, 1, #v-4)
            tbl[clsn] = cls
            env[id][clsn] = cls
            table.insert(onL, lH)
			table.remove(queue, 1)
        end
    end
    for i=1, #onL do
        onL[i]()
    end
end
function Browser:getResource(name)
    return fs.open(fs.combine(self.rclocation, name), "r")
end
function Browser:getFile(name, env, merenv, ...)
    env = (env == true and _ENV) or env
    local file = fs.combine(self.location, name)
    if env then
        local menv = {}
        for k, v in pairs(env) do menv[k] = v end
        for k, v in pairs(merenv or _ENV) do menv[k] = v end
        menv._G = menv
        menv._ENV = menv
        menv.class = {}
        setmetatable(menv.class, {__index = self.env.class})
		setmetatable(menv, {__index = function(mself, k)
			return rawget(mself, k) or self.env[k]
		end})
        for k, v in pairs({...}) do
            for k2, v2 in pairs(v) do
                menv.class[k2] = v2
            end
        end
        return loadfile(file, menv)
    else
        return file
    end
end
function Browser:CreateFrame(term, URL)
    local frame = new(self.classes.Frame)(term)
    local URLO = new(self.classes.URL)(URL)
    local req = {
        URL = URLO,
        page = {
            window = frame
        }
    }
    
    return new(self.classes.BrowserObject)(self, req)
end

return Browser, new