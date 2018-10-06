This is a programming exercise, implemented two different ways. One approach is the traditional algorithmic reverse polish notation/shunting yard algorithm, the other is the declarative / functional approach with DSLs. The two implementations are pointed by the two branches: [parslet](/../../tree/parslet), [reverse polish](/../../tree/reverse_polish).

## Example

The program supports of parsing and evaluating simple arithmetic, and variables. Every second line is the REPL response to the previous line input.

```
$ repl.rb
2.0
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

### Precedences

Precedences and parenthesis are correctly handled:

```
1+2*2
5.0
1*2+2
4.0
(1+2)*2
6.0
```
