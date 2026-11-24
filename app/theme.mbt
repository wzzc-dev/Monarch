///|
/// Orca palette. Single source of truth for every colour in the app.
let bg_outer : @graphics.Color = @graphics.Color::from_argb(0xFF0A0A0A)

///|
let bg_main : @graphics.Color = @graphics.Color::from_argb(0xFF151515)

///|
let bg_sidebar : @graphics.Color = @graphics.Color::from_argb(0xFF2A2A2A)

///|
let bg_tabbar : @graphics.Color = @graphics.Color::from_argb(0xFF171717)

///|
let bg_card : @graphics.Color = @graphics.Color::from_argb(0xFF171717)

///|
let bg_machine : @graphics.Color = @graphics.Color::from_argb(0xFF323232)

///|
let bg_selected : @graphics.Color = @graphics.Color::from_argb(0xFF3F3F3F)

///|
let bg_bubble : @graphics.Color = @graphics.Color::from_argb(0xFF252525)

///|
let bg_send : @graphics.Color = @graphics.Color::from_argb(0xFF262626)

///|
let bg_field : @graphics.Color = @graphics.Color::from_argb(0xFF1D1D1D)

///|
let bg_field_focus : @graphics.Color = @graphics.Color::from_argb(0xFF191919)

///|
let fg_primary : @graphics.Color = @graphics.Color::from_argb(0xFFF0F0F0)

///|
let fg_bubble : @graphics.Color = @graphics.Color::from_argb(0xFFDADADA)

///|
let fg_body : @graphics.Color = @graphics.Color::from_argb(0xFFC0C0C0)

///|
let fg_secondary : @graphics.Color = @graphics.Color::from_argb(0xFFACACAC)

///|
let fg_muted : @graphics.Color = @graphics.Color::from_argb(0xFF929292)

///|
let fg_dim : @graphics.Color = @graphics.Color::from_argb(0xFF6F6F6F)

///|
let accent_claude : @graphics.Color = @graphics.Color::from_argb(0xFFD97757)

///|
let accent_codex : @graphics.Color = @graphics.Color::from_argb(0xFF34D399)

///|
let accent_grok : @graphics.Color = @graphics.Color::from_argb(0xFFC0C0C0)

///|
let accent_amber : @graphics.Color = @graphics.Color::from_argb(0xFFFBBF24)

///|
let accent_full_access : @graphics.Color = @graphics.Color::from_argb(0xFFEAB308)

///|
let accent_globe : @graphics.Color = @graphics.Color::from_argb(0xFF60A5FA)

///|
let accent_folder : @graphics.Color = @graphics.Color::from_argb(0xFFF59E0B)

///|
let accent_green : @graphics.Color = @graphics.Color::from_argb(0xFF34D399)

///|
let traffic_red : @graphics.Color = @graphics.Color::from_argb(0xFFFF5F57)

///|
let traffic_yellow : @graphics.Color = @graphics.Color::from_argb(0xFFFFBD2E)

///|
let traffic_green : @graphics.Color = @graphics.Color::from_argb(0xFF28C840)

///|
/// White with alpha, for Orca's translucent hairlines and badge fills.
pub fn white_a(a : Double) -> @graphics.Color {
  @graphics.Color::rgba(r=1.0, g=1.0, b=1.0, a~)
}

///|
/// Black with alpha, used by the modal scrim and shadows.
pub fn black_a(a : Double) -> @graphics.Color {
  @graphics.Color::rgba(r=0.0, g=0.0, b=0.0, a~)
}

///|
/// A one-pixel border in the given colour.
pub fn border_of(color : @graphics.Color, width : Double) -> @graphics.BorderStyle {
  @graphics.BorderStyle::new(brush=@graphics.Brush::Solid(color), width~)
}

///|
/// Main-app hairline: rgba(255,255,255,0.07).
pub fn hairline() -> @graphics.BorderStyle {
  border_of(white_a(0.07), 1.0)
}

///|
/// Orca's compositor hairline: rgba(240,240,240,0.09).
pub fn composer_border() -> @graphics.BorderStyle {
  border_of(@graphics.Color::rgba(r=240.0 / 255.0, g=240.0 / 255.0, b=240.0 / 255.0, a=0.09), 1.0)
}

///|
/// Selected-worktree border: rgba(255,255,255,0.24).
pub fn selected_border() -> @graphics.BorderStyle {
  border_of(white_a(0.24), 1.0)
}

///|
/// Orca UI sans font. The host has Inter installed and it closely tracks SF.
pub fn sans(size : Double, weight : Int32) -> @text.FontSpec {
  @text.FontSpec::new(
    families=@text.FontFamilyStack::named("Inter"),
    size~,
    weight~,
  )
}

///|
/// Sans font with an explicit line height for transcript copy.
pub fn sans_lh(size : Double, weight : Int32, line_height : Double) -> @text.FontSpec {
  @text.FontSpec::new(
    families=@text.FontFamilyStack::named("Inter"),
    size~,
    weight~,
    line_height~,
  )
}

///|
/// Monospace font used for branch names and code-ish labels.
pub fn mono(size : Double, weight : Int32) -> @text.FontSpec {
  @text.FontSpec::new(
    families=@text.FontFamilyStack::named("DejaVu Sans Mono"),
    size~,
    weight~,
  )
}

///|
/// Pinned dark theme. The app never follows `--scheme`.
pub fn orca_theme() -> @moui.Theme {
  @views.dark_theme()
}
