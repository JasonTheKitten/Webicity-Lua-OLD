local ribbon = require()

local class = ribbon.require "class"
local util = ribbon.require "util"
local environment = ribbon.require "environment"

local Buffer = ribbon.reqpath("${CLASS}/string/buffer").Buffer

local parser = ...

local isOC = environment.is("OC")

local HTMLParser = {}
parser.HTMLParser = HTMLParser

HTMLParser.cparents = {class.Class}

--https://html.spec.whatwg.org/#tokenization
function HTMLParser.parse(buffer)
    class.checkType(buffer, Buffer, 2, "Buffer")
    
    local abc = "abcdefghijklmnopqrstuvwxyz"
	local characters = util.stringToTable(abc..abc:upper(), true)
	local whitespace = util.stringToTable("\n\t\f\r ", true)
    
    local TOKEN_TYPES = util.reverse {
        "CHARACTER", "EOF", "START_TAG", "COMMENT", "END_TAG", "DOCTYPE"
    }
    
    local REP_CHAR = "�"
    
    local STATE_LOOKUP, state, return_state, token, tmp_buf
    local attr_name, attr_value, quote_type, lastStartTagTokenName
	
	local function matches(v, ...) --TODO: Move to Ribbon
		for k, m in pairs({...}) do
			if v==m then return true end
		end
		return false
	end

	local function strlookfor(part, pattern)
		if isOC then
			local fres
			for i=1, #pattern do --Avoid patterns, as they are slow on OC
				local res = part:find(pattern:sub(i, i))
				if res then
					fres = fres or res
					fres = (res<fres and res) or fres
				end
			end
			return fres
		else
			return part:find("["..pattern.."]")
		end
	end
	local function lookfor(pattern)
		local len = 0
		while not buffer:isEmpty(len) do
			len = len+buffer.chunksize
			local part = buffer:peek(len)
			local fres = strlookfor(part, pattern)
			if fres then return fres end
		end
		return buffer:length()+1
	end

	local MODE_LOOKUP, insertion_mode, original_insertion_mode
	local reprocess, mode_override
    local function processInsertionMode(token)
        reprocess, mode_override = true, nil
		MODE_LOOKUP = MODE_LOOKUP or {
			["INITIAL"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
					
                elseif token[1] == TOKEN_TYPES.COMMENT then
				
                elseif token[1] == TOKEN_TYPES.DOCTYPE then
				
                else
                    insertion_mode, reprocess = MODE_LOOKUP.BEFORE_HTML, true
                end
			end,
			["BEFORE_HTML"] = function(token)
				if token[1] == TOKEN_TYPES.DOCTYPE then
                elseif token[1] == TOKEN_TYPES.COMMENT then
                
                elseif token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
                elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
                
				elseif token[1] == TOKEN_TYPES.END_TAG and not matches(token[2], "head", "body", "html", "br") then
					
				else
					
					insertion_mode, reprocess = MODE_LOOKUP.BEFORE_HEAD, true
                end
			end,
			["BEFORE_HEAD"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
				elseif token[1] == TOKEN_TYPES.COMMENT then
					
				elseif token[1] == TOKEN_TYPES.DOCTYPE then
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
					mode_override, reprocess = MODE_LOOKUP.IN_BODY, true
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "head" then
					
					insertion_mode = MODE_LOOKUP.IN_HEAD
				elseif token[1] == TOKEN_TYPES.END_TAG and not matches(token[2], "head", "body", "html", "br") then
				else
				
					insertion_mode, reprocess = MODE_LOOKUP.IN_HEAD, true
				end
			end,
			["IN_HEAD"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
				
				elseif token[1] == TOKEN_TYPES.COMMENT then
				
				elseif token[1] == TOKEN_TYPES.DOCTYPE then
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
					mode_override, reprocess = MODE_LOOKUP.IN_BODY, true
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "base", "basefont", "bgsound", "link") then
					
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "meta" then
					
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "title" then
					--TODO: Use algo
					state = STATE_LOOKUP.RCDATA
					original_insertion_mode = insertion_mode
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "noscript", "noframes", "style") then
					--TODO
					state = STATE_LOOKUP.RAWTEXT
					original_insertion_mode = insertion_mode
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "script" then
					state = STATE_LOOKUP.SCRIPT_DATA
					original_insertion_mode = insertion_mode --TODO: Direct function from lookup?
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "template" then
				
					insertion_mode = MODE_LOOKUP.IN_TEMPLATE
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "head" then
					
					insertion_mode = MODE_LOOKUP.AFTER_HEAD
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "template" then
				
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "head" then
				elseif token[1] == TOKEN_TYPES.END_TAG and not matches(token[2], "body", "html", "br") then
				else
				
					insertion_mode, reprocess = MODE_LOOKUP.AFTER_HEAD, true
				end
			end,
			["IN_HEAD_NOSCRIPT"] = function(token)
			
			end,
			["AFTER_HEAD"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
				
				elseif token[1] == TOKEN_TYPES.COMMENT then
				
				elseif token[1] == TOKEN_TYPES.DOCTYPE then
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
					mode_override, reprocess = MODE_LOOKUP.IN_BODY, true
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "body" then
					
					insertion_mode = MODE_LOOKUP.IN_BODY
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "frameset" then
					
					insertion_mode = MODE_LOOKUP.IN_FRAMESET
				elseif token[1] == TOKEN_TYPES.START_TAG and
					matches(token[2], "base", "basefont", "bgsound", "link", "meta", "noframes", "script", "style", "template", "title") then
					
					mode_override, reprocess = MODE_LOOKUP.IN_HEAD, true --TODO: Call function instead?
					
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2]=="template" then
					mode_override, reprocess = MODE_LOOKUP.IN_HEAD, true
				elseif (token[1] == TOKEN_TYPES.START_TAG and token[2] == "head") or
					(token[1] == TOKEN_TYPES.END_TAG and not matches(token[2], "body", "html", "br")) then
				else
					
					insertion_mode, reprocess = MODE_LOOKUP.IN_BODY, true
				end
			end,
			["IN_BODY"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER and token[2] == "\0" then
				elseif token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] then
				
				elseif token[1] == TOKEN_TYPES.CHARACTER then
				
				elseif token[1] == TOKEN_TYPES.COMMENT then
				
				elseif token[1] == TOKEN_TYPES.DOCTYPE then
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "html" then
				
				elseif (token[1] == TOKEN_TYPES.START_TAG
					and matches(token[2], "base", "basefont", "bgsound", "link", "meta", "noframes", "script", "style", "template", "title")) or
					(token[1] == TOKEN_TYPES.END_TAG and token[2] == "template") then
					
					mode_override, reprocess = MODE_LOOKUP.IN_HEAD, true
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "body" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "frameset" then
				
				elseif token[1] == TOKEN_TYPES.EOF then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "body" then
				
					insertion_mode = MODE_LOOKUP.AFTER_BODY
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "html" then
					
					insertion_mode, reprocess = MODE_LOOKUP.AFTER_BODY, true
				elseif token[1] == TOKEN_TYPES.START_TAG and 
					matches(token[2],"address", "article", "aside", "blockquote", "center", "details", "dialog", "dir", "div", "dl", "fieldset", "figcaption",
						"figure", "footer", "header", "hgroup", "main", "menu", "nav", "ol", "p", "section", "summary", "ul") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "h1", "h2", "h3", "h4", "h5", "h6") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "pre", "listing") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "form" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "li" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "dd", "dt") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "plaintext" then
					
					insertion_mode = MODE_LOOKUP.PLAINTEXT --Goodbye, fair world
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "button" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and
					matches(token[2],"address", "article", "aside", "blockquote", "center", "details", "dialog", "dir", "div", "dl", "fieldset", "figcaption",
						"figure", "footer", "header", "hgroup", "main", "menu", "nav", "ol", "p", "section", "summary", "ul") then
						
						
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "form" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "p" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "li" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and matches(token[2], "dd", "dt") then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and matches(token[2], "h1", "h2", "h3", "h4", "h5", "h6") then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "sarcasm" and false then
					takeADeepBreath()
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "a" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and
					matches(token[2], "b", "big", "code", "em", "font", "i", "s", "small", "strike", "strong", "tt", "u") then
					
					
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "nobr" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and
					matches(token[2], "a", "b", "big", "code", "em", "font", "i", "nobr", "s", "small", "strike", "strong", "tt", "u") then
					
					
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "applet", "marquee", "object") then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and matches(token[2], "applet", "marquee", "object") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2]=="table" then
				
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "br" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "area", "br", "embed", "img", "keygen", "wbr") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "param", "source", "track") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "hr" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "image" then
					token[2], reprocess = "img", true
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "textarea" then
				
					state = STATE_LOOKUP.RCDATA
					original_insertion_mode = insertion_mode
					
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "xmp" then
				
					state = STATE_LOOKUP.RAWTEXT
					original_insertion_mode = insertion_mode
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "iframe" then
				
					state = STATE_LOOKUP.RAWTEXT
					original_insertion_mode = insertion_mode
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "noembed", "noscript") then
					state = STATE_LOOKUP.RAWTEXT
					original_insertion_mode = insertion_mode
					insertion_mode = MODE_LOOKUP.TEXT
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "select" then
				
					insertion_mode = MODE_LOOKUP.IN_SELECT
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "rb", "rtc") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and matches(token[2], "rp", "rt") then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "math" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and token[2] == "svg" then
				
				elseif token[1] == TOKEN_TYPES.START_TAG and
					matches(token[2], "caption", "col", "colgroup", "frame", "head", "tbody", "td", "tfoot", "th", "thead", "tr") then
				elseif token[1] == TOKEN_TYPES.START_TAG then
				
				elseif token[2] == TOKEN_TYPES.END_TAG then
					
				end
			end,
			["TEXT"] = function(token)
				if token[1] == TOKEN_TYPES.CHARACTER then
					
				elseif token[1] == TOKEN_TYPES.EOF then
					insertion_mode, reprocess = original_insertion_mode, true
				elseif token[1] == TOKEN_TYPES.END_TAG and token[2] == "script" then
					
					insertion_mode = original_insertion_mode
				else
					
					insertion_mode = original_insertion_mode
				end
			end,
			["IN_TABLE"] = function(token)
			
			end,
			["IN_TABLE_TEXT"] = function(token)
			
			end,
			["IN_CAPTION"] = function(token)
			
			end,
			["IN_COLUMN_GROUP"] = function(token)
			
			end,
			["IN_TABLE_BODY"] = function(token)
			
			end,
			["IN_ROW"] = function(token)
			
			end,
			["IN_CELL"] = function(token)
			
			end,
			["IN_SELECT"] = function(token)
			
			end,
			["IN_SELECT_IN_TABLE"] = function(token)
			
			end,
			["IN_TEMPLATE"] = function(token)
			
			end,
			["AFTER_BODY"] = function(token)
			
			end,
			["IN_FRAMESET"] = function(token)
			
			end,
			["AFTER_FRAMESET"] = function(token)
			
			end,
			["AFTER_AFTER_BODY"] = function(token)
				if token[1] == TOKEN_TYPES.COMMENT then
				
				elseif token[1] == TOKEN_TYPES.DOCTYPE or
					token[1] == TOKEN_TYPES.CHARACTER and whitespace[token[2]] or
					token[1] == TOKEN_TYPES.START_TAG and token[2] =="html" then
				
					mode_override = MODE_LOOKUP.IN_BODY
				elseif token[1] ~= TOKEN_TYPES.EOF then
					insertion_mode, reprocess = MODE_LOOKUP.IN_BODY, true
				end
			end,
			["AFTER_AFTER_FRAMESET"] = function(token)
			
			end
		}
		insertion_mode = insertion_mode or MODE_LOOKUP.INITIAL

		--TODO: Divide character tokens
        while reprocess == true do
            reprocess = false
			local cur_mode = mode_override or insertion_mode
			mode_override = nil
			cur_mode(token)
        end
    end
    local function emit(token)
        if token[1] == TOKEN_TYPES.START_TAG then
            lastStartTagTokenName = token[2]
        end
		if token[1] == TOKEN_TYPES.CHARACTER then
			processInsertionMode({TOKEN_TYPES.CHARACTER, token[2]})
		else
			processInsertionMode(token)
		end
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
				--print(char..buffer:peek(lookfor("&<\0")-1))
                emit({TOKEN_TYPES.CHARACTER, char..buffer:eat(lookfor(" \t\n\f\r&<\0")-1)})
                --buffer:eat(lookfor("&<\0")-1)
                --emit({TOKEN_TYPES.CHARACTER, char})
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
                emit({TOKEN_TYPES.CHARACTER, char})
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
                emit({TOKEN_TYPES.CHARACTER, char..buffer:eat(lookfor("<\0")-1)})
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
                emit({TOKEN_TYPES.CHARACTER, char..buffer:eat(lookfor("<\0")-1)})
                emit({TOKEN_TYPES.CHARACTER, char..buffer:eat(lookfor("<\0")-1)})
            end
        end,
        ["PLAINTEXT"] = function()
            local char = buffer:eat(1)
            if char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                emit({TOKEN_TYPES.CHARACTER, char})
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
                state = STATE_LOOKUP.DATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
            end
        end,
        ["END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
				state = STATE_LOOKUP.TAG_NAME
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
                state = STATE_LOOKUP.DATA
                emit(token)
            elseif char == "\0" then
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2]..char
            end
        end,
        ["RCDATA_LT"] = function()
            if buffer:peek(1) == "/" then
                buffer:eat(1)
                tmp_buf = ""
                state = STATE_LOOKUP.END_TAG_OPEN
            else
                state = STATE_LOOKUP.RCDATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
            end
        end,
        ["RCDATA_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.END_TAG
            else
                state = STATE_LOOKUP.RCDATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
            end
        end,
        ["RCDATA_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
				state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
                state = STATE_LOOKUP.DATA
                emit(token)
            else
                state = STATE_LOOKUP.RCDATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gmatch(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
            end
        end,
        ["RAWTEXT_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.RAWTEXT_END_TAG_OPEN
            else
                state = STATE_LOOKUP.RAWTEXT
                emit({TOKEN_TYPES.CHARACTER, "<"})
            end
        end,
        ["RAWTEXT_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.RAWTEXT_END_TAG_NAME
            else
                state = STATE_LOOKUP.RAWTEXT
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
            end
        end,
        ["RAWTEXT_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
				token[2] = token[2]..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
				state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
                state = STATE_LOOKUP.DATA
                emit(token)
            else
                state = STATE_LOOKUP.RAWTEXT
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gmatch(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
            end
        end,
        ["SCRIPT_DATA_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.SCRIPT_DATA_END_TAG_OPEN
            elseif char == "!" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPE_START
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "!"})
            else
                state = STATE_LOOKUP.SCRIPT_DATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
            end
        end,
        ["SCRIPT_DATA_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.SCRIPT_DATA_END_TAG_NAME
            else
                state = STATE_LOOKUP.SCRIPT_DATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
            end
        end,
        ["SCRIPT_DATA_END_TAG_NAME"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                buffer:eat(1); tmp_buf=tmp_buf..char:lower()
				token[2] = token[2]..char:lower()
            elseif whitespace[char] and token[2] == lastStartTagTokenName then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
				state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
                state = STATE_LOOKUP.DATA
                emit(token)
            else
                state = STATE_LOOKUP.SCRIPT_DATA
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gmatch(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
            end
        end,
        ["SCRIPT_DATA_ESCAPE_START"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                state = STATE_LOOKUP.SCRIPT_DATA_START_DASH
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, "-"})
            else
                state = STATE_LOOKUP.SCRIPT_DATA
            end
        end,
        ["SCRIPT_DATA_ESCAPE_START_DASH"] = function()
            local char = buffer:peek(1)
            if char == "-" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH_DASH
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, "-"})
            else
                state = STATE_LOOKUP.SCRIPT_DATA            
            end
        end,
        ["SCRIPT_DATA_ESCAPED"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH
                emit({TOKEN_TYPES.CHARACTER, "-"})
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
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_DASH_DASH
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_LT
            elseif char == "\0" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_ESCAPED_DASH_DASH"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_LT
            elseif char == ">" then
                state = STATE_LOOKUP.SCRIPT_DATA
                emit({TOKEN_TYPES.CHARACTER, ">"})
            elseif char == "\0" then
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
				state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_ESCAPED_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_END_TAG_OPEN
            elseif characters[char] then
                tmp_buf = ""
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPE_START
                emit({TOKEN_TYPES.CHARACTER, "<"})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, "<"})
            end
        end,
        ["SCRIPT_DATA_ESCAPED_END_TAG_OPEN"] = function()
            local char = buffer:peek(1)
            if characters[char] then
                token = {TOKEN_TYPES.END_TAG, ""}
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED_END_TAG_NAME
            else
                state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
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
				buffer:eat(1)
				state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" and token[2] == lastStartTagTokenName then
				buffer:eat(1)
				state = STATE_LOOKUP.DATA
                emit(token)
            else
				state = STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, "<"})
                emit({TOKEN_TYPES.CHARACTER, "/"})
                for char in tmp_buf:gmatch(".") do
                    emit({TOKEN_TYPES.CHARACTER, char})
                end
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPE_START"] = function()
            local char = buffer:peek(1)
            if whitespace[char] or char=="/" or char==">" then
				state = (tmp_buf == "script" and STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED)
                    or STATE_LOOKUP.SCRIPT_DATA_ESCAPED
                buffer:eat(1); emit({TOKEN_TYPES.CHARACTER, char})
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
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_DASH
                emit({TOKEN_TYPES.CHARACTER, "-"})
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
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_LT
                emit({TOKEN_TYPES.CHARACTER, "<"})
            elseif char == "\0" then
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED_DASH_DASH"] = function()
            local char = buffer:eat(1)
            if char == "-" then
                emit({TOKEN_TYPES.CHARACTER, "-"})
            elseif char == "<" then
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED_LT
                emit({TOKEN_TYPES.CHARACTER, "<"})
            elseif char == ">" then
				state = STATE_LOOKUP.SCRIPT_DATA
                emit({TOKEN_TYPES.CHARACTER, ">"})
            elseif char == "\0" then
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, REP_CHAR})
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
                emit({TOKEN_TYPES.CHARACTER, char})
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPED_LT"] = function()
            local char = buffer:peek(1)
            if char == "/" then
                buffer:eat(1); tmp_buf = ""
				state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPE_END
                emit({TOKEN_TYPES.CHARACTER, "/"})
            else
                state = STATE_LOOKUP.SCRIPT_DATA_DOUBLE_ESCAPED
            end
        end,
        ["SCRIPT_DATA_DOUBLE_ESCAPE_END"] = function()
            local char = buffer:peek(1)
            if whitespace[char] or char=="/" or char==">" then
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
            elseif char=="/" or char==">" or char=="" then
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
            if whitespace[char] or char=="/" or char==">" or char == "" then
                state = STATE_LOOKUP.AFTER_ATTR_NAME
            elseif char == "=" then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_VALUE
            elseif char == "\0" then
                buffer:eat(1); attr_name=attr_name..REP_CHAR
            else
                attr_name=attr_name..buffer:eat(1)..buffer:eat(lookfor(" \n\t\r/>=\0")-1):lower()
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
            elseif char == "" then
                buffer:eat(1);
                emit({TOKEN_TYPES.EOF})
			else
				attr_name, attr_value = "", ""
				state = STATE_LOOKUP.ATTR_NAME
            end
        end,
        ["BEFORE_ATTR_VALUE"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1)
            elseif char=="'" or char=="\"" then
                buffer:eat(1); quote_type = char
                state = STATE_LOOKUP.ATTR_VAL_QUO
            elseif char == ">" then
				buffer:eat(1)
			    state = STATE_LOOKUP.DATA
				emit(token)
			else
				state = STATE_LOOKUP.ATTR_VAL_NQ
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
                attr_value = attr_value..char..buffer:eat(lookfor(quote_type)-1)
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
				state = STATE_LOOKUP.DATA
                emit(token)
            elseif char == "\0" then
                attr_value = attr_value..REP_CHAR
            elseif char == "" then
                emit({TOKEN_TYPES.EOF})
            else
                attr_value = attr_value..char..buffer:eat(lookfor(" \t\r\n\f&>\0")-1)
            end
        end,
        ["AFTER_ATTR_VAL"] = function()
            local char = buffer:peek(1)
            if whitespace[char] then
                buffer:eat(1); state = STATE_LOOKUP.BEFORE_ATTR_NAME
            elseif char == "/" then
                buffer:eat(1); state = STATE_LOOKUP.SELF_CLOSING_START_TAG
            elseif char == ">" then
				state = STATE_LOOKUP.DATA
                buffer:eat(1); emit(token)
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
                state = STATE_LOOKUP.DATA
                emit(token)
            elseif char == "" then
                buffer:eat(1); emit({TOKEN_TYPES.EOF})
            else
                state = STATE_LOOKUP.BEFORE_ATTR_NAME
            end
        end,
        ["BOGUS_COMMENT"] = function()
            local char = buffer:eat(1)
            if char == ">" then
                state = STATE_LOOKUP.DATA
                emit(token)
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
                state = STATE_LOOKUP.DATA
                buffer:eat(1); emit(token)
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
                emit({TOKEN_TYPES.EOF})
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
                state = STATE_LOOKUP.DATA
                emit(token)
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
                state = STATE_LOOKUP.DATA
                emit(token)
            elseif char == "" then
                buffer:eat(1); emit(token); emit({TOKEN_TYPES.EOF})
            else
                token[2] = token[2].."--!"
                state = STATE_LOOKUP.COMMENT
            end
        end,
        ["DOCTYPE"] = function()
            local char = buffer:peek(1)
			state = STATE_LOOKUP.BEFORE_DOCTYPE_NAME
            if whitespace[char] then
                buffer:eat(1)
            elseif char == "" then
                buffer:eat(1)
                emit({TOKEN_TYPES.DOCTYPE, "", forceQuirks = true})
                emit({TOKEN_TYPES.EOF})
            end
        end,
        ["BEFORE_DOCTYPE_NAME"] = function()
            local char = buffer:eat(1)
            if whitespace[char] then
            elseif char == ">" then
				state = STATE_LOOKUP.DATA
                emit({TOKEN_TYPES.DOCTYPE, "", forceQuirks = true})
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                buffer:eat(1); emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
				state = STATE_LOOKUP.DATA
                emit(token)
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
                state = STATE_LOOKUP.DATA
				emit(token)
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
				state = STATE_LOOKUP.CDATA_SECTION
                emit({TOKEN_TYPES.CHARACTER, "]"})
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
				state = STATE_LOOKUP.CDATA_SECTION
                emit({TOKEN_TYPES.CHARACTER, "]"})
                emit({TOKEN_TYPES.CHARACTER, "]"})
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
    
    state = STATE_LOOKUP.DATA
	local tclock = os.clock()
    while not buffer:isEmpty() do
		local ost, ct = state, os.clock()
		state()
		if os.clock()-tclock>.2 then
			coroutine.yield()
			tclock = os.clock()
		end
	end
    state()
	
	
	return parsed
end