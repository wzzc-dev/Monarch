///|
/// Automations page scene with the active automation list.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_automations_model())
}
