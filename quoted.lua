require [[lib.core]]

local original_G = {}

for k, v in pairs(_G) do
    original_G[k] = v
end

local tokenize

local TokenType = {
    Name = "name",
    Number = "number",
    String = "string",
    Paren = "paren",
    Bracket = "bracket",
    Brace = "brace",
    Special = "special",
    Delimiter = "delimiiter",
}

---@class Token
---@field type string
---@field value string
---@field map fun(self: Token, fn: fun(s: string): string): Token
---@field flatmap fun(self: Token, fn: fun(s: string): Token): Quote
---@field is fun(self: Token, value: string): boolean
---@field is_name fun(self: Token): boolean
---@field is_number fun(self: Token): boolean
---@field is_string fun(self: Token): boolean
---@field is_special fun(self: Token): boolean
---@field is_paren fun(self: Token): boolean
---@field is_bracket fun(self: Token): boolean
---@field is_brace fun(self: Token): boolean
---@field assert_is fun(self: Token, ...: string): nil

Token = setmetatable({
    name = "name",
    number = "number",
    string = "string",
    paren = "paren",
    bracket = "bracket",
    brace = "brace",
    special = "special",
    delimiter = "delimiter",
    __tostring = function(self)
        return tostring(self.value)
    end,
}, {
    __call = function(self, type, value)
        local token = setmetatable({}, self)
        token.type = type
        token.value = value
        return token
    end,
})
Token.__index = Token


--- Maps over each character of a token with the specified function
--- @param fn fun(s: string): string -- The transformation that will be applied to each character of the token
--- @return Token -- A new token with transformations applied
function Token:map(fn)
    local value = ""
    for i = 1, #self.value do
        local char = self.value:sub(i, i)
        value = value .. fn(char)
    end
    return Token(self.type, value)
end

--- Flatmaps over each character of a token with the specified function, generating a quote of all the results
--- @param fn fun(s: string): Token -- The transformation from string to Token that will be applied to each character of the token
--- @return Quote
function Token:flatmap(fn)
    local quote = Quote()
    for i = 1, #self.value do
        local char = self.value:sub(i, i)
        quote = quote:extend(Quote(fn(char)))
    end
    return quote
end

--- Returns true if the value of the token matches the specified value
--- @param value string
--- @return boolean
function Token:is(value)
    return self.value == value
end

--- Returns true if the type of the token is name
--- @return boolean
function Token:is_name()
    return self.type == "name"
end

--- Returns true if the type of the token is number
--- @return boolean
function Token:is_number()
    return self.type == "number"
end

--- Returns true if the type of the token is string
--- @return boolean
function Token:is_string()
    return self.type == "string"
end

--- Returns true if the type of the token is special
--- @return boolean
function Token:is_special()
    return self.type == "special"
end

--- Returns true if the type of the token is paren
--- @return boolean
function Token:is_paren()
    return self.type == "paren"
end

--- Returns true if the type of the token is bracket
--- @return boolean
function Token:is_bracket()
    return self.type == "bracket"
end

--- Returns true if the type of the token is brace
--- @return boolean
function Token:is_brace()
    return self.type == "brace"
end

--- Asserts that the token matches at least one of the specified types
--- @vararg string
--- @return nil
function Token:assert_is(...)
    local types = {...}
    local str = ""
    for i, type in pairs(types) do
        if i > 1 and i < #types then
            str = str .. ", "
        end
        if i == #types then
            str = str .. " or "
        end
        str = str .. type
        if self.type == type then
            return
        end
    end
    error("Expected one of " .. str .. ", but got " .. self.type .. " instead", 2)
end

function getenv(depth)
    local env = {
        f = f,
        println = println,
        loop = function(quote)
            local i, quote = quote:expect_name()
            quote = quote << "do"
            quote = quote >> "end"
            return Quote([[
                for %s in forever do
                    %s
                end
            ]], i, quote)
        end,
        select = function(quote)
            quote = quote << "["
            local mode, quote = quote:take_until("]")
            if #mode == 1 and mode[1].value == "#" then
                mode = Quote([["#"]])[1]
            end
            if #quote > 0 then
                quote = quote:prepend(",")
            end
            return Quote([[
                select(%s %s)
            ]], mode, quote)
        end,
    }
    for i = 1, debug.getinfo(1, "l").currentline do
        local name, value = debug.getlocal(depth + 2, i)
        if not name then
            break
        end
        env[name] = value
    end
    local __G = {}
    for k, v in pairs(_G) do
        __G[k] = v
    end
    for k, v in pairs(__G) do
      if original_G[k] then
        __G[k] = nil
      end
    end
    for k, v in pairs(env) do
        __G[k] = v
    end
    return __G
end

--- @class Quote
--- @field values {[number]: Token}
--- @field env {[string]: any}
--- @field enumerate fun(self: Quote): fun(): (number, Token) | nil
--- @field insert fun(self: Quote, index: number, value: Token): Quote
--- @field index_of fun(self: Quote, value: Token | string): number | nil
--- @field count fun(self: Quote, value: Token | string): number
--- @field reverse fun(self: Quote): Quote
--- @field remove fun(self: Quote, index: number): Token, Quote
--- @field contains fun(self: Quote, token: Token | string): boolean
--- @field append fun(self: Quote, value: Token | string): Quote
--- @field prepend fun(self: Quote, value: Token | string): Quote
--- @field pop fun(self: Quote): Token, Quote
--- @field peek_value fun(self: Quote): string
--- @field extend fun(self: Quote, other: Quote): Quote
--- @field slice fun(self: Quote, min: number, max: number?): Quote
--- @field expect fun(self: Quote, value: string): Token, Quote
--- @field consume fun(self: Quote, value: string): Quote
--- @field expect_last fun(self: Quote, value: string): Token, Quote
--- @field expect_type fun(self: Quote, ...: string): Token, Quote
--- @field expect_name fun(self: Quote): Token, Quote
--- @field expect_number fun(self: Quote): Token, Quote
--- @field expect_paren fun(self: Quote): Token, Quote
--- @field expect_bracket fun(self: Quote): Token, Quote
--- @field expect_brace fun(self: Quote): Token, Quote
--- @field expect_special fun(self: Quote): Token, Quote
--- @field expect_delimiter fun(self: Quote): Token, Quote
--- @field expect_string fun(self: Quote): Token, Quote
--- @field expect_last_type fun(self: Quote, type: string): Token, Quote
--- @field split fun(self: Quote, separator: string | Token, deep: boolean?): QuoteList
--- @field args fun(self: Quote): Quote
--- @field str fun(self: Quote): string
--- @field repr fun(self: Quote): string
--- @field balanced fun(self: Quote, start: string | Token, finish: string | Token): Quote | nil, Quote
--- @field replace fun(self: Quote, old: string | Token, new: string | Token): Quote
--- @field splitjoin fun(self: Quote, separator: string | Token, joiner: string | Token): Quote
--- @field map fun(self: Quote, fn: fun(token: Token): Token | Quote): Quote
--- @field foreach fun(self: Quote, fn: fun(token: Token))
--- @field pairs fun(self: Quote, fn: fun(i: number, token: Token))
--- @field take_until fun(self: Quote, separator: string | Token): Quote, Quote
--- @field rep fun(self: Quote, num: number): QuoteList
--- @field tolist fun(self: Quote): QuoteList
--- @field expr fun(self: Quote): any
Quote = setmetatable({
    __tostring = function(self)
        local str = ""
        for i, tok in self:enumerate() do
            if i > 1 then
                str = str .. " "
            end
            str = str .. tostring(tok)
        end
        return str
    end,
    --- Index
    --- @param key any
    --- @return Token
    __index = function(self, key)
        if type(key) == "number" then
            return rawget(self, "values")[key]
        end
        if key == "_" then
            local ok, result = pcall(expr, self)
            if not ok then
                error(result:gsub("^.-:%d+: ", ""), 2)
            end
            return result
        end
        if rawget(self, key) ~= nil then
            return rawget(self, key)
        end
        return rawget(Quote, key)
    end,
    __call = function(self)
        return block(self)
    end,
    __len = function(self)
        return #self.values
    end,
    __add = function(self, other)
        return self:append(other)
    end,
    __concat = function(self, other)
        return self:extend(other)
    end,
    __shl = function(self, value)
        return self:expect(value)
    end,
    __shr = function(self, value)
        return self:expect_last(value)
    end,
    __mul = function(self, num)
        return self:rep(num)
    end,
    __unm = function(self)
        return self:pop()
    end,
    --- Generates a new quote, with the environment of the specified one
    --- @param self Quote
    --- @param other Quote
    --- @return Quote
    from = function(self, other)
        local new = self()
        new.env = other.env
        return new
    end,
    iter = function(self)
        local index = 0
        local function iter()
            index = index + 1
            if self.values[index] then
                return self.values[index]
            end
        end
        return iter
    end,
}, {
    __call = function(self, str)
        local depth
        if type(str) ~= "nil" then
            str = tostring(str)
        end
        if str and type(str) == "string" then
            str = tokenize(str)
            depth = 1
        elseif type(str) == "number" then
            depth = str
            str = tokenize(str)
        else
            depth = 1
        end
        if str then
            local new_tokens = self()
            for tok in str:iter() do
                new_tokens = new_tokens:append(tok)
            end
            new_tokens.env = getenv(depth)
            return new_tokens
        end
        local stream = setmetatable({}, self)
        stream.values = {}
        stream.env = getenv(depth)
        return stream
    end,
    --- Index
    --- @param key any
    --- @return Token
    __index = function(self, key)
        --- @type any
        local value = rawget(self, key)
        return value
    end,
})

--- @class QuoteList
local QuoteList = setmetatable({
    __tostring = function(self)
        local str = "{"
        for i, stream in pairs(self) do
            if i > 1 then
              str = str .. ","
            end
            str = str .. " [[ "
            str = str .. tostring(stream)
            str = str .. " ]] "
        end
        return str
    end,
}, {
    __call = function(self)
        local list = setmetatable({}, self)
        return list
    end,
})
QuoteList.__index = QuoteList

--- Based on a given string, this function replaces occurences of the ${} pattern with the variables specified as the mappings
--- @param str string -- The format string
--- @return fun(mappings: {[string]: Quote}): string
function format(str)
    return function(mappings)
        function replace_placeholder(str)
            str = str:gsub("%$([%w_]+)", function(match)
                if mappings[match] then
                    return tostring(mappings[match])
                end
                return "$" .. match
            end)
            return str
        end
        str = replace_placeholder(str)
        return str
    end
end

--- Tokenizes a given string into a sequence of tokens (Quote)
--- @param code string
--- @return Quote
function tokenize(code)
    code = code:gsub("%-%-.*", "")
    local tokens = Quote()
    local i = 1
    while i <= #code do
        local char = code:sub(i, i)
        if char == "\\" then
            i = i + 1
        elseif char:match("%s") then
            i = i + 1
        elseif char:match("%d") then
            local num = ""
            local dot = false
            while char:match("[%d%.]") do
                if char == "." then
                    if dot then break end
                    dot = true
                end
                num = num .. char
                i = i + 1
                char = code:sub(i, i)
            end
            table.insert(tokens.values, Token(TokenType.Number, num))
        elseif char:match("\"") then
            local str = "\""
            i = i + 1
            char = code:sub(i, i)
            while not char:match("\"") and i <= #code do
                str = str .. char
                i = i + 1
                char = code:sub(i, i)
            end
            i = i + 1
            char = code:sub(i, i)
            table.insert(tokens.values, Token(TokenType.String, str .. "\""))
        elseif char:match("%[") and code:sub(i+1, i+1):match("%[") then
            local str = "[["
            i = i + 2
            char = code:sub(i, i)
            while not char:match("%]") do
                str = str .. char
                i = i + 1
                char = code:sub(i, i)
            end
            i = i + #code:sub(i+1):match("^\\*%]") + 2
            char = code:sub(i, i)
            table.insert(tokens.values, Token(TokenType.String, str .. "]]"))
        elseif char:match("[a-zA-Z_]") then
            local name = ""
            while char:match("[a-zA-Z_0-9]") do
                name = name .. char
                i = i + 1
                char = code:sub(i, i)
            end
            table.insert(tokens.values, Token(TokenType.Name, name))
        elseif char:match("[()]") then
            i = i + 1
            table.insert(tokens.values, Token(TokenType.Paren, char))
        elseif char:match("[%[%]]") then
            i = i + 1
            table.insert(tokens.values, Token(TokenType.Bracket, char))
        elseif char:match("[{}]") then
            i = i + 1
            table.insert(tokens.values, Token(TokenType.Brace, char))
        elseif char:match("[;,]") then
            i = i + 1
            table.insert(tokens.values, Token("delimiter", char))
        elseif char:match("[!]") then
            i = i + 1
            table.insert(tokens.values, Token("special", char))
        elseif char:match("[^%w%s()%[%]{}_,;\"!]") then
            local special = ""
            while char:match("[^%w%s()%[%]{}_,;\"!]") do
                i = i + 1
                special = special .. char
                char = code:sub(i, i)
            end
            table.insert(tokens.values, Token(TokenType.Special, special))
        end
    end
    return tokens
end

--- Evaluates the specified quote as a block
--- @param tokens Quote
--- @return any
function block(tokens)
    if type(tokens) == "string" then
        tokens = Quote(2, tokens)
    end
    local func, err = load(tostring(tokens), "chunk", "t", tokens.env)
    if not func then
        print("syntax error on the following quote:\n" .. tostring(tokens))
        error(err)
    end
    return func()
end

--- Evaluates the specified quote, returning its result
--- @param tokens Quote
--- @return any
function expr(tokens)
    if type(tokens) == "string" then
        tokens = Quote(2, tokens)
    end
    tokens = tokens:apply_macros(tokens.env)
    if #tokens == 1 and tokens[1].type == "name"
    and tokens[1].value ~= "true"
    and tokens[1].value ~= "false"
    and tokens[1].value ~= "nil" then
        return nil
    end
    local func, err = load("require(\"lib.core\") return " .. tostring(tokens), "chunk", "t", setmetatable(_G, { __index = tokens.env }))
    if not func then
        print("syntax error on the following quote:\n" .. tostring(tokens))
        error(err)
    end
    local ok, res = pcall(func)
    if not ok then
        return nil
    end
    return res
end

--- Evaluates the quote as a block
--- @return any
function Quote:block()
    return block(self)
end


--- Evaluates the quote, returning its result
--- @return any
function Quote:expr()
    local quote = self
    return expr(quote)
end

--- Returns an interator that gives back the index, and the current token of the quote
--- @return fun(): (number, Token) | nil
function Quote:enumerate()
    local index = 0
    local function iter()
        index = index + 1
        if self.values[index] then
            return index, self.values[index]
        end
    end
    return iter
end

--- Inserts a token at the specified index and returns the new quote
--- @param index number
--- @param value Token
--- @return Quote
function Quote:insert(index, value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local new_tokens = Quote:from(self)
    for i, tok in self:enumerate() do
        if i == index then
            new_tokens = new_tokens:append(value)
        end
        new_tokens = new_tokens:append(tok)
    end
    return new_tokens
end

--- Returns the index of the specified value inside the quote, returning nil if it fails
--- @param value Token | string
--- @return number | nil
function Quote:index_of(value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    for i, tok in self:enumerate() do
        if tok.type == value.type and tok.value == value.value then
            return i
        end
    end
end

--- Returns the amount of times a value is found inside the quotek
--- @param value Token | string
--- @return number
function Quote:count(value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local count = 0
    for tok in self do
        if tok.type == value.type and tok.value == value.value then
            count = count + 1
        end
    end
    return count
end

--- Reverses the quote and returns the reversed value
--- @return Quote
function Quote:reverse()
    local new_tokens = Quote:from(self)
    for i = #self, 1, -1 do
        new_tokens:append(self[i])
    end
    return new_tokens
end

--- Removes the value at the index specified and returns the removed value and the new quote
--- @param index number
--- @return Token, Quote
function Quote:remove(index)
    local new_tokens = Quote:from(self)
    local removed
    for i, tok in self:enumerate() do
        if i == index then
            removed = tok
        else
            new_tokens = new_tokens:append(tok)
        end
    end
    return removed, new_tokens
end

--- Returns true if the value is found inside the quote
--- @param token Token | string
--- @return boolean
function Quote:contains(token)
    if type(token) == "string" then
        token = Quote(token)[1]
    end
    for tok in self:iter() do
        if tok.type == token.type and tok.value == token.value then
            return true
        end
    end
    return false
end

--- Appends a value to the end of the quote and returns the new quote
--- @param value Token | string
--- @return Quote
function Quote:append(value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local new_tokens = Quote:from(self)
    for tok in self:iter() do
        table.insert(new_tokens.values, tok)
    end
    table.insert(new_tokens.values, value)
    return new_tokens
end

--- Prepends a value to the start of the quote and returns the new quote
--- @param value Token | string
--- @return Quote
function Quote:prepend(value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local new_tokens = Quote:from(self)
    table.insert(new_tokens.values, value)
    for tok in self:iter() do
        table.insert(new_tokens.values, tok)
    end
    return new_tokens
end

--- Pops the first value of the quote and returns it alongside the quote
--- @return Token, Quote
function Quote:pop()
    local new_tokens = Quote:from(self)
    for i = 2, #self do
        new_tokens = new_tokens:append(self[i])
    end
    --- @type Token
    local first = self[1]
    return first, new_tokens
end

--- Returns the value of the first token of the quote
--- @return string
function Quote:peek_value()
    return self[1].value
end

--- Extends the quote with the other quote, appending the other at the end of the quote
--- @param other Quote
--- @return Quote
function Quote:extend(other)
    if type(other) == "string" then
        other = Quote(other)
    end
    local new_tokens = Quote:from(self)
    for tok in self:iter() do
        new_tokens = new_tokens:append(tok)
    end
    for tok in other:iter() do
        new_tokens = new_tokens:append(tok)
    end
    return new_tokens
end

--- Returns the subslice of the quote starting from min and ending on max
--- @param min number
--- @param max number
--- @return Quote
function Quote:slice(min, max)
    if not max then
        max = #self
    end
    if max < 0 then
        max = #self + max + 1
    end
    local new_tokens = Quote:from(self)
    for i = min, max do
        new_tokens = new_tokens:append(self[i])
    end
    return new_tokens
end

--- Pops the first token of the quote and asserts that it is equal to the provided value
--- @param value string
--- @return Token, Quote
function Quote:expect(value)
    local popped, tokens = self:pop()
    if popped.value == value then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

--- Consumes the first token of the quote and asserts that it is equal to the provided value, and only returns the tokens
--- @param value string
--- @return Quote
function Quote:consume(value)
    local popped, tokens = self:pop()
    if popped.value == value then
        return tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

--- Pops the last token of the quote and asserts that it is equal to the provided value
--- @param value string
--- @return Token, Quote
function Quote:expect_last(value)
    local popped, tokens = self:remove(#self)
    if popped.value == value then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

--- Pops the first token of the quote and asserts that its type matches at least one of the provided types
--- @vararg string
--- @return Token, Quote
function Quote:expect_type(...)
    local popped, tokens = self:pop()
    popped:assert_is(...)
    return popped, tokens
end

function Quote:expect_name()
    return self:expect_type("name")
end

function Quote:expect_number()
    return self:expect_type("number")
end

function Quote:expect_paren()
    return self:expect_type("paren")
end

function Quote:expect_bracket()
    return self:expect_type("bracket")
end

function Quote:expect_brace()
    return self:expect_type("brace")
end

function Quote:expect_special()
    return self:expect_type("special")
end

function Quote:expect_delimiter()
    return self:expect_type("delimiter")
end

function Quote:expect_string()
    return self:expect_type("string")
end

function Quote:expect_last_type(type)
    local popped, tokens = self:remove(#self)
    if popped.type == type then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", type, popped))
end

function Quote:split(separator, deep)
    deep = deep or false
    if type(separator) == "string" then
        separator = Quote(separator)[1]
    end
    local results = QuoteList()
    local new_tokens = Quote:from(self)
    local i = 1
    while i <= #self do
        local paren = self:slice(i):balanced("(", ")")
        local bracket = self:slice(i):balanced("[", "]")
        local brace = self:slice(i):balanced("{", "}")
        if paren and not deep
        and separator.value ~= "(" and separator.value ~= ")" then
            i = i + #paren
            new_tokens = new_tokens:extend(paren)
        elseif bracket and not deep
        and separator.value ~= "[" and separator.value ~= "]" then
            i = i + #bracket
            new_tokens = new_tokens:extend(bracket)
        elseif brace and not deep
        and separator.value ~= "{" and separator.value ~= "}" then
            i = i + #brace
            new_tokens = new_tokens:extend(brace)
        else
            ::run::
            local tok = self[i]
            if tok.value == separator.value then
                table.insert(results, new_tokens)
                new_tokens = Quote:from(self)
                i = i + 1
                tok = self[i]
                goto continue
            end
            new_tokens = new_tokens:append(tok)
            i = i + 1
        end
        ::continue::
    end
    table.insert(results, new_tokens)
    return results
end

function Quote:args()
    return self:split(","):unpack()
end

function Quote:str()
    local str = tostring(self)
    str = str:gsub("\\", "\\\\")
    str = str:gsub("\"", "\\\"")
    return str
end

function Quote:repr()
    return tostring(self)
end

function Quote:balanced(start, finish)
    if type(start) == "string" then
        start = Quote(start)[1]
    end
    if type(finish) == "string" then
        finish = Quote(finish)[1]
    end
    if #self == 0 then
        return nil, self
    end
    if self[1].value ~= start.value then
        return nil, self
    end
    local counter = 0
    local i = 1
    local new_tokens = Quote:from(self)
    while i <= #self do
        local tok = self[i]
        if tok.value == start.value then
            counter = counter + 1
        end
        if tok.value == finish.value then
            counter = counter - 1
            if start.value == finish.value then
                counter = counter - 2
            end
        end
        if counter <= 0 then
            new_tokens = new_tokens:append(tok)
            break
        end
        new_tokens = new_tokens:append(tok)
        i = i + 1
    end
    return new_tokens, self:slice(i)
end

function Quote:replace(old, new)
    if type(old) == "string" then
        old = Quote(old)[1]
    end
    if type(new) == "string" then
        new = Quote(new)[1]
    end
    local new_tokens = Quote:from(self)
    for tok in self:iter() do
        if tok.value == old.value then
            new_tokens = new_tokens:append(new)
        else
            new_tokens = new_tokens:append(tok)
        end
    end
    return new_tokens
end

function Quote:splitjoin(separator, joiner)
    return self:split(separator):join(joiner)
end

function Quote:map(fn)
    local new = Quote()
    for token in self:iter() do
        local result = fn(token)
        if result.type and result.value then
            new = new:append(result)
        else
            new = new:extend(result)
        end
    end
    return new
end

function Quote:foreach(fn)
    for token in self:iter() do
        fn(token)
    end
end

function Quote:pairs(fn)
    for i, token in self:enumerate() do
        fn(i, token)
    end
end

function Quote:take_until(separator)
    if type(separator) == "string" then
        separator = Quote(separator)[1]
    end
    local split = self:split(separator)
    local first = split[1]
    table.remove(split, 1)
    return first, split:join(separator)
end

function Quote:rep(num)
    local quote_list = QuoteList()
    for i = 1, num do
        table.insert(quote_list, self)
    end
    return quote_list:join("")
end

function Quote:tolist()
    local quote_list = QuoteList()
    for token in self:iter() do
        quote_list = quote_list:append(Quote(token))
    end
    return quote_list
end

function QuoteList:join(separator)
    if type(separator) == "string" or separator.type then
        separator = Quote(separator)
    end
    local new_tokens = Quote()
    for i, stream in pairs(self) do
        if i > 1 then
            new_tokens = new_tokens:extend(separator)
        end
        new_tokens = new_tokens:extend(stream)
    end
    return new_tokens
end

function QuoteList:map(fn)
    local quote_list = QuoteList()
    for i, quote in pairs(self) do
        table.insert(quote_list, fn(quote))
    end
    return quote_list
end

function QuoteList:foreach(fn)
    for i, quote in pairs(self) do
        fn(quote)
    end
end

function QuoteList:filter(fn)
    if not fn then
        fn = function(quote)
            return #quote > 0
        end
    end
    local quote_list = QuoteList()
    for i, quote in pairs(self) do
        if fn(quote) then
            table.insert(quote_list, quote)
        end
    end
    return quote_list
end

function QuoteList:slice(min, max)
    if not max then
        max = #self
    end
    if max < 0 then
        max = #self + max + 1
    end
    local quote_list = QuoteList()
    for i = min, max do
        table.insert(quote_list, self[i])
    end
    return quote_list
end

function QuoteList:append(quote)
    if type(quote) == "string" then
        quote = Quote(quote)
    end
    local new = QuoteList()
    for i, v in pairs(self) do
        table.insert(new, v)
    end
    table.insert(new, quote)
    return new
end

function QuoteList:contains(quote)
    if type(quote) == "string" then
        quote = Quote(quote)
    end
    for i, v in pairs(self) do
        if tostring(v) == tostring(quote) then
            return true
        end
    end
    return false
end

function QuoteList:unpack()
    return table.unpack(self)
end

function QuoteList:reverse()
    local new = QuoteList()
    for i = #self, 1, -1 do
        table.insert(new, self[i])
    end
    return new
end

function Macro(impl)
    return setmetatable({
        expr = function(self, str)
            local quote = Quote(2, str)
            return expr(self(quote))
        end,
        block = function(self, str)
            local quote = Quote(2, str)
            return block(self(quote))
        end,
    }, {
        __macro = true,
        __call = function(_, str)
            local tokens = str
            local env = getenv(1)
            if type(str) == "string" then
                tokens = Quote(str)
                tokens.env = env
            end
            local result = Quote(impl(tokens))
            result.env = tokens.env
            return result
        end,
    })
end

function Quote:apply_macros(env)
    local calls = {}
    for i, tok in self:enumerate() do
        if tok.type == "name" then
            if self[i+1] and self[i+1].value == "!" then
                local args = self:slice(i+2):balanced("(", ")")
                    or self:slice(i+2):balanced("[", "]")
                    or self:slice(i+2):balanced("{", "}")
                if args then
                    table.insert(calls, {tok, args:slice(2, -2), i})
                elseif self[i+2] and self[i+2]:is_string() then
                    table.insert(calls, {
                        tok, Quote(self[i+2]), i
                    })
                    i = i + 3
                    goto continue
                else
                    table.insert(calls, {tok, Quote(), i})
                end
            end
        end
        ::continue::
    end
    local replaced = {}
    for _, call in pairs(calls) do
        local name, args, i = table.unpack(call)
        if env[name.value] then
            if type(env[name.value]) == "function" then
                args.env = env
                local quote, mappings = env[name.value](args)
                local value = Quote(format(quote)(mappings))
                value.env = env
                value = value:apply_macros(env)
                if #value ~= 1 or value[1].value ~= "nil" then
                    table.insert(replaced, {
                        value,
                        i,
                    })
                end
            else
                local value = env[name.value]
                value = value:apply_macros(env)
                table.insert(replaced, {
                    value,
                    i,
                })
            end
        end
    end
    local new_quote = Quote()
    local i = 1
    while i <= #self do
        for _, rep in pairs(replaced) do
            local value, j = table.unpack(rep)
            if i == j then
                i = i + 2
                local args = self:slice(i):balanced("(", ")")
                    or self:slice(i):balanced("[", "]")
                    or self:slice(i):balanced("{", "}")
                if not args then
                    if self[i] and self[i]:is_string() then
                        new_quote = new_quote:append(value)
                        goto continue
                    end
                    i = i - 1
                    new_quote = new_quote:extend(value)
                    goto continue
                end
                i = i + #args - 1
                new_quote = new_quote:extend(value)
                goto continue
            end
        end
        new_quote = new_quote:append(self[i])
        ::continue::
        i = i + 1
    end
    return new_quote
end

function Quote:write(path, env)
    self = self:apply_macros(env)
    local file = io.open(path, "w+")
    if file then
        file:write("\nrequire \"quoted_lib\"\n\n" .. tostring(self))
    end
    assert(file)
    file:close()
    local handle = io.popen("stylua --version")
    if handle then        
        local result = handle:read("*a")
        handle:close()
        if  result and result ~= "" then
            os.execute("stylua " .. path)
        end
    end
end

local function get_path(depth)
  if not path then
    path = debug.getinfo(depth + 3).source:sub(2)
    path = path:gsub("%.lua", "")
    path = path .. ".out.lua"
  end
  return path
end

function generate(path, depth)
    depth = depth or 0
    return function(quote)
        local env = getenv(depth + 1)
        path = get_path(depth)
        quote = Quote(quote)
        quote:write(path, env)
    end
end

function run(mode, depth, original)
    depth = depth or 0
    return function(quote)
        original = quote
        quote = Quote(quote)
        local env = getenv(depth + 1)
        quote = quote:apply_macros(env)
        if mode == "debug" or mode == "test" then
            local file = io.open("temp", "w+")
            assert(file)
            file:write(tostring(quote))
            file:close()
            os.execute("stylua temp")
            local file = io.open("temp", "r+")
            assert(file)
            local formatted = file:read("*all")
            file:close()
            os.remove("temp")
            if mode == "debug" then
                return print(formatted)
            elseif mode == "test" then
                return formatted
            end
        end
        local func, err = load("require(\"quoted_lib\")" .. tostring(quote), "chunk", "t", original_G)
        if not err and func then
            return func()
        end
        error(err, 2)
    end
end

function execute(path)
    return function(quote)
        path = get_path(0)
        generate(path, 1)(quote)
        os.execute("lua54 " .. path)
    end
end

todo = Quote [=[
    error("TODO!")
]=]

function f(quote)
    local original = quote
    quote = quote:append(")")
    quote = quote:prepend("("):prepend("repr")
    local vars = QuoteList()
    if type(expr(original)) ~= "string" then
        return [[$quote]], {quote = quote}
    end
    local str = expr(quote)
    for match in str:gmatch("(\\*){") do
        if #match % 2 == 0 then
            local raw = Quote(str)
            raw:pairs(function(index, _)
                local brace = raw:slice(index):balanced("{", "}")
                if brace then
                    vars = vars:append(brace:slice(2, -2))
                end
            end)
            str = str:gsub(match .. "%b{}", match .. "%%s")
        else
            str = str:gsub(match .. "{", match:sub(2) .. "{")
            str = str:gsub(match .. "}", match:sub(2) .. "}")
        end
    end
    vars = vars:map(function(var)
        return var:prepend(",")
    end):join("")
    return [[
        string.format("$str" $vars)
    ]], {
        str = str,
        vars = vars,
    }
end

function println(quote)
    return [[
        print(f!($quote))
    ]], { quote = quote }
end

function fn(quote)
    _, quote = quote:expect("(")
    local params, quote = quote:take_until(")")
    _, quote = quote:expect("=>")
    if quote[1]:is("do") then
        _, quote = quote:expect("do")
        _, quote = quote:expect_last("end")
        return [=[
            table.remove{function($params)
                $quote
            end}
        ]=], {
            params = params,
            quote = quote,
        }
    end
    return [=[
        table.remove{function($params)
            return $quote
        end}
    ]=], {
        params = params,
        quote = quote,
    }
end

function breakif(quote)
    return Quote [=[
        if $quote then
            break
        end
    ]=]
end

function r(quote)
    local var, quote = quote:expect_name()
    local op, quote = quote:expect_special()
    op = Quote(op.value:sub(1, -2))[1]
    return Quote [=[
        table.remove({function()
            $var = $var $op $quote
            return $var
        end})()
    ]=]
end

function set(quote)
    local var, func = quote:take_until(":=")
    return Quote [=[
        $var = $func($var)
    ]=]
end

function concat(quote)
    local args = quote:split("..")
    local str = ""
    args:foreach(function(arg)
        arg = expr(arg)
        str = str .. tostring(arg)
    end)
    return [=["$str"]=], {str = str}
end

function trim(quote)
    str = expr(quote)
    return [=[
        (($quote):gsub("^%s*(.-)%s*$", "%1"))
    ]=], {quote = quote}
end

function read(quote)
    local scope = ""
    if quote:peek_value() == "local" then
        _, quote = quote:pop()
        scope = "local"
    end
    local var, quote = quote:expect_name()
    quote = quote:consume("<=")
    local path, quote = quote:expect_string()
    return [=[
        $scope $var = (function()
            local file = io.open($path, "r")
            if not file then return nil end
            local content = file:read("*all")
            file:close()
            return content
        end)()
    ]=], {
        scope = scope,
        var = var,
        path = path,
    }
end

function enum(quote)
    local fields = quote:split(",")
    fields = fields:filter()
    local iota = 0
    fields = fields:map(function(field)
        iota = iota + 1
        local str = tostring(iota)
        return field:extend("=" .. str)
    end):join(",")
    return [=[
        { $fields }
    ]=], { fields = fields }
end

function assert_eq(quote)
    local a, b = quote:args()
    a, b = expr(a), expr(b)
    assert(a == b)
    return [=[ ]=]
end