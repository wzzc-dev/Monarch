///|
/// Automations at a narrow viewport with the sidebar drawer closed.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_automations_narrow_model())
}
