///|
/// Tasks page with the new-task composer open and no title typed yet.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model({
    ..@app.scene_tasks_model(),
    task_composer_open: true,
    sidebar_open: false,
  })
}
