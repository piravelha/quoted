# Quote

Quotes are the essential part of the quoted library, allowing you to delay code evaluation.

> NOTE: All methods return new quotes, no in-place modification happens here.

## `insert`
`Quote:insert(index: number, value: Token | string): Quote`

Inserts the value at the specified index in the quote.

## `index_of`
`Quote:index_of(value: Token | string): number`

Returns the index of the first occurrence of the value.

## `count`
`Quote:count(value: Token | string): number`

Returns the number of times a value is found inside a quote.

## `reverse`
`Quote:reverse(): Quote`

Returns a new, reversed version of the quote.

## `remove`
`Quote:remove(index: number): Quote`

Returns a new quote with the specified index removed.

## `contains`
`Quote:contains(value: Token | string): boolean`

Returns true if the value is contained inside the quote.

## `append`
`Quote:append(value: Token | string): Quote`

Returns a new quote with the specified value appended to the end.

## `prepend`
`Quote:prepend(value: Token | string): Quote`

Returns a new quote with the specified value prepended to the start of the quote.

## `pop`
`Quote:pop(): Token, Quote`

Returns the first value of the quote and the rest of the quote.

## `peek_value`
`Quote:peek_value(): string`

Returns the value (string) of the first token of the quote.

## `extend`
`Quote:extend(other: Quote): Quote`

Extends the quote with another quote, with the other one being appended to the end.

## `slice`
`Quote:slice(min: number, max?: number): Quote`

Returns the subquote starting from `min` and ending at `max`, works similarly to `string.sub`, `max` parameter defaults to the length of the quote, and both `min` and `max` can be negative.

## `expect`
`Quote:expect(value: Token | string): Token, Quote`

Pops the first value from the quote, and asserts its value matches `value`, returns first the popped value, and then the rest of the quote.

## `consume`
`Quote:consume(value: Token | string): Quote`

Pops the first value from the quote, and asserts its value matches `value`, returns only the rest of the quote, useful when chaining transformations.

## `expect_last`
`Quote:expect_last(value: Token | string): Token, Quote`

Pops the last value from the quote, and asserts its value matches `value`, returns first the popped value, and then the rest of the quote.

## `expect_name`
`Quote:expect_name(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `name`, returns first the popped value, and then the rest of the quote.

## `expect_number`
`Quote:expect_number(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `number`, returns first the popped value, and then the rest of the quote.

## `expect_string`
`Quote:expect_string(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `string`, returns first the popped value, and then the rest of the quote.

## `expect_paren`
`Quote:expect_paren(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `paren`, returns first the popped value, and then the rest of the quote.

## `expect_bracket`
`Quote:expect_bracket(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `bracket`, returns first the popped value, and then the rest of the quote.

## `expect_brace`
`Quote:expect_brace(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `brace`, returns first the popped value, and then the rest of the quote.

## `expect_special`
`Quote:expect_special(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `special`, returns first the popped value, and then the rest of the quote.

## `expect_delimiter`
`Quote:expect_delimiter(): Token, Quote`

Pops the first value of the quote, and asserts its type is of `delimiter`, returns first the popped value, and then the rest of the quote.

## `split`
`Quote:split(separator: Token | string, deep?: boolean): QuoteList`

Returns a `QuoteList` containing the values that were split by the separator, `deep` parameter specifies if it should ignore parenthesis/bracket/brace nesting precautions when splitting.

## `args`
`Quote:args(): QuoteList`

Returns an unpacked result of splitting the quote by `","`.

## `str`
`Quote:str(): string`

(WIP) Returns the string representation of the quote, with double quotes escaped, intended to be used when putting quotes directly inside strings.

## `repr`
`Quote:repr(): string`

Returns the string representation of the quote.

## `balanced`
`Quote:balanced(start: Token | string, finish: Token | string): Quote | nil`

Returns the subquote starting from the first token, where `start` and `finish` are balanced, returns nil otherwise.

## `replace`
`Quote:replace(old: Token | string, new: Token | string): Quote`

Replaces all occurrences of token `old` inside the quote with `new`.

## `map`
`Quote:map(fn): Quote`

Applies a transformation function to each token of the quote.

## `foreach`
`Quote:foreach(fn): void`

Calls the specified function for each token of the quote.

## `pairs`
`Quote:pairs(fn): void`

Calls the specified function for each index and token of the quote, similar to `pairs()/ipairs()`.

## `take_until`
`Quote:take_until(value: Token | string): Quote, Quote`

Keeps consuming the quote until it finds the specified value, returns the consumed subquote first, and then the rest of the quote afterwards, with the found value not included.

## `rep`
`Quote:rep(num: number): QuoteList`

Repeats the quote the specified amount of times and returns a `QuoteList` of the results.

## `expr`
`Quote:expr(): any`

Evaluates the quote, returning its result.
