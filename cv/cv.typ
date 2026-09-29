#import "common.typ": *
#import "../look-and-feel/index.typ": themes

#show: base-configuration
#let with-signature = eval(sys.inputs.at("with-signature", default: "false"))
#let with-image = eval(sys.inputs.at("with-image", default: "false"))

#let visit-me-on-section = [
  Visit me on
  #import "@preview/pinit:0.2.2": *

  #let items = (
    link(configuration.contacts.linkedin, image(
      "../assets/logos/linkedin-square.png",
      height: 12pt,
    )),
    link(configuration.contacts.github, image(
      "../assets/logos/github-invertocat.svg",
      height: 12pt,
    )),
    {
      link(configuration.contacts.website, image(
        "../assets/identity/icon.png",
        height: 12pt,
      ))
      place(pin(1))
    },
  )

  #items.map(box).join(h(1em))
  #pinit-point-from(
    1,
    offset-dy: -1cm,
    body-dy: -1em,
    pin-dy: -4mm,
    pin-dx: 6mm,
  )[
    #set text(size: 0.9em)
    personal Website
  ]
]

#let muted = text.with(fill: luma(100))

#let table-sans(size) = text.with(
  size: size,
  font: themes.fonts.sans.family,
)

#let cv-table(rows) = {
  let cells = ()
  for row in rows {
    let (period, body) = row
    cells.push(period)
    cells.push(body)
  }
  table(
    columns: (1.5cm, 1fr),
    column-gutter: 1.2em,
    row-gutter: 1em,
    stroke: none,
    inset: 0pt,
    align: (right + top, left + top),
    ..cells,
  )
}

#let period(place) = {
  show: strong
  show: block.with(breakable: false)
  if "year" in place [
    #place.year
    #linebreak()
  ]
  if "to" in place and "from" in place [
    #place.to
    #pad(sym.arrow.t, right: 1em, y: -0.25em)
    #place.from
  ] else if "arbitrary_interval" in place [
    #place.arbitrary_interval
  ]
}

#let education-body(place) = {
  let description-items = ()
  let degree-and-major = none
  if "degree" in place and "major" in place {
    degree-and-major = strong[#place.degree~#place.major]
  }
  if "final_work" in place and "name" in place.final_work {
    let thesis-link = place.final_work.at("link", default: none)
    let thesis-name = place.final_work.at("name")
    if thesis-link != none and thesis-name != none {
      description-items.push([*Thesis* #link(thesis-link)[#thesis-name]])
    } else if thesis-name != none {
      description-items.push([*Thesis* #thesis-name])
    }
  }
  if "location" in place {
    description-items.push([#place.location])
  }
  [
    #{
      set text(
        size: eval(settings.font.size.heading),
        font: themes.fonts.sans.family,
      )
      strong(link(place.place.link)[#place.place.name])
      if degree-and-major != none [
        #set text(
          size: eval(settings.font.size.description),
          font: themes.fonts.sans.family,
        )
        #sym.dash.em
        #degree-and-major
      ]
      linebreak()
    }
    #{
      set text(
        size: eval(settings.font.size.education_description),
        font: themes.fonts.sans.family,
      )
      if "track" in place [#place.track~track]
      description-items.join(linebreak())
    }
  ]
}

#let job-body(job) = [
  #{
    set text(
      size: eval(settings.font.size.heading),
      font: themes.fonts.sans.family,
    )
    [*#job.position* @
      #link(job.company.link)[#job.company.name]]
  }
  #set par(spacing: 0.75em)
  #{
    v(-0.25em)
    set text(
      size: eval(settings.font.size.description),
      font: themes.fonts.sans.family,
    )
    list(..job.description)
  }
  #{
    set text(
      size: eval(settings.font.size.tags),
      font: themes.fonts.sans.family,
    )
    job
      .tags
      .map(box.with(fill: themes.light.info, inset: 3pt, radius: 2pt))
      .map(text.with(fill: themes.light.base))
      .join("  ")
  }
]

#let certificate-body(certificate) = [
  #{
    set text(
      size: eval(settings.font.size.heading),
      font: themes.fonts.sans.family,
      weight: "bold",
    )
    [
      #link(certificate.venue.link)[#certificate.venue.name]
      #if "certificate_link" in certificate [
        #text(fill: luma(150))[ – ] #link(
          certificate.certificate_link,
        )[Credential]
      ]
    ]
  }
  #{
    v(-0.25em)
    set text(
      size: eval(settings.font.size.description),
      font: themes.fonts.sans.family,
    )
    set par(justify: true, leading: eval(settings.paragraph.leading))
    list(certificate.description)
  }
]

#let contacts-table = {
  set text(
    size: eval(settings.font.size.contacts),
    font: themes.fonts.sans.family,
  )
  table(
    columns: (auto, auto),
    column-gutter: 0.8em,
    row-gutter: 0.35em,
    stroke: none,
    inset: 0pt,
    align: (left, left),
    ..(
      (
        muted[Email],
        link("mailto:" + configuration.contacts.email),
        muted[Phone],
        link("tel:" + configuration.contacts.phone),
        muted[Location],
        [
          #configuration.contacts.city, #configuration.contacts.homecountry
        ],
      )
    ),
  )
}

#let skills-table = table(
  columns: (2.5cm, 1fr),
  column-gutter: 1em,
  row-gutter: 0.6em,
  stroke: none,
  inset: 0pt,
  align: (left + top, left + top),
  ..configuration
    .skills
    .map(skill => (
      [#set text(weight: "bold"); #{
          show: table-sans(eval(settings.font.size.description))
          skill.category
        }],
      [#set text(tracking: -0.01em); #{
          show: table-sans(eval(settings.font.size.description))
          skill.items.join(" • ")
        }],
    ))
    .flatten(),
)

#grid(
  columns: (1fr, auto),
  gutter: 1em,
  {
    par[
      #set text(
        size: eval(settings.font.size.heading_huge),
        font: themes.fonts.sans.family,
      )
      *#configuration.contacts.name*
    ]

    par[
      #set text(
        size: eval(settings.font.size.heading),
        font: themes.fonts.sans.family,
        top-edge: 0pt,
      )
      #configuration.contacts.title
    ]

    {
      set text(
        size: eval(settings.font.size.contacts),
        font: themes.fonts.sans.family,
      )
      grid(
        columns: (auto, 1fr),
        align: (left, center),
        contacts-table, pad(visit-me-on-section, right: 2cm),
      )
    }

    [= Summary]

    {
      set text(
        size: eval(settings.font.size.education_description),
        font: themes.fonts.sans.family,
      )
      par(justify: true)[#configuration.summary]
    }
  },
  ..if with-image {
    (
      {
        show: block.with(stroke: black, radius: 1em, clip: true)
        image("../assets/picture/avatar.jpg", width: 4cm)
      },
    )
  },
)

#line(length: 100%)

= Experience

#cv-table(configuration.jobs.map(job => (
  muted(size: eval(settings.font.size.description), period(job)),
  job-body(job),
)))

= Education

#cv-table(configuration.education.map(place => (
  muted(size: eval(settings.font.size.description), period(place)),
  education-body(place),
)))

= Skills

#skills-table

= Certifications

#cv-table(configuration.certifications.map(certificate => (
  muted(size: eval(settings.font.size.description), period(certificate)),
  certificate-body(certificate),
)))

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
      let wins-by-year = achievement.wins.fold((:), (acc, win) => {
        if str(win.year) in acc { acc.at(str(win.year)).push(win) } else {
          acc.insert(str(win.year), (win,))
        }
        acc
      })

      let sorted-years = wins-by-year.keys().sorted().rev()

      table(
        columns: (1.5cm, 1fr),
        column-gutter: 1em,
        row-gutter: 0.8em,
        stroke: none,
        inset: 0pt,
        align: (right + top, left + top),
        ..sorted-years
          .map(year => (
            muted(weight: "bold")[#year],
            {
              set text(
                size: eval(settings.font.size.description),
                font: themes.fonts.sans.family,
                weight: "regular",
              )
              list(
                ..wins-by-year
                  .at(year)
                  .map(((value)) => {
                    if "placement" in value [ *#value.placement* – ]
                    value.category
                  }),
                marker: _ => "",
              )
            },
          ))
          .flatten(),
      )
    }
  ]
]

#if with-signature {
  line(length: 100%, stroke: 0.5pt + luma(200))
  v(0em)

  grid(
    columns: (1fr, auto),
    align: (left, horizon),
    [
      #set text(
        size: eval(settings.font.size.description),
        font: themes.fonts.sans.family,
        fill: themes.light.foreground,
      )
      I hereby declare that all the above information is correct to the best of my knowledge and belief.\

      *#configuration.contacts.name*, #muted(size: 0.9em)[#datetime.today().display()]
    ],
    [
      #box(image("src/sensitive/signature.svg", height: 3em), inset: (
        right: 1em,
      ))
    ],
  )
}
