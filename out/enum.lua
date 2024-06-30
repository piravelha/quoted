local Fruit = setmetatable({ Apple = 1, Banana = 2, Grape = 3, Orange = 4 }, {
	__tostring = function(_)
		return "Fruit"
	end,
})
print(Fruit.Orange)
