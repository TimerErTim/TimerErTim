#import "../deps.typ": sj
#import "../theming.typ": theme
#import "depth.typ": depth-shadow-block
#import "../presentation.typ": (
  _presentation_handout, _presentation_randomness_seed,
)

#let _rotation-for-slide(seed, page) = {
  let rng = sj.gen-rng(seed * page)
  let sample
  (rng, sample) = sj.uniform(rng, low: -1.0, high: 1.0)
  let num = 1.0 - calc.abs(sample)
  num = if sample > 0.0 { num } else { -num }
  return num * 1.5deg
}

#let _numbered-slide(
  page-number: auto,
  margin: 5mm,
  cont,
) = {
  cont
  {
    show: place.with(right + bottom, dx: -margin, dy: -margin)
    set text(fill: theme.colors.muted)
    if page-number == auto {
      counter(page).display("1")
    } else [#page-number]
  }
}

#let _main-slide-primitive(
  cont,
  page-number: auto,
  fill: theme.colors.surface,
  inset: 1cm,
) = {
  show: box.with(width: 100%, height: 100%, fill: fill, inset: inset)
  show: align.with(center)
  show: _numbered-slide.with(page-number: page-number, margin: 5mm - inset)
  cont
}

#let _card-slide-primitive(cont, rotation: 0deg) = {
  show: rotate.with(rotation)
  show: scale.with(92.5%, reflow: false)
  show: depth-shadow-block.with(
    fill: white.transparentize(100%),
    inner-border: theme.layout.borderWidth.medium,
  )
  cont
}

#let card-slide-mod(cont) = context {
  if not _presentation_handout.get() {
    range(
      counter(page).get().first(),
      counter(page).final().first(),
      inclusive: true,
    )
      .chunks(5)
      .first()
      .slice(1)
      .map(page => {
        show: _card-slide-primitive.with(
          rotation: _rotation-for-slide(
            _presentation_randomness_seed.get(),
            page,
          ),
        )
        show: _main-slide-primitive.with(page-number: page)
        []
      })
      .enumerate()
      .rev()
      .map(((idx, it)) => {
        idx = idx + 1
        place(horizon + center, it, dx: idx * 3%, dy: idx * 1%)
      })
      .join([])
  }

  show: if not _presentation_handout.get() {
    _card-slide-primitive.with(rotation: _rotation-for-slide(
      _presentation_randomness_seed.get(),
      counter(page).get().first(),
    ))
  } else { it => it }
  cont
}

#let focus-slide(cont, fill: theme.colors.surface) = context {
  show: _main-slide-primitive.with(fill: fill)
  cont
}

#let full-slide(body, fill: theme.colors.surface) = context {
  show: _main-slide-primitive.with(fill: fill, inset: 0cm)
  body
}
