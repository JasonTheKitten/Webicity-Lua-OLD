--New (Now single-inh!)
local function new(class)
	function class:__index(key)
		local nxt = self
		while nxt do
			if rawget(nxt, key) then
				return rawget(nxt, key)
			end
			nxt = nxt.cparent
		end
	end
	
	local rtn = {cparent = class}
	setmetatable(rtn, class)
	
	return rtn
end

--Browser
--This class represents an internet/web browser
local Browser = {}

function Browser:__call(cdata) --Init
	self.cdata = cdata
	local env = {}
	env.class = self:load(self:load("classes", self.SOURCE), "class", env, _ENV)
	Browser.cparent = env.class.Class
	env.protocols = self:load(self:load("protocols", self.SOURCE), "protocols", env, _ENV)
	self.env = env
	
	return self
end

--Methods
function Browser:load(f, var, ...)
	--f->file
	--...->env
	--Not providing an env will load a resource file
	--An env of string will return a path
	
	local args = {...}
	if not var then
		return fs.open(
			fs.combine(
				fs.combine("/", self.cdata.resourceLocation)
			, f), "r")
	end
	if type(var) == "number" then
		if var == self.SOURCE then
			return fs.combine(self.cdata.sourceLocation, f)
		elseif var == self.RESOURCE then
			return fs.combine(self.cdata.resourceLocation, f)
		end
	end
	
	local env = {
		[var] = {},
		new = new
	}
	local evars
	if type(var) == "table" then
		evars = var
		var = var[1]
	end
	setmetatable(env, {
		__index = function(s, k)
			if rawget(s, k) then return rawget(s, k) end
			for i=1, #args do
				local r = args[i]
				if r and r[k] then return r[k] end
			end
		end
	})
	setmetatable(env[var], {
		__index = function(s, k)
			if rawget(s, k) then return rawget(s, k) end
			for i=1, #args do
				local r = args[i]
				if r and r[var] and r[var][k] then return r[var][k] end
			end
		end
	})
	
	if fs.isDir(f) then --Load as dir
		local q, l, ol = {f}, {}, {}
		while #q>0 do
			if fs.isDir(q[1]) then
				local n = q[1]
				table.remove(q, 1)
				for k, v in pairs(fs.list(n)) do
					table.insert(q, fs.combine(n, v))
				end
			else
				--print(q[1])
				local cls, lH = loadfile(q[1], env)
				if not cls then error(lH, -1) end
				cls, lH = cls()
				local v = fs.getName(q[1])
				local clsn = string.sub(v, 1, #v-4)
				l[clsn] = cls
				env[var][clsn] = cls
				ol[#ol+1] = lH
				table.remove(q, 1)
			end
		end
		for i=1, #ol do ol[i]() end
		return l
	else --Load as file
		local l, h = loadfile(f, env)
		if h then error(h.."\n at "..f, -1) end
		return l()
	end
end
function Browser:getContentHandler(contentType)
	--Returns the handler for a content type
	--EG text/html
	local ok, rtn = pcall(
		self.load, self,
		self:load(
			"contentManagers/"..fs.combine("/", contentType).."/ini.lua", 
			self.SOURCE),
		"", self.env, _ENV)
	if ok then return rtn end
end

function Browser:CreateFrame(URL, method, pterm, x, y, l, h, handlers)
	local req = new(self.env.class.Request)(
		self, URL, method,
		new(self.env.class.ScrollFrame)(pterm, x, y, l, h), 
		handlers)
	return new(self.env.class.BrowserObject)(req)
end

--Constants
Browser.SOURCE = 1
Browser.RESOURCE = 2
Browser.SAVEFILE = 3

--Rtn (with def args)
return new(Browser)(...)