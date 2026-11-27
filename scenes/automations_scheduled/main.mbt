///|
/// Automations page after the host timer has armed the enabled schedules.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_automations_scheduled_model())
}
