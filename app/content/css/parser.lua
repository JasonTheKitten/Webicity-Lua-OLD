local ribbon = require()

local class = ribbon.require "class"
local util = ribbon.require "util"

local Buffer = ribbon.reqpath("${CLASS}/string/buffer").Buffer

local cssparser = ...

local CSSParser = {}
cssparser.CSSParser = CSSParser

CSSParser.cparents = {class.Class}

--https://www.w3.org/TR/css-syntax-3
CSSParser.parse = function(buffer)
    if type(buffer) == "string" then
        buffer = class.new(Buffer, buffer)
    end
    class.checkType(buffer, Buffer, 2, "Buffer")
    
    local whitespace = util.stringToTable("\n\t ", true)
    
    local tokens = {}
    
    local function consumeString(char)
    
    end
    
    while not buffer:checkEmpty() do
        local char = buffer:peek(1)
        if whitespace[char] then
            while whitespace[buffer:peek(1)] do buffer:eat(1) end
            table.insert(tokens, {"<whitespace-token>"})
        elseif char == "\"" then
            buffer:eat(1); consumeString(char)
        elseif char == "#" then
            --TODO
        elseif char == "'" then
            buffer:eat(1); consumeString(char)
        elseif char == "(" then
            buffer:eat(1); table.insert(tokens, {"<(-token>"})
        elseif char == ")" then
            buffer:eat(1); table.insert(tokens, {"<)-token>"})
        elseif char == "+" then
            --TODO
        elseif char == "," then
            buffer:eat(1); table.insert(tokens, {"<comma-token>"})
        elseif char == "-" then
            --TODO
        elseif char == "." then
            --TODO
        elseif char == ":" then
            buffer:eat(1); table.insert(tokens, {"<semicolon-token>"})
        elseif char == "<" then
            buffer:eat(1)
            if buffer:peek(3) == "!--" then
                buffer:eat(3); table.insert(tokens, {"<CDO-token>"})
            else
                table.insert(tokens, {"<delim-token>", "<"})
            end
        elseif char == "@" then
            --TODO
        elseif char == "[" then
            buffer:eat(1); table.insert(tokens, {"<[-token>"})
        elseif char == "\\" then
            --TODO
        elseif char == "]" then
             buffer:eat(1); table.insert(tokens, {"<]-token>"})
        elseif char == "{" then
             buffer:eat(1); table.insert(tokens, {"<{-token>"})
        elseif char == "}" then
             buffer:eat(1); table.insert(tokens, {"<}-token>"})
        elseif char:find("%d") then
            --TODO
        elseif false then
            --TODO
        elseif char == "" then
            table.insert(tokens, {"<EOF-token>"})
            break
        else
            buffer:eat(1); table.insert(tokens, {"<delim-token>", char})
        end
    end
end