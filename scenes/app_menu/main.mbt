///|
/// Projects with the wordmark page menu open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_app_menu_model())
}
