local mt = {
  __gc = function()
    print("Object destroyed")
  end,
}

local obj = setmetatable({}, mt)
print(obj)
