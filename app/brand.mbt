///|
/// Claude mark: a simple eight-spoke starburst, which reads like the Claude
/// asterisk at 14 px without the heavy outline a stroked blob path produces.
let svg_claude : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M12 2V22M3.34 7L20.66 17M20.66 7L3.34 17\"/></svg>"

///|
/// Codex mark: a hexagonal knot silhouette in mint.
let svg_codex : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M12 2.6L20.1 7.3V16.7L12 21.4L3.9 16.7V7.3ZM8.2 12H15.8\"/></svg>"

///|
/// Loader circle, three-quarter stroke.
let svg_loader : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M21 12a9 9 0 1 1-6.219-8.56\"/></svg>"

///|
/// Microphone.
let svg_mic : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M12 19V22M19 10v2a7 7 0 0 1-14 0v-2M15 5a3 3 0 0 0-6 0v5a3 3 0 0 0 6 0z\"/></svg>"

///|
/// Arrow up, used by the composer send button.
let svg_arrow_up : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M12 19V5M5 12L12 5L19 12\"/></svg>"

///|
/// Arrow up-right, used by worker cards.
let svg_arrow_up_right : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M7 17L17 7M7 7L17 7L17 17\"/></svg>"

///|
/// Sliders, used by the Projects header.
let svg_sliders : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M10 5H3M12 19H3M14 3V7M16 17V21M21 12H12M21 19H16M21 5H14M8 10V14M8 12H3\"/></svg>"

///|
/// Folder with a plus, used by the Projects header.
let svg_folder_plus : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M12 10V16M9 13H15M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z\"/></svg>"

///|
/// Shield with an alert, used by the composer access chip.
let svg_shield_alert : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1zM12 8V12M12 16h.01\"/></svg>"

///|
/// Double chevron used by select controls.
let svg_chevrons_up_down : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M7 15L12 20L17 15M7 9L12 4L17 9\"/></svg>"

///|
/// Sparkles used by the modal "Smart" chip.
let svg_sparkles : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M11.017 2.814a1 1 0 0 1 1.966 0l1.051 5.558a2 2 0 0 0 1.594 1.594l5.558 1.051a1 1 0 0 1 0 1.966l-5.558 1.051a2 2 0 0 0-1.594 1.594l-1.051 5.558a1 1 0 0 1-1.966 0l-1.051-5.558a2 2 0 0 0-1.594-1.594l-5.558-1.051a1 1 0 0 1 0-1.966l5.558-1.051a2 2 0 0 0 1.594-1.594z\"/></svg>"

///|
/// Code brackets with absolute subpath starts.
let svg_code : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M9 18L3 12L9 6M15 6L21 12L15 18\"/></svg>"

///|
/// Close cross with explicit line commands.
let svg_x : String = "<svg viewBox=\"0 0 24 24\"><path d=\"M18 6L6 18M6 6L18 18\"/></svg>"

///|
/// The brand glyph for an agent family.
pub fn brand_icon(kind : AgentKind, size : Double) -> @moui.View[Msg] {
  match kind {
    Claude =>
      @views.icon_svg(
        svg_claude,
        size=size,
        color=accent_claude,
        stroke_width=2.1,
        label="Claude",
      )
    Codex =>
      @views.icon_svg(
        svg_codex,
        size=size,
        color=accent_codex,
        stroke_width=1.8,
        label="Codex",
      )
    Grok =>
      x_icon(size, accent_grok)
  }
}

///|
/// Small amber progress ring for a running or working agent.
pub fn spinner(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    svg_loader,
    size=size,
    color=color,
    stroke_width=2.0,
    label="Working",
  )
}

///|
/// A plain filled dot.
pub fn status_dot(color : @graphics.Color, size : Double) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width=size,
    height=size,
    background=color,
    corner_radius=size / 2.0,
    padding=0.0,
  )
}

///|
/// Agent status indicator: amber spinner, green done dot or gray idle dot.
pub fn status_indicator(status : AgentStatus) -> @moui.View[Msg] {
  match status {
    Running => spinner(9.0, accent_amber)
    Working => spinner(9.0, accent_amber)
    Done => status_dot(accent_green, 6.0)
    Idle => status_dot(fg_dim, 6.0)
  }
}

///|
/// A green ring with a check, used on the front of an active tab.
pub fn done_badge() -> @moui.View[Msg] {
  @views.container(
    @views.lucide_icon("check", size=8.0, color=accent_green, stroke_width=2.4),
    width=12.0,
    height=12.0,
    background=@graphics.Color::rgba(r=52.0 / 255.0, g=211.0 / 255.0, b=153.0 / 255.0, a=0.16),
    corner_radius=6.0,
    border=Some(border_of(@graphics.Color::rgba(r=52.0 / 255.0, g=211.0 / 255.0, b=153.0 / 255.0, a=0.5), 1.0)),
    padding=0.0,
  )
}

///|
/// Small mic icon for the composer footer.
pub fn mic_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_mic, size=size, color=color, stroke_width=1.7)
}

///|
/// Arrow-up icon for the circular send button.
pub fn arrow_up_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_arrow_up, size=size, color=color, stroke_width=1.8)
}

///|
/// Arrow up-right icon for worker card headers.
pub fn arrow_up_right_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_arrow_up_right, size=size, color=color, stroke_width=1.7)
}

///|
/// Shield-alert icon for the composer's Full access chip.
pub fn shield_alert_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_shield_alert, size=size, color=color, stroke_width=1.7)
}

///|
/// Sliders icon for the Projects header.
pub fn sliders_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_sliders, size=size, color=color, stroke_width=1.7)
}

///|
/// Folder-plus icon for the Projects header.
pub fn folder_plus_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_folder_plus, size=size, color=color, stroke_width=1.7)
}

///|
/// Chevrons-up-down icon for the modal select controls.
pub fn chevrons_up_down_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_chevrons_up_down, size=size, color=color, stroke_width=1.7)
}

///|
/// Sparkles icon for the modal's Smart chip.
pub fn sparkles_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_sparkles, size=size, color=color, stroke_width=1.5)
}

///|
/// Code brackets used by the modal GitHub chip.
pub fn code_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_code, size=size, color=color, stroke_width=1.8)
}

///|
/// Close cross used by tab and modal close buttons.
pub fn x_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_x, size=size, color=color, stroke_width=1.8, label="Close")
}

///|
/// Folder icon for project selects.
pub fn folder_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.lucide_icon("folder", size=size, color=color, stroke_width=1.8)
}

///|
/// Loader-circle icon for the live "Working…" row.
pub fn loader_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(svg_loader, size=size, color=color, stroke_width=1.8)
}
