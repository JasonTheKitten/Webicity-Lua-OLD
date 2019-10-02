local bigintobject = {...}

local BigIntObject = {}
bigintobject.BigIntObject = BigIntObject

function BigIntObject:__call()
    error("BigIntObject is not a supported object type")
end