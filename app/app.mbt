///|
/// The Orca program at the default seed state.
pub fn program() -> @moui.Program[Model, Msg] {
  program_with_model(Model::new()).with_state_persistence(
    save=save_model_json,
    load=load_model_json,
  )
}

///|
/// The production program wires the platform timer into the automations
/// scheduler. The timer carries the host's monotonic frame time; the model
/// turns that into cadence-based due times while the app stays open.
pub fn program_with_timer(
  timer : @services.TimerSource,
) -> @moui.Program[Model, Msg] {
  program_with_timer_model(Model::new(), timer).with_state_persistence(
    save=save_model_json,
    load=load_model_json,
  )
}

///|
/// Build the Orca program around a given starting model.
pub fn program_with_model(model : Model) -> @moui.Program[Model, Msg] {
  @moui.Program::simple_with_environment(init=model, update~, view~)
}

///|
/// Build the Orca program with a host timer subscription. Scenes and tests
/// keep using `program_with_model`, so screenshots stay deterministic.
pub fn program_with_timer_model(
  model : Model,
  timer : @services.TimerSource,
) -> @moui.Program[Model, Msg] {
  @moui.Program::simple_with_environment(init=model, update~, view~, subscriptions=fn(
    _model,
  ) {
    timer.subscription(
      interval_ms=30000.0,
      map=fn(frame) { AutomationTick(frame.time_ms) },
      key="orca/automation-scheduler",
      label="Automation scheduler",
    )
  })
}
