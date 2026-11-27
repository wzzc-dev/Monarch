///|
/// Screenshot scene: the Bots composer after the local dictation demo runs.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_dictation_model())
}
