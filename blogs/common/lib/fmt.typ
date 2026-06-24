#let _metric_suffix_thresholds = (
  (0, none),
  (3, $upright(k)$),
  (6, $upright(M)$),
  (9, $upright(G)$),
  (12, $upright(T)$),
  (15, $upright(P)$),
  (18, $upright(E)$),
).map(((exp, suffix)) => (calc.pow(10, exp), suffix))

#let num_metric_suffix(num, round_digits: 2) = {
  for i in range(_metric_suffix_thresholds.len()) {
    if calc.abs(num) < _metric_suffix_thresholds.at(i).at(0) {
      let idx = i - 1
      if idx < 0 {
        break
      }
      let (divisor, suffix) = _metric_suffix_thresholds.at(idx)
      return [
        #calc.round(digits: round_digits, num / divisor)#suffix
      ]
    }
  }
  return [
    #calc.round(digits: round_digits, num)
  ]
}
