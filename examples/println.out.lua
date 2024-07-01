require([[quoted_lib]])
local y = 20
local add = function(x, y)
	return x + y
end
local z = add(10, y)
table.remove({
	function()
		z = z + 5
		return z
	end,
})()
z = z * z
z = print(string.format("Result: %s", z))
