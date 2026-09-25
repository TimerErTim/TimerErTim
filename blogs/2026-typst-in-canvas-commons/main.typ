#import "../common/components/xhtml.typ": xhtml
#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, theme
#import "../common/deps.typ": codly, codly-local, strfmt
#import "../common/components/depth.typ": depth-shadow-block
#import "../common/components/callouts.typ": (
  danger-callout, info-callout, success-callout, warning-callout,
)
#import "../common/components/pikchr.typ": color-to-pikchr, pikchr
#import "../common/variants.typ": broader-than, hide-in-preview, web-or
#import "deps.typ": conch, sj

#set text(lang: "en")
#set document(
  title: "Integrating Typst (and better SVG Morphing) into Canvas Commons",
  description: "Canvas Commons is the community fork of Motion Canvas, a Vite-based framework for creating illustrative animations and videos. I am using it for my own projects and wanted to see if I can integrate Typst into it. To \"keep things simple\" morphing between different states is done purely via the SVG content. Warning: It did not stay simple for long.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "SVG",
    "Motion Canvas",
    "Canvas Commons",
    "vite",
    "TypeScript",
  ),
)
#show: blog-entry.with(
  target: auto,
  created-at: datetime(year: 2026, month: 9, day: 24),
  //updated-at: datetime(year: 2026, month: 6, day: 12),
)

#import "deps.typ": fl, lq
