#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, color-cycle, theme, themes
#import "../common/variants.typ": broader-than, hide-in-preview, in-preview-or, web-only, web-or, web-page-width
#import "../common/deps.typ": codly, codly-local, lq, no-codly, strfmt
#import "../common/components/depth.typ": depth-shadow-block


#set text(lang: "en")
#set document(
  title: "Publishing a Typst Template Package on Typst Universe",
  description: "As part of my current bachelor thesis writing and efforts to establish Typst at my university, I recently published the ready to use easy-hgb-thesis package for usage at Campus Hagenberg. The package can be found on the official Typst Universe, and I am going to show how easy that process was. This can be thought of as a tutorial with my personal tone.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "Templates",
    "Thesis Writing",
    "Campus Hagenberg"
  ),
)
#show: blog-entry.with(
  target: auto,
  created-at: datetime(year: 2026, month: 7, day: 28),
  //updated-at: datetime(year: 2026, month: 7, day: 29),
)

// Setup document content dependencies
#import "deps.typ": *
#import pinit: *
#import "../common/components/callouts.typ": (
  accent-callout, callout, danger-callout, info-callout, success-callout, warning-callout,
)
#import "../common/calc/auc.typ": auc
#import "../common/calc/analysis.typ": smooth_series
#import "../common/lib/fmt.typ": num_metric_suffix
#import "../common/components/xhtml.typ": xhtml

// Document specific styles
#show raw.where(lang: "show-tree-graph"): hg.enable-graph-in-raw(hg.tree-render)
#show raw.where(lang: "show-polar-graph"): hg.enable-graph-in-raw(
  hg.polar-render,
)
#show raw.where(lang: "show-md", block: true): it => cmarker.render(it.text)

