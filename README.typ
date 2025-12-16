#let dark-theme = sys.inputs.at("theme", default: "") == "dark"
#let now = sys.inputs.at("now", default: datetime.today(offset: 0))
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
<xhtml:img src="http://server.timerertim.eu:5000/" />
```, outer-width: 500pt, outer-height: 250pt)

#align(center)[
  #set text(size: 14pt, fill: gray)
  built on: #now.display() | 
]