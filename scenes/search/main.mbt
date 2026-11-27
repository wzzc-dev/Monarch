///|
/// Search page scene with a representative query.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_search_model())
}
