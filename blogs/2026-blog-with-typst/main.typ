#import "../common/components/xhtml.typ": xhtml
#import "../common/template.typ": blog-entry
#import "../common/theming.typ": theme, catppuccin-accents
#import "../common/deps.typ": codly, local as codly-local, strfmt
#import "../common/components/callouts.typ": danger-callout, info-callout, success-callout, warning-callout
#import "../common/components/pikchr.typ": pikchr, color-to-pikchr

#set text(lang: "en")
#set document(
  title: "Writing a static blog with Typst",
  description: "Let's dive into the world of Typst and see how we can use it to power this very blog website. We will investigate potential solutions, the custom build process I settled on and the technologies necessary. For static hosting highly efficient compression and patching is necessary.\nOr in other words: How to proberly misuse Typst for everthing.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "SSG",
    "NextJS",
    "mise-en-place",
    "compression",
    "patching",
    "GitHub",
    "brotli",
    "vcdiff",
  ),
)
#show: blog-entry.with(
  target: auto,
  created-at: datetime(year: 2026, month: 6, day: 11),
  updated-at: datetime(year: 2026, month: 6, day: 11),
)

#import "deps.typ": fl, lq

#let single(any) = (any,)

= Introduction

Ever since I started programming at around 14 years old I have been fascinated by interactively exploring ideas and finding problems to my mediocre solutions. The projects coming out of that were slowly but almost always for sure forgotten over time, even by myself. In the last few weeks I figured that to be a real shame and that I should start writing down my ideas and solutions to them, especially because technical writing is a skill I enjoy and want to improve.

Because I don't do things by halves, I intent to reignite my online persona *TimerErTim* and use it to cover all these technical/semi-professional aspects of my life. It shall be used as a central point of reference for myself, including videos on #link("https://www.youtube.com/@TimerErTim")[YouTube], career and professional information, as well as (probably very unregular) blog posts on #link("https://timerertim.eu/blog")[my website].

Now, there is one problem: The website does not yet exist. So let's go build it. Let's use #link("https://typst.app/")[Typst] for writing the blog posts.

= Why Typst?

#quote(block: true, attribution: "You probably")[
  *But why not use Markdown or some of the 1000 blog static site generators out there?*
]

Very good question. There are a few reasons for that, most importantly: *It's boring*.\
Writing code is fun and with our custom implementation only our imagination#footnote[Unfotunately artistic creativity is none of my strengths] is the limit.

Furthermore, I really enjoy Typst for its capabilities and yet simplicity. It is a joy to write and the results are beautiful. Show me where Markdown can do this:

$ z_(n+1) = z_n^2 + c $ <mandelbrot-equation>

#let mandelbrot-code = ```typc
let iterations(c_r, c_i, max: 100) = {
  let z_r = 0
  let z_i = 0
  for i in range(max) {
    let z_r_next = z_r * z_r - z_i * z_i + c_r
    let z_i_next = 2 * z_r * z_i + c_i
    if z_r_next * z_r_next + z_i_next * z_i_next > 4 {
      return i
    }
    z_r = z_r_next
    z_i = z_i_next
  }
  return max
}

iterations
```

#let iterations = eval(mandelbrot-code.text)

#let real_range = (-2, 0.6, 250)
#let imag_range = (-1, 1, 200)
#let mandelbrot_width = 20em
#let mandelbrot_height = (
  mandelbrot_width / (real_range.at(1) - real_range.at(0)) * (imag_range.at(1) - imag_range.at(0))
)
#lq.diagram(
  title: [Image of @mandelbrot-equation],
  width: 20em,
  height: mandelbrot_height,
  xaxis: (
    label: [
      $c_r$
    ],
  ),
  yaxis: (
    label: [
      #show: rotate.with(90deg)
      $c_i$
    ],
  ),
  lq.colormesh(
    range(real_range.at(2)).map(x => (
      x / real_range.at(2) * (real_range.at(1) - real_range.at(0)) + real_range.at(0)
    )),
    range(imag_range.at(2)).map(y => (
      y / imag_range.at(2) * (imag_range.at(1) - imag_range.at(0)) + imag_range.at(0)
    )),
    (x, y) => iterations(x, y),
  ),
)

The above Mandelbrot set is generated entirely in Typst during document compilation with the following code:

#codly(ranges: ((none, 14),))
#mandelbrot-code

It is very easy to style and with correct abuse can be used to represent the central source of truth for the whole website's look and feel. More on that in @lookandfeel-section.

= The naive approach

With the tool choice being made, my first idea was to use the #link("https://myriad-dreamin.github.io/typst.ts/")[typst-ts] project of the fantastic #link("https://github.com/Myriad-Dreamin")[Myriad-Dreamin] to create a React component that would render the blog post. It is a fantastic tool specifically designed for responsive embedding of Typst documents in web applications.

#pikchr(strfmt(```pikchr
/* 01 */ scale = 0.8
/* 02 */ fill = {base}
/* 03 */ linewid *= 0.5
/* 04 */ circle "C0" fit
/* 05 */ circlerad = previous.radius
/* 06 */ arrow
/* 07 */ circle "C1"
/* 08 */ arrow
/* 09 */ circle "C2"
/* 10 */ arrow
/* 11 */ circle "C4"
/* 12 */ arrow
/* 13 */ circle "C6"
/* 14 */ circle "C3" at dist(C2,C4) heading 30 from C2
/* 15 */ arrow
/* 16 */ circle "C5"
/* 17 */ arrow from C2 to C3 chop
/* 18 */ C3P: circle "C3'" at dist(C4,C6) heading 30 from C6
/* 19 */ arrow right from C3P.e
/* 20 */ C5P: circle "C5'"
/* 21 */ arrow from C6 to C3P chop
/* 22 */ box height C3.y-C2.y \
/* 23 */     width (C5P.e.x-C0.w.x)+linewid \
/* 24 */     with .w at 0.5*linewid west of C0.w \
/* 25 */     behind C0 \
/* 26 */     fill {sky} thin color {border}
/* 27 */ box same width previous.e.x - C2.w.x \
/* 28 */     with .se at previous.ne \
/* 29 */     fill {teal}
/* 30 */ text "trunk 🫶" below at 2nd last box.s// color textcolor
/* 31 */ text "feature branch" above at last box.n// color {foreground}
```.text, base: color-to-pikchr(theme.colors.base), sky: color-to-pikchr(catppuccin-accents.sky.mix(theme.colors.base)), teal: color-to-pikchr(catppuccin-accents.teal.mix(theme.colors.base)), border: color-to-pikchr(theme.colors.border), foreground: color-to-pikchr(theme.colors.foreground)))

#let pikchr-test = pikchr(```
arrow right
circle "C5 🫶"
```.text)

#pikchr-test

#fl.diagram(
  {
    import fl: *
    node(name: <blog-source>)[
      blog.typ
    ]
    edge()
    node(name: <blog-website>)[
      website/
    ]
  }
)

Later I dug into the #link("https://github.com/Myriad-Dreamin/shiroa")[shiora]'s source code, because it being a static site generator using only Typst was exactly covering my usecase. Probably a skill issue but I could not figure out why the _typst-ts_ integration worked beautifully there but not in my own project. It used a similar precompilation process but the browser rendering was way more low level. Anyway, for me it looked something like this:

#{
  show raw: set text(font: "minecraft enchantment")
  show: codly-local.with(number-format: none)
  raw(block: true, {
    "Well done decoding!"
    lorem(29)
  })
}

= Centralize look and feel <lookandfeel-section>

Topic collection:
- Introduction/General Goal
- Why Typst?
- typst-ts react tried, shiora reference, but wtf
- Custom process for creating embeddable svg documents
  + typst-ts-cli build as svg_html
  + replace `<image>` with svg base64 data with decoded svg content inline #sym.arrow allows embedding html content in typst (demo something iframe idk)
- How to make responsive in website
  + Build multiple variants of the same document with different widths and themes
  + Delta compress all of them with custom xdelta3 bindings to arbitary reference
  + Brotli compress the delta patches
  + Store these compressed files as base64 in the static website (handled by server components of NextJS)
  + Decode with fitting browser side decompression library depending on browser div width and theme
- How does PDF download work?
- Centralized look and feel for blogs and website
- Potential room for improvements
  - Remove flickering of iframe content when new size loads
  - More powerful blog description/preview content support, currently onyl metadata string
  - Better compression by comparing all combinations of refs #sym.arrow.l.r target
  - Replace custom update time detection with manual metadata field

Brotli customDictionary compression to python xdelta3 to create a vcdiff patch.
