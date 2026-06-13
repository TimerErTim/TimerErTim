#let lang = sys.inputs.at("lang", default: "en")

#let _merge_dicts(a, b) = {
  let merged = (:)
  for key in (a.keys() + b.keys()).dedup() {
    if key in a and key not in b {
      merged.insert(key, a.at(key))
      continue
    } else if key in b and key not in a {
      merged.insert(key, b.at(key))
      continue
    }

    let a-value = a.at(key)
    let b-value = b.at(key)

    if type(a-value) != type(b-value) {
      // b overrides a
      merged.insert(key, b-value)
      continue
    }

    if type(a-value) == array {
      merged.insert(key, a-value + b-value)
    } else if type(a-value) == dictionary {
      merged.insert(key, _merge_dicts(a-value, b-value))
    } else {
      merged.insert(key, b-value)
    }
  }

  return merged
}


#let get-configuration(lang) = {
  let global-config = json("../config/values.json")
  let cv-config = yaml("src/" + lang + ".yaml")
  cv-config.contacts.email = global-config.TIMERERTIM_EMAIL
  cv-config.contacts.phone = global-config.TIMERERTIM_PHONE
  cv-config.contacts.website = global-config.TIMERERTIM_SITE_ORIGIN
  cv-config.contacts.name = global-config.TIMERERTIM_LEGAL_NAME
  cv-config.contacts.linkedin = global-config.TIMERERTIM_LINKEDIN_URL
  cv-config.contacts.github = global-config.TIMERERTIM_GITHUB_URL
  return cv-config
}
#let configuration = get-configuration(lang)
#let add-sensitive-configuration(lang) = {
  let base = get-configuration(lang)
  let sensitive = yaml("src/sensitive/" + lang + ".yaml")
  return _merge_dicts(base, sensitive)
}
#let settings = yaml("settings.yaml")
#import "../look-and-feel/index.typ": themes


#let base-configuration(doc, lang: lang) = {
  set text(
    size: eval(settings.font.size.heading_large),
    font: themes.fonts.sans.family,
    lang: lang,
  )

  show link: set text(themes.light.info.lighten(25%))
  show link: underline

  set page(
    paper: "a4",
    margin: (
      top: 1.5cm,
      bottom: 1cm,
    ),
  )

  //show heading: set text(fill: themes.light.accent)
  show heading: h => [
    #set text(
      size: eval(settings.font.size.heading_large),
      font: themes.fonts.sans.family,
    )
    #set block(below: 0.75em)
    #h
  ]

  doc
}
