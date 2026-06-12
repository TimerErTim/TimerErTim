#import "common.typ": *

#show: base-configuration

#let muted = text.with(fill: luma(100))
#let sidebarSection = {[
  #set par(justify: true)

  #set text(
    size: eval(settings.font.size.contacts),
    font: themes.fonts.sans.family,
  )
      
  #link("mailto:" + configuration.contacts.email) \
  #link("tel:" + configuration.contacts.phone) \
  #set text(size: eval(settings.font.size.description))
  #configuration.contacts.city,
  #configuration.contacts.homecountry

  LinkedIn:\ #link(configuration.contacts.linkedin) \
  GitHub:\ #link(configuration.contacts.github) \
  Website: #link(configuration.contacts.website)
  
  #line(length: 100%)

  = Summary

  #set text(
      eval(settings.font.size.education_description),
      font: themes.fonts.sans.family,
  )
  #{
    par(justify: true)[
      #configuration.summary
    ]
  }
  
  = Education

  #{
    for place in configuration.education [
        #par(justify: false)[
          #set text(
            size: eval(settings.font.size.heading),
            font: themes.fonts.sans.family,
          )
            #{
              if "to" in place and "from" in place [
                #place.from
                – #place.to \
              ] else if "arbitrary_interval" in place [
                #place.arbitrary_interval
              ]
            }
            #link(place.place.link)[#place.place.name]
        ]
        #par(justify: false)[
          #set text(
            eval(settings.font.size.education_description),
            font: themes.fonts.sans.family,
          )
          #{
            let description_items = ()
            if "degree" in place and "major" in place [
              #description_items.push([#place.degree~#place.major #if "track" in place [ #place.track~track ]])
            ]
            if "final_work" in place [
              #if "link" in place.final_work [
                #let thesis_link = place.final_work.link
                #let thesis_url = thesis_link.at("url", default: none)
                #let thesis_name = thesis_link.at("name", default: none)
                // Format thesis text as link, if given. Otherwise, just the name.
                #if thesis_url != none and thesis_name != none [
                  #description_items.push([*Thesis* #link(thesis_url)[#thesis_name]])
                ] else if thesis_name != none [
                  #description_items.push([*Thesis* #thesis_name])
                ]
            ]
            ]
            if "location" in place [
              #description_items.push([#place.location])
            ]
            description_items.join(linebreak())
          }
        ]
    ]
  }

  = Skills

  #{
    for skill in configuration.skills [
      #par(justify: false)[
        #set text(
          size: eval(settings.font.size.description),
          tracking: -0.01em,
        )
        #set text(
          // size: eval(settings.font.size.tags),
          font: themes.fonts.sans.family,
          tracking: -0.01em,
        )
        *#skill.category*
        #linebreak()
        #skill.items.join(" • ")
      ]
    ]
  }
]}

#let mainSection = {[
  #par[
    #set text(
      size: eval(settings.font.size.heading_huge),
      font: themes.fonts.sans.family,
    )
    *#configuration.contacts.name*
  ]

  #par[
    #set text(
      size: eval(settings.font.size.heading),
      font: themes.fonts.sans.family,
      top-edge: 0pt
    )
    #configuration.contacts.title
  ]

  = Experience

  #{
    for job in configuration.jobs [
      #set par(justify: false)
        #set text(
          size: eval(settings.font.size.heading),
          font: themes.fonts.sans.family
        )
        *#job.position*
        #link(job.company.link)[\@  #job.company.name] \
        #job.from – #job.to

      #set text(
        size: eval(settings.font.size.description),
        font: themes.fonts.sans.family
      )
      #list(..job.description)
      
      #par(
        justify: false,
        leading: eval(settings.paragraph.leading),
      )[
        #set text(
          size: eval(settings.font.size.tags),
          font: themes.fonts.sans.family
        )
        #{
          let tag_line = job.tags.join(" • ")
          tag_line
        }
      ]
    ]
  }

  = Certifications

  #for certificate in configuration.certifications [
      #block(breakable: false, below: 1em)[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          [
            #set text(size: eval(settings.font.size.heading), font: themes.fonts.sans.family, weight: "bold")
            #link(certificate.venue.link)[#certificate.venue.name]
            #if "certificate_link" in certificate [
              #text(fill: luma(150))[ – ] #link(certificate.certificate_link)[Credential]
            ]
          ],
          [
            #muted(size: eval(settings.font.size.description))[
              #certificate.year#if "from" in certificate and "to" in certificate [ (#certificate.from – #certificate.to) ]
            ]
          ]
        )
        #v(-0.5em)
        #set text(size: eval(settings.font.size.description), font: themes.fonts.sans.family)
        #set par(justify: true, leading: eval(settings.paragraph.leading))
        #list(certificate.description)
      ]
    ]

  = Achievements
    #for achievement in configuration.achievements [
      #block(breakable: false, below: 1.2em)[
        #set text(size: eval(settings.font.size.heading), font: themes.fonts.sans.family, weight: "bold")
        #if "link" in achievement [
          #link(achievement.link)[#achievement.name]
        ] else [
          #achievement.name
        ]

        #if "description" in achievement [
          #v(-0.5em)
          #set text(size: eval(settings.font.size.description), font: themes.fonts.sans.family)
          #show: muted
          #achievement.description
          #v(1em)
        ]
        
        #v(-0.5em)
        #{
          let wins_by_year = achievement.wins.fold((:), (acc, win) => {
            if str(win.year) in acc { acc.at(str(win.year)).push(win) } 
            else { acc.insert(str(win.year), (win,)) }
            acc
          })

          let sorted_years = wins_by_year.keys().sorted().rev()

          set text(size: eval(settings.font.size.description), font: themes.fonts.sans.family, weight: "regular")
          
          grid(
            columns: (3em, 1fr),
            column-gutter: 1em,
            row-gutter: 0.8em,
            ..for year in sorted_years {
              (
                muted(weight: "bold")[#year],
                list(
                  ..wins_by_year.at(year).map(((value)) => {
                    if "placement" in value [ *#value.placement* – ]
                    value.category
                  }),
                  marker: (_) => ""
                ),
              )
            }
          )
        }
      ]
    ]
]}

#{
  grid(
    columns: (2fr, 5fr),
    column-gutter: 2em,
    sidebarSection,
    mainSection,
  )
}
