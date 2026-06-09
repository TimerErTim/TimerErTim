#import "../../look-and-feel/index.typ": themes

#set page(
  width: 1200pt,
  height: 630pt,
  margin: 80pt,
  fill: white,
  background: {
    place(right + bottom, box(width: 250%, height: 200%, fill: gradient.radial(
      white.transparentize(100%),
      themes.light.surface,
      themes.dark.accent.transparentize(70%),
      themes.light.overlay,
      white.transparentize(100%),
      center: (100%, 100%),
    )))
    place(left + top, box(width: 200%, height: 200%, fill: gradient.radial(
      white.transparentize(100%),
      themes.light.surface,
      themes.light.info.transparentize(50%),
      themes.light.accent.transparentize(100%),
      white.transparentize(100%),
      center: (0%, 0%),
    )))
  }
)

#set align(center + horizon)
#image("../identity/subtitled.png", height: 100%)