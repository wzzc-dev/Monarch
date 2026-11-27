///|
/// Diff review for the completed CI checks worktree.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_diff_checks_model())
}
