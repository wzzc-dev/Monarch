///|
/// Bots Files panel with a query that matches indexed code content.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_files_model())
}
