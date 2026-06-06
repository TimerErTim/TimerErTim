#let is-web = sys.inputs.at("x-target", default: "classic") == "web"
#let web-page-width = sys.inputs.at("x-page-width", default: none)
#let web-theme = sys.inputs.at("x-theme", default: "light")
#import "../common/components/metadata.typ": blog-metadata
#import "../common/components/xhtml.typ": xhtml

#set document(
  title: "Writing a static blog with Typst",
  description: "How this very blog was written with Typst and statically hosting it efficiently with brotli compression and vcdiff patching on GitHub. Or in other words: How to probably misuse Typst for everthing.",
  author: "Tim Peko (TimerErTim)",
  keywords: ("Typst", "SSG", "NextJS", "mise-en-place", "Compression", "Patching", "GitHub", "brotli", "vcdiff"),
)

#blog-metadata()
#set page(
  width: eval(web-page-width),
  height: auto,
  fill: white.transparentize(100%),
  margin: 0pt
) if is-web

#let pro-tip-box(content) = {
  show: box.with(stroke: 1pt + yellow, radius: 0.5em, fill: yellow.lighten(80%), inset: 1em)
  {
    set text(fill: black, font: "JetBrains Mono", size: 1.2em)
    [Protip Box]
  }
  parbreak()
  content
}

#pro-tip-box[
  This is a tip we want to see in our exported document.

  Maybe even html text? #xhtml(```html
  <p>Test from html</p>
  <iframe width="560" height="315" src="https://www.youtube.com/embed/iPo_88PNudI?si=bFFhLu0I2FFMNB-D" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen="true"></iframe>
  ```, outer-width: 100%, outer-height: 315pt, inner-width: 560pt, inner-height: 330pt)
]

#let single(any) = (any,)

#show link: it => {
  set text(fill: blue)
  underline(it)
}

Let's add a #link("https://lilaq.org/")[lilaq] diagram for good measure:\
#import "@preview/lilaq:0.6.0" as lq
#lq.diagram(
  title: [Sample Plot],
  lq.plot(
    range(10),
    x => x * x / calc.exp(x),
    smooth: true
  )
)

Brotli customDictionary compression to python xdelta3 to create a vcdiff patch.