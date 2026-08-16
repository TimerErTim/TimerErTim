#import "../variants.typ": input-is-pdf, targets-web
#import "../../../libs/typst-svg/lib.typ": (
  xhtml_0-7-0 as _xhtml_0-7-0, xhtml_0-8-0 as _xhtml_0-8-0,
)

#let _inject_xhtml(original_fn) = (
  outer-width: 160pt,
  outer-height: 90pt,
  inner-width: none,
  inner-height: none,
  cont,
) => context {
  let placeholder = targets-web.get() and input-is-pdf
  original_fn(
    cont,
    outer-width: outer-width,
    outer-height: outer-height,
    inner-width: inner-width,
    inner-height: inner-height,
    placeholder: placeholder,
  )
}

#let xhtml = if sys.version.minor >= 15 {
  _inject_xhtml(_xhtml_0-8-0)
} else {
  _inject_xhtml(_xhtml_0-7-0)
}
