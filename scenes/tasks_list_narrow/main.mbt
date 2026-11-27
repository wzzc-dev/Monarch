///|
/// Narrow Tasks list with the single-pane detail closed.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_tasks_list_narrow_model())
}
