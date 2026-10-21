#import "common.typ": *
#import "../look-and-feel/index.typ": themes
// https://typst.app/universe/package/impressive-impression/
#import "@preview/impressive-impression:0.2.1": (
  cv as impression-cv, make-aside-grid, make-aside-persona,
  make-main-content-block-with-timeline, make-pill,
)

#let with-signature = eval(sys.inputs.at("with-signature", default: "false"))
#let with-image = eval(sys.inputs.at("with-image", default: "false"))
#set text(lang: lang)
#show link: set text(fill: themes.light.accent)
#show link: underline

#let make-dot(cont) = [
  #show: circle.with(
    fill: themes.light.surface,
    inset: -1pt,
    stroke: themes.light.info,
  )
  #cont
]

#let configuration = get-configuration(lang)
#let is-german = lang == "de"
#let section-labels = if is-german {
  (
    profile: "Profil",
    hobbies: "Interessen",
    summary: "Profil",
    experience: "Berufserfahrung",
    education: "Ausbildung",
    skills: "Kenntnisse",
    certifications: "Zertifikate",
    achievements: "Auszeichnungen",
    thesis: "Abschlussarbeit",
    credential: "Nachweis",
    declaration: "Ich erkläre, dass alle oben genannten Angaben nach bestem Wissen und Gewissen richtig sind.",
  )
} else {
  (
    profile: "Profile",
    hobbies: "Interests",
    summary: "Summary",
    experience: "Experience",
    education: "Education",
    skills: "Skills",
    certifications: "Certifications",
    achievements: "Achievements",
    thesis: "Thesis",
    credential: "Credential",
    declaration: "I hereby declare that all the above information is correct to the best of my knowledge and belief.",
  )
}
#{
  section-labels += (
    email: make-dot[📧],
    phone: make-dot[☎️],
    location: make-dot[📍],
    website: make-dot(pad(1pt, image(
      "../assets/identity/icon.png",
      height: 1.2em,
    ))),
    linkedin: make-dot(box(radius: 100%, clip: true, outset: 1pt, pad(
      1pt,
      image(
        "../assets/logos/linkedin-square.png",
        height: 1.2em,
      ),
    ))),
    github: make-dot(pad(1pt, image(
      "../assets/logos/github-invertocat.svg",
      height: 1.2em,
    ))),
  )
}

#let cv-theme = (
  name: "TimerErTim",
  margin: 1.1cm,
  main-text: (
    font: themes.fonts.sans.family,
    size: eval(settings.font.size.description),
    style: "normal",
    weight: "regular",
    fill: themes.light.foreground,
  ),
  base-text: (
    font: themes.fonts.sans.family,
    size: eval(settings.font.size.description),
    style: "normal",
    weight: "regular",
    fill: themes.light.foreground,
  ),
  main-heading-text: (
    font: themes.fonts.sans.family,
    size: eval(settings.font.size.heading),
    weight: "bold",
    fill: themes.light.accent,
  ),
  main-subheading-text: (
    font: themes.fonts.sans.family,
    size: eval(settings.font.size.description),
    weight: "bold",
    fill: themes.light.foreground,
  ),
  aside-side: "left",
  primary-accent-color: themes.light.accent,
  secondary-accent-color: themes.light.accent.darken(12%),
  primary-text-color: themes.light.foreground,
  secondary-text-color: themes.light.foreground,
  faint-text-color: themes.light.muted,
  profile-image-enabled: with-image,
  profile-image-size: 90%,
  profile-image-stroke: themes.light.accent + themes.layout.borderWidth.small,
  profile-image-radius: themes.layout.radius.large,
  aside-width: 6.2cm,
  aside-background-color: themes.light.overlay,
  aside-name-text: (
    font: themes.fonts.sans.family,
    weight: "bold",
    size: eval(settings.font.size.heading_huge),
    style: "normal",
    fill: themes.light.foreground,
  ),
  aside-pronouns-text: (
    font: themes.fonts.sans.family,
    weight: "regular",
    size: eval(settings.font.size.tags),
    style: "normal",
    fill: themes.light.muted,
  ),
  aside-text: (
    font: themes.fonts.sans.family,
    weight: "regular",
    size: eval(settings.font.size.contacts),
    style: "normal",
    fill: themes.light.foreground,
  ),
  aside-grid-first-column-width: 1.35cm,
  aside-short-description-text: (
    font: themes.fonts.sans.family,
    weight: "medium",
    size: eval(settings.font.size.description),
    style: "normal",
    fill: themes.light.muted.mix(themes.light.foreground),
  ),
  aside-heading-text: (
    font: themes.fonts.sans.family,
    weight: "bold",
    size: eval(settings.font.size.heading),
    style: "normal",
    fill: themes.light.accent,
  ),
  aside-heading-line-enable: true,
  aside-heading-line-gap: 0.35em,
  aside-heading-line-opposite-gap: 0pt,
  aside-heading-line-thickness: themes.layout.borderWidth.small,
  aside-heading-line-cap: "butt",
  aside-heading-line-opposite-cap: "butt",
  aside-pill-box-inner: (
    fill: themes.light.info,
    outset: themes.layout.borderWidth.large,
    radius: themes.layout.radius.small,
  ),
  aside-pill-pad: (x: 4pt, y: 2pt),
  gutter-stroke: none,
  gutter-margin: 0.75cm,
)

#let aside-persona = make-aside-persona(
  configuration.contacts.name,
  short-description: configuration.contacts.title,
  image: pad(image("src/sensitive/avatar.jpg"), top: 2mm),
  theme: cv-theme,
)

#let aside-content = [
  #show: pad.with(left: -2.5mm)
  #aside-persona

  == #section-labels.profile
  #make-aside-grid(
    theme: cv-theme,
    columns: (auto, 1fr),
    [#section-labels.email],
    [#link(
      "mailto:" + configuration.contacts.email,
    )[#configuration.contacts.email]],
    [#section-labels.phone],
    [#link(
      "tel:" + configuration.contacts.phone,
    )[#configuration.contacts.phone]],
    [#section-labels.location],
    [#configuration.contacts.city, #configuration.contacts.homecountry],
    [#section-labels.linkedin],
    [#link(configuration.contacts.linkedin)[#configuration.contacts.linkedin]],
    [#section-labels.github],
    [#link(configuration.contacts.github)[#configuration.contacts.github]],
    [#section-labels.website],
    [#link(configuration.contacts.website)[#configuration.contacts.website]],
  )

  == #section-labels.skills
  #for skill in configuration.skills [
    #block(below: 0.55em)[
      #text(weight: "bold", size: eval(
        settings.font.size.description,
      ))[#skill.category] \\
      #text(
        size: eval(settings.font.size.tags),
        fill: themes.light.muted,
      )[#skill.items.join(" · ")]
    ]
  ]
  #v(1em)

  == #section-labels.hobbies
  #for hobby in configuration.hobbies [
    #block(below: 0.55em)[
      #text(weight: "bold", size: eval(
        settings.font.size.description,
      ))[#hobby.category] \\
      #text(
        size: eval(settings.font.size.tags),
        fill: themes.light.muted,
      )[#hobby.items.join(" · ")]
    ]
  ]
]

#let periods(item) = {
  if "from" in item and "to" in item {
    (
      align(top, layout(parent-dims => [
        #show: box
        #let dims = measure(box(width: parent-dims.width, item.to))
        #place(box(
          width: dims.width,
          height: dims.height + 2mm,
          fill: themes.light.surface,
        ))
        #item.to
      ])),
      align(bottom, layout(parent-dims => [
        #show: box
        #let dims = measure(box(width: parent-dims.width, item.from))
        #place(box(
          width: dims.width,
          height: dims.height + 2mm,
          fill: themes.light.surface,
        ))
        #item.from
      ])),
    )
  } else if "year" in item {
    [#item.year]
  } else {
    []
  }
}

#let job-entry(job) = make-main-content-block-with-timeline(
  periods(job),
  job.position,
  [
    #set par(justify: true, leading: eval(settings.paragraph.leading))
    #grid(
      columns: (1fr, auto),
      job
        .tags
        .map(tag => make-pill(
          text(tag, size: eval(settings.font.size.tags), fill: themes.light.surface),
          cv-theme,
        ))
        .join(h(0.35em)),
      if "location" in job [
        #show: pad.with(top: 2pt)
        #text(fill: themes.light.muted, size: eval(
          settings.font.size.tags,
        ))[#job.location]],
    )
    #v(-0.35em)
    #list(..job.description)
  ],
  supplement: [#link(job.company.link)[#job.company.name]],
  theme: cv-theme,
)

#let education-entry(place) = {
  let institution = link(place.place.link)[#place.place.name]
  let qualification = [#place.degree in #place.major]
  if "track" in place { qualification += [, #place.track~track] }
  let details = ()
  if "final_work" in place and "name" in place.final_work {
    let thesis-link = place.final_work.at("link", default: none)
    let thesis-name = place.final_work.name
    if thesis-link != none and type(thesis-link) == dictionary {
      let thesis-url = thesis-link.at("url", default: thesis-link.at(
        "link",
        default: none,
      ))
      if thesis-url != none {
        details.push(
          [*#section-labels.thesis:* #link(thesis-url)[#thesis-name]],
        )
      } else {
        details.push([*#section-labels.thesis:* #thesis-name])
      }
    } else if thesis-link != none {
      details.push([*#section-labels.thesis:* #link(thesis-link)[#thesis-name]])
    } else {
      details.push([*#section-labels.thesis:* #thesis-name])
    }
  }
  if "location" in place {
    details.insert(0, [
      #h(1fr)
      #show: text.with(fill: themes.light.muted, size: eval(
        settings.font.size.tags,
      ))
      #place.location
    ])
  }
  make-main-content-block-with-timeline(
    periods(place),
    qualification,
    details.join(linebreak()),
    supplement: institution,
    theme: cv-theme,
  )
  //   make-main-content-block-with-timeline(
  //   periods(job),
  //   job.position,
  //   [
  //     #set par(justify: true, leading: eval(settings.paragraph.leading))
  //     #grid(
  //       columns: (1fr, auto),
  //       job.tags.map(tag => make-pill(text(tag, size: eval(settings.font.size.tags)), cv-theme)).join(h(0.35em)),
  //       if "location" in job [
  //         #show: pad.with(top: 2pt)
  //         #text(fill: themes.light.muted, size: eval(settings.font.size.tags))[#job.location]],
  //     )
  //     #v(-0.35em)
  //     #list(..job.description)
  //   ],
  //   supplement: [#link(job.company.link)[#job.company.name]],
  //   theme: cv-theme,
  // )
}

#let certification-entry(certificate) = {
  let certificate-period = if "from" in certificate and "to" in certificate {
    ([#certificate.from], [#certificate.to])
  } else {
    [#certificate.year]
  }
  let supplement = if "certificate_link" in certificate {
    [#link(certificate.certificate_link)[#section-labels.credential]]
  } else {
    none
  }
  make-main-content-block-with-timeline(
    certificate-period,
    certificate.venue.name,
    [
      #set par(justify: true, leading: eval(settings.paragraph.leading))
      #list(certificate.description)
    ],
    supplement: supplement,
    theme: cv-theme,
  )
}

#let achievement-entry(achievement) = [
  #block(below: 1.6em)[
    #text(weight: "bold", fill: themes.light.foreground)[
      #if "link" in achievement [#link(
        achievement.link,
      )[#achievement.name]] else [#achievement.name]
    ]
    #if "description" in achievement [
      #linebreak()
      #text(fill: themes.light.muted, size: eval(
        settings.font.size.tags,
      ))[#achievement.description]
    ]
    #v(-0.4em)
    #grid(
      columns: (1.25cm, 1fr),
      row-gutter: 0.6em,
      column-gutter: 0.5em,
      ..for win in achievement.wins {
        (
          text(weight: "bold", fill: themes.light.accent)[#win.year],
          [#if "placement" in win [*#win.placement* – ]#win.category],
        )
      }
    )
  ]
]

#let main-page-one = [
  == #section-labels.summary
  #par(justify: true, leading: eval(
    settings.paragraph.leading,
  ))[#configuration.summary]

  == #section-labels.experience
  #for job in configuration.jobs [#job-entry(job)]

  == #section-labels.education
  #for place in configuration.education [#education-entry(place)]
]

#let main-page-two = [
  == #section-labels.certifications
  #for certificate in configuration.certifications [#certification-entry(
    certificate,
  )]

  == #section-labels.achievements
  #for achievement in configuration.achievements [

    #achievement-entry(achievement)
  ]

  #if with-signature [
    #v(0.7em)
    #line(length: 100%, stroke: 0.5pt + themes.light.neutral)
    #v(0.5em)
    #grid(
      columns: (1fr, auto),
      align: (left, horizon),
      [
        #set text(size: eval(settings.font.size.description))
        #section-labels.declaration \
        *#configuration.contacts.name*, #datetime.today().display()
      ],
      image("src/sensitive/signature.svg", height: 3em),
    )
  ]
]

#impression-cv(
  theme: cv-theme,
  paper: "a4",
  pages-content: (
    (
      "left": aside-content,
      "main": {
        main-page-one
        main-page-two
      },
    ),
    //("left": aside-content, "main": main-page-two),
  ),
)
