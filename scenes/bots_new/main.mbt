///|
/// Screenshot scene: a newly added bot with its empty Home Chat.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.update(@app.scene_bots_model(), @app.AddBot))
}
