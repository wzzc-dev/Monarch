///|
let titlebar_height : Double = 36.0

///|
let tabbar_height : Double = 36.0

///|
/// Sidebar rows inset by the surrounding 8 px gutters.
fn sidebar_row_w(model : Model) -> Double {
  model.sidebar_w - 24.0
}

///|
/// ⌘1–9 map to the first nine open worktree tabs.
fn tab_shortcut_index(key : String) -> Int32 {
  match key {
    "1" => 0
    "2" => 1
    "3" => 2
    "4" => 3
    "5" => 4
    "6" => 5
    "7" => 6
    "8" => 7
    "9" => 8
    _ => -1
  }
}

///|
fn panel_shortcut_index(key : String) -> Int32 {
  match key {
    "1" => 0
    "2" => 1
    "3" => 2
    "4" => 3
    _ => -1
  }
}

///|
fn nav_hover_id(section : NavSection) -> String {
  match section {
    Search => "nav-search"
    Tasks => "nav-tasks"
    Automations => "nav-automations"
    Bots => "nav-bots"
  }
}

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
  @views.text(value, wrap=false, align=TextStart)
  .font(sans(size, weight))
  .foreground(color)
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
  @views.text(value, width~, wrap=true, align=TextStart)
  .font(sans_lh(size, weight, line_height))
  .foreground(color)
}

///|
/// A clickable square icon button.
fn icon_button(
  icon : @moui.View[Msg],
  message : Msg,
  size : Double,
) -> @moui.View[Msg] {
  @views.container(
    icon,
    width=size,
    height=size,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(message)
}

///|
/// One 28 px item in a right-click context menu.
fn context_menu_row(
  icon_name : String,
  label : String,
  action : Int32,
) -> @moui.View[Msg] {
  context_menu_row_tinted(icon_name, label, action, fg_body, fg_muted)
}

///|
/// One tinted context-menu row, used for destructive actions.
fn context_menu_row_tinted(
  icon_name : String,
  label : String,
  action : Int32,
  color : @graphics.Color,
  icon_color : @graphics.Color,
) -> @moui.View[Msg] {
  let content = @views.row(
    [
      @views.lucide_icon(
        icon_name,
        size=13.0,
        color=icon_color,
        stroke_width=1.7,
      ),
      txt(label, 12.5, 400, color),
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=180.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=196.0,
    height=28.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(ContextAction(action))
}

///|
/// Right-click menu for the focused worktree or task row.
fn context_menu_card(model : Model) -> @moui.View[Msg] {
  let rows : Array[@moui.View[Msg]] = []
  if model.ctx_kind == 0 {
    rows.push(context_menu_row("arrow-right", "Open worktree", 0))
    rows.push(context_menu_row("file-text", "Show diff", 1))
    rows.push(context_menu_row("pencil", "Rename worktree", 2))
    rows.push(context_menu_row("x", "Close tab", 3))
    rows.push(
      context_menu_row_tinted(
        "trash-2", "Delete worktree", 4, fg_diff_del, fg_diff_del,
      ),
    )
  } else {
    let done = model.ctx_index >= 0 &&
      model.ctx_index < model.tasks.length() &&
      model.tasks[model.ctx_index].status == TaskDone
    rows.push(context_menu_row("arrow-right", "Open task", 0))
    rows.push(
      if done {
        context_menu_row("refresh-cw", "Reopen task", 1)
      } else {
        context_menu_row("check", "Mark done", 1)
      },
    )
  }
  @views.container(
    @views.column(rows, spacing=1.0, align=Stretch),
    width=204.0,
    height=if model.ctx_kind == 0 { 152.0 } else { 66.0 },
    background=bg_card,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=4.0,
  ).on_tap(Noop)
}

///|
/// Keeps a context menu fully inside the window, anchored at the click point.
fn context_menu_at(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let menu_w = 212.0
  let menu_h = if model.ctx_kind == 0 { 158.0 } else { 74.0 }
  let x = if model.ctx_anchor.x + menu_w > width {
    width - menu_w
  } else {
    model.ctx_anchor.x
  }
  let y = if model.ctx_anchor.y + menu_h > height {
    height - menu_h
  } else {
    model.ctx_anchor.y
  }
  let clamped_x = if x < 8.0 { 8.0 } else { x }
  let clamped_y = if y < 8.0 { 8.0 } else { y }
  context_menu_card(model).offset(dx=clamped_x, dy=clamped_y)
}

///|
/// Full-window click catcher that dismisses an open context menu.
fn context_menu_scrim(width : Double, height : Double) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseContextMenu)
}

///|
/// One 32 px page row in the wordmark menu.
fn app_menu_row(
  model : Model,
  label : String,
  icon_name : String,
  selected : Bool,
  message : Msg,
  hover_id : String,
) -> @moui.View[Msg] {
  let hovered = model.hover == hover_id
  let color = if selected { fg_primary } else { fg_body }
  let content = @views.row(
    [
      @views.lucide_icon(
        icon_name,
        size=14.0,
        color=if selected { fg_primary } else { fg_muted },
        stroke_width=1.7,
      ),
      txt(label, 12.5, 500, color),
      @views.spacer(weight=1.0),
    ],
    spacing=9.0,
    align=Center,
  ).frame(width=208.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=224.0,
    height=32.0,
    background=if selected {
      white_a(0.07)
    } else if hovered {
      white_a(0.05)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(hover_id, entered) })
}

///|
/// Page switcher anchored to the title bar wordmark.
fn app_menu_card(model : Model) -> @moui.View[Msg] {
  let rows = @views.column(
    [
      app_menu_row(
        model,
        "Projects",
        "folder",
        model.screen == Projects,
        ShowProjects,
        "app-menu-projects",
      ),
      app_menu_row(
        model,
        "Search",
        "search",
        model.screen == SearchScreen,
        SetSection(Search),
        "app-menu-search",
      ),
      app_menu_row(
        model,
        "Tasks",
        "list",
        model.screen == TasksScreen,
        SetSection(Tasks),
        "app-menu-tasks",
      ),
      app_menu_row(
        model,
        "Automations",
        "clock",
        model.screen == AutomationsScreen,
        SetSection(Automations),
        "app-menu-automations",
      ),
      app_menu_row(
        model,
        "Bots",
        "users",
        model.screen == Bots,
        SetSection(Bots),
        "app-menu-bots",
      ),
    ],
    spacing=1.0,
    align=Stretch,
  )
  @views.container(
    rows,
    width=232.0,
    height=172.0,
    background=bg_card,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=4.0,
  ).on_tap(Noop)
}

///|
fn app_menu_at(model : Model) -> @moui.View[Msg] {
  app_menu_card(model).offset(dx=16.0, dy=titlebar_height + 8.0)
}

///|
/// Full-window click catcher that dismisses the wordmark menu.
fn app_menu_scrim(width : Double, height : Double) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseAppMenu)
}

///|
/// Full application view; viewport-aware so the shell always fills the window.
pub fn view(model : Model, env : @moui.ViewEnvironment) -> @moui.View[Msg] {
  let viewport = env.viewport_size()
  let width = viewport.width
  let height = viewport.height
  let shell = match model.screen {
    Bots => bots_screen(model, width, height)
    DiffScreen => diff_screen(model, width, height)
    _ => shell_view(model, width, height)
  }
  let root = if model.modal_open {
    @views.stack([shell, create_worktree_modal(model, width, height)])
  } else if model.rename_open {
    @views.stack([shell, rename_worktree_modal(model, width, height)])
  } else if model.delete_open {
    @views.stack([shell, delete_worktree_modal(model, width, height)])
  } else if model.automation_editor_open {
    @views.stack([shell, automation_editor_modal(model, width, height)])
  } else if model.help_open {
    @views.stack([shell, help_modal(width, height)])
  } else {
    shell
  }
  let with_context = if model.ctx_open {
    @views.stack([
      root,
      context_menu_scrim(width, height),
      context_menu_at(model, width, height),
    ])
  } else {
    root
  }
  let framed = if model.app_menu_open {
    @views.stack([
      with_context,
      app_menu_scrim(width, height),
      app_menu_at(model),
    ])
  } else {
    with_context
  }
  framed
  .theme(orca_theme())
  .on_key(fn(event) {
    let command = event.modifiers.meta || event.modifiers.control
    let drawer_open = if model.screen == Bots {
      width < 760.0 && (model.sidebar_open || model.bots_item_open)
    } else {
      width < 720.0 && model.sidebar_open
    }
    let page_arrows = !page_arrow_blocked(model, drawer_open)
    if !event.pressed {
      Noop
    } else if event.key == "Escape" && model.ctx_open {
      CloseContextMenu
    } else if event.key == "Escape" && model.modal_open {
      CloseModal
    } else if event.key == "Escape" && model.rename_open {
      CancelRename
    } else if event.key == "Escape" && model.delete_open {
      CancelDeleteWorktree
    } else if event.key == "Escape" && model.automation_editor_open {
      CloseAutomationEditor
    } else if event.key == "Escape" && model.help_open {
      ToggleHelp
    } else if event.key == "Escape" && model.app_menu_open {
      CloseAppMenu
    } else if event.key == "Escape" && composer_menu_keys_active(model) {
      DismissComposerMenu
    } else if event.key == "Escape" && diff_composer_menu_keys_active(model) {
      DismissDiffComposerMenu
    } else if event.key == "Enter" && composer_menu_keys_active(model) {
      ComposerPick(composer_active_accept_index(model))
    } else if event.key == "Enter" && diff_composer_menu_keys_active(model) {
      DiffComposerPick(diff_composer_active_accept_index(model))
    } else if event.key == "Enter" && !command {
      enter_page_action(model, drawer_open)
    } else if event.key == "Escape" && model.task_detail_editing {
      CancelTaskDetail
    } else if event.key == "Escape" && model.task_link_menu_open {
      ToggleTaskWorktreeLink
    } else if event.key == "Escape" &&
      model.screen == TasksScreen &&
      model.task_composer_open &&
      !model.modal_open {
      ToggleTaskComposer
    } else if event.key == "Escape" &&
      model.screen == TasksScreen &&
      model.task_detail_open &&
      !model.modal_open {
      CloseTaskDetail
    } else if event.key == "Escape" &&
      model.screen == DiffScreen &&
      model.diff_file_menu_open {
      CloseDiffFileMenu
    } else if event.key == "Escape" &&
      model.screen == DiffScreen &&
      model.diff_note_open {
      ToggleDiffNote
    } else if event.key == "Escape" &&
      model.screen == DiffScreen &&
      model.diff_focus {
      ToggleDiffFocus
    } else if event.key == "Escape" &&
      model.screen == SearchScreen &&
      (model.search_query != "" || model.search_filter != 0) {
      ClearSearch
    } else if event.key == "Escape" && model.sidebar_options_open {
      ToggleSidebarOptions
    } else if event.key == "Escape" && model.bot_search_open {
      ToggleBotSearch
    } else if event.key == "Escape" && model.bots_options_open {
      ToggleBotOptions
    } else if event.key == "Escape" && model.bot_status_menu_open {
      ToggleBotStatusMenu
    } else if event.key == "Escape" && width < 760.0 && model.sidebar_open {
      ToggleSidebar
    } else if event.key == "Escape" &&
      width < 760.0 &&
      model.screen == Bots &&
      model.bots_item_open {
      ToggleBotItemPanel
    } else if event.key == "ArrowDown" && composer_menu_keys_active(model) {
      MoveComposerPick(1)
    } else if event.key == "ArrowUp" && composer_menu_keys_active(model) {
      MoveComposerPick(-1)
    } else if event.key == "ArrowDown" && diff_composer_menu_keys_active(model) {
      MoveDiffComposerPick(1)
    } else if event.key == "ArrowUp" && diff_composer_menu_keys_active(model) {
      MoveDiffComposerPick(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == SearchScreen &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveSearchSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == SearchScreen &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveSearchSelection(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == TasksScreen &&
      !model.task_composer_open &&
      !model.task_detail_editing &&
      !model.task_link_menu_open &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveTaskSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == TasksScreen &&
      !model.task_composer_open &&
      !model.task_detail_editing &&
      !model.task_link_menu_open &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveTaskSelection(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == AutomationsScreen &&
      !model.automation_editor_open &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveAutomationSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == AutomationsScreen &&
      !model.automation_editor_open &&
      !model.modal_open &&
      !model.app_menu_open {
      MoveAutomationSelection(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == Bots &&
      !model.bots_collapsed &&
      !model.bot_search_open &&
      !model.bots_options_open &&
      !model.modal_open &&
      !model.help_open {
      MoveBotSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == Bots &&
      !model.bots_collapsed &&
      !model.bot_search_open &&
      !model.bots_options_open &&
      !model.modal_open &&
      !model.help_open {
      MoveBotSelection(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == DiffScreen &&
      !model.diff_file_menu_open &&
      event.modifiers.shift {
      ExtendDiffSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == DiffScreen &&
      !model.diff_file_menu_open &&
      event.modifiers.shift {
      ExtendDiffSelection(-1)
    } else if page_arrows &&
      event.key == "ArrowDown" &&
      model.screen == DiffScreen &&
      !model.diff_file_menu_open {
      MoveDiffSelection(1)
    } else if page_arrows &&
      event.key == "ArrowUp" &&
      model.screen == DiffScreen &&
      !model.diff_file_menu_open {
      MoveDiffSelection(-1)
    } else if command && event.key == "k" {
      SetSection(Search)
    } else if command && event.key == "[" {
      GoBack
    } else if command && event.key == "]" {
      GoForward
    } else if command &&
      event.modifiers.alt &&
      model.screen == Bots &&
      panel_shortcut_index(event.key) >= 0 {
      OpenBotItemPanel(panel_shortcut_index(event.key))
    } else if command && tab_shortcut_index(event.key) >= 0 {
      SelectTabAt(tab_shortcut_index(event.key))
    } else if command && event.key == "b" {
      ToggleSidebar
    } else if command &&
      event.key == "w" &&
      model.screen == Projects &&
      model.active != "" {
      CloseTab(model.active)
    } else if command && event.key == "p" {
      ShowProjects
    } else if command && event.key == "Enter" && model.modal_open {
      CreateWorktree
    } else if command && event.key == "Enter" && model.rename_open {
      CommitRename
    } else if command && event.key == "Enter" && model.automation_editor_open {
      SaveAutomation
    } else if command &&
      event.key == "Enter" &&
      model.screen == TasksScreen &&
      model.task_detail_editing &&
      !model.modal_open {
      SaveTaskDetail
    } else {
      Noop
    }
  })
}

///|
/// Window chrome plus the sidebar/main split.
pub fn shell_compact(width : Double) -> Bool {
  width < 720.0
}

///|
/// Title-bar width in compact shells. The wordmark is dropped so the main tab
/// strip keeps usable room at phone widths.
pub fn shell_compact_chrome_width() -> Double {
  124.0
}

///|
/// Compact tab-strip priorities: the arrows and plus are shed before the
/// worktree tabs can push past the window edge.
pub fn shell_tab_back_visible(width : Double) -> Bool {
  width >= 140.0
}

///|
pub fn shell_tab_forward_visible(width : Double) -> Bool {
  width >= 300.0
}

///|
/// History arrows only take strip space when there is somewhere to go, so an
/// empty history leaves the tab title flush against the sidebar vrule.
pub fn tab_back_shown(model : Model, width : Double) -> Bool {
  shell_tab_back_visible(width) && !model.nav_back.is_empty()
}

///|
pub fn tab_forward_shown(model : Model, width : Double) -> Bool {
  shell_tab_forward_visible(width) && !model.nav_forward.is_empty()
}

///|
pub fn shell_tab_plus_visible(width : Double) -> Bool {
  width >= 140.0
}

///|
/// Shared tab width: fills the strip up to the 300 px design width and never
/// drops below a 48 px tap target.
pub fn shell_tab_strip_width(
  width : Double,
  tab_count : Int32,
  show_back : Bool,
  show_forward : Bool,
) -> Double {
  if tab_count <= 0 {
    return 0.0
  }
  let mut reserved = 0.0
  if show_back {
    reserved = reserved + 30.0
  }
  if show_forward {
    reserved = reserved + 30.0
  }
  if shell_tab_plus_visible(width) {
    reserved = reserved + 40.0
  }
  let per_tab = (width - reserved) / tab_count.to_double()
  if per_tab < 48.0 {
    48.0
  } else if per_tab < tab_strip_max_width(tab_count) {
    per_tab
  } else {
    tab_strip_max_width(tab_count)
  }
}

///|
/// A lone tab gets the wider reference measure so its title and close action
/// keep breathing room; multi-tab strips stay at the denser 300 px cap.
pub fn tab_strip_max_width(tab_count : Int32) -> Double {
  if tab_count == 1 {
    375.0
  } else {
    300.0
  }
}

///|
/// The completion badge only appears once a tab has enough room for the badge,
/// label and close control to remain legible.
pub fn tabs_show_status_badge(width : Double, worktree : Worktree) -> Bool {
  width >= 90.0 && worktree_has_completion(worktree)
}

///|
fn shell_view(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let compact = shell_compact(width)
  let inline_sidebar = model.sidebar_open && !compact
  let sidebar_w = if compact {
    let available = if width < 48.0 { 0.0 } else { width - 48.0 }
    if available < model.sidebar_w {
      available
    } else {
      model.sidebar_w
    }
  } else {
    model.sidebar_w
  }
  let view_model = { ..model, sidebar_w, }
  let content_height = height - titlebar_height - 1.0
  let chrome_w = if inline_sidebar {
    sidebar_w
  } else if compact {
    shell_compact_chrome_width()
  } else {
    208.0
  }
  let main_w = width - chrome_w - 5.0
  let top = @views.row(
    [
      title_bar(view_model, chrome_w, compact),
      if inline_sidebar {
        resize_handle(titlebar_height, model.hover == "resize-projects")
      } else {
        vrule(titlebar_height)
      },
      tab_strip(model, main_w),
    ],
    spacing=0.0,
    align=Stretch,
  ).frame(width~, height=titlebar_height)
  let children : Array[@moui.View[Msg]] = []
  if inline_sidebar {
    children.push(
      sidebar(view_model, content_height, sidebar_nav_visible(model, compact)),
    )
    children.push(
      resize_handle(content_height, model.hover == "resize-projects"),
    )
  }
  let body_w = if inline_sidebar { width - sidebar_w - 5.0 } else { width }
  children.push(main_area(model, body_w, content_height))
  let root = @views.container(
    @views.column(
      [
        top,
        @views.divider(color=white_a(0.07), thickness=1.0),
        @views.row(children, spacing=0.0, align=Stretch).frame(
          width~,
          height=content_height,
        ),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  ).clip()
  if compact && model.sidebar_open {
    let scrim = @views.container(
        @views.empty(),
        width~,
        height=content_height,
        background=black_a(0.45),
        padding=0.0,
      )
      .on_tap(ToggleSidebar)
      .offset(dx=0.0, dy=titlebar_height + 1.0)
    let overlay = sidebar(view_model, content_height, true).offset(
      dx=0.0,
      dy=titlebar_height + 1.0,
    )
    @views.stack([root, scrim, overlay])
  } else {
    root
  }
}

///|
/// macOS-style traffic lights, wordmark and panel toggle.
fn title_bar(model : Model, width : Double, compact : Bool) -> @moui.View[Msg] {
  let toggle_hovered = model.hover == "panel-toggle"
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
  let wordmark = @views.container(
      @views.padding_edges(
        @views.row(
          [
            txt("Orca", 12.0, 600, fg_primary),
            @views.lucide_icon(
              "chevron-down",
              size=10.0,
              color=fg_muted,
              stroke_width=1.6,
            ),
          ],
          spacing=4.0,
          align=Center,
        ),
        left=6.0,
        right=6.0,
      ),
      height=24.0,
      background=if model.app_menu_open || model.hover == "app-menu" {
        white_a(0.06)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=6.0,
      padding=0.0,
    )
    .on_tap(ToggleAppMenu)
    .on_hover(fn(entered) { Hover("app-menu", entered) })
  let content = if compact {
    @views.row(
      [lights, @views.spacer(weight=1.0), toggle],
      spacing=0.0,
      align=Center,
    ).frame(width=width - 32.0)
  } else {
    @views.row(
      [lights, wordmark, toggle, @views.spacer(weight=1.0)],
      spacing=20.0,
      align=Center,
    ).frame(width=width - 32.0)
  }
  @views.container(
    @views.padding_edges(content, left=16.0, right=16.0),
    width~,
    height=titlebar_height,
    background=bg_sidebar,
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
fn sidebar(model : Model, height : Double, show_nav : Bool) -> @moui.View[Msg] {
  let children : Array[@moui.View[Msg]] = []
  if show_nav {
    children.push(sidebar_nav(model))
    children.push(projects_header(model))
  } else {
    children.push(@views.padding_edges(projects_header(model), top=19.0))
  }
  if model.sidebar_options_open {
    children.push(projects_options(model))
  }
  if show_nav {
    children.push(machines_column(model))
  } else {
    children.push(@views.padding_edges(machines_column(model), top=5.0))
  }
  children.push(@views.spacer(min_length=12.0, weight=0.0))
  let content = @views.column(children, spacing=0.0, align=Stretch).frame(
    width=model.sidebar_w,
  )
  @views.container(
    @views.scroll_view(content, width=model.sidebar_w, height~),
    width=model.sidebar_w,
    height~,
    background=bg_sidebar,
    padding=0.0,
  )
}

///|
/// The reference Projects rail starts with its header, while the other pages
/// keep the shared page nav. Compact Projects keeps the nav inside its drawer.
pub fn sidebar_nav_visible(model : Model, compact : Bool) -> Bool {
  compact || model.screen != Projects
}

///|
/// A 1 px rule with a wider invisible grip; dragging it resizes the sidebar.
fn resize_handle(height : Double, hovered : Bool) -> @moui.View[Msg] {
  let line = @views.container(
    @views.empty(),
    width=1.0,
    height~,
    background=white_a(0.07),
    padding=0.0,
  )
  let grip = @views.container(
    @views.empty(),
    width=4.0,
    height~,
    background=if hovered {
      white_a(0.12)
    } else {
      @graphics.Color::transparent()
    },
    padding=0.0,
  )
  @views.row([line, grip], spacing=0.0, align=Stretch)
  .on_drag(fn(event) { ResizeSidebar(event.position.x) })
  .on_hover(fn(entered) { Hover("resize-projects", entered) })
  .cursor(@views.CursorStyle::Icon(@views.CursorIcon::CursorColResize))
}

///|
/// Search / Tasks / Automations / Bots nav rows.
fn sidebar_nav(model : Model) -> @moui.View[Msg] {
  let rows = @views.column(
    [
      nav_row(
        Search,
        "Search",
        @views.lucide_icon(
          "search",
          size=16.0,
          color=nav_icon_color(model, Search),
          stroke_width=1.8,
        ),
        model,
      ),
      nav_row(
        Tasks,
        "Tasks",
        @views.lucide_icon(
          "list",
          size=16.0,
          color=nav_icon_color(model, Tasks),
          stroke_width=1.8,
        ),
        model,
      ),
      nav_row(
        Automations,
        "Automations",
        @views.lucide_icon(
          "clock",
          size=16.0,
          color=nav_icon_color(model, Automations),
          stroke_width=1.8,
        ),
        model,
      ),
      bots_nav_row(model),
    ],
    spacing=2.0,
    align=Stretch,
  )
  @views.padding_edges(rows, top=6.0, left=12.0, right=12.0, bottom=2.0)
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
  let hovered = model.hover == nav_hover_id(section)
  let color = if selected { fg_primary } else { fg_muted }
  let content = @views.row(
    [icon, txt(label, 13.0, 500, color), @views.spacer(weight=1.0)],
    spacing=8.0,
    align=Center,
  ).frame(width=sidebar_row_w(model) - 16.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=sidebar_row_w(model),
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
  .on_tap(SetSection(section))
  .on_hover(fn(entered) { Hover(nav_hover_id(section), entered) })
}

///|
/// Bots nav row with a live needs-you badge.
fn bots_nav_row(model : Model) -> @moui.View[Msg] {
  let selected = model.section == Bots
  let hovered = model.hover == "nav-bots"
  let color = if selected { fg_primary } else { fg_muted }
  let label = bots_needs_label(bots_needing_you(model))
  let badge = if label == "" {
    @views.empty()
  } else {
    @views.container(
      @views.padding_edges(
        txt(label, 9.0, 500, fg_muted),
        left=5.0,
        right=5.0,
        top=2.0,
        bottom=2.0,
      ),
      background=white_a(0.06),
      corner_radius=6.0,
      padding=0.0,
    )
  }
  let content = @views.row(
    [
      @views.lucide_icon("users", size=16.0, color~, stroke_width=1.8),
      txt("Bots", 13.0, 500, color),
      @views.spacer(weight=1.0),
      badge,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=sidebar_row_w(model) - 16.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=sidebar_row_w(model),
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
  .on_tap(SetSection(Bots))
  .on_hover(fn(entered) { Hover("nav-bots", entered) })
}

///|
/// "Projects" section header with its three tiny icon buttons.
fn projects_header(model : Model) -> @moui.View[Msg] {
  let options_open = model.sidebar_options_open
  let sliders = @views.container(
    sliders_icon(14.0, if options_open { fg_primary } else { fg_muted }),
    width=20.0,
    height=20.0,
    background=if options_open {
      white_a(0.10)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(ToggleSidebarOptions)
  let actions = @views.row(
    [
      sliders,
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
  ).frame(width=sidebar_row_w(model) - 16.0)
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=sidebar_row_w(model),
      height=32.0,
      background=@graphics.Color::transparent(),
      padding=0.0,
    ),
    left=16.0,
    right=16.0,
  )
}

///|
/// Inline display options revealed by the sliders button in the Projects header.
fn projects_options(model : Model) -> @moui.View[Msg] {
  let rows = @views.column(
    [
      option_row(
        "sidebar-collapse-all",
        @views.lucide_icon(
          "chevron-down",
          size=14.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        "Collapse all",
        CollapseAllWorktrees,
        model,
      ),
      option_row(
        "sidebar-expand-all",
        @views.lucide_icon(
          "chevron-up",
          size=14.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        "Expand all",
        ExpandAllWorktrees,
        model,
      ),
    ],
    spacing=0.0,
    align=Stretch,
  )
  @views.padding_edges(
    @views.container(
      @views.padding_edges(rows, left=2.0, right=2.0, top=2.0, bottom=2.0),
      width=model.sidebar_w - 24.0,
      background=white_a(0.04),
      corner_radius=8.0,
      border=Some(border_of(white_a(0.08), 1.0)),
      padding=0.0,
    ),
    left=12.0,
    right=12.0,
    top=2.0,
    bottom=6.0,
  )
}

///|
fn option_row(
  id : String,
  icon : @moui.View[Msg],
  label : String,
  message : Msg,
  model : Model,
) -> @moui.View[Msg] {
  let hovered = model.hover == id
  let content = @views.row(
    [icon, txt(label, 12.0, 500, fg_body), @views.spacer(weight=1.0)],
    spacing=8.0,
    align=Center,
  ).frame(width=model.sidebar_w - 56.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width=model.sidebar_w - 40.0,
    height=26.0,
    background=if hovered {
      white_a(0.06)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(id, entered) })
}

///|
/// All machine cards stacked in the sidebar.
fn machines_column(model : Model) -> @moui.View[Msg] {
  let cards : Array[@moui.View[Msg]] = []
  for machine in model.machines {
    cards.push(machine_card(machine, model))
    if !list_contains(model.collapsed_machines, machine.name) {
      for project in machine.projects {
        cards.push(project_block(model, project))
      }
    }
  }
  @views.column(cards, spacing=2.0, align=Stretch)
}

///|
fn list_contains(items : Array[String], needle : String) -> Bool {
  let mut found = false
  for item in items {
    if item == needle {
      found = true
    }
  }
  found
}

///|
/// A 32 px machine card with host and count.
fn machine_card(machine : Machine, model : Model) -> @moui.View[Msg] {
  let collapsed = list_contains(model.collapsed_machines, machine.name)
  let count = @views.container(
    @views.padding_edges(
      txt("\{machine_worktree_count(machine)}", 9.0, 500, fg_secondary),
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
    @views.lucide_icon(
      if collapsed {
        "chevron-right"
      } else {
        "chevron-down"
      },
      size=12.0,
      color=fg_dim,
      stroke_width=1.8,
    ),
    @views.lucide_icon("server", size=14.0, color=fg_muted, stroke_width=1.7),
    txt(machine.name, 12.0, 600, fg_primary),
  ]
  if machine.host != "" {
    row_items.push(txt(machine.host, 11.0, 400, fg_dim))
  }
  row_items.push(@views.spacer(weight=1.0))
  row_items.push(count)
  let content = @views.row(row_items, spacing=6.0, align=Center).frame(
    width=sidebar_row_w(model) - 16.0,
  )
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=8.0, right=8.0),
      width=sidebar_row_w(model),
      height=32.0,
      background=bg_machine,
      corner_radius=8.0,
      border=Some(hairline()),
      padding=0.0,
    ).on_tap(ToggleMachine(machine.name)),
    left=12.0,
    right=12.0,
    top=4.0,
  )
}

///|
/// Project header plus its worktree rows.
fn project_block(model : Model, project : Project) -> @moui.View[Msg] {
  let collapsed = list_contains(model.collapsed_projects, project.id)
  let hovered = model.hover == "project-\{project.id}"
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
            @views.lucide_icon(
              if collapsed {
                "chevron-right"
              } else {
                "chevron-down"
              },
              size=12.0,
              color=fg_dim,
              stroke_width=1.8,
            ),
            @views.lucide_icon(icon_name, size=14.0, color~, stroke_width=1.8),
            txt(project.name, 13.0, 600, fg_primary),
            @views.spacer(weight=1.0),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=sidebar_row_w(model) - 16.0),
        left=8.0,
        right=8.0,
      ),
      width=sidebar_row_w(model),
      height=32.0,
      background=if hovered {
        white_a(0.03)
      } else {
        @graphics.Color::transparent()
      },
      padding=0.0,
    )
    .on_tap(ToggleProject(project.id))
    .on_hover(fn(entered) { Hover("project-\{project.id}", entered) })
  let rows : Array[@moui.View[Msg]] = [
    @views.padding_edges(header, left=12.0, right=12.0, top=2.0),
  ]
  if !collapsed {
    for worktree in project.worktrees {
      let selected = model.active == worktree.id
      rows.push(
        @views.padding_edges(
          worktree_row(
            worktree,
            selected,
            sidebar_row_w(model),
            model.hover == "worktree-\{worktree.id}",
          ),
          left=12.0,
          right=12.0,
          bottom=2.0,
        ),
      )
    }
  }
  @views.column(rows, spacing=0.0, align=Stretch)
}

///|
/// Worktree status dot: green while running, amber while working, green when done.
fn worktree_status_indicator(worktree : Worktree) -> @moui.View[Msg] {
  let mut running = false
  let mut working = false
  let mut done = false
  for agent in worktree.agents {
    if agent.status == Running {
      running = true
    } else if agent.status == Working {
      working = true
    } else if agent.status == Done {
      done = true
    }
  }
  if running {
    spinner(8.0, accent_amber)
  } else if working {
    spinner(9.0, accent_amber)
  } else if done {
    status_dot(accent_green, 6.0)
  } else {
    status_dot(fg_dim, 6.0)
  }
}

///|
/// Vertical inset of a worktree card. The reference selected card runs
/// y=277–440 at 1×, with its header 10 px below the top edge and its last
/// agent 12 px above the bottom edge.
pub fn worktree_card_padding() -> (Double, Double) {
  (10.0, 12.0)
}

///|
/// One worktree row with its agents.
fn worktree_row(
  worktree : Worktree,
  selected : Bool,
  width : Double,
  hovered : Bool,
) -> @moui.View[Msg] {
  let content_w = width - 40.0
  let (pad_top, pad_bottom) = worktree_card_padding()
  let header_items : Array[@moui.View[Msg]] = [
    worktree_status_indicator(worktree),
    txt(truncate_chars(worktree.name, 30), 13.0, 400, fg_primary),
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
  let header = @views.row(header_items, spacing=6.0, align=Center).frame(
    width=content_w,
  )
  let branch = @views.padding_edges(
    @views.text(worktree.branch).font(mono(11.0, 400)).foreground(fg_muted),
    left=16.0,
  )
  let agents : Array[@moui.View[Msg]] = []
  for agent in worktree.agents {
    agents.push(agent_row(agent, worktree.id, content_w))
  }
  let content = @views.column(
    [header, branch, @views.column(agents, spacing=5.0, align=Stretch)],
    spacing=10.0,
    align=Start,
  ).frame(width=content_w)
  @views.container(
    @views.padding_edges(
      content,
      top=pad_top,
      bottom=pad_bottom,
      left=28.0,
      right=12.0,
    ),
    width~,
    background=if selected {
      bg_selected
    } else if hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=10.0,
    border=if selected { Some(selected_border()) } else { None },
    padding=0.0,
  )
  .on_tap(SelectWorktree(worktree.id))
  .on_hover(fn(entered) { Hover("worktree-\{worktree.id}", entered) })
  .on_secondary_tap_with_frame(fn(point, _frame) {
    OpenContextMenu(0, worktree.id, -1, point)
  })
}

///|
/// Agent names clip harder as the sidebar approaches its 220 px minimum.
pub fn agent_row_name_limit(content_w : Double) -> Int32 {
  if content_w < 200.0 {
    10
  } else if content_w < 240.0 {
    12
  } else {
    17
  }
}

///|
/// The model token is dropped before the time so narrow rows stay inside the card.
pub fn agent_row_shows_model(content_w : Double) -> Bool {
  content_w >= 240.0
}

///|
/// One agent row inside a worktree.
fn agent_row(
  agent : Agent,
  worktree_id : String,
  content_w : Double,
) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = [
    status_indicator(agent.status),
    brand_icon(agent.kind, 12.0),
    txt(
      truncate_chars(agent.name, agent_row_name_limit(content_w)),
      12.0,
      400,
      fg_secondary,
    ),
    @views.spacer(weight=1.0),
  ]
  if agent_row_shows_model(content_w) {
    items.push(
      @views.text(agent.model).font(mono(11.0, 400)).foreground(fg_dim),
    )
  }
  items.push(txt(agent.time, 11.0, 400, fg_dim))
  let row = @views.row(items, spacing=5.0, align=Center).frame(
    width=content_w,
    height=28.0,
  )
  row.on_tap(SelectWorktree(worktree_id))
}

///|
/// Main pane: tab strip, transcript and composer.
fn main_area(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  let main_height = height
  if model.screen == Projects {
    let composer_height = composer_area_height(model)
    @views.column(
      [
        chat_area(model, width, main_height - composer_height),
        composer_area(model, width),
      ],
      spacing=0.0,
      align=Stretch,
    ).frame(width~, height=main_height)
  } else {
    page_screen(model, width, main_height).frame(width~, height=main_height)
  }
}

///|
/// Back/forward arrow at the far left of a tab strip.
fn history_button(model : Model, back : Bool) -> @moui.View[Msg] {
  let icon = if back { "arrow-left" } else { "arrow-right" }
  let id = if back { "nav-back" } else { "nav-forward" }
  let enabled = if back {
    !model.nav_back.is_empty()
  } else {
    !model.nav_forward.is_empty()
  }
  let message = if back { GoBack } else { GoForward }
  let hovered = model.hover == id
  @views.container(
    @views.lucide_icon(
      icon,
      size=15.0,
      color=if enabled {
        if hovered {
          fg_primary
        } else {
          fg_muted
        }
      } else {
        fg_dim
      },
      stroke_width=1.8,
    ),
    width=30.0,
    height=tabbar_height,
    background=if hovered && enabled {
      white_a(0.05)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=7.0,
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(id, entered) })
}

///|
/// Tab strip with the worktree tabs and the plus button.
fn tab_strip(model : Model, width : Double) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = []
  let show_back = tab_back_shown(model, width)
  let show_forward = tab_forward_shown(model, width)
  let show_plus = shell_tab_plus_visible(width)
  if show_back {
    items.push(history_button(model, true))
  }
  if show_forward {
    items.push(history_button(model, false))
  }
  let tab_count = model.tabs.length()
  let tab_width = shell_tab_strip_width(
    width, tab_count, show_back, show_forward,
  )
  for id in model.tabs {
    items.push(tab_view(model, id, tab_width))
  }
  if show_plus {
    items.push(
      @views.container(
        @views.lucide_icon("plus", size=16.0, color=fg_muted, stroke_width=1.8).offset(
          dx=0.0,
          dy=5.0,
        ),
        width=40.0,
        height=tabbar_height,
        background=if model.hover == "tab-plus" {
          white_a(0.05)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=8.0,
        padding=0.0,
      )
      .on_tap(NewTab)
      .on_hover(fn(entered) { Hover("tab-plus", entered) }),
    )
  }
  items.push(@views.spacer(weight=1.0))
  @views.container(
    @views.row(items, spacing=0.0, align=Stretch).frame(width~),
    width~,
    height=tabbar_height,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// Very narrow tabs drop the badge and agent glyph so the label and close X
/// still fit side by side.
pub fn shell_tab_icons_visible(width : Double) -> Bool {
  width >= 90.0
}

///|
/// One tab; the active tab takes the main background.
fn tab_view(model : Model, id : String, width : Double) -> @moui.View[Msg] {
  let active = model.active == id
  let hovered = model.hover == "tab-\{id}"
  let close_hovered = model.hover == "tab-close-\{id}"
  let worktree = find_worktree(model, id)
  let title = match worktree {
    Some(value) => truncate_chars(value.tab_title, 48)
    None => id
  }
  let color = if active { fg_primary } else { fg_muted }
  let show_badge = match worktree {
    Some(value) => tabs_show_status_badge(width, value)
    None => false
  }
  let show_close = hovered || close_hovered
  let close = @views.container(
      x_icon(14.0, fg_muted),
      width=20.0,
      height=20.0,
      background=if close_hovered {
        white_a(0.10)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=5.0,
      padding=0.0,
    )
    .on_tap(CloseTab(id))
    .on_hover(fn(entered) { Hover("tab-close-\{id}", entered) })
  let label_width = if show_close {
    width - (if show_badge { 68.0 } else { 52.0 })
  } else {
    width - (if show_badge { 48.0 } else { 22.0 })
  }
  let label = @views.row(
      [
        @views.text(title, wrap=false, align=TextStart)
        .font(sans(14.0, if active { 500 } else { 400 }))
        .foreground(color),
        @views.spacer(weight=1.0),
      ],
      spacing=0.0,
      align=Center,
    )
    .frame(
      width=if label_width < 1.0 { 1.0 } else { label_width },
      height=tabbar_height - 10.0,
    )
    .clip()
  let label_items : Array[@moui.View[Msg]] = []
  if show_badge {
    label_items.push(done_badge())
  }
  label_items.push(label)
  let content = @views.padding_edges(
    @views.row(
      label_items,
      spacing=if show_badge { 10.0 } else { 0.0 },
      align=Center,
    ).frame(width=width - 16.0, height=tabbar_height - 10.0),
    left=8.0,
    right=8.0,
    top=10.0,
  )
  let body = if show_close {
    @views.stack([
      content,
      close.offset(dx=width - 28.0, dy=(tabbar_height - 10.0) / 2.0 + 10.0),
    ])
  } else {
    content
  }
  @views.container(
    body,
    width~,
    height=tabbar_height,
    background=if active {
      bg_main
    } else if hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=0.0,
    border=None,
    padding=0.0,
  )
  .on_tap(SelectWorktree(id))
  .on_hover(fn(entered) { Hover("tab-\{id}", entered) })
}

///|
/// Transcript region: scrollable chat, or a section/empty state.
fn chat_area(model : Model, width : Double, height : Double) -> @moui.View[Msg] {
  match model.section {
    Search =>
      if model.active == "" {
        empty_chat(model, width, height)
      } else {
        @views.scroll_view(
          @views.column([transcript(model, width)], spacing=0.0, align=Center).frame(
            width~,
          ),
          offset=@geometry.Point::new(x=0.0, y=model.chat_scroll_y),
          width~,
          height~,
          on_scroll=Some(fn(point) { ScrollChat(point.y) }),
        )
      }
    Tasks =>
      section_empty(
        width, height, "Tasks", "No tasks yet", "Workers you launch will show up here.",
      )
    Automations =>
      section_empty(
        width, height, "Automations", "No automations yet", "Scheduled agent runs will show up here.",
      )
    Bots => {
      let needs = bots_needing_you(model)
      let body = if needs == 0 {
        "Bots are on standby — open Bots to see the fleet."
      } else if needs == 1 {
        "1 needs you — open Bots to see the fleet."
      } else {
        "\{needs} need you — open Bots to see the fleet."
      }
      section_empty(width, height, "Bots", "Bots are on standby", body)
    }
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
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
/// The no-open-tab state.
fn empty_chat(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
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
        @views.padding_edges(
          @views.row(
            [
              page_button_hover(
                model,
                "empty-new-worktree",
                "New worktree",
                @views.lucide_icon(
                  "plus",
                  size=14.0,
                  color=bg_card,
                  stroke_width=1.8,
                ),
                OpenModal,
                true,
              ),
              page_button_hover(
                model,
                "empty-search",
                "Search",
                @views.lucide_icon(
                  "search",
                  size=14.0,
                  color=fg_body,
                  stroke_width=1.8,
                ),
                SetSection(Search),
                false,
              ),
            ],
            spacing=8.0,
            align=Center,
          ),
          top=6.0,
        ),
      ],
      spacing=10.0,
      align=Center,
    ),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}
