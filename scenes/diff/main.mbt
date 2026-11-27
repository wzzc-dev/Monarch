///|
/// Diff review scene with a line note open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_diff_model())
}
