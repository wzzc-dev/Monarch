///|
/// The Orca program at the default seed state.
pub fn program() -> @moui.Program[Model, Msg] {
  program_with_model(Model::new())
}

///|
/// Build the Orca program around a given starting model.
pub fn program_with_model(model : Model) -> @moui.Program[Model, Msg] {
  @moui.Program::simple_with_environment(
    init=model,
    update=update,
    view=view,
  )
}
