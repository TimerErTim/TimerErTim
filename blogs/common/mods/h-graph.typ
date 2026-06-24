#import "../../../libs/h-graph/0.1.0/src/lib.typ": *
#import "../../../libs/h-graph/0.1.0/src/lib.typ": tree-render as _tree-render, polar-render as _polar-render
#import "fletcher.typ": diagram
#import "../theming.typ": theme

#let tree-render = _tree-render.with(diagram-fn: diagram)
#let polar-render = _polar-render.with(diagram-fn: diagram)