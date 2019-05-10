# Syntax

## Metacharacters

#### Quantifiers

| Implemented? | Quantifier | Example    | Equivalency | Description
| :----------: | :--------: | :--------- | :---------- | -----------
| No           | `{n}`      | `a{3}`     | `aaa`       | Matches the preceding element exactly `n` times.
| No           | `{n,}`     | `a{1,}`    | `aa*`       | Matches the preceding element at least `n` times.
| No           | `{n,m}`    | `a{1,3}`   | `aa?a?`     | Matches the preceding element from `n` to `m` times.
| Yes          | `?`        | `x?`       | `x{0,1}`    | Matches the preceding element zero times or once.
| Yes          | `*`        | `x*`       | `x{0,}`     | Matches the preceding element from zero to unlimited times.
| Yes          | `+`        | `x+`       | `xx*`       | Matches the preceding element at least once.


#### Operations

| Implemented? | Operation  | Example    | Equivalency | Description
| :----------: | :--------: | :--------- | :---------- | -----------
| Yes          | `(E)`      | `(abc)`    | `abc`       | Some subexpression `E`.
| Yes          | `[S]`      | `[abc]`    | `a|b|c`     | Matches any character in set `S`.
| Yes          | `.`        | `.`        |             | Matches any character.
| Yes          | `^`        | `^a`, `[^ab]` |          | Negation. Matches any character but the following.
| Yes          | `|`        | `ab|xy`    |             | Matches either `ab` or `xy`.



## Escape sequences

#### Special characters

In order to match the following characters literally, they should always be escaped. In some contexts they may not require escaping, but it is highly recommended to do so regardless.

| Character | Literal context | Bracket context |
| :-------: | :-------------: | :-------------: |
| `\`       | `\\`            | `\\`            |
| `(`       | `\(`            | `(`             |
| `)`       | `\)`            | `)`             |
| `[`       | `\[`            | `\[`            |
| `]`       | `\]`            | `\]`            |
| `{`       | `\{`            | `{`             |
| `}`       | `\}`            | `}`             |
| `^`       | `\^`            | `\^`            |

<!-- | `-`       | `-`             | `\-`            | -->
<!-- | `$`       | `\$`            | `\$`            | -->


#### Character classes

**NOTE**: Character classes can **not** be used in the bracket context. However, this behaviour can be simulated using the union operation, since e.g. `[\d\s]` is equivalent to `(\d|\s)`.

| Sequence  | Equivalent character set |
| :-------: | :----------------------- |
| `\w`      | `[A-Za-z0-9_]`           |
| `\W`      | `[^A-Za-z0-9_]`          |
| `\d`      | `[0-9]`                  |
| `\D`      | `[^0-9]`                 |
| `\s`      | `[ \t\r\n\v\f]`          |
| `\S`      | `[^ \t\r\n\v\f]`         |
| `\l`      | `[a-z]`                  |
| `\L`      | `[^a-z]`                 |
| `\u`      | `[A-Z]`                  |
| `\U`      | `[^A-Z]`                 |



## Sample expressions

| Expression      | Matches input...
| :-------------- | :----------
| `a+`            | ...with at least one `a`, and no other symbols.
| `ab+`           | ...beginning with `a`, followed by at least one `b`.
| `\w*`           | ...with any amount of symbols in the set `[A-Za-z0-9_]`.
| `^a.*`          | ...beginning with any other symbol than `a`.
| `.*\.(jpg|png)` | ...ending in `.jpg` or `.png`.
