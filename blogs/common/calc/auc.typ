#let auc(x, y) = {
  let area = 0
  let prev-x = x.at(0)
  let prev-y = y.at(0)
  for i in range(1, x.len()) {
    let curr-x = x.at(i)
    let curr-y = y.at(i)
    let dx = curr-x - prev-x
    let dy = curr-y - prev-y
    // If slope is negative, slop correction: only add if dx > 0
    if dx > 0 {
      // Trapezoidal rule, but clamp negative areas to 0 to ignore "slop"
      let segment = dx * (curr-y + prev-y) / 2
      area += if segment > 0 { segment } else { 0 }
    }
    prev-x = curr-x
    prev-y = curr-y
  }
  area
}
