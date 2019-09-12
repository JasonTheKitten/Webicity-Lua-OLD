--GAH! I'll never finish a browser in decent time within 2MB at this rate!

local ribbon = require()

local class = ribbon.require "class"
local util = ribbon.require "util"

local Buffer = ribbon.reqpath("${CLASS}/string/buffer").Buffer

local parser = ...

local HTMLParser = {}
parser.HTMLParser = HTMLParser

HTMLParser.cparents = {class.Class}

--https://html.spec.whatwg.org/#tokenization
function HTMLParser.parse(buffer, selfClosingTags, rawTags, isRoot)
    
    class.checkType(buffer, Buffer, 2, "Buffer")
    
    local abc = "abcdefghijklmnopqrstuvwxyz"
	local characters = util.stringToTable(abc..abc:upper(), true)
	local whitespace = util.stringToTable("\n\t\f ", true)

    local INSERTION_MODE_LOOKUP = util.reverse {
       "INITIAL", "BEFORE_HTML", "BEFORE_HEAD", "IN_HEAD",
       "IN_HEAD_NOSCRIPT", "AFTER_HEAD", "IN_BODY", "TEXT",
       "IN_TABLE", "IN_TABLE_TEXT", "IN_CAPTION", "IN_COLUMN_GROUP",
       "IN_TABLE_BODY", "IN_ROW", "IN_CELL", "IN_SELECT", "IN_SELECT_IN_TABLE",
       "IN_TEMPLATE", "AFTER_BODY", "IN_FRAMESET", "AFTER_FRAMESET", "AFTER_AFTER_BODY",
       "AFTER_AFTER_FRAMESET"
    }
    
    local TOKEN_TYPES = util.reverse {
        "CHARACTER", "EOF", "START_TAG", "COMMENT", "END_TAG"
    }
    
    local REP_CHAR = "�"
    
    local lastStartTagTokenName
    local function emit(token)
        if token[1] == TOKEN_TYPE.START_TAG then
            lastStartTagTokenName = token[1]
        end
    end
    
    local function ezprocess(char)
        if char == "\0" then
            emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
        elseif char == "" then
            emit({TOKEN_TYPES.EOF})
        else
            emit({TOKEN_TYPES.CHARACTER, " "})
        end
    end
    
    local STATE_LOOKUP, state, return_state, token, tmp_buf
    STATE_LOOKUP = {
        ["DATA"] = function()
            local char = buffer:eat(1)
            if char == "&" then
                return_state = STATE_LOOKUP.DATA
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == "<" then
                state = STATE_LOOKUP.TAG_OPEN
            else ezprocess(char) end
        end,
        ["RCDATA"] = function()
            local char = buffer:eat(1)
            if char == "&" then
                return_state = STATE_LOOKUP.RCDATA
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == "<" then
                state = STATE_LOOKUP.RCDATA_LT
            else ezprocess(char) end
        end,
        ["RAWTEXT"] = function()
            local char = buffer:eat(1)
            if char == "<" then
                state = STATE_LOOKUP.RAWTEXT_LT
            else ezprocess(char) end
        end,
        ["SCRIPT_DATA"] = function()
            local char = buffer:eat(1)
            if char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_LT
            else ezprocess(char) end
        end,
        ["PLAINTEXT"] = function()
            ezprocess(buffer:eat(1))
        end,
        ["TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if char == "!" then
                buffer:eat(1); state = STATE_LOOKUP.MARKUP_DECLERATION_OPEN
            elseif char == "/" then
                buffer:eat(1); state = STATE_LOOKUP.END_TAG_OPEN
            elseif characters[char] then
                token = {TOKEN_TYPES.START_TAG, ""}
                state = STATE_LOOKUP.TAG_NAME
            elseif char == "?" then
                token = {TOKEN_TYPES.COMMENT, ""}
                state = STATE_LOOKUP.BOGUS_COMMENT
            elseif char == "" then
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, "<"})
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.DATA
            end
        end,
        ["END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
            elseif char == ">" then
                buffer:eat(1); state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                emit({TOKEN_TYPES.EOF})
            else
                token = {TOKEN_TYPES.COMMENT, ""}
                state = STATE_LOOKUP.BOGUS_COMMENT
            end
        end,
        ["TAG_NAME"] = function()
            local char = buffer:eat(1):lower()
            if whitespace[char] then
                state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" then
                state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" then
                emit(token)
                state = STATE_LOOKUP.DATA
            else ezprocess(char) end
        end,
        ["RCDATA_LT"] = function()
            if buffer:peek(1) == "/" then
                buffer:eat(1)
                tmp_buf = ""
                state = STATE_LOOKUP.END_TAG_OPEN
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.RCDATA
            end
        end,
        ["RCDATA_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.END_TAG
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                state = STATE_LOOKUP.RCDATA
            end
        end,
        ["RCDATA_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
               state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gsub(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
                state = STATE_LOOKUP.RCDATA
            end
        end,
        ["RAWTEXT_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.RAWTEXT_END_TAG_OPEN
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.RAWTEXT
            end
        end,
        ["RAWTEXT_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.RAWTEXT_END_TAG_NAME
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                state = STATE_LOOKUP.RAWTEXT
            end
        end,
        ["RAWTEXT_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
               state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gsub(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
                state = STATE_LOOKUP.RAWTEXT
            end
        end,
        ["SCRIPT_DATA_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.SCRIPT_DATA_END_TAG_OPEN
            elseif char == "!" then
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "!"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPE_START
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.SCRIPT_DATA
            end
        end,
        ["SCRIPT_DATA_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.SCRIPT_DATA_END_TAG_NAME
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                state = STATE_LOOKUP.SCRIPT_DATA
            end
        end,
        ["SCRIPT_DATA_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
               state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gsub(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
                state = STATE_LOOKUP.SCRIPT_DATA
            end
        end,
        ["SCRIPT_DATA_ESCAPE_START"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_START_DASH
            else
                state = STATE_LOOKUP.SCRIPT_DATA
            end
        end,
        ["SCRIPT_DATA_ESCAPE_START_DASH"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH_DASH
            else
                state = STATE_LOOKUP.SCRIPT_DATA            
            end
        end,
        ["SCRIPT_DATA_ESCAPED"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_LT
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_ESCAPED_DASH"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH_DASH
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_LT
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_ESCAPED_DASH_DASH"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_LT
            elseif char == ">" then
                emit({TOKEN_TYPES.CHARACTER, ">"})
                state = STATE_LOOKUP.SCRIPT_DATA
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_ESCAPED_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_END_TAG_OPEN
            elseif characters[char] then
                tmp_buf = ""
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPE_START
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_ESCAPED_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_END_TAG_NAME
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_ESCAPED_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); token[2] = token[2]..char:lower()
                tmp_buf=tmp_buf..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
               state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gsub(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPE_START"] = function()
            local char = buffer:peek(1)
            if whitespace[char] or char:find("[/>]") then
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, char})
                state = (tmp_buf == "script" and STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED)
                    or STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            elseif characters[char] then
                buffer:eat(1); tmp_buf = tmp_buf..char:lower()
                emit({TOKEN_TYPES.CHARACTER, char})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_DASH
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_LT
                emit({TOKEN_TYPES.CHARACTER, "<"})
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED_DASH"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_LT
                emit({TOKEN_TYPES.CHARACTER, "<"})
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH"] = function()
        
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED_LT"] = function()
        
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPE_END"] = function()
        
        end,
        ["BEFORE_ATTR_NAME"] = function()
        
        end,
        ["ATTR_NAME"] = function()
        
        end,
        ["AFTER_ATTR_NAME"] = function()
        
        end,
        ["BEFORE_ATTR_VALUE"] = function()
        
        end,
        ["ATTR_VAL_QUO"] = function()
        
        end,
        ["ATTR_VAL_NQ"] = function()
        
        end,
        ["AFTER_ATTR_VAL"] = function()
        
        end,
        ["SELF_CLOSING_START_TAG"] = function()
        
        end,
        ["BOGUS_COMMENT"] = function()
        
        end,
        ["MARKUP_DECLERATION_OPEN"] = function()
        
        end,
        ["COMMENT_START"] = function()
        
        end,
        ["COMMENT_START_DASH"] = function()
        
        end,
        ["COMMENT"] = function()
        
        end,
        ["COMMENT_LT"] = function()
        
        end,
        ["COMMENT_LT_BANG"] = function()
        
        end,
        ["COMMENT_LT_BANG_DASH"] = function()
        
        end,
        ["COMMENT_LT_BANG_DASH_DASH"] = function()
        
        end,
        ["COMMENT_END_DASH"] = function()
        
        end,
        ["COMMENT_END"] = function()
        
        end,
        ["COMMENT_END_BANG"] = function()
        
        end,
        ["DOCTYPE"] = function()
        
        end,
        ["BEFORE_DOCTYPE_NAME"] = function()
        
        end,
        ["DOCTYPE_NAME"] = function()
        
        end,
        ["AFTER_DOCTYPE_NAME"] = function()
        
        end,
        ["AFTER_DOCTYPE_PUBLIC_KEYWORD"] = function()
        
        end,
        ["BEFORE_DOCTYPE_PUBLIC_IDENTIFIER"] = function()
        
        end,
        ["DOCTYPE_PUBLIC_IDENTIFIER"] = function()
        
        end,
        ["AFTER_DOCTYPE_PUBLIC_IDENTIFIER"] = function()
        
        end,
        ["BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS"] = function()
        
        end,
    }
    
    state = STATE.DATA
    while not buffer:isEmpty() do state() end
    state()
	
	return parsed
end