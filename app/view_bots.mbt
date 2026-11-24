///|
/// Width of the bots sidebar, per the phase-2 spec.
let bots_sidebar_width : Double = 272.0

///|
/// Width of the right item panel.
let bots_right_width : Double = 380.0

///|
/// Height of the shared top bar.
let bots_top_height : Double = 36.0

///|
/// Height of the full-width status bar.
let bots_status_height : Double = 24.0

///|
/// Slack brand colours, drawn as a 2×2 block mark.
let slack_blue : @graphics.Color = @graphics.Color::from_argb(0xFF36C5F0)

///|
let slack_green : @graphics.Color = @graphics.Color::from_argb(0xFF2EB67D)

///|
let slack_red : @graphics.Color = @graphics.Color::from_argb(0xFFE01E5A)

///|
let slack_yellow : @graphics.Color = @graphics.Color::from_argb(0xFFECB22E)

///|
/// A 1 px vertical separator.
fn vrule(height : Double) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width=1.0,
    height=height,
    background=white_a(0.07),
    padding=0.0,
  )
}

///|
/// Root layout for the three-pane Bots screen.
pub fn bots_screen(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  let body_height = height - bots_top_height - 2.0 - bots_status_height
  let center_width = width - bots_sidebar_width - bots_right_width - 2.0
  let top = @views.row(
    [
      bots_title_bar(),
      vrule(bots_top_height),
      bots_center_tabs(model, center_width),
      vrule(bots_top_height),
      bots_panel_tabs(model),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width=width, height=bots_top_height)
  let body = @views.row(
    [
      bots_sidebar(model, body_height),
      vrule(body_height),
      bots_chat(model, center_width, body_height),
      vrule(body_height),
      bots_panel(model, body_height),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width=width, height=body_height)
  @views.column(
    [
      top,
      @views.divider(color=white_a(0.07), thickness=1.0),
      body,
      @views.divider(color=white_a(0.10), thickness=1.0),
      bots_status_bar(width),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width=width, height=height).clip()
}

///|
/// Title bar segment over the sidebar: traffic lights, wordmark, panel toggle,
/// and the undo/redo history arrows at the band's right edge.
fn bots_title_bar() -> @moui.View[Msg] {
  let lights = @views.row(
    [
      traffic_light(traffic_red),
      traffic_light(traffic_yellow),
      traffic_light(traffic_green),
    ],
    spacing=8.0,
    align=Center,
  )
  let undo = @views.container(
    @views.icon_svg(
      "<svg viewBox=\"0 0 24 24\"><path d=\"M19 12H5M12 5l-7 7 7 7\"/></svg>",
      size=16.0,
      color=fg_muted,
      stroke_width=1.8,
    ),
    width=20.0,
    height=20.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(Noop)
  let redo = @views.container(
    @views.icon_svg(
      "<svg viewBox=\"0 0 24 24\"><path d=\"M5 12h14M12 5l7 7-7 7\"/></svg>",
      size=16.0,
      color=fg_muted,
      stroke_width=1.8,
    ),
    width=20.0,
    height=20.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(Noop)
  let content = @views.row(
    [
      lights,
      @views.spacer(min_length=40.0, weight=0.0),
      txt("Orca", 12.0, 600, fg_primary),
      @views.spacer(min_length=20.0, weight=0.0),
      @views.lucide_icon("panel-left", size=15.0, color=fg_muted, stroke_width=1.7),
      @views.spacer(weight=1.0),
      undo,
      @views.spacer(min_length=4.0, weight=0.0),
      redo,
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width=bots_sidebar_width,
    height=bots_top_height,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// Center tab strip: Scout, #eng, plus. The Scout tab starts flush at the
/// sidebar divider; undo/redo now live in the sidebar title bar.
fn bots_center_tabs(model : Model, width : Double) -> @moui.View[Msg] {
  let scout_tab = bot_center_tab(model, 0, "Scout", mascot_avatar(Scout, 16.0), 150.0, 100.0)
  let eng_tab = bot_center_tab(
    model,
    1,
    "#eng · checkout on Safari?",
    slack_icon(13.0),
    214.0,
    162.0,
  )
  let plus = @views.container(
    @views.lucide_icon("plus", size=15.0, color=fg_muted, stroke_width=1.8),
    width=40.0,
    height=bots_top_height,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(Noop)
  let content = @views.row(
    [scout_tab, vrule(bots_top_height), eng_tab, plus, @views.spacer(weight=1.0)],
    spacing=2.0,
    align=Center,
  ).frame(width=width)
  @views.container(
    content,
    width=width,
    height=bots_top_height,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// One center tab with icon, title and close cross.
fn bot_center_tab(
  model : Model,
  index : Int32,
  title : String,
  icon : @moui.View[Msg],
  width : Double,
  text_width : Double,
) -> @moui.View[Msg] {
  let active = model.center_tab == index
  let color = if active { fg_primary } else { fg_muted }
  let content = @views.row(
    [
      icon,
      @views.text(title, width=text_width, wrap=false, align=TextStart)
      .font(sans(13.0, if active { 500 } else { 400 }))
      .foreground(color),
      @views.spacer(weight=1.0),
      x_icon(13.0, fg_muted),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=width - 20.0)
  let panel = @views.container(
    @views.padding_edges(content, left=10.0, right=10.0),
    width=width,
    height=if active { bots_top_height - 2.0 } else { bots_top_height },
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
  let accent = @views.container(
    @views.empty(),
    width=width,
    height=2.0,
    background=fg_primary,
    padding=0.0,
  )
  let body = if active {
    @views.column([panel, accent], spacing=0.0, align=Stretch).frame(
      width=width,
      height=bots_top_height,
    )
  } else {
    @views.container(
      panel,
      width=width,
      height=bots_top_height,
      background=@graphics.Color::transparent(),
      padding=0.0,
    )
  }
  @views.container(
    body,
    width=width,
    height=bots_top_height,
    background=if active {
      @graphics.Color::from_argb(0xFF232323)
    } else {
      @graphics.Color::transparent()
    },
    padding=0.0,
  ).on_tap(SetCenterTab(index))
}

///|
/// Right panel tab bar: Home, Connectors, Chats, Files.
fn bots_panel_tabs(model : Model) -> @moui.View[Msg] {
  let entries : Array[(@moui.View[Msg], String, Int32)] = [
    (@views.lucide_icon("house", size=14.0, color=fg_muted, stroke_width=1.7), "Home", 0),
    (@views.lucide_icon("link", size=14.0, color=fg_muted, stroke_width=1.7), "Connectors", 1),
    (
      @views.lucide_icon("message-circle", size=14.0, color=fg_muted, stroke_width=1.7),
      "Chats",
      2,
    ),
    (@views.lucide_icon("file", size=14.0, color=fg_muted, stroke_width=1.7), "Files", 3),
  ]
  let items : Array[@moui.View[Msg]] = []
  for entry in entries {
    let (icon, label, index) = entry
    let selected = model.panel_tab == index
    let color = if selected { fg_primary } else { fg_secondary }
    let content = @views.row(
      [icon, txt(label, 13.0, if selected { 500 } else { 400 }, color)],
      spacing=5.0,
      align=Center,
    )
    items.push(
      @views.padding_edges(
        @views.container(
          @views.padding_edges(content, left=8.0, right=8.0),
          height=28.0,
          background=if selected { white_a(0.08) } else { @graphics.Color::transparent() },
          corner_radius=8.0,
          padding=0.0,
        ).on_tap(SetPanelTab(index)),
        left=1.0,
        right=1.0,
      ),
    )
  }
  items.push(@views.spacer(weight=1.0))
  items.push(@views.lucide_icon("panel-left", size=14.0, color=fg_muted, stroke_width=1.7))
  let content = @views.row(items, spacing=2.0, align=Center).frame(width=bots_right_width - 24.0)
  @views.container(
    @views.padding_edges(content, left=12.0, right=12.0),
    width=bots_right_width,
    height=bots_top_height,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// Sidebar: nav, Bots fleet, Projects disclosure and account footer.
fn bots_sidebar(model : Model, height : Double) -> @moui.View[Msg] {
  let list_height = height - 72.0
  let list_items : Array[@moui.View[Msg]] = [
    bots_nav_block(),
    bots_section_header(),
  ]
  match active_bot_of(model) {
    Some(bot) => list_items.push(selected_bot_card(model, bot))
    None => ()
  }
  for bot in model.bots {
    if bot.id != model.active_bot {
      list_items.push(other_bot_card(bot))
    }
  }
  let content = @views.column(list_items, spacing=0.0, align=Stretch)
  .frame(width=bots_sidebar_width)
  @views.container(
    @views.column(
      [
        @views.scroll_view(content, width=bots_sidebar_width, height=list_height),
        projects_disclosure(),
        sidebar_account_footer(),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width=bots_sidebar_width,
    height=height,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// Search / Tasks / Automations nav rows; Search stays highlighted in Bots.
fn bots_nav_block() -> @moui.View[Msg] {
  let rows = @views.column(
    [
      fleet_nav_row(
        "Search",
        @views.lucide_icon("search", size=16.0, color=fg_primary, stroke_width=1.8),
        true,
        SetSection(Search),
      ),
      fleet_nav_row(
        "Tasks",
        @views.lucide_icon("list", size=16.0, color=fg_muted, stroke_width=1.8),
        false,
        SetSection(Tasks),
      ),
      fleet_nav_row(
        "Automations",
        @views.lucide_icon("clock", size=16.0, color=fg_muted, stroke_width=1.8),
        false,
        SetSection(Automations),
      ),
    ],
    spacing=2.0,
    align=Stretch,
  )
  @views.padding_edges(rows, top=6.0, left=8.0, right=8.0, bottom=4.0)
}

///|
fn fleet_nav_row(
  label : String,
  icon : @moui.View[Msg],
  selected : Bool,
  message : Msg,
) -> @moui.View[Msg] {
  let content = @views.row(
    [
      icon,
      txt(label, 13.0, 500, if selected { fg_primary } else { fg_muted }),
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 32.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=bots_sidebar_width - 16.0,
    height=32.0,
    background=if selected { white_a(0.05) } else { @graphics.Color::transparent() },
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(message)
}

///|
/// "Bots" section header with collapse chevron and actions.
fn bots_section_header() -> @moui.View[Msg] {
  let actions = @views.row(
    [
      @views.lucide_icon("search", size=14.0, color=fg_muted, stroke_width=1.7),
      sliders_icon(14.0, fg_muted),
      @views.lucide_icon("plus", size=14.0, color=fg_muted, stroke_width=1.8),
    ],
    spacing=8.0,
    align=Center,
  )
  let content = @views.row(
    [
      @views.lucide_icon("chevron-down", size=12.0, color=fg_secondary, stroke_width=1.8),
      txt("Bots", 12.0, 600, fg_secondary),
      @views.spacer(weight=1.0),
      actions,
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 32.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=bots_sidebar_width - 16.0,
      height=32.0,
      background=@graphics.Color::transparent(),
      padding=0.0,
    ),
    left=8.0,
    right=8.0,
  )
}

///|
/// The selected bot card with its nested sessions.
fn selected_bot_card(model : Model, bot : Bot) -> @moui.View[Msg] {
  let name_column = @views.column(
    [
      txt(bot.name, 13.0, 600, fg_primary),
      @views.text(
        if bot.working > 0 { "\{bot.working} working" } else { bot.subtitle },
        width=110.0,
        wrap=false,
        align=TextStart,
      ).font(sans(12.0, 400)).foreground(fg_secondary),
    ],
    spacing=2.0,
    align=Start,
  ).frame(width=110.0)
  let right_side : Array[@moui.View[Msg]] = []
  if bot.working > 0 {
    right_side.push(spinner(9.0, accent_amber))
    right_side.push(txt("\{bot.working}", 12.0, 500, fg_secondary))
  }
  right_side.push(@views.lucide_icon("more-horizontal", size=14.0, color=fg_muted, stroke_width=1.8))
  let header_items : Array[@moui.View[Msg]] = [
    mascot_avatar(bot.mascot, 36.0),
    name_column,
    @views.spacer(weight=1.0),
  ]
  for item in right_side {
    header_items.push(item)
  }
  let header = @views.row(header_items, spacing=6.0, align=Center)
  .frame(width=bots_sidebar_width - 26.0)
  let session_views : Array[@moui.View[Msg]] = []
  for session in bot.sessions {
    session_views.push(session_row(model, session))
  }
  let sessions = @views.padding_edges(
    @views.column(session_views, spacing=1.0, align=Stretch),
    left=14.0,
    right=2.0,
    top=6.0,
  )
  let child = @views.column([header, sessions], spacing=0.0, align=Start)
  .frame(width=bots_sidebar_width - 26.0)
  @views.padding_edges(
    @views.container(
      child,
      width=bots_sidebar_width - 8.0,
      background=white_a(0.10),
      corner_radius=10.0,
      border=Some(selected_border()),
      padding=5.0,
    ),
    left=4.0,
    right=4.0,
    top=2.0,
    bottom=2.0,
  )
}

///|
/// One indented session row.
fn session_row(model : Model, session : Session) -> @moui.View[Msg] {
  let selected = model.active_session == session.id
  let glyphs : Array[@moui.View[Msg]] = []
  match session.kind {
    Home =>
      glyphs.push(@views.lucide_icon("house", size=13.0, color=fg_secondary, stroke_width=1.7))
    ClaudeSession => {
      glyphs.push(spinner(11.0, accent_amber))
      glyphs.push(brand_icon(Claude, 11.0))
    }
    CodexSession => {
      glyphs.push(
        @views.container(
          @views.lucide_icon("check", size=8.0, color=accent_green, stroke_width=2.2),
          width=11.0,
          height=11.0,
          background=@graphics.Color::rgba(r=52.0 / 255.0, g=211.0 / 255.0, b=153.0, a=0.16),
          corner_radius=6.0,
          padding=0.0,
        ),
      )
      glyphs.push(brand_icon(Codex, 11.0))
    }
    Slack => glyphs.push(slack_icon(12.0))
  }
  let content = @views.row(
    [
      @views.row(glyphs, spacing=4.0, align=Center),
      @views.text(truncate_chars(session.label, 26), width=150.0, wrap=false, align=TextStart)
      .font(sans(12.0, 400))
      .foreground(if selected { fg_primary } else { fg_secondary }),
      @views.spacer(weight=1.0),
      @views.text(session.time, wrap=false, align=TextEnd)
      .font(sans(11.0, 400))
      .foreground(@graphics.Color::rgba(r=172.0 / 255.0, g=172.0 / 255.0, b=172.0 / 255.0, a=0.70)),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 49.0)
  @views.container(
    @views.padding_edges(content, left=4.0, right=4.0),
    width=bots_sidebar_width - 41.0,
    height=24.0,
    background=if selected { white_a(0.06) } else { @graphics.Color::transparent() },
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(SelectBot(session.id))
}

///|
/// A non-selected bot row in the fleet list.
fn other_bot_card(bot : Bot) -> @moui.View[Msg] {
  let name_column = @views.column(
    [
      txt(bot.name, 13.0, 600, fg_primary),
      @views.text(truncate_chars(bot.subtitle, 28), width=160.0, wrap=false, align=TextStart)
      .font(sans(12.0, 400))
      .foreground(fg_secondary),
    ],
    spacing=2.0,
    align=Start,
  ).frame(width=160.0)
  let right_items : Array[@moui.View[Msg]] = []
  if bot.working > 0 {
    right_items.push(spinner(9.0, accent_amber))
    right_items.push(txt("\{bot.working}", 12.0, 500, fg_secondary))
  } else {
    right_items.push(txt(bot.time, 11.0, 400, fg_secondary))
  }
  right_items.push(@views.lucide_icon("chevron-right", size=12.0, color=fg_muted, stroke_width=1.8))
  let right = @views.column(right_items, spacing=3.0, align=End)
  let content = @views.row(
    [mascot_avatar(bot.mascot, 36.0), name_column, @views.spacer(weight=1.0), right],
    spacing=7.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 26.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=5.0, right=5.0, top=5.0, bottom=5.0),
      width=bots_sidebar_width - 8.0,
      height=52.0,
      background=@graphics.Color::transparent(),
      corner_radius=10.0,
      padding=0.0,
    ),
    left=4.0,
    right=4.0,
    bottom=2.0,
  ).on_tap(SelectBot(bot.id))
}

///|
/// Projects disclosure row pinned above the account footer.
fn projects_disclosure() -> @moui.View[Msg] {
  let content = @views.row(
    [
      @views.lucide_icon("chevron-right", size=12.0, color=fg_muted, stroke_width=1.8),
      txt("Projects", 13.0, 500, fg_body),
      @views.spacer(weight=1.0),
      sliders_icon(14.0, fg_muted),
      folder_plus_icon(14.0, fg_muted),
      @views.lucide_icon("plus", size=14.0, color=fg_muted, stroke_width=1.8),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width=bots_sidebar_width,
    height=36.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(SetSection(Search))
}

///|
/// Settings / help on the left, history and panel toggle on the right.
fn sidebar_account_footer() -> @moui.View[Msg] {
  let content = @views.row(
    [
      @views.lucide_icon("settings", size=16.0, color=fg_muted, stroke_width=1.7),
      @views.lucide_icon("help-circle", size=16.0, color=fg_muted, stroke_width=1.7),
      @views.spacer(weight=1.0),
      @views.lucide_icon("clock", size=15.0, color=fg_muted, stroke_width=1.7),
      @views.lucide_icon("panel-left", size=14.0, color=fg_muted, stroke_width=1.7),
    ],
    spacing=9.0,
    align=Center,
  ).frame(width=bots_sidebar_width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width=bots_sidebar_width,
    height=36.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
/// Mascot avatar: coloured rounded square with eyes and a mouth.
fn mascot_avatar(mascot : Mascot, size : Double) -> @moui.View[Msg] {
  let ink = @graphics.Color::from_argb(0xFF2B2B2B)
  let color = match mascot {
    Scout => @graphics.Color::from_argb(0xFFCFE3F6)
    CIWatch => @graphics.Color::from_argb(0xFFFFD166)
    ReviewBuddy => @graphics.Color::from_argb(0xFFBFE8D4)
    ReleaseNotes => @graphics.Color::from_argb(0xFFECD0BC)
    Standup => @graphics.Color::from_argb(0xFFFFFFFF)
    DocsHelper => @graphics.Color::from_argb(0xFFD8DEF0)
  }
  let eye_size = size * 0.10
  let eye = @views.container(
    @views.empty(),
    width=eye_size,
    height=eye_size,
    background=ink,
    corner_radius=eye_size / 2.0,
    padding=0.0,
  )
  let mouth = @views.container(
    @views.empty(),
    width=size * 0.22,
    height=size * 0.05,
    background=ink,
    corner_radius=2.0,
    padding=0.0,
  )
  let face = @views.column(
    [
      @views.row([eye, eye], spacing=size * 0.16, align=Center),
      mouth,
    ],
    spacing=size * 0.09,
    align=Center,
  )
  @views.container(
    face,
    width=size,
    height=size,
    background=color,
    corner_radius=if size > 20.0 { 6.0 } else { 4.0 },
    padding=size * 0.20,
  )
}

///|
/// Small robot-head outline glyph for Home Chat rows.
fn bot_glyph(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"M12 2V5M8 5H16A2 2 0 0 1 18 7V17A2 2 0 0 1 16 19H8A2 2 0 0 1 6 17V7A2 2 0 0 1 8 5ZM9 11H9.01M15 11H15.01M9 15H15\"/></svg>",
    size=size,
    color=color,
    stroke_width=1.7,
  )
}

///|
/// Four-lobe Slack mark built from coloured rounded squares.
fn slack_icon(size : Double) -> @moui.View[Msg] {
  let cell = (size - 2.0) / 2.0
  let block = fn(color : @graphics.Color) {
    @views.container(
      @views.empty(),
      width=cell,
      height=cell,
      background=color,
      corner_radius=2.0,
      padding=0.0,
    )
  }
  @views.column(
    [
      @views.row([block(slack_blue), block(slack_green)], spacing=2.0, align=Center),
      @views.row([block(slack_red), block(slack_yellow)], spacing=2.0, align=Center),
    ],
    spacing=2.0,
    align=Center,
  )
}

///|
/// Center chat pane: transcript, composer and caption.
fn bots_chat(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  let content_width = if width - 32.0 > 560.0 { 560.0 } else { width - 32.0 }
  let composer_area_height = 140.0
  let scroll_height = height - composer_area_height
  let blocks = bots_transcript(model, content_width)
  let transcript = @views.column(blocks, spacing=16.0, align=Start)
  .frame(width=content_width)
  let scroller = @views.scroll_view(
    @views.padding_edges(
      @views.column([transcript], spacing=0.0, align=Center).frame(width=width - 32.0),
      top=12.0,
      bottom=24.0,
      left=16.0,
      right=16.0,
    ),
    width=width,
    height=scroll_height,
  )
  @views.container(
    @views.column([scroller, bots_composer(model, width)], spacing=0.0, align=Stretch),
    width=width,
    height=height,
    background=bg_main,
    padding=0.0,
  )
}

///|
/// Build the blocks for the active center tab / bot / session.
fn bots_transcript(model : Model, width : Double) -> Array[@moui.View[Msg]] {
  if model.center_tab == 1 {
    return eng_blocks(model, width)
  }
  let bot = match active_bot_of(model) {
    Some(value) => value
    None => return []
  }
  if bot.id == "ci-watch" {
    return ci_watch_blocks(bot, width)
  }
  if bot.id == "scout" {
    if model.active_session == "safari-pay-click" {
      return worker_session_blocks(
        "safari-pay-click",
        Claude,
        "Claude is tracing why Safari drops the first pointerdown on the Pay button.",
        width,
      )
    } else if model.active_session == "webkit-repro-test" {
      return repro_blocks(width)
    } else if model.active_session == "eng-checkout" {
      return eng_blocks(model, width)
    }
    return scout_blocks(width)
  }
  generic_bot_blocks(bot, width)
}

///|
/// Muted intro paragraph.
fn muted_paragraph(value : String, width : Double) -> @moui.View[Msg] {
  paragraph(value, width, 14.0, 400, 20.0, @graphics.Color::from_argb(0xFF8F8F8F))
}

///|
/// Inline chip used inside center tool rows.
fn tool_chip_view(chip : ToolChip) -> @moui.View[Msg] {
  if chip.kind == Plain {
    return txt(chip.text, 13.0, 400, fg_body)
  }
  let color = match chip.kind {
    Green => accent_green
    Amber | Status | Neutral | Link => fg_primary
    Plain => fg_body
  }
  let lead : Array[@moui.View[Msg]] = []
  match chip.kind {
    Amber => lead.push(loader_icon(10.0, accent_amber))
    Status => lead.push(status_dot(accent_amber, 6.0))
    Green =>
      lead.push(@views.lucide_icon("check", size=10.0, color=accent_green, stroke_width=2.0))
    Link =>
      lead.push(@views.lucide_icon("git-branch", size=10.0, color=fg_muted, stroke_width=1.7))
    Neutral | Plain => ()
  }
  let items = lead.copy()
  items.push(txt(chip.text, 12.0, 500, color))
  let content = @views.row(items, spacing=4.0, align=Center)
  @views.container(
    @views.padding_edges(content, left=4.0, right=4.0, top=1.0, bottom=1.0),
    background=white_a(0.06),
    corner_radius=4.0,
    padding=0.0,
  )
}

///|
/// One 24 px tool row.
fn tool_row(
  icon : ToolIcon,
  lead : String,
  chips : Array[ToolChip],
  width : Double,
) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = [tool_icon_view(icon, 14.0), txt(lead, 13.0, 400, fg_body)]
  for chip in chips {
    items.push(tool_chip_view(chip))
  }
  items.push(@views.spacer(weight=1.0))
  @views.row(items, spacing=6.0, align=Center).frame(width=width, height=24.0)
}

///|
fn tool_icon_view(icon : ToolIcon, size : Double) -> @moui.View[Msg] {
  match icon {
    List => @views.lucide_icon("list", size=size, color=fg_muted, stroke_width=1.7)
    ClaudeTool => brand_icon(Claude, size)
    CodexTool => brand_icon(Codex, size)
    BotTool => bot_glyph(size, fg_muted)
    LinkTool => @views.lucide_icon("link", size=size, color=fg_muted, stroke_width=1.7)
    PlusTool => @views.lucide_icon("plus", size=size, color=fg_muted, stroke_width=1.8)
    CheckTool => @views.lucide_icon("check", size=size, color=accent_green, stroke_width=2.0)
    CommentTool =>
      @views.lucide_icon("message-circle", size=size, color=fg_muted, stroke_width=1.7)
    PlayTool => @views.lucide_icon("play", size=size, color=fg_muted, stroke_width=1.7)
  }
}

///|
/// Inline code chip for prose blocks.
fn code_span(text : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      @views.text(text, wrap=false, align=TextStart).font(mono(12.0, 400)).foreground(fg_primary),
      left=4.0,
      right=4.0,
      top=1.0,
      bottom=1.0,
    ),
    background=white_a(0.06),
    corner_radius=4.0,
    padding=0.0,
  )
}

///|
/// A smaller code chip used inside the right-panel message card.
fn code_span_small(text : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      @views.text(text, wrap=false, align=TextStart).font(mono(10.0, 400)).foreground(fg_primary),
      left=3.0,
      right=3.0,
      top=1.0,
      bottom=1.0,
    ),
    background=white_a(0.06),
    corner_radius=4.0,
    padding=0.0,
  )
}

///|
/// One fixed line of prose with inline code spans.
fn prose_row(parts : Array[(String, Bool)], width : Double) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = []
  for part in parts {
    let (text, is_code) = part
    if is_code {
      items.push(code_span(text))
    } else {
      items.push(txt(text, 14.0, 400, fg_body))
    }
  }
  items.push(@views.spacer(weight=1.0))
  @views.row(items, spacing=0.0, align=Center).frame(width=width)
}

///|
/// A prose line variant that uses the compact code chip.
fn small_prose_row(parts : Array[(String, Bool)], width : Double) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = []
  for part in parts {
    let (text, is_code) = part
    if is_code {
      items.push(code_span_small(text))
    } else {
      items.push(txt(text, 13.0, 400, fg_bubble))
    }
  }
  items.push(@views.spacer(weight=1.0))
  @views.row(items, spacing=0.0, align=Center).frame(width=width)
}

///|
/// "Worked for … ›" row with its bottom hairline.
fn bots_worked_row(label : String, width : Double) -> @moui.View[Msg] {
  let header = @views.row(
    [
      txt(label, 12.0, 400, fg_muted),
      @views.lucide_icon("chevron-right", size=12.0, color=fg_muted, stroke_width=1.8),
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  )
  @views.column(
    [header, @views.divider(color=white_a(0.07), thickness=1.0)],
    spacing=8.0,
    align=Stretch,
  ).frame(width=width)
}

///|
/// Scout's rich user bubble.
fn bots_user_bubble(width : Double) -> @moui.View[Msg] {
  let first = @views.container(
    @views.padding_edges(
      @views.row(
        [
          status_dot(accent_amber, 6.0),
          txt("Pay button ignores first tap on Safari", 14.0, 500, fg_primary),
        ],
        spacing=6.0,
        align=Center,
      ),
      left=8.0,
      right=8.0,
      top=4.0,
      bottom=4.0,
    ),
    background=white_a(0.06),
    corner_radius=6.0,
    padding=0.0,
  )
  let second = txt("Behind a flag", 14.0, 400, fg_primary)
  let bubble = @views.container(
    @views.padding_edges(
      @views.column([first, second], spacing=10.0, align=Start),
      left=14.0,
      right=14.0,
      top=10.0,
      bottom=10.0,
    ),
    background=bg_bubble,
    corner_radius=14.0,
    padding=0.0,
  )
  @views.column([bubble], spacing=0.0, align=End).frame(width=width)
}

///|
/// The reference Scout conversation.
fn scout_blocks(width : Double) -> Array[@moui.View[Msg]] {
  [
    muted_paragraph(
      "New bug from support: the Pay button does nothing on the first tap in Safari. 14 reports since yesterday’s deploy, all Safari 18 on iOS and macOS. I reproduced it on WebKit, so it’s ours, not the payment provider.",
      width,
    ),
    @views.column(
      [
        tool_row(
          List,
          "Added and moved",
          [
            { text: "Pay button ignores first tap on Safari", kind: Amber },
            { text: "to In progress", kind: Plain },
          ],
          width,
        ),
        tool_row(ClaudeTool, "Started safari-pay-click", [], width),
        tool_row(CodexTool, "Started webkit-repro-test", [], width),
      ],
      spacing=0.0,
      align=Start,
    ),
    bots_worked_row("Worked for 6m 12s", width),
    @views.column(
      [
        prose_row(
          [
            ("Found it. ", false),
            ("PayButton", true),
            (" starts the payment on ", false),
            ("pointerdown", true),
            (", and Safari drops that", false),
          ],
          width,
        ),
        prose_row(
          [
            ("event while the sticky cart footer overlaps the button. The fix listens for ", false),
            ("click", true),
          ],
          width,
        ),
        prose_row(
          [
            ("instead. WebKit tests pass, ", false),
            ("38 of 38", true),
            (", and the new repro test fails without it.", false),
          ],
          width,
        ),
      ],
      spacing=0.0,
      align=Start,
    ),
    @views.column(
      [
        tool_row(
          List,
          "Linked",
          [
            { text: "acme/web#1287", kind: Link },
            { text: "to", kind: Plain },
            { text: "Pay button ignores first tap on Safari", kind: Amber },
          ],
          width,
        ),
        tool_row(
          List,
          "Added",
          [{ text: "Sticky cart footer covers Pay on small s…", kind: Neutral }],
          width,
        ),
        tool_row(
          List,
          "Asked you about",
          [{ text: "Pay button ignores first tap on Safari", kind: Status }],
          width,
        ),
      ],
      spacing=0.0,
      align=Start,
    ),
    bots_user_bubble(width),
    @views.column(
      [
        prose_row(
          [
            ("Shipping it behind ", false),
            ("safari_pay_click", true),
            (". I’ll merge acme/web#1287 and turn the flag", false),
          ],
          width,
        ),
        prose_row([("on for Safari once the deploy is out.", false)], width),
      ],
      spacing=0.0,
      align=Start,
    ),
    tool_row(ClaudeTool, "Sent follow-up to safari-pay-click", [], width),
  ]
}

///|
/// Worker-session transcript for safari-pay-click.
fn worker_session_blocks(
  name : String,
  kind : AgentKind,
  intro : String,
  width : Double,
) -> Array[@moui.View[Msg]] {
  [
    muted_paragraph(intro, width),
    tool_row(
      match kind {
        Claude => ClaudeTool
        Codex => CodexTool
        Grok => BotTool
      },
      "Started \{name}",
      [],
      width,
    ),
    bots_worked_row("Worked for 3m 40s", width),
    paragraph(
      "The handler is bound to pointerdown and Safari swallows it when the sticky footer paints over the Pay button. Switching to click makes the first tap register.",
      width,
      14.0,
      400,
      20.0,
      fg_body,
    ),
    tool_row(List, "Added", [{ text: "Regression test for the first tap", kind: Neutral }], width),
  ]
}

///|
/// WebKit repro transcript.
fn repro_blocks(width : Double) -> Array[@moui.View[Msg]] {
  [
    muted_paragraph(
      "Codex is building a WebKit-only repro for the Pay button first-tap bug.",
      width,
    ),
    tool_row(CodexTool, "Started webkit-repro-test", [], width),
    bots_worked_row("Worked for 2m 41s", width),
    paragraph(
      "The repro fails on the old handler and passes once the button listens for click. 38 of 38 WebKit tests pass.",
      width,
      14.0,
      400,
      20.0,
      fg_body,
    ),
  ]
}

///|
/// The #eng thread tab.
fn eng_blocks(model : Model, width : Double) -> Array[@moui.View[Msg]] {
  let status_line = if model.flag_selected {
    "Scout: shipped behind the safari_pay_click flag — Safari first tap now works."
  } else {
    "Scout: fix is ready in acme/web#1287 — deciding whether to ship behind a flag."
  }
  [
    muted_paragraph("Thread in #eng: checkout on Safari is dropping the first tap on Pay.", width),
    tool_row(BotTool, "Scout posted a status update", [{ text: "#eng", kind: Link }], width),
    bots_worked_row("Worked for 18m", width),
    paragraph(status_line, width, 14.0, 400, 20.0, fg_body),
    @views.column(
      [
        prose_row(
          [
            ("The fix listens for ", false),
            ("click", true),
            (" and ships behind ", false),
            ("safari_pay_click", true),
            (".", false),
          ],
          width,
        ),
      ],
      spacing=0.0,
      align=Start,
    ),
  ]
}

///|
/// CI Watch transcript.
fn ci_watch_blocks(bot : Bot, width : Double) -> Array[@moui.View[Msg]] {
  [
    muted_paragraph(bot.subtitle, width),
    tool_row(
      List,
      "Opened",
      [{ text: "e2e/cart.spec is flaky, not a re…", kind: Amber }],
      width,
    ),
    bots_worked_row("Worked for 2h 4m", width),
    paragraph(
      "The cart spec fails on webkit only, roughly one in five runs. The race is in the cart fixture teardown, not in checkout code.",
      width,
      14.0,
      400,
      20.0,
      fg_body,
    ),
    tool_row(
      List,
      "Suggested",
      [{ text: "Quarantine cart.spec while fixing the race", kind: Neutral }],
      width,
    ),
  ]
}

///|
/// Fallback transcript for the remaining bots.
fn generic_bot_blocks(bot : Bot, width : Double) -> Array[@moui.View[Msg]] {
  [
    muted_paragraph(bot.subtitle, width),
    tool_row(BotTool, "Opened a session", [], width),
    bots_worked_row("Worked for 12m", width),
    paragraph(
      "The bot will report back here when there is a concrete next step.",
      width,
      14.0,
      400,
      20.0,
      fg_body,
    ),
  ]
}

///|
/// Center composer plus the caption underneath.
fn bots_composer(model : Model, center_width : Double) -> @moui.View[Msg] {
  let composer_width = if center_width - 32.0 > 575.0 { 575.0 } else { center_width - 32.0 }
  let field_width = composer_width - 16.0
  let field = @views.text_field(
    model.draft,
    on_input=fn(text) { DraftInput(text) },
    on_submit=Some(Send),
    key="bots-composer",
    placeholder="Ask anything, @ to mention bots or files, / for commands",
    style=bots_field_style(15.0, fg_muted),
    width=field_width,
    height=44.0,
  )
  let send = @views.container(
    arrow_up_icon(15.0, fg_primary),
    width=32.0,
    height=32.0,
    background=@graphics.Color::from_argb(0xFF3D3D3D),
    corner_radius=16.0,
    padding=0.0,
  ).on_tap(Send)
  let footer_content = @views.row(
    [
      @views.lucide_icon("plus", size=16.0, color=fg_secondary, stroke_width=1.8),
      @views.spacer(weight=1.0),
      txt("Claude Opus 5.5 Med", 14.0, 400, fg_body),
      @views.lucide_icon("chevron-down", size=12.0, color=fg_muted, stroke_width=1.8),
      mic_icon(16.0, fg_secondary),
      send,
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=field_width)
  let card = @views.container(
    @views.column([field, footer_content], spacing=4.0, align=Stretch)
    .frame(width=field_width),
    background=@graphics.Color::from_argb(0xFF1B1B1B),
    corner_radius=14.0,
    border=Some(composer_border()),
    padding=8.0,
  )
  let centered = @views.row(
    [@views.spacer(weight=1.0), card, @views.spacer(weight=1.0)],
    spacing=0.0,
    align=Center,
  ).frame(width=center_width)
  let caption = @views.row(
    [
      txt("Maya’s MacBook Pro   Scout · Folder", 11.0, 400, fg_muted),
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=composer_width)
  @views.padding_edges(
    @views.column(
      [centered, @views.padding_edges(caption, top=8.0)],
      spacing=0.0,
      align=Center,
    ).frame(width=center_width),
    top=10.0,
    bottom=8.0,
  )
}

///|
/// Transparent text field style for bot-side inputs.
fn bots_field_style(size : Double, placeholder : @graphics.Color) -> @style.TextFieldStyle {
  let transparent = @graphics.Brush::Solid(@graphics.Color::transparent())
  let normal = @views.new_control_state_style(foreground=fg_body, background=transparent)
  let focused = @views.new_control_state_style(foreground=fg_body, background=transparent)
  @style.TextFieldStyle::new(
    normal~,
    focused~,
    disabled=normal,
    placeholder_color=placeholder,
    cursor_color=fg_primary,
    font=sans_lh(size, 400, 21.0),
  )
}

///|
/// Right item panel: tab-specific content plus the comment composer.
fn bots_panel(model : Model, height : Double) -> @moui.View[Msg] {
  let composer_height = 72.0
  let scroll_height = height - composer_height
  let content = match model.panel_tab {
    0 => panel_home_content(model, scroll_height)
    1 => connectors_content(scroll_height)
    2 => panel_empty(scroll_height, "Chats", "No chats linked to this item yet.")
    _ => panel_empty(scroll_height, "Files", "No files linked to this item yet.")
  }
  @views.container(
    @views.column(
      [
        content,
        @views.padding_edges(
          comment_composer(model),
          left=16.0,
          right=16.0,
          top=8.0,
          bottom=16.0,
        ),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width=bots_right_width,
    height=height,
    background=bg_main,
    padding=0.0,
  )
}

///|
/// Greedy word wrapper for the compact "Done means" two-column body.
fn done_body_lines(value : String) -> Array[String] {
  let words = value.split(" ").to_array()
  let lines : Array[String] = []
  let mut line = ""
  for word in words {
    let token = word.to_string()
    if line == "" {
      line = token
    } else if line.length() + 1 + token.length() > 37 {
      lines.push(line)
      line = token
    } else {
      line = line + " " + token
    }
  }
  if line != "" {
    lines.push(line)
  }
  lines
}

///|
/// Home tab: item details, activity and Scout's question card.
fn panel_home_content(model : Model, height : Double) -> @moui.View[Msg] {
  let bot = match active_bot_of(model) {
    Some(value) => value
    None => return panel_empty(height, "Home", "No bot selected.")
  }
  let item = match bot.item {
    Some(value) => value
    None => return panel_empty(height, "Home", "No item selected.")
  }
  let back = @views.row(
    [
      @views.lucide_icon("chevron-left", size=12.0, color=fg_muted, stroke_width=1.8),
      txt("Home", 13.0, 400, fg_muted),
      @views.spacer(min_length=8.0, weight=0.0),
      mascot_avatar(bot.mascot, 20.0),
      txt(bot.name, 13.0, 400, fg_primary),
      @views.spacer(weight=1.0),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=348.0)
  let title = @views.text(
    "\{item.number} \{item.title}",
    width=356.0,
    wrap=false,
    align=TextStart,
  ).font(sans(16.0, 600)).foreground(fg_primary)
  let status_row = @views.row(
    [
      loader_icon(13.0, accent_amber),
      txt(item.state, 13.0, 500, fg_primary),
      @views.lucide_icon("chevron-down", size=12.0, color=fg_muted, stroke_width=1.8),
      @views.spacer(min_length=24.0, weight=0.0),
      txt(item.meta, 12.0, 400, fg_muted),
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=348.0)
  let chip_rows : Array[@moui.View[Msg]] = []
  let mut chip_index = 0
  while chip_index < item.chips.length() {
    let group : Array[@moui.View[Msg]] = [panel_chip(item.chips[chip_index])]
    if chip_index + 1 < item.chips.length() {
      group.push(panel_chip(item.chips[chip_index + 1]))
    }
    chip_rows.push(@views.row(group, spacing=8.0, align=Center))
    chip_index = chip_index + 2
  }
  let chat_row = @views.row(
    [
      txt("Chat", 12.0, 400, fg_muted),
      @views.spacer(min_length=48.0, weight=0.0),
      @views.lucide_icon("house", size=14.0, color=fg_muted, stroke_width=1.7),
      txt("Home Chat", 13.0, 400, fg_primary),
      @views.lucide_icon("external-link", size=12.0, color=fg_muted, stroke_width=1.7),
      @views.spacer(weight=1.0),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=348.0)
  let done_lines : Array[@moui.View[Msg]] = []
  for line in done_body_lines(item.done_means) {
    done_lines.push(
      @views.text(line, width=246.0, wrap=false, align=TextStart)
      .font(sans(13.0, 400))
      .foreground(fg_body),
    )
  }
  let done_row = @views.row(
    [
      @views.container(
        txt("Done means", 12.0, 400, fg_muted),
        width=84.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      @views.column(done_lines, spacing=2.0, align=Start).frame(width=246.0),
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Start,
  ).frame(width=348.0)
  let activity_rows : Array[@moui.View[Msg]] = []
  for activity in item.activities {
    activity_rows.push(
      activity_row(
        activity_icon_view(activity.icon),
        activity.text,
        activity.sub,
        activity.time,
        false,
      ),
    )
  }
  for comment in model.comments {
    activity_rows.push(
      activity_row(activity_icon_view(CommentActivity), comment, "", "now", true),
    )
  }
  let activity_block = @views.column(
    [
      txt("Activity", 12.0, 400, fg_muted),
      @views.column(activity_rows, spacing=2.0, align=Stretch),
    ],
    spacing=8.0,
    align=Start,
  ).frame(width=348.0)
  let message_block = match item.message {
    Some(message) => scout_message_card(model, message)
    None => @views.empty()
  }
  let dot = @views.column(
    [
      @views.container(
        @views.empty(),
        width=8.0,
        height=8.0,
        background=white_a(0.85),
        corner_radius=4.0,
        padding=0.0,
      ),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=348.0)
  let body = @views.column(
    [
      back,
      title,
      status_row,
      @views.column(chip_rows, spacing=9.0, align=Start),
      @views.divider(color=white_a(0.07), thickness=1.0),
      chat_row,
      @views.divider(color=white_a(0.07), thickness=1.0),
      done_row,
      activity_block,
      message_block,
      @views.padding_edges(dot, top=32.0),
    ],
    spacing=12.0,
    align=Start,
  ).frame(width=356.0)
  @views.scroll_view(
    @views.padding_edges(body, left=12.0, right=12.0, top=16.0, bottom=16.0),
    width=bots_right_width,
    height=height,
  )
}

///|
/// Panel chip: amber loader, green check or branch glyph with a bordered pill.
fn panel_chip(chip : ToolChip) -> @moui.View[Msg] {
  let color = match chip.kind {
    Green => accent_green
    Link => fg_secondary
    Amber | Status | Neutral | Plain => fg_primary
  }
  let lead : Array[@moui.View[Msg]] = []
  match chip.kind {
    Amber => lead.push(loader_icon(11.0, accent_amber))
    Green =>
      lead.push(@views.lucide_icon("check", size=11.0, color=accent_green, stroke_width=2.0))
    Link =>
      lead.push(@views.lucide_icon("git-branch", size=11.0, color=fg_muted, stroke_width=1.7))
    Status => lead.push(status_dot(accent_amber, 6.0))
    Neutral | Plain => ()
  }
  let items = lead.copy()
  if chip.text == "Fix Safari Pay tap follow-up" {
    items.push(txt("Fix Safari Pay tap", 12.0, 500, fg_primary))
    items.push(txt("follow-up", 12.0, 500, fg_muted))
  } else {
    items.push(txt(chip.text, 12.0, 500, color))
  }
  @views.container(
    @views.padding_edges(
      @views.row(items, spacing=5.0, align=Center),
      left=8.0,
      right=8.0,
    ),
    height=28.0,
    background=white_a(0.04),
    corner_radius=7.0,
    border=Some(border_of(white_a(0.08), 1.0)),
    padding=0.0,
  )
}

///|
/// Activity glyphs.
fn activity_icon_view(icon : ActivityIcon) -> @moui.View[Msg] {
  match icon {
    AddActivity => @views.lucide_icon("plus", size=13.0, color=fg_muted, stroke_width=1.8)
    PlayActivity => @views.lucide_icon("play", size=13.0, color=fg_muted, stroke_width=1.7)
    CheckActivity => @views.lucide_icon("check", size=13.0, color=fg_muted, stroke_width=1.8)
    LinkActivity => @views.lucide_icon("link", size=13.0, color=fg_muted, stroke_width=1.7)
    CommentActivity =>
      @views.lucide_icon("message-circle", size=13.0, color=fg_muted, stroke_width=1.7)
  }
}

///|
/// One activity row with an optional sub-line.
fn activity_row(
  icon : @moui.View[Msg],
  text : String,
  sub : String,
  time : String,
  wrap : Bool,
) -> @moui.View[Msg] {
  let label = if wrap {
    @views.text(text, width=250.0, wrap=true, align=TextStart)
    .font(sans_lh(12.0, 400, 17.0))
    .foreground(fg_body)
  } else {
    txt(text, 12.0, 400, fg_body)
  }
  let main = @views.row(
    [icon, label, @views.spacer(weight=1.0), txt(time, 11.0, 400, fg_muted)],
    spacing=8.0,
    align=Center,
  ).frame(width=348.0, height=26.0)
  if sub == "" {
    main
  } else {
    @views.column(
      [main, @views.padding_edges(txt(sub, 12.0, 400, fg_muted), left=21.0)],
      spacing=2.0,
      align=Start,
    )
  }
}

///|
/// Scout's message card with the reply chip.
fn scout_message_card(model : Model, message : BotMessage) -> @moui.View[Msg] {
  let header = @views.row(
    [
      mascot_avatar(Scout, 24.0),
      txt(message.name, 13.0, 500, fg_primary),
      @views.spacer(weight=1.0),
      txt(message.time, 11.0, 400, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=328.0)
  let reply_chip = @views.container(
    @views.padding_edges(
      txt(message.reply_chip, 12.0, 500, if model.flag_selected { accent_amber } else { fg_body }),
      left=8.0,
      right=8.0,
    ),
    height=26.0,
    background=if model.flag_selected { white_a(0.08) } else { white_a(0.04) },
    corner_radius=7.0,
    border=Some(
      border_of(
        if model.flag_selected {
          @graphics.Color::rgba(r=234.0 / 255.0, g=179.0 / 255.0, b=8.0 / 255.0, a=0.6)
        } else {
          white_a(0.10)
        },
        1.0,
      ),
    ),
    padding=0.0,
  ).on_tap(ToggleFlag)
  let second_line = @views.row(
    [
      txt("flag first? →", 13.0, 400, fg_bubble),
      @views.spacer(min_length=6.0, weight=0.0),
      reply_chip,
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=328.0)
  let body = @views.column(
    [
      txt(message.line1, 13.0, 400, fg_bubble),
      small_prose_row(
        [("Ship it to everyone, or behind the ", false), ("safari_pay_click", true)],
        328.0,
      ),
      second_line,
    ],
    spacing=4.0,
    align=Start,
  ).frame(width=328.0)
  @views.container(
    @views.padding_edges(
      @views.column([header, body], spacing=10.0, align=Start),
      left=10.0,
      right=10.0,
      top=10.0,
      bottom=10.0,
    ),
    width=348.0,
    background=bg_card,
    corner_radius=12.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=0.0,
  )
}

///|
/// Fixed comment composer at the bottom of the right panel.
fn comment_composer(model : Model) -> @moui.View[Msg] {
  let field = @views.text_field(
    model.comment_draft,
    on_input=fn(text) { CommentInput(text) },
    on_submit=Some(SendComment),
    key="bots-comment",
    placeholder="Add a comment…",
    style=bots_field_style(13.0, fg_muted),
    width=232.0,
    height=40.0,
  )
  let send = @views.container(
    arrow_up_icon(13.0, fg_primary),
    width=28.0,
    height=28.0,
    background=@graphics.Color::from_argb(0xFF3D3D3D),
    corner_radius=14.0,
    padding=0.0,
  ).on_tap(SendComment)
  let content = @views.row(
    [
      @views.lucide_icon("plus", size=16.0, color=fg_secondary, stroke_width=1.8),
      field,
      @views.spacer(weight=1.0),
      mic_icon(15.0, fg_secondary),
      send,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=328.0)
  @views.container(
    @views.padding_edges(content, left=10.0, right=10.0),
    width=348.0,
    height=48.0,
    background=white_a(0.04),
    corner_radius=12.0,
    border=Some(border_of(white_a(0.09), 1.0)),
    padding=0.0,
  )
}

///|
/// Connectors tab: a short list of linked services.
fn connectors_content(height : Double) -> @moui.View[Msg] {
  let entries : Array[(String, Mascot, String)] = [
    ("Slack", Scout, "#eng · 42 members"),
    ("Linear", CIWatch, "ACME · 6 open items"),
    ("GitHub", ReviewBuddy, "acme/web · connected"),
    ("Gmail", ReleaseNotes, "maya@acme.dev"),
  ]
  let rows : Array[@moui.View[Msg]] = []
  for entry in entries {
    let (label, mascot, sub) = entry
    let content = @views.row(
      [
        mascot_avatar(mascot, 28.0),
        @views.column(
          [
            txt(label, 13.0, 500, fg_primary),
            txt(sub, 11.0, 400, fg_muted),
          ],
          spacing=2.0,
          align=Start,
        ),
        @views.spacer(weight=1.0),
        @views.lucide_icon("chevron-right", size=12.0, color=fg_muted, stroke_width=1.8),
      ],
      spacing=10.0,
      align=Center,
    ).frame(width=348.0)
    rows.push(@views.padding_edges(content, top=10.0, bottom=10.0))
  }
  let body = @views.column(
    [
      txt("Connectors", 16.0, 600, fg_primary),
      @views.column(rows, spacing=2.0, align=Stretch),
    ],
    spacing=10.0,
    align=Start,
  ).frame(width=348.0)
  @views.scroll_view(
    @views.padding_edges(body, left=16.0, right=16.0, top=16.0),
    width=bots_right_width,
    height=height,
  )
}

///|
/// Empty state for Chats and Files.
fn panel_empty(height : Double, eyebrow : String, body : String) -> @moui.View[Msg] {
  @views.scroll_view(
    @views.padding_edges(
      @views.container(
        @views.column(
          [
            txt(eyebrow, 11.0, 600, fg_dim),
            txt(body, 13.0, 400, fg_muted),
          ],
          spacing=6.0,
          align=Center,
        ),
        width=348.0,
        height=200.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      left=16.0,
      right=16.0,
      top=16.0,
    ),
    width=bots_right_width,
    height=height,
  )
}

///|
/// Full-width 24 px status bar with the two meters and host label.
fn bots_status_bar(width : Double) -> @moui.View[Msg] {
  let meter = fn(fraction : Double) {
    let fill_width = 76.0 * fraction
    @views.container(
      @views.row(
        [
          @views.container(
            @views.empty(),
            width=fill_width,
            height=4.0,
            background=white_a(0.35),
            corner_radius=2.0,
            padding=0.0,
          ),
          @views.spacer(weight=1.0),
        ],
        spacing=0.0,
        align=Center,
      ).frame(width=76.0, height=4.0),
      width=76.0,
      height=4.0,
      background=white_a(0.10),
      corner_radius=2.0,
      padding=0.0,
    )
  }
  let left = @views.row(
    [
      sparkles_icon(11.0, accent_amber),
      @views.spacer(min_length=6.0, weight=0.0),
      meter(0.38),
      @views.spacer(min_length=6.0, weight=0.0),
      txt("38%", 11.0, 400, fg_muted),
      @views.spacer(min_length=16.0, weight=0.0),
      brand_icon(Codex, 11.0),
      @views.spacer(min_length=6.0, weight=0.0),
      meter(0.12),
      @views.spacer(min_length=6.0, weight=0.0),
      txt("12%", 11.0, 400, fg_muted),
      @views.spacer(weight=1.0),
      txt("maya-mbp", 11.0, 400, fg_muted),
      @views.spacer(min_length=12.0, weight=0.0),
      txt("2 hosts", 11.0, 400, fg_dim),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=width - 24.0)
  @views.container(
    @views.padding_edges(left, left=12.0, right=12.0),
    width=width,
    height=bots_status_height,
    background=@graphics.Color::from_argb(0xFF101010),
    padding=0.0,
  )
}
