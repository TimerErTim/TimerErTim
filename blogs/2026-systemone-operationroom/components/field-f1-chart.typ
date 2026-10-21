#import "../../common/theming.typ": theme
#import "../../common/variants.typ": broader-than
#import "../deps.typ": lq
#import "../results.typ": model-comparison-raw
#import "../../common/presentation.typ": case, object

#let field-f1-chart(
  model-names: ("jev-latest", "alibiserikbay/JevK5-2B"),
  labels: ("Jev", "JevK5-2B"),
  width: 100%,
  height: 8cm,
  interactive: false,
  tag: (label, it) => it,
) = {
  let fields = model-comparison-raw
    .models
    .first()
    .field_f1
    .map(it => it.field)
  let field-data(model-name) = model-comparison-raw.models.find(
    it => it.model_name == model-name,
  ).field_f1
  let total = if interactive { 2 } else { model-names.len() }
  let bar(model-name, index) = {
    let values = fields.map(field => {
      field-data(model-name).find(it => it.field == field).f1
    })
    lq.bar(
      range(fields.len()),
      values,
      width: 0.8 / total,
      offset: (index - (total - 1) / 2) * (0.8 / total),
      label: text(labels.at(index)),
    )
  }
  let diagram(jevk5-data: ()) = lq.diagram(
    width: width,
    height: height,
    xlim: (-1, fields.len()),
    xaxis: (
      ticks: {
        let fields = fields
          .map(rotate.with(-45deg, reflow: true))
          .map(broader-than(480pt, it => it, text.with(size: 9pt)))
        fields
          .map(place.with(right, dx: 0.75em))
          .map(it => context {
            let max-height = calc.max(
              ..fields.map(measure).map(it => it.height),
            )
            show: box.with(height: max-height)
            it
          })
          .enumerate()
      },
      subticks: none,
    ),
    yaxis: (
      format-ticks: (ticks, ..) => {
        lq.tick-format.linear(ticks.map(it => it * 100), suffix: $%$)
      },
    ),
    bar(model-names.at(0), 0),
    ..jevk5-data,
  )

  set rect(radius: (rest: theme.layout.radius.small, bottom: 0pt))
  if interactive {
    tag(
      "diagram",
      object(
        diagram,
        with-jevk5: case(jevk5-data: (bar(model-names.at(1), 1),)),
      )(),
    )
  } else {
    diagram(jevk5-data: model-names.slice(1).enumerate().map(
      ((index, name)) => bar(name, index + 1),
    ))
  }
}
