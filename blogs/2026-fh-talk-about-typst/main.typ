#import "../common/components/xhtml.typ": xhtml
#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, theme
#import "../common/deps.typ": codly, local as codly-local, strfmt
#import "../common/components/callouts.typ": danger-callout, info-callout, success-callout, warning-callout
#import "../common/components/pikchr.typ": color-to-pikchr, pikchr
#import "../common/variants.typ": light-or, web-or
#import "deps.typ": fl, conch

#set text(lang: "en")
#set document(
  title: "My workshop about Typst for the fhLUG in Campus Hagenberg",
  description: ```
  On June 8th, 2026, I had the wonderful opportunity to lead a Typst workshop for the fh Linux User Group at Campus Hagenberg, made possible by Daniel Knittl-Frank's excellent organization. It was a fantastic experience, with enthusiastic and engaged participants. In this blog post, you'll find highlights from the workshop as well as access to the full recording (German).
  ```.text,
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "Video",
    "Workshop",
    "fhLUG",
    "Campus Hagenberg",
  ),
)
#show: blog-entry.with(
  //target: "web"
)


#let youtube-link = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

If you're primarily interested in the workshop recording (German language only), you'll find the video #web-or(
  [
    just down below:

    #layout(((width, height)) => {
      let outer-width = width
      let outer-height = width / 16 * 9
      // TODO: replace with actual youtube link
      let iframe = strfmt(```html
      <iframe width="{outer-width}" height="{outer-height}" src="https://www.youtube.com/embed/GS978MRbqqo?si=KJ6Y-WodSd6uAKVz" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen="true" ></iframe>
      ```.text, outer-width: outer-width, outer-height: outer-height)
      xhtml(iframe, outer-width: outer-width, outer-height: outer-height, inner-width: outer-width, inner-height: outer-height)
    })
  ],
  [at #link(youtube-link)],
)

= Quick Background

#{
  show: box.with(fill: light-or(none, white), outset: 1pt, radius: 1pt)
  image("assets/fg_lug_logo.png", height: 1em)
} is the #link("https://fhlug.at/")[Linux User Group FH Hagenberg]. They host talks, workshops or simple get togethers roughly once a month to discuss Linux and topics from the open software world.

Daniel Knittl-Frank is the main organizer and head of the group. His support and hassle-free organization allowed me to focus on the content of the workshop. Thank you, Daniel!

= The Workshop

#{
  show: figure.with(caption: "Me after the workshop and snagging a fitting shirt.")
  show: box.with(stroke: theme.colors.border)
  image("assets/base-thumbnail.png", width: 80%)
}

Before jumping into action, we started with a high level overview of document writing and why #link("https://typst.app/")[Typst] stands out. Did you know that you can categorize tools in two categories?

#{
  show: figure.with(caption: [Two types of categories: Word Processors and Typesetting Systems.])
  layout(((width, height)) => {
    show: box.with(stroke: theme.colors.border, clip: true, width: width, height: width / 3.2, inset: (top: -10%))
    show: align.with(center + horizon)
    image(
      "assets/2026_Typst_Hagenberg_TimPeko_Handout_4.svg",
      width: 115%,
      alt: ```
      Comparison of word processors and typesetting systems. On the left: Word Processors - Microsoft Word, Google Docs, What you see is what you get. On the right: Typesetting Systems - LaTeX, Markdown, and Typst. Compiles markup to a document.
      ```.text,
    )
  })
}

The greatest advantage of typesetting is the separation between content and presentation. This allows for a lot of flexibility and reusability. It is literally what powers this blog website in its dark and light theme, as well as making blog posts available for download in a PDF optimized format.

#let cubic-count = 4
Typst enables us to write documents programmatically. For example, let's generate the first #cubic-count cubic numbers:

#{
  set math.equation(numbering: none)
  show: it => {
    $ underbrace(it, #[Not a single cubic number written by hand]) $
  }

  let code = strfmt(
    ```typ
    #for i in range(1, {cubic-count} + 1) [
      $#i^3 = #calc.pow(i, 3)$\
    ]
    ```.text,
    cubic-count: cubic-count,
  )

  grid(
    columns: (1fr, auto, 1fr),
    align: horizon,
    gutter: 1em,
    {
      raw(code, block: true, lang: "typst")
    },
    {
      set text(size: 2em)
      sym.arrow.r
    },
    {
      eval(code, mode: "markup")
    },
  )
}

See that?! We have the power of a full turing complete programming language at our fingertips.

== About Typst

#grid(
  columns: (1fr, auto, auto),
  gutter: 1em,
  [
    The #link("https://github.com/typst/typst")[Typst GitHub Repository] has about *54.1k* stars and *441* Contributors, which is no small achievement at all. Development was initiated by *Martin Haug* and *Laurenz Mädje* in 2019. After 4 years of development they founded an organization in *Berlin*.

    #quote(block: true, attribution: [Typst `README.md`])[
      There are two ways to make something flexible: Have a knob for everything or have a few knobs that you can combine in many ways. Typst is designed with the second way in mind.
    ]
  ],
  {
    show: box.with(width: 2cm)
    show: figure.with(caption: [Martin Haug])
    show: box.with(stroke: theme.colors.border)
    image("assets/martin_haug.webp")
  },
  {
    show: box.with(width: 2cm)
    show: figure.with(caption: [Laurenz Mädje])
    show: box.with(stroke: theme.colors.border)
    image("assets/laurenz-madje.webp")
  },
)

The above quote perfectly captures the philosophy of Typst and lays the foundation for its expressive power.

== Deep Dive

#let holy-trinity-diagram(highlight-section: none) = {
  let distance = 8em
  let radius = 3em
  //show raw: highlight.with(fill: theme.colors.muted, extent: 2pt, top-edge: 1em, bottom-edge: -1em / 3)
  fl.diagram(
    fl.node(
      (90deg, distance),
      [
        #set text(fill: catppuccin-accents.blue)
        #show: strong
        Mark\ up
      ],
      shape: fl.shapes.circle,
      stroke: if highlight-section == "markup" { catppuccin-accents.mauve + 3pt } else {
        theme.colors.foreground + 2pt
      },
      width: radius,
      height: radius,
      name: "markup",
    ),
    fl.node(
      (330deg, distance),
      [
        #set text(fill: catppuccin-accents.green)
        #show: strong
        Math
      ],
      shape: fl.shapes.circle,
      stroke: if highlight-section == "math" { catppuccin-accents.mauve + 3pt } else { theme.colors.foreground + 2pt },
      width: radius,
      height: radius,
      name: "math",
    ),
    fl.node(
      (210deg, distance),
      [
        #set text(fill: catppuccin-accents.red)
        #show: strong
        Code
      ],
      shape: fl.shapes.circle,
      stroke: if highlight-section == "code" { catppuccin-accents.mauve + 3pt } else { theme.colors.foreground + 2pt },
      width: radius,
      height: radius,
      name: "code",
    ),
    fl.edge(
      <markup>,
      <math>,
      "-|>",
      `$...$`,
      stroke: if highlight-section == "markup" { catppuccin-accents.yellow } else { theme.colors.border + 2pt },
      shift: 2mm,
    ),
    //fl.edge(<math>, <markdown>, "-|>", stroke: base-colors.overlay2 + 1.5pt, shift: 2mm),
    fl.edge(
      <markup>,
      <code>,
      "-|>",
      `#...`,
      stroke: if highlight-section == "markup" { catppuccin-accents.yellow } else { theme.colors.border + 2pt },
      shift: 2mm,
      label-side: left,
    ),
    fl.edge(
      <code>,
      <markup>,
      "-|>",
      `[...]`,
      stroke: if highlight-section == "code" { catppuccin-accents.yellow } else { theme.colors.border + 2pt },
      shift: 2mm,
    ),
    fl.edge(
      <code>,
      <math>,
      "-|>",
      `$...$`,
      stroke: if highlight-section == "code" { catppuccin-accents.yellow } else { theme.colors.border + 2pt },
      shift: 2mm,
    ),
    fl.edge(
      <math>,
      <code>,
      "-|>",
      `#...`,
      stroke: if highlight-section == "math" { catppuccin-accents.yellow } else { theme.colors.border + 2pt },
      shift: 2mm,
      label-side: left,
    ),
  )
}


#{
  layout(((width, height)) => {
    let dir = if width < 460pt {
      "vertical"
    } else {
      "horizontal"
    }
    grid(
      columns: if dir == "horizontal" { (auto, 1fr) } else { (auto) },
      gutter: 1em,
      {
        show: box.with(width: 19em)
        show: figure.with(
          caption: [The three modes of Typst: _Markup_, _Math_, and _Code_. Arrows indicate syntax to swtich between modes.],
        )
        holy-trinity-diagram()
      },
      {
        show: figure.with(
          caption: [The markdown related _Markup_ mode, switching to _Code_ mode for `rect` drawing and _Math_ mode for the equation.],
        )
        let code = ```typ
        == A Title
        *Bold* and _italic_ content.
        #rect(stroke: red, "Trapped")
        $ E(X) = sum_(i=1)^n x_i P(X = x_i) $
        ```
        grid(
          columns: 1,
          gutter: 1em,
          align: center,
          {
            code
          },
          {
            set text(size: 2em)
            sym.arrow.b
          },
          grid.cell(align: left, {
            set math.equation(numbering: none)
            set heading(numbering: none, outlined: false)
            eval(code.text, mode: "markup")
          }),
        )
      },
    )
  })
}

The official #link("https://typst.app/docs/")[Typst Documentation] is a great resource to learn more about the syntax and features of Typst. You can directly jump into #link("https://typst.app/docs/tutorial/")[the tutorial] for a step-by-step introduction to Typst's features.

Arguably the most powerful styling tools are the `#set`- and `#show`-Rules. You can already tell that they are invoked in _Code_ mode.

=== `#set`-Rules

`#set`-Rules are used to set default parameters for the following functions.

#info-callout(heading: [Have you mentioned functions?], grid(
  columns: (1fr, auto),
  gutter: 1em,
  [
    Turns out, everything you see in Typst is a function.
    `= Topic` is really just syntactic sugar for an invocation of the `#heading("Topic")` function. `*Bold*` is just `#strong("Bold")`. This holds true for all of Typst and is the second foundation for its flexibility.
  ],
  grid.cell(align: horizon, {
    show: pad.with(left: 0pt, top: -0.5em - 0.2em, rest: -1em)
    image("assets/functions_meme.png", width: 6cm)
  }),
))

Let's say we wanted to change the text font for the rest of this document. I will just quickly insert `#set text(font: "Source Code Pro")`...

#set text(font: "Source Code Pro")

Ah, there it is. Perfect! Neat huh?

Revert back with #raw(strfmt("#set text(font: {theme-fonts-sans-family:?})", theme-fonts-sans-family: theme.fonts.sans.family))

#set text(font: theme.fonts.sans.family)

#danger-callout(heading: [Mind the scope!])[
  `#set` (and `#show`) -Rules are effective for the whole scope they are defined in. If you have a block 
  #let code = ```typ
  #[
    #set text(fill: red)
    Red Text
  ]

  Text normal
  ```
  #grid(
    columns: 1,
    gutter: 1em,
    align: center,
    {
      code
    },
    {
      set text(size: 2em)
      sym.arrow.b
    },
    {
      eval(code.text, mode: "markup")
    },
  )

  you can observe the red text `#set`-Rule only effects the _Markup_ block. Had we left out the block:

  #let code = ```typ
  #set text(fill: red)
  Red Text

  Text normal
  ```
  #grid(
    columns: 1,
    gutter: 1em,
    align: center,
    {
      code
    },
    {
      set text(size: 2em)
      sym.arrow.b
    },
    {
      eval(code.text, mode: "markup")
    },
  )

  you can observe the red text `#set`-Rule now effects the whole content.
]

=== `#show`-Rules

Whereas we saw `#set`-Rules to set default parameters for the following functions, `#show`-Rules are used to transform elements. For the rest of this document, I want "Typst" to show up in blue and in italic.

```typ
#show "Typst": set text(fill: blue)
#show "Typst": it => [_#(it)_]
```

Let's also try out putting the headings inside a green rectangle:

```typ
#show heading: it => rect(stroke: green, it)
```

#show "Typst": set text(fill: catppuccin-accents.blue)
#show "Typst": it => [_#(it)_]
#show heading: it => rect(stroke: catppuccin-accents.green, it)

If you continue on reading this blog post, you should notice all our intended `#show`-Rules are in place and working as expected.

=== Packages

This serves only as demonstration purpose about the power of the already promising package ecosystem: We will use the "conch" package for emulating a whole terminal right in our document:

#let code = strfmt(```typ
#import "@preview/conch:0.1.0": terminal-block, system

#terminal-block(
  width: 100%,
  user: "timerertim",
  system: system(
    files: (
      "test.txt": (
        "Show Line!",
        "Ignore Line!"
      ).join("\n")
    )
  ),
 {backticks}
 ls
 cat test.txt
 cat test.txt | grep Show
 {backticks}
)
```.text, backticks: "```")

#eval(code, mode: "markup")

Very nice, looking like a real terminal! Can you believe that all of that is just #code.split("\n").len() lines of code?

#raw(code, block: true, lang: "typst")

= Conclusion

Thanks for reading this far! I hope you enjoyed the very brief overview of Typst and the incredibly steep deep dive. You can find a few resources below in order to dive deeper into Typst:

- #link("https://typst.app/docs/")[Typst Documentation]
- #link("https://typst.app/docs/tutorial/")[Typst Tutorial]
- #link("https://forum.typst.app/")[Typst Forum]
- #link("https://typst.app/universe/")[Typst Universe] (Package Registry)
- #link("https://github.com/typst/typst")[Typst GitHub Repository]