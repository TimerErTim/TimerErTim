#import "../common.typ" as c: get-configuration, base-configuration
#import "../../look-and-feel/index.typ": themes


#let cover-letter(
  company, 
  subject, 
  address,
  lang: c.lang,
) = {
  let configuration = c.add-sensitive-configuration(lang)

  return (configuration: configuration, template: body => {
    show: base-configuration.with(lang: lang)
    set text(size: 11pt)
    set page(background: {
      show: pad.with(8mm)
      rect(stroke: themes.light.accent, width: 100%, height: 100%)
  })

    {
      set text(fill: themes.light.accent, size: 16pt)
      configuration.contacts.name
      linebreak()
    }
    [
      #set text(fill: themes.light.muted)
      #configuration.contacts.address, #configuration.contacts.homecountry\
      #link("mailto:" + configuration.contacts.email)[#configuration.contacts.email], #configuration.contacts.phone
    ]

    {
      set align(right)
      {
        set text(fill: themes.light.accent, size: 16pt)
        company
        linebreak()
      }
      [
        #set text(fill: themes.light.muted)
        #address
      ]
    }
    [_#datetime.today().display()_]

    {
      set text(fill: themes.light.accent, size: 12pt)
      show: underline
      show: strong
      parbreak()
      subject
    }

    v(1em)
    body

    place(right + bottom, dy: -0.5cm,
      image("../src/sensitive/signature.svg", height: 1.5cm))
  })
}
