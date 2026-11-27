///|
/// Bots screen at a narrow viewport with the Home item panel open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_panel_narrow_model())
}
