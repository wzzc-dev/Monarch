///|
let web_state_key : String = "orca-moui.state"

///|
fn settings_read(services : @services.AppServices, key : String) -> String? {
  let value : Ref[String?] = Ref(None)
  let task = services.settings().read(key)
  let _ = task.start(fn(result) {
    match result {
      Success(text) => value.val = text
      _ => ()
    }
  })
  value.val
}

///|
fn settings_write(
  services : @services.AppServices,
  key : String,
  payload : String,
) -> Unit {
  let task = services.settings().write(key, payload)
  let _ = task.start(fn(_result) { () })
}

///|
fn web_state_transport() -> @core.ProgramStateTransport {
  let services = @web.web_app_services()
  @core.ProgramStateTransport::new(
    read=fn() { settings_read(services, web_state_key) },
    write=fn(payload) { settings_write(services, web_state_key, payload) },
  )
}

///|
fn main {
  let timer = @web.web_timer_source()
  let runtime = @runtime.new_program_with_dimensions(
    program=@app.program_with_timer(timer),
    width=1280.0,
    height=800.0,
    state_transport=Some(web_state_transport()),
  )
  @apphost.run_app("Orca", runtime)
  .render_all(@webgpu_adapter.from_env())
  .backend(@web.entry())
  .run()
}

///|
pub fn web_dispatch_event(
  kind : Int32,
  raw_id : Int32,
  arg0 : Int32,
  arg1 : Int32,
  argd : Double,
  text_id : Int32,
) -> Unit {
  @web.web_dispatch_event(kind, raw_id, arg0, arg1, argd, text_id)
}

///|
pub fn web_dispatch_pointer_input(
  raw_id : Int32,
  kind : Int32,
  x_px : Double,
  y_px : Double,
  delta_x_px : Double,
  delta_y_px : Double,
  button : Int32,
  modifiers : Int32,
  pointer_id : Int32,
  pressure : Double,
) -> Int32 {
  @web.web_dispatch_pointer_input(
    raw_id, kind, x_px, y_px, delta_x_px, delta_y_px, button, modifiers, pointer_id,
    pressure,
  )
}

///|
pub fn web_dispatch_route(source_code : Int32, text_id : Int32) -> Unit {
  @web.web_dispatch_route(source_code, text_id)
}

///|
pub fn web_dispatch_semantics_action(
  raw_id : Int32,
  node_id_text_id : Int32,
  generation_text_id : Int32,
  action_code : Int32,
  value_id : Int32,
  direction_code : Int32,
) -> Unit {
  @web.web_dispatch_semantics_action(
    raw_id, node_id_text_id, generation_text_id, action_code, value_id, direction_code,
  )
}

///|
pub fn web_complete_async_clipboard_read(
  request_id : Int32,
  ok : Bool,
  text_id : Int32,
) -> Unit {
  @web.web_complete_async_clipboard_read(request_id, ok, text_id)
}

///|
pub fn web_complete_async_file_dialog(
  request_id : Int32,
  ok : Bool,
  text_id : Int32,
) -> Unit {
  @web.web_complete_async_file_dialog(request_id, ok, text_id)
}
