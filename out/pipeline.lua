local double = function(__)
	return __ * 2
end
local square = function(__)
	return __ * __
end
local negate = function(__)
	return -__
end
local process = function(a)
	return negate(square(double(a)))
end
print(process(3))
