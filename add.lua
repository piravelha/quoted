require("quoted")

ADD = Macro(function(tokens)
  local nums = tokens:split[[ , ]]
  return nums:join[[ + ]]
end)

local quote = ADD[[1, 2, 3]]
print(quote)
--> 1 + 2 + 3
print(expr(quote))
--> 6

