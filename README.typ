#let dark-theme = sys.inputs.at("theme", default: "") == "dark"
#set text(fill: if dark-theme { white } else { black })

This is a test

#image(if dark-theme { "out/snake-contribution-graph-dark.svg" } else { "out/snake-contribution-graph-light.svg" })

#lorem(1000)
