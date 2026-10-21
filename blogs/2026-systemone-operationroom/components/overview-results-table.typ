#import "../../common/theming.typ": catppuccin-accents, theme
#import "../deps.typ": z
#import "../results.typ": latency-raw, model-comparison-raw

#let overview-results-table(
  tag: (label, it) => it,
) = {
  show table.cell.where(y: 0): strong
  set table.cell(stroke: none)
  z.set-round(
    precision: 3,
    mode: "figures",
  )

  let number-row(..numbers, format-num: auto, highlight: top) = {
    let format-num = if format-num == auto {
      z.num.with(..numbers.named())
    } else { format-num }
    let sorted = numbers.pos().enumerate().sorted(key: ((idx, val)) => val)
    let highlight-index = if highlight == top {
      sorted.last().at(0)
    } else {
      sorted.first().at(0)
    }
    for (idx, number) in numbers.pos().enumerate() {
      (
        [
          #show: if idx == highlight-index { math.bold } else { it => it }
          #format-num(number)
        ],
      )
    }
  }

  let get-model-data(model-name) = {
    model-comparison-raw.models.find(it => it.model_name == model-name)
  }

  let get-latency-data(model-name) = {
    latency-raw.per_model.find(it => it.model_name == model-name)
  }

  let model-rows(
    ..names,
    map: it => it,
    format-num: auto,
    highlight: top,
  ) = {
    number-row(
      ..names.pos().map(get-model-data).map(map),
      ..names.named(),
      format-num: format-num,
      highlight: highlight,
    )
  }

  let latency-rows(
    ..names,
    map: it => it,
    format-num: auto,
    highlight: top,
  ) = {
    number-row(
      ..names.pos().map(get-latency-data).map(map),
      ..names.named(),
      format-num: format-num,
      highlight: highlight,
    )
  }

  show: z.format-table(none, auto, auto)
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
      table.cell()[Jev (TypeSafe AI)],
      table.cell()[JevK5-2B 🖥️],
    ),
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.medium),
    [_Field Macro-F1_],
    ..model-rows("jev-latest", "alibiserikbay/JevK5-2B", map: it => {
      it.field_macro_f1
    }),
    [_Fresh Accuracy_],
    ..model-rows("jev-latest", "alibiserikbay/JevK5-2B", map: it => {
      it.accuracy_fresh
    }),
    [_Hallucination Rate_],
    ..model-rows(
      "jev-latest",
      "alibiserikbay/JevK5-2B",
      map: it => {
        it.no_change_false_positive_rate * 100
      },
      format-num: z.zi.percent,
      highlight: bottom,
    ),
    [_Fresh Latency p50 / p95_],
    ..latency-rows(
      "jev-latest",
      "alibiserikbay/JevK5-2B",
      map: it => (it.report.fresh.pass.p50_ms, it.report.fresh.pass.p95_ms),
      format-num: ((p50, p95)) => {
        z.zi.ms(p50)
        " / "
        z.zi.ms(p95)
      },
      highlight: bottom,
    ),
    [_Fresh Calibration ECE_],
    ..model-rows(
      "jev-latest",
      "alibiserikbay/JevK5-2B",
      map: it => it.calibration.ece,
      highlight: bottom,
    ),
  )
}

#overview-results-table()
