///|
/// Projects scene with the composer file picker filtered by checkout.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_composer_mentions_model())
}
