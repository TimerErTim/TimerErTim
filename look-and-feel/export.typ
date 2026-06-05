#import "index.typ": themes

#let _convert-to-hex-colors(input) = {
  if type(input) == dictionary {
    input
      .pairs()
      .map(((key, value)) => {
        (key, _convert-to-hex-colors(value))
      })
      .to-dict()
  } else if type(input) == array {
    input.map(_convert-to-hex-colors)
  } else if type(input) == color {
    rgb(input).to-hex()
  } else {
    input
  }
}

#let _convert-to-js-units(input) = {
  if type(input) == dictionary {
    input
      .pairs()
      .map(((key, value)) => {
        (key, _convert-to-js-units(value))
      })
      .to-dict()
  } else if type(input) == array {
    input.map(_convert-to-js-units)
  } else if type(input) == length {
    input.pt()
  } else {
    input
  }
}

#metadata((themes,).map(_convert-to-js-units).map(_convert-to-hex-colors).first()) <themes>
