#import "../deps.typ": cz, datify
#import "../../common/theming.typ": theme
#import "../../common/presentation.typ": apply, scene
#import "../../common/components/callouts.typ": callout-block
#import "../../common/components/slides.typ": focus-slide


#let stop-sign = {
  cz.canvas({
    import cz.draw: *
    polygon(
      (0, 0),
      8,
      angle: 22.5deg,
      fill: theme.colors.danger,
      stroke: theme.colors.surface + theme.layout.borderWidth.large,
      radius: 64pt * 1.75,
    )
    content((0, 0), [
      #set text(fill: theme.colors.base, size: 64pt)
      #set align(center)
      STOP
    ])
  })
}

#let title-scene(
  date: auto,
) = context {
  let author = document.author.join(", ")
  let description = document.description
  let title = document.title

  scene(
    tag => [
      #show: focus-slide.with(fill: white.transparentize(100%))
      #set strong(delta: 600)

      #{
        show: tag.with("title-block")
        show: box.with(inset: (x: 3cm, y: 2cm), outset: 1cm, clip: false)
        show: callout-block.with(color-val: theme.colors.accent)
        show: align.with(center + top)
        show: box.with(height: 100%, inset: 1.5cm)
        {
          set text(size: 52pt, fill: theme.colors.accent)
          show: upper
          title
        }
        v(-0.75cm)
        {
          set text(size: 20pt, fill: theme.colors.accent)

          description
        }
        let additional-box-style(body) = {
          show: box.with(
            stroke: theme.colors.accent + theme.layout.borderWidth.small,
            inset: 5mm,
            radius: theme.layout.radius.small,
            fill: theme.colors.surface,
          )
          set text(size: 16pt, fill: theme.colors.accent)
          body
        }
        place(bottom + left, dy: 2.5cm, dx: -3cm, {
          show: rotate.with(4deg)
          show: additional-box-style
          show: box.with(width: 3cm, height: 0.8cm)
          set align(top)
          image("../assets/uap_hagenberg.png", height: 3cm, width: 5cm)
        })
        place(bottom + center, dy: 2.5cm, {
          show: rotate.with(-2deg)
          show: additional-box-style
          show: strong
          author
        })
        place(bottom + right, dy: 2.5cm, dx: 2.5cm, context {
          show: rotate.with(2deg)
          show: additional-box-style
          let date = if date == auto {
            document.date
          } else {
            date
          }
          datify.display-date(date, pattern: "medium")
        })
      }
      #place(top + right, {
        show: rotate.with(-3deg)
        stop-sign
      })
    ],
    controls: (
      (),
      apply("title-block"),
    ),
  )
}
