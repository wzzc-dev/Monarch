///|
/// Automations page with the create dialog open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_automation_editor_model())
}
