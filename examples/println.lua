require [[quoted]]

local function square(quote)
  return Quote([[
    (%s) * (%s)
  ]], quote, quote)
end

local function set(quote)
  print(quote)
  local var, func = quote:take_until(":=")
  return Quote([[
    %s = %s(%s)
  ]], var, func, var)
end

local x = Quote [=[ 10 ]=]

execute() [=[

local y = 20
local add = fn!{(x, y) => x + y}
local z = add(x!, y)
r!(z += 5)
set!(z := square!)
z = square!(z!("Result: {z}")

]=]

