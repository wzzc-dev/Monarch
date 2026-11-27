///|
/// Bots screen at a narrow viewport with both side panes tucked away.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_narrow_model())
}
