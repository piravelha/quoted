
TokenType = {
    Name = "name",
    Number = "number",
    String = "string",
    Paren = "paren",
    Bracket = "bracket",
    Brace = "brace",
    Special = "special",
    Splice = "splice",
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

TokenStream = setmetatable({
    __tostring = function(self)
        local str = ""
        for i, tok in pairs(self) do
            if i > 1 then
                str = str .. " "
            end
            str = str .. tostring(tok)
        end
        return str
    end,
}, {
    __call = function(self, str)
        if str then
            local stream = tokenize(str)
            local new_tokens = self()
            local env = getenv(2)
            for i, tok in pairs(stream) do
                if tok.type == TokenType.Splice then
                    local value = tostring(env[tok.value:sub(2)])
                    new_tokens = new_tokens:extend(tokenize(value))
                else
                    new_tokens = new_tokens:append(tok)
                end
            end
            return new_tokens
        end
        local stream = setmetatable({}, self)
        return stream
    end,
})
TokenStream.__index = TokenStream

function tokenize(code, file)
    local tokens = TokenStream()
    local i = 1
    while i <= #code do
        local char = code:sub(i, i)
        if char:match("%s") then
            i = i + 1
        elseif char:match("%d") then
            local num = ""
            while char:match("%d") do
                num = num .. char
                i = i + 1
                char = code:sub(i, i)
            end
            table.insert(tokens, Token(TokenType.Number, num))
        elseif char:match("\"") then
            local str = ""
            i = i + 1
            char = code:sub(i, i)
            while not char:match("\"") do
                str = str .. char
                i = i + 1
                char = code:sub(i, i)
            end
            i = i + 1
            char = code:sub(i, i)
            table.insert(tokens, Token(TokenType.String, str))
        elseif char:match("[a-zA-Z_]") then
            local name = ""
            while char:match("[a-zA-Z_0-9]") do
                name = name .. char
                i = i + 1
                char = code:sub(i, i)
            end
            table.insert(tokens, Token(TokenType.Name, name))
        elseif char:match("[$]") then
            local splice = "$"
            i = i + 1
            char = code:sub(i, i)
            while char:match("[a-zA-Z_0-9]") do
                splice = splice .. char
                i = i + 1
                char = code:sub(i, i)
            end
            table.insert(tokens, Token(TokenType.Splice, splice))
        elseif char:match("[()]") then
            i = i + 1
            table.insert(tokens, Token(TokenType.Paren, char))
        elseif char:match("[%[%]]") then
            i = i + 1
            table.insert(tokens, Token(TokenType.Bracket, char))
        elseif char:match("[{}]") then
            i = i + 1
            table.insert(tokens, Token(TokenType.Brace, char))
        elseif char:match("[^%w%s()%[%]{}$]") then
            local special = ""
            while char:match("[^%w%s()%[%]{}$]") do
                i = i + 1
                special = special .. char
                char = code:sub(i, i)
            end
            table.insert(tokens, Token(TokenType.Special, special))
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
    local func = load(tostring(tokens), "chunk", "t", getenv(1))
    return func()
end

function expr(tokens)
    local func = load("return " .. tostring(tokens), "chunk", "t", getenv(1))
    return func()
end

function TokenStream:append(value)
    if type(value) == "string" then
        value = TokenStream(value)[1]
    end
    local new_tokens = TokenStream()
    for i, tok in pairs(self) do
        table.insert(new_tokens, tok)
    end
    table.insert(new_tokens, value)
    return new_tokens
end

function TokenStream:prepend(value)
    if type(value) == "string" then
        value = TokenStream(value)[1]
    end
    local new_tokens = TokenStream()
    table.insert(new_tokens, value)
    for i, tok in pairs(self) do
        table.insert(new_tokens, tok)
    end
    return new_tokens
end

function TokenStream:pop()
    local new_tokens = TokenStream()
    for i = 2, #self do
        new_tokens = new_tokens:append(self[i])
    end
    return self[1], new_tokens
end

function TokenStream:extend(other)
    if type(other) == "string" then
        other = TokenStream(other)
    end
    local new_tokens = TokenStream()
    for i, tok in pairs(self) do
        new_tokens = new_tokens:append(tok)
    end
    for i, tok in pairs(other) do
        new_tokens = new_tokens:append(tok)
    end
    return new_tokens
end

function TokenStream:slice(min, max)
    if not max then
        max = #self
    end
    if max < 0 then
        max = #self + max + 1
    end
    local new_tokens = TokenStream()
    for i = min, max do
        new_tokens = new_tokens:append(self[i])
    end
    return new_tokens
end

function TokenStream:expect(value)
    local popped, tokens = self:pop()
    if popped.value == value then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

function TokenStream:expect_type(type)
    local popped, tokens = self:pop()
    if popped.type == type then
        return popped, tokens
    end
    error(string.format("Expected '%s', got '%s'", type, popped))
end

function Macro(impl)
    return function(str)
        local tokens = TokenStream(str)
        local result = string.format(impl(tokens))
        return TokenStream(result)
    end
end

local ADD = Macro(function(tokens)
    local first, tokens = tokens:expect_type(TokenType.Number)
    local _, tokens = tokens:expect(",")
    local second, tokens = tokens:expect_type(TokenType.Number)
    return "%s + %s", first, second
end)

local x = 1
local tokens = ADD[[$x, 2]]
print(expr(tokens))
