///|
/// Create-worktree modal scene with a typed worktree name.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_modal_model())
}
