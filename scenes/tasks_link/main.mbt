///|
/// Tasks page with the worktree picker open on the selected task.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_tasks_link_model())
}
