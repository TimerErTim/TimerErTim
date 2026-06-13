#import "../common/components/xhtml.typ": xhtml
#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, theme
#import "../common/deps.typ": codly, local as codly-local, strfmt
#import "../common/components/callouts.typ": (
  danger-callout, info-callout, success-callout, warning-callout,
)
#import "../common/components/pikchr.typ": color-to-pikchr, pikchr
#import "../common/variants.typ": broader-than, hide-in-preview, web-or
#import "deps.typ": conch, sj

#set text(lang: "en")
#set document(
  title: "Writing a static blog with Typst",
  description: "Let's dive into the world of Typst and see how we can use it to power this very blog website. We will investigate potential solutions, the custom build process I settled on, and the technologies necessary. For static hosting, highly efficient compression and patching are necessary.\nOr in other words: How to properly misuse Typst for everything.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "SSG",
    "NextJS",
    "mise-en-place",
    "compression",
    "patching",
    "GitHub",
    "Brotli",
    "Vcdiff",
  ),
)
#show: blog-entry.with(
  target: auto,
  created-at: datetime(year: 2026, month: 6, day: 12),
  updated-at: datetime(year: 2026, month: 6, day: 12),
)

#import "deps.typ": fl, lq

#let single(any) = (any,)

= Introduction

Ever since I started programming at around 14 years old I have been fascinated by interactively exploring ideas and finding problems with my mediocre solutions. The projects coming out of that were slowly but almost always for sure forgotten over time, even by myself. In the last few weeks I figured that to be a real shame and that I should start writing down my ideas and solutions to them, especially because technical writing is a skill I enjoy and want to improve.

Because I don't do things by halves, I intend to reignite my online persona *TimerErTim* and use it to cover all these technical/semi-professional aspects of my life. It shall be used as a central point of reference for myself, including videos on #link("https://www.youtube.com/@TimerErTim")[YouTube], career and professional information, as well as (probably very irregular) blog posts on #link("https://timerertim.eu/blog")[my website].

Now, there is one problem: The website does not yet exist. So let's go build it. Let's use #link("https://typst.app/")[Typst] for writing the blog posts.

= Why Typst?

#quote(block: true, attribution: "You probably")[
  *But why not use Markdown or some of the 1000 static site generators out there?*
]

Very good question. There are a few reasons for that, most importantly: *it's boring*.\
Writing code is fun, and with our custom implementation only our imagination#footnote[Unfortunately artistic creativity is none of my strengths] is the limit.

Furthermore, I really enjoy Typst for its capabilities and its simplicity. It is a joy to write, and the results are beautiful. Show me where Markdown can do this:

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
  mandelbrot_width
    / (real_range.at(1) - real_range.at(0))
    * (imag_range.at(1) - imag_range.at(0))
)
#hide-in-preview(lq.diagram(
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
      x / real_range.at(2) * (real_range.at(1) - real_range.at(0))
        + real_range.at(0)
    )),
    range(imag_range.at(2)).map(y => (
      y / imag_range.at(2) * (imag_range.at(1) - imag_range.at(0))
        + imag_range.at(0)
    )),
    (x, y) => iterations(x, y),
  ),
))

The above Mandelbrot set is generated entirely in Typst during document compilation with the following code:

```typ
#lq.diagram(
  title: [Image of @mandelbrot-equation],
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
    linspace(real_range.at(0), real_range.at(1), real_range.at(2)),
    linspace(imag_range.at(0), imag_range.at(1), imag_range.at(2)),
    (x, y) => iterations(x, y),
  ),
)
```

It is very easy to style, and with correct abuse, it can be used to represent the central source of truth for the whole website's look and feel. More on that in @lookandfeel-section.

= The naive approach

With the tool choice being made, my first idea was to use the #link("https://myriad-dreamin.github.io/typst.ts/")[typst-ts] project of the fantastic #link("https://github.com/Myriad-Dreamin")[Myriad-Dreamin] to create a React component that would render the blog post. It is a fantastic tool specifically designed for responsive embedding of Typst documents in web applications.

#{
  show: figure.with(
    caption: [Proposal process for embedding a Typst document in a website],
  )
  show: rect.with(inset: (left: -1em))
  pikchr(
    ```pikchr
    fill = $base
    outerheight = 1in
    BUILD: [

      file "main.typ" fit
      arrow
      AR: box "pre-compiled" "artifact"
      box thin width last file.width+0.5in height last file.height+0.25in at last file.center fill $info behind last file
      text "typst-ts-cli" below ljust at last box.nw color $base
    ]
    arrow 1in dashed "deploy" above
    SITEHOST: [
      box "pre-compiled" "artifact"
    ]
    arrow 1in dashed "download" above
    BROWSER: [
      box "pre-compiled" "artifact"
      arrow
      cylinder "Rendered" "in DOM"
      box thin width last cylinder.width+0.5in height last cylinder.height+0.25in at last cylinder.center fill $info behind last cylinder
      text "typst-ts" below ljust at last box.nw color $base
    ]

    color = $base
    box thin width BUILD.width+0.5in height outerheight at BUILD.center fill $warning behind BUILD
    text "GitHub Runner" below ljust at last box.nw

    box same thin width SITEHOST.width+0.5in height outerheight at SITEHOST.center fill $success
    text "GitHub Pages" below ljust at last box.nw

    box same thin width BROWSER.width+0.5in height outerheight at BROWSER.center fill $danger
    text "End User Browser" below ljust at last box.nw


    // /* 02 */ fill = $base
    // /* 03 */ linewid *= 0.5
    // /* 04 */ circle "C0" fit
    // /* 05 */ circlerad = previous.radius
    // /* 06 */ arrow
    // /* 07 */ circle "C1"
    // /* 08 */ arrow
    // /* 09 */ circle "C2"
    // /* 10 */ arrow
    // /* 11 */ circle "C4"
    // /* 12 */ arrow
    // /* 13 */ circle "C6"
    // /* 14 */ circle "C3" at dist(C2,C4) heading 30 from C2
    // /* 15 */ arrow
    // /* 16 */ circle "C5"
    // /* 17 */ arrow from C2 to C3 chop
    // /* 18 */ C3P: circle "C3'" at dist(C4,C6) heading 30 from C6
    // /* 19 */ arrow right from C3P.e
    // /* 20 */ C5P: circle "C5'"
    // /* 21 */ arrow from C6 to C3P chop
    // /* 22 */ box height C3.y-C2.y \
    // /* 23 */     width (C5P.e.x-C0.w.x)+linewid \
    // /* 24 */     with .w at 0.5*linewid west of C0.w \
    // /* 25 */     behind C0 \
    // /* 26 */     fill $sky thin color $border
    // /* 27 */ box same width previous.e.x - C2.w.x \
    // /* 28 */     with .se at previous.ne \
    // /* 29 */     fill $teal
    // /* 30 */ text "trunk 🫶" below at 2nd last box.s
    // /* 31 */ text "feature branch" above at last box.n
    ```.text,
  )
}

The document is then rendered on the client side by the browser using the `typst-ts` wasm binary... or so I thought.

#image("assets/you-dont-say.png", width: 20%, alt: "You don't say!?!")

Turns out we have problems embedding HTML content in Typst and responsiveness is not really responding. HTML content is important because it allows us to do things like#web-or[:
  #xhtml(```html
  <iframe data-testid="embed-iframe" src="https://open.spotify.com/embed/track/7mixpZVqU8AWHvSqOL0wKy?utm_source=generator&amp;si=156c406b2fff4d4a" width="512" height="352" frameBorder="0" allowfullscreen="true" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>
  ```, outer-width: 50%, inner-height: 352pt, inner-width: 512pt)
][
  embedding an iframe of a totally unrelated Spotify track.
]

So naturally continuing the search, I dug into #link("https://github.com/Myriad-Dreamin/shiroa")[shiroa]'s source code, because as a static site generator using only Typst it was exactly covering my use case. Probably a skill issue, but I could not figure out why the _typst-ts_ integration worked beautifully there but not in my own project. It used a similar precompilation process, but the browser rendering was way more low-level and, for me, read like

#{
  show raw: set text(font: "minecraft enchantment")
  show: codly-local.with(number-format: it => [
    #set text(font: theme.fonts.sans.family)
    #numbering("1", it)
  ])
  let rng = sj.gen-rng(42)
  let sizes
  let prefixes
  (rng, sizes) = sj.uniform(rng, low: 10, high: 30, size: 3)
  (rng, prefixes) = sj.uniform(rng, low: 0, high: 2, size: 3)
  sizes = sizes.map(it => int(calc.round(it)))
  prefixes = prefixes.map(it => "    " * int(it))
  let text = lorem(sizes.sum())
  let lines = ()
  let covered-chars = 0
  for (size, prefix) in array.zip(sizes, prefixes) {
    let line = prefix + text.slice(covered-chars, covered-chars + size)
    covered-chars += size
    lines.push(prefix + line)
  }
  raw(block: true, lines.join("\n"))
}

So, without further ado, a custom implementation it is.

= Doing it ourselves

#image("assets/thanos-diy.png", width: 50%)

== Create embeddable SVG documents

Fortunately, the `typst-ts-cli` CLI has a `--format` option that allows us to export the document as an *HTML* page with the whole content rendered as a single *interactive*#footnote[Text selection, navigation to headings, etc.] SVG. A script simply yoinks that out for us.

#codly(
  ranges: ((none, 5), (30, none)),
  highlighted-lines: (1, 2, 3, 30, 31),
  highlighted-default-color: color.mix(
    (theme.colors.danger, 50%),
    (theme.colors.base, 50%),
  ),
  annotations: (
    (
      start: 4,
      end: 6,
      content: [
        #show: rotate.with(-90deg)
        YOINK!
      ],
    ),
  ),
  annotation-format: none,
)
```html
<!DOCTYPE html>
<html lang="en">
  <body>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 600 330"
      width="100%"
      height="auto"
    >
      <rect width="600" height="330" fill="#181825"/>
      <ellipse cx="400" cy="165" rx="60" ry="120" fill="#f5c2e7" opacity="0.3"/>
      <ellipse cx="200" cy="165" rx="100" ry="140" fill="#f5c2e7" opacity="0.3"/>
      <text x="300" y="50" font-size="2em" fill="#d9e0ee" font-family="monospace" text-anchor="middle">
        Mandelbrot SVG (Typst Example)
      </text>
      <g>
        <circle cx="185" cy="160" r="4" fill="#b5e8e0"/>
        <circle cx="237" cy="190" r="5" fill="#f28fad"/>
        <circle cx="290" cy="170" r="8" fill="#96cdfb"/>
        <circle cx="360" cy="150" r="6" fill="#abe9b3"/>
        <circle cx="410" cy="155" r="3" fill="#89dceb"/>
        <circle cx="260" cy="250" r="6" fill="#f8bd96"/>
        <circle cx="325" cy="200" r="5" fill="#f5c2e7"/>
        <circle cx="380" cy="245" r="4" fill="#b5e8e0"/>
      </g>
      <text x="300" y="320" font-size="1.1em" fill="#a6adc8" font-family="sans-serif" text-anchor="middle">
        Example: Computed and styled in Typst, exported as SVG
      </text>
    </svg>
  </body>
</html>
```

Inspecting this extracted SVG reveals how `typst-ts-cli` embeds SVG images in the document #box({
  show raw: it => box(it.lines.at(0).body)
  codly(enabled: false)
  ```typ
  #image(bytes("<svg>Hello, world!</svg>"), format: "svg", alt: "!test-alt")
  ```
  codly(enabled: true)
})

#{
  codly(
    skips: ((1, 10),),
    highlights: (
      (
        line: 11,
        start: 91,
        end: 119,
        tag: "svg",
      ),
    ),
    reference-by: "item",
    header: [Base64 encoded SVG inside `image` tag],
  )

  ```svg
  <image class="typst-image" width="400" height="300" xlink:href="data:image/svg+xml;base64,PHN2ZyB4bWxu...IvPjwvc3ZnPg==" alt="!test-alt"/>
  ```
}

Here, #box(baseline: 2pt, inset: 2pt, stroke: catppuccin-accents.blue, fill: catppuccin-accents.blue.mix((theme.colors.base, 80%)))[svg] is the base64 encoded SVG content. Decoding it reveals our original SVG content: `<svg>Hello, world!</svg>`. Amazing!

A second pass script replaces all occurrences of the `<image>` tag with a specific `alt="!typst-embed-command"` with the base64 decoded SVG content. Now we can precisely control the XML (and by extension HTML) content in our document, ready to embed in the website as normal SVG.

For example #web-or[the spotify embed above was][embedding the totally unrelated Spotify track mentioned earlier could be] accomplished by this code:

#raw(block: true, lang: "typ", strfmt(
  ```typ
  #xhtml({triplequote}html
  <iframe data-testid="embed-iframe" src="https://open.spotify.com/embed/track/7mixpZVqU8AWHvSqOL0wKy?utm_source=generator&amp;si=156c406b2fff4d4a" width="100%" height="352" frameBorder="0" allowfullscreen="true" allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" loading="lazy"></iframe>
  {triplequote})
  ```.text,
  triplequote: "```",
))

where `xhtml` is a helper function handling conversion to SVG's `foreignObject` tag, sizing, etc.

== Embed in website responsively <responsive-embedding>

How to embed fixed size content in a variable width container, like the web browser? Easy fix: Generate multiple width variants of the same document, distribute them and have the browser decide which one to display.

#{
  show: figure.with(
    caption: [Bundling multiple variants of the blog post with differing widths; the client side browser decides which one to display],
  )
  show: rect.with(inset: (left: -1em))
  pikchr(
    ```pikchr
    fill = $base
    outerheight = 2.75in
    BUILD: [
      BUILD_PROCESS: [
        file "main.typ" fit
        arrow
        BUILD_AR2: file "SVG" "width 1088pt" fit
        BUILD_AR1: file "SVG" "width 722pt" at 2cm below BUILD_AR2 fit
        BUILD_AR3: file "SVG" "width 456pt" at 2cm above BUILD_AR2 fit
        arrow from first file to BUILD_AR1 chop
        arrow from first file to BUILD_AR3 chop
      ]
      box thin width BUILD_PROCESS.width+0.5in height BUILD_PROCESS.height+0.25in at BUILD_PROCESS.center fill $info behind BUILD_PROCESS
      text "blog compilation" below ljust at last box.nw color $base
      BUILD_BUNDLE: box "HTML bundle" at 2cm right of BUILD_PROCESS.e
      arrow from BUILD_PROCESS.BUILD_AR2 to BUILD_BUNDLE chop
      arrow from BUILD_PROCESS.BUILD_AR1 to BUILD_BUNDLE chop
      arrow from BUILD_PROCESS.BUILD_AR3 to BUILD_BUNDLE chop
    ]
    move; move;
    SITEHOST: [
      BUNDLE: box "HTML bundle"
    ]
    arrow dashed from BUILD.BUILD_BUNDLE to SITEHOST.BUNDLE "deploy" above chop

    move 4cm;
    BROWSER: [
      BUNDLE: box "HTML bundle"
      move;
      BUILD_PROCESS: [
        BUILD_AR2: box "SVG" "width 1088pt" fit
        move; DOM: cylinder "Rendered" "in DOM"
        BUILD_AR1: box "SVG" "width 722pt" at 2cm below BUILD_AR2 fit
        BUILD_AR3: box "SVG" "width 456pt" at 2cm above BUILD_AR2 fit

        arrow dashed from BUILD_AR2 to DOM chop
        arrow dashed from BUILD_AR1 to DOM chop
        arrow from BUILD_AR3 to DOM chop color $foreground "Browser Width" aligned above "512pt" aligned above
      ]
      arrow from BUNDLE to BUILD_PROCESS.BUILD_AR1 chop
      arrow from BUNDLE to BUILD_PROCESS.BUILD_AR2 chop
      arrow from BUNDLE to BUILD_PROCESS.BUILD_AR3 chop

      box thin width BUILD_PROCESS.width+0.5in height BUILD_PROCESS.height+0.25in at BUILD_PROCESS.center fill $info behind BUILD_PROCESS
      text "React content ingestion" below ljust at last box.nw color $base
    ]
    arrow dashed from SITEHOST.BUNDLE to BROWSER.BUNDLE chop

    color = $base
    box thin width BUILD.width+0.5in height outerheight at BUILD.center fill $warning behind BUILD
    text "GitHub Runner" below ljust at last box.nw

    box same thin width SITEHOST.width+0.5in height outerheight at SITEHOST.center fill $success
    text "GitHub Pages" below ljust at last box.nw

    box same thin width BROWSER.width+0.5in height outerheight at BROWSER.center fill $danger
    text "End User Browser" below ljust at last box.nw
    ```.text,
  )
}

We can use the exact same concept for light and dark variants. Now, informing Typst about the target width is as easy as

#codly(header: [blog/main.typ])
```typ
#let web-page-width = sys.inputs.at("x-page-width", default: none)

#set page(
  width: eval(web-page-width),
  height: auto,
  fill: white.transparentize(100%),
  margin: 0pt,
)
```

and compiling the document with `typst-ts-cli --input "x-page-width=456pt" main.typ` for a width of 456pt.

== Squeeze the bytes out of the payload <payload-compression>

#let typical-svg-size_mb = 3
#let theme-variants = 2
#let size-variants = 6
#let total-payload-size_mb = (
  size-variants * theme-variants * typical-svg-size_mb
)
#danger-callout(
  heading: [$#size-variants "Size variants" times #theme-variants "Theme variants" times underbrace(
    #typical-svg-size_mb "MB", #{
      show: box.with(height: 1em)
      place(center)[typical size]
    }
  ) "content SVG size" = underline(bold(#calc.round(total-payload-size_mb) "MB" "bundle payload"))$],
)[
  Hell NO! Every user has to download this payload *for every visit*!
  We need to heavily compress this ASAP.

  Luckily, since the content of all variants stays the same, we can heavily rely
  on *delta compression* by choosing a single reference variant and for all others
  calculating the difference to the reference and transmitting that instead.
]

We will heavily utilize *Brotli* compression because it has great compression ratios, is very fast to decompress and works directly in the browser. It is also easily available with bindings for many programming languages we will require during the build process.

#info-callout(heading: [*Brotli* supports delta compression!])[
  #{
    show: figure.with(
      caption: [Dictionary compression in *Brotli* \[#link("https://www.annalytic.com/")[Anna Monus], #link("https://www.debugbear.com/blog/shared-compression-dictionaries")\]],
    )
    image("assets/dictionary_compression.png")
  }

  Modern versions of *Brotli* support dictionary compression, which is a technique that can greatly improve the compression ratio of the compressed data by providing a shared dictionary of common data to compress against.

  ...or in other words: *A reference variant very similar to the other variants!*

  Our reference variant is the dictionary we use for compression and require for decompression.
]

The reference variant is compressed without any delta compression: 2.4 MB #sym.arrow *866 KB*. Not that bad! A simple build script using NodeJS's *zlib* should handle all the delta compression for us. And indeed, compression ratios are insane now, with delta compressed variants only taking up *2 KB* each.

== Not so fast young man!

Let's go ahead and implement decompression and DOM node ingestion on the browser side. Simple enough, add a corresponding package, implement variant selection and...

#{
  show: rect
  set text(fill: theme.colors.danger)
  codly(enabled: false)
  ```
    791 |               const wordLength = this.copyLength;
    792 |               if (wordLength > 31) {
  > 793 |                 throw new BrotliDecoderAllocRingBuffer1Error(
        |                       ^
    794 |                   "Invalid backward reference",
    795 |                 );
    796 |               } (app/error.tsx:15:13)
  ```
  codly(enabled: true)
}

*F\*\*\*\*K!*

#warning-callout(
  heading: [Browser-side *Brotli* dictionary support is limited],
)[
  I am sure this is partially a user error, but it turns out *zlib*'s dictionary support is more flexible than the browser-side *Brotli* decoder.

  Using the _cleartext_ reference SVG variant as dictionary
  - in *zlib* for compression #text(fill: theme.colors.success)[#sym.checkmark works]
  - in the browser-side *Brotli* decoder #text(fill: theme.colors.danger)[#sym.crossmark does not]

  We'd need to preprocess the dict for browser usage somehow.
]

After not figuring it out for one day, I abandoned this concrete approach. I already have a backup idea in mind: Use the same delta compression algorithm as *Git*... *VCDIFF*!

== VCDIFF to the rescue!

Instead of relying on *Brotli*'s dictionary support, we can use *VCDIFF* to create delta patches between the reference variant and the other variants, and then use *Brotli* to compress the delta patches.

#grid(
  columns: broader-than(560pt, (2fr, auto, 3fr), 1),
  gutter: 1em,
  align: broader-than(560pt, top, center),
  {
    show: figure.with(caption: [Naive *Brotli* dictionary approach])
    show: rect.with(width: 100%)
    ```show-pikchr
    file "reference" "SVG" fit color $accent
    arrow
    box "Brotli" "dictionary" "compression" fit
    arrow
    cylinder "Compressed" "Artifact" fit
    file "variant 1" "SVG" at 1in below first file same as first file color $foreground
    arrow from last file to first box.sw chop
    file "variant 2" "SVG" at 1in below first box same as first file color $muted
    arrow dashed from last file to first box chop color $muted
    file "variant 3" "SVG" at 1in below first cylinder same as first file color $muted
    arrow dashed from last file to first box chop color $muted
    ```
  },
  grid.cell(align: center + horizon, {
    set text(size: 2em)
    broader-than(560pt, sym.arrow.r, sym.arrow.b)
  }),
  {
    show: figure.with(
      caption: [Compression approach with delta patches from *VCDIFF*],
    )
    show: rect.with(width: 100%)
    ```show-pikchr
    file "reference" "SVG" fit color $accent
    arrow
    box "VCDIFF" "delta compression" fit
    arrow
    box "Brotli" "general-purpose" "compression" fit
    arrow
    cylinder "Compressed" "Artifact" fit
    file "variant 1" "SVG" fit at 1in below first file same as first file color $foreground
    arrow from last file to first box.sw chop
    file "variant 2" "SVG" fit at 1in below first box same as first file color $muted
    arrow dashed from last file to first box chop color $muted
    file "variant 3" "SVG" at 1in below last box same as first file color $muted
    arrow dashed from last file to first box chop color $muted
    ```
  },
)

*VCDIFF* is also great, because there are reliable pure browser-side implementations for decoding it.

#warning-callout(heading: [
  We use *Python* with *uv* in the build scripts for easily reproducible builds.
])[
  Both *open-vcdiff* (Google) and *xdelta3* have Python bindings, but they don't work with the latest Python versions, only at most _3.8_. But getting the latest *uv* version to support Python 3.8 was impossible for me. Sigh...
]

Fortunately, there are up-to-date *xdelta3* bindings for *Rust*, so we quickly write a *PyO3* wrapper around it and use *Maturin* for installing in the script:

#codly(header: [libs/xdelta3/src/lib.rs])
```rs
//! PyO3 bindings for [xdelta3](https://docs.rs/xdelta3/latest/xdelta3/) (VCDIFF).
use ::xdelta3 as xdelta3_rs;

#[pyfunction]
#[pyo3(signature = (reference, target))]
fn encode(reference: &[u8], target: &[u8]) -> PyResult<Vec<u8>> {
    xdelta3_rs::encode(target, reference)
        .ok_or_else(|| PyValueError::new_err("xdelta3 encode failed"))
}

#[pyfunction]
#[pyo3(signature = (reference, patch))]
fn decode(reference: &[u8], patch: &[u8]) -> PyResult<Vec<u8>> {
    xdelta3_rs::decode(patch, reference)
        .ok_or_else(|| PyValueError::new_err("xdelta3 decode failed"))
}

#[pymodule]
fn xdelta3(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(encode, m)?)?;
    m.add_function(wrap_pyfunction!(decode, m)?)?;
    Ok(())
}
```

That's all there is to it. We can set this required dependency in *uv* scripts using the frontmatter:

#codly(skips: ((12, 10), (17, 1)))
```py
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "xdelta3",
# ]
#
# [tool.uv.sources]
# xdelta3 = { path = "../../../libs/xdelta3" }  # Path from this file's directory
# ///
import xdelta3

with open(filename, "rb") as f:
  file_bytes = f.read()

delta_bytes = xdelta3.encode(reference_bytes, file_bytes)

```

And now, finally, after almost no hassle at all, the build process is complete! The client side decompression and rendering works as evidenced by you reading this.

*Stats*\
#conch.terminal-frame(
  width: 100%,
  theme: "catppuccin",
  font: theme.fonts.mono.family,
  title: [static files @ out/blog/2026-blog-with-typst/],
)[
  #show: pad.with(top: -1em)
  #conch.render-ansi(
    read("assets/eza_dist_output.txt"),
    theme: "catppuccin",
  )
]

We managed to squeeze all variants, content, scripts, ... into a single *3 MB* HTML payload!

#info-callout(heading: [What this *3 MB* includes])[
  While still quite a lot for a single webpage, it is one hell of an improvement over the original #total-payload-size_mb MB we would need uncompressed. And remember, this single HTML payload delivers everything for
  - every theme variant
  - every size variant
  - every script needed for interactivity
  - every 3rd party content such as images
  - injecting the content into DOM
  - the normal webpage content besides the blog entry
]

= How does ... work?

If that question is floating around in your head, you can look around this chapter for answers.

== PDF download

When you click the "download" button on the website, the browser fetches a precompiled PDF version of this blog post.

#codly(header: [Blogpost Styling: Either web optimized or PDF optimized])
```typ
#let targets-web = sys.inputs.at("x-target", default: "classic") == "web"

#let web-or(
  web-variant,
  classic-variant,
) = if targets-web {
  web-variant
} else {
  classic-variant
}

#show: web-or(
  web-template,
  pdf-template,
)
```

The build process injects the correct `#sys.inputs` for the correct artifact type, same as in @responsive-embedding.

== Centralized look and feel <lookandfeel-section>

Because everything is organized as a monorepo, we can define a central file for the colors of our look and feel:

#codly(header: [colors.typ])
```typ
#let colors = (
  "light": (
    "base": oklch(98%, 1%, 265deg),
    "foreground": oklch(44%, 4%, 279deg).darken(50%),
    "accent": rgb("#62a123").oklch(),
    "neutral": oklch(86%, 1%, 268deg),
    "surface": oklch(93%, 1%, 265deg),
    "overlay": oklch(91%, 1%, 265deg),
    "border": oklch(71%, 2%, 275deg),
    "danger": oklch(55%, 22%, 20deg),
    "warning": oklch(71%, 15%, 68deg),
    "success": oklch(63%, 18%, 140deg),
    "info": oklch(68%, 14%, 235deg), // Info is also used for links
  ),
  "dark": (
    "base": oklch(18%, 2%, 284deg),
    "foreground": oklch(88%, 4%, 272deg).lighten(50%),
    "accent": rgb("#426E17").oklch(),
    "neutral": oklch(40%, 3%, 280deg),
    "surface": oklch(22%, 3%, 284deg),
    "overlay": oklch(24%, 3%, 284deg),
    "border": oklch(55%, 3%, 277deg),
    "danger": oklch(76%, 13%, 3deg),
    "warning": oklch(92%, 7%, 87deg),
    "success": oklch(86%, 11%, 143deg),
    "info": oklch(85%, 8%, 210deg), // Info is also used for links
  ),
)
```

These are combined with layout and font definitions into `themes`, which in turn is imported by this very blog entry.

#info-callout(heading: [Exporting for third party consumption])[
  #codly(header: [export.typ])
  ```typ
  #metadata(
    (themes,).map(_convert-to-js-units).map(_convert-to-hex-colors).first(),
  ) <themes>
  ```

  This metadata field converts all units in our data structure to standard units and exposes them to third-party tools, such as our build tool:

  #codly(enabled: false)
  ```bash
  typst query export.typ "<themes>" --field value --one --pretty > themes.json
  ```
  #codly(enabled: true)
]

The website build pipeline takes these theme values and generates a CSS file, defining the whole look and feel of the website:

#codly(header: [website/tasks/scripts/generate-theme.mjs])
#codly(skips: ((17, 8),))
```js
const css = `/* Generated from look-and-feel/themes.json — do not edit */
:root,
.light {
${themeVars(themes.light)}
}

.dark {
${themeVars(themes.dark)}
}

@theme inline {
  --color-background: var(--theme-base);
  --color-foreground: var(--theme-foreground);
  --color-accent: var(--theme-accent);
  --color-muted: var(--theme-muted);
  --color-surface: var(--theme-surface);
  --leading-large: ${layout.lineHeight.large}px;

  --radius-sm: ${layout.radius.small}px;
  --radius-md: ${layout.radius.medium}px;
  --radius-lg: ${layout.radius.large}px;
}
`;
writeFileSync("src/app/theme.generated.css", css);
```

#info-callout(heading: [You can use imports with PostCSS!])[
  #codly(header: [website/src/app/globals.css], skips: ((3, 100),))
  ```css
  @import "tailwindcss";
  @import "./theme.generated.css";

  ```

  Tailwind registers the generated CSS file and uses the theme variables in its config.
]

= Potential improvements

The solution is not yet perfect. While pretty much fully functional, there are things left to improve.

== Remove iframe reloading upon resize
Because we actually insert a new DOM child and remove the previous one upon resize, the iframe is considered to be different by the browser, which causes a reset of its state, effectively canceling any ongoing playback.

#grid(
  columns: broader-than(560pt, (1fr, auto, 1fr), 1),
  gutter: 1em,
  align: broader-than(560pt, horizon, center),
  {
    show: figure.with(caption: [Playing YouTube video before resize])
    show: rect.with(inset: 0pt)
    image("assets/prereload-downsized.png")
  },
  {
    set text(size: 2em)
    broader-than(560pt, sym.arrow.r, sym.arrow.b)
  },
  {
    show: figure.with(caption: [Thumbnail after resize])
    show: rect.with(inset: 0pt)
    image("assets/postreload-downsized.png")
  },
)

== More Website integration
The current solution only writes the following metadata to the filesystem during the export process:

#codly(skips: ((9, 5),))
```json
{
  "author": [
    "Tim Peko (TimerErTim)"
  ],
  "title": "Writing a static blog with Typst",
  "description": "Let's dive ... Typst for everything.",
  "keywords": [
    "Typst",
    "Brotli",
    "Vcdiff"
  ]
}
```

NextJS is therefore unable to include any complex content in the description of the blog post, such as images or videos.

== Better compression
Even though the current solution is already pretty efficient, there is still room for improvement. We could, for example, search for the best reference variant for each possible target variant and then store what reference was used for every individual target variant. This is not trivial, because we need to prevent cyclic references. Imagine the following situation:

#{
  show: figure.with(
    caption: [Cyclic delta compression references: Files represent delta patches, cylinders represent only brotli compressed full variants.],
  )
  show: box.with(width: 60%)
  ```show-pikchr
  file "delta" "variant 1" fit color $sky
  right; move;
  up; move;
  file "delta" "variant 2" fit color $mauve
  arc -> from first file.e down 1cm to last file.s "references" ljust below
  arc -> from last file.w down 1cm to first file.n "references" rjust above
  down; move;
  right; move; move; move;
  file "delta" "variant 3" fit color $red
  arrow 2cm "references" above
  cylinder "brotli" "variant 0" fit color $accent
  up; move;
  file "delta" "variant 4" fit color $rosewater
  arrow from last file.sw to 2nd last file.ne "references" above rjust
  ```
}

Here a primitive algorithm would see #text(fill: catppuccin-accents.sky)[variant 1] has the best compression ratio delta compressing against #text(fill: catppuccin-accents.mauve)[variant 2] as reference, and #text(fill: catppuccin-accents.mauve)[variant 2] with #text(fill: catppuccin-accents.sky)[variant 1] as reference. It would compress them both against each other's cleartext, uncompressed format. But now, we can never decompress them again because we have no way to restore the original uncompressed reference for one of these two. #text(fill: catppuccin-accents.red)[variant 3] and #text(fill: catppuccin-accents.rosewater)[variant 4] would work fine since we can trace back the reference hierarchy to #text(fill: theme.colors.accent)[variant 0].

#success-callout(heading: [Let's exploit XML's strict structure])[
  Now we are in Min-Maxing territory.
  We could also utilize an XML optimized compression algorithm like *EXI* to compress the SVG instead of general-purpose compression algorithms like *Brotli*.
  #link("https://svgo.dev/")[SVGO] is a tool that can optimize SVGs for size and performance and could be used in the compression pipeline.

  #danger-callout[
    Our SVGs are currently incompatible with SVGO, so further investigation is necessary.
  ]
]
