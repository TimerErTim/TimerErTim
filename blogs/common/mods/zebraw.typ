#import "../deps.typ": zebraw as _zebraw
#import "../base-style.typ": style-raw

/// Block of code with highlighted lines and comments.
///
/// -> content
#let zebraw(
  /// Whether to show the line numbers.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   numbering: false,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///    )
  ///   ```
  ///  )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> boolean
  numbering: none,
  /// Lines to highlight or comments to show.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   highlight-lines: range(3, 7),
  ///   header: [*Fibonacci sequence*],
  ///   ```typst
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  ///   footer: [The fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$],
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  ///
  /// -> array | int
  highlight-lines: (),
  /// The offset of line numbers. The first line number will be `numbering-offset + 1`.
  /// Defaults to `0`.
  /// -> int
  numbering-offset: 0,
  /// The header of the code block.
  ///
  /// -> string | content
  header: none,
  /// The footer of the code block.
  ///
  /// -> string | content
  footer: none,
  /// The inset of each line.
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   inset: (top: 6pt, bottom: 6pt),
  ///   ```typ
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> dictionary
  inset: none,
  /// The radius of the code block corners.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   radius: 10pt,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> length
  radius: none,
  /// The background color of the block and normal lines.
  ///
  /// #example(
  /// ````typ
  /// #zebraw(
  ///   background-color: (luma(240), luma(245), luma(250), luma(245)),
  ///   ```typst
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```,
  /// )
  /// ````,
  /// scale-preview: 100%,
  /// )
  /// -> color | array
  background-color: none,
  /// The background color of the highlighted lines.
  ///
  /// -> color
  highlight-color: none,
  /// The background color of the comments. The color is set to `none` at default and it will be rendered in a lightened `highlight-color`.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   highlight-color: yellow.lighten(80%),
  ///   comment-color: yellow.lighten(90%),
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> color
  comment-color: none,
  /// The background color of the language tab. The color is set to `none` at default and it will be rendered in comments' color.
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   lang-color: eastern,
  ///   lang-font-args: (
  ///     font: "libertinus serif",
  ///     weight: "bold",
  ///     fill: white
  ///   ),
  ///   ```typst
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  /// -> color
  lang-color: none,
  /// The flag at the beginning of comments. The indentation of codes will be rendered before the flag. When the flag is set to `""`, the indentation before the flag will be disabled as well.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   comment-flag: "",
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> string | content
  comment-flag: none,
  /// Whether to show the language tab, or a string or content of custom language name to display.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: strong[Typst],
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean | string | content
  lang: none,
  /// The arguments passed to comments' font.
  ///
  /// -> dictionary
  comment-font-args: none,
  /// The arguments passed to the language tab's font.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   lang: true,
  ///   comment-font-args: (font: "IBM Plex Serif", style: "italic"),
  ///   lang-font-args: (font: "IBM Plex Sans", weight: "bold"),
  ///   highlight-lines: (
  ///     (1, [The Fibonacci sequence is defined through the recurrence relation $F_n = F_(n-1) + F_(n-2)$]),
  ///     ..range(9, 14),
  ///     (13, [The first \#count numbers of the sequence.]),
  ///   ),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> dictionary
  lang-font-args: none,
  /// The arguments passed to the line numbers' font.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   numbering-font-args: (fill: blue),
  ///   ```typ
  ///   = Fibonacci sequence
  ///   #let count = 8
  ///   #let nums = range(1, count + 1)
  ///   #let fib(n) = (
  ///     if n <= 2 { 1 }
  ///     else { fib(n - 1) + fib(n - 2) }
  ///   )
  ///
  ///   #align(center, table(
  ///     columns: count,
  ///     ..nums.map(n => $F_#n$),
  ///     ..nums.map(n => str(fib(n))),
  ///   ))
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> dictionary
  numbering-font-args: none,
  /// Whether to extend the vertical spacing.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   extend: false,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  extend: none,
  /// Whether to show the numbering separator line.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   numbering-separator: true,
  ///   ```typ
  ///   #grid(
  ///      columns: (1fr, 1fr),
  ///      [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  numbering-separator: none,
  /// Whether to show the hanging indent.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   hanging-indent: true,
  ///   ```typ
  ///   This is a short line.
  ///     Do a deer, a female deer. Ray, a drop of golden sun. Me, a name I call myself. Far, a long, long way to run. Sew, a needle pulling thread. La, a note to follow sew. Tea, a drink with jam and bread. That will bring us back to do, oh, oh, oh.
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> boolean
  hanging-indent: none,
  /// The amount of indentation, used to draw indentation lines.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   indentation: 2,
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> int
  indentation: none,
  /// Line range to show. Accepts an array of 2 integers [a, b) or a dictionary with keys named `range` and `keep-offset`. Defaults to [1, none). (none means the last line). Noticed that the line numbers are 1-based.
  ///
  /// #example(````typ
  /// #zebraw(
  ///   line-range: (2, 4),
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// #example(````typ
  /// #zebraw(
  ///   line-range: (range: (2, 4), keep-offset: false),
  ///   ```typ
  ///   #grid(
  ///     columns: (1fr, 1fr),
  ///     [Hello,], [world!],
  ///   )
  ///   ```
  /// )
  /// ````,
  /// scale-preview: 100%)
  ///
  /// -> array | dictionary
  line-range: (1, none),
  /// (Only for HTML) The width of the code block.
  /// -> length | relative
  block-width: 42em,
  /// (Only for HTML) Whether to wrap the code lines.
  /// -> boolean
  wrap: true,
  /// (Only for HTML) Whether to show the copy button.
  /// -> boolean
  copy-button: true,
  /// The body.
  /// -> content
  body,
) = {
  let args = (
    background-color: background-color,
    radius: radius,
    extend: extend,
    lang-color: lang-color,
    comment-color: comment-color,
    comment-flag: comment-flag,
    lang: lang,
    lang-font-args: lang-font-args,
    numbering-font-args: numbering-font-args,
    numbering: numbering,
    numbering-offset: numbering-offset,
    highlight-lines: highlight-lines,
    indentation: indentation,
    line-range: line-range,
    block-width: block-width,
    wrap: wrap,
    copy-button: copy-button,
    header: header,
    footer: footer,
  )
  show: _zebraw.with(
    ..args,
  )
  show raw: style-raw
  body
}
