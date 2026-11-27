///|
/// Projects with the delete-worktree confirmation open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_delete_worktree_model())
}
