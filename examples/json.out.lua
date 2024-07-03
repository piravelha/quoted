require("lib.core")

local info = {
    ["name"] = "Ian",
    ["age"] = 15,
    ["programming"] = true
}
print(string.format("Name: %s", repr(info.name)))
print(string.format("Age: %s", repr(info.age)))
print(string.format("Programming: %s", repr(info.programming)))
