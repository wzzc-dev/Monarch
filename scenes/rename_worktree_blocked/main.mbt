///|
/// Rename dialog with a blank name, showing the disabled Rename action.
pub fn program() -> @moui.Program[@app.Model, @app.Msg] {
  @app.program_with_model({
    ..@app.scene_rename_worktree_model(),
    rename_draft: "",
  })
}
