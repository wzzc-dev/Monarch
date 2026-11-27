///|
/// Phone-width Diff review with the file picker open.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model({
    ..@app.scene_diff_model(),
    diff_file_menu_open: true,
  })
}
