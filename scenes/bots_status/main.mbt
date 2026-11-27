///|
/// Screenshot scene: the Bots Home status menu with an item-state override.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_status_model())
}
