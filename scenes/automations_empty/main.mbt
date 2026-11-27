///|
/// Automations page with empty automation and run-history cards.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_automations_empty_model())
}
