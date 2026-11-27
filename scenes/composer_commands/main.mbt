///|
/// Projects scene with the composer command picker open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_composer_commands_model())
}
