///|
/// Screenshot scene: a newly added bot after its first Home Chat message.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  let added = @app.update(@app.scene_bots_model(), @app.AddBot)
  let typed = @app.update(
    added,
    @app.DraftInput("Draft a release checklist for 4.13"),
  )
  @app.program_with_model(@app.update(typed, @app.Send))
}
