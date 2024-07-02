# Token

Tokens are the building blocks of quoted, quotes are made out of a sequence of tokens, and each token is just an object with a type, and a value.

- `Token.value`: the (string) value of the token.
- `Token.type`: type of the token, the types are listed below:

---

- `Token.name`: alias for the string `"name"`.
- `Token.number`: alias for the string `"number"`.
- `Token.string`: alias for the string `"string"`.
- `Token.paren`: alias for the string `"paren"`.
- `Token.bracket`: alias for the string `"bracket"`.
- `Token.brace`: alias for the string `"brace"`.
- `Token.special`: alias for the string `"special"`.
- `Token.delimiter`: alias for the string `"delimiter"`.

---

- `Token:map(fn)`: maps each character of the token's value with a transformation function.
- `Token:flatmap(fn)`: flatmaps each character of the token's value with a transformation function that must return itself another token, and then concatenates all the output tokens into a quote.
- `Token:is(value)`: checks if the value of the token matches the value.
- `Token:is_name()`: checks if the token is of type `name`.
- `Token:is_number()`: checks if the token is of type `number`.
- `Token:is_string()`: checks if the token is of type `string`.
- `Token:is_special()`: checks if the token is of type `special`.
- `Token:is_paren()`: checks if the token is of type `paren`.
- `Token:is_bracket()`: checks if the token is of type `bracket`.
- `Token:is_brace()`: checks if the token is of type `brace`.
- `Token:assert_is(...)`: asserts that the type of the token matches at least one of the specified types.
