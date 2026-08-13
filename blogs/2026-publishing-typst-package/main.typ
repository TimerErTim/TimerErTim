#import "../common/template.typ": blog-entry
#import "../common/theming.typ": catppuccin-accents, color-cycle, theme, themes
#import "../common/variants.typ": (
  broader-than, hide-in-preview, in-preview-or, input-web-page-width, web-only,
)
#import "../common/deps.typ": codly, codly-local, lq, no-codly, strfmt
#import "../common/components/depth.typ": depth-shadow-block

#set text(lang: "en")
#set document(
  title: "Publishing a Typst Template Package on Typst Universe",
  description: "As part of my current bachelor thesis writing and efforts to establish Typst at my university, I recently published the ready to use easy-hgb-thesis package for usage at Campus Hagenberg. The package can be found on the official Typst Universe, and I am going to show how easy that process was. This can be thought of as a tutorial with my personal tone and choice of tools: mise, jujutsu and Typst CLI.",
  author: "Tim Peko (TimerErTim)",
  keywords: (
    "Typst",
    "Templates",
    "Thesis Writing",
    "Campus Hagenberg",
    "Mise",
    "Jujutsu",
  ),
)
#show: blog-entry.with(
  target: "web",
  created-at: datetime(year: 2026, month: 8, day: 12),
  updated-at: datetime(year: 2026, month: 8, day: 13),
  bibl: bibliography("bib.yaml"),
)

// Setup document content dependencies
#import "deps.typ": *
#import "../common/components/callouts.typ": (
  accent-callout, callout, danger-callout, info-callout, success-callout,
  warning-callout,
)
#import "../common/components/xhtml.typ": xhtml

= Goal

Being the *Typst* enthusiast that I am, my bachelor thesis shall be written in *Typst* as well. There is only one problem: There is no ready to use template for the university of applied sciences Upper Austria... at least not outside of the _LaTeX_ world. That has to change before I can start writing! The #link("https://typst.app/universe/package/easy-hgb-thesis")[*easy-hgb-thesis* package] was born.

With that being settled, I have the following goals in mind:
+ The template should be easy to use and understand
+ It should get you going very quickly
+ Flexibility for every unique constellation
+ Support of german and english language
+ Covers advanced customization needs
+ Good documentation and examples.

All in all, the package should be a well-rounded solution for the typical bachelor thesis writing process. Easy for newcomers but powerful for experienced typesetting users, accessable on the official package registry, #link("https://typst.app/universe")[Typst Universe].

= Writing the package

There are two main parts: The package itself and the ready to get going template. Conceptionally, the package is the real content with styles and convetions, whereas the template can be thought of a new project starter.

#conch.terminal-frame(
  width: 100%,
  title: [File structure of the package],
  style: (
    inset: (top: -0.5em, rest: 1em),
  ),
)[
  #conch.render-ansi(read("assets/ansi-ls.txt"))
]

== The package itself

A *Typst* package requires only a `typst.toml` file and a configurable entrypoint (per convention `lib.typ`). The `typst.toml` file contains metadata relevant for *Typst Universe*, with the full specification available #link("https://github.com/typst/packages/blob/main/docs/manifest.md")[here].

#codly(skips: ((10, 3),))
```toml
[package]
name = "easy-hgb-thesis"
description = "Opinionated bachelor's, master's thesis or protocols for the FH Upper Austria, especially campus Hagenberg."
version = "0.2.0"
compiler = "0.14.0"
entrypoint = "lib.typ"
authors = ["Tim Peko <timerertim@gmail.com> @TimerErTim"]
repository = "https://github.com/TimerErTim/hagenberg-thesis-typst"
license = "MIT-0"

```

`lib.typ` works as a proxy for the public API surface of the package. With it we manually expose functions and types, while the rest stays hidden as internals. This is done by importing them: `#import "components/template.typ": full-thesis, .."`. With that out of the way, let's fill it with life! Let me quickly walk you through the design decisions serving our established goals:

*Easy to use and understand*\
The `full-thesis` function is kept simple and straightforward. It pairs well with *Typst*-native concepts such as `#set document(..)` or `#set text(lang: ..)` to define the document's metadata. There are only a few parameter categories, all of which are optional and have sensible defaults:
- *Coverpage*
- *Feature toggles* (such as list of tables, print size control, etc.)
- *Section contents* such as preface, bibliography, main content; skips section per default
- *Style hooks* (`show`-Rules spanning the according sections) for customization

*Gets you going very quickly*\
By providing a ready to use template with chapters, typical configurations and compilation scripts already set up, users can get going simple by invoking `typst init @preview/easy-hgb-thesis`. This will create a new directory with the template and all necessary files.
@template-chapter further down below expands on this.

*Flexibility for every unique constellation*\
We expose all sections as individual functions so users can opt-out of the opinionated default order. Inserting an appendix is as simple as calling `#appendix-section[..]`. These functions provide the same customization options as the complete `full-thesis` function (including style hooks).

We also provide different premade thesis styles, controlling the default style for the individual sections, allowing users to quickly switch between completely different style variants they can build upon later on. This is simply added as another parameter to the `full-thesis` and sections functions.

```typ
#let THESIS_STYLE = (
  "modern": 1,
  "classic": 2,
)
```

*Multiple languages*\
By using a `#set text(lang: ..)` rule before the `full-thesis` invocation, users can switch between german and english language. Every text content passes through a `#i8n(key)` function, returning the appropriate variant from a central translation dictionary based on the current `text.lang` value.

*Advanced customization*\
Style hooks are very powerful and allow users to override stylings as well as the whole content of individual sections. By adhering to the principle of only using fully reversible `#set`- or impactless `#show`-rules inside the package, users retain the ability to fully override all styling.

*Documentation*\
Every publicly facing function is well documented, the template is blastered with helpful comments and a manual is provided with detailed explanations and examples for common customizations.

#info-callout(heading: [The repository is available on GitHub])[
  If you want to inspect the source code or contribute yourself, the repository is available at: #link("https://github.com/TimerErTim/hagenberg-thesis-typst")[TimerErTim/hagenberg-thesis-typst]
]

=== Other resources

There are other resources you might want to include when uploading to *Typst Universe* without being required for the package to work in *Typst*, for example a thumbnail image referenced in the `README.md` (so *Typst Universe* can display a nice preview image).

There is an option specifically exclude published files from being fetched by *Typst* when installing the package:

#codly(skips: ((2, 6),))
```toml
[package]
exclude = ["thumbnail.png"]
```

You can read more about this #link("https://github.com/typst/packages/blob/main/docs/tips.md#what-to-commit-what-to-exclude")[here].

== The template <template-chapter>

*Typst Universe* allows packages to define a project template with optional thumbnail, which makes setup for new users a breeze. All we need is an additional `[template]` section in `typst.toml` to point to the template directory and the entrypoint:

#codly(offset: 9)
```toml
[template]
path = "template"
entrypoint = "main.typ"
thumbnail = "thumbnail.png"
```

Everything inside the `template` directory is copied to the new project directory when invoking `typst init @preview/easy-hgb-thesis`. I also decided to include a `mise.toml` file to make it easier to get started compiling and formatting the thesis project.

The `main.typ` is the entrypoint for the template and should always use the *Typst Universe* hosted package `@preview/easy-hgb-thesis` to ensure setup agnosticity.

```typ
#import "@preview/easy-hgb-thesis:0.2.0": full-thesis, titlepage, WORK_TYPES

#set document(
  title: "Thesis Title",
  author: ("Author Name", "Name Two", "Name Three"),
  description: "Thesis Description",
  keywords: ("Keyword 1 ", "Keyword 2"),
)
// If German, set to "de" instead of "en"
#set text(lang: "en")

#show: full-thesis.with(
  titlepage: titlepage(
    "Computer Science",
    "Dr. Max Mentorman",
    work-type: WORK_TYPES.bachelor-thesis,
  ),
  kurzfassung: include "chapters/kurzfassung.typ",
  abstract: include "chapters/abstract.typ",
  appendix: include "chapters/appendix.typ", // Can be deleted if not required
  bibl: bibliography("bib.yaml"), // Can be replaced with a BibLaTex file,

  // Style hooks can be used to apply custom styles to sections
  content-style: it => {
    show table.cell.where(y: 0): strong
    it
  },
)

// Include your chapters here, content can also be written here directly but
// may become confusing and hard to maintain with very long contents
#include "chapters/introduction.typ"
#include "chapters/methodology.typ"
#include "chapters/conclusion.typ"
```

An additional user serving artifact is the manual, which is available #link("https://github.com/TimerErTim/hagenberg-thesis-typst/blob/main/easy-hgb-thesis-manual.pdf")[in the repository]. It uses the template with `THESIS_STYLE.modern`. The source functions as example for how to use the package template.

= Publishing to Typst Universe <publishing-to-universe>

== Technical introduction

*Typst* went for an easy and straightforward approach for its early-stage package registry: Hosting everything in a public GitHub repository #link("https://github.com/typst/packages/")[typst/packages].
Because there is no namespacing solution in place yet, the only available package namespace for now is `@preview/` @typst-package-manager.

*Typst Universe*, the package browser on the web, is effectively just a mirror of this GitHub repo. Submitting a new package is therefore as simple as opening a Pull Request.

== Creating the Pull Request

Using the #link("https://medium.com/@abhijit838/git-fork-development-workflow-and-best-practices-fb5b3573ab74")[GitHub Pull Request Flow]
+ Create a new branch on the locally cloned fork
+ Copy the package files into `packages/preview/easy-hgb-thesis/<version>/`
+ Create and push a new commit
+ Open a Pull Request on the upstream packages repo

That's it. After filling out the PR description, your job is to wait for approval. There is #link("https://github.com/typst/packages/tree/main/docs")[good documentation] for rules and best practices, so the package does not stay in review hell.

= Automation

Let's finally mention #link("https://mise.jdx.dev")[mise-en-place] for automating some of the publishing process. Some of these are genuinely great tips.

#let mise-toml = raw(lang: "toml", block: true, read("assets/_mise.toml"))

We are going to start by adding basic tools and environment variables to the `mise.toml` file that ensure proper compilation.

#codly(ranges: ((1, 2), (5, 7)))
#mise-toml

== Formatting

#link("https://github.com/typstyle-rs/typstyle")[typstyle] is a great *Typst* formatter that we can easily integrate into our workflow with just one tool and according task defintion:

#codly(ranges: ((1, 1), (3, 3), (10, 14)))
#mise-toml

Listing the individual subdirectories manually is tedius but required for the next chapter.

== Local compilation

*Typst Universe* recommends compiling the exact template version locally before publishing to ensure compilability. So the unreleased, local package version has to become available to the template via `#import "@preview/easy-hgb-thesis:<unreleased-version>"` directive.

*Typst* supports local package registries via the `TYPST_PACKAGE_PATH` environment variable. Instead of probing into the `packages/` folder of the GitHub repo mentioned in @publishing-to-universe, it probes into the folder this environment variable points to.

#codly(ranges: ((5, 5), (8, 8), (122, 137)))
#mise-toml

Let's break this down:

- `TYPST_PACKAGE_PATH = "{{config_root}}/local-packages/"`: Tells *Typst* to look for packages inside the `local-packages/` folder.
- `[tasks."setup:editable-package"]`: Symlinks the project root to the `local-packages/` folder so *Typst* can find the package.
  + Extract package `name` and `version` from the `typst.toml` file using _yq_ (the yaml equivalent of _jq_)
  + *Typst* will look for the package at `<namespace>/<name>/<version>/` of the local package registry. Store that as symlink target.
  + Create a relative symlink from the project root to the target directory.

Ta-da! Compilation will now work seamlessly.

== Publishing

The whole git workspace management can be automated as well. The whole publishing process then consists of five steps:
+ *Preparation*: Compile artifacts and format code
+ *Workspace setup*: Clone the forked package repository under `packages`
+ *Extract version* from the package metadata
+ *Copy package files* to the correct version directory
+ *Commit*

#codly(
  ranges: ((45, 47), (101, 120)),
  highlights: (
    (
      line: 116,
      fill: catppuccin-accents.peach.transparentize(70%),
    ),
  ),
)
#mise-toml

The magic happens in line 116, because the `publish:copy-to` task#footnote[a simple python script] has a certain gimmick: It respects a `.publishignore` file, that works like a `.gitignore` file but for the publish process. There are some files we do not want to publish but want to track in the project repo, such as the root `mise.toml` file.

#codly(header: [Example for a `.publishignore` file])
```gitignore
# Exclude additional resources
thumbnail/
manual/

# Exclude development/IDE config
.vscode/
/mise.toml
```

That's it, the `publish` task will now take care of the rest. Thanks for reading this far!


