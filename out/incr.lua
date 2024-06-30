local x = 5;
(function()
	local result = x
	x = x + 1
	return result
end)()
print(string.format("Result: %s", x));
(function()
	local result = x
	x = x + 1
	return result
end)()
print(string.format("Result: %s", x))
