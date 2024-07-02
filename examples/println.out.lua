require("lib.core")

local main = table.remove({
	function(arg)
		print(string.format("Arg is %s", arg))
		return "Done!"
	end,
})
print(repr(main(5)))
