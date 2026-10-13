#import "../../common/theming.typ": catppuccin-accents, theme


#let llm-decision-model-comparison-table(
  tag: (label, it) => it,
) = {
  let textstream-vis(..lengths) = {
    set line(stroke: theme.colors.muted)
    show line: box
    show: box
    lengths.pos().map(length => line(length: length)).join(h(0.5mm))
  }

  show table.cell.where(y: 0): strong
  set table.cell(stroke: none)

  show: tag.with("llm-decision-model-comparison-table")
  table(
    columns: 3,
    column-gutter: 1em,
    align: (x, y) => {
      if x == 0 {
        return left
      }

      right + horizon
    },
    inset: 0.5em,
    table.header(
      table.cell(stroke: none)[],
      table.cell()[Large Language Model],
      table.cell()[System-One Model],
    ),
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.medium),
    [_Fundamental Output_],
    [Textstream #h(1cm) #{
        show: box
        place(top + right, textstream-vis(2mm, 1mm, 1.5mm, 3mm), dy: -2mm)
        place(top + right, textstream-vis(3mm, 0.5mm, 2mm, 2mm), dy: -0mm)
      }],
    [Typed Probabilities
      #(
        (2mm, 5mm, 3mm)
          .map(length => box(
            height: length,
            width: 2mm,
            fill: catppuccin-accents.blue,
            radius: 0.5mm,
          ))
          .join(h(1mm))
      )
    ],
    [_Reasoning Efforts_], [High, Long Thinking 🧠], [Low, Intuitive 💢],
    [_Cost Efficiency and Speed_], [Low, Slow 🐌], [High, Fast 🚀],
  )
}
