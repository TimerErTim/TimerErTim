// Accroding to GitHub recommendations
#set page(
  width: 640pt,
  height: 320pt,
  margin: 40pt,
  fill: white
)

#import "../../look-and-feel/index.typ": themes

#set align(center + horizon)
#set page(
  background: {
    place( box(width: 100%, height: 100%, fill: gradient.radial(
    white.transparentize(100%),
    themes.light.surface,
    themes.light.info.transparentize(50%),
    themes.light.accent.transparentize(100%),
    white.transparentize(100%),
    center: (0%, 0%)
  )))
  place( box(width: 100%, height: 100%, fill: gradient.radial(
    white.transparentize(100%),
    themes.light.surface,
    themes.dark.accent.transparentize(100%),
    themes.light.overlay,
    white.transparentize(100%),
    center: (100%, 100%)
  )))
  }
)
#{
  image("../identity/banner.png", width: 70%)
}

#set text(fill: black, font: themes.fonts.sans.family, size: 22pt)
#set par(spacing: 0.5em)

#line(length: 100%, stroke: black)
#v(-0.8em)
== Monorepo for Tim Peko's\ professional and artistic identity
#line(length: 100%, stroke: black)
#set text(size: 16pt)
#v(6pt)
Here you will find all that coverns my internet identity. Interesting projects, a little bit about myself and cursed misuse of technology.
