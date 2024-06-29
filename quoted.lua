
TokenType = {
    Name = "name",
    Number = "number",
    String = "string",
    Paren = "paren",
    Bracket = "bracket",
    Brace = "brace",
    Special = "special",
}

Token = setmetatable({
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
    __index = function(self, key)
        if type(key) == "number" then
            return rawget(self, "values")[key]
        end
        if key == "_" or key == "expr" then
            return expr(self)
        end
        if key == "block" then
            return block(self)
        end
        if rawget(self, key) ~= nil then
            return rawget(self, key)
        end
        return rawget(Quote, key)
    end,
    __len = function(self)
        return #self.values
    end,
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
    __call = function(self, str, depth)
        depth = depth or 1
        if str and type(str) == "string" then
            str = tokenize(str)
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
})

QuoteList = setmetatable({
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

function tokenize(code, file)
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
            while not char:match("\"") do
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
            while not char:match("%]") or not code:sub(i+1):match("^\\*%]") do
                if char == "\\" then
                    i = i + 1
                    char = code:sub(i, i)
                else
                    str = str .. char
                    i = i + 1
                    char = code:sub(i, i)
                end
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
        elseif char:match("[^%w%s()%[%]{}]") then
            local special = ""
            while char:match("[^%w%s()%[%]{}]") do
                i = i + 1
                special = special .. char
                char = code:sub(i, i)
            end
            table.insert(tokens.values, Token(TokenType.Special, special))
        end
    end
    return tokens
end

function getenv(depth)
    local env = {}
    for i = 1, debug.getinfo(1, "l").currentline do
        local name, value = debug.getlocal(depth + 2, i)
        if not name then
            break
        end
        env[name] = value
    end
    for k, v in pairs(_G) do
        env[k] = v
    end
    return env
end

function block(tokens)
    if type(tokens) == "string" then
        tokens = Quote(tokens, 2)
    end
    local func = load(tostring(tokens), "chunk", "t", getenv(1))
    return func()
end

function expr(tokens)
    if type(tokens) == "string" then
        tokens = Quote(tokens, 2)
    end
    local func = load("return " .. tostring(tokens), "chunk", "t", tokens.env)
    return func()
end

function Quote:block()
    return block(self)
end

function Quote:expr()
    local quote = self
    return expr(quote)
end

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

function Quote:insert(index, value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local new_tokens = Quote:from(self)
    for i, tok in self:enumerate() do
        if i == index then
            new_tokens:append(value)
        end
        new_tokens:append(tok)
    end
    return new_tokens
end

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

function Quote:reverse()
    local new_tokens = Quote:from(self)
    for i = #self, 1, -1 do
        new_tokens:append(self[i])
    end
    return new_tokens
end

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

function Quote:contains(token)
    if type(token) == "string" then
        token = Quote(token)[1]
    end
    for tok in self do
        if tok.type == token.type and tok.value == token.value then
            return true
        end
    end
    return false
end

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

function Quote:prepend(value)
    if type(value) == "string" then
        value = Quote(value)[1]
    end
    local new_tokens = Quote:from(self)
    table.insert(new_tokens.values, value)
    for tok in self do
        table.insert(new_tokens.values, tok)
    end
    return new_tokens
end

function Quote:pop()
    local new_tokens = Quote:from(self)
    for i = 2, #self do
        new_tokens = new_tokens:append(self[i])
    end
    return self[1], new_tokens
end

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

function Quote:expect(value)
    local popped, tokens = self:pop()
    if popped.value == value then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

function Quote:expect_last(value)
    local popped, tokens = self:remove(#self)
    if popped.value == value then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

function Quote:expect_type(type)
    local popped, tokens = self:pop()
    if popped.type == type then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", type, popped))
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
        if paren and not deep then
            i = i + #paren
            new_tokens = new_tokens:extend(paren)
        elseif bracket and not deep then
            i = i + #bracket
            new_tokens = new_tokens:extend(bracket)
        elseif brace and not deep then
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

function Quote:balanced(start, finish)
    if type(start) == "string" then
        start = Quote(start)[1]
    end
    if type(finish) == "string" then
        finish = Quote(finish)[1]
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
    for tok in self do
        if tok.value == old.value then
            new_tokens = new_tokens:append(new)
        else
            new_tokens = new_tokens:append(tok)
        end
    end
    return new_tokens
end

function Quote:segmentize(separator, joiner)
    return self:split(separator):join(joiner)
end

function Quote:take_until(separator)
    local split = self:split(separator)
    local first = split[1]
    table.remove(split, 1)
    return first, split:join(separator)
end

function QuoteList:join(separator)
    if type(separator) == "string" then
        separator = Quote(separator)
    end
    local new_tokens = Quote:from(self)
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

function Macro(impl)
    return setmetatable({
        expr = function(self, str)
            local quote = Quote(str, 2)
            return expr(self(quote))
        end,
        block = function(self, str)
            local quote = Quote(str, 2)
            return block(self(quote))
        end,
    }, {
        __call = function(_, str)
            local tokens = str
            if type(str) == "string" then
                tokens = Quote(str, 2)
            end
            local results = {impl(tokens)}
            results[1] = tostring(results[1])
            local result = string.format(table.unpack(results))
            if type(result) == "string" then
                result = Quote(result, 2)
                result.env = tokens.env
            end
            return result
        end,
    })
end
