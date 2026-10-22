#import "../../common/theming.typ": catppuccin-accents, theme

// 16:9 canvas the annotated room illustration was designed on in the
// presentation, all box positions below are relative to it
#let canvas-width = 841.88976378pt
#let canvas-height = 473.562992126pt

#let room-objects = (
  (
    label: [Insufflator],
    color: catppuccin-accents.red,
    pos: (1cm, 2cm),
    dims: (3cm, 8cm),
    fields: [`gas_flow_l_min`, `target_pressure_mmhg`, `insufflator_active`],
  ),
  (
    label: [Light],
    color: catppuccin-accents.yellow,
    pos: (12cm, 0.5cm),
    dims: (5.5cm, 2cm),
    fields: [`light_brightness`, `light_mode`],
  ),
  (
    label: [Table],
    color: catppuccin-accents.blue,
    pos: (10cm, 11cm),
    dims: (9.5cm, 4.5cm),
    fields: [`table_tilt_degrees`, `table_height_cm`],
  ),
  (
    label: [Endoscope],
    color: catppuccin-accents.green,
    pos: (19.5cm, 2.25cm),
    dims: (9cm, 6cm),
    fields: [`zoom_level`, `white_balance_locked`, `irrigation_active`],
  ),
)

// The virtual room illustration with the controlled equipment highlighted by
// colored boxes, reused from the presentation
#let annotated-room(width: 100%) = layout(avail => {
  let full = if width == 100% { avail.width } else { width }
  let scale = full / canvas-width
  let height = canvas-height * scale
  block(
    width: full,
    height: height,
    clip: true,
    breakable: false,
    {
      image(
        "../assets/operating_room.png",
        width: 100%,
        height: 100%,
        fit: "stretch",
        alt: "Virtual operating room with the insufflator, light, table, and endoscope highlighted in color",
      )
      for obj in room-objects {
        place(
          left + top,
          dx: obj.pos.at(0) * scale,
          dy: obj.pos.at(1) * scale,
          box(
            width: obj.dims.at(0) * scale,
            height: obj.dims.at(1) * scale,
            stroke: obj.color + theme.layout.borderWidth.large,
            radius: theme.layout.radius.large,
            place(
              left + bottom,
              dy: 1.25em,
              strong(text(fill: obj.color, obj.label)),
            ),
          ),
        )
      }
    },
  )
})

// Object to field mapping table, colored to match the highlighted room,
// styled like the other tables in this blog post
#let room-fields-table() = {
  show table.cell.where(y: 0): strong
  set table.cell(stroke: none)
  table(
    columns: 2,
    column-gutter: 1em,
    inset: 0.5em,
    align: left,
    table.header([Object], [Example fields]),
    table.hline(stroke: theme.colors.border + theme.layout.borderWidth.medium),
    ..room-objects
      .map(obj => (
        table.hline(
          stroke: theme.colors.border + theme.layout.borderWidth.small,
        ),
        table.cell(text(fill: obj.color, strong(obj.label))),
        obj.fields,
      ))
      .flatten(),
  )
}
