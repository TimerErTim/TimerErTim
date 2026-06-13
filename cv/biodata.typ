#import "../look-and-feel/index.typ": themes
#import "common.typ": (
  add-sensitive-configuration, base-configuration, lang, settings,
)
#let configuration = add-sensitive-configuration(lang)
#show: base-configuration
// -----------------------------------------------------------------------------
// HELPER COMPONENTS
// -----------------------------------------------------------------------------
#let muted = text.with(fill: themes.light.muted)
#let tag(name) = box(
  fill: luma(245),
  inset: (x: 0.5em, y: 0.3em),
  radius: 3pt,
  text(size: eval(settings.font.size.tags), weight: "medium", name),
)

// Global styling for section headings
#show heading.where(level: 1): it => block(
  outset: (top: 1.5em, bottom: 1em),
  [
    #set text(
      size: eval(settings.font.size.heading),
      font: themes.fonts.sans.family,
      weight: "bold",
    )
    #it.body
    #v(-0.5em)
    #line(length: 100%, stroke: 0.5pt + luma(200))
  ],
)

// -----------------------------------------------------------------------------
// HEADER SECTION
// -----------------------------------------------------------------------------
#grid(
  columns: (1fr, auto),
  column-gutter: 0em,
  align(horizon)[
    #block[
      #text(
        size: eval(settings.font.size.heading_huge),
        font: themes.fonts.sans.family,
        weight: "bold",
      )[#configuration.contacts.name]
      #h(0.5em)
      #muted(size: eval(
        settings.font.size.heading,
      ))[| #configuration.contacts.birthdate]
    ]

    #v(-0.2em)
    #text(
      size: eval(settings.font.size.heading),
      font: themes.fonts.sans.family,
      fill: themes.light.muted,
    )[#configuration.contacts.title]

    #v(0.5em)

    // Contact & Personal Details Grid
    #set text(size: eval(settings.font.size.contacts))
    #grid(
      columns: (auto, auto),
      column-gutter: 2em,

      // Left Sub-column (Contact)
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.6em,
        muted[Address:], configuration.contacts.address,
        muted[Email:], link("mailto:" + configuration.contacts.email),
        muted[Phone:], link("tel:" + configuration.contacts.phone),
        muted[LinkedIn:], link(configuration.contacts.linkedin),
        muted[GitHub:], link(configuration.contacts.github),
        muted[Website:], link(configuration.contacts.website),
      ),

      // Right Sub-column (Personal)
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.6em,
        muted[Nationality:], configuration.contacts.nationality,
        muted[Gender:], configuration.contacts.gender,
        ..if "religion" in configuration.contacts {
          (muted[Religion:], configuration.contacts.religion)
        },
        muted[Marital Status:], configuration.contacts.marital_status,
        muted[Birthplace:], configuration.contacts.birthplace,
      ),
    )
  ],
  align(right + horizon)[
    #box(
      width: 100pt,
      clip: true,
      radius: 8pt, // Slightly rounded corners for the avatar
      image("src/sensitive/avatar.jpg", width: 100%, fit: "cover"),
    )
  ],
)

// -----------------------------------------------------------------------------
// SUMMARY
// -----------------------------------------------------------------------------
= Summary
#par(justify: true, leading: eval(settings.paragraph.leading))[
  #set text(
    size: eval(settings.font.size.description),
    font: themes.fonts.sans.family,
  )
  #configuration.summary
]

#v(1em)

// -----------------------------------------------------------------------------
// MAIN TWO-COLUMN LAYOUT
// -----------------------------------------------------------------------------
#grid(
  columns: (3fr, 7fr),
  // Adjusted ratio for better breathing room
  column-gutter: 2.5em,

  // LEFT COLUMN ---------------------------------------------------------------
  [
    = Education
    #{
      for place in configuration.education [
        #block(breakable: false)[
          #text(
            size: eval(settings.font.size.heading),
            font: themes.fonts.sans.family,
            weight: "bold",
          )[
            #link(place.place.link)[#place.place.name]
          ]
          #muted(size: eval(settings.font.size.education_description))[
            #{
              if "to" in place and "from" in place [
                \ #place.from – #place.to
              ] else if "arbitrary_interval" in place [
                \ #place.arbitrary_interval
              ]
            }
          ]
          #v(-0.5em)
          #set text(
            size: eval(settings.font.size.education_description),
            font: themes.fonts.sans.family,
          )
          #{
            let description_items = ()
            if "degree" in place and "major" in place [
              #description_items.push([#place.degree #place.major#if (
                  "track" in place
                ) [, #place.track track]])
            ]
            if "final_work" in place [
              #if "link" in place.final_work [
                #let thesis_link = place.final_work.link
                #let thesis_url = thesis_link.at("url", default: none)
                #let thesis_name = thesis_link.at("name", default: none)
                #if thesis_url != none and thesis_name != none [
                  #description_items.push(
                    [*Thesis*: #link(thesis_url)[#thesis_name]],
                  )
                ] else if thesis_name != none [
                  #description_items.push([*Thesis*: #thesis_name])
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
    #for skill in configuration.skills [
      #block(sticky: true, above: 0pt, below: 0.5em)[#text(
        size: eval(settings.font.size.description),
        weight: "bold",
      )[#skill.category]]
      #block(below: 1em)[
        #set text(
          size: eval(settings.font.size.tags),
          font: themes.fonts.sans.family,
        )
        #skill.items.join(" • ")
      ]
    ]

    = Hobbies
    #for hobby in configuration.hobbies [
      #block(sticky: true, above: 0pt, below: 0.5em)[#text(
        size: eval(settings.font.size.description),
        weight: "bold",
      )[#hobby.category]]
      #block(below: 1em)[
        #set text(
          size: eval(settings.font.size.tags),
          font: themes.fonts.sans.family,
        )
        #hobby.items.join(" • ")
      ]
    ]
  ],

  // RIGHT COLUMN --------------------------------------------------------------
  [
    = Experience
    #for job in configuration.jobs [
      #block(breakable: false, below: 1.5em)[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          [
            #text(
              size: eval(settings.font.size.heading),
              font: themes.fonts.sans.family,
              weight: "bold",
            )[#job.position] \
            #text(
              size: eval(settings.font.size.description),
              fill: rgb("4A6B8C"),
            )[\@ #link(job.company.link)[#job.company.name]]
          ],
          [
            #muted(size: eval(
              settings.font.size.description,
            ))[#job.from – #job.to]
          ],
        )

        #v(-0.5em)
        #set text(
          size: eval(settings.font.size.description),
          font: themes.fonts.sans.family,
        )
        #set par(justify: true, leading: eval(settings.paragraph.leading))
        #list(..job.description)

        #v(0.4em)
        // Render tags as beautiful pills
        #job.tags.map(t => tag(t)).join(h(0.4em))
      ]
    ]

    = Certifications
    #for certificate in configuration.certifications [
      #block(breakable: false, below: 1em)[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          [
            #set text(
              size: eval(settings.font.size.description),
              font: themes.fonts.sans.family,
              weight: "bold",
            )
            #link(certificate.venue.link)[#certificate.venue.name]
            #if "certificate_link" in certificate [
              #text(fill: luma(150))[ – ] #link(
                certificate.certificate_link,
              )[Credential]
            ]
          ],
          [
            #muted(size: eval(settings.font.size.description))[
              #certificate.year#if (
                "from" in certificate and "to" in certificate
              ) [ (#certificate.from – #certificate.to) ]
            ]
          ],
        )
        #v(-0.5em)
        #set text(
          size: eval(settings.font.size.description),
          font: themes.fonts.sans.family,
        )
        #set par(justify: true, leading: eval(settings.paragraph.leading))
        #list(certificate.description)
      ]
    ]

    = Achievements
    #for achievement in configuration.achievements [
      #block(breakable: false, below: 1.2em)[
        #set text(
          size: eval(settings.font.size.heading),
          font: themes.fonts.sans.family,
          weight: "bold",
        )
        #if "link" in achievement [
          #link(achievement.link)[#achievement.name]
        ] else [
          #achievement.name
        ]

        #if "description" in achievement [
          #v(-0.5em)
          #set text(
            size: eval(settings.font.size.description),
            font: themes.fonts.sans.family,
          )
          #show: muted
          #achievement.description
          #v(1em)
        ]

        #v(-0.5em)
        #{
          let wins_by_year = achievement.wins.fold((:), (acc, win) => {
            if str(win.year) in acc { acc.at(str(win.year)).push(win) } else {
              acc.insert(str(win.year), (win,))
            }
            acc
          })

          let sorted_years = wins_by_year.keys().sorted().rev()

          set text(
            size: eval(settings.font.size.description),
            font: themes.fonts.sans.family,
            weight: "regular",
          )

          grid(
            columns: (3em, 1fr),
            column-gutter: 1em,
            row-gutter: 0.8em,
            ..for year in sorted_years {
              (
                muted(weight: "bold")[#year],
                list(
                  ..wins_by_year
                    .at(year)
                    .map(((value)) => {
                      if "placement" in value [ *#value.placement* – ]
                      value.category
                    }),
                  marker: _ => "",
                ),
              )
            }
          )
        }
      ]
    ]
  ],
)

#v(2em)

// -----------------------------------------------------------------------------
// FOOTER / DECLARATION
// -----------------------------------------------------------------------------
#line(length: 100%, stroke: 0.5pt + luma(200))
#v(0em)

#grid(
  columns: (1fr, auto),
  align: (left, horizon),
  [
    #set text(
      size: eval(settings.font.size.description),
      font: themes.fonts.sans.family,
      fill: themes.light.muted,
    )
    I hereby declare that all the above information is correct to the best of my knowledge and belief.\

    *#configuration.contacts.name*, #muted(size: 0.9em)[#datetime.today().display()]
  ],
  [
    #box(image("src/sensitive/signature.svg", height: 3em), inset: (right: 1em))
  ],
)
