///|
/// Tasks page at a narrow viewport with the detail pane open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_tasks_narrow_model())
}
