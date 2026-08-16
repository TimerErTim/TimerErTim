#let input-theme-name = sys.inputs.at(
  "x-theme",
  default: sys.inputs.at("theme", default: "light"),
)
#let now = datetime.today(offset: 0)

#let themed(light-variant, dark-variant) = if input-theme-name == "dark" {
  dark-variant
} else {
  light-variant
}

#let config = json("../config/values.json")
