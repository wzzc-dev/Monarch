///|
let titlebar_height : Double = 36.0

///|
let tabbar_height : Double = 36.0

///|
let sidebar_width : Double = 280.0

///|
let sidebar_row_width : Double = sidebar_width - 16.0

///|
let worktree_row_width : Double = sidebar_width - 12.0

///|
/// Fixed height of the composer block (48 input + 32 footer + padding).
let composer_height : Double = 136.0

///|
/// Clamp a string to `max` characters with an ellipsis.
pub fn truncate_chars(text : String, max : Int32) -> String {
  let chars = text.to_array()
  if chars.length() <= max {
    return text
  }
  let out : Array[Char] = []
  let mut i = 0
  while i < max - 1 {
    out.push(chars[i])
    i = i + 1
  }
  out.push('…')
  String::from_iter(out.iter())
}

///|
/// A plain text run with font and colour.
pub fn txt(
  value : String,
  size : Double,
  weight : Int32,
  color : @graphics.Color,
) -> @moui.View[Msg] {
  @views.text(value, wrap=false, align=TextStart).font(sans(size, weight)).foreground(color)
}

///|
/// A wrapping paragraph with a fixed width and line height.
pub fn paragraph(
  value : String,
  width : Double,
  size : Double,
  weight : Int32,
  line_height : Double,
  color : @graphics.Color,
) -> @moui.View[Msg] {
  @views.text(value, width=width, wrap=true, align=TextStart).font(sans_lh(size, weight, line_height)).foreground(color)
}

///|
/// A clickable square icon button.
fn icon_button(
  icon : @moui.View[Msg],
  message : Msg,
  size : Double,
) -> @moui.View[Msg] {
  @views.container(icon, width=size, height=size, background=@graphics.Color::transparent(), corner_radius=6.0, padding=0.0)
  .on_tap(message)
}

///|
/// Full application view; viewport-aware so the shell always fills the window.
pub fn view(model : Model, env : @moui.ViewEnvironment) -> @moui.View[Msg] {
  let viewport = env.viewport_size()
  let width = viewport.width
  let height = viewport.height
  let shell = if model.screen == Bots {
    bots_screen(model, width, height)
  } else {
    shell_view(model, width, height)
  }
  let root = if model.modal_open {
    @views.stack([shell, create_worktree_modal(model, width, height)])
  } else {
    shell
  }
  root.theme(orca_theme()).on_key(fn(event) {
    if event.pressed && event.key == "Escape" && model.modal_open {
      CloseModal
    } else {
      Noop
    }
  })
}

///|
/// Window chrome plus the sidebar/main split.
fn shell_view(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  let content_height = height - titlebar_height - 1.0
  @views.container(
    @views.column(
      [
        title_bar(width),
        @views.divider(color=white_a(0.07), thickness=1.0),
        @views.row(
          [
            sidebar(model, content_height),
            main_area(model, width - sidebar_width, content_height),
          ],
          spacing=0.0,
          align=Stretch,
        ).frame(width=width, height=content_height),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width=width,
    height=height,
    background=bg_main,
    padding=0.0,
  ).clip()
}

///|
/// macOS-style traffic lights, wordmark and panel toggle.
fn title_bar(width : Double) -> @moui.View[Msg] {
  let lights = @views.row(
    [
      traffic_light(traffic_red),
      traffic_light(traffic_yellow),
      traffic_light(traffic_green),
    ],
    spacing=8.0,
    align=Center,
  )
  let content = @views.row(
    [
      lights,
      txt("Orca", 12.0, 600, fg_primary),
      @views.lucide_icon("panel-left", size=15.0, color=fg_muted, stroke_width=1.7),
      @views.spacer(weight=1.0),
    ],
    spacing=20.0,
    align=Center,
  ).frame(width=width - 32.0)
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width=width,
    height=titlebar_height,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// One 12 px traffic light dot.
fn traffic_light(color : @graphics.Color) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width=12.0,
    height=12.0,
    background=color,
    corner_radius=6.0,
    padding=0.0,
  )
}

///|
/// Orca's left rail: nav, projects header, machines and worktrees.
fn sidebar(model : Model, height : Double) -> @moui.View[Msg] {
  let content = @views.column(
    [
      sidebar_nav(model),
      projects_header(),
      machines_column(model),
      @views.spacer(min_length=12.0, weight=0.0),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width=sidebar_width)
  @views.container(
    @views.scroll_view(content, width=sidebar_width, height=height),
    width=sidebar_width,
    height=height,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// Search / Tasks / Automations / Bots nav rows.
fn sidebar_nav(model : Model) -> @moui.View[Msg] {
  let rows = @views.column(
    [
      nav_row(Search, "Search", @views.lucide_icon("search", size=16.0, color=nav_icon_color(model, Search), stroke_width=1.8), model),
      nav_row(Tasks, "Tasks", @views.lucide_icon("list", size=16.0, color=nav_icon_color(model, Tasks), stroke_width=1.8), model),
      nav_row(Automations, "Automations", @views.lucide_icon("clock", size=16.0, color=nav_icon_color(model, Automations), stroke_width=1.8), model),
      bots_nav_row(model),
    ],
    spacing=2.0,
    align=Stretch,
  )
  @views.padding_edges(rows, top=6.0, left=8.0, right=8.0, bottom=2.0)
}

///|
fn nav_icon_color(model : Model, section : NavSection) -> @graphics.Color {
  if model.section == section {
    fg_primary
  } else {
    fg_muted
  }
}

///|
/// One 32 px sidebar nav row.
fn nav_row(
  section : NavSection,
  label : String,
  icon : @moui.View[Msg],
  model : Model,
) -> @moui.View[Msg] {
  let selected = model.section == section
  let color = if selected { fg_primary } else { fg_muted }
  let content = @views.row(
    [
      icon,
      txt(label, 14.0, 500, color),
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=sidebar_row_width - 16.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=sidebar_row_width,
    height=32.0,
    background=if selected { white_a(0.05) } else { @graphics.Color::transparent() },
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(SetSection(section))
}

///|
/// Bots nav row with its "1 needs you" badge.
fn bots_nav_row(model : Model) -> @moui.View[Msg] {
  let selected = model.section == Bots
  let color = if selected { fg_primary } else { fg_muted }
  let badge = @views.container(
    @views.padding_edges(
      txt("1 needs you", 9.0, 500, fg_muted),
      left=5.0,
      right=5.0,
      top=2.0,
      bottom=2.0,
    ),
    background=white_a(0.06),
    corner_radius=6.0,
    padding=0.0,
  )
  let content = @views.row(
    [
      @views.lucide_icon("users", size=16.0, color=color, stroke_width=1.8),
      txt("Bots", 14.0, 500, color),
      @views.spacer(weight=1.0),
      badge,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=sidebar_row_width - 16.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=sidebar_row_width,
    height=32.0,
    background=if selected { white_a(0.05) } else { @graphics.Color::transparent() },
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(SetSection(Bots))
}

///|
/// "Projects" section header with its three tiny icon buttons.
fn projects_header() -> @moui.View[Msg] {
  let actions = @views.row(
    [
      icon_button(sliders_icon(14.0, fg_muted), Noop, 20.0),
      icon_button(folder_plus_icon(14.0, fg_muted), OpenModal, 20.0),
      icon_button(
        @views.lucide_icon("plus", size=15.0, color=fg_muted, stroke_width=1.8),
        OpenModal,
        20.0,
      ),
    ],
    spacing=4.0,
    align=Center,
  )
  let content = @views.row(
    [
      txt("Projects", 13.0, 600, fg_secondary),
      @views.spacer(weight=1.0),
      actions,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=sidebar_row_width - 16.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=sidebar_row_width,
      height=32.0,
      background=@graphics.Color::transparent(),
      padding=0.0,
    ),
    left=8.0,
    right=8.0,
  )
}

///|
/// All machine cards stacked in the sidebar.
fn machines_column(model : Model) -> @moui.View[Msg] {
  let cards : Array[@moui.View[Msg]] = []
  for machine in model.machines {
    cards.push(machine_card(machine))
    for project in machine.projects {
      cards.push(project_block(model, project))
    }
  }
  @views.column(cards, spacing=2.0, align=Stretch)
}

///|
/// A 32 px machine card with host and count.
fn machine_card(machine : Machine) -> @moui.View[Msg] {
  let count = @views.container(
    @views.padding_edges(
      txt("\{machine_worktree_count(machine)}", 10.0, 500, fg_secondary),
      left=4.0,
      right=4.0,
      top=1.0,
      bottom=1.0,
    ),
    background=white_a(0.06),
    corner_radius=4.0,
    padding=0.0,
  )
  let row_items : Array[@moui.View[Msg]] = [
    @views.lucide_icon("server", size=14.0, color=fg_muted, stroke_width=1.7),
    txt(machine.name, 13.0, 600, fg_primary),
  ]
  if machine.host != "" {
    row_items.push(txt(machine.host, 11.0, 400, fg_dim))
  }
  row_items.push(@views.spacer(weight=1.0))
  row_items.push(count)
  let content = @views.row(row_items, spacing=6.0, align=Center)
  .frame(width=sidebar_row_width - 16.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=sidebar_row_width,
      height=32.0,
      background=bg_machine,
      corner_radius=8.0,
      border=Some(hairline()),
      padding=0.0,
    ),
    left=8.0,
    right=8.0,
    top=4.0,
  )
}

///|
/// Project header plus its worktree rows.
fn project_block(model : Model, project : Project) -> @moui.View[Msg] {
  let color = match project.kind {
    Globe => accent_globe
    Folder => accent_folder
  }
  let icon_name = match project.kind {
    Globe => "globe"
    Folder => "folder"
  }
  let header = @views.container(
    @views.padding_edges(
      @views.row(
        [
          @views.lucide_icon(icon_name, size=14.0, color=color, stroke_width=1.8),
          txt(project.name, 14.0, 600, fg_primary),
          @views.spacer(weight=1.0),
        ],
        spacing=6.0,
        align=Center,
      ).frame(width=sidebar_row_width - 16.0),
      left=8.0,
      right=8.0,
    ),
    width=sidebar_row_width,
    height=32.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
  let rows : Array[@moui.View[Msg]] = [
    @views.padding_edges(header, left=8.0, right=8.0, top=2.0),
  ]
  for worktree in project.worktrees {
    let selected = model.active == worktree.id
    rows.push(
      @views.padding_edges(
        worktree_row(worktree, selected),
        left=6.0,
        right=6.0,
        bottom=2.0,
      ),
    )
  }
  @views.column(rows, spacing=0.0, align=Stretch)
}

///|
/// Worktree status dot: green while running, amber while working, green when done.
fn worktree_status_indicator(worktree : Worktree) -> @moui.View[Msg] {
  let mut running = false
  let mut working = false
  for agent in worktree.agents {
    if agent.status == Running {
      running = true
    } else if agent.status == Working {
      working = true
    }
  }
  if running {
    status_dot(accent_green, 8.0)
  } else if working {
    spinner(9.0, accent_amber)
  } else {
    status_dot(accent_green, 8.0)
  }
}

///|
/// One worktree row with its agents.
fn worktree_row(worktree : Worktree, selected : Bool) -> @moui.View[Msg] {
  let header_items : Array[@moui.View[Msg]] = [
    worktree_status_indicator(worktree),
    txt(truncate_chars(worktree.name, 30), 14.0, 400, fg_primary),
  ]
  if worktree.primary {
    header_items.push(
      @views.container(
        @views.padding_edges(
          txt("primary", 10.0, 500, fg_secondary),
          left=4.0,
          right=4.0,
          top=1.0,
          bottom=1.0,
        ),
        background=white_a(0.06),
        corner_radius=4.0,
        padding=0.0,
      ),
    )
  }
  let header = @views.row(header_items, spacing=6.0, align=Center)
  .frame(width=worktree_row_width - 12.0)
  let branch = @views.padding_edges(
    @views.text(worktree.branch).font(mono(12.0, 400)).foreground(fg_muted),
    left=16.0,
  )
  let agents : Array[@moui.View[Msg]] = []
  for agent in worktree.agents {
    agents.push(agent_row(agent, worktree.id))
  }
  let content = @views.column(
    [header, branch, @views.column(agents, spacing=2.0, align=Stretch)],
    spacing=4.0,
    align=Start,
  ).frame(width=worktree_row_width - 12.0)
  @views.container(
    @views.padding_edges(content, top=5.0, bottom=6.0, left=6.0, right=6.0),
    width=worktree_row_width,
    background=if selected { bg_selected } else { @graphics.Color::transparent() },
    corner_radius=10.0,
    border=if selected {
      Some(selected_border())
    } else {
      None
    },
    padding=0.0,
  ).on_tap(SelectWorktree(worktree.id))
}

///|
/// One agent row inside a worktree.
fn agent_row(agent : Agent, worktree_id : String) -> @moui.View[Msg] {
  let row = @views.row(
    [
      status_indicator(agent.status),
      brand_icon(agent.kind, 12.0),
      txt(truncate_chars(agent.name, 17), 12.0, 400, fg_secondary),
      @views.spacer(weight=1.0),
      @views.text(agent.model).font(mono(12.0, 400)).foreground(fg_dim),
      txt(agent.time, 12.0, 400, fg_dim),
    ],
    spacing=5.0,
    align=Center,
  ).frame(width=worktree_row_width - 12.0)
  row.on_tap(SelectWorktree(worktree_id))
}

///|
/// Main pane: tab strip, transcript and composer.
fn main_area(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  let main_height = height
  @views.column(
    [
      tab_strip(model, width),
      @views.divider(color=white_a(0.07), thickness=1.0),
      chat_area(model, width, main_height - tabbar_height - 1.0 - composer_height),
      composer_area(model, width),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width=width, height=main_height)
}

///|
/// Tab strip with the worktree tabs and the plus button.
fn tab_strip(model : Model, width : Double) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = []
  for id in model.tabs {
    items.push(tab_view(model, id))
  }
  items.push(
    @views.container(
      @views.lucide_icon("plus", size=16.0, color=fg_muted, stroke_width=1.8),
      width=40.0,
      height=tabbar_height,
      background=@graphics.Color::transparent(),
      corner_radius=8.0,
      padding=0.0,
    ).on_tap(NewTab),
  )
  items.push(@views.spacer(weight=1.0))
  @views.container(
    @views.row(items, spacing=0.0, align=Stretch).frame(width=width),
    width=width,
    height=tabbar_height,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// One tab; the active tab takes the main background.
fn tab_view(model : Model, id : String) -> @moui.View[Msg] {
  let active = model.active == id
  let title = match find_worktree(model, id) {
    Some(worktree) => truncate_chars(worktree.tab_title, 34)
    None => id
  }
  let kind = match find_worktree(model, id) {
    Some(worktree) =>
      if worktree.agents.is_empty() {
        AgentKind::Claude
      } else {
        worktree.agents[0].kind
      }
    None => AgentKind::Claude
  }
  let color = if active { fg_primary } else { fg_muted }
  let close = @views.container(
    x_icon(14.0, fg_muted),
    width=20.0,
    height=20.0,
    background=@graphics.Color::transparent(),
    corner_radius=5.0,
    padding=0.0,
  ).on_tap(CloseTab(id))
  let content = @views.row(
    [
      done_badge(),
      brand_icon(kind, 14.0),
      @views.text(title, width=208.0, wrap=false, align=TextStart).font(sans(14.0, if active { 500 } else { 400 })).foreground(color),
      close,
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=300.0 - 20.0)
  @views.container(
    @views.padding_edges(content, left=12.0, right=8.0),
    width=300.0,
    height=tabbar_height,
    background=if active { bg_main } else { @graphics.Color::transparent() },
    corner_radius=0.0,
    border=None,
    padding=0.0,
  ).on_tap(SelectWorktree(id))
}

///|
/// Transcript region: scrollable chat, or a section/empty state.
fn chat_area(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  match model.section {
    Search =>
      if model.active == "" {
        empty_chat(width, height)
      } else {
        @views.scroll_view(
          @views.column(
            [transcript(model, width)],
            spacing=0.0,
            align=Center,
          ).frame(width=width),
          width=width,
          height=height,
        )
      }
    Tasks =>
      section_empty(
        width,
        height,
        "Tasks",
        "No tasks yet",
        "Workers you launch will show up here.",
      )
    Automations =>
      section_empty(
        width,
        height,
        "Automations",
        "No automations yet",
        "Scheduled agent runs will show up here.",
      )
    Bots =>
      section_empty(
        width,
        height,
        "Bots",
        "Bots are on standby",
        "1 needs you — open Bots to see the fleet.",
      )
  }
}

///|
/// A centered empty state for non-project sections.
fn section_empty(
  width : Double,
  height : Double,
  eyebrow : String,
  title : String,
  body : String,
) -> @moui.View[Msg] {
  @views.container(
    @views.column(
      [
        txt(eyebrow, 11.0, 600, fg_dim),
        txt(title, 22.0, 600, fg_primary),
        txt(body, 14.0, 400, fg_muted),
      ],
      spacing=8.0,
      align=Center,
    ),
    width=width,
    height=height,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
/// The no-open-tab state.
fn empty_chat(width : Double, height : Double) -> @moui.View[Msg] {
  @views.container(
    @views.column(
      [
        txt("Orca", 28.0, 600, fg_primary),
        txt("Open a worktree to start chatting", 15.0, 400, fg_body),
        @views.container(
          @views.padding_edges(
            txt("⌘K", 12.0, 500, fg_muted),
            left=8.0,
            right=8.0,
            top=3.0,
            bottom=3.0,
          ),
          background=white_a(0.06),
          corner_radius=6.0,
          padding=0.0,
        ),
      ],
      spacing=10.0,
      align=Center,
    ),
    width=width,
    height=height,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}
