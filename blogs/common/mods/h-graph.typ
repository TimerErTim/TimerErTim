#import "../../../libs/h-graph/0.1.0/src/lib.typ": *
#import "../../../libs/h-graph/0.1.0/src/lib.typ": tree-render as _tree-render, polar-render as _polar-render, _diagram
#import "../theming.typ": theme

#let _diagram-fn = _diagram.with(
  node-stroke: theme.colors.border,
  node-fill: theme.colors.base,
  edge-stroke: theme.colors.border,
)

#let tree-render = _tree-render.with(diagram-fn: _diagram-fn)
#let polar-render = _polar-render.with(diagram-fn: _diagram-fn)