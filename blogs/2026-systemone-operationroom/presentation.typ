#import "../common/presentation.typ": (
  apply, presentation, revert, scene, slide, once, clear, revert, cover, object,
  case,
)
#import "../common/components/slides.typ": (
  card-slide-mod, focus-slide, full-slide,
)
#import "../common/theming.typ": catppuccin-accents, theme
#import "../common/variants.typ": hide-in-preview

#set document(
  title: [#strong[S]ys#strong[t]em One #strong[Op]erating Room],
  author: "Tim Peko",
  date: datetime(year: 2026, month: 10, day: 20),
  description: "Employing System-One Decisions Models for Controlling Operating Room Equipment",
  keywords: (
    "System One",
    "Operating Room",
    "English",
    "University of Applied Sciences, Digital Campus Hagenberg",
  ),
)
#show: presentation.with(
  handout: false,
  seed: 42 * 42,
)

#import "presentation/slides.typ": chapter-intro-slide
#import "presentation/title.typ": title-scene
#import "../common/components/depth.typ": depth-shadow-block
#import "../common/components/callouts.typ": (
  callout-block, danger-callout, info-callout, success-callout,
)
#import "components/comparison.typ": llm-decision-model-comparison-table
#import "components/systemone-choices.typ": systemone-choices
#import "components/criteria-table.typ": criteria-table
#import "components/overview-results-table.typ": overview-results-table
#import "deps.typ": lq, sj, treet, z, zebraw


#title-scene()

#scene(
  // Show image of operating room
  // Problem introduction (voice utterance room control -> realtime and less complexity)
  tag => [
    #show: card-slide-mod
    #show: full-slide
    #image(
      "assets/operating_room.png",
      height: 100%,
      width: 100%,
      fit: "stretch",
    )
  ],
  controls: (),
)

#scene(
  // Chapter: System-One models
  tag => [
    #show: focus-slide.with(fill: white.transparentize(100%))
    #chapter-intro-slide(
      description: [
        And how they can be used for controlling operating room equipment?
      ],
    )[
      What are System-One models
    ]
  ],
)

// System-One and Jev Introduction => System 1 and System 2! TypeSafe AI
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide

    #grid(
      columns: (1fr, auto, 1fr),
      rows: (1fr, auto, 1fr),
      align: center + horizon,
      [
        #set text(size: 28pt)
        #show: strong
        #{
          show: box.with(radius: theme.layout.radius.large, clip: true)
          image("assets/typesafe_logo.png", height: 60%)
        }\
        TypeSafe AI
      ],
      {
        show: tag.with("systemone")
        set text(size: 64pt)
        sym.arrow
      },
      {
        show: tag.with("systemone")
        set par(spacing: 0.5em)
        [
          #set text(size: 32pt)
          #show: strong
          System 1 🏎️
        ]
        parbreak()
        [
          Fast, Instinctive
        ]
      },

      {
        show: tag.with("jev")
        set text(size: 64pt)
        sym.arrow.b
      },
      {},
      {
        show: tag.with("systemtwo")
        set text(size: 24pt, fill: catppuccin-accents.red)
        [vs.]
      },

      {
        show: tag.with("jev")
        set text(size: 36pt)
        show: strong.with(delta: 600)
        show: underline.with(
          stroke: catppuccin-accents.pink + theme.layout.borderWidth.large,
        )
        [JEV]
      },
      {},
      {
        show: tag.with("systemtwo")
        set par(spacing: 0.5em)
        [
          #set text(size: 32pt)
          #show: strong
          System 2 🚛
        ]
        parbreak()
        [
          Deliberate, High Reasoning
        ]
      },
    )
  ],
  controls: (
    (),
    apply("systemone"),
    apply("systemtwo"),
    apply("jev"),
  ),
)

#let hide-table(rows: auto, cols: auto, body) = {
  if rows == auto and cols == auto {
    return {
      show table: hide
      body
    }
  }

  let combs = if rows == auto {
    cols.map(col => (auto, col))
  } else if cols == auto {
    rows.map(row => (row, auto))
  } else {
    for row in rows {
      for col in cols {
        ((row, col),)
      }
    }
  }

  show: combs.fold(
    it => it,
    (func, (row, col)) => {
      it => {
        if row == auto {
          show table.cell.where(x: col): hide
          func(it)
        } else if col == auto {
          show table.cell.where(y: row): hide
          func(it)
        } else {
          show table.cell.where(y: row, x: col): hide
          func(it)
        }
      }
    },
  )
  body
}
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #{
      grid(
        columns: (3fr, auto, 1fr, auto, 1fr),
        gutter: 1em,
        {
          set align(center + horizon)
          show: tag.with("lorem")
          show: info-callout
          set text(font: "minecraft enchantment")
          lorem(10)
        },
        {
          show: tag.with("lorem")
          show: pad.with(1cm)
          set align(center + horizon)
          set text(size: 64pt)
          sym.arrow
        },
        {
          image("assets/coin_front.png")
          show: place.with(center + horizon)
          set text(size: 32pt, fill: white)
          show: strong
          [LLMs]
        },
        {
          set align(center + horizon)
          set text(size: 24pt)
          sym.arrow.l.r
        },
        {
          image("assets/coin_back.png")
          show: place.with(center + horizon)
          set text(size: 24pt, fill: white)
          show: strong
          [Decision\ Models]
        },
      )
    }

    #v(1cm)
    #scale(150%, reflow: true, llm-decision-model-comparison-table(tag: tag))
  ],
  controls: (
    (),
    apply("lorem"),
    once("llm-decision-model-comparison-table", it => {
      show: hide-table.with(rows: (2, 3))
      it
    }),
    once("llm-decision-model-comparison-table", it => {
      show: hide-table.with(rows: (3,))
      it
    }),
    apply("llm-decision-model-comparison-table"),
  ),
)

#let images = (
  image("assets/jev-slop-detector.webp"),
  image("assets/jev-canvas-demo.png"),
  image("assets/jev-plaing-doom.webp"),
)
#scene(
  tag => [
    #show: card-slide-mod
    #show: full-slide
    #(
      images
        .enumerate()
        .map(((i, img)) => {
          show: tag.with("img" + str(i))
          show: place
          set image(height: 100%, width: 100%, fit: "stretch")
          img
        })
        .join([])
    )
    #show: tag.with("generalising")
    #show: place.with(center + horizon)
    #show: rotate.with(4deg, reflow: true)
    #show: block.with(
      inset: 1cm,
      stroke: theme.colors.danger + theme.layout.borderWidth.large,
      radius: theme.layout.radius.large,
    )
    #show: strong
    #show: text.with(
      size: 128pt,
      fill: theme.colors.danger,
      stroke: theme.colors.danger.transparentize(50%)
        + theme.layout.borderWidth.large,
    )
    Generalist!
  ],
  controls: (
    once("img0"),
    once("img1"),
    apply("img2"),
    apply("generalising"),
  ),
)

#let underline-table-cell(y, x, body) = {
  show table.cell.where(y: y, x: x): underline.with(
    stroke: theme.colors.accent + theme.layout.borderWidth.medium,
  )
  let (target-x, target-y) = (x, y)
  set table(fill: (x, y) => {
    if y == target-y {
      theme.colors.info.transparentize(75%)
    }
  })
  body
}
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Types of Questions

    #{
      show: align.with(center + horizon)
      show: scale.with(125%, reflow: true)
      systemone-choices(tag: tag)
    }
  ],
  options: (handout-index: 1),
  controls: (
    apply("systemone-choices-table"),
    once("systemone-choices-table", underline-table-cell.with(1, 0)),
    once("systemone-choices-table", underline-table-cell.with(2, 0)),
    once("systemone-choices-table", underline-table-cell.with(3, 0)),
  ),
)

// Example: Json Input/Output for Systemone API
#let api-example(
  subtype,
  input-line-range,
  output-line-range,
  controls: (
    (apply("input"), apply("nn"), apply("output")),
  ),
) = scene(
  tag => [
    #show: hide-in-preview
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Example Invocation
    #text(size: 24pt, subtype)

    #{
      show: zebraw.with(line-range: (2, 8))
      raw(block: true, lang: "json", read("assets/systemone_input.json"))
    }
    #set align(center + horizon)
    #v(1em)
    #grid(
      columns: (1fr, auto, auto, auto, 1fr),
      align: (top, horizon, horizon, horizon, top),
      gutter: 0.5em,
      {
        show: tag.with("input")
        show: zebraw.with(indentation: 2, line-range: input-line-range)
        raw(block: true, lang: "json", read("assets/systemone_input.json"))
      },
      {
        show: tag.with("nn")
        set text(size: 32pt)
        sym.arrow
      },
      {
        show: tag.with("nn")
        image("assets/connection_tweak.png", width: 4cm)
      },
      {
        show: tag.with("output")
        set text(size: 32pt)
        sym.arrow
      },
      {
        show: tag.with("output")
        show: zebraw.with(indentation: 2, line-range: output-line-range)
        raw(block: true, lang: "json", read("assets/systemone_output.json"))
      },
    )

  ],
  controls: controls,
)
#api-example(
  [Score],
  (8, 19),
  (4, 17),
  controls: ((), (apply("input")), (apply("nn")), (apply("output"))),
)

#api-example(
  [Choice],
  (19, 29),
  (17, 28),
)

#api-example(
  [Noul],
  (29, 33),
  (28, 33),
)

// Chapter: Process - How can we use this for Room Control?
#scene(
  tag => [
    #show: focus-slide.with(fill: white.transparentize(100%))
    #chapter-intro-slide(
      description: [Modelling and Controlling of our Virtual Operating Room],
    )[
      Let's do room control!
    ]
  ],
  controls: (),
)

// Room Setup
// Choices -> Every possible action in the room is a choice
//
#let hide-grid(rows: auto, cols: auto, body) = {
  if rows == auto and cols == auto {
    return {
      show grid: hide
      body
    }
  }

  let combs = if rows == auto {
    cols.map(col => (auto, col))
  } else if cols == auto {
    rows.map(row => (row, auto))
  } else {
    for row in rows {
      for col in cols {
        ((row, col),)
      }
    }
  }

  show: combs.fold(
    it => it,
    (func, (row, col)) => {
      it => {
        return if row == auto {
          show grid.cell.where(x: col): hide
          func(it)
        } else if col == auto {
          show grid.cell.where(y: row): hide
          func(it)
        } else {
          show grid.cell.where(y: row, x: col): hide
          func(it)
        }
      }
    },
  )
  body
}
#scene(
  tag => [
    #show: card-slide-mod
    #show: tag.with("slide")

    #let choice-tag = box.with(
      inset: 2mm,
      fill: theme.colors.info,
      radius: theme.layout.radius.small,
    )
    #let noul-type = text(fill: theme.colors.surface, box(
      choice-tag[noul],
      width: 3cm,
    ))
    #let choice-type = text(fill: theme.colors.surface, box(
      choice-tag[choice],
      width: 3cm,
    ))
    #let objects = (
      (
        label: "Insufflator",
        choices: (
          [#choice-type
            #show: strong
            insufflator_flow],
          [#choice-type
            #show: strong
            insufflator_pressure],
          [#noul-type
            #show: strong
            insufflator_active],
        ),
      ),
      (
        label: "Light",
        choices: (
          [#choice-type
            #show: strong
            light_brightness],
          {
            let underbrace(body, annotation: none, fill: none) = context {
              let prev-fill = text.fill
              set text(fill: fill) if fill != none
              math.underbrace(
                {
                  set text(fill: prev-fill)
                  body
                },
                text(
                  fill: prev-fill,
                  annotation,
                ),
              )
            }
            let idk = object(
              underbrace.with(
                [
                  #show: text.with(font: theme.fonts.sans.family)
                  #choice-type
                  #show: strong
                  light_mode],
                fill: white.transparentize(100%),
              ),
              annotated: case(
                fill: theme.colors.border,
                text.with(fill: catppuccin-accents.red),
                annotation: [
                  #show: place.with(center, dy: -1mm)
                  #set text(fill: theme.colors.foreground)
                  #(
                    (`Normal`, `AmbientRed`, `CavityFocus`, `null`)
                      .enumerate()
                      .map(((i, mode)) => {
                        show: box
                        //place(bottom + center, dy: 1.25em, [#(i + 1)])
                        mode
                      })
                      .join(sym.space.en)
                  )
                ],
              ),
            )
            //show: tag.with("light-mode")
            tag("light-mode", idk())
          },
        ),
      ),
      (
        label: "Table",
        choices: (
          [#choice-type
            #show: strong
            table_height],
          [#choice-type
            #show: strong
            table_tilt],
        ),
      ),
      (
        label: "Endoscope",
        choices: (
          [#choice-type
            #show: strong
            endoscope_zoom],
          [#noul-type
            #show: strong
            endoscope_whitebalance],
          [#noul-type
            #show: strong
            endoscope_irrigation],
        ),
      ),
    )
    #let boxes = (
      (color: catppuccin-accents.red, pos: (1cm, 2cm), dims: (3cm, 8cm)),
      (
        color: catppuccin-accents.yellow,
        pos: (12cm, 0.5cm),
        dims: (5.5cm, 2cm),
      ),
      (color: catppuccin-accents.blue, pos: (10cm, 11cm), dims: (9.5cm, 4.5cm)),
      (
        color: catppuccin-accents.green,
        pos: (19.5cm, 2.25cm),
        dims: (9cm, 6cm),
      ),
    )

    #{
      show: tag.with("imagery")
      image(
        "assets/operating_room.png",
        height: 100%,
        width: 100%,
        fit: "stretch",
      )

      boxes
        .zip(objects)
        .map(((conf, object)) => {
          show: tag.with("boxes")
          set text(fill: conf.color)
          show: place.with(left + top, dx: conf.pos.at(0), dy: conf.pos.at(1))
          box(
            width: conf.dims.at(0),
            height: conf.dims.at(1),
            stroke: conf.color + theme.layout.borderWidth.large,
            radius: theme.layout.radius.large,
            place(left + bottom, dy: 1.25em, object.label),
          )
        })
        .join()
    }

    #{
      show: tag.with("mapping")
      set align(left)
      grid(
        columns: (auto, auto, auto),
        gutter: 1em,
        row-gutter: 1cm,
        align: (right + horizon, center + horizon, left + horizon),
        ..for (color, object) in boxes.map(conf => conf.color).zip(objects) {
          (
            grid.cell(align: right)[
              #set text(fill: color, size: 32pt)
              #show: strong
              #object.label
            ],
            {
              set text(size: 64pt)
              sym.arrow
            },
            [
              #set text(size: 22pt)
              #set par(leading: 0.3em)
              #enum(..object.choices, tight: true)
            ],
          )
        }
      )
    }
  ],
  controls: (
    (apply("slide", full-slide), apply("imagery")),
    once("boxes"),
    (
      clear("slide"),
      apply("imagery", it => none),
      apply("slide", focus-slide),
      once("mapping", hide-grid.with(cols: (1, 2))),
      apply("light-mode"),
    ),
    once("mapping", hide-grid.with(rows: range(1, 4), cols: (1, 2))),
    once("mapping", hide-grid.with(rows: range(2, 4), cols: (1, 2))),
    once("mapping", hide-grid.with(rows: range(3, 4), cols: (1, 2))),
    apply("mapping"),
    apply("light-mode", "annotated"),
  ),
)

// Criteria -> Number extraction from utterance -> Present that as criterias
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Criteria
    #v(1cm)
    #[
      #show: tag.with("utterance")
      #set text(size: 22pt)
      "Turn up brightness by #tag("20-text")[twenty] percent, table should be
      #tag("95-text")[ninety five] centimeters."
    ]
    #{
      show: tag.with("criteria-table")
      show: scale.with(145%, reflow: true)
      criteria-table(
        columns: (auto, auto, auto, 1fr),
        headers: (
          [
            #show: tag.with("table-number")
            20
          ],
          [
            #show: tag.with("table-number")
            //#pinit.pinit-arrow(("20pre", "20post"), ("table20pre", "table20post"))
            95
          ],
        ),
      )
    }
  ],
  controls: (
    (
      apply("criteria-table"),
      apply("20-text"),
      apply("95-text"),
      apply("criteria-table", hide-table.with(cols: (2, 3)), hide-table.with(
        rows: (2, 3),
      )),
    ),
    (apply("utterance")),
    (
      apply(
        "20-text",
        text.with(fill: catppuccin-accents.red),
        strong,
        underline,
      ),
      apply(
        "95-text",
        text.with(fill: catppuccin-accents.red),
        strong,
        underline,
      ),
    ),
    (
      clear("criteria-table"),
      apply("criteria-table", hide-table.with(rows: (2, 3)), hide-table.with(
        cols: (2, 3),
        rows: (1,),
      )),
      apply("table-number", text.with(fill: catppuccin-accents.red), strong),
    ),
    (
      clear("20-text"),
      clear("95-text"),
      clear("criteria-table"),
      apply("criteria-table", hide-table.with(rows: (2, 3))),
    ),
    (
      clear("criteria-table"),
      clear("criteria-table", hide-table.with(rows: (3,))),
      clear("table-number"),
    ),
    (clear("criteria-table")),
  ),
)

// Chapter: Results
#scene(
  tag => [
    #show: focus-slide.with(fill: white.transparentize(100%))
    #chapter-intro-slide(
      description: [#tag("benchmarks")[Benchmarks] and #tag("live-demo")[Live
          Demo]],
    )[
      Results
    ]
  ],
  options: (
    handout-index: 1,
  ),
  controls: (
    (apply("live-demo"), apply("benchmarks")),
    once("benchmarks", it => box({
      it
      place(left + bottom, dx: -1cm, dy: 3cm, {
        show: rotate.with(2.5deg, reflow: true)
        set text(size: 32pt)
        set strong(delta: 600)
        [*Not*
          #show: underline.with(
            stroke: theme.colors.info + theme.layout.borderWidth.large,
          )
          all mouth and no trousers
        ]
        set text(size: 24pt, fill: theme.colors.border)
        place(top + center, dy: -1.25cm, dx: -5cm, rotate(
          -90deg,
          sym.arrow.long.squiggly,
        ))
      })
    })),
    apply("live-demo", it => box({
      // Live Demo
      it
      place(left + top, dx: -5mm, dy: -4mm, {
        show: rotate.with(-3deg)
        ellipse(
          width: 4cm,
          height: 2em,
          stroke: catppuccin-accents.red + theme.layout.borderWidth.large,
        )
      })
    })),
  ),
)
//

// Benchmark Dataset
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Benchmark Dataset
    #v(1cm)


    // 1000 Realistic Operation Cases with 12 Utterances each, including irrelevant small talk.
    // LLM generated with expected Output State.

    // (Abgerundete Ecke unten links / Ast-Ende)
    // • ╭ (Ecke oben links)
    // • ├ (Abzweigung)
    // • │ (Vertikale Linie)
    // • ─

    #{
      grid(
        columns: (1fr, 2fr),
        {
          set text(size: 18pt)
          [Scenarios]
          show: tag.with("scenario-list")
          set text(size: 24pt)
          let scenario-item(cont) = {
            show: strong
            cont
          }
          grid(
            columns: 1,
            row-gutter: 1cm,
            {
              show: tag.with("scenario-appendectomy")
              scenario-item[Appendectomy]
            },
            {
              show: tag.with("scenario-hernia-repair")
              scenario-item[Hernia Repair]
            },
            {
              show: tag.with("scenario-fundoplication")
              scenario-item[Fundoplication]
            },
            {
              show: tag.with("scenario-cholecystectomy")
              scenario-item[Cholecystectomy]
            },
            {
              show: tag.with("scenario-sleeve-gastrectomy")
              scenario-item[Sleeve Gastrectomy]
            },
          )
        },
        {
          set align(center)
          show: tag.with("llm-generation")
          show: box
          {
            set align(center)
            show: text.with(size: 26pt)
            show: strong
            [🤖]
            show: tag.with("llm")
            linebreak()
            [inclusionai/ling-3.0-flash-vl]
          }
          {
            {
              show: tag.with("sample-case-arrow")
              set text(size: 32pt)
              sym.arrow.b
            }
            parbreak()
            show: tag.with("sample-case")
            show: box
            show: align.with(left)
            show list: treet.tree-list.with(
              marker: "├─",
              indent: "│ ",
              last-marker: "╰─",
              marker-font: "JetBrains Mono",
            )
            set text(size: 18pt, font: theme.fonts.sans.family)

            [
              #let label-box(cont) = {
                show: box.with(width: 2cm)
                show: highlight.with(
                  radius: theme.layout.radius.small,
                  fill: theme.colors.info,
                  extent: 2mm,
                  bottom-edge: -0.3em,
                  top-edge: 0.9em,
                )
                set text(fill: theme.colors.surface)
                cont
              }
              #tag("case-label")[#strong[Case] `appendectomy`]\
              #tag("case-1")[
                - #label-box("noise") "Alright, the patient is sleeping tightly"
              ]
              #tag("case-2")[
                - #label-box("real") "Lets start the insufflator.
                  Put flow at 6 l/m"
                  - New State: `{"insufflator_flow": 6, ...}`
              ]
              #tag("case-further")[- #h(1mm) #sym.dots.v #h(5mm) #sym.times 10]
            ]
          }
        },
      )
    }


  ],
  controls: (
    (
      apply("scenario-list"),
      ..(
        "scenario-appendectomy",
        "scenario-hernia-repair",
        "scenario-fundoplication",
        "scenario-cholecystectomy",
        "scenario-sleeve-gastrectomy",
      ).map(apply),
    ),
    (
      apply(
        "scenario-appendectomy",
        underline.with(
          stroke: theme.colors.accent + theme.layout.borderWidth.large,
        ),
        strong,
      ),
      clear("scenario-list"),
    ),
    (
      apply("llm", underline.with(
        stroke: theme.colors.accent + theme.layout.borderWidth.large,
      )),
      apply("llm-generation"),
    ),
    (
      apply("sample-case"),
      clear("llm"),
      apply("case-label"),
      apply("sample-case-arrow"),
    ),
    apply("case-1"),
    apply("case-2"),
    apply("case-further"),
    (
      clear("scenario-appendectomy"),
      apply("sample-case", it => context {
        let prev-text-size = text.size
        set text(size: 24pt)
        math.underbrace(
          {
            set text(size: prev-text-size)
            show: pad.with(bottom: 1cm)
            it
          },
          {
            set text(fill: theme.colors.accent)
            show: math.bold
            $times 1000$
          },
        )
      }),
    ),
  ),
)

#import "components/field-f1-chart.typ": field-f1-chart

// Latency and Overall Accuracy
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Results
    #[
      #set text(size: 18pt)
      Overall Usability
    ]

    #{
      set align(center + horizon)
      show: tag.with("overview-results-table")
      show: scale.with(150%, reflow: true)
      overview-results-table()
    }
    #v(1cm)
  ],
  controls: (
    (apply("overview-results-table", hide-table.with(cols: (2,)))),
    (clear("overview-results-table")),
    (
      apply("overview-results-table", it => {
        show table.cell.where(x: 1, y: 0): underline.with(
          stroke: theme.colors.accent + theme.layout.borderWidth.medium,
          offset: 1.5mm,
        )
        it
      })
    ),
  ),
)

// Field Results
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Results
    #[
      #set text(size: 18pt)
      Field F1 Scores
    ]
    #z.set-num(round: (precision: 3))
    #v(1fr)
    #field-f1-chart(interactive: true, tag: tag)
  ],
  controls: (
    apply("diagram"),
    apply("diagram", "with-jevk5"),
  ),
)

// Chapter: Outlook and Discussion
#scene(
  tag => [
    #show: focus-slide.with(fill: white.transparentize(100%))
    #chapter-intro-slide(description: [You tell me!])[
      Outlook?
    ]
  ],
  controls: (),
)
// Pending improvements (Calibrated Confidence Gating, Finetuning, Better Hardware) => Discussion
#let color-cycle = (
  catppuccin-accents.blue,
  catppuccin-accents.green,
  catppuccin-accents.yellow,
  catppuccin-accents.mauve,
)
#scene(
  tag => [
    #show: card-slide-mod
    #show: focus-slide
    #set align(left + top)
    == Discussion
    #v(1cm)
    #set text(size: 38pt)

    #set enum(numbering: n => {
      set text(fill: color-cycle.at(calc.rem(n - 1, color-cycle.len())))
      show: strong
      [#n\.]
    })
    #tag("improvements")[+ Ways for Improvement?]
    #tag("local-hosting")[+ Local Hosting and Privacy?]
    #tag("system-one")[+ Other Applications for System-One?]
    #tag("conclusion")[+ Any Further Questions?]
  ],
  controls: (
    (apply("improvements", strong)),
    (apply("local-hosting", strong), clear("improvements")),
    (apply("system-one", strong), clear("local-hosting")),
    (apply("conclusion", strong), clear("system-one")),
  ),
)
