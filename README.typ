#let dark-theme = sys.inputs.at("theme", default: "") == "dark"
#set page(margin: 6pt, height: auto)
#set text(size: 16pt)
#set text(fill: if dark-theme { white } else { black })

#import "lib.typ": *

This is a test

#image(if dark-theme { "out/snake-contribution-graph-dark.svg" } else { "out/snake-contribution-graph-light.svg" })

#xhtml(```html
<xhtml:div style="background-color: green;">Hello, world!</xhtml:div>
```)


#xhtml(```html
<xhtml:img src="https://www.google.com/logos/doodles/2025/seasonal-holidays-2025-6753651837110711.4-la1f1f1f.gif" />
```, outer-width: 140pt, outer-height: 72pt)

#align(center)[
  #set text(size: 14pt, fill: gray)
  #let build-date = datetime.today(offset: 0)
  last build on: #build-date.display() | 
]