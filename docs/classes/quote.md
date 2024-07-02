# Quote

quotes are the essential part of the quoted library, allowing you for delaying code evaluation.

> NOTE: All methods return new quotes, no in-place modification happens here

- `Quote:insert(index: number, value: Token | string)`: inserts the value at the specified index at the quote.
- `Quote:index_of(value: Token | string)`: returns the index of the first occurence of the value.
- `Quote:count(value: Token | string)`: returns the amount of times a value is found inside a quote.
- `Quote:reverse()`: returns a new, reversed version of the quote.
- `Quote:remove(index: number)`: returns a new quote with the specified index removed.
- `Quote:contains(value: Token | string)`: returns true if the value is contained inside the quote.
- `Quote:append(value: Token | string)`: returns a new quote with the specified value appended to the end.
- `Quote:prepend(value: Token | string)`: returns a new quote with the specified value prepended to the start of the quote.
- `Quote:pop()`: returns the first value of the quote, and the rest of the quote.
- `Quote:peek_value()`: returns the value (string) of the first token of the quote.
- `Quote:extend(other: Quote)`: extends the quote with another quote, with the other one being appended to the end.
- `Quote:slice(min: number, max?: number)`: returns the subquote starting from `min` and ending at `max`, works similarly to `string.sub`, `max` parameter defaults to the length of the quote, and both `min` and `max` can be negative.
- `Quote:expect(value: Token | string)`: pops the first value from the quote, and asserts its value matches `value`, returns first the popped value, and then the rest of the quote.
- `Quote:consume(value: Token | string)`: pops the first value from the quote, and asserts its value matches `value`, returns only the rest of the quote, useful when chaining transformations.
- `Quote:expect_last(value: Token | string)`: pops the last value from the quote, and asserts its value matches `value`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_name()`: pops the first value of the quote, and asserts its type is of `name`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_number()`: pops the first value of the quote, and asserts its type is of `number`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_string()`: pops the first value of the quote, and asserts its type is of `string`, returns first the popped value, and then the rest of the quote
- `Quote:expect_paren()`: pops the first value of the quote, and asserts its t.ype is of `paren`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_bracket()`: pops the first value of the quote, and asserts its type is of `bracket`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_brace()`: pops the first value of the quote, and asserts its type is of `brace`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_special()`: pops the first value of the quote, and asserts its type is of `special`, returns first the popped value, and then the rest of the quote.
- `Quote:expect_delimiter()`: pops the first value of the quote, and asserts its type is of `delimiter`, returns first the popped value, and then the rest of the quote.
- `Quote:split(separator: Token | string, deep?: boolean)`: returns a `QuoteList` containing the values that were split by the separator, `deep` parameter specifies if it should ignore parenthesis/bracket/brace nesting precautions when splitting.
- `Quote:args()`: returns an unpacked result of splitting the quote by `","`.
- `Quote:str()`: (**WIP**) returns the string representation of the quote, with double quotes escaped, intented to be used when putting quotes directly inside strings. 
- `Quote:repr()`: simply returns the string representation of the quote.
- `Quote:balanced(start: Token | string, finish: Token | string)`: returns the subquote starting from the first token, where `start` and `finish` are balanced, returns nil otherwise.
- `Quote:replace(old: Token | string, new: Token | string)`: replaces all occurrences of token `old` inside the quote with `new`.
- `Quote:map(fn)`: applies a transformation function to each token of the quote.
- `Quote:foreach(fn)`: calls the specified function for each token of the quote.
- `Quote:pairs(fn)`: calls the specified function for each index and token of the quote, similar to `pairs()/ipairs()`.
- `Quote:take_until(value: Token | string)`: keeps consuming the quote until it finds the specified value, returns the consumed subquote first, and then the rest of the quote afterwards, with the found value not included.
- `Quote:rep(num: number)`: repeats the quote the specified amount of times and returns a QuoteList of the results
- `Quote:expr()`: evaluates the quote, returning its result.