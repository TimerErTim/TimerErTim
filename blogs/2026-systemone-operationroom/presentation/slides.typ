#import "../deps.typ": cz, datify
#import "../../common/theming.typ": theme
#import "../../common/presentation.typ": apply, scene
#import "../../common/components/callouts.typ": callout-block
#import "../../common/components/slides.typ": focus-slide

#let chapter-intro-slide(
  description: "",
  title,
) = {
  show heading: upper
  set text(size: 24pt)

  callout-block(color-val: theme.colors.accent, heading: heading(
    title,
    depth: 1,
  ))[

    #set text(size: 18pt, fill: theme.colors.accent)
    #show: strong
    #description
  ]
}
