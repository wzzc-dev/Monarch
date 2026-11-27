///|
/// Diff review at a narrow viewport with the two panes stacked.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_diff_model())
}
