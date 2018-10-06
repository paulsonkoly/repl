This is a programming exercise, implemented two different ways. One approach is the traditional algorithmic reverse polish notation/shunting yard algorithm, the other is the declarative / functional approach with DSLs. The two implementations are pointed by the two branches: [parslet](/phaul/repl/tree/parslet), [reverse polish](/phaul/repl/tree/reverse_polish).

## Example

The program supports of parsing and evaluating simple arithmetics, and variables.

```
$ repl.rb
2.0
a
nil
a = 3 + 4
7.0
1 + a
8.0
a + a
14.0
```
