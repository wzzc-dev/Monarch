///|
/// Create-worktree modal scene with the Advanced section expanded.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_modal_advanced_model())
}
