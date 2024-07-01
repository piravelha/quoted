function replace_placeholder(str, k, v)
    -- Escape magic characters in k
    local escaped_k = k:gsub("%%", "%%%%")
      :gsub("%(", "%%(")
      :gsub("%)", "%%)")
      :gsub("%.", "%%.")
      :gsub("%+", "%%+")
      :gsub("%-", "%%-")
      :gsub("%*", "%%*")
      :gsub("%?", "%%?")
      :gsub("%[", "%%[")
      :gsub("%]", "%%]")
      :gsub("%^", "%%^")
      :gsub("%$", "%%$")
  
    -- Replace ${k} with v
    local pattern = "%${" .. escaped_k .. "}"
    local escaped_v = v:gsub("%%", "%%%%")
    return str:gsub(pattern, escaped_v)
  end
  
  -- Example usage:
  local template = "Hello, ${name}! Welcome to ${place}."
  local k = "name"
  local v = "${name} is cool"
  local result = replace_placeholder(
    template, k, v)
result = replace_placeholder(result, "place", "test")
  print(result)
  -- Output: Hello, Alice! Welcome to ${place}.
  