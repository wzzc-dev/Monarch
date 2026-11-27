///|
/// Tasks detail with the worktree picker open at phone width.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_tasks_link_phone_model())
}
