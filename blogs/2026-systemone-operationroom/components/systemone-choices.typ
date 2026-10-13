#import "../../common/theming.typ": theme

#let systemone-choices(tag: (label, it) => it) = {
  show: tag.with("systemone-choices-table")
  set table.cell(stroke: none)
  show table.cell.where(y: 0): strong
  table(
    columns: 4,
    column-gutter: 1em,
    inset: 0.5em,
    align: left,
    table.header(
      table.cell()[Primitive],
      table.cell()[Question],
      table.cell()[Example answer space],
      table.cell()[Example output],
    ),
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.medium),
    [*Choice*],
    [Which team should handle this ticket?],
    [`billing`, `technical`, or `account`],
    [`choice: "billing"`],
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.small),
    [*Score*],
    [How frustrated is this customer?],
    [0 = calm, 1 = frustrated, 2 = very frustrated],
    [`score: 1.4`],
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.small),
    [*Noul*],
    [Does this message request a refund?],
    [True or false],
    [`noul: 0.95`],
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.small),
  )
}
