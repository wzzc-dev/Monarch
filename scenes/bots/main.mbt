///|
/// Phase-2 screenshot scene: the Bots three-pane screen.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_bots_model())
}
