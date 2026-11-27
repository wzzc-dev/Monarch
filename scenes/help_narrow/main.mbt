///|
/// Screenshot scene: the keyboard-shortcuts card at phone width.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_help_model())
}
