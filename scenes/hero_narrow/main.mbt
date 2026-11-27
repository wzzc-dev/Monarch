///|
/// Projects at a phone width with the sidebar drawer closed.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_hero_narrow_model())
}
