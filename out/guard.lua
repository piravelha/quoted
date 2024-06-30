local safe_div = function(a, b)
	if not (b ~= 0) then
		error("failure to satisfy guard 'b ~= 0'", 2)
	end
	return a / b
end
print(safe_div(4, 2))
print(safe_div(3, 2))
