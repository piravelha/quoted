local person = {
	name = "Ian",
	age = 15,
	birthday = function(self)
		self.age = self.age + 1
	end,
}
print(person.age)
person.birthday(person)
print(person.age)
