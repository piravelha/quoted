Person = function(params)
	return { name = params[1], age = params[2] }
end
local person = Person({ "Ian", 15 })
print(person.name)
print(person.age)
