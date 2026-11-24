///|
fn main {
  let runtime = @runtime.new_program_with_dimensions(
    program=@app.program(),
    width=1280.0,
    height=800.0,
  )
  @apphost.run_app("Orca", runtime)
    .render_all(@render_skia.from_env(platform=@render_skia.NativeGpuPlatform::Linux))
    .backend(@platform_host.entry())
    .run()
}
