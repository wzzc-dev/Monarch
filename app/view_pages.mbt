///|
/// Shared transparent text-field style for full-page search and filter inputs.
fn page_field_style(
  size : Double,
  placeholder : @graphics.Color,
) -> @style.TextFieldStyle {
  let transparent = @graphics.Brush::Solid(@graphics.Color::transparent())
  let normal = @views.new_control_state_style(
    foreground=fg_primary,
    background=transparent,
  )
  let focused = @views.new_control_state_style(
    foreground=fg_primary,
    background=transparent,
  )
  @style.TextFieldStyle::new(
    normal~,
    focused~,
    disabled=normal,
    placeholder_color=placeholder,
    cursor_color=fg_primary,
    font=sans(size, 400),
  )
}

///|
/// Case-insensitive substring search used by the Search page.
fn contains_text(haystack : String, needle : String) -> Bool {
  let folded = haystack.to_lower()
  let target = needle.to_lower()
  if target.length() == 0 {
    return true
  }
  let h = folded.to_array()
  let n = target.to_array()
  if n.length() > h.length() {
    return false
  }
  let mut i = 0
  while i + n.length() <= h.length() {
    let mut j = 0
    while j < n.length() && h[i + j] == n[j] {
      j = j + 1
    }
    if j == n.length() {
      return true
    }
    i = i + 1
  }
  false
}

///|
/// Small uppercase section label used across the new pages.
fn section_label(text : String, size : Double) -> @moui.View[Msg] {
  @views.padding_edges(txt(text, size, 600, fg_muted), top=2.0, bottom=2.0)
}

///|
/// Fixed-width clipped text column. A plain container centres its child when
/// the text is narrower than the column, which reads as misaligned in tables
/// and list rows; this helper pins the child to the leading edge instead.
fn clip_left(
  child : @moui.View[Msg],
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  @views.column([child], spacing=0.0, justify=Center, align=Start)
  .frame(width~, height~)
  .clip()
}

///|
fn align_right(child : @moui.View[Msg], width : Double) -> @moui.View[Msg] {
  @views.column([child], spacing=0.0, justify=Center, align=End).frame(width~)
}

///|
/// Below this width the page header drops its supporting line so the title and
/// actions keep their space.
pub fn page_header_compact(width : Double) -> Bool {
  width < 520.0
}

///|
/// Below this width pill labels use their short forms.
pub fn page_compact_pills(width : Double) -> Bool {
  width < 420.0
}

///|
/// Below 480 px Search's full category labels plus their counts no longer
/// leave room for the result total, so labels shorten and pill padding drops.
pub fn search_filters_compact(width : Double) -> Bool {
  width < 480.0
}

///|
/// Below 360 px the four Tasks status pills, their counts and the trailing
/// total cannot share one row at the normal padding.
pub fn task_filter_pills_dense(width : Double) -> Bool {
  width < 360.0
}

///|
/// Page header with a title, supporting line and optional trailing controls.
fn page_header(
  title : String,
  subtitle : String,
  width : Double,
  actions : Array[@moui.View[Msg]],
  actions_width~ : Double = 0.0,
) -> @moui.View[Msg] {
  let left_column = if page_header_compact(width) {
    @views.column([txt(title, 20.0, 600, fg_primary)], spacing=4.0, align=Start)
  } else {
    @views.column(
      [txt(title, 20.0, 600, fg_primary), txt(subtitle, 12.0, 400, fg_muted)],
      spacing=4.0,
      align=Start,
    )
  }
  let content_w = if width - 64.0 < 0.0 { 0.0 } else { width - 64.0 }
  let left_w = if actions_width > 0.0 {
    let available = content_w - actions_width - 10.0
    if available < 120.0 {
      120.0
    } else {
      available
    }
  } else {
    content_w
  }
  let left = clip_left(left_column, left_w, 44.0)
  let items : Array[@moui.View[Msg]] = [left]
  for action in actions {
    items.push(action)
  }
  let content = @views.row(items, spacing=10.0, align=Center)
  @views.container(
    @views.padding_edges(content, left=32.0, right=32.0, top=18.0, bottom=16.0).frame(
      width~,
    ),
    width~,
    height=76.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
/// Page action with a pointer-hover background, used where a button sits inside
/// a card or toolbar that otherwise reads as static.
fn page_button_hover(
  model : Model,
  id : String,
  label : String,
  icon : @moui.View[Msg],
  message : Msg,
  primary : Bool,
) -> @moui.View[Msg] {
  let hovered = model.hover == id
  let fg = if primary { bg_card } else { fg_body }
  let content = @views.row(
    [icon, txt(label, 13.0, 500, fg)],
    spacing=6.0,
    align=Center,
  )
  @views.container(
    @views.padding_edges(content, left=12.0, right=12.0),
    height=32.0,
    background=if primary {
      if hovered {
        @graphics.Color::from_argb(0xFFD8D8D8)
      } else {
        fg_primary
      }
    } else if hovered {
      white_a(0.10)
    } else {
      white_a(0.05)
    },
    corner_radius=8.0,
    border=if primary {
      None
    } else {
      Some(border_of(white_a(if hovered { 0.14 } else { 0.09 }), 1.0))
    },
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(id, entered) })
}

///|
/// Compact text-only action used where three icon+label buttons would crowd a
/// phone-width card.
fn page_text_button(
  model : Model,
  id : String,
  label : String,
  message : Msg,
  primary : Bool,
) -> @moui.View[Msg] {
  let hovered = model.hover == id
  @views.container(
    @views.padding_edges(
      txt(label, 11.0, 500, if primary { bg_card } else { fg_body }),
      left=8.0,
      right=8.0,
      top=5.0,
      bottom=5.0,
    ),
    background=if primary {
      if hovered {
        @graphics.Color::from_argb(0xFFD8D8D8)
      } else {
        fg_primary
      }
    } else if hovered {
      white_a(0.10)
    } else {
      white_a(0.05)
    },
    corner_radius=6.0,
    padding=0.0,
  )
  .on_tap(message)
  .on_hover(fn(entered) { Hover(id, entered) })
}

///|
/// Dimmed, inert version of a page action for unavailable operations.
fn page_button_hover_disabled(
  label : String,
  icon : @moui.View[Msg],
) -> @moui.View[Msg] {
  let content = @views.row(
    [icon, txt(label, 13.0, 500, fg_dim)],
    spacing=6.0,
    align=Center,
  )
  @views.container(
    @views.padding_edges(content, left=12.0, right=12.0),
    height=32.0,
    background=white_a(0.02),
    corner_radius=8.0,
    border=Some(border_of(white_a(0.05), 1.0)),
    padding=0.0,
  )
}

///|
/// Dimmed, inert compact text action.
fn page_text_button_disabled(label : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      txt(label, 11.0, 500, fg_dim),
      left=8.0,
      right=8.0,
      top=5.0,
      bottom=5.0,
    ),
    background=white_a(0.02),
    corner_radius=6.0,
    padding=0.0,
  )
}

///|
/// A small selected/unselected filter pill at the given horizontal padding.
fn filter_pill_padded(
  label : String,
  selected : Bool,
  padding_x : Double,
) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      txt(label, 12.0, 500, if selected { fg_primary } else { fg_muted }),
      left=padding_x,
      right=padding_x,
      top=4.0,
      bottom=4.0,
    ),
    height=26.0,
    background=if selected {
      white_a(0.08)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=7.0,
    border=if selected {
      Some(border_of(white_a(0.12), 1.0))
    } else {
      Some(border_of(white_a(0.05), 1.0))
    },
    padding=0.0,
  )
}

///|
/// A small selected/unselected filter pill.
fn filter_pill(label : String, selected : Bool) -> @moui.View[Msg] {
  filter_pill_padded(label, selected, 9.0)
}

///|
fn filter_pill_tap(
  label : String,
  selected : Bool,
  message : Msg,
) -> @moui.View[Msg] {
  filter_pill(label, selected).on_tap(message)
}

///|
fn filter_pill_tap_padded(
  label : String,
  selected : Bool,
  message : Msg,
  padding_x : Double,
) -> @moui.View[Msg] {
  filter_pill_padded(label, selected, padding_x).on_tap(message)
}

///|
/// A filter pill with a live count. The count uses the muted ink so the label
/// keeps the stronger weight while the number reads as supporting metadata.
fn filter_pill_count_padded(
  label : String,
  count : Int32,
  selected : Bool,
  padding_x : Double,
) -> @moui.View[Msg] {
  let label_color = if selected { fg_primary } else { fg_muted }
  let count_color = if selected { fg_secondary } else { fg_dim }
  let content = @views.row(
    [
      txt(label, 12.0, 500, label_color),
      txt("\{count}", 10.0, 500, count_color),
    ],
    spacing=5.0,
    align=Center,
  )
  @views.container(
    @views.padding_edges(
      content,
      left=padding_x,
      right=padding_x,
      top=4.0,
      bottom=4.0,
    ),
    height=26.0,
    background=if selected {
      white_a(0.08)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=7.0,
    border=if selected {
      Some(border_of(white_a(0.12), 1.0))
    } else {
      Some(border_of(white_a(0.05), 1.0))
    },
    padding=0.0,
  )
}

///|
fn filter_pill_count_tap(
  label : String,
  count : Int32,
  selected : Bool,
  message : Msg,
) -> @moui.View[Msg] {
  filter_pill_count_padded(label, count, selected, 9.0).on_tap(message)
}

///|
fn task_matches(
  item : Task,
  filter : Int32,
  source : Int32,
  query : String,
) -> Bool {
  let status_ok = match filter {
    0 => true
    1 => item.assignee == "you"
    2 => item.status == TaskNeedsYou
    _ => item.status == TaskDone
  }
  let source_ok = match source {
    0 => true
    1 => item.source == GitHubTask
    2 => item.source == LinearTask
    _ => item.source == SlackTask
  }
  let query_ok = query == "" ||
    contains_text(item.title, query) ||
    contains_text(item.repo, query) ||
    contains_text(item.labels, query) ||
    contains_text(item.detail, query) ||
    contains_text(item.worktree_id, query)
  status_ok && source_ok && query_ok
}

///|
fn status_in_group(item : Task, group : Int32) -> Bool {
  match group {
    0 => item.status == TaskNeedsYou
    1 => item.status == TaskInProgress
    _ => item.status == TaskDone
  }
}

///|
pub fn filtered_task_indices(model : Model) -> Array[Int32] {
  let out : Array[Int32] = []
  let mut index = 0
  for item in model.tasks {
    if task_matches(
        item,
        model.task_filter,
        model.task_source_filter,
        model.task_query,
      ) {
      out.push(index)
    }
    index = index + 1
  }
  out
}

///|
/// Space reserved below the Tasks controls for the inline composer, including
/// the amber hint shown while the title is blank.
pub fn task_composer_extra(model : Model, compact : Bool) -> Double {
  if !model.task_composer_open {
    0.0
  } else {
    let hint_extra = if task_add_blocked(model) { 20.0 } else { 0.0 }
    if compact {
      84.0 + hint_extra
    } else {
      44.0 + hint_extra
    }
  }
}

///|
/// Live count for a Task status/source pill. `filter` and `source` let a pill
/// preview its own result count while the other active filter still applies.
pub fn task_filter_count(
  model : Model,
  filter : Int32,
  source : Int32,
) -> Int32 {
  let mut count = 0
  for item in model.tasks {
    if task_matches(item, filter, source, model.task_query) {
      count = count + 1
    }
  }
  count
}

///|
/// Route the main pane below the tab strip to a full page.
pub fn page_screen(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  match model.screen {
    SearchScreen => search_page(model, width, height)
    TasksScreen => tasks_page(model, width, height)
    AutomationsScreen => automations_page(model, width, height)
    _ =>
      @views.container(
        @views.empty(),
        width~,
        height~,
        background=bg_main,
        padding=0.0,
      )
  }
}

// ---------------------------------------------------------------------------
// Search

///|
#derive(Eq)
pub(all) enum SearchHitKind {
  WorktreeHit
  BotHit
  SessionHit
  FileHit
}

///|
#derive(Eq)
pub(all) enum SearchGlyph {
  GlobeGlyph
  FolderGlyph
  ScoutGlyph
  SlackGlyph
  ClaudeGlyph
  CodexGlyph
  FileGlyph
}

///|
pub(all) struct SearchHit {
  id : String
  title : String
  subtitle : String
  meta : String
  glyph : SearchGlyph
  kind : SearchHitKind
}

///|
fn search_glyph(glyph : SearchGlyph) -> @moui.View[Msg] {
  match glyph {
    GlobeGlyph =>
      @views.container(
        @views.lucide_icon(
          "globe",
          size=14.0,
          color=accent_globe,
          stroke_width=1.8,
        ),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=96.0 / 255.0,
          g=165.0 / 255.0,
          b=250.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      )
    FolderGlyph =>
      @views.container(
        @views.lucide_icon(
          "folder",
          size=14.0,
          color=accent_folder,
          stroke_width=1.8,
        ),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=245.0 / 255.0,
          g=158.0 / 255.0,
          b=11.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      )
    ScoutGlyph => mascot_avatar(Scout, 26.0)
    SlackGlyph => slack_icon(20.0)
    ClaudeGlyph =>
      @views.container(
        brand_icon(Claude, 15.0),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=217.0 / 255.0,
          g=119.0 / 255.0,
          b=87.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      )
    CodexGlyph =>
      @views.container(
        brand_icon(Codex, 15.0),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=52.0 / 255.0,
          g=211.0 / 255.0,
          b=153.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      )
    FileGlyph =>
      @views.container(
        @views.lucide_icon(
          "file-text",
          size=14.0,
          color=fg_secondary,
          stroke_width=1.7,
        ),
        width=26.0,
        height=26.0,
        background=white_a(0.06),
        corner_radius=7.0,
        padding=0.0,
      )
  }
}

///|
fn hit_kind_code(kind : SearchHitKind) -> Int32 {
  match kind {
    WorktreeHit => 1
    BotHit => 2
    SessionHit => 3
    FileHit => 4
  }
}

///|
fn hit_section(kind : SearchHitKind) -> String {
  match kind {
    WorktreeHit => "Worktrees"
    BotHit => "Bots"
    SessionHit => "Sessions"
    FileHit => "Files"
  }
}

///|
/// Search accepts an `@` prefix that narrows results to files. Returns the
/// scope flag plus the text to match against each source.
pub fn search_file_scope(query : String) -> (Bool, String) {
  let chars = query.to_array()
  if chars.length() > 0 && chars[0] == '@' {
    let rest : Array[Char] = []
    let mut i = 1
    while i < chars.length() {
      rest.push(chars[i])
      i = i + 1
    }
    (true, String::from_iter(rest.iter()))
  } else {
    (false, query)
  }
}

///|
fn search_hits(model : Model, query : String) -> Array[SearchHit] {
  let hits : Array[SearchHit] = []
  let (files_only, needle) = search_file_scope(query)
  if !files_only {
    for machine in model.machines {
      for project in machine.projects {
        let glyph = match project.kind {
          Globe => GlobeGlyph
          Folder => FolderGlyph
        }
        for worktree in project.worktrees {
          let haystack = "\{worktree.name} \{worktree.branch} \{worktree.tab_title} \{project.name} \{machine.name}"
          if contains_text(haystack, needle) {
            hits.push({
              id: worktree.id,
              title: worktree.name,
              subtitle: "\{project.name} · \{worktree.branch}",
              meta: "\{worktree.agents.length()} agents",
              glyph,
              kind: WorktreeHit,
            })
          }
        }
      }
    }
    for bot in model.bots {
      let mut haystack = "\{bot.name} \{bot.subtitle}"
      for session in bot.sessions {
        haystack = haystack + " " + session.label
      }
      if contains_text(haystack, needle) {
        hits.push({
          id: bot.id,
          title: bot.name,
          subtitle: bot.subtitle,
          meta: if bot.working > 0 {
            "\{bot.working} working"
          } else {
            bot.time
          },
          glyph: ScoutGlyph,
          kind: BotHit,
        })
      }
      for session in bot.sessions {
        let session_haystack = "\{session.label} \{bot.name}"
        if contains_text(session_haystack, needle) {
          let glyph = match session.kind {
            Home => ScoutGlyph
            ClaudeSession => ClaudeGlyph
            CodexSession => CodexGlyph
            Slack => SlackGlyph
          }
          hits.push({
            id: session.id,
            title: session.label,
            subtitle: "\{bot.name} · session",
            meta: session.time,
            glyph,
            kind: SessionHit,
          })
        }
      }
    }
  }
  for file in live_files(model) {
    let haystack = "\{file.path} \{file.project} \{file.summary} \{file.content}"
    if contains_text(haystack, needle) {
      hits.push({
        id: file.worktree_id,
        title: file.path,
        subtitle: "\{file.project} · \{file.summary}",
        meta: "file",
        glyph: FileGlyph,
        kind: FileHit,
      })
    }
  }
  hits
}

///|
fn search_hit_row(
  hit : SearchHit,
  model : Model,
  index : Int32,
  width : Double,
) -> @moui.View[Msg] {
  let hover_id = "search-hit-\{index}"
  let hovered = model.hover == hover_id
  let selected = model.search_selected == index
  let wide = width >= 620.0
  let title_w = if wide { 470.0 } else { search_hit_title_width(width) }
  let title = if wide {
    @views.text(hit.title, width=470.0, wrap=false, align=TextStart)
    .font(sans(14.0, 500))
    .foreground(fg_primary)
  } else {
    clip_left(
      @views.text(hit.title, width=0.0, wrap=false, align=TextStart)
      .font(sans(14.0, 500))
      .foreground(fg_primary),
      title_w,
      20.0,
    )
  }
  let subtitle = if wide {
    txt(hit.subtitle, 11.0, 400, fg_muted)
  } else {
    clip_left(txt(hit.subtitle, 11.0, 400, fg_muted), title_w, 16.0)
  }
  let details = @views.column([title, subtitle], spacing=3.0, align=Start)
  let children : Array[@moui.View[Msg]] = [
    search_glyph(hit.glyph),
    details,
    @views.spacer(weight=1.0),
  ]
  if wide {
    let meta_items : Array[@moui.View[Msg]] = [
      txt(hit.meta, 11.0, 400, fg_muted),
      @views.spacer(min_length=14.0, weight=0.0),
    ]
    if selected {
      meta_items.push(txt("↵", 11.0, 400, fg_dim))
    }
    children.push(@views.row(meta_items, spacing=0.0, align=Center))
  } else if search_hit_meta_visible(width) {
    let meta_items : Array[@moui.View[Msg]] = [
      @views.spacer(weight=1.0),
      txt(hit.meta, 11.0, 400, fg_muted),
    ]
    if search_hit_marker_visible(width) && selected {
      meta_items.push(@views.spacer(min_length=6.0, weight=0.0))
      meta_items.push(txt("↵", 11.0, 400, fg_dim))
    }
    children.push(
      align_right(
        @views.row(meta_items, spacing=0.0, align=Center).frame(
          width=search_hit_meta_width(width),
        ),
        search_hit_meta_width(width),
      ),
    )
  }
  let content = @views.row(children, spacing=12.0, align=Center).frame(
    width=width - 24.0,
    height=52.0,
  )
  @views.container(
    @views.padding_edges(content, left=12.0, right=12.0),
    width~,
    height=52.0,
    background=if selected {
      white_a(0.06)
    } else if hovered {
      white_a(0.04)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
    padding=0.0,
  )
  .on_tap(SelectSearchResult(hit.id))
  .on_hover(fn(entered) { Hover(hover_id, entered) })
}

///|
/// At phone widths the hit row drops its right-hand metadata so the title and
/// subtitle keep a readable column.
pub fn search_hit_meta_visible(row_w : Double) -> Bool {
  row_w >= 300.0
}

///|
/// The selected-row return marker is the first thing to go as the metadata
/// column tightens.
pub fn search_hit_marker_visible(row_w : Double) -> Bool {
  row_w >= 420.0
}

///|
fn search_hit_meta_width(row_w : Double) -> Double {
  if search_hit_marker_visible(row_w) {
    92.0
  } else {
    76.0
  }
}

///|
/// Width left for a hit's title after the glyph, metadata and row gaps.
pub fn search_hit_title_width(row_w : Double) -> Double {
  let inner = row_w - 24.0
  let gaps = if search_hit_meta_visible(row_w) { 36.0 } else { 24.0 }
  let meta = if search_hit_meta_visible(row_w) {
    search_hit_meta_width(row_w)
  } else {
    0.0
  }
  let available = inner - 26.0 - gaps - meta
  if available < 40.0 {
    40.0
  } else if available > 470.0 {
    470.0
  } else {
    available
  }
}

///|
pub fn filtered_search_hits(model : Model) -> Array[SearchHit] {
  let hits : Array[SearchHit] = []
  for hit in search_hits(model, model.search_query) {
    if model.search_filter == 0 ||
      hit_kind_code(hit.kind) == model.search_filter {
      hits.push(hit)
    }
  }
  hits
}

///|
/// Number of hits a category pill would show after tapping it. Non-Files
/// categories count the text after a leading `@` because tapping them leaves
/// file scope, while Files keeps the scoped file count.
pub fn search_filter_count(model : Model, filter : Int32) -> Int32 {
  let mut count = 0
  let (_, needle) = search_file_scope(model.search_query)
  for hit in search_hits(model, needle) {
    if filter == 0 || hit_kind_code(hit.kind) == filter {
      count = count + 1
    }
  }
  count
}

///|
/// The Search header's supporting line plus the ⌘K / ↵ shortcut block must
/// share the page header at 960 px. Drop the machine clause before the row
/// overflows its 32 px right gutter.
pub fn search_header_subtitle(width : Double) -> String {
  if width < 680.0 {
    "Find worktrees, bots, sessions and files."
  } else {
    "Find worktrees, bots, sessions and files across every connected machine."
  }
}

///|
fn search_page(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let query = model.search_query
  let hits = filtered_search_hits(model)
  let filter_count = hits.length()
  let shortcuts = @views.row(
    [
      txt("⌘K", 11.0, 500, fg_muted),
      txt("Search", 11.0, 400, fg_dim),
      @views.spacer(min_length=8.0, weight=0.0),
      txt("↵", 11.0, 500, fg_muted),
      txt("Open", 11.0, 400, fg_dim),
    ],
    spacing=4.0,
    align=Center,
  )
  let header = page_header(
    "Search",
    search_header_subtitle(width),
    width,
    [shortcuts],
    actions_width=128.0,
  )
  let field = @views.text_field(
    model.search_query,
    on_input=fn(text) { SearchInput(text) },
    on_submit=Some(OpenTopSearchHit),
    key="page-search",
    placeholder="Search worktrees, bots, sessions…",
    style=page_field_style(15.0, fg_muted),
    width=width - 200.0,
    height=44.0,
  )
  let search_box = @views.container(
    @views.padding_edges(
      @views.row(
        [
          @views.lucide_icon(
            "search",
            size=16.0,
            color=fg_muted,
            stroke_width=1.8,
          ),
          field,
          @views.spacer(weight=1.0),
          @views.container(txt("esc", 11.0, 500, fg_dim), padding=0.0).on_tap(
            ClearSearch,
          ),
        ],
        spacing=10.0,
        align=Center,
      ).frame(width=width - 96.0),
      left=16.0,
      right=16.0,
    ),
    width=width - 64.0,
    height=52.0,
    background=@graphics.Color::from_argb(0xFF1D1D1D),
    corner_radius=12.0,
    border=Some(border_of(white_a(0.12), 1.0)),
    padding=0.0,
  )
  let compact_pills = search_filters_compact(width)
  let short_count = width < 360.0
  let show_filter_counts = width >= 420.0
  let pill_padding = if compact_pills { 6.0 } else { 9.0 }
  let category_pill = fn(label : String, filter : Int32) {
    if show_filter_counts {
      filter_pill_count_padded(
        label,
        search_filter_count(model, filter),
        model.search_filter == filter,
        pill_padding,
      ).on_tap(SetSearchFilter(filter))
    } else {
      filter_pill_tap_padded(
        label,
        model.search_filter == filter,
        SetSearchFilter(filter),
        pill_padding,
      )
    }
  }
  let filters = @views.row(
    [
      category_pill("All", 0),
      category_pill(if compact_pills { "Trees" } else { "Worktrees" }, 1),
      category_pill("Bots", 2),
      category_pill(if compact_pills { "Chats" } else { "Sessions" }, 3),
      category_pill("Files", 4),
      @views.spacer(weight=1.0),
      txt(
        if short_count {
          "\{filter_count}"
        } else {
          "\{filter_count} results"
        },
        11.0,
        400,
        fg_muted,
      ),
    ],
    spacing=if compact_pills { 4.0 } else { 6.0 },
    align=Center,
  ).frame(width=width - 64.0)
  let result_views : Array[@moui.View[Msg]] = []
  let mut last_kind = 0
  let mut index = 0
  for hit in hits {
    let code = hit_kind_code(hit.kind)
    if code != last_kind {
      result_views.push(
        @views.padding_edges(
          section_label(hit_section(hit.kind), 11.0),
          top=if last_kind == 0 { 4.0 } else { 14.0 },
          bottom=6.0,
        ),
      )
      last_kind = code
    }
    result_views.push(search_hit_row(hit, model, index, width - 64.0))
    index = index + 1
  }
  if hits.is_empty() {
    result_views.push(
      @views.padding_edges(
        @views.column(
          [
            txt("No matches", 18.0, 600, fg_primary),
            txt(
              "Try a worktree name, branch, bot or session.", 13.0, 400, fg_muted,
            ),
            @views.padding_edges(
              filter_pill_tap("Clear search", false, ClearSearch),
              top=4.0,
            ),
          ],
          spacing=8.0,
          align=Center,
        ).frame(width=width - 64.0, height=180.0),
        top=28.0,
      ),
    )
  }
  let suggestion_items : Array[@moui.View[Msg]] = [
    txt("Try", 11.0, 500, fg_dim),
    filter_pill_tap("checkout", query == "checkout", SearchInput("checkout")),
    filter_pill_tap("Safari", query == "Safari", SearchInput("Safari")),
  ]
  if width >= 360.0 {
    suggestion_items.push(
      filter_pill_tap(
        "acme-internal",
        query == "acme-internal",
        SearchInput("acme-internal"),
      ),
    )
  }
  suggestion_items.push(@views.spacer(weight=1.0))
  if width >= 520.0 {
    suggestion_items.push(
      txt("Search files with @", 11.0, 400, fg_body).on_tap(SearchInput("@")),
    )
  }
  let suggestions = @views.row(suggestion_items, spacing=6.0, align=Center).frame(
    width=width - 64.0,
  )
  let body = @views.column(
    [
      @views.padding_edges(
        @views.column([search_box, filters], spacing=12.0, align=Start),
        left=32.0,
        right=32.0,
        top=4.0,
        bottom=10.0,
      ),
      @views.divider(color=white_a(0.06), thickness=1.0),
      @views.scroll_view(
        @views.column(
          [
            @views.padding_edges(
              @views.column(result_views, spacing=2.0, align=Start).frame(
                width=width - 64.0,
              ),
              left=32.0,
              right=32.0,
              top=12.0,
              bottom=20.0,
            ),
            @views.padding_edges(
              suggestions,
              left=32.0,
              right=32.0,
              top=12.0,
              bottom=24.0,
            ),
          ],
          spacing=0.0,
          align=Start,
        ).frame(width~),
        width~,
        height=height - 200.0,
      ),
    ],
    spacing=0.0,
    align=Stretch,
  )
  @views.container(
    @views.column(
      [
        header,
        @views.divider(color=white_a(0.07), thickness=1.0),
        @views.padding_edges(body, top=18.0),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

// ---------------------------------------------------------------------------
// Tasks

// Task and Automation data types and seeds live in model.mbt.

///|
fn task_source_icon(source : TaskSource) -> @moui.View[Msg] {
  match source {
    GitHubTask =>
      @views.lucide_icon(
        "code",
        size=13.0,
        color=fg_secondary,
        stroke_width=1.8,
      )
    LinearTask =>
      @views.lucide_icon(
        "grid-3x3",
        size=13.0,
        color=fg_secondary,
        stroke_width=1.8,
      )
    SlackTask => slack_icon(14.0)
  }
}

///|
fn task_source_label(source : TaskSource) -> String {
  match source {
    GitHubTask => "GitHub"
    LinearTask => "Linear"
    SlackTask => "Slack"
  }
}

///|
pub fn task_assignee_label(assignee : String) -> String {
  if assignee == "you" {
    "you"
  } else if assignee == "maya" {
    "Maya"
  } else if assignee == "liam" {
    "Liam"
  } else if assignee == "" {
    "unassigned"
  } else {
    assignee
  }
}

///|
fn task_status_label(status : TaskStatus) -> String {
  match status {
    TaskNeedsYou => "Needs you"
    TaskInProgress => "In progress"
    TaskDone => "Done"
  }
}

///|
fn task_status_color(status : TaskStatus) -> @graphics.Color {
  match status {
    TaskNeedsYou => accent_amber
    TaskInProgress => accent_globe
    TaskDone => accent_green
  }
}

///|
fn task_activity_tone(icon : ActivityIcon) -> @graphics.Color {
  match icon {
    CheckActivity => accent_green
    PlayActivity => accent_globe
    CommentActivity => accent_amber
    _ => fg_dim
  }
}

///|
fn task_status_pill(status : TaskStatus) -> @moui.View[Msg] {
  let color = task_status_color(status)
  let content = @views.row(
    [status_dot(color, 6.0), txt(task_status_label(status), 11.0, 500, color)],
    spacing=6.0,
    align=Center,
  )
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    height=24.0,
    background=white_a(0.04),
    corner_radius=7.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=0.0,
  )
}

///|
fn agent_label(kind : AgentKind) -> String {
  match kind {
    Claude => "Claude Code"
    Codex => "Codex"
    Grok => "Grok"
  }
}

///|
/// Below 360 px the new-task composer's source / agent / Add row cannot fit
/// "Claude Code" beside the other two 32 px buttons.
pub fn task_composer_agent_compact(width : Double) -> Bool {
  width < 360.0
}

///|
/// Agent button copy for the new-task composer. Only Claude's label is long
/// enough to need the phone-width shortening; Codex and Grok are unchanged.
pub fn task_composer_agent_label(kind : AgentKind, width : Double) -> String {
  if task_composer_agent_compact(width) && kind == Claude {
    "Claude"
  } else {
    agent_label(kind)
  }
}

///|
pub fn task_row_compact(row_w : Double) -> Bool {
  row_w < 520.0
}

///|
pub fn task_row_time_visible(row_w : Double) -> Bool {
  row_w >= 380.0
}

///|
pub fn task_row_title_width(row_w : Double) -> Double {
  let content_w = row_w - 20.0
  let reserved = 26.0 + 96.0 + 30.0
  let time_reserved = if task_row_time_visible(row_w) { 42.0 } else { 0.0 }
  let raw_title_w = content_w - reserved - time_reserved
  if raw_title_w < 40.0 {
    40.0
  } else if raw_title_w > 390.0 {
    390.0
  } else {
    raw_title_w
  }
}

///|
fn task_row(
  item : Task,
  index : Int32,
  selected : Bool,
  hovered : Bool,
  row_w : Double,
) -> @moui.View[Msg] {
  let source = @views.container(
    task_source_icon(item.source),
    width=26.0,
    height=26.0,
    background=white_a(0.05),
    corner_radius=7.0,
    padding=0.0,
  )
  let compact = task_row_compact(row_w)
  let show_time = !compact || task_row_time_visible(row_w)
  let title_w = task_row_title_width(row_w)
  let title = if compact {
    clip_left(
      @views.text(item.title, width=0.0, wrap=false, align=TextStart)
      .font(sans(13.0, if selected { 500 } else { 400 }))
      .foreground(fg_primary),
      title_w,
      20.0,
    )
  } else {
    @views.text(item.title, width=title_w, wrap=false, align=TextStart)
    .font(sans(13.0, if selected { 500 } else { 400 }))
    .foreground(fg_primary)
  }
  let subtitle_row = @views.row(
    [
      txt(item.repo, 11.0, 400, fg_muted),
      txt("·", 11.0, 400, fg_dim),
      txt(item.labels, 11.0, 400, fg_dim),
    ],
    spacing=5.0,
    align=Center,
  )
  let subtitle = if compact {
    clip_left(subtitle_row, title_w, 16.0)
  } else {
    subtitle_row
  }
  let children : Array[@moui.View[Msg]] = [
    source,
    @views.column([title, subtitle], spacing=3.0, align=Start),
    @views.spacer(weight=1.0),
    task_status_pill(item.status),
  ]
  if show_time {
    if compact {
      children.push(align_right(txt(item.time, 10.0, 400, fg_muted), 32.0))
    } else {
      children.push(
        @views.padding_edges(txt(item.time, 11.0, 400, fg_muted), left=10.0),
      )
    }
  }
  let content = @views.row(children, spacing=10.0, align=Center).frame(
    width=row_w - 20.0,
    height=52.0,
  )
  @views.padding_edges(
    @views.container(
      @views.padding_edges(content, left=10.0, right=10.0),
      width=row_w,
      height=52.0,
      background=if selected {
        white_a(0.05)
      } else if hovered {
        white_a(0.03)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=8.0,
      border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
      padding=0.0,
    )
    .on_tap(SelectTask(index))
    .on_hover(fn(entered) { Hover("task-\{index}", entered) })
    .on_secondary_tap_with_frame(fn(point, _frame) {
      OpenContextMenu(1, "", index, point)
    }),
    top=2.0,
    bottom=2.0,
  )
}

///|
fn task_detail(
  model : Model,
  item : Task,
  index : Int32,
  height : Double,
  width : Double,
  show_back : Bool,
) -> @moui.View[Msg] {
  let content_w = if width - 44.0 < 180.0 { 180.0 } else { width - 44.0 }
  let linked = item.worktree_id != ""
  let branch = if !linked {
    "Choose a worktree to connect"
  } else {
    match find_worktree(model, item.worktree_id) {
      Some(worktree) => worktree.branch
      None => "feature/\{item.worktree_id}"
    }
  }
  let link_name = if linked { item.worktree_id } else { "No worktree linked" }
  let link_hovered = model.hover == "task-link"
  let status = @views.row(
    [
      task_status_pill(item.status),
      txt(task_source_label(item.source), 11.0, 400, fg_muted),
      txt("·", 11.0, 400, fg_dim),
      txt(item.time, 11.0, 400, fg_muted),
    ],
    spacing=6.0,
    align=Center,
  )
  let link_card_base = @views.container(
    @views.row(
      [
        @views.container(
          @views.lucide_icon(
            "folder",
            size=14.0,
            color=if linked { accent_folder } else { fg_muted },
            stroke_width=1.8,
          ),
          width=28.0,
          height=28.0,
          background=@graphics.Color::rgba(
            r=245.0 / 255.0,
            g=158.0 / 255.0,
            b=11.0 / 255.0,
            a=0.10,
          ),
          corner_radius=7.0,
          padding=0.0,
        ),
        @views.column(
          [
            txt(
              link_name,
              13.0,
              500,
              if linked {
                fg_primary
              } else {
                fg_muted
              },
            ),
            txt(branch, 11.0, 400, fg_muted),
          ],
          spacing=2.0,
          align=Start,
        ),
        @views.spacer(weight=1.0),
        @views.lucide_icon(
          if linked {
            "chevron-right"
          } else {
            "plus"
          },
          size=13.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
      ],
      spacing=10.0,
      align=Center,
    ).frame(width=content_w - 14.0),
    width=content_w,
    height=48.0,
    background=if link_hovered {
      @graphics.Color::from_argb(0xFF202020)
    } else {
      bg_card
    },
    corner_radius=10.0,
    border=Some(border_of(white_a(if link_hovered { 0.14 } else { 0.07 }), 1.0)),
    padding=10.0,
  )
  let link_card = if linked {
    link_card_base
    .on_tap(SelectSearchResult(item.worktree_id))
    .on_hover(fn(entered) { Hover("task-link", entered) })
  } else {
    link_card_base
    .on_tap(ToggleTaskWorktreeLink)
    .on_hover(fn(entered) { Hover("task-link", entered) })
  }
  let link_action_label = if model.task_link_menu_open {
    "Close"
  } else if linked {
    "Change"
  } else {
    "Link"
  }
  let link_header = @views.row(
    [
      txt("Linked worktree", 11.0, 600, fg_muted),
      @views.spacer(weight=1.0),
      page_text_button(
        model,
        "task-link-toggle",
        link_action_label,
        ToggleTaskWorktreeLink,
        false,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=content_w)
  let agent_row = @views.row(
    [
      brand_icon(item.agent, 15.0),
      @views.column(
        [
          txt(agent_label(item.agent), 12.0, 500, fg_primary),
          @views.text(item.agent_model)
          .font(mono(10.0, 400))
          .foreground(fg_muted),
        ],
        spacing=2.0,
        align=Start,
      ),
      @views.spacer(weight=1.0),
      if item.status == TaskDone {
        status_dot(accent_green, 6.0)
      } else {
        spinner(10.0, accent_amber)
      },
      txt(
        if item.status == TaskDone {
          "finished"
        } else {
          "running"
        },
        11.0,
        400,
        fg_muted,
      ),
    ],
    spacing=9.0,
    align=Center,
  ).frame(width=content_w)
  let activity_rows : Array[@moui.View[Msg]] = []
  for entry in item.activity {
    activity_rows.push(
      @views.row(
        [
          status_dot(task_activity_tone(entry.icon), 5.0),
          txt(entry.text, 11.0, 400, fg_body),
          @views.spacer(weight=1.0),
          txt(entry.time, 10.0, 400, fg_dim),
        ],
        spacing=7.0,
        align=Center,
      ).frame(width=content_w, height=22.0),
    )
  }
  let description_views : Array[@moui.View[Msg]] = []
  if model.task_detail_editing {
    description_views.push(
      @views.text_area(
        model.task_detail_draft,
        on_input=fn(text) { TaskDetailInput(text) },
        placeholder="Add a description",
        lines=4,
        width=content_w,
        line_height=21.0,
      ),
    )
    description_views.push(
      @views.row(
        [
          page_button_hover(
            model,
            "task-save",
            "Save",
            @views.lucide_icon(
              "check",
              size=12.0,
              color=bg_card,
              stroke_width=2.0,
            ),
            SaveTaskDetail,
            true,
          ),
          page_button_hover(
            model,
            "task-cancel",
            "Cancel",
            x_icon(12.0, fg_body),
            CancelTaskDetail,
            false,
          ),
        ],
        spacing=8.0,
        align=Center,
      ),
    )
  } else {
    description_views.push(
      paragraph(item.detail, content_w, 13.0, 400, 19.0, fg_body),
    )
  }
  let body_items : Array[@moui.View[Msg]] = []
  if show_back {
    body_items.push(
      @views.row(
        [
          page_button_hover(
            model,
            "task-back",
            "Back to tasks",
            @views.lucide_icon(
              "arrow-left",
              size=13.0,
              color=fg_body,
              stroke_width=2.0,
            ),
            CloseTaskDetail,
            false,
          ),
          @views.spacer(weight=1.0),
        ],
        spacing=8.0,
        align=Center,
      ).frame(width=content_w),
    )
  }
  body_items.push(
    txt("TASK · \{task_source_label(item.source)}", 10.0, 600, fg_dim),
  )
  body_items.push(
    @views.text(item.title, width=content_w, wrap=true, align=TextStart)
    .font(sans_lh(20.0, 600, 26.0))
    .foreground(fg_primary),
  )
  body_items.push(status)
  body_items.push(@views.divider(color=white_a(0.07), thickness=1.0))
  body_items.push(
    @views.row(
      [
        txt("Description", 11.0, 600, fg_muted),
        @views.spacer(weight=1.0),
        if model.task_detail_editing {
          icon_button(x_icon(12.0, fg_muted), CancelTaskDetail, 20.0)
        } else {
          icon_button(
            @views.lucide_icon(
              "pencil",
              size=12.0,
              color=fg_muted,
              stroke_width=1.8,
            ),
            EditTaskDetail,
            20.0,
          )
        },
      ],
      spacing=6.0,
      align=Center,
    ).frame(width=content_w),
  )
  body_items.push(@views.column(description_views, spacing=8.0, align=Start))
  body_items.push(@views.divider(color=white_a(0.07), thickness=1.0))
  body_items.push(link_header)
  body_items.push(
    if model.task_link_menu_open {
      task_worktree_link_picker(model, item.worktree_id, content_w)
    } else {
      link_card
    },
  )
  body_items.push(txt("Agent", 11.0, 600, fg_muted))
  body_items.push(agent_row)
  body_items.push(txt("Activity", 11.0, 600, fg_muted))
  body_items.push(@views.column(activity_rows, spacing=2.0, align=Start))
  let footer_buttons : Array[@moui.View[Msg]] = []
  if linked {
    footer_buttons.push(
      page_button_hover(
        model,
        "task-open",
        "Open in worktree",
        arrow_up_right_icon(13.0, bg_card),
        SelectSearchResult(item.worktree_id),
        true,
      ),
    )
  }
  footer_buttons.push(
    if item.status == TaskDone {
      page_button_hover(
        model,
        "task-reopen",
        "Reopen",
        @views.lucide_icon(
          "refresh-cw",
          size=12.0,
          color=fg_body,
          stroke_width=2.0,
        ),
        ReopenTask(index),
        false,
      )
    } else {
      page_button_hover(
        model,
        "task-done",
        "Mark done",
        @views.lucide_icon("check", size=12.0, color=fg_body, stroke_width=2.0),
        MarkTaskDone(index),
        false,
      )
    },
  )
  body_items.push(
    @views.padding_edges(
      @views.row(footer_buttons, spacing=8.0, align=Center),
      top=8.0,
    ),
  )
  let body = @views.column(body_items, spacing=12.0, align=Start).frame(
    width=content_w,
  )
  @views.container(
    @views.scroll_view(
      @views.padding_edges(body, left=22.0, right=22.0, top=22.0, bottom=24.0),
      width~,
      height~,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

///|
/// Inline worktree chooser for the Tasks detail pane. It only lists worktrees
/// that still exist, so a task link cannot point at a deleted destination.
fn task_worktree_link_picker(
  model : Model,
  current : String,
  width : Double,
) -> @moui.View[Msg] {
  let options = live_worktrees(model)
  let rows : Array[@moui.View[Msg]] = []
  let mut index = 0
  for worktree in options {
    let selected = worktree.id == current
    let hovered = model.hover == "task-link-option-\{index}"
    let content = @views.row(
      [
        @views.container(
          @views.lucide_icon(
            "folder",
            size=13.0,
            color=accent_folder,
            stroke_width=1.8,
          ),
          width=26.0,
          height=26.0,
          background=@graphics.Color::rgba(
            r=245.0 / 255.0,
            g=158.0 / 255.0,
            b=11.0 / 255.0,
            a=0.10,
          ),
          corner_radius=7.0,
          padding=0.0,
        ),
        @views.column(
          [
            txt(worktree.name, 12.0, 500, fg_primary),
            txt(worktree.branch, 10.0, 400, fg_muted),
          ],
          spacing=2.0,
          align=Start,
        ),
        @views.spacer(weight=1.0),
        if selected {
          @views.lucide_icon(
            "check",
            size=13.0,
            color=accent_green,
            stroke_width=2.0,
          )
        } else {
          @views.empty()
        },
      ],
      spacing=9.0,
      align=Center,
    ).frame(width=width - 40.0, height=36.0)
    rows.push(
      @views.container(
        @views.padding_edges(content, left=8.0, right=8.0),
        width=width - 24.0,
        height=40.0,
        background=if selected {
          white_a(0.07)
        } else if hovered {
          white_a(0.04)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=8.0,
        border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
        padding=0.0,
      )
      .on_tap(LinkTaskWorktree(worktree.id))
      .on_hover(fn(entered) { Hover("task-link-option-\{index}", entered) }),
    )
    index = index + 1
  }
  if rows.is_empty() {
    rows.push(
      @views.padding_edges(
        @views.column(
          [
            txt("No worktrees available", 12.0, 500, fg_body),
            txt(
              "Create one from Projects, then return here to link it.", 11.0, 400,
              fg_muted,
            ),
          ],
          spacing=4.0,
          align=Start,
        ),
        left=8.0,
        right=8.0,
        top=10.0,
        bottom=10.0,
      ),
    )
  }
  let header = @views.row(
    [
      txt("Choose a worktree", 11.0, 600, fg_muted),
      @views.spacer(weight=1.0),
      txt("\{options.length()} available", 10.0, 400, fg_dim),
      icon_button(x_icon(12.0, fg_muted), ToggleTaskWorktreeLink, 20.0),
    ],
    spacing=7.0,
    align=Center,
  ).frame(width=width - 24.0)
  let unlink = if current != "" {
    @views.container(
      @views.row(
        [
          unplug_icon(12.0, fg_muted),
          txt("Unlink from this task", 11.0, 500, fg_body),
          @views.spacer(weight=1.0),
        ],
        spacing=7.0,
        align=Center,
      ).frame(width=width - 40.0, height=28.0),
      width=width - 24.0,
      height=28.0,
      background=if model.hover == "task-link-unlink" {
        white_a(0.05)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=7.0,
      padding=0.0,
    )
    .on_tap(UnlinkTaskWorktree)
    .on_hover(fn(entered) { Hover("task-link-unlink", entered) })
  } else {
    @views.empty()
  }
  let create = @views.container(
      @views.row(
        [
          @views.lucide_icon(
            "plus",
            size=12.0,
            color=fg_muted,
            stroke_width=2.0,
          ),
          txt("Create worktree", 11.0, 500, fg_body),
          @views.spacer(weight=1.0),
        ],
        spacing=7.0,
        align=Center,
      ).frame(width=width - 40.0, height=32.0),
      width=width - 24.0,
      height=32.0,
      background=if model.hover == "task-link-create" {
        white_a(0.05)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=7.0,
      padding=0.0,
    )
    .on_tap(OpenTaskWorktreeCreate)
    .on_hover(fn(entered) { Hover("task-link-create", entered) })
  let items : Array[@moui.View[Msg]] = [
    header,
    @views.column(rows, spacing=2.0, align=Stretch),
  ]
  items.push(@views.divider(color=white_a(0.06), thickness=1.0))
  items.push(create)
  if current != "" {
    items.push(@views.divider(color=white_a(0.06), thickness=1.0))
    items.push(unlink)
  }
  @views.container(
    @views.column(items, spacing=4.0, align=Start).frame(width=width - 24.0),
    width~,
    background=@graphics.Color::from_argb(0xFF111111),
    corner_radius=10.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=10.0,
  )
}

///|
/// Narrow Tasks layout: below 640 px the list and detail become one pane at a
/// time, so neither overflows the window.
pub fn tasks_compact(width : Double) -> Bool {
  width < 640.0
}

///|
fn tasks_page(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let compact = tasks_compact(width)
  let detail_width = if compact { width } else { 358.0 }
  let raw_list_width = if compact { width } else { width - detail_width - 1.0 }
  let list_width = if compact || raw_list_width < 240.0 {
    if compact {
      width
    } else {
      240.0
    }
  } else {
    raw_list_width
  }
  let raw_list_content = list_width - 48.0
  let list_content_w = if raw_list_content < 60.0 {
    60.0
  } else {
    raw_list_content
  }
  let actions = @views.row(
    [
      page_button_hover(
        model,
        "tasks-new",
        "New task",
        @views.lucide_icon("plus", size=13.0, color=bg_card, stroke_width=2.0),
        ToggleTaskComposer,
        true,
      ),
    ],
    spacing=8.0,
    align=Center,
  )
  let header = page_header(
    "Tasks",
    if width < 520.0 {
      "Work items from GitHub, Linear and Slack."
    } else {
      "Work items synced from GitHub, Linear and Slack."
    },
    width,
    [actions],
    actions_width=104.0,
  )
  let filtered = filtered_task_indices(model)
  let mut needs_count = 0
  let mut progress_count = 0
  let mut done_count = 0
  for index in filtered {
    let status = model.tasks[index].status
    if status == TaskNeedsYou {
      needs_count = needs_count + 1
    } else if status == TaskInProgress {
      progress_count = progress_count + 1
    } else {
      done_count = done_count + 1
    }
  }
  let fallback = if filtered.is_empty() { 0 } else { filtered[0] }
  let mut selected_in_filter = false
  for index in filtered {
    if index == model.task_selected {
      selected_in_filter = true
    }
  }
  let selected_index = if selected_in_filter {
    model.task_selected
  } else {
    fallback
  }
  let compact_pills = page_compact_pills(width)
  let dense_pills = task_filter_pills_dense(width)
  let pill_padding = if dense_pills { 6.0 } else { 9.0 }
  let all_count = task_filter_count(model, 0, model.task_source_filter)
  let mine_count = task_filter_count(model, 1, model.task_source_filter)
  let needs_filter_count = task_filter_count(model, 2, model.task_source_filter)
  let done_filter_count = task_filter_count(model, 3, model.task_source_filter)
  let tabs = @views.row(
    [
      filter_pill_count_padded(
        "All",
        all_count,
        model.task_filter == 0,
        pill_padding,
      ).on_tap(SetTaskFilter(0)),
      filter_pill_count_padded(
        if compact_pills {
          "Mine"
        } else {
          "Assigned to me"
        },
        mine_count,
        model.task_filter == 1,
        pill_padding,
      ).on_tap(SetTaskFilter(1)),
      filter_pill_count_padded(
        if compact_pills {
          "Needs"
        } else {
          "Needs you"
        },
        needs_filter_count,
        model.task_filter == 2,
        pill_padding,
      ).on_tap(SetTaskFilter(2)),
      filter_pill_count_padded(
        "Done",
        done_filter_count,
        model.task_filter == 3,
        pill_padding,
      ).on_tap(SetTaskFilter(3)),
      @views.spacer(weight=1.0),
      txt(
        if compact {
          "\{filtered.length()}/\{model.tasks.length()}"
        } else {
          "\{filtered.length()} of \{model.tasks.length()} tasks"
        },
        11.0,
        400,
        fg_muted,
      ),
    ],
    spacing=if dense_pills { 4.0 } else { 6.0 },
    align=Center,
  ).frame(width=list_content_w)
  let task_rows : Array[@moui.View[Msg]] = []
  let group_titles : Array[(Int32, String, Int32)] = [
    (0, "Needs you", needs_count),
    (1, "In progress", progress_count),
    (2, "Done", done_count),
  ]
  for group in group_titles {
    let (group_id, label, count) = group
    task_rows.push(
      @views.padding_edges(
        @views.row(
          [
            section_label(label, 11.0),
            txt("\{count}", 10.0, 500, fg_dim),
            @views.spacer(weight=1.0),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=list_content_w),
        top=if group_id == 0 { 0.0 } else { 16.0 },
        bottom=6.0,
      ),
    )
    for index in filtered {
      let item = model.tasks[index]
      if status_in_group(item, group_id) {
        task_rows.push(
          task_row(
            item,
            index,
            selected_index == index,
            model.hover == "task-\{index}",
            list_content_w,
          ),
        )
      }
    }
  }
  if filtered.is_empty() {
    task_rows.push(
      @views.padding_edges(
        @views.column(
          [
            txt("No tasks match", 15.0, 600, fg_primary),
            txt(
              "Try another search, status or source filter.", 12.0, 400, fg_muted,
            ),
            @views.padding_edges(
              filter_pill_tap("Clear filters", false, ClearTaskFilters),
              top=4.0,
            ),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=list_content_w, height=120.0),
        top=24.0,
      ),
    )
  }
  let composer : Array[@moui.View[Msg]] = []
  if model.task_composer_open {
    let field_w = if compact { list_content_w } else { 250.0 }
    let add_blocked = task_add_blocked(model)
    let field = @views.text_field(
      model.task_draft,
      on_input=fn(text) { TaskDraftInput(text) },
      on_submit=Some(AddTask),
      key="new-task-title",
      placeholder="What needs doing?",
      style=page_field_style(13.0, fg_muted),
      width=field_w,
      height=36.0,
    )
    let buttons = @views.row(
      [
        page_button_hover(
          model,
          "task-source",
          task_source_label(task_source_kind(model.task_new_source)),
          task_source_icon(task_source_kind(model.task_new_source)),
          CycleTaskSource,
          false,
        ),
        page_button_hover(
          model,
          "task-agent",
          task_composer_agent_label(
            modal_agent_kind(model.task_new_agent),
            width,
          ),
          brand_icon(modal_agent_kind(model.task_new_agent), 12.0),
          CycleTaskAgent,
          false,
        ),
        if add_blocked {
          page_button_hover_disabled(
            "Add",
            @views.lucide_icon(
              "check",
              size=12.0,
              color=fg_dim,
              stroke_width=2.0,
            ),
          )
        } else {
          page_button_hover(
            model,
            "task-add",
            "Add",
            @views.lucide_icon(
              "check",
              size=12.0,
              color=bg_card,
              stroke_width=2.0,
            ),
            AddTask,
            true,
          )
        },
      ],
      spacing=8.0,
      align=Center,
    )
    let composer_row = if compact {
      @views.column([field, buttons], spacing=8.0, align=Start).frame(
        width=list_content_w,
      )
    } else {
      @views.row([field, buttons], spacing=8.0, align=Center).frame(
        width=list_content_w,
      )
    }
    let composer_items : Array[@moui.View[Msg]] = [composer_row]
    if add_blocked {
      composer_items.push(
        txt("Type a task title to add", 11.0, 400, accent_amber),
      )
    }
    composer.push(
      @views.padding_edges(
        @views.column(composer_items, spacing=6.0, align=Start).frame(
          width=list_content_w,
        ),
        bottom=8.0,
      ),
    )
  }
  let task_field = @views.text_field(
    model.task_query,
    on_input=fn(text) { TaskQueryInput(text) },
    on_submit=Some(ActivateTaskSelection),
    key="task-search",
    placeholder="Search tasks",
    style=page_field_style(12.0, fg_muted),
    width=if compact { list_content_w - 48.0 } else { 170.0 },
    height=30.0,
  )
  let task_search = @views.container(
    @views.padding_edges(
      @views.row(
        [
          @views.lucide_icon(
            "search",
            size=13.0,
            color=fg_muted,
            stroke_width=1.8,
          ),
          task_field,
          if model.task_query != "" {
            @views.container(
              x_icon(12.0, fg_muted),
              width=20.0,
              height=20.0,
              padding=0.0,
            ).on_tap(TaskQueryInput(""))
          } else {
            @views.empty()
          },
        ],
        spacing=7.0,
        align=Center,
      ),
      left=10.0,
      right=8.0,
    ),
    height=32.0,
    background=bg_field,
    corner_radius=8.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=0.0,
  )
  let source_pills = @views.row(
    [
      filter_pill_count_tap(
        "GitHub",
        task_filter_count(model, model.task_filter, 1),
        model.task_source_filter == 1,
        SetTaskSource(1),
      ),
      filter_pill_count_tap(
        "Linear",
        task_filter_count(model, model.task_filter, 2),
        model.task_source_filter == 2,
        SetTaskSource(2),
      ),
      filter_pill_count_tap(
        "Slack",
        task_filter_count(model, model.task_filter, 3),
        model.task_source_filter == 3,
        SetTaskSource(3),
      ),
    ],
    spacing=8.0,
    align=Center,
  )
  let toolbar = if compact {
    @views.column([task_search, source_pills], spacing=8.0, align=Start).frame(
      width=list_content_w,
    )
  } else {
    @views.row(
      [task_search, @views.spacer(weight=1.0), source_pills],
      spacing=8.0,
      align=Center,
    ).frame(width=list_content_w, height=32.0)
  }
  let selected = model.tasks[selected_index]
  let toolbar_extra = if compact { 34.0 } else { 0.0 }
  let composer_extra = task_composer_extra(model, compact)
  let list_scroll_height = height -
    76.0 -
    1.0 -
    91.0 -
    toolbar_extra -
    composer_extra
  let list_scroll = @views.scroll_view(
    @views.padding_edges(
      @views.column(task_rows, spacing=0.0, align=Start).frame(
        width=list_content_w,
      ),
      left=24.0,
      right=24.0,
      top=10.0,
      bottom=24.0,
    ),
    width=list_width,
    height=list_scroll_height,
  )
  let controls : Array[@moui.View[Msg]] = []
  for control in composer {
    controls.push(control)
  }
  controls.push(tabs)
  controls.push(toolbar)
  let list_pane = @views.container(
    @views.column(
      [
        @views.padding_edges(
          @views.column(controls, spacing=10.0, align=Start).frame(
            width=list_content_w,
          ),
          left=24.0,
          right=24.0,
          top=14.0,
          bottom=8.0,
        ),
        @views.divider(color=white_a(0.06), thickness=1.0),
        list_scroll,
      ],
      spacing=0.0,
      align=Start,
    ),
    width=list_width,
    height=height - 76.0 - 1.0,
    background=bg_main,
    padding=0.0,
  )
  let details = if filtered.is_empty() {
    let empty_w = if detail_width - 44.0 < 180.0 {
      180.0
    } else {
      detail_width - 44.0
    }
    @views.container(
      @views.column(
        [
          txt("No task selected", 16.0, 600, fg_primary),
          txt(
            "Clear a status or source filter to see the queue.", 12.0, 400, fg_muted,
          ),
          @views.padding_edges(
            filter_pill_tap("Clear filters", false, ClearTaskFilters),
            top=4.0,
          ),
        ],
        spacing=8.0,
        align=Center,
      ).frame(width=empty_w, height=180.0),
      width=detail_width,
      height=height - 76.0 - 1.0,
      background=bg_main,
      padding=0.0,
    )
  } else {
    task_detail(
      model,
      selected,
      selected_index,
      height - 76.0 - 1.0,
      detail_width,
      compact,
    )
  }
  let content = if compact {
    if model.task_detail_open && !filtered.is_empty() {
      details
    } else {
      list_pane
    }
  } else {
    @views.row(
      [list_pane, vrule(height - 76.0 - 1.0), details],
      spacing=0.0,
      align=Stretch,
    ).frame(width~, height=height - 76.0 - 1.0)
  }
  @views.container(
    @views.column(
      [header, @views.divider(color=white_a(0.07), thickness=1.0), content],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

// ---------------------------------------------------------------------------
// Automations

// Automation data lives in model.mbt.

///|
/// Below this width the automation table becomes a stacked list and the
/// metric cards lose their decorative glyphs.
pub fn automations_compact(width : Double) -> Bool {
  width < 560.0
}

///|
/// Width reserved for the Automations header's primary action. The short
/// "New" label appears below 420 px.
pub fn automation_header_actions_width(width : Double) -> Double {
  if width < 420.0 {
    72.0
  } else {
    148.0
  }
}

///|
fn automation_toggle(on : Bool) -> @moui.View[Msg] {
  let knob = @views.container(
    @views.empty(),
    width=12.0,
    height=12.0,
    background=if on { fg_primary } else { fg_dim },
    corner_radius=6.0,
    padding=0.0,
  )
  let items = if on {
    [@views.spacer(weight=1.0), knob]
  } else {
    [knob, @views.spacer(weight=1.0)]
  }
  @views.container(
    @views.row(items, spacing=0.0, align=Center).frame(width=24.0),
    width=30.0,
    height=18.0,
    background=if on { white_a(0.22) } else { white_a(0.08) },
    corner_radius=9.0,
    padding=3.0,
  )
}

///|
fn automation_row(
  model : Model,
  item : Automation,
  index : Int32,
  selected : Bool,
  hovered : Bool,
  row_w : Double,
) -> @moui.View[Msg] {
  let scale = automation_col_scale(row_w - 28.0)
  let name_w = 360.0 * scale
  let schedule_w = 170.0 * scale
  let status_w = 160.0 * scale
  let status_color = task_status_color(item.tone)
  let status = @views.row(
    [
      if item.tone == TaskNeedsYou {
        spinner(10.0, accent_amber)
      } else {
        status_dot(status_color, 6.0)
      },
      txt(
        item.last_run,
        11.0,
        400,
        if item.tone == TaskInProgress {
          fg_dim
        } else {
          fg_body
        },
      ),
    ],
    spacing=7.0,
    align=Center,
  ).frame(width=status_w)
  let name = clip_left(
    @views.column(
      [
        @views.text(item.name, width=name_w, wrap=false, align=TextStart)
        .font(sans(13.0, if selected { 500 } else { 400 }))
        .foreground(fg_primary),
        txt(item.subtitle, 11.0, 400, fg_muted),
      ],
      spacing=3.0,
      align=Start,
    ),
    name_w,
    38.0,
  )
  let next_label = automation_next_run_label(model, index)
  let schedule_line = @views.row(
    [
      @views.lucide_icon("clock", size=12.0, color=fg_muted, stroke_width=1.7),
      txt(item.schedule, 11.0, 400, fg_body),
    ],
    spacing=6.0,
    align=Center,
  )
  let schedule = clip_left(
    if next_label == "" {
      schedule_line
    } else {
      @views.column(
        [schedule_line, txt(next_label, 9.5, 400, fg_dim)],
        spacing=2.0,
        align=Start,
      )
    },
    schedule_w,
    if next_label == "" {
      20.0
    } else {
      34.0
    },
  )
  let status = clip_left(status, status_w, 20.0)
  let trailing = @views.row(
    [
      automation_toggle(item.enabled).on_tap(ToggleAutomation(index)),
      txt(item.status, 11.0, 400, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=automation_trailing_width())
  let content = @views.row(
    [
      @views.container(
        sparkles_icon(13.0, accent_amber),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=251.0 / 255.0,
          g=191.0 / 255.0,
          b=36.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      ),
      name,
      schedule,
      status,
      trailing,
    ],
    spacing=14.0,
    align=Center,
  ).frame(width=row_w - 28.0, height=58.0)
  @views.container(
    @views.padding_edges(content, left=14.0, right=14.0),
    width=row_w,
    height=58.0,
    background=if selected {
      white_a(0.05)
    } else if hovered {
      white_a(0.03)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
    padding=0.0,
  )
  .on_tap(SelectAutomation(index))
  .on_hover(fn(entered) { Hover("auto-\{index}", entered) })
}

///|
/// Narrow automation row: the schedule/status columns move under the name so
/// the toggle and tap target still fit at phone widths.
fn automation_row_compact(
  model : Model,
  item : Automation,
  index : Int32,
  selected : Bool,
  hovered : Bool,
  row_w : Double,
) -> @moui.View[Msg] {
  let inner = row_w - 28.0
  let title_w = inner - 26.0 - 30.0 - 30.0
  let clamped_title_w = if title_w < 40.0 { 40.0 } else { title_w }
  let name = clip_left(
    @views.text(item.name, width=0.0, wrap=false, align=TextStart)
    .font(sans(13.0, if selected { 500 } else { 400 }))
    .foreground(fg_primary),
    clamped_title_w,
    18.0,
  )
  let next_label = automation_next_run_label(model, index)
  let detail_tail = if next_label == "" { item.status } else { next_label }
  let detail = clip_left(
    txt("\{item.schedule} · \{detail_tail}", 10.0, 400, fg_muted),
    clamped_title_w,
    16.0,
  )
  let content = @views.row(
    [
      @views.container(
        sparkles_icon(13.0, accent_amber),
        width=26.0,
        height=26.0,
        background=@graphics.Color::rgba(
          r=251.0 / 255.0,
          g=191.0 / 255.0,
          b=36.0 / 255.0,
          a=0.10,
        ),
        corner_radius=7.0,
        padding=0.0,
      ),
      @views.column([name, detail], spacing=3.0, align=Start),
      @views.spacer(weight=1.0),
      automation_toggle(item.enabled).on_tap(ToggleAutomation(index)),
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=inner, height=52.0)
  @views.container(
    @views.padding_edges(content, left=14.0, right=14.0),
    width=row_w,
    height=52.0,
    background=if selected {
      white_a(0.05)
    } else if hovered {
      white_a(0.03)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    border=if selected { Some(border_of(white_a(0.12), 1.0)) } else { None },
    padding=0.0,
  )
  .on_tap(SelectAutomation(index))
  .on_hover(fn(entered) { Hover("auto-\{index}", entered) })
}

///|
/// Width of the automation table's trailing toggle/status column. The toggle
/// and its label are fixed-size controls, so this column must not shrink with
/// the text columns or it paints past the card's right edge.
pub fn automation_trailing_width() -> Double {
  60.0
}

///|
/// Fixed columns in an automation row: the leading glyph, four 14 px gaps and
/// the fixed trailing toggle/status column.
fn automation_fixed_columns_width() -> Double {
  26.0 + 56.0 + automation_trailing_width()
}

///|
/// Width of the three text columns at full scale.
fn automation_text_columns_width() -> Double {
  360.0 + 170.0 + 160.0
}

///|
/// Column scale for the automation table's inner row width: full size at
/// 840 px and never below 35% so labels stay legible on narrow pages. The
/// trailing controls stay at their natural width and the text columns absorb
/// the difference.
pub fn automation_col_scale(row_w : Double) -> Double {
  let scale = (row_w - automation_fixed_columns_width()) /
    automation_text_columns_width()
  if scale < 0.35 {
    0.35
  } else if scale > 1.0 {
    1.0
  } else {
    scale
  }
}

///|
/// Total width used by the automation icon, text columns and their gaps.
pub fn automation_columns_width(row_w : Double) -> Double {
  automation_fixed_columns_width() +
  automation_text_columns_width() * automation_col_scale(row_w)
}

///|
/// Space reserved for Edit / Run now / Delete and the gaps between them.
fn automation_actions_width() -> Double {
  294.0
}

///|
/// Width left for the selected automation's name and subtitle after the action
/// buttons take their fixed share of the row.
pub fn automation_action_summary_width(content_w : Double) -> Double {
  let available = content_w - automation_actions_width()
  if available < 120.0 {
    120.0
  } else {
    available
  }
}

///|
/// Inner content width shared by metric, list and run cards. The extra 28 px
/// is the list card's horizontal padding, so both the content and its card stay
/// inside the page's 32 px gutters at every width.
pub fn automations_content_width(width : Double) -> Double {
  let raw_content_w = width - 64.0 - 28.0
  if raw_content_w < 120.0 {
    120.0
  } else if raw_content_w > 872.0 {
    872.0
  } else {
    raw_content_w
  }
}

///|
pub fn automations_card_width(width : Double) -> Double {
  automations_content_width(width) + 28.0
}

///|
fn automations_page(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let compact = automations_compact(width)
  let content_w = automations_content_width(width)
  let compact_labels = width < 420.0
  let card_w = automations_card_width(width)
  let col_scale = automation_col_scale(content_w - 28.0)
  let metric_row_w = card_w
  let metric_w = (metric_row_w - 28.0) / 3.0
  let show_metric_helper = metric_w >= 100.0
  let actions = @views.row(
    [
      page_button_hover(
        model,
        "automations-new",
        if compact_labels {
          "New"
        } else {
          "New automation"
        },
        @views.lucide_icon("plus", size=13.0, color=bg_card, stroke_width=2.0),
        OpenAutomationEditor,
        true,
      ),
    ],
    spacing=8.0,
    align=Center,
  )
  let header = page_header(
    "Automations",
    "Scheduled agent runs across your projects and connected hosts.",
    width,
    [actions],
    actions_width=automation_header_actions_width(width),
  )
  let metric_card = fn(
    label : String,
    value : String,
    helper : String,
    color : @graphics.Color,
    glyph : @moui.View[Msg],
    card_w : Double,
  ) {
    if compact {
      let lines : Array[@moui.View[Msg]] = [
        txt(label, 10.0, 500, fg_muted),
        txt(value, 18.0, 600, fg_primary),
      ]
      if show_metric_helper {
        lines.push(txt(helper, 10.0, 400, color))
      }
      @views.container(
        @views.column(lines, spacing=1.0, align=Start).frame(
          width=card_w - 20.0,
        ),
        width=card_w,
        height=if show_metric_helper { 64.0 } else { 54.0 },
        background=bg_card,
        corner_radius=10.0,
        border=Some(border_of(white_a(0.07), 1.0)),
        padding=10.0,
      )
    } else {
      @views.container(
        @views.row(
          [
            @views.container(
              glyph,
              width=30.0,
              height=30.0,
              background=@graphics.Color::rgba(r=1.0, g=1.0, b=1.0, a=0.05),
              corner_radius=8.0,
              padding=0.0,
            ),
            @views.column(
              [
                txt(label, 10.0, 500, fg_muted),
                txt(value, 18.0, 600, fg_primary),
                txt(helper, 10.0, 400, color),
              ],
              spacing=1.0,
              align=Start,
            ),
            @views.spacer(weight=1.0),
          ],
          spacing=12.0,
          align=Center,
        ).frame(width=card_w - 26.0),
        width=card_w,
        height=64.0,
        background=bg_card,
        corner_radius=10.0,
        border=Some(border_of(white_a(0.07), 1.0)),
        padding=10.0,
      )
    }
  }
  let runs_today = model.automation_runs_today
  let passed_today = model.automation_passed_today
  let attention_today = model.automation_attention_today
  let success_pct = automation_success_pct(model)
  let runs_delta = automation_runs_delta(model)
  let runs_delta_color = if runs_delta > 0 { accent_green } else { fg_muted }
  let metrics = @views.row(
    [
      metric_card(
        if compact_labels {
          "Runs"
        } else {
          "Runs today"
        },
        "\{runs_today}",
        automation_runs_delta_label(model),
        runs_delta_color,
        @views.lucide_icon(
          "play",
          size=14.0,
          color=accent_green,
          stroke_width=1.7,
        ),
        metric_w,
      ),
      metric_card(
        "Passed",
        "\{passed_today}",
        "\{success_pct}% success rate",
        accent_green,
        @views.lucide_icon(
          "check",
          size=14.0,
          color=accent_green,
          stroke_width=2.0,
        ),
        metric_w,
      ),
      metric_card(
        if compact_labels {
          "Needs"
        } else {
          "Needs attention"
        },
        "\{attention_today}",
        if attention_today == 1 {
          "1 run needs review"
        } else {
          "\{attention_today} runs need review"
        },
        accent_amber,
        @views.lucide_icon(
          "alert-triangle",
          size=14.0,
          color=accent_amber,
          stroke_width=1.7,
        ),
        metric_w,
      ),
    ],
    spacing=14.0,
    align=Center,
  ).frame(width=metric_row_w)
  let table_header = @views.row(
    [
      @views.container(
        @views.empty(),
        width=26.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      @views.column(
        [txt("Automation", 10.0, 600, fg_dim)],
        spacing=0.0,
        justify=Center,
        align=Start,
      ).frame(width=360.0 * col_scale),
      @views.column(
        [txt("Schedule", 10.0, 600, fg_dim)],
        spacing=0.0,
        justify=Center,
        align=Start,
      ).frame(width=170.0 * col_scale),
      @views.column(
        [txt("Last run", 10.0, 600, fg_dim)],
        spacing=0.0,
        justify=Center,
        align=Start,
      ).frame(width=160.0 * col_scale),
      @views.column(
        [txt("Status", 10.0, 600, fg_dim)],
        spacing=0.0,
        justify=Center,
        align=Start,
      ).frame(width=automation_trailing_width()),
      @views.spacer(weight=1.0),
    ],
    spacing=14.0,
    align=Center,
  ).frame(width=content_w - 28.0, height=26.0)
  let table_header = @views.padding_edges(table_header, left=28.0, right=0.0)
  let rows_scroll : Array[@moui.View[Msg]] = []
  let mut index = 0
  for item in model.automations {
    rows_scroll.push(
      if compact {
        automation_row_compact(
          model,
          item,
          index,
          model.automation_selected == index,
          model.hover == "auto-\{index}",
          content_w,
        )
      } else {
        automation_row(
          model,
          item,
          index,
          model.automation_selected == index,
          model.hover == "auto-\{index}",
          content_w,
        )
      },
    )
    if index < model.automations.length() - 1 {
      rows_scroll.push(@views.divider(color=white_a(0.05), thickness=1.0))
    }
    index = index + 1
  }
  let run_rows : Array[@moui.View[Msg]] = []
  let mut shown = 0
  for run in model.automation_runs {
    if model.automation_runs_expanded || shown < 3 {
      shown = shown + 1
      let name = if run.automation >= 0 &&
        run.automation < model.automations.length() {
        model.automations[run.automation].name
      } else {
        "Automation"
      }
      let dot = status_dot(
        if run.tone == TaskNeedsYou {
          accent_amber
        } else {
          accent_green
        },
        6.0,
      )
      let run_row = if compact {
        let text_w = content_w - 74.0
        let clamped_w = if text_w < 40.0 { 40.0 } else { text_w }
        let run_name = clip_left(
          txt(name, 12.0, 500, fg_primary),
          clamped_w,
          16.0,
        )
        let note = clip_left(
          txt(run.note, 10.0, 400, fg_muted),
          clamped_w,
          14.0,
        )
        @views.row(
          [
            dot,
            @views.column([run_name, note], spacing=2.0, align=Start),
            @views.spacer(weight=1.0),
            align_right(txt(run.time, 10.0, 400, fg_muted), 44.0),
          ],
          spacing=8.0,
          align=Center,
        ).frame(width=content_w, height=42.0)
      } else {
        @views.row(
          [
            dot,
            @views.column(
              [
                txt(name, 12.0, 500, fg_primary),
                txt(run.note, 10.0, 400, fg_muted),
              ],
              spacing=2.0,
              align=Start,
            ),
            @views.spacer(weight=1.0),
            txt(run.state, 11.0, 400, fg_body),
            align_right(txt(run.time, 11.0, 400, fg_muted), 58.0),
          ],
          spacing=10.0,
          align=Center,
        ).frame(width=content_w, height=40.0)
      }
      run_rows.push(
        run_row
        .on_tap(SelectAutomation(run.automation))
        .on_hover(fn(entered) { Hover("auto-run-\{shown}", entered) }),
      )
    }
  }
  let list_items : Array[@moui.View[Msg]] = []
  let has_selection = model.automation_selected >= 0 &&
    model.automation_selected < model.automations.length()
  if model.automations.is_empty() {
    list_items.push(
      @views.column(
        [
          txt("No automations yet", 15.0, 600, fg_primary),
          txt(
            "Create one to run an agent prompt on a schedule.", 12.0, 400, fg_muted,
          ),
        ],
        spacing=6.0,
        align=Center,
      ).frame(width=content_w, height=120.0),
    )
  } else {
    if !compact {
      list_items.push(table_header)
    }
    list_items.push(@views.column(rows_scroll, spacing=4.0, align=Start))
    if has_selection {
      let item = model.automations[model.automation_selected]
      let run_button = if item.enabled {
        page_text_button(
          model,
          "automation-compact-run-\{model.automation_selected}",
          "Run now",
          RunAutomation(model.automation_selected),
          false,
        )
      } else {
        page_text_button_disabled("Run now")
      }
      list_items.push(@views.divider(color=white_a(0.06), thickness=1.0))
      if compact {
        list_items.push(
          @views.column(
            [
              @views.row(
                [
                  sparkles_icon(13.0, accent_amber),
                  txt("\{item.schedule}", 10.0, 400, fg_muted),
                  txt("·", 10.0, 400, fg_dim),
                  txt(item.last_run, 10.0, 400, fg_muted),
                  @views.spacer(weight=1.0),
                ],
                spacing=6.0,
                align=Center,
              ).frame(width=content_w),
              @views.row(
                [
                  page_text_button(
                    model,
                    "automation-compact-edit-\{model.automation_selected}",
                    "Edit",
                    EditAutomation(model.automation_selected),
                    false,
                  ),
                  run_button,
                  page_text_button(
                    model,
                    "automation-compact-delete-\{model.automation_selected}",
                    "Delete",
                    DeleteAutomation(model.automation_selected),
                    false,
                  ),
                ],
                spacing=6.0,
                align=Center,
              ),
            ],
            spacing=8.0,
            align=Start,
          ).frame(width=content_w),
        )
      } else {
        let summary_w = automation_action_summary_width(content_w)
        let run_button = if item.enabled {
          page_button_hover(
            model,
            "auto-run",
            "Run now",
            @views.lucide_icon(
              "play",
              size=12.0,
              color=fg_body,
              stroke_width=1.8,
            ),
            RunAutomation(model.automation_selected),
            false,
          )
        } else {
          page_button_hover_disabled(
            "Run now",
            @views.lucide_icon(
              "play",
              size=12.0,
              color=fg_dim,
              stroke_width=1.8,
            ),
          )
        }
        let summary = clip_left(
          @views.column(
            [
              txt(item.name, 11.0, 500, fg_body),
              txt("\{item.subtitle} · \{item.schedule}", 10.0, 400, fg_muted),
            ],
            spacing=2.0,
            align=Start,
          ),
          summary_w,
          38.0,
        )
        list_items.push(
          @views.row(
            [
              sparkles_icon(13.0, accent_amber),
              summary,
              @views.spacer(weight=1.0),
              page_button_hover(
                model,
                "auto-edit",
                "Edit",
                @views.lucide_icon(
                  "pencil",
                  size=12.0,
                  color=fg_body,
                  stroke_width=1.8,
                ),
                EditAutomation(model.automation_selected),
                false,
              ),
              run_button,
              page_button_hover(
                model,
                "auto-delete",
                "Delete",
                @views.lucide_icon(
                  "trash-2",
                  size=12.0,
                  color=fg_body,
                  stroke_width=1.8,
                ),
                DeleteAutomation(model.automation_selected),
                false,
              ),
            ],
            spacing=8.0,
            align=Center,
          ).frame(width=content_w, height=40.0),
        )
      }
    }
  }
  let list_card = @views.container(
    @views.column(list_items, spacing=8.0, align=Start).frame(width=content_w),
    width=card_w,
    background=bg_card,
    corner_radius=12.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=14.0,
  )
  let runs_card = @views.container(
    @views.column(
      [
        @views.row(
          [
            txt("Recent runs", 12.0, 600, fg_secondary),
            @views.spacer(weight=1.0),
            if !model.automation_runs.is_empty() {
              @views.row(
                [
                  txt(
                    if model.automation_runs_expanded {
                      "Show less"
                    } else {
                      "View all"
                    },
                    11.0,
                    500,
                    fg_muted,
                  ),
                  @views.lucide_icon(
                    if model.automation_runs_expanded {
                      "chevron-up"
                    } else {
                      "chevron-down"
                    },
                    size=12.0,
                    color=fg_muted,
                    stroke_width=1.8,
                  ),
                ],
                spacing=4.0,
                align=Center,
              ).on_tap(ToggleAutomationRuns)
            } else {
              @views.spacer(weight=0.0)
            },
          ],
          spacing=8.0,
          align=Center,
        ).frame(width=content_w),
        if model.automation_runs.is_empty() {
          @views.column(
            [
              txt("No runs yet", 15.0, 600, fg_primary),
              txt(
                "Run an automation to see its history here.", 12.0, 400, fg_muted,
              ),
              @views.padding_edges(
                page_text_button(
                  model,
                  "automations-runs-new",
                  "New automation",
                  OpenAutomationEditor,
                  false,
                ),
                top=4.0,
              ),
            ],
            spacing=6.0,
            align=Start,
          ).frame(width=content_w, height=92.0)
        } else {
          @views.column(run_rows, spacing=2.0, align=Start)
        },
      ],
      spacing=10.0,
      align=Start,
    ).frame(width=content_w),
    width=card_w,
    background=bg_card,
    corner_radius=12.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=14.0,
  )
  let content = @views.scroll_view(
    @views.padding_edges(
      @views.column(
        [
          metrics,
          @views.padding_edges(
            @views.row([list_card, @views.spacer(weight=1.0)], spacing=0.0).frame(
              width=content_w,
            ),
            top=12.0,
          ),
          @views.padding_edges(
            @views.row([runs_card, @views.spacer(weight=1.0)], spacing=0.0).frame(
              width=content_w,
            ),
            top=12.0,
          ),
        ],
        spacing=0.0,
        align=Start,
      ),
      left=32.0,
      right=32.0,
      top=14.0,
      bottom=28.0,
    ),
    width~,
    height=height - 76.0 - 1.0,
  )
  @views.container(
    @views.column(
      [header, @views.divider(color=white_a(0.07), thickness=1.0), content],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

// ---------------------------------------------------------------------------
// Automation editor

///|
/// Full-screen scrim plus the centered automation editor.
pub fn automation_editor_modal(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let scrim = @views.container(
    @views.empty(),
    width~,
    height~,
    background=black_a(0.60),
    padding=0.0,
  )
  let overlay = @views.container(
    @views.column(
      [automation_editor_card(model, width)],
      spacing=0.0,
      justify=Center,
      align=Center,
    ).frame(width~, height~),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseAutomationEditor)
  @views.stack([scrim, overlay])
}

///|
fn automation_editor_card(
  model : Model,
  viewport_w : Double,
) -> @moui.View[Msg] {
  let card_w = overlay_card_width(viewport_w)
  let content_w = card_w - 48.0
  let field_w = (content_w - 16.0) / 2.0
  let editing = model.automation_editor_index >= 0 &&
    model.automation_editor_index < model.automations.length()
  let title = if editing { "Edit automation" } else { "New automation" }
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(CloseAutomationEditor)
  let header = @views.row(
    [txt(title, 20.0, 600, fg_primary), @views.spacer(weight=1.0), close],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let name_field = @views.text_field(
    model.automation_name,
    on_input=fn(text) { AutomationNameInput(text) },
    on_submit=Some(SaveAutomation),
    on_cancel=CloseAutomationEditor,
    key="automation-name",
    placeholder="Nightly EU promo regression",
    style=modal_field_style(),
    width=content_w - 28.0,
    height=40.0,
  )
  let name_control = @views.container(
    @views.padding_edges(name_field, left=14.0, right=14.0),
    width=content_w,
    height=40.0,
    background=bg_field_focus,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.22), 1.0)),
    padding=0.0,
  )
  let save_blocked = automation_save_blocked(model)
  let name_items : Array[@moui.View[Msg]] = [name_control]
  if save_blocked {
    name_items.push(txt("Type a name to save", 11.0, 400, accent_amber))
  }
  let name_block = @views.column(name_items, spacing=6.0, align=Start)
  let compact = overlay_footer_compact(content_w)
  let field_width = if compact { content_w } else { field_w }
  let schedule_field = select_field(
    model,
    "Schedule",
    @views.lucide_icon("clock", size=14.0, color=fg_muted, stroke_width=1.7),
    automation_schedule_label(model.automation_schedule),
    CycleAutomationSchedule,
    field_width,
    icon_width=14.0,
  )
  let project_field = select_field(
    model,
    "Project",
    @views.lucide_icon(
      "folder",
      size=14.0,
      color=accent_folder,
      stroke_width=1.8,
    ),
    automation_project_label(model.automation_project),
    CycleAutomationProject,
    field_width,
    icon_width=14.0,
  )
  let fields = if compact {
    @views.column([schedule_field, project_field], spacing=10.0, align=Start).frame(
      width=content_w,
    )
  } else {
    @views.row([schedule_field, project_field], spacing=16.0, align=Start).frame(
      width=content_w,
    )
  }
  let summary = paragraph(
    "Runs on Local Mac with full access. Each run starts a fresh agent in the \{automation_project_label(model.automation_project)} project.",
    content_w,
    12.0,
    400,
    18.0,
    fg_muted,
  )
  let cancel = @views.container(
    @views.padding_edges(
      txt("Cancel", 13.0, 500, fg_body),
      left=12.0,
      right=12.0,
    ),
    height=36.0,
    background=white_a(0.05),
    corner_radius=8.0,
    border=Some(border_of(white_a(0.09), 1.0)),
    padding=0.0,
  ).on_tap(CloseAutomationEditor)
  let save = @views.container(
    @views.padding_edges(
      @views.row(
        [
          txt(
            if editing {
              "Save changes"
            } else {
              "Create automation"
            },
            13.0,
            500,
            if save_blocked {
              fg_muted
            } else {
              bg_card
            },
          ),
          @views.spacer(weight=1.0),
          txt("⌘↵", 12.0, 400, fg_dim),
        ],
        spacing=6.0,
        align=Center,
      ).frame(width=150.0),
      left=12.0,
      right=12.0,
    ),
    height=36.0,
    background=if save_blocked { white_a(0.14) } else { fg_primary },
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(SaveAutomation)
  let footer = if overlay_footer_compact(content_w) {
    @views.column([cancel, save], spacing=8.0, align=End).frame(width=content_w)
  } else {
    @views.row(
      [cancel, @views.spacer(weight=1.0), save],
      spacing=8.0,
      align=Center,
    ).frame(width=content_w)
  }
  @views.container(
    @views.column(
      [
        header,
        txt("Name", 13.0, 400, fg_secondary),
        name_block,
        fields,
        summary,
        footer,
      ],
      spacing=18.0,
      align=Start,
    ).frame(width=content_w),
    background=bg_card,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=24.0,
  ).on_tap(Noop)
}
