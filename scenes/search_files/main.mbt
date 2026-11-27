///|
/// Search page scoped to files with the `@` prefix.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_search_files_model())
}
