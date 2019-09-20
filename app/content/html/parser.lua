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
    
    local TOKEN_TYPES = util.reverse {
        "CHARACTER", "EOF", "START_TAG", "COMMENT", "END_TAG", "DOCTYPE"
    }
    
    local REP_CHAR = "�"
    
    local STATE_LOOKUP, state, return_state, token, tmp_buf
    local attr_name, attr_val, quote_type, lastStartTagTokenName
    local insertion_mode = "initial" 
    
    local function processInsertionMode(token)
        local reprocess = true
        while reprocess == true do
            reprocess = false
            if insertion_mode == "initial" then
                if token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
                elseif token[1] == TOKEN_TYPES.COMMENT then
                    
                elseif token[1] == TOKEN_TYPES.DOCTYPE then
                    
                else
                    insertion_mode, reprocess = "before html", true
                end
            elseif insertion_mode == "before html" then
                if token[1] == TOKEN_TYPES.DOCTYPE then
                elseif token[1] == TOKEN_TYPES.COMMENT then
                
                elseif token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
                elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
                
                end
            end
        end
    end
    local function emit(token)
        if token[1] == TOKEN_TYPE.START_TAG then
            lastStartTagTokenName = token[1]
        end
        processInsertionMode(token)
    end
    
    STATE_LOOKUP = {
        ["DATA"] = function()
            local char = buffer:eat(1)
            if char == "&" then
                return_state = STATE_LOOKUP.DATA
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == "<" then
                state = STATE_LOOKUP.TAG_OPEN
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
        end,
        ["RCDATA"] = function()
            local char = buffer:eat(1)
            if char == "&" then
                return_state = STATE_LOOKUP.RCDATA
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == "<" then
                state = STATE_LOOKUP.RCDATA_LT
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
        end,
        ["RAWTEXT"] = function()
            local char = buffer:eat(1)
            if char == "<" then
                state = STATE_LOOKUP.RAWTEXT_LT
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
        end,
        ["SCRIPT_DATA"] = function()
            local char = buffer:eat(1)
            if char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_LT
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
        end,
        ["PLAINTEXT"] = function()
            local char = buffer:eat(1)
            if char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
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
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, " "})
            end
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
            local char = buffer:eat(1)
            if char == "-" then 
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
                emit({TOKEN_TYPES.CHARACTER, "<"})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_LT
            elseif char == ">" then
                emit({TOKEN_TYPES.CHARACTER, ">"})
                state = STATE_LOOKUP.SCRIPT_DATA
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
        ["SCRIPT_DATA_DOUBLE_ESCAPED_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                emit({TOKEN_TYPES.CHARACTER, "/"})
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPE_END
            else
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPE_END"] = function()
            local char = buffer:peek(1)
            if whitespace[char] or char:find("[/>]") then
                buffer:eat(1)
                if tmp_buf == "script" then
                    state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                else
                    state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
                end
                emit({TOKEN_TYPES.CHARACTER, char})
            elseif characters[char] then
                buffer:eat(1); tmp_buf = tmp_buf..char:lower()
                emit({TOKEN_TYPES.CHARACTER, char})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
            end
        end,
        ["BEFORE_ATTR_NAME"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char:find("[/>]") or char=="" then
                state = STATE_LOOKUP.AFTER_ATTR_NAME
            elseif char == "=" then
                buffer:eat(1);
                attr_name, attr_value = char, ""
                state = STATE_LOOKUP.ATTR_NAME
            else
                attr_name, attr_value = "", ""
                state = STATE_LOOKUP.ATTR_NAME
            end
        end,
        ["ATTR_NAME"] = function() --TODO: attr_name, attr_value
            local char = buffer:peek(1)
            if whitespace[char] or char:find("[/>]") or char == "" then
                state = STATE_LOOKUP.AFTER_ATTR_NAME
            elseif char == "=" then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_VALUE
            elseif char == "\0" then
                buffer:eat(1); attr_name=attr_name..REP_CHAR
            else
                buffer:eat(1); attr_name=attr_name..char:lower()
            end
        end,
        ["AFTER_ATTR_NAME"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "/" then
                buffer:eat(1); state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == "=" then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_VALUE
            elseif char == ">" then
                buffer:eat(1); state = STATE_LOOKUP.DATA
                emit(token)
            elseif char == "/" then
                buffer:eat(1);
                emit({TOKEN_TYPES.EOF})
            end
        end,
        ["BEFORE_ATTR_VALUE"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char:find("\"'") then
                buffer:eat(1); quote_type = char
                state = STATE_LOOKUP.ATTR_VAL_QUO
            elseif char == ">" then
                state = STATE_LOOKUP.DATA
            end
        end,
        ["ATTR_VAL_QUO"] = function()
            local char = buffer:eat(1)
            if char == quote_type then
                state = STATE_LOOKUP.AFTER_ATTR_VAL
            elseif char == "&" then
                return_state = state
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == "\0" then
                attr_value = attr_value..REP_CHAR
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                attr_value = attr_value..char
            end
        end,
        ["ATTR_VAL_NQ"] = function()
            local char = buffer:eat(1)
            if whitespace[char] then
                state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "&" then
                return_state = state
                state = STATE_LOOKUP.CHARACTER_REFERENCE
            elseif char == ">" then
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "\0" then
                attr_value = attr_value..REP_CHAR
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                attr_value = attr_value..char
            end
        end,
        ["AFTER_ATTR_VAL"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" then
                buffer:eat(1); state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" then
                buffer:eat(1); emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1); emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.BEFORE_ATTR_NAME
            end
        end,
        ["SELF_CLOSING_START_TAG"] = function()
            local char = buffer:peek(1)
            if char == ">" then
                buffer:eat(1)
                token.selfClosing = true
                emit(token)
                state = STATE_LOOKUP.DATA_STATE
            elseif char == "" then
                buffer:eat(1); emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.BEFORE_ATTR_NAME
            end
        end,
        ["BOGUS_COMMENT"] = function()
            local char = buffer:eat(1)
            if char == ">" then
                emit(token)
                state = STATE_LOOKUP.DATA_STATE
            elseif char == "" then
                emit(token); emit({TOKEN_TYPES.EOF})
            elseif char == "\0" then
                token[2] = token[2]..REP_CHAR
            else
                token[2] = token[2]..char
            end
        end,
        ["MARKUP_DECLERATION_OPEN"] = function()
            if buffer:peek(2) == "--" then
                buffer:eat(2)
                token = {TOKEN_TYPES.COMMENT, ""}
                state = STATE_LOOKUP.COMMENT_START
            elseif buffer:peek(7):upper() == "DOCTYPE" then
                buffer:eat(7)
                state = STATE_LOOKUP.DOCTYPE
            elseif buffer:peek(7) == "[CDATA[" then
                buffer:eat(7)
                --TODO
                token = {TOKEN_TYPES.COMMENT, "[CDATA["}
                state = STATE_LOOKUP.BOGUS_COMMENT
            else
                token = {TOKEN_TYPES.COMMENT, ""}
                state = STATE_LOOKUP.BOGUS_COMMENT
            end
        end,
        ["COMMENT_START"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_START_DASH
            elseif char == ">" then
                buffer:eat(1); emit(token)
                state = STATE_LOOKUP.DATA
            else
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["COMMENT_START_DASH"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_END
            elseif char == ">" then
                buffer:eat(1); emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1); emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2].."-"
            end
        end,
        ["COMMENT"] = function()
            local char = buffer:eat(1)
            if char == "<" then
                token[2] = token[2]..char
                state = STATE_LOOKUP.COMMENT_LT
            elseif char == "-" then
                state = STATE_LOOKUP.COMMENT_END_DASH
            elseif char == "" then
                emit(token)
                emit({TOKEN_TYPE.EOF})
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            else
                token[2] = token[2]..char
            end
        end,
        ["COMMENT_LT"] = function()
            local char = buffer:peek(1)
            if char == "<" or char == "!" then
                buffer:eat(1)
                token[2] = token[2]..char
            else
                state = STATE_LOOKUP.COMMENT
            end
            if char == "!" then state = STATE_LOOKUP.COMMENT_LT_BANG end
        end,
        ["COMMENT_LT_BANG"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_LT_BANG_DASH
            else
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["COMMENT_LT_BANG_DASH"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_LT_BANG_DASH_DASH
            else
                state = STATE_LOOKUP.COMMENT_END_DASH
            end
        end,
        ["COMMENT_LT_BANG_DASH_DASH"] = function()
            state = STATE_LOOKUP.COMMENT_END --TODO: We can simplify a few states
        end,
        ["COMMENT_END_DASH"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_END
            elseif char == "" then
                buffer:eat(1)
                emit(token); emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2].."-"
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["COMMENT_END"] = function()
            local char = buffer:peek(1)
            if char == ">" then
                buffer:eat(1)
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "!" then
                buffer:eat(1)
                state = STATE_LOOKUP.COMMENT_END
            elseif char == "-" then
                buffer:eat(1)
                token[2] = token[2]..char
            elseif char == "" then
                buffer:eat(1); emit(token); emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2].."--"
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["COMMENT_END_BANG"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                buffer:eat(1)
                token[2] = token[2].."--!"
                state = STATE_LOOKUP.COMMENT_END_DASH
            elseif char == ">" then
                buffer:eat(1)
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1); emit(token); emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2].."--!"
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["DOCTYPE"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "" then
                buffer:eat(1)
                emit({TOKEN_TYPES.DOCTYPE, "", forceQuirks = true})
                emit({TOKEN_TYPES.EOF})
            end
            state = STATE_LOOKUP.BEFORE_DOCTYPE_NAME
        end,
        ["BEFORE_DOCTYPE_NAME"] = function()
            local char = buffer:eat(1)
            if whitespace[char] then
            elseif char == ">" then
                emit({TOKEN_TYPES.DOCTYPE, "", forceQuirks = true})
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                emit({TOKEN_TYPES.DOCTYPE, "", forceQuirks = true})
                emit({TOKEN_TYPES.EOF})
            elseif char == "\0" then
                token = {TOKEN_TYPES.DOCTYPE, REP_CHAR}
                state = STATE_LOOKUP.DOCTYPE_NAME
            else
                token = {TOKEN_TYPES.DOCTYPE, char}
                state = STATE_LOOKUP.DOCTYPE_NAME
            end
        end,
        ["DOCTYPE_NAME"] = function()
            local char = buffer:eat(1)
            if whitespace[char] then
                state = STATE_LOOKUP.AFTER_DOCTYPE_NAME
            elseif char == ">" then
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            elseif char == "\0" then
                token[2] = token[2]..REP_CHAR
            else
                token[2] = token[2]..char
            end
        end,
        ["AFTER_DOCTYPE_NAME"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == ">" then
                buffer:eat(1)
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                if buffer:peek(6):upper() == "PUBLIC" then
                    buffer:eat(6)
                    state = STATE_LOOKUP.AFTER_DOCTYPE_PUBLIC_KEYWORD
                elseif buffer:peek(6):upper() == "SYSTEM" then
                    buffer:eat(6)
                    state = STATE_LOOKUP.AFTER_DOCTYPE_SYSTEM_KEYWORD
                else
                    token.forceQuirks = true
                    state = STATE_LOOKUP.BOGUS_DOCTYPE
                end
            end
        end,
        ["AFTER_DOCTYPE_PUBLIC_KEYWORD"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
                state = STATE_LOOKUP.BEFORE_DOCTYPE_PUBLIC_IDENTIFIER
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.pubid = ""
                state = STATE_LOOKUP.DOCTYPE_PUBLIC_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["BEFORE_DOCTYPE_PUBLIC_IDENTIFIER"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.pubid = ""
                state = STATE_LOOKUP.DOCTYPE_PUBLIC_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["DOCTYPE_PUBLIC_IDENTIFIER"] = function()
            local char = buffer:eat(1)
            if char == quote_type then
                state = STATE_LOOKUP.AFTER_DOCTYPE_PUBLIC_IDENTIFIER
            elseif char == "" then
                token.forceQuirks = true
                emit(token); emit({TOKEN_TYPES.EOF})
            elseif char == "\0" then
                token.pubid = token.pubid..REP_CHAR
            elseif char == ">" then
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                token.pubid = token.pubid..char
            end
        end,
        ["AFTER_DOCTYPE_PUBLIC_IDENTIFIER"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
                state = STATE_LOOKUP.DOCTYPE_AND_PUBLIC_IDENTIFIERS
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.sysid = ""
                state = STATE_LOOKUP.DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1); emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["BETWEEN_DOCTYPE_PUBLIC_AND_SYSTEM_IDENTIFIERS"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.sysid = ""
                state = STATE_LOOKUP.DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1)
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["AFTER_DOCTYPE_SYSTEM_KEYWORD"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
                state = STATE_LOOKUP.BEFORE_DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.sysid = ""
                state = STATE_LOOKUP.DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["BEFORE_DOCTYPE_SYSTEM_IDENTIFIER"] = function() --TODO
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "'" or char == "\"" then
                buffer:eat(1)
                quote_type = char
                token.sysid = ""
                state = STATE_LOOKUP.DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == ">" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                token.forceQuirks = true
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["DOCTYPE_SYSTEM_IDENTIFIER"] = function()
            local char = buffer:eat(1)
            if char == quote_type then
                state = STATE_LOOKUP.AFTER_DOCTYPE_SYSTEM_IDENTIFIER
            elseif char == "" then
                token.forceQuirks = true
                emit(token); emit({TOKEN_TYPES.EOF})
            elseif char == "\0" then
                token.sysid = token.pubid..REP_CHAR
            elseif char == ">" then
                token.forceQuirks = true
                emit(token)
                state = STATE_LOOKUP.DATA
            else
                token.pubid = token.sysid..char
            end
        end,
        ["AFTER_DOCTYPE_SYSTEM_IDENTIFIER"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char == ">" then
                buffer:eat(1)
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                buffer:eat(1)
                token.forceQuirks = true
                emit(token)
                emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.BOGUS_DOCTYPE
            end
        end,
        ["BOGUS_DOCTYPE"] = function()
            local char = buffer:eat(1)
            if char == ">" then
                emit(token)
                state = STATE_LOOKUP.DATA
            elseif char == "" then
                emit(token)
                emit({TOKEN_TYPES.EOF})
            end
        end,
        ["CDATA_SECTION"] = function()
            local char = buffer:eat(1)
            if char == "]" then
                state = STATE_LOOKUP.CDATA_SECTION_BRACKET
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["CDATA_SECTION_BRACKET"] = function()
            if buffer:peek(1) == "]" then
                buffer:eat(1)
                state = STATE_LOOKUP.CDATA_SECTION_END
            else
                emit({TOKEN_TYPES.CHARACTER, "]"})
                state = STATE_LOOKUP.CDATA_SECTION
            end
        end,
        ["CDATA_SECTION_END"] = function()
            local char = buffer:peek(1)
            if char == "]" then
                buffer:eat(1)
                emit({TOKEN_TYPES.CHARACTER, "]"})
            elseif char == ">" then
                buffer:eat(1)
                state = STATE_LOOKUP.DATA
            else
                emit({TOKEN_TYPES.CHARACTER, "]"})
                emit({TOKEN_TYPES.CHARACTER, "]"})
                state = STATE_LOOKUP.CDATA_SECTION
            end
        end,
        ["CHARACTER_REFERENCE"] = function()
            --TODO
            state = return_state
        end,
        ["NAMED_CHARACTER_REFERENCE"] = function()
        
        end,
        ["AMBIGUOUS_AMPERSAND"] = function()
        
        end,
        ["NUMERIC_CHARACTER_REFERENCE"] = function()
        
        end,
        ["HEXADECIMAL_CHARACTER_REFERENCE_START"] = function()
        
        end,
        ["DECIMAL_CHARACTER_REFERENCE_START"] = function()
        
        end,
        ["HEXADECIMAL_CHARACTER_REFERENCE"] = function()
        
        end,
        ["DECIMAL_CHARACTER_REFERENCE"] = function()
        
        end,
        ["NUMERIC_CHARACTER_REFERENCE_END"] = function()
        
        end
    }
    
    state = STATE.DATA
    while not buffer:isEmpty() do state() end
    state()
	
	return parsed
end