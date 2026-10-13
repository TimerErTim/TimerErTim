#import "deps.typ": sj, sr
#import "base-style.typ": base-style
#import "theming.typ": theme
#import "variants.typ": is-preview, targets-web
#import "lib/dicts.typ": merge-dicts

#import sr: *

#let _input_presentation_handout = (
  sys.inputs.at("x-handout", default: "false") == "true"
)

#let _presentation_randomness_seed = state("prs:randomness", 42)
#let _presentation_handout = state("prs:handout", _input_presentation_handout)

#let presentation(
  /// Seed of randomness for the predefined slide components
  seed: 42,
  handout: auto,
  body,
) = {
  targets-web.update(true) // Unlocks full formatting

  if is-preview {
    if handout == true {
      _presentation_handout.update(true)
    } else {
      _presentation_handout.update(false)
    }
  }

  context if _presentation_handout.get() {
    targets-web.update(false)
  }

  show: base-style
  set page(paper: "presentation-16-9", fill: theme.colors.base, margin: 0pt)

  show: align.with(center + horizon)
  _presentation_randomness_seed.update(seed)
  body
}

#let slide(..args) = context {
  let options = args.named().at("options", default: (:))
  options = merge-dicts(("handout": _presentation_handout.get()), base: options)
  let kwargs = args.named()
  let _ = kwargs.remove("options", default: none)
  let args = args.pos()
  sr.slide(..args, ..kwargs, options: options)
}

#let scene(..args) = context {
  let options = args.named().at("options", default: (:))
  options = merge-dicts(("handout": _presentation_handout.get()), base: options)
  let kwargs = args.named()
  let _ = kwargs.remove("options", default: none)
  let args = args.pos()
  sr.scene(..args, ..kwargs, options: options)
}
