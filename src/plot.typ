#import "deps.typ": *
#import "common.typ": _parse-inter-key

#let _barchart(
  /// -> "h" | "v"
  orientation,
  /// -> array
  data,
  /// -> float | none
  width: none,
  /// -> float | none
  gap: none,
  /// -> float | none
  max-length: none,
  /// -> bool
  show-axes: false,
  /// -> float | auto
  tick-step: auto
) = {
  import cetz.draw: *
  import calc: log, floor, ceil, pow, sqrt

  let max = calc.max(..data, 1)
  let style = (stroke: none, fill: black)

  let tick-step = if tick-step == auto {
    let b = max / pow(10, floor(log(max)))

    let k = if b < 1 {
      0.1
    } else if b < 2.5 {
      0.5
    } else {
      1
    }

    k * pow(10, floor(log(max)))
  } else {
    tick-step
  }

  if max / tick-step > 8 {
    tick-step *= 2
  }

  let n-ticks = ceil(max / tick-step) + 1
  let actual-max = n-ticks * tick-step

  let D = -0.05

  if orientation == "h" {
    for (i, y) in data.enumerate() {
      let x = (i + 1) * gap + i * width
      rect((x, 0), (x + width, y / actual-max * max-length), ..style)
    }

    if show-axes {
      line((D, 0), (D, max / actual-max * max-length))

      for i in range(n-ticks) {
        let u = i / (n-ticks - 1) * max / actual-max * max-length
        
        line((D + 0.05, u), (D - 0.05, u))
        content(anchor: "east", (D - 0.15, u), [
          #set text(8pt)
          $#(i * tick-step)$
        ])
      }
    }
  } else {
    for (i, x) in data.rev().enumerate() {
      let y = (i + 1) * gap + i * width
      rect((max-length - x / max * max-length, y), (max-length, y + width), ..style)
    }

    if show-axes {
      line((0, D), (max-length, D))

      for i in range(n-ticks) {
        let u = i / (n-ticks - 1) * max-length

        line((u, D + 0.05), (u, D - 0.05))
        content(anchor: "north", (u, D - 0.15), [
          #set text(8pt)  
          $#((n-ticks - 1 - i) * tick-step)$
        ])
      }
    }
  }
}

#let _interchart(
  /// -> "h" | "v"
  orientation,
  /// -> dictionary
  sets,
  /// -> array
  inter,
  /// -> str
  delim,
  /// -> float | none
  width: none,
   /// -> float | none
  gap-sets: none,
  /// -> float | none
  gap-inter: none
) = {
  import cetz.draw: *

  let n = sets.len()
  let m = inter.len()
  let r = width / 2

  if orientation == "v" {
    inter = inter.rev()
  }

  let coord(x, y) = if orientation == "h" {
    (x, y)
  } else {
    (y, x)
  }

  for (i, s) in inter.enumerate() {
    let inter-dict = _parse-inter-key(s, delim)

    let min = n - 1
    let max = 0

    for (s, j) in sets.pairs() {
      let k = if orientation == "h" {
        n - j - 1
      } else {
        j
      }

      let args = arguments(coord(gap-inter + i * (width + gap-inter) + r, gap-sets + k * (width + gap-sets) + r), radius: 0.8 * r, stroke: none)
      
      if s in inter-dict {
        on-layer(1, circle(..args, fill: black))

        if k < min { min = k }
        if k > max { max = k }
      } else {
        circle(..args, fill: black.lighten(80%))
      }

      if min < max {
        rect(
          coord(
            gap-inter + i * (width + gap-inter) + 0.65 * r,
            gap-sets + min * (width + gap-sets) + 0.65 * r
          ),
          coord(
            gap-inter + i * (width + gap-inter) + 1.35 * r,
            gap-sets + max * (width + gap-sets) + 1.35 * r              
          ),
          stroke: none,
          fill: black
        )
      }
    }
  }
  
  for (s, i) in sets.pairs() {
    if calc.rem-euclid(i, 2) != 0 { continue }

    on-layer(-1, rect(
      coord(0, i * (width + gap-sets) + gap-sets/2),
      coord(gap-inter + m * (width + gap-inter), (i + 1) * (width + gap-sets) + gap-sets/2),
      stroke: none,
      fill: black.lighten(96%)
    ))
  }
}
