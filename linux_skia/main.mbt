///|
fn state_transport_path() -> String {
  match @native.dev_state_transport_path() {
    Some(path) => path
    None => {
      let home = match @env.get_env_var("HOME") {
        Some(value) if value != "" => value
        _ => "."
      }
      "\{home}/.orca-moui-state.json"
    }
  }
}

///|
fn main {
  let state_path = state_transport_path()
  let state_transport = @native.dev_state_transport(state_path)
  let timer = @platform_host.linux_timer_source()
  let runtime = @runtime.new_program_with_dimensions(
    program=@app.program_with_timer(timer),
    width=1280.0,
    height=800.0,
    state_transport=Some(state_transport),
  )
  @apphost.run_app("Orca", runtime)
  .render_all(
    @render_skia.from_env(platform=@render_skia.NativeGpuPlatform::Linux),
  )
  .backend(@platform_host.entry())
  .run()
}
