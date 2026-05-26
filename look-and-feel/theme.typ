#let current-theme-name = sys.inputs.at("theme", default: "light")

#let load-theme(theme) = {
  let theme-data = json("heroui.json")

  let theme = theme-data.themes.at(theme)
  let convert-vals-to-oklch(input) = {
    if type(input) == dictionary {
      input
        .pairs()
        .map(((key, value)) => {
          (key, convert-vals-to-oklch(value))
        })
        .to-dict()
    } else if type(input) == list {
      input.map(convert-vals-to-oklch)
    } else {
      rgb(input).oklch()
    }
  }
  theme = convert-vals-to-oklch(theme)

  theme.layout = theme-data.layout
  let convert-vals-to-length(input) = {
    if type(input) == dictionary {
      input
        .pairs()
        .map(((key, value)) => {
          (key, convert-vals-to-length(value))
        })
        .to-dict()
    } else if type(input) == list {
      input.map(convert-vals-to-length)
    } else {
      if "px" in input {
        1pt * eval(input.replace("px", ""))
      } else if "rem" in input {
        16pt * eval(input.replace("rem", ""))
      } else if "em" in input {
        1em * eval(input.replace("em", ""))
      } else {
        100% * eval(input)
      }
    }
  }
  theme.layout = convert-vals-to-length(theme.layout)

  theme
}

#let current-theme = load-theme(current-theme-name)
