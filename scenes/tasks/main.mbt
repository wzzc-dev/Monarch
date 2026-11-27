///|
/// Tasks page scene with the P0 address task selected.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_tasks_model())
}
