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

function Token:map(fn)
    local value = ""
    for i = 1, #self.value do
        local char = self.value:sub(i, i)
        value = value .. fn(char)
    end
    return Token(self.type, value)
end

function Token:flatmap(fn)
    local quote = Quote()
    for i = 1, #self.value do
        local char = self.value:sub(i, i)
        quote = quote:extend(Quote(fn(char)))
    end
    return quote
end

function Token:is(value)
    return self.value == value
end

function Token:is_name()
    return self.type == "name"
end

function Token:is_number()
    return self.type == "number"
end

function Token:is_string()
    return self.type == "string"
end

function Token:is_special()
    return self.type == "special"
end

function Token:is_paren()
    return self.type == "paren"
end

function Token:is_bracket()
    return self.type == "bracket"
end

function Token:is_brace()
    return self.type == "brace"
end

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
    return setmetatable(__G, { __index = env })
end



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
    __call = function(self, str, ...)
        local depth
        if type(str) ~= "nil" then
            str = tostring(str)
        end
        if str and type(str) == "string" then
            if #({...}) > 0 then
                str = tokenize(string.format(str, ...))
            else
                str = tokenize(str)
            end
            depth = 1
        elseif type(str) == "number" then
            depth = str
            str = ({...})[1]
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
})

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
        elseif char:match("[^%w%s()%[%]{}_,;\"]") then
            local special = ""
            while char:match("[^%w%s()%[%]{}_,;\"]") do
                i = i + 1
                special = special .. char
                char = code:sub(i, i)
            end
            table.insert(tokens.values, Token(TokenType.Special, special))
        end
    end
    return tokens
end

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

function expr(tokens)
    if type(tokens) == "string" then
        tokens = Quote(2, tokens)
    end
    if #tokens == 1 and tokens[1].type == "name"
    and tokens[1].value ~= "true"
    and tokens[1].value ~= "false"
    and tokens[1].value ~= "nil" then
        error("Attempting to evaluate not compile-time known value: '" .. tokens[1].value .. "'")
    end
    local func, err = load("return " .. tostring(tokens), "chunk", "t", tokens.env)
    if not func then
        print("syntax error on the following quote:\n" .. tostring(tokens))
        error(err)
    end
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
    for tok in self:iter() do
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
    for tok in self:iter() do
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

function Quote:extend(other, ...)
    if type(other) == "string" then
        other = Quote(string.format(other, ...))
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
        return tokens, popped
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

function Quote:expect_last(value)
    local popped, tokens = self:remove(#self)
    if popped.value == value then
        return tokens, popped
    end
    error(string.format("Expected '%s', got '%s'", value, popped))
end

function Quote:expect_type(...)
    local popped, tokens = self:pop()
    popped:assert_is(...)
    return popped, tokens
end

function Quote:expect_name(type)
    return self:expect_type("name")
end

function Quote:expect_number(type)
    return self:expect_type("number")
end

function Quote:expect_paren(type)
    return self:expect_type("paren")
end

function Quote:expect_bracket(type)
    return self:expect_type("bracket")
end

function Quote:expect_brace(type)
    return self:expect_type("brace")
end

function Quote:expect_special(type)
    return self:expect_type("special")
end

function Quote:expect_delimiter(type)
    return self:expect_type("delimiter")
end

function Quote:expect_string(type)
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
        return
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
        separator = Quote("%s", separator)
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
                local value = Macro(env[name.value])(args)
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
        file:write("require [[quoted_lib]]\n" .. tostring(self))
    end
    file:close()
    local handle = io.popen("stylua --version")
    local result = handle:read("*a")
    handle:close()
    if result and result ~= "" then
        os.execute("stylua " .. path)
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
            file:write(tostring(quote))
            file:close()
            os.execute("stylua temp")
            local file = io.open("temp", "r+")
            local formatted = file:read("*all")
            file:close()
            os.remove("temp")
            if mode == "debug" then
                return print(formatted)
            elseif mode == "test" then
                return formatted
            end
        end
        local func, err = load(tostring(quote), "chunk", "t", original_G)
        if not err then
            return func()
        end
        error(err, 2)
    end
end

function execute(path)
    return function(quote)
        path = get_path(0)
        generate(path, 1)(quote)
        os.execute("lua5.3 " .. path)
    end
end

todo = Quote [=[
  error("TODO!")
]=]

function f(quote)
    assert(#quote == 1, "f!() macro only supports a single string token")
    local vars = QuoteList()
    local str = quote[1].value
    for match in str:gmatch("(\\*){") do
        if #match % 2 == 0 then
            local raw = Quote(str:sub(2, -2))
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
    end)
    return [[
        string.format(%s %s)
    ]], str, vars:join("")
end

function println(quote)
    return [[
        print(f!(%s))
    ]], quote
end

function fn(quote)
    quote = quote << "("
    local params, quote = quote:take_until(")")
    quote = quote << "=>"
    if quote[1]:is("do") then
        quote = quote << "do" >> "end"
        return Quote([[
            table.remove({function(%s)
                %s
            end})
        ]], params, quote)
    end
    return Quote([[
        (function(%s)
            return %s
        end)
    ]], params, quote)
end

function breakif(quote)
    return Quote([[
        if %s then
            break
        end
    ]], quote)
end

function r(quote)
    local var, quote = quote:expect_name()
    local op, quote = quote:expect_special()
    op = Quote(op.value:sub(1, -2))[1]
    return Quote([[
        table.remove({function()
            %s = %s %s %s
            return %s
        end})()
    ]], var, var, op, quote, var)
end


