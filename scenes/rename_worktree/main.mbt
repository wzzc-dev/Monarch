///|
/// Projects with the rename-worktree dialog open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_rename_worktree_model())
}
