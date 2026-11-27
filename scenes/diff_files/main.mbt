///|
/// Diff review scene with the file picker open from the tab-strip plus.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model(@app.scene_diff_files_model())
}
