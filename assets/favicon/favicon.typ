#set page(
  width: 256pt,
  height: 256pt,
  fill: white.transparentize(100%),
  margin: 0pt
)

#import "../../look-and-feel/index.typ": themes
#import "../../logo/icon.typ": logo

#set align(center + horizon)
#show: circle.with(
  fill: white,
  inset: -16pt,
)
#image("../identity/icon.png", width: 100%)