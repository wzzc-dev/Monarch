///|
test "web state helpers round-trip through the settings service" {
  let fake = @services.FakeAppServices::new()
  let services = fake.services()
  settings_write(services, "orca-moui.test", "{\"version\":1}")
  let restored = match settings_read(services, "orca-moui.test") {
    Some(text) => text
    None => ""
  }
  inspect(restored, content="{\"version\":1}")
  inspect(settings_read(services, "orca-moui.missing") is None, content="true")
}
