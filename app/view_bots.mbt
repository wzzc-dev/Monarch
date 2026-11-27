///|
/// Width of the collapsed right item rail.
let bots_rail_width : Double = 48.0

///|
/// Height of the shared top bar.
let bots_top_height : Double = 36.0

///|
/// Height of the full-width status bar.
let bots_status_height : Double = 24.0

///|
/// Center-tab widths from the Bots reference: the activity tab is compact, the
/// session tab has room for its full title, and the plus button follows.
pub let bots_home_tab_width : Double = 143.0

///|
pub let bots_eng_tab_width : Double = 196.0

///|
pub let bots_center_tabs_width : Double = 383.0

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
    height~,
    background=white_a(0.07),
    padding=0.0,
  )
}

///|
/// 1 px rule; a transparent overlay supplies the wider drag hit area.
fn bots_resize_handle(height : Double, hovered : Bool) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width=1.0,
    height~,
    background=if hovered { white_a(0.12) } else { white_a(0.07) },
    padding=0.0,
  )
  .on_drag(fn(event) { ResizeBotsSidebar(event.position.x) })
  .on_hover(fn(entered) { Hover("resize-bots-sidebar", entered) })
  .cursor(@views.CursorStyle::Icon(@views.CursorIcon::CursorColResize))
}

///|
/// Transparent 9 px hit target centred on the sidebar rule. The row is sized by
/// the parent stack, so the grip widens the pointer target without taking
/// layout space from the panes.
fn bots_sidebar_grip(
  width : Double,
  grip_height : Double,
  boundary : Double,
) -> @moui.View[Msg] {
  let grip = @views.container(
      @views.empty(),
      width=9.0,
      height=grip_height,
      background=@graphics.Color::transparent(),
      padding=0.0,
    )
    .on_drag(fn(event) { ResizeBotsSidebar(event.position.x) })
    .on_hover(fn(entered) { Hover("resize-bots-sidebar", entered) })
    .cursor(@views.CursorStyle::Icon(@views.CursorIcon::CursorColResize))
  @views.row(
    [
      @views.spacer(min_length=boundary - 4.0, weight=0.0),
      grip,
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Start,
  ).frame(width~)
}

///|
/// Mirror of `bots_resize_handle` for the item panel, which grows leftwards.
fn bots_panel_resize_handle(
  height : Double,
  window_width : Double,
  hovered : Bool,
) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width=1.0,
    height~,
    background=if hovered { white_a(0.12) } else { white_a(0.07) },
    padding=0.0,
  )
  .on_drag(fn(event) { ResizeBotsPanel(window_width - event.position.x) })
  .on_hover(fn(entered) { Hover("resize-bots-panel", entered) })
  .cursor(@views.CursorStyle::Icon(@views.CursorIcon::CursorColResize))
}

///|
/// Transparent 9 px hit target for the item-panel rule.
fn bots_panel_grip(
  width : Double,
  grip_height : Double,
  boundary : Double,
  window_width : Double,
) -> @moui.View[Msg] {
  let grip = @views.container(
      @views.empty(),
      width=9.0,
      height=grip_height,
      background=@graphics.Color::transparent(),
      padding=0.0,
    )
    .on_drag(fn(event) { ResizeBotsPanel(window_width - event.position.x) })
    .on_hover(fn(entered) { Hover("resize-bots-panel", entered) })
    .cursor(@views.CursorStyle::Icon(@views.CursorIcon::CursorColResize))
  @views.row(
    [
      @views.spacer(min_length=boundary - 4.0, weight=0.0),
      grip,
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Start,
  ).frame(width~)
}

///|
/// Narrow Bots layout: below 760 px the fleet becomes a drawer and an open
/// item panel is drawn over the chat instead of squeezing it.
pub fn bots_compact(width : Double) -> Bool {
  width < 760.0
}

///|
/// Title-bar width in compact Bots layouts. The wordmark is dropped so the
/// chat's tab strip keeps useful room at phone widths.
pub fn bots_compact_chrome_width() -> Double {
  124.0
}

///|
/// Compact tab-strip priorities. The Slack tab is shed before tabs can
/// overflow the strip; the active bot tab and plus remain.
pub fn bots_tab_plus_visible(width : Double) -> Bool {
  width >= 124.0
}

///|
pub fn bots_tab_eng_visible(
  width : Double,
  is_scout : Bool,
  eng_open : Bool,
) -> Bool {
  is_scout && eng_open && width >= 480.0
}

///|
/// The compact drawer gives the chat a 64 px peek only while the panel can
/// keep its 320 px desktop minimum. Below that the panel fills the window.
pub fn compact_panel_width(model : Model, width : Double) -> Double {
  let available = if width < 64.0 { width } else { width - 64.0 }
  if available < 320.0 {
    width
  } else if model.bots_panel_w < available {
    model.bots_panel_w
  } else {
    available
  }
}

///|
/// The item panel is a drawer at phone widths; its Home cards switch to
/// single-column, clipped rows below 360 px.
pub fn bots_panel_narrow(width : Double) -> Bool {
  width < 360.0
}

///|
/// The item title keeps its single-line design at desktop panel widths and
/// wraps onto a second line when the panel narrows, instead of cutting a word
/// at the panel's right edge.
pub fn bots_panel_title_wraps(width : Double) -> Bool {
  bots_panel_narrow(width)
}

///|
/// Below 400 px the status bar drops the second usage meter so the machine
/// and host labels keep their right edge.
pub fn bots_status_compact(width : Double) -> Bool {
  width < 400.0
}

///|
/// Root layout for the three-pane Bots screen.
pub fn bots_screen(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let compact = bots_compact(width)
  let body_height = height - bots_top_height - 2.0 - bots_status_height
  let (left_width, right_open_width) = bots_pinned_widths(model, width)
  let sidebar_w = if compact {
    let available = if width < 48.0 { 0.0 } else { width - 48.0 }
    if available < model.bots_sidebar_w {
      available
    } else {
      model.bots_sidebar_w
    }
  } else {
    left_width
  }
  let sidebar_inline = model.sidebar_open && !compact
  let panel_inline = model.bots_item_open && !compact
  let chrome_w = if sidebar_inline {
    sidebar_w
  } else if compact {
    bots_compact_chrome_width()
  } else {
    208.0
  }
  let right_width = if panel_inline {
    right_open_width
  } else {
    bots_rail_width
  }
  let top_center_width = width - chrome_w - 2.0 - right_width
  let body_center_width = if sidebar_inline {
    width - sidebar_w - 2.0 - right_width
  } else {
    width - 1.0 - right_width
  }
  let panel_model = if compact {
    { ..model, bots_item_open: false, }
  } else {
    model
  }
  let show_sidebar_drawer = compact && model.sidebar_open
  let show_panel_drawer = compact && model.bots_item_open && !model.sidebar_open
  let top = @views.row(
    [
      bots_title_bar(chrome_w, compact, model.hover == "panel-toggle"),
      if sidebar_inline {
        bots_resize_handle(
          bots_top_height,
          model.hover == "resize-bots-sidebar",
        )
      } else {
        vrule(bots_top_height)
      },
      bots_center_tabs(model, top_center_width),
      if panel_inline {
        bots_panel_resize_handle(
          bots_top_height,
          width,
          model.hover == "resize-bots-panel",
        )
      } else {
        vrule(bots_top_height)
      },
      bots_panel_tabs(panel_model, right_width),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width~, height=bots_top_height)
  let body_children : Array[@moui.View[Msg]] = []
  if sidebar_inline {
    body_children.push(bots_sidebar(model, sidebar_w, body_height))
    body_children.push(
      bots_resize_handle(body_height, model.hover == "resize-bots-sidebar"),
    )
  }
  body_children.push(bots_chat(model, body_center_width, body_height))
  body_children.push(
    if panel_inline {
      bots_panel_resize_handle(
        body_height,
        width,
        model.hover == "resize-bots-panel",
      )
    } else {
      vrule(body_height)
    },
  )
  body_children.push(bots_panel(panel_model, right_width, body_height))
  let body = @views.row(body_children, spacing=0.0, align=Stretch).frame(
    width~,
    height=body_height,
  )
  let root = @views.column(
      [
        top,
        @views.divider(color=white_a(0.07), thickness=1.0),
        body,
        @views.divider(color=white_a(0.10), thickness=1.0),
        bots_status_bar(width),
      ],
      spacing=0.0,
      align=Stretch,
    )
    .frame(width~, height~)
    .clip()
  let mut layered = root
  let grip_height = bots_top_height + body_height + 2.0
  if sidebar_inline {
    layered = @views.stack([
      layered,
      bots_sidebar_grip(width, grip_height, sidebar_w),
    ])
  }
  if panel_inline {
    layered = @views.stack([
      layered,
      bots_panel_grip(width, grip_height, width - right_width - 1.0, width),
    ])
  }
  if show_sidebar_drawer {
    let scrim = @views.container(
        @views.empty(),
        width~,
        height=bots_top_height + body_height + 2.0,
        background=black_a(0.45),
        padding=0.0,
      )
      .on_tap(ToggleSidebar)
      .offset(dx=0.0, dy=0.0)
    let drawer = bots_sidebar(model, sidebar_w, body_height).offset(
      dx=0.0,
      dy=bots_top_height + 1.0,
    )
    layered = @views.stack([layered, scrim, drawer])
  }
  if show_panel_drawer {
    let panel_w = compact_panel_width(model, width)
    let scrim = @views.container(
      @views.empty(),
      width~,
      height=bots_top_height + body_height + 2.0,
      background=black_a(0.35),
      padding=0.0,
    ).on_tap(ToggleBotItemPanel)
    let panel = @views.column(
        [
          bots_panel_tabs(model, panel_w),
          bots_panel(model, panel_w, body_height),
        ],
        spacing=0.0,
        align=Stretch,
      )
      .frame(width=panel_w, height=bots_top_height + body_height)
      .offset(dx=width - panel_w, dy=0.0)
    layered = @views.stack([layered, scrim, panel])
  }
  layered
}

///|
/// Title bar segment over the sidebar: traffic lights, wordmark and panel toggle.
fn bots_title_bar(
  width : Double,
  compact : Bool,
  toggle_hovered : Bool,
) -> @moui.View[Msg] {
  let lights = @views.row(
    [
      traffic_light(traffic_red),
      traffic_light(traffic_yellow),
      traffic_light(traffic_green),
    ],
    spacing=8.0,
    align=Center,
  )
  let toggle = @views.container(
      @views.lucide_icon(
        "panel-left",
        size=15.0,
        color=fg_muted,
        stroke_width=1.7,
      ),
      width=22.0,
      height=22.0,
      background=if toggle_hovered {
        white_a(0.06)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=5.0,
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover("panel-toggle", entered) })
    .on_tap(ToggleSidebar)
  let content = if compact {
    @views.row(
      [lights, @views.spacer(weight=1.0), toggle],
      spacing=0.0,
      align=Center,
    ).frame(width=width - 24.0)
  } else {
    @views.row(
      [
        lights,
        @views.spacer(min_length=13.0, weight=0.0),
        txt("Orca", 12.0, 600, fg_primary),
        @views.spacer(min_length=12.0, weight=0.0),
        toggle,
        @views.spacer(weight=1.0),
      ],
      spacing=0.0,
      align=Center,
    ).frame(width=width - 24.0)
  }
  @views.container(
    @views.padding_edges(content, left=8.0, right=16.0),
    width~,
    height=bots_top_height,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// Center tab strip: Scout, #eng and plus.
fn bots_center_tabs(model : Model, width : Double) -> @moui.View[Msg] {
  let active = active_bot_of(model)
  let title = match active {
    Some(bot) => bot.name
    None => "Scout"
  }
  let is_scout = match active {
    Some(bot) => bot.id == "scout"
    None => true
  }
  let tabs : Array[@moui.View[Msg]] = []
  if width >= 500.0 {
    let available = width
    let wanted = bots_center_tabs_width
    let scale = if available < wanted {
      let ratio = available / wanted
      if ratio < 0.45 {
        0.45
      } else {
        ratio
      }
    } else {
      1.0
    }
    if model.bot_chat_open {
      tabs.push(
        bot_center_tab(model, 0, title, bots_home_tab_width * scale, true),
      )
    }
    if is_scout && model.bot_eng_open {
      tabs.push(
        bot_center_tab(
          model,
          1,
          "#eng · checkout on Safari?",
          bots_eng_tab_width * scale,
          false,
        ),
      )
    }
    tabs.push(
      @views.container(
        @views.lucide_icon("plus", size=15.0, color=fg_muted, stroke_width=1.8),
        width=40.0 * scale,
        height=bots_top_height,
        background=@graphics.Color::transparent(),
        corner_radius=6.0,
        padding=0.0,
      ).on_tap(OpenModal),
    )
  } else {
    let show_plus = bots_tab_plus_visible(width)
    let show_eng = bots_tab_eng_visible(width, is_scout, model.bot_eng_open)
    let mut count = 0.0
    if model.bot_chat_open {
      count = count + 1.0
    }
    if show_eng {
      count = count + 1.0
    }
    if show_plus {
      count = count + 1.0
    }
    let gaps = if count > 1.0 { (count - 1.0) * 2.0 } else { 0.0 }
    let mut fixed = gaps
    if show_plus {
      fixed = fixed + 36.0
    }
    if show_eng {
      fixed = fixed + bots_eng_tab_width
    }
    let mut bot_width = width - fixed
    if bot_width < 84.0 {
      bot_width = 84.0
    }
    if bot_width > bots_home_tab_width {
      bot_width = bots_home_tab_width
    }
    if model.bot_chat_open {
      tabs.push(bot_center_tab(model, 0, title, bot_width, true))
    }
    if show_eng {
      tabs.push(
        bot_center_tab(
          model, 1, "#eng · checkout on Safari?", bots_eng_tab_width, false,
        ),
      )
    }
    if show_plus {
      tabs.push(
        @views.container(
          @views.lucide_icon(
            "plus",
            size=15.0,
            color=fg_muted,
            stroke_width=1.8,
          ),
          width=36.0,
          height=bots_top_height,
          background=@graphics.Color::transparent(),
          corner_radius=6.0,
          padding=0.0,
        ).on_tap(OpenModal),
      )
    }
  }
  tabs.push(@views.spacer(weight=1.0))
  let content = @views.row(tabs, spacing=2.0, align=Center).frame(width~)
  @views.container(
    content,
    width~,
    height=bots_top_height,
    background=bg_panel,
    padding=0.0,
  )
}

///|
/// One center tab with icon, title and close cross.
fn bot_center_tab(
  model : Model,
  index : Int32,
  title : String,
  width : Double,
  with_mascot : Bool,
) -> @moui.View[Msg] {
  let active = model.center_tab == index
  let hovered = model.hover == "bot-tab-\{index}"
  let color = if active { fg_primary } else { fg_muted }
  let show_close = hovered
  let label_width = if show_close { width - 46.0 } else { width - 20.0 }
  let show_icons = width >= 110.0
  let leading_items : Array[@moui.View[Msg]] = []
  let mut leading_w = 0.0
  if show_icons {
    if with_mascot {
      match active_bot_of(model) {
        Some(bot) => {
          if bot.working > 0 {
            leading_items.push(spinner(8.0, accent_amber))
            leading_w = leading_w + 11.0
          }
          leading_items.push(mascot_avatar(bot.mascot, 12.0))
          leading_w = leading_w + 12.0
        }
        None => ()
      }
    } else {
      leading_items.push(hash_icon(12.0, fg_muted))
      leading_w = leading_w + 12.0
    }
  }
  let text_gap = if with_mascot { 4.0 } else { 3.0 }
  let text_width = if label_width - leading_w - text_gap < 1.0 {
    1.0
  } else {
    label_width - leading_w - text_gap
  }
  let label_items : Array[@moui.View[Msg]] = []
  if show_icons && !leading_items.is_empty() {
    label_items.push(@views.row(leading_items, spacing=3.0, align=Center))
  }
  label_items.push(
    @views.text(title, wrap=false, align=TextStart)
    .font(sans(13.0, if active { 500 } else { 400 }))
    .foreground(color)
    .frame(width=text_width, height=bots_top_height)
    .clip(),
  )
  let label = @views.row(
      [
        @views.row(label_items, spacing=text_gap, align=Center),
        @views.spacer(weight=1.0),
      ],
      spacing=0.0,
      align=Center,
    )
    .frame(
      width=if label_width < 1.0 { 1.0 } else { label_width },
      height=bots_top_height,
    )
    .clip()
  let tab_children : Array[@moui.View[Msg]] = [label]
  if show_close {
    tab_children.push(@views.spacer(weight=1.0))
    tab_children.push(
      @views.container(
        x_icon(13.0, fg_muted),
        width=20.0,
        height=20.0,
        background=@graphics.Color::transparent(),
        corner_radius=5.0,
        padding=0.0,
      ).on_tap(CloseBotTab(index)),
    )
  }
  let content = @views.row(tab_children, spacing=6.0, align=Center).frame(
    width=width - 20.0,
  )
  let panel = @views.container(
    @views.padding_edges(
      content,
      left=if with_mascot { 3.0 } else { 0.0 },
      right=10.0,
    ),
    width~,
    height=bots_top_height,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
  let tab = @views.container(
    panel,
    width~,
    height=bots_top_height,
    background=if active {
      @graphics.Color::from_argb(0xFF232323)
    } else if hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    padding=0.0,
  )
  let hit = if active {
    @views.stack([
      tab,
      @views.container(
        @views.empty(),
        width~,
        height=2.0,
        background=fg_primary,
        padding=0.0,
      ).offset(dx=0.0, dy=bots_top_height - 2.0),
    ]).frame(width~, height=bots_top_height)
  } else {
    tab
  }
  hit
  .on_tap(SetCenterTab(index))
  .on_hover(fn(entered) { Hover("bot-tab-\{index}", entered) })
}

///|
/// Hash glyph; `hash` is absent from MoUI's vendored Lucide subset.
fn hash_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"M1 9h22M1 15h22M10 1 8 23M16 1l-2 22\"/></svg>",
    size~,
    color~,
    stroke_width=1.6,
  )
}

///|
/// Plug glyph for a connector's Connect action.
fn plug_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"M12 22v-5M9 8V2M15 8V2M18 8v5a4 4 0 0 1-4 4h-4a4 4 0 0 1-4-4V8Z\"/></svg>",
    size~,
    color~,
    stroke_width=1.8,
  )
}

///|
/// Unplug glyph for a connector's Disconnect action.
fn unplug_icon(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"m19 5 3-3M2 22l3-3M6.3 20.3a2.4 2.4 0 0 0 3.4 0L12 18l-6-6-2.3 2.3a2.4 2.4 0 0 0 0 3.4ZM7.5 13.5l5 5M10 8l2 2M15 3l2 2M9.5 7.5 8 9\"/></svg>",
    size~,
    color~,
    stroke_width=1.8,
  )
}

///|
/// Right panel tab bar: Home, Connectors, Chats, Files.
fn bots_panel_tabs(model : Model, width : Double) -> @moui.View[Msg] {
  if !model.bots_item_open {
    let toggle = @views.container(
      @views.lucide_icon(
        "panel-left",
        size=14.0,
        color=fg_muted,
        stroke_width=1.7,
      ),
      width=22.0,
      height=22.0,
      background=@graphics.Color::transparent(),
      corner_radius=5.0,
      padding=0.0,
    ).on_tap(ToggleBotItemPanel)
    let content = @views.row(
      [@views.spacer(weight=1.0), toggle],
      spacing=0.0,
      align=Center,
    ).frame(width=width - 16.0)
    return @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width~,
      height=bots_top_height,
      background=bg_panel,
      padding=0.0,
    )
  }
  let entries : Array[(@moui.View[Msg], String, Int32)] = [
    (
      @views.lucide_icon("house", size=14.0, color=fg_muted, stroke_width=1.7),
      "Home",
      0,
    ),
    (
      @views.lucide_icon("link", size=14.0, color=fg_muted, stroke_width=1.7),
      "Connectors",
      1,
    ),
    (
      @views.lucide_icon(
        "message-circle",
        size=14.0,
        color=fg_muted,
        stroke_width=1.7,
      ),
      "Chats",
      2,
    ),
    (
      @views.lucide_icon("file", size=14.0, color=fg_muted, stroke_width=1.7),
      "Files",
      3,
    ),
  ]
  let items : Array[@moui.View[Msg]] = []
  let compact = width < 360.0
  for entry in entries {
    let (icon, label, index) = entry
    let selected = model.panel_tab == index
    let hovered = model.hover == "panel-\{index}"
    let color = if selected { fg_primary } else { fg_secondary }
    let content = if compact {
      @views.row([icon], spacing=0.0, align=Center)
    } else {
      @views.row(
        [icon, txt(label, 13.0, if selected { 500 } else { 400 }, color)],
        spacing=5.0,
        align=Center,
      )
    }
    items.push(
      @views.padding_edges(
        @views.container(
          @views.padding_edges(content, left=8.0, right=8.0),
          height=28.0,
          background=if selected {
            white_a(0.10)
          } else if hovered {
            white_a(0.05)
          } else {
            @graphics.Color::transparent()
          },
          corner_radius=8.0,
          padding=0.0,
        )
        .on_tap(SetPanelTab(index))
        .on_hover(fn(entered) { Hover("panel-\{index}", entered) }),
        left=1.0,
        right=1.0,
      ),
    )
  }
  items.push(@views.spacer(weight=1.0))
  items.push(
    @views.container(
      @views.lucide_icon(
        "panel-left",
        size=14.0,
        color=fg_muted,
        stroke_width=1.7,
      ),
      width=22.0,
      height=22.0,
      background=@graphics.Color::transparent(),
      corner_radius=5.0,
      padding=0.0,
    ).on_tap(ToggleBotItemPanel),
  )
  let content = @views.row(items, spacing=2.0, align=Center).frame(
    width=width - 14.0,
  )
  @views.container(
    @views.padding_edges(content, left=7.0, right=7.0),
    width~,
    height=bots_top_height,
    background=bg_panel,
    padding=0.0,
  )
}

///|
/// Keep the two side panes inside the window; the chat keeps at least 300 px.
/// Stored drag widths are preferences, so a narrow window only shrinks the
/// rendered panes and a later widening restores them.
pub fn bots_pinned_widths(model : Model, width : Double) -> (Double, Double) {
  let left_cap = if width * 0.30 > 200.0 { width * 0.30 } else { 200.0 }
  let left = if model.bots_sidebar_w < 200.0 {
    200.0
  } else if model.bots_sidebar_w > left_cap {
    left_cap
  } else {
    model.bots_sidebar_w
  }
  let room = width - left - 10.0 - 300.0
  let panel_cap = if width * 0.32 > 240.0 { width * 0.32 } else { 240.0 }
  let mut cap = if panel_cap > 480.0 { 480.0 } else { panel_cap }
  if room < cap {
    cap = room
  }
  let panel = if cap < bots_rail_width {
    bots_rail_width
  } else if model.bots_panel_w < bots_rail_width {
    bots_rail_width
  } else if model.bots_panel_w > cap {
    cap
  } else {
    model.bots_panel_w
  }
  (left, panel)
}

///|
/// Sidebar: nav, Bots fleet, Projects disclosure and account footer.
fn bots_sidebar(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let list_height = height - 72.0
  let list_items : Array[@moui.View[Msg]] = [
    bots_nav_block(model, width),
    bots_section_header(model, width),
  ]
  if !model.bots_collapsed {
    if model.bot_search_open {
      list_items.push(bot_search_field(model, width))
    }
    if model.bots_options_open {
      list_items.push(bots_options(model, width))
    }
    let visible : Array[Bot] = []
    for bot in model.bots {
      if bot_matches(bot, model.bot_query) {
        visible.push(bot)
      }
    }
    let mut active_shown = false
    match active_bot_of(model) {
      Some(bot) =>
        if bot_matches(bot, model.bot_query) {
          list_items.push(selected_bot_card(model, bot, width))
          active_shown = true
        }
      None => ()
    }
    let mut others = 0
    for bot in visible {
      if bot.id != model.active_bot || !active_shown {
        list_items.push(other_bot_card(model, bot, width))
        others = others + 1
      }
    }
    if visible.is_empty() {
      list_items.push(bots_empty_row())
    }
  }
  let content = @views.column(list_items, spacing=0.0, align=Stretch).frame(
    width~,
  )
  @views.container(
    @views.column(
      [
        @views.scroll_view(content, width~, height=list_height),
        projects_disclosure(model, width),
        sidebar_account_footer(width),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// Search / Tasks / Automations nav rows; Search stays highlighted in Bots.
fn bots_nav_block(model : Model, width : Double) -> @moui.View[Msg] {
  let rows = @views.column(
    [
      fleet_nav_row(
        model,
        "Search",
        @views.lucide_icon(
          "search",
          size=16.0,
          color=fg_primary,
          stroke_width=1.8,
        ),
        true,
        SetSection(Search),
        "nav-search",
        width,
      ),
      fleet_nav_row(
        model,
        "Tasks",
        @views.lucide_icon("list", size=16.0, color=fg_muted, stroke_width=1.8),
        false,
        SetSection(Tasks),
        "nav-tasks",
        width,
      ),
      fleet_nav_row(
        model,
        "Automations",
        @views.lucide_icon("clock", size=16.0, color=fg_muted, stroke_width=1.8),
        false,
        SetSection(Automations),
        "nav-automations",
        width,
      ),
    ],
    spacing=1.5,
    align=Stretch,
  )
  @views.padding_edges(rows, top=3.0, left=8.0, right=8.0, bottom=9.0)
}

///|
fn fleet_nav_row(
  model : Model,
  label : String,
  icon : @moui.View[Msg],
  selected : Bool,
  message : Msg,
  hover_id : String,
  width : Double,
) -> @moui.View[Msg] {
  let hovered = model.hover == hover_id
  let content = @views.row(
    [
      icon,
      txt(label, 13.0, 500, if selected { fg_primary } else { fg_muted }),
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 32.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=width - 16.0,
    height=32.0,
    background=if selected {
      white_a(0.05)
    } else if hovered {
      white_a(0.03)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(hover_id, entered) })
}

///|
/// "Bots" section header with collapse chevron and actions.
fn bots_section_header(model : Model, width : Double) -> @moui.View[Msg] {
  let chevron = @views.container(
    @views.lucide_icon(
      if model.bots_collapsed {
        "chevron-right"
      } else {
        "chevron-down"
      },
      size=12.0,
      color=fg_secondary,
      stroke_width=1.8,
    ),
    width=16.0,
    height=20.0,
    background=@graphics.Color::transparent(),
    corner_radius=5.0,
    padding=0.0,
  ).on_tap(ToggleBotsFleet)
  let actions = @views.row(
    [
      icon_toggle(
        @views.lucide_icon(
          "search",
          size=14.0,
          color=if model.bot_search_open { fg_primary } else { fg_muted },
          stroke_width=1.7,
        ),
        model.bot_search_open,
        ToggleBotSearch,
      ),
      icon_toggle(
        sliders_icon(
          14.0,
          if model.bots_options_open {
            fg_primary
          } else {
            fg_muted
          },
        ),
        model.bots_options_open,
        ToggleBotOptions,
      ),
      icon_toggle(
        @views.lucide_icon("plus", size=14.0, color=fg_muted, stroke_width=1.8),
        false,
        AddBot,
      ),
    ],
    spacing=4.0,
    align=Center,
  )
  let content = @views.row(
    [
      chevron,
      txt("Bots", 12.0, 600, fg_secondary),
      @views.spacer(weight=1.0),
      actions,
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=width - 21.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=0.0, right=8.0),
      width=width - 13.0,
      height=32.0,
      background=@graphics.Color::transparent(),
      padding=0.0,
    ),
    left=5.0,
    right=8.0,
  )
}

///|
fn icon_toggle(
  icon : @moui.View[Msg],
  active : Bool,
  message : Msg,
) -> @moui.View[Msg] {
  @views.container(
    icon,
    width=20.0,
    height=20.0,
    background=if active {
      white_a(0.10)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=5.0,
    padding=0.0,
  ).on_tap(message)
}

///|
pub fn bot_matches(bot : Bot, query : String) -> Bool {
  if contains_text(bot.name, query) ||
    contains_text(bot.id, query) ||
    contains_text(bot.subtitle, query) {
    return true
  }
  for session in bot.sessions {
    if contains_text(session.label, query) {
      return true
    }
  }
  false
}

///|
fn bot_search_field(model : Model, width : Double) -> @moui.View[Msg] {
  let field = @views.text_field(
    model.bot_query,
    on_input=fn(text) { BotQueryInput(text) },
    key="bots-search",
    placeholder="Filter bots",
    style=bots_field_style(12.0, fg_muted),
    width=width - 68.0,
    height=28.0,
  )
  let content = @views.row(
    [
      @views.lucide_icon("search", size=13.0, color=fg_muted, stroke_width=1.8),
      field,
      @views.spacer(weight=1.0),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=width - 48.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=width - 32.0,
      height=32.0,
      background=white_a(0.05),
      corner_radius=8.0,
      border=Some(border_of(white_a(0.08), 1.0)),
      padding=0.0,
    ),
    left=8.0,
    right=8.0,
    top=2.0,
    bottom=4.0,
  )
}

///|
fn bots_options(model : Model, width : Double) -> @moui.View[Msg] {
  let content = @views.row(
    [
      txt("Show sessions", 12.0, 500, fg_body),
      @views.spacer(weight=1.0),
      bot_switch(model.bots_show_sessions),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 48.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=width - 32.0,
      height=32.0,
      background=white_a(0.04),
      corner_radius=8.0,
      border=Some(border_of(white_a(0.08), 1.0)),
      padding=0.0,
    ).on_tap(ToggleBotSessions),
    left=8.0,
    right=8.0,
    bottom=4.0,
  )
}

///|
fn bot_switch(on : Bool) -> @moui.View[Msg] {
  let knob = @views.container(
    @views.empty(),
    width=14.0,
    height=14.0,
    background=fg_primary,
    corner_radius=7.0,
    padding=0.0,
  )
  let track_items = if on {
    [@views.spacer(weight=1.0), knob]
  } else {
    [knob, @views.spacer(weight=1.0)]
  }
  @views.container(
    @views.row(track_items, spacing=0.0, align=Center).frame(width=30.0),
    width=36.0,
    height=20.0,
    background=if on { white_a(0.22) } else { white_a(0.10) },
    corner_radius=10.0,
    padding=3.0,
  )
}

///|
fn bots_empty_row() -> @moui.View[Msg] {
  @views.padding_edges(
    @views.column(
      [
        txt("No bots match", 12.0, 500, fg_body),
        txt("Try a bot name or session label.", 11.0, 400, fg_muted),
        @views.padding_edges(
          filter_pill_tap("Clear search", false, ClearBotQuery),
          top=2.0,
        ),
      ],
      spacing=6.0,
      align=Start,
    ),
    left=16.0,
    right=16.0,
    top=12.0,
    bottom=12.0,
  )
}

///|
/// The selected bot card with its nested sessions.
fn selected_bot_card(
  model : Model,
  bot : Bot,
  width : Double,
) -> @moui.View[Msg] {
  let name_column = @views.column(
    [
      txt(bot.name, 13.0, 600, fg_primary),
      @views.text(
        if bot.working > 0 {
          "\{bot.working} working"
        } else {
          bot.subtitle
        },
        width=110.0,
        wrap=false,
        align=TextStart,
      )
      .font(sans(12.0, 400))
      .foreground(fg_secondary),
    ],
    spacing=2.0,
    align=Start,
  ).frame(width=110.0)
  let right_side : Array[@moui.View[Msg]] = []
  if bot.working > 0 {
    right_side.push(spinner(9.0, accent_amber))
    right_side.push(txt("\{bot.working}", 12.0, 500, fg_secondary))
  }
  right_side.push(
    @views.container(
      @views.lucide_icon(
        "more-horizontal",
        size=14.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
      width=20.0,
      height=20.0,
      background=@graphics.Color::transparent(),
      corner_radius=5.0,
      padding=0.0,
    ).on_tap(ToggleBotOptions),
  )
  let header_items : Array[@moui.View[Msg]] = [
    mascot_with_status(bot.mascot, 36.0, accent_amber),
    name_column,
    @views.spacer(weight=1.0),
  ]
  for item in right_side {
    header_items.push(item)
  }
  let header = @views.row(header_items, spacing=6.0, align=Center).frame(
    width=width - 26.0,
  )
  let header_card = @views.padding_edges(
    @views.container(
      header,
      width=width - 8.0,
      background=white_a(0.10),
      corner_radius=10.0,
      border=Some(selected_border()),
      padding=5.0,
    ),
    left=4.0,
    right=4.0,
    top=2.0,
  )
  let items = [header_card]
  if model.bots_show_sessions {
    let session_views : Array[@moui.View[Msg]] = []
    for session in bot.sessions {
      session_views.push(session_row(model, session, width))
    }
    let sessions = @views.padding_edges(
      @views.column(session_views, spacing=1.0, align=Stretch),
      left=21.0,
      top=4.0,
      bottom=6.0,
    )
    items.push(sessions)
  } else {
    items.push(@views.padding_edges(@views.empty(), top=7.0))
  }
  @views.column(items, spacing=0.0, align=Start)
}

///|
/// Label column inside a Bots session row. The row ends 5 px from the
/// sidebar edge so the timestamp sits flush with the reference while a long
/// `#eng · checkout on Safari?` label still fits at the default 272 px width.
pub fn session_row_label_width(width : Double) -> Double {
  width - 107.0
}

///|
/// Character cap for a session label at the current sidebar width.
pub fn session_row_label_limit(width : Double) -> Int32 {
  let label_width = session_row_label_width(width)
  if label_width / 6.2 < 10.0 {
    10
  } else {
    (label_width / 6.2).to_int()
  }
}

///|
/// One indented session row.
fn session_row(
  model : Model,
  session : Session,
  width : Double,
) -> @moui.View[Msg] {
  let selected = model.active_session == session.id
  let mut nested_agent = false
  let base_label_width = session_row_label_width(width)
  let label_chars = session_row_label_limit(width)
  let glyphs : Array[@moui.View[Msg]] = []
  match session.kind {
    Home =>
      glyphs.push(
        @views.lucide_icon(
          "house",
          size=13.0,
          color=fg_secondary,
          stroke_width=1.7,
        ),
      )
    ClaudeSession => {
      nested_agent = true
      glyphs.push(spinner(10.0, accent_amber))
      glyphs.push(brand_icon(Claude, 12.0))
    }
    CodexSession => {
      nested_agent = true
      glyphs.push(check_circle_icon(10.0, accent_green))
      glyphs.push(brand_icon(Codex, 12.0))
    }
    Slack => glyphs.push(slack_icon(12.0))
  }
  let label_width = if nested_agent {
    base_label_width - 23.0
  } else {
    base_label_width
  }
  let content = @views.row(
    [
      @views.padding_edges(
        @views.row(glyphs, spacing=6.0, align=Center),
        left=if nested_agent { 12.0 } else { 0.0 },
        right=if nested_agent { 2.0 } else { 0.0 },
      ),
      @views.text(
        truncate_chars(session.label, label_chars),
        width=label_width,
        wrap=false,
        align=TextStart,
      )
      .font(sans(if nested_agent { 10.75 } else { 11.5 }, 400))
      .foreground(if selected { fg_primary } else { fg_secondary }),
      @views.spacer(weight=1.0),
      @views.padding_edges(
        @views.text(session.time, wrap=false, align=TextEnd)
        .font(sans(11.0, 400))
        .foreground(
          @graphics.Color::rgba(
            r=172.0 / 255.0,
            g=172.0 / 255.0,
            b=172.0 / 255.0,
            a=0.70,
          ),
        ),
        right=1.5,
      ),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=width - 36.0)
  let id = "session-\{session.id}"
  let hovered = model.hover == id
  @views.container(
    @views.padding_edges(content, left=4.0, right=4.0),
    width=width - 26.0,
    height=26.0,
    background=if selected {
      white_a(0.06)
    } else if hovered {
      white_a(0.03)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(SelectBot(session.id))
}

///|
/// A non-selected bot row in the fleet list.
fn other_bot_card(model : Model, bot : Bot, width : Double) -> @moui.View[Msg] {
  let name_column = @views.column(
    [
      txt(bot.name, 13.0, 600, fg_primary),
      @views.text(
        truncate_chars(bot.subtitle, 28),
        width=160.0,
        wrap=false,
        align=TextStart,
      )
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
  right_items.push(
    @views.lucide_icon(
      "chevron-right",
      size=12.0,
      color=fg_muted,
      stroke_width=1.8,
    ),
  )
  let right = @views.column(right_items, spacing=3.0, align=End)
  let content = @views.row(
    [
      mascot_avatar(bot.mascot, 36.0),
      name_column,
      @views.spacer(weight=1.0),
      right,
    ],
    spacing=7.0,
    align=Center,
  ).frame(width=width - 26.0)
  let id = "bot-\{bot.id}"
  let hovered = model.hover == id
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=5.0, right=5.0, top=5.0, bottom=5.0),
      width=width - 8.0,
      height=48.0,
      background=if hovered {
        white_a(0.04)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=10.0,
      padding=0.0,
    ),
    left=4.0,
    right=4.0,
    bottom=2.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(SelectBot(bot.id))
}

///|
/// Projects disclosure row pinned above the account footer.
fn projects_disclosure(model : Model, width : Double) -> @moui.View[Msg] {
  let content = @views.row(
    [
      @views.lucide_icon(
        "chevron-right",
        size=12.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
      txt("Projects", 13.0, 500, fg_body),
      @views.spacer(weight=1.0),
      icon_button(sliders_icon(14.0, fg_muted), ShowProjectsOptions, 20.0),
      icon_button(folder_plus_icon(14.0, fg_muted), OpenModal, 20.0),
      icon_button(
        @views.lucide_icon("plus", size=14.0, color=fg_muted, stroke_width=1.8),
        OpenModal,
        20.0,
      ),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width~,
    height=36.0,
    background=if model.hover == "sidebar-projects" {
      white_a(0.03)
    } else {
      @graphics.Color::transparent()
    },
    padding=0.0,
  )
  .on_tap(ShowProjects)
  .on_hover(fn(entered) { Hover("sidebar-projects", entered) })
}

///|
/// Settings / help on the left, history and panel toggle on the right.
fn sidebar_account_footer(width : Double) -> @moui.View[Msg] {
  let content = @views.row(
    [
      icon_button(
        @views.lucide_icon(
          "settings",
          size=15.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
        ToggleBotOptions,
        20.0,
      ),
      icon_button(
        @views.lucide_icon(
          "help-circle",
          size=15.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
        ToggleHelp,
        20.0,
      ),
      @views.spacer(weight=1.0),
      icon_button(
        @views.lucide_icon("clock", size=14.0, color=fg_muted, stroke_width=1.7),
        OpenBotItemPanel(2),
        20.0,
      ),
      icon_toggle(
        @views.lucide_icon(
          "panel-left",
          size=14.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
        false,
        ToggleSidebar,
      ),
      profile_avatar(28.0),
    ],
    spacing=9.0,
    align=Center,
  ).frame(width=width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width~,
    height=36.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
/// Signed-in account avatar with the reference's small plus badge.
fn profile_avatar(size : Double) -> @moui.View[Msg] {
  let badge_size = 10.0
  let avatar = @views.container(
    @views.center(txt("M", 12.0, 600, fg_primary), width=size, height=size),
    width=size,
    height=size,
    background=white_a(0.12),
    corner_radius=size / 2.0,
    border=Some(selected_border()),
    padding=0.0,
  )
  let badge = @views.container(
    @views.center(
      @views.lucide_icon("plus", size=6.5, color=fg_primary, stroke_width=2.4),
      width=badge_size,
      height=badge_size,
    ),
    width=badge_size,
    height=badge_size,
    background=white_a(0.18),
    corner_radius=badge_size / 2.0,
    border=Some(selected_border()),
    padding=0.0,
  )
  @views.stack([
    avatar,
    badge.offset(dx=size - badge_size - 1.0, dy=size - badge_size - 1.0),
  ]).frame(width=size, height=size)
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
    [@views.row([eye, eye], spacing=size * 0.16, align=Center), mouth],
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
/// Selected mascot with the reference's amber status dot and dark ring at
/// its bottom-right corner.
fn mascot_with_status(
  mascot : Mascot,
  size : Double,
  color : @graphics.Color,
) -> @moui.View[Msg] {
  let dot_size = 7.0
  let ring_size = dot_size + 4.0
  let ring = @views.container(
    status_dot(color, dot_size),
    width=ring_size,
    height=ring_size,
    background=@graphics.Color::from_argb(0xFF2A2A2A),
    corner_radius=ring_size / 2.0,
    padding=2.0,
  )
  @views.stack([
    mascot_avatar(mascot, size),
    ring.offset(dx=size - ring_size, dy=size - ring_size),
  ]).frame(width=size, height=size)
}

///|
/// Small robot-head outline glyph for Home Chat rows.
fn bot_glyph(size : Double, color : @graphics.Color) -> @moui.View[Msg] {
  @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"M12 2V5M8 5H16A2 2 0 0 1 18 7V17A2 2 0 0 1 16 19H8A2 2 0 0 1 6 17V7A2 2 0 0 1 8 5ZM9 11H9.01M15 11H15.01M9 15H15\"/></svg>",
    size~,
    color~,
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
      @views.row(
        [block(slack_blue), block(slack_green)],
        spacing=2.0,
        align=Center,
      ),
      @views.row(
        [block(slack_red), block(slack_yellow)],
        spacing=2.0,
        align=Center,
      ),
    ],
    spacing=2.0,
    align=Center,
  )
}

///|
/// Center chat pane: transcript, composer and caption.
fn bots_chat(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  if !bots_tab_open(model) {
    return @views.container(
      @views.column(
        [
          @views.lucide_icon(
            "message-circle",
            size=28.0,
            color=fg_dim,
            stroke_width=1.4,
          ),
          txt("No chat open", 16.0, 600, fg_primary),
          txt(
            "Pick a bot or session from the sidebar to start chatting.", 13.0, 400,
            fg_muted,
          ),
        ],
        spacing=10.0,
        justify=Center,
        align=Center,
      ).frame(width~, height~),
      width~,
      height~,
      background=bg_main,
      padding=0.0,
    )
  }
  let content_width = if width - 32.0 > 560.0 { 560.0 } else { width - 32.0 }
  let composer_area_height = 140.0 + bots_composer_menu_height(model)
  let scroll_height = height - composer_area_height
  let blocks = bots_transcript(model, content_width)
  let transcript = @views.column(blocks, spacing=16.0, align=Start).frame(
    width=content_width,
  )
  let scroller = @views.scroll_view(
    @views.padding_edges(
      @views.column([transcript], spacing=0.0, align=Center).frame(
        width=width - 32.0,
      ),
      top=0.0,
      bottom=24.0,
      left=16.0,
      right=16.0,
    ),
    width~,
    height=scroll_height,
  )
  @views.container(
    @views.column(
      [scroller, bots_composer(model, width)],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

///|
/// Build the blocks for the active center tab / bot / session.
fn bots_transcript(model : Model, width : Double) -> Array[@moui.View[Msg]] {
  let blocks = bots_base_transcript(model, width)
  let key = bot_chat_key(model)
  let mut index = 0
  for message in model.bot_messages {
    if message.key == key {
      blocks.push(bots_message_block(key, message.block, index, width))
      index = index + 1
    }
  }
  blocks
}

///|
/// Bots keeps its compact chat scale; only the Projects transcript uses the
/// larger reference copy.
fn bots_message_block(
  worktree_id : String,
  block : Block,
  index : Int32,
  width : Double,
) -> @moui.View[Msg] {
  match block {
    UserMessage(text) => user_bubble_sized(text, width, 14.0, 20.0)
    AssistantMessage(text) => paragraph(text, width, 14.0, 400, 20.0, fg_body)
    _ => block_view(worktree_id, block, index, width, width)
  }
}

///|
/// Seed transcript for the active center tab / bot / session.
fn bots_base_transcript(
  model : Model,
  width : Double,
) -> Array[@moui.View[Msg]] {
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
  if bot.item is None {
    if bot_chat_waiting(model) {
      return [
        muted_paragraph(new_bot_intro(bot), width),
        tool_row(BotTool, "Waiting for your first message", [], width),
      ]
    }
    return []
  }
  if !bot_has_seed_transcript(bot) {
    return []
  }
  generic_bot_blocks(bot, width)
}

///|
pub fn new_bot_intro(bot : Bot) -> String {
  "\{bot.name} is ready. Send a message to start its first task."
}

///|
/// Muted intro paragraph.
fn muted_paragraph(value : String, width : Double) -> @moui.View[Msg] {
  paragraph(
    value,
    width,
    14.0,
    400,
    22.0,
    @graphics.Color::from_argb(0xFF8F8F8F),
  )
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
      lead.push(
        @views.lucide_icon(
          "check",
          size=10.0,
          color=accent_green,
          stroke_width=2.0,
        ),
      )
    Link =>
      lead.push(
        @views.lucide_icon(
          "git-branch",
          size=10.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
      )
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
  let items : Array[@moui.View[Msg]] = [
    tool_icon_view(icon, 14.0),
    txt(lead, 13.0, 400, fg_body),
  ]
  for chip in chips {
    items.push(tool_chip_view(chip))
  }
  items.push(@views.spacer(weight=1.0))
  @views.row(items, spacing=6.0, align=Center).frame(width~, height=29.0)
}

///|
fn tool_icon_view(icon : ToolIcon, size : Double) -> @moui.View[Msg] {
  match icon {
    List => @views.lucide_icon("list", size~, color=fg_muted, stroke_width=1.7)
    ClaudeTool => brand_icon(Claude, size)
    CodexTool => brand_icon(Codex, size)
    BotTool => bot_glyph(size, fg_muted)
    LinkTool =>
      @views.lucide_icon("link", size~, color=fg_muted, stroke_width=1.7)
    PlusTool =>
      @views.lucide_icon("plus", size~, color=fg_muted, stroke_width=1.8)
    CheckTool =>
      @views.lucide_icon("check", size~, color=accent_green, stroke_width=2.0)
    CommentTool =>
      @views.lucide_icon(
        "message-circle",
        size~,
        color=fg_muted,
        stroke_width=1.7,
      )
    PlayTool =>
      @views.lucide_icon("play", size~, color=fg_muted, stroke_width=1.7)
  }
}

///|
/// Inline code chip for prose blocks.
fn code_span(text : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      @views.text(text, wrap=false, align=TextStart)
      .font(mono(12.0, 400))
      .foreground(fg_primary),
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
/// Inline code run used inside the right-panel message card.
fn code_span_small(text : String) -> @moui.View[Msg] {
  @views.text(text, wrap=false, align=TextStart)
  .font(mono(10.0, 400))
  .foreground(fg_secondary)
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
  @views.row(items, spacing=0.0, align=Center).frame(width~)
}

///|
/// A prose line variant that uses the compact code chip.
fn small_prose_row(
  parts : Array[(String, Bool)],
  width : Double,
) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = []
  for part in parts {
    let (text, is_code) = part
    if is_code {
      items.push(code_span_small(text))
    } else {
      items.push(
        @views.text(text, wrap=false, align=TextStart)
        .font(sans_lh(13.0, 400, 18.0))
        .foreground(fg_bubble),
      )
    }
  }
  items.push(@views.spacer(weight=1.0))
  @views.row(items, spacing=0.0, align=Center).frame(width~)
}

///|
/// "Worked for … ›" row with its bottom hairline.
fn bots_worked_row(label : String, width : Double) -> @moui.View[Msg] {
  let header = @views.row(
    [
      txt(label, 12.0, 400, fg_muted),
      @views.lucide_icon(
        "chevron-right",
        size=12.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  )
  @views.padding_edges(
    @views.column(
      [header, @views.divider(color=white_a(0.07), thickness=1.0)],
      spacing=10.0,
      align=Stretch,
    ).frame(width~),
    top=3.0,
  )
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
      @views.column([first, second], spacing=4.0, align=Start),
      left=14.0,
      right=14.0,
      top=10.0,
      bottom=16.0,
    ),
    background=bg_bubble,
    corner_radius=14.0,
    padding=0.0,
  )
  @views.column([bubble], spacing=0.0, align=End).frame(width~)
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
            { text: "Pay button ignores first tap on Safari", kind: Amber, },
            { text: "to In progress", kind: Plain, },
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
            (
              "event while the sticky cart footer overlaps the button. The fix listens for ",
              false,
            ),
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
      spacing=7.0,
      align=Start,
    ),
    @views.column(
      [
        tool_row(
          List,
          "Linked",
          [
            { text: "acme/web#1287", kind: Link, },
            { text: "to", kind: Plain, },
            { text: "Pay button ignores first tap on Safari", kind: Amber, },
          ],
          width,
        ),
        tool_row(
          List,
          "Added",
          [
            {
              text: "Sticky cart footer covers Pay on small s…",
              kind: Neutral,
            },
          ],
          width,
        ),
        tool_row(
          List,
          "Asked you about",
          [{ text: "Pay button ignores first tap on Safari", kind: Status, }],
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
      spacing=7.0,
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
      width, 14.0, 400, 22.0, fg_body,
    ),
    tool_row(
      List,
      "Added",
      [{ text: "Regression test for the first tap", kind: Neutral, }],
      width,
    ),
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
      width, 14.0, 400, 22.0, fg_body,
    ),
  ]
}

///|
/// The #eng thread tab.
fn eng_blocks(model : Model, width : Double) -> Array[@moui.View[Msg]] {
  let status_line = if bot_flag_on(model) {
    "Scout: shipped behind the safari_pay_click flag — Safari first tap now works."
  } else {
    "Scout: fix is ready in acme/web#1287 — deciding whether to ship behind a flag."
  }
  [
    muted_paragraph(
      "Thread in #eng: checkout on Safari is dropping the first tap on Pay.", width,
    ),
    tool_row(
      BotTool,
      "Scout posted a status update",
      [{ text: "#eng", kind: Link, }],
      width,
    ),
    bots_worked_row("Worked for 18m", width),
    paragraph(status_line, width, 14.0, 400, 22.0, fg_body),
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
      [{ text: "e2e/cart.spec is flaky, not a re…", kind: Amber, }],
      width,
    ),
    bots_worked_row("Worked for 2h 4m", width),
    paragraph(
      "The cart spec fails on webkit only, roughly one in five runs. The race is in the cart fixture teardown, not in checkout code.",
      width, 14.0, 400, 22.0, fg_body,
    ),
    tool_row(
      List,
      "Suggested",
      [{ text: "Quarantine cart.spec while fixing the race", kind: Neutral, }],
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
      "The bot will report back here when there is a concrete next step.", width,
      14.0, 400, 22.0, fg_body,
    ),
  ]
}

///|
/// Single-line composer copy trimmed to the field width. The full sentence
/// needs about 440 px; the phone field is 223 px, so it falls back to the
/// same short prompt as the main composer before cutting a word in half.
pub fn bots_composer_placeholder(field_width : Double) -> String {
  if field_width < 320.0 {
    "Ask anything…"
  } else if field_width < 460.0 {
    "Ask anything, @ bots or files, / for…"
  } else {
    "Ask anything, @ to mention bots or files, / for commands"
  }
}

///|
/// Center composer plus the caption underneath.
fn bots_composer(model : Model, center_width : Double) -> @moui.View[Msg] {
  let composer_width = if center_width - 32.0 > 575.0 {
    575.0
  } else {
    center_width - 32.0
  }
  let field_width = composer_width - 16.0
  let submit = match composer_menu_active(model) {
    Some(menu) => ComposerPick(composer_accept_index(model, menu))
    None => Send
  }
  let field = @views.text_field(
    model.draft,
    on_input=fn(text) { DraftInput(text) },
    on_submit=Some(submit),
    key="bots-composer",
    placeholder=bots_composer_placeholder(field_width),
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
  let model_picker = @views.row(
    [
      txt(bots_composer_model_label(model.composer_model), 14.0, 400, fg_body),
      @views.lucide_icon(
        "chevron-down",
        size=12.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).on_tap(CycleComposerModel)
  let footer_content = @views.row(
    [
      @views.container(
        @views.lucide_icon(
          "plus",
          size=16.0,
          color=fg_secondary,
          stroke_width=1.8,
        ),
        width=16.0,
        height=24.0,
        background=if model.hover == "bots-composer-plus" {
          white_a(0.06)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=6.0,
        padding=0.0,
      )
      .on_hover(fn(entered) { Hover("bots-composer-plus", entered) })
      .on_tap(DraftInput(composer_mention_trigger(model.draft))),
      @views.spacer(weight=1.0),
      model_picker,
      dictation_mic(
        16.0,
        dictation_main,
        model.dictation_target == dictation_main,
        model.hover == "bots-composer-mic",
        "bots-composer-mic",
      ),
      send,
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=field_width)
  let card = @views.container(
    @views.column([field, footer_content], spacing=4.0, align=Stretch).frame(
      width=field_width,
    ),
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
  let caption_items : Array[@moui.View[Msg]] = [
    txt("Maya’s MacBook Pro   Scout · Folder", 11.0, 400, fg_muted),
    @views.spacer(weight=1.0),
  ]
  if model.dictation_target == dictation_main && composer_width >= 360.0 {
    caption_items.push(txt("Dictated locally", 11.0, 500, accent_amber))
  }
  let caption = @views.row(caption_items, spacing=0.0, align=Center).frame(
    width=composer_width,
  )
  let body = @views.column(
    [centered, @views.padding_edges(caption, top=8.0)],
    spacing=0.0,
    align=Center,
  )
  let content = match composer_menu_active(model) {
    Some(menu) => {
      let picker = composer_menu_view(model, menu, composer_width, fn(insert) {
        DraftInput(insert)
      })
      @views.column([picker, body], spacing=8.0, align=Center)
    }
    None => body
  }
  @views.padding_edges(content.frame(width=center_width), top=10.0, bottom=8.0)
}

///|
/// Transparent text field style for bot-side inputs.
fn bots_field_style(
  size : Double,
  placeholder : @graphics.Color,
) -> @style.TextFieldStyle {
  let transparent = @graphics.Brush::Solid(@graphics.Color::transparent())
  let normal = @views.new_control_state_style(
    foreground=fg_body,
    background=transparent,
  )
  let focused = @views.new_control_state_style(
    foreground=fg_body,
    background=transparent,
  )
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
fn bots_panel(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  if !model.bots_item_open {
    return bots_panel_rail(model, height)
  }
  let show_composer = model.panel_tab == 0
  let composer_height = if show_composer { 72.0 } else { 0.0 }
  let scroll_height = height - composer_height
  let content = match model.panel_tab {
    0 => panel_home_content(model, scroll_height, width)
    1 => connectors_content(model, scroll_height, width)
    2 => chats_content(model, scroll_height, width)
    _ => files_content(model, scroll_height, width)
  }
  let children : Array[@moui.View[Msg]] = [content]
  if show_composer {
    children.push(
      @views.padding_edges(
        comment_composer(model, width),
        left=16.0,
        right=16.0,
        top=8.0,
        bottom=16.0,
      ),
    )
  }
  @views.container(
    @views.column(children, spacing=0.0, align=Stretch),
    width~,
    height~,
    background=bg_panel,
    padding=0.0,
  )
}

///|
/// Collapsed right panel: a vertical icon rail that reopens a tab in place.
fn bots_panel_rail(model : Model, height : Double) -> @moui.View[Msg] {
  let entries : Array[(String, Int32)] = [
    ("house", 0),
    ("link", 1),
    ("message-circle", 2),
    ("file", 3),
  ]
  let items : Array[@moui.View[Msg]] = []
  for entry in entries {
    let (icon_name, index) = entry
    let selected = model.panel_tab == index
    items.push(
      @views.padding_edges(
        @views.container(
          @views.lucide_icon(
            icon_name,
            size=15.0,
            color=if selected { fg_primary } else { fg_muted },
            stroke_width=1.7,
          ),
          width=32.0,
          height=32.0,
          background=if selected {
            white_a(0.10)
          } else {
            @graphics.Color::transparent()
          },
          corner_radius=8.0,
          padding=0.0,
        ).on_tap(OpenBotItemPanel(index)),
        top=3.0,
        bottom=3.0,
      ),
    )
  }
  @views.container(
    @views.padding_edges(
      @views.column(items, spacing=0.0, align=Center).frame(
        width=bots_rail_width,
      ),
      top=8.0,
    ),
    width=bots_rail_width,
    height~,
    background=bg_panel,
    padding=0.0,
  )
}

///|
/// Inner width of a right-panel row after the 12 px body gutter and the
/// container's 8 px side padding.
pub fn panel_row_inner_width(width : Double) -> Double {
  width - 40.0
}

///|
/// Text column in a Files row after the 28 px icon, 13 px chevron and the
/// row's three 10 px gaps.
pub fn panel_file_text_width(width : Double) -> Double {
  panel_row_inner_width(width) - 71.0
}

///|
/// One file row in the right panel's Files tab.
fn panel_file_row(
  model : Model,
  file : SeedFile,
  width : Double,
) -> @moui.View[Msg] {
  let text_w = panel_file_text_width(width)
  let id = "file-\{file.path}"
  let hovered = model.hover == id
  let content = @views.row(
    [
      @views.container(
        @views.lucide_icon(
          "file-text",
          size=14.0,
          color=fg_secondary,
          stroke_width=1.7,
        ),
        width=28.0,
        height=28.0,
        background=white_a(0.04),
        corner_radius=7.0,
        padding=0.0,
      ),
      @views.column(
        [
          clip_left(txt(file.path, 13.0, 500, fg_primary), text_w, 18.0),
          clip_left(
            txt("\{file.project} · \{file.summary}", 11.0, 400, fg_muted),
            text_w,
            15.0,
          ),
        ],
        spacing=2.0,
        align=Start,
      ),
      @views.spacer(weight=1.0),
      @views.lucide_icon(
        "chevron-right",
        size=13.0,
        color=fg_muted,
        stroke_width=1.7,
      ),
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=panel_row_inner_width(width), height=44.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=width - 24.0,
    height=44.0,
    background=if hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(SelectSearchResult(file.worktree_id))
}

///|
/// Source files that survive the Files-tab filter.
pub fn filtered_files(model : Model) -> Array[SeedFile] {
  let out : Array[SeedFile] = []
  for file in live_files(model) {
    if model.files_query == "" ||
      contains_text(file.path, model.files_query) ||
      contains_text(file.project, model.files_query) ||
      contains_text(file.summary, model.files_query) ||
      contains_text(file.content, model.files_query) {
      out.push(file)
    }
  }
  out
}

///|
/// Files tab: the indexed source list; each row opens its owning worktree.
fn files_content(
  model : Model,
  height : Double,
  width : Double,
) -> @moui.View[Msg] {
  let shown = filtered_files(model)
  let total = live_files(model).length()
  let field = @views.text_field(
    model.files_query,
    on_input=fn(text) { FileQueryInput(text) },
    key="files-filter",
    placeholder="Filter files",
    style=bots_field_style(12.0, fg_muted),
    width=width - 68.0,
    height=28.0,
  )
  let filter_row = @views.padding_edges(
    @views.container(
      @views.padding_edges(
        @views.row(
          [
            @views.lucide_icon(
              "search",
              size=13.0,
              color=fg_muted,
              stroke_width=1.8,
            ),
            field,
            @views.spacer(weight=1.0),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=width - 48.0),
        left=8.0,
        right=8.0,
      ),
      width=width - 32.0,
      height=32.0,
      background=white_a(0.05),
      corner_radius=8.0,
      border=Some(border_of(white_a(0.08), 1.0)),
      padding=0.0,
    ),
    top=2.0,
    bottom=2.0,
  )
  let count_label = if model.files_query == "" {
    "\{total} indexed source files"
  } else {
    "\{shown.length()} of \{total} indexed source files"
  }
  let rows : Array[@moui.View[Msg]] = [
    @views.column(
      [
        txt("Files", 16.0, 600, fg_primary),
        txt(count_label, 12.0, 400, fg_muted),
      ],
      spacing=3.0,
      align=Start,
    ),
    filter_row,
  ]
  let items : Array[@moui.View[Msg]] = []
  for file in shown {
    items.push(panel_file_row(model, file, width))
  }
  if items.is_empty() {
    rows.push(
      @views.padding_edges(
        txt("No files match this filter.", 12.0, 400, fg_muted),
        top=8.0,
        bottom=8.0,
      ),
    )
  } else {
    rows.push(@views.column(items, spacing=2.0, align=Stretch))
  }
  let body = @views.column(rows, spacing=12.0, align=Start).frame(
    width=width - 24.0,
  )
  @views.scroll_view(
    @views.padding_edges(body, left=12.0, right=12.0, top=16.0, bottom=16.0),
    width~,
    height~,
  )
}

///|
/// Greedy word wrapper for the compact "Done means" two-column body.
pub fn done_body_lines(value : String, max_chars : Int32) -> Array[String] {
  let words = value.split(" ").to_array()
  let lines : Array[String] = []
  let mut line = ""
  for word in words {
    let token = word.to_owned()
    if line == "" {
      line = token
    } else if line.length() + 1 + token.length() > max_chars {
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
/// Character budget for the Home "Done means" column. The desktop panel splits
/// its width between the label and the copy, so the copy wraps at the same word
/// boundary as the reference at the default 385 px panel width.
pub fn done_body_max_chars(body_width : Double) -> Int32 {
  let chars = (body_width / 5.3).to_int()
  if chars < 18 {
    18
  } else {
    chars
  }
}

///|
/// Inline menu under the Home status row. Picking a state overrides the
/// seeded item state for this bot only.
fn bot_status_menu(model : Model, bot : Bot, width : Double) -> @moui.View[Msg] {
  let available = width - 32.0
  let menu_width = if available > 208.0 {
    208.0
  } else if available < 0.0 {
    180.0
  } else {
    available
  }
  let current = bot_item_state(bot)
  let rows : Array[@moui.View[Msg]] = []
  for state in bot_item_states() {
    let selected = state == current
    let hovered = model.hover == "bot-status-option-\{state}"
    let row_items : Array[@moui.View[Msg]] = [
      txt(
        state,
        12.0,
        if selected {
          500
        } else {
          400
        },
        if selected {
          fg_primary
        } else {
          fg_body
        },
      ),
      @views.spacer(weight=1.0),
    ]
    if selected {
      row_items.push(
        @views.lucide_icon(
          "check",
          size=12.0,
          color=accent_amber,
          stroke_width=2.0,
        ),
      )
    }
    let row = @views.container(
        @views.padding_edges(
          @views.row(row_items, spacing=6.0, align=Center).frame(
            width=menu_width - 24.0,
          ),
          left=8.0,
          right=8.0,
        ),
        width=menu_width - 8.0,
        height=28.0,
        background=if hovered {
          white_a(0.07)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=6.0,
        padding=0.0,
      )
      .on_tap(SetBotItemState(state))
      .on_hover(fn(entered) { Hover("bot-status-option-\{state}", entered) })
    rows.push(row)
  }
  @views.container(
    @views.column(rows, spacing=2.0, align=Stretch),
    width=menu_width,
    background=@graphics.Color::from_argb(0xFF232323),
    corner_radius=8.0,
    border=Some(border_of(white_a(0.12), 1.0)),
    padding=4.0,
  )
}

///|
/// Home-panel text blocks keep a 12 px gutter on the left; widths already
/// account for the matching right margin.
fn panel_home_inset(view : @moui.View[Msg]) -> @moui.View[Msg] {
  @views.padding_edges(view, left=12.0)
}

///|
/// Home tab: item details, activity and Scout's question card.
fn panel_home_content(
  model : Model,
  height : Double,
  width : Double,
) -> @moui.View[Msg] {
  let bot = match active_bot_of(model) {
    Some(value) => value
    None => return panel_empty(height, "Home", "No bot selected.", width)
  }
  let item = match bot.item {
    Some(value) => value
    None => return panel_home_empty(model, bot, height, width)
  }
  let mut home_session_id = ""
  for session in bot.sessions {
    if home_session_id == "" && session.kind == Home {
      home_session_id = session.id
    }
  }
  let has_home_chat = home_session_id != ""
  let back_hovered = has_home_chat && model.hover == "panel-home-back"
  let back_base = @views.container(
    @views.padding_edges(
      @views.row(
        [
          @views.lucide_icon(
            "arrow-left",
            size=12.0,
            color=fg_muted,
            stroke_width=1.8,
          ),
          txt("Home", 12.0, 400, fg_muted),
          @views.spacer(min_length=3.0, weight=0.0),
          mascot_avatar(bot.mascot, 16.0),
          txt(bot.name, 12.0, 400, fg_primary),
          @views.spacer(weight=1.0),
        ],
        spacing=5.0,
        align=Center,
      ).frame(width=width - 40.0),
      left=4.0,
      right=4.0,
    ),
    width=width - 32.0,
    height=24.0,
    background=if back_hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  let back = if has_home_chat {
    back_base
    .on_tap(SelectBot(home_session_id))
    .on_hover(fn(entered) { Hover("panel-home-back", entered) })
  } else {
    back_base
  }
  let narrow = bots_panel_narrow(width)
  let title = if bots_panel_title_wraps(width) {
    @views.text(
      "\{item.number} \{item.title}",
      width=width - 24.0,
      wrap=true,
      align=TextStart,
    )
    .font(sans(16.0, 600))
    .foreground(fg_primary)
  } else {
    @views.text(
      "\{item.number} \{item.title}",
      width=width - 24.0,
      wrap=false,
      align=TextStart,
    )
    .font(sans(16.0, 600))
    .foreground(fg_primary)
  }
  let status_state = bot_item_state(bot)
  let status_lead = if status_state == "Done" {
    @views.lucide_icon("check", size=13.0, color=accent_green, stroke_width=2.0)
  } else {
    loader_icon(13.0, accent_amber)
  }
  let status_hovered = model.hover == "bot-status-menu"
  let status_chip = @views.container(
      @views.padding_edges(
        @views.row(
          [
            status_lead,
            txt(status_state, 13.0, 500, fg_primary),
            @views.lucide_icon(
              "chevron-down",
              size=12.0,
              color=accent_amber,
              stroke_width=1.8,
            ),
          ],
          spacing=5.0,
          align=Center,
        ),
        left=0.0,
        right=0.0,
      ),
      height=24.0,
      background=if model.bot_status_menu_open {
        white_a(0.08)
      } else if status_hovered {
        white_a(0.05)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=6.0,
      padding=0.0,
    )
    .on_tap(ToggleBotStatusMenu)
    .on_hover(fn(entered) { Hover("bot-status-menu", entered) })
  let status_items : Array[@moui.View[Msg]] = [status_chip]
  if !narrow {
    status_items.push(@views.spacer(min_length=10.0, weight=0.0))
    status_items.push(txt(item.meta, 12.0, 400, fg_muted))
  }
  status_items.push(@views.spacer(weight=1.0))
  let status_row = @views.row(status_items, spacing=4.0, align=Center).frame(
    width=width - 28.0,
  )
  let status_block = if model.bot_status_menu_open {
    @views.column(
      [status_row, bot_status_menu(model, bot, width)],
      spacing=4.0,
      align=Start,
    )
  } else {
    status_row
  }
  let chip_rows : Array[@moui.View[Msg]] = []
  let mut chip_index = 0
  while chip_index < item.chips.length() {
    let group : Array[@moui.View[Msg]] = [panel_chip(item.chips[chip_index])]
    if !narrow && chip_index + 1 < item.chips.length() {
      group.push(panel_chip(item.chips[chip_index + 1]))
    }
    chip_rows.push(@views.row(group, spacing=8.0, align=Center))
    let step = if narrow { 1 } else { 2 }
    chip_index = chip_index + step
  }
  let chat_row_hovered = has_home_chat && model.hover == "panel-home-chat"
  let chat_row_base = @views.container(
    @views.padding_edges(
      @views.row(
        [
          txt("Chat", 12.0, 400, fg_muted),
          hgap(48.0),
          @views.lucide_icon(
            "house",
            size=14.0,
            color=fg_muted,
            stroke_width=1.7,
          ),
          txt("Home Chat", 13.0, 400, fg_primary),
          @views.lucide_icon(
            "external-link",
            size=12.0,
            color=fg_muted,
            stroke_width=1.7,
          ),
          @views.spacer(weight=1.0),
        ],
        spacing=6.0,
        align=Center,
      ).frame(width=width - 36.0, height=24.0),
      left=4.0,
      right=4.0,
    ),
    width=width - 28.0,
    height=24.0,
    background=if chat_row_hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  let chat_row = if has_home_chat {
    chat_row_base
    .on_tap(SelectBot(home_session_id))
    .on_hover(fn(entered) { Hover("panel-home-chat", entered) })
  } else {
    chat_row_base
  }
  let done_row = if narrow {
    @views.column(
      [
        txt("Done means", 12.0, 400, fg_muted),
        paragraph(item.done_means, width - 28.0, 13.0, 400, 18.0, fg_body),
      ],
      spacing=4.0,
      align=Start,
    ).frame(width=width - 28.0)
  } else {
    let done_lines : Array[@moui.View[Msg]] = []
    let body_width = width - 124.0
    for
      line in done_body_lines(item.done_means, done_body_max_chars(body_width)) {
      done_lines.push(
        @views.text(line, width=body_width, wrap=false, align=TextStart)
        .font(sans(13.0, 400))
        .foreground(fg_body),
      )
    }
    @views.row(
      [
        @views.text("Done means", width=94.0, wrap=false, align=TextStart)
        .font(sans(12.0, 400))
        .foreground(fg_muted),
        @views.column(done_lines, spacing=2.0, align=Start).frame(
          width=body_width,
        ),
        @views.spacer(weight=1.0),
      ],
      spacing=0.0,
      align=Start,
    ).frame(width=width - 28.0)
  }
  let activity_rows : Array[@moui.View[Msg]] = []
  for activity in item.activities {
    activity_rows.push(
      activity_row(
        activity_icon_view(activity.icon),
        activity.text,
        activity.sub,
        activity.time,
        false,
        width,
      ),
    )
  }
  let mut has_status_activity = false
  for activity in item.activities {
    if activity.text.has_prefix("Status set to ") {
      has_status_activity = true
    }
  }
  let comment_key = bot_comment_key(model)
  for comment in model.comments {
    if comment.key == comment_key {
      activity_rows.push(
        activity_row(
          activity_icon_view(CommentActivity),
          comment.text,
          "",
          "now",
          true,
          width,
        ),
      )
    }
  }
  if bot.item_state != "" && !has_status_activity {
    activity_rows.push(
      activity_row(
        activity_icon_view(
          if bot.item_state == "Done" {
            CheckActivity
          } else {
            PlayActivity
          },
        ),
        "Status set to \{bot.item_state}",
        "",
        "now",
        false,
        width,
      ),
    )
  }
  let activity_block = @views.column(
    [
      txt("Activity", 12.0, 400, fg_muted),
      @views.column(activity_rows, spacing=0.5, align=Stretch),
    ],
    spacing=6.5,
    align=Start,
  ).frame(width=width - 28.0)
  let message_block = match item.message {
    Some(message) => scout_message_card(model, message, width)
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
  ).frame(width=width - 28.0)
  let body = @views.column(
    [
      panel_home_inset(back),
      panel_home_inset(title),
      panel_home_inset(status_block),
      panel_home_inset(@views.column(chip_rows, spacing=6.0, align=Start)),
      @views.divider(color=white_a(0.07), thickness=1.0),
      panel_home_inset(@views.padding_edges(chat_row, top=4.0)),
      panel_home_inset(done_row),
      panel_home_inset(@views.padding_edges(activity_block, top=5.0)),
      @views.padding_edges(message_block, left=6.0, right=6.0),
      panel_home_inset(@views.padding_edges(dot, top=32.0)),
    ],
    spacing=8.0,
    align=Start,
  ).frame(width~)
  @views.scroll_view(
    @views.padding_edges(body, top=6.0, bottom=16.0),
    width~,
    height~,
  )
}

///|
/// Home tab for a bot that has no active work item yet: explains the empty
/// state and opens its Home Chat instead of dead-ending.
fn panel_home_empty(
  model : Model,
  bot : Bot,
  height : Double,
  width : Double,
) -> @moui.View[Msg] {
  let mut home_session_id = ""
  for session in bot.sessions {
    if home_session_id == "" && session.kind == Home {
      home_session_id = session.id
    }
  }
  let has_home_chat = home_session_id != ""
  let open_button = if has_home_chat {
    page_button_hover(
      model,
      "panel-home-open",
      "Open Home Chat",
      @views.lucide_icon(
        "message-circle",
        size=13.0,
        color=fg_body,
        stroke_width=1.8,
      ),
      SelectBot(home_session_id),
      false,
    )
  } else {
    page_button_hover_disabled(
      "Open Home Chat",
      @views.lucide_icon(
        "message-circle",
        size=13.0,
        color=fg_dim,
        stroke_width=1.8,
      ),
    )
  }
  let body_w = if width - 64.0 < 160.0 { 160.0 } else { width - 64.0 }
  @views.scroll_view(
    @views.padding_edges(
      @views.container(
        @views.column(
          [
            mascot_avatar(bot.mascot, 40.0),
            txt("No active item", 16.0, 600, fg_primary),
            paragraph(
              bot_home_empty_copy(model, bot),
              body_w,
              13.0,
              400,
              19.0,
              fg_muted,
            ),
            @views.padding_edges(open_button, top=4.0),
          ],
          spacing=10.0,
          align=Center,
        ).frame(width=body_w, height=240.0),
        width=body_w,
        height=240.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      left=16.0,
      right=16.0,
      top=16.0,
    ),
    width~,
    height~,
  )
}

///|
/// A fixed horizontal gap that reports no height, unlike a zero-weight spacer
/// (which uses its min length on both axes).
fn hgap(width : Double) -> @moui.View[Msg] {
  @views.padding_edges(@views.empty(), left=width / 2.0, right=width / 2.0)
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
      lead.push(
        @views.lucide_icon(
          "check",
          size=11.0,
          color=accent_green,
          stroke_width=2.0,
        ),
      )
    Link =>
      lead.push(
        @views.lucide_icon(
          "git-branch",
          size=11.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
      )
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
    height=24.0,
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
    AddActivity =>
      @views.lucide_icon("plus", size=13.0, color=fg_muted, stroke_width=1.8)
    PlayActivity =>
      @views.lucide_icon("play", size=13.0, color=fg_muted, stroke_width=1.7)
    CheckActivity =>
      @views.lucide_icon("check", size=13.0, color=fg_muted, stroke_width=1.8)
    LinkActivity =>
      @views.lucide_icon("link", size=13.0, color=fg_muted, stroke_width=1.7)
    CommentActivity =>
      @views.lucide_icon(
        "message-circle",
        size=13.0,
        color=fg_muted,
        stroke_width=1.7,
      )
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
  width : Double,
) -> @moui.View[Msg] {
  let label = if wrap {
    @views.text(text, width=width - 130.0, wrap=true, align=TextStart)
    .font(sans_lh(12.0, 400, 17.0))
    .foreground(fg_body)
  } else if bots_panel_narrow(width) {
    clip_left(
      @views.text(text, width=0.0, wrap=false, align=TextStart)
      .font(sans(12.0, 400))
      .foreground(fg_body),
      width - 140.0,
      20.0,
    )
  } else {
    txt(text, 12.0, 400, fg_body)
  }
  let main = @views.row(
    [icon, label, @views.spacer(weight=1.0), txt(time, 11.0, 400, fg_muted)],
    spacing=9.0,
    align=Center,
  ).frame(width=width - 33.0, height=24.0)
  let main = @views.padding_edges(main, left=5.0)
  if sub == "" {
    main
  } else {
    @views.column(
      [main, @views.padding_edges(txt(sub, 12.0, 400, fg_muted), left=26.0)],
      spacing=2.0,
      align=Start,
    )
  }
}

///|
/// Scout's message card with the reply chip.
fn scout_message_card(
  model : Model,
  message : BotMessage,
  width : Double,
) -> @moui.View[Msg] {
  let flag_on = bot_flag_on(model)
  let header = @views.row(
    [
      mascot_avatar(Scout, 20.0),
      txt(message.name, 13.0, 500, fg_primary),
      @views.spacer(weight=1.0),
      txt(message.time, 11.0, 400, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 27.0)
  let reply_chip = @views.container(
    @views.padding_edges(
      txt(
        message.reply_chip,
        12.0,
        500,
        if flag_on {
          accent_amber
        } else {
          fg_body
        },
      ),
      left=8.0,
      right=8.0,
    ),
    height=26.0,
    background=if flag_on { white_a(0.08) } else { white_a(0.04) },
    corner_radius=7.0,
    border=Some(
      border_of(
        if flag_on {
          @graphics.Color::rgba(
            r=234.0 / 255.0,
            g=179.0 / 255.0,
            b=8.0 / 255.0,
            a=0.6,
          )
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
  ).frame(width=width - 54.5)
  let line1 = if bots_panel_narrow(width) {
    clip_left(
      @views.text(message.line1, width=0.0, wrap=false, align=TextStart)
      .font(sans(13.0, 400))
      .foreground(fg_bubble),
      width - 54.5,
      20.0,
    )
  } else {
    txt(message.line1, 13.0, 400, fg_bubble)
  }
  let prompt = @views.column(
    [
      small_prose_row(
        [
          ("Ship it to everyone, or behind the ", false),
          ("safari_pay_click", true),
        ],
        width - 54.5,
      ),
      second_line,
    ],
    spacing=0.0,
    align=Start,
  )
  let body = @views.column(
    [line1, @views.padding_edges(prompt, top=15.0)],
    spacing=0.0,
    align=Start,
  ).frame(width=width - 54.5)
  @views.container(
    @views.padding_edges(
      @views.column(
        [header, @views.padding_edges(body, left=27.5)],
        spacing=6.0,
        align=Start,
      ),
      left=8.0,
      right=5.0,
      top=2.5,
      bottom=10.0,
    ),
    width=width - 14.0,
    background=white_a(0.05),
    corner_radius=12.0,
    padding=0.0,
  )
}

///|
/// Fixed comment composer at the bottom of the right panel.
fn comment_composer(model : Model, width : Double) -> @moui.View[Msg] {
  let field = @views.text_field(
    model.comment_draft,
    on_input=fn(text) { CommentInput(text) },
    on_submit=Some(SendComment),
    key="bots-comment",
    placeholder="Add a comment…",
    style=bots_field_style(13.0, fg_muted),
    width=width - 148.0,
    height=40.0,
  )
  let send = @views.container(
      arrow_up_icon(13.0, fg_primary),
      width=28.0,
      height=28.0,
      background=if model.hover == "bots-comment-send" {
        @graphics.Color::from_argb(0xFF4D4D4D)
      } else {
        @graphics.Color::from_argb(0xFF3D3D3D)
      },
      corner_radius=14.0,
      padding=0.0,
    )
    .on_tap(SendComment)
    .on_hover(fn(entered) { Hover("bots-comment-send", entered) })
  let left_group = @views.row(
    [
      @views.lucide_icon(
        "plus",
        size=16.0,
        color=fg_secondary,
        stroke_width=1.8,
      ),
      field,
    ],
    spacing=3.0,
    align=Center,
  )
  let content = @views.row(
    [
      left_group,
      @views.spacer(weight=1.0),
      dictation_mic(
        15.0,
        dictation_comment,
        model.dictation_target == dictation_comment,
        model.hover == "bots-comment-mic",
        "bots-comment-mic",
      ),
      send,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 47.5)
  @views.container(
    @views.padding_edges(content, left=5.5, right=10.0),
    width=width - 32.0,
    height=48.0,
    background=white_a(0.04),
    corner_radius=12.0,
    border=Some(border_of(white_a(0.09), 1.0)),
    padding=0.0,
  )
}

///|
/// Connectors tab: linked services that expand into a short status card and
/// can be connected or disconnected in place.
fn connectors_content(
  model : Model,
  height : Double,
  width : Double,
) -> @moui.View[Msg] {
  let mut connected = 0
  for connector in model.connectors {
    if connector.connected {
      connected = connected + 1
    }
  }
  let rows : Array[@moui.View[Msg]] = []
  let mut index = 0
  for connector in model.connectors {
    let open = model.connector_open == index
    let hovered = model.hover == "connector-\{index}"
    let header = @views.container(
        @views.padding_edges(
          @views.row(
            [
              mascot_avatar(connector.mascot, 28.0),
              @views.column(
                [
                  txt(connector.name, 13.0, 500, fg_primary),
                  txt(connector.account, 11.0, 400, fg_muted),
                ],
                spacing=2.0,
                align=Start,
              ),
              @views.spacer(weight=1.0),
              @views.lucide_icon(
                if open {
                  "chevron-down"
                } else {
                  "chevron-right"
                },
                size=12.0,
                color=fg_muted,
                stroke_width=1.8,
              ),
            ],
            spacing=10.0,
            align=Center,
          ).frame(width=width - 52.0),
          left=10.0,
          right=10.0,
          top=10.0,
          bottom=10.0,
        ),
        width=width - 32.0,
        background=if open {
          @graphics.Color::transparent()
        } else if hovered {
          white_a(0.04)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=10.0,
        padding=0.0,
      )
      .on_tap(ToggleConnector(index))
      .on_hover(fn(entered) { Hover("connector-\{index}", entered) })
    let items : Array[@moui.View[Msg]] = [header]
    if open {
      let action = if connector.connected {
        page_button_hover(
          model,
          "connector-action-\{index}",
          "Disconnect",
          unplug_icon(12.0, fg_body),
          ToggleConnectorConnected(index),
          false,
        )
      } else {
        page_button_hover(
          model,
          "connector-action-\{index}",
          "Connect",
          plug_icon(12.0, bg_card),
          ToggleConnectorConnected(index),
          true,
        )
      }
      items.push(
        @views.padding_edges(
          @views.column(
            [
              paragraph(
                connector.detail,
                width - 56.0,
                12.0,
                400,
                18.0,
                fg_body,
              ),
              @views.row(
                [
                  status_dot(
                    if connector.connected {
                      accent_green
                    } else {
                      fg_dim
                    },
                    6.0,
                  ),
                  txt(
                    if connector.connected {
                      "Connected"
                    } else {
                      "Not connected"
                    },
                    11.0,
                    400,
                    fg_muted,
                  ),
                  @views.spacer(weight=1.0),
                  action,
                ],
                spacing=7.0,
                align=Center,
              ).frame(width=width - 56.0),
            ],
            spacing=10.0,
            align=Start,
          ),
          left=12.0,
          right=12.0,
          bottom=12.0,
        ),
      )
    }
    rows.push(
      @views.container(
        @views.column(items, spacing=0.0, align=Stretch),
        width=width - 32.0,
        background=if open {
          white_a(0.04)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=10.0,
        border=if open { Some(border_of(white_a(0.09), 1.0)) } else { None },
        padding=0.0,
      ),
    )
    index = index + 1
  }
  let title = @views.row(
    [
      txt("Connectors", 16.0, 600, fg_primary),
      @views.spacer(weight=1.0),
      txt(
        "\{connected} of \{model.connectors.length()} connected",
        11.0,
        400,
        fg_muted,
      ),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 32.0)
  let body = @views.column(
    [title, @views.column(rows, spacing=4.0, align=Stretch)],
    spacing=12.0,
    align=Start,
  ).frame(width=width - 32.0)
  @views.scroll_view(
    @views.padding_edges(body, left=16.0, right=16.0, top=16.0, bottom=16.0),
    width~,
    height~,
  )
}

///|
fn session_kind_label(kind : SessionKind) -> String {
  match kind {
    Home => "Home chat"
    ClaudeSession => "Claude Code"
    CodexSession => "Codex"
    Slack => "Slack"
  }
}

///|
fn chat_session_icon(kind : SessionKind) -> @moui.View[Msg] {
  match kind {
    Home =>
      @views.lucide_icon(
        "house",
        size=14.0,
        color=fg_secondary,
        stroke_width=1.7,
      )
    ClaudeSession => brand_icon(Claude, 14.0)
    CodexSession => brand_icon(Codex, 14.0)
    Slack => slack_icon(14.0)
  }
}

///|
/// Chats tab: the active bot's sessions, each opening that chat.
fn chats_content(
  model : Model,
  height : Double,
  width : Double,
) -> @moui.View[Msg] {
  let bot = match active_bot_of(model) {
    Some(value) => value
    None => return panel_empty(height, "Chats", "No bot selected.", width)
  }
  let rows : Array[@moui.View[Msg]] = []
  for session in bot.sessions {
    let selected = model.active_session == session.id
    let hovered = model.hover == "panel-chat-\{session.id}"
    let content = @views.row(
      [
        @views.container(
          chat_session_icon(session.kind),
          width=28.0,
          height=28.0,
          background=white_a(0.04),
          corner_radius=7.0,
          padding=0.0,
        ),
        @views.column(
          [
            txt(session.label, 13.0, 500, fg_primary),
            txt(session_kind_label(session.kind), 11.0, 400, fg_muted),
          ],
          spacing=2.0,
          align=Start,
        ),
        @views.spacer(weight=1.0),
        txt(session.time, 11.0, 400, fg_muted),
        @views.lucide_icon(
          "chevron-right",
          size=12.0,
          color=fg_muted,
          stroke_width=1.7,
        ),
      ],
      spacing=10.0,
      align=Center,
    ).frame(width=panel_row_inner_width(width), height=44.0)
    rows.push(
      @views.container(
        @views.padding_edges(content, left=8.0, right=8.0),
        width=width - 24.0,
        height=48.0,
        background=if selected {
          white_a(0.06)
        } else if hovered {
          white_a(0.03)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=8.0,
        border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
        padding=0.0,
      )
      .on_tap(SelectBot(session.id))
      .on_hover(fn(entered) { Hover("panel-chat-\{session.id}", entered) }),
    )
  }
  let body = @views.column(
    [
      @views.column(
        [
          txt("Chats", 16.0, 600, fg_primary),
          txt(
            "\{bot.sessions.length()} chat sessions with \{bot.name}",
            12.0,
            400,
            fg_muted,
          ),
        ],
        spacing=3.0,
        align=Start,
      ),
      @views.column(rows, spacing=2.0, align=Stretch),
    ],
    spacing=12.0,
    align=Start,
  ).frame(width=width - 24.0)
  @views.scroll_view(
    @views.padding_edges(body, left=12.0, right=12.0, top=16.0, bottom=16.0),
    width~,
    height~,
  )
}

///|
/// Empty state for Chats and Files.
fn panel_empty(
  height : Double,
  eyebrow : String,
  body : String,
  width : Double,
) -> @moui.View[Msg] {
  @views.scroll_view(
    @views.padding_edges(
      @views.container(
        @views.column(
          [txt(eyebrow, 11.0, 600, fg_dim), txt(body, 13.0, 400, fg_muted)],
          spacing=6.0,
          align=Center,
        ),
        width=width - 32.0,
        height=200.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      left=16.0,
      right=16.0,
      top=16.0,
    ),
    width~,
    height~,
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
  let compact = bots_status_compact(width)
  let left_items : Array[@moui.View[Msg]] = [
    sparkles_icon(11.0, accent_amber),
    @views.spacer(min_length=6.0, weight=0.0),
    meter(0.38),
    @views.spacer(min_length=6.0, weight=0.0),
    txt("38%", 11.0, 400, fg_muted),
  ]
  if !compact {
    left_items.push(@views.spacer(min_length=16.0, weight=0.0))
    left_items.push(brand_icon(Codex, 11.0))
    left_items.push(@views.spacer(min_length=6.0, weight=0.0))
    left_items.push(meter(0.12))
    left_items.push(@views.spacer(min_length=6.0, weight=0.0))
    left_items.push(txt("12%", 11.0, 400, fg_muted))
  }
  left_items.push(@views.spacer(weight=1.0))
  left_items.push(txt("maya-mbp", 11.0, 400, fg_muted))
  left_items.push(@views.spacer(min_length=12.0, weight=0.0))
  left_items.push(txt("2 hosts", 11.0, 400, fg_dim))
  let left = @views.row(left_items, spacing=0.0, align=Center).frame(
    width=width - 24.0,
  )
  @views.container(
    @views.padding_edges(left, left=12.0, right=12.0),
    width~,
    height=bots_status_height,
    background=bg_panel,
    padding=0.0,
  )
}
