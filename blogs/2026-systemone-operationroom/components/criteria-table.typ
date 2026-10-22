#import "../../common/theming.typ": catppuccin-accents, theme
#import "../../common/variants.typ": broader-than


#let criteria-table(
  columns: (1fr, auto, auto, auto),
  headers: ([20], [95]),
) = {
  show table.cell.where(y: 0): strong
  set table.cell(stroke: none)

  table(
    columns: columns,
    column-gutter: 1em,
    align: (center + horizon, ..(left + horizon,) * 3),
    inset: 0.5em,
    table.header(
      table.cell(stroke: none)[],
      table.cell()[Base],
      ..headers,
    ),
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.large),
    [_light#broader-than(480pt, none, linebreak())\_brightness_], [
      `null`\
      `increase:1`\
      `decrease:1`\
      `set:0`\
      `set:100`\
    ], [
      `set:20`\
      `increase:20`\
      `decrease:20`\
    ], [
      `set:95`\
      `increase:95`\
      `decrease:95`\
    ],
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.small),
    [_table#broader-than(480pt, none, linebreak())\_tilt_], [
      `null`\
      `increase:1`\
      `decrease:1`\
      `set:0`\
    ], [
      `set:20`\
      `increase:20`\
      `decrease:20`\
    ], [
      `set:95`\
      `increase:95`\
      `decrease:95`\
    ],
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.small),
    ..(table.cell(align: auto, pad(left: 1cm, sym.dots.v)),) * 4
  )
}
