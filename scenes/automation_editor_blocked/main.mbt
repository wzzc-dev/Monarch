///|
/// Automations editor with a blank name, showing the disabled save state.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model({
    ..@app.scene_automation_editor_model(),
    automation_name: "",
  })
}
