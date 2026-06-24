#let smooth_series(series, strength: 0%) = {
  // Exponential smoothing, similar to Tensorflow (smoothing strength between 0 and 1)
  if series.len() == 0 {
    ()
  } else {
    let smooth = (series.at(0),)
    let strength = strength / 100%
    let alpha = 1.0 - strength
    for i in range(1, series.len()) {
      let last = smooth.last()
      let smoothed = strength * last + alpha * series.at(i)
      smooth.push(smoothed)
    }
    smooth
  }
}
