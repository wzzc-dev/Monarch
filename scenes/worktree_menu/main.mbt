///|
/// Projects with the worktree context menu open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_worktree_menu_model())
}
