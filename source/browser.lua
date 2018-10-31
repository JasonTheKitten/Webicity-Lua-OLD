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
    self:loadClassFolder(
        fs.combine(self.location, "classes"),
        self.classes)
    
    if (#(getmetatable(self).cparents) == 0) then
        getmetatable(self).cparents = {self.classes.Class}
    end
    
    self.classes.Browser = Browser
    
    return self
end
function Browser:loadClassFolder(loc, tbl, curClassTbl)
    local env = {}
    for k, v in pairs(_G) do env[k] = v end
    env._G = env
    env._ENV = env
    env.class = {}
    setmetatable(env.class, {__index = curClassTbl})
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
			print(queue[1])
            local cls, lH =
                loadfile(queue[1], env)()
			local v = fs.getName(queue[1])
            local clsn = string.sub(v, 1, #v-4)
            tbl[clsn] = cls
            env.class[clsn] = cls
            table.insert(onL, lH)
			table.remove(queue, 1)
        end
    end
    for i=1, #onL do
        onL[i]()
    end
end
function Browser:loadResource(rctype, name)
    
end
function Browser:getFile(name, env, merenv, ...)
    env = (env == true and _ENV) or env
    local file = fs.combine(self.location, name)
    if env then
        local menv = {}
        for k, v in pairs(env) do menv[k] = v end
        for k, v in pairs(merenv) do menv[k] = v end
        menv._G = menv
        menv._ENV = menv
        menv.class = {}
        setmetatable(menv.class, {__index = env.class})
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
    
    return new(self.classes.BrowserObject)(frame, URLO)
end

return Browser, new