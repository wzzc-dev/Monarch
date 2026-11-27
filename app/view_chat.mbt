///|
/// Orca's default chat width is 46rem (736 px) for the "Narrow" appearance preset.
/// The composer shares this maximum so the transcript and input line up.
let chat_max_width : Double = 736.0

///|
/// Side gutter at compact widths. The reference keeps the chat card ~26 px
/// inside the main pane instead of the older 32 px gutter.
let chat_side_gutter : Double = 26.0

///|
/// Reference transcript copy: 17.5 px with a 29 px line box. Worker cards, live
/// rows and user bubbles share it so the chat reads as one type system.
let chat_body_size : Double = 17.5

///|
let chat_body_line_height : Double = 29.0

///|
/// Content width after the side gutters, clamped for very narrow panes.
pub fn chat_content_width(width : Double) -> Double {
  let inner = width - chat_side_gutter * 2.0
  if inner < 0.0 {
    0.0
  } else if inner > chat_max_width {
    chat_max_width
  } else {
    inner
  }
}

///|
/// Paragraph bounds get a little more room than cards: the paragraph engine is
/// conservative with wrapped runs, while painted lines still end inside the
/// card column.
pub fn chat_prose_width(width : Double) -> Double {
  if width <= 0.0 {
    0.0
  } else {
    width + 20.0
  }
}

///|
/// The full transcript for the active worktree.
fn transcript(model : Model, width : Double) -> @moui.View[Msg] {
  match find_worktree(model, model.active) {
    None => @views.empty()
    Some(worktree) => {
      let content_width = chat_content_width(width)
      let prose_width = chat_prose_width(content_width)
      let blocks : Array[@moui.View[Msg]] = []
      let mut index = 0
      for block in worktree.transcript {
        blocks.push(
          block_view(worktree.id, block, index, content_width, prose_width),
        )
        index = index + 1
      }
      @views.padding_edges(
        @views.column(blocks, spacing=14.0, align=Start)
        .frame(width=prose_width)
        .offset(dx=(prose_width - content_width) / 2.0),
        top=16.0,
        bottom=24.0,
      )
    }
  }
}

///|
/// Render one transcript block.
fn block_view(
  worktree_id : String,
  block : Block,
  index : Int32,
  width : Double,
  prose_width : Double,
) -> @moui.View[Msg] {
  match block {
    UserMessage(text) => user_bubble(text, width)
    AssistantMessage(text) =>
      paragraph(
        text, prose_width, chat_body_size, 400, chat_body_line_height, fg_body,
      )
    Worked(row) => worked_row(worktree_id, row, index, width)
    Worker(card) =>
      worker_card(card, width).on_tap(ToggleWorker(worktree_id, index))
    LiveRow(label, text) => live_row(label, text, width)
  }
}

///|
/// Right-aligned user bubble.
fn user_bubble(text : String, width : Double) -> @moui.View[Msg] {
  user_bubble_sized(text, width, chat_body_size, chat_body_line_height)
}

///|
/// User bubble with an explicit type scale; Bots keeps its smaller copy.
fn user_bubble_sized(
  text : String,
  width : Double,
  size : Double,
  line_height : Double,
) -> @moui.View[Msg] {
  let bubble_width = width * 0.80
  let bubble = @views.container(
    @views.padding_edges(
      paragraph(text, bubble_width - 14.0, size, 400, line_height, fg_bubble),
      left=14.0,
      top=10.0,
      bottom=10.0,
    ),
    background=bg_bubble,
    corner_radius=14.0,
    padding=0.0,
  )
  @views.column([bubble], spacing=0.0, align=End).frame(width~)
}

///|
/// Collapsible "Worked for Ns" row with a bottom hairline.
fn worked_row(
  worktree_id : String,
  row : WorkedRow,
  index : Int32,
  width : Double,
) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = [
    @views.row(
      [
        txt(row.label, 17.5, 400, fg_muted),
        @views.lucide_icon(
          "chevron-right",
          size=16.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        @views.spacer(weight=1.0),
      ],
      spacing=6.0,
      align=Center,
    ),
  ]
  if row.expanded {
    items.push(
      paragraph(
        row.body,
        width,
        chat_body_size,
        400,
        chat_body_line_height,
        fg_body,
      ),
    )
  }
  items.push(@views.divider(color=white_a(0.07), thickness=1.0))
  @views.column(items, spacing=8.0, align=Stretch)
  .frame(width~)
  .on_tap(ToggleWorked(worktree_id, index))
}

///|
/// Worker progress card; the focused card carries the outer white ring.
fn worker_card(card : WorkerCard, width : Double) -> @moui.View[Msg] {
  let card_width = if card.focused { width - 6.0 } else { width }
  let header = @views.row(
    [
      brand_icon(card.kind, 18.0),
      txt("Update from worker", 17.5, 500, fg_primary),
      txt(card.name, 15.5, 400, fg_muted),
      arrow_up_right_icon(14.0, fg_dim),
      @views.spacer(weight=1.0),
      txt(card.time, 15.5, 400, fg_muted),
      @views.lucide_icon(
        "chevron-up",
        size=16.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=card_width - 32.0)
  let body = paragraph(
    card.body,
    card_width,
    chat_body_size,
    400,
    chat_body_line_height,
    fg_body,
  )
  let inner = @views.container(
    @views.padding_edges(
      @views.column([header, body], spacing=10.0, align=Start).frame(
        width=card_width,
      ),
      top=12.0,
      bottom=12.0,
    ).offset(dx=12.0),
    width=card_width,
    background=bg_card,
    corner_radius=14.0,
    border=if card.focused {
      Some(border_of(white_a(0.32), 1.0))
    } else {
      Some(border_of(white_a(0.07), 1.0))
    },
    padding=0.0,
  )
  if card.focused {
    @views.container(
      inner,
      width~,
      background=white_a(0.04),
      corner_radius=17.0,
      padding=3.0,
    )
  } else {
    inner
  }
}

///|
/// A muted live status row with a "Working for N" divider above it.
fn live_row(label : String, text : String, width : Double) -> @moui.View[Msg] {
  @views.column(
    [
      @views.row(
        [
          txt(label, 16.5, 400, fg_dim),
          @views.lucide_icon(
            "chevron-right",
            size=15.0,
            color=fg_dim,
            stroke_width=1.8,
          ),
          @views.spacer(weight=1.0),
        ],
        spacing=6.0,
        align=Center,
      ),
      @views.divider(color=white_a(0.06), thickness=1.0),
      @views.row(
        [loader_icon(17.5, fg_muted), txt(text, 17.5, 400, fg_muted)],
        spacing=8.0,
        align=Center,
      ),
    ],
    spacing=8.0,
    align=Stretch,
  ).frame(width~)
}

///|
/// Composer column, centered under the transcript.
fn composer_area(model : Model, main_width : Double) -> @moui.View[Msg] {
  let full_width = main_width - chat_side_gutter * 2.0
  let padded_width = if full_width < 0.0 { 0.0 } else { full_width }
  let composer_width = if padded_width > chat_max_width {
    chat_max_width
  } else {
    padded_width
  }
  let side = if main_width < chat_side_gutter * 2.0 {
    0.0
  } else {
    chat_side_gutter
  }
  let inner = @views.row(
    [
      @views.spacer(weight=1.0),
      composer(model, composer_width),
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=padded_width)
  let content = match composer_menu_active(model) {
    Some(menu) => {
      let picker = composer_menu_view(model, menu, composer_width, fn(insert) {
        DraftInput(insert)
      })
      @views.column([picker, inner], spacing=8.0, align=Center).frame(
        width=padded_width,
      )
    }
    None => inner
  }
  @views.padding_edges(content, top=16.0, bottom=22.0, left=side, right=side)
}

///|
/// Transparent text-field style that leaves the composer chrome to its card.
fn composer_field_style() -> @style.TextFieldStyle {
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
    placeholder_color=fg_muted,
    cursor_color=fg_primary,
    font=sans_lh(18.0, 400, 24.0),
  )
}

///|
fn access_color(index : Int32) -> @graphics.Color {
  if index == 1 {
    accent_amber
  } else if index == 2 {
    fg_muted
  } else {
    accent_full_access
  }
}

///|
/// Below this composer width the footer drops its accessory icons and uses
/// short access labels so the chips and send button stay inside the card.
pub fn composer_footer_compact(width : Double) -> Bool {
  width < 330.0
}

///|
pub fn composer_access_short_label(index : Int32) -> String {
  if index == 1 {
    "Ask"
  } else if index == 2 {
    "Read"
  } else {
    "Full"
  }
}

///|
/// Placeholder copy trimmed to the field width so narrow panes never clip it.
pub fn composer_placeholder(field_width : Double) -> String {
  if field_width < 392.0 {
    "Ask anything…"
  } else if field_width < 430.0 {
    "Ask anything, @ to mention files, / for…"
  } else {
    "Ask anything, @ to mention files, / for commands"
  }
}

///|
/// One row in the composer's `/` command or `@` file picker.
pub(all) struct ComposerSuggestion {
  label : String
  detail : String
  insert : String
}

///|
/// The active completion menu for a composer draft.
pub(all) struct ComposerMenu {
  is_command : Bool
  query : String
  suggestions : Array[ComposerSuggestion]
}

///|
fn composer_is_space(value : Char) -> Bool {
  value == ' ' || value == '\t' || value == '\n'
}

///|
fn composer_command_suggestions() -> Array[ComposerSuggestion] {
  [
    { label: "/review", detail: "Review the current diff", insert: "/review ", },
    { label: "/test", detail: "Run the relevant checks", insert: "/test ", },
    {
      label: "/fix",
      detail: "Fix failing checks in this worktree",
      insert: "/fix ",
    },
    {
      label: "/explain",
      detail: "Explain the latest changes",
      insert: "/explain ",
    },
    {
      label: "/summarize",
      detail: "Summarize this conversation",
      insert: "/summarize ",
    },
  ]
}

///|
/// Index of the `@` that starts the mention at the end of the draft, or -1.
fn composer_mention_start(draft : String) -> Int32 {
  let chars = draft.to_array()
  let mut index = chars.length() - 1
  while index >= 0 {
    let value = chars[index]
    if value == '@' {
      if index == 0 || composer_is_space(chars[index - 1]) {
        return index
      }
      return -1
    }
    if composer_is_space(value) {
      return -1
    }
    index = index - 1
  }
  -1
}

///|
/// Completion menu for the current draft. Commands are only offered while the
/// first token starts with `/`; mentions are offered for the last unfinished
/// `@` token so both can be typed without memorizing the syntax.
pub fn composer_menu(draft : String, files : Array[SeedFile]) -> ComposerMenu? {
  let chars = draft.to_array()
  if chars.length() > 0 && chars[0] == '/' {
    let query_chars : Array[Char] = []
    let mut index = 1
    while index < chars.length() {
      if composer_is_space(chars[index]) {
        return None
      }
      query_chars.push(chars[index])
      index = index + 1
    }
    let query = String::from_iter(query_chars.iter())
    let matches : Array[ComposerSuggestion] = []
    for suggestion in composer_command_suggestions() {
      if contains_text(suggestion.label, query) {
        matches.push(suggestion)
      }
    }
    if matches.is_empty() {
      None
    } else {
      Some({ is_command: true, query, suggestions: matches, })
    }
  } else {
    let start = composer_mention_start(draft)
    if start < 0 {
      return None
    }
    let query_chars : Array[Char] = []
    let mut index = start + 1
    while index < chars.length() {
      query_chars.push(chars[index])
      index = index + 1
    }
    let query = String::from_iter(query_chars.iter())
    let matches : Array[ComposerSuggestion] = []
    for file in files {
      if matches.length() >= 5 {
        break
      }
      let haystack = "\{file.path} \{file.project} \{file.summary}"
      if contains_text(haystack, query) {
        let inserted : Array[Char] = []
        let mut prefix_index = 0
        while prefix_index < start {
          inserted.push(chars[prefix_index])
          prefix_index = prefix_index + 1
        }
        inserted.push('@')
        for value in file.path.to_array() {
          inserted.push(value)
        }
        inserted.push(' ')
        matches.push({
          label: file.path,
          detail: "\{file.project} · \{file.summary}",
          insert: String::from_iter(inserted.iter()),
        })
      }
    }
    if matches.is_empty() {
      None
    } else {
      Some({ is_command: false, query, suggestions: matches, })
    }
  }
}

///|
pub fn composer_menu_height(menu : ComposerMenu) -> Double {
  47.0 + menu.suggestions.length().to_double() * 42.0
}

///|
/// Menu shown for the Projects/Bots draft, honoring an Escape dismissal.
pub fn composer_menu_active(model : Model) -> ComposerMenu? {
  if model.composer_menu_closed {
    None
  } else {
    composer_menu(model.draft, live_files(model))
  }
}

///|
pub fn diff_composer_menu_active(model : Model) -> ComposerMenu? {
  if model.diff_composer_menu_closed {
    None
  } else {
    composer_menu(model.diff_draft, live_files(model))
  }
}

///|
/// Keyboard/hover highlight inside the open completion menu. A negative value
/// means no row is highlighted yet; `composer_accept_index` still resolves
/// Enter to the first match so typing `/rev` + Enter inserts `/review `.
pub fn composer_pick_index(model : Model, menu : ComposerMenu) -> Int32 {
  let last = menu.suggestions.length() - 1
  if last < 0 || model.composer_pick < 0 {
    -1
  } else if model.composer_pick > last {
    last
  } else {
    model.composer_pick
  }
}

///|
pub fn composer_accept_index(model : Model, menu : ComposerMenu) -> Int32 {
  let pick = composer_pick_index(model, menu)
  if pick < 0 {
    0
  } else {
    pick
  }
}

///|
pub fn composer_active_accept_index(model : Model) -> Int32 {
  match composer_menu_active(model) {
    Some(menu) => composer_accept_index(model, menu)
    None => 0
  }
}

///|
pub fn diff_composer_active_accept_index(model : Model) -> Int32 {
  match diff_composer_menu_active(model) {
    Some(menu) => composer_accept_index(model, menu)
    None => 0
  }
}

///|
/// Whether the Projects/Bots completion menu should own the arrow keys. Bots
/// only has a composer while a chat tab is open, and overlays keep their own
/// navigation.
pub fn composer_menu_keys_active(model : Model) -> Bool {
  if model.modal_open ||
    model.rename_open ||
    model.delete_open ||
    model.automation_editor_open ||
    model.help_open ||
    model.ctx_open ||
    model.bot_search_open ||
    model.bots_options_open ||
    model.sidebar_options_open {
    return false
  }
  let on_composer = model.screen == Projects ||
    (model.screen == Bots && bots_tab_open(model))
  on_composer && composer_menu_active(model) is Some(_)
}

///|
pub fn diff_composer_menu_keys_active(model : Model) -> Bool {
  if model.modal_open ||
    model.help_open ||
    model.ctx_open ||
    model.diff_note_open ||
    model.diff_focus ||
    model.screen != DiffScreen {
    return false
  }
  diff_composer_menu_active(model) is Some(_)
}

///|
/// Height reserved above the Projects composer; the closed composer keeps the
/// reference's 155 px band.
pub fn composer_area_height(model : Model) -> Double {
  match composer_menu_active(model) {
    Some(menu) => 155.0 + composer_menu_height(menu) + 8.0
    None => 155.0
  }
}

///|
/// Extra height the Bots composer needs when its completion menu is open.
pub fn bots_composer_menu_height(model : Model) -> Double {
  match composer_menu_active(model) {
    Some(menu) => composer_menu_height(menu) + 8.0
    None => 0.0
  }
}

///|
/// Extra height the Diff composer needs when its completion menu is open.
pub fn diff_composer_menu_height(model : Model) -> Double {
  match diff_composer_menu_active(model) {
    Some(menu) => composer_menu_height(menu) + 8.0
    None => 0.0
  }
}

///|
/// Insert text for the composer's plus button: it opens a file mention rather
/// than pretending to attach a binary blob the replica cannot store.
pub fn composer_mention_trigger(draft : String) -> String {
  let chars = draft.to_array()
  if chars.is_empty() {
    "@"
  } else if composer_is_space(chars[chars.length() - 1]) {
    draft + "@"
  } else {
    draft + " @"
  }
}

///|
fn composer_menu_view(
  model : Model,
  menu : ComposerMenu,
  width : Double,
  on_pick : (String) -> Msg,
) -> @moui.View[Msg] {
  let row_width = if width - 12.0 < 0.0 { 0.0 } else { width - 12.0 }
  let title_width = if row_width - 72.0 < 60.0 {
    60.0
  } else {
    row_width - 72.0
  }
  let header = @views.row(
    [
      txt(
        if menu.is_command {
          "Commands"
        } else {
          "Mention a file"
        },
        11.0,
        500,
        fg_muted,
      ),
      @views.spacer(weight=1.0),
      txt(
        if row_width >= 330.0 {
          if menu.query == "" {
            "↑↓ select · Enter insert"
          } else {
            "↑↓ · Enter · \{if menu.is_command { "/" } else { "@" }}\{menu.query}"
          }
        } else if menu.query == "" {
          "↑↓ · Enter"
        } else {
          "↑↓ · \{if menu.is_command { "/" } else { "@" }}\{menu.query}"
        },
        10.0,
        400,
        fg_dim,
      ),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=row_width, height=22.0)
  let rows : Array[@moui.View[Msg]] = []
  let picked = composer_pick_index(model, menu)
  let mut index = 0
  for suggestion in menu.suggestions {
    let hovered = index == picked
    let icon_name = if menu.is_command { "terminal" } else { "file-text" }
    rows.push(
      @views.container(
        @views.row(
          [
            @views.container(
              @views.lucide_icon(
                icon_name,
                size=13.0,
                color=if menu.is_command { accent_amber } else { fg_secondary },
                stroke_width=1.8,
              ),
              width=24.0,
              height=24.0,
              background=if menu.is_command {
                @graphics.Color::rgba(
                  r=251.0 / 255.0,
                  g=191.0 / 255.0,
                  b=36.0 / 255.0,
                  a=0.10,
                )
              } else {
                white_a(0.06)
              },
              corner_radius=6.0,
              padding=0.0,
            ),
            @views.column(
              [
                clip_left(
                  txt(suggestion.label, 13.0, 500, fg_primary),
                  title_width,
                  17.0,
                ),
                clip_left(
                  txt(suggestion.detail, 10.0, 400, fg_muted),
                  title_width,
                  13.0,
                ),
              ],
              spacing=2.0,
              align=Start,
            ),
            @views.spacer(weight=1.0),
          ],
          spacing=10.0,
          align=Center,
        ).frame(width=row_width, height=38.0),
        width=row_width,
        height=42.0,
        background=if hovered {
          white_a(0.06)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=8.0,
        padding=0.0,
      )
      .on_tap(on_pick(suggestion.insert))
      .on_hover(fn(entered) {
        if entered {
          SetComposerPick(index)
        } else {
          Noop
        }
      }),
    )
    index = index + 1
  }
  let content = @views.column(
    [
      header,
      @views.divider(color=white_a(0.07), thickness=1.0),
      @views.column(rows, spacing=0.0, align=Stretch),
    ],
    spacing=6.0,
    align=Stretch,
  ).frame(width=row_width)
  @views.container(
    @views.padding_edges(content, left=6.0, right=6.0, top=6.0, bottom=6.0),
    width~,
    height=composer_menu_height(menu),
    background=@graphics.Color::from_argb(0xFF1D1D1D),
    corner_radius=12.0,
    border=Some(border_of(white_a(0.12), 1.0)),
    padding=0.0,
  )
}

///|
/// Composer mic button for the deterministic local dictation demo. The outer
/// footprint matches the icon so footer spacing is unchanged; the active and
/// hover states tint the same 20/16/15 px slot.
fn dictation_mic(
  size : Double,
  target : Int32,
  active : Bool,
  hovered : Bool,
  key : String,
) -> @moui.View[Msg] {
  @views.container(
    mic_icon(size, if active { accent_amber } else { fg_secondary }),
    width=size,
    height=size,
    background=if active {
      @graphics.Color::from_argb(0x2EFBBF24)
    } else if hovered {
      white_a(0.06)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=size * 0.32,
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(key, entered) })
  .on_tap(Dictate(target))
}

///|
/// The Orca composer: input, access chip, model selector, mic and send.
fn composer(model : Model, width : Double) -> @moui.View[Msg] {
  let field_width = width - 16.0
  let compact = composer_footer_compact(width)
  let submit = match composer_menu_active(model) {
    Some(menu) => ComposerPick(composer_accept_index(model, menu))
    None => Send
  }
  let field = @views.text_field(
    model.draft,
    on_input=fn(text) { DraftInput(text) },
    on_submit=Some(submit),
    key="composer",
    placeholder=composer_placeholder(field_width),
    style=composer_field_style(),
    width=field_width,
    height=38.0,
  )
  let access = @views.row(
    [
      shield_alert_icon(18.0, access_color(model.composer_access)),
      txt(
        if compact {
          composer_access_short_label(model.composer_access)
        } else {
          composer_access_label(model.composer_access)
        },
        15.0,
        500,
        access_color(model.composer_access),
      ),
      @views.lucide_icon(
        "chevron-down",
        size=14.0,
        color=access_color(model.composer_access),
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).on_tap(CycleAccess)
  let model_picker = @views.row(
    [
      txt(composer_model_label(model.composer_model), 15.0, 400, fg_secondary),
      @views.lucide_icon(
        "chevron-down",
        size=14.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).on_tap(CycleComposerModel)
  let send_hovered = model.hover == "composer-send"
  let send_bg = if send_hovered {
    @graphics.Color::from_argb(0xFF969696)
  } else {
    bg_send
  }
  let send_alpha = if send_hovered { 0.16 } else { 0.05 }
  let send_border = border_of(white_a(send_alpha), 1.0)
  let send = @views.container(
      arrow_up_icon(18.0, @graphics.Color::from_argb(0xFF1D1D1D)),
      width=40.0,
      height=40.0,
      background=send_bg,
      corner_radius=20.0,
      border=Some(send_border),
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover("composer-send", entered) })
    .on_tap(Send)
  let footer_items : Array[@moui.View[Msg]] = []
  if !compact {
    let plus_hovered = model.hover == "composer-plus"
    footer_items.push(
      @views.container(
        @views.lucide_icon(
          "plus",
          size=20.0,
          color=fg_secondary,
          stroke_width=1.8,
        ),
        width=20.0,
        height=28.0,
        background=if plus_hovered {
          white_a(0.06)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=7.0,
        padding=0.0,
      )
      .on_hover(fn(entered) { Hover("composer-plus", entered) })
      .on_tap(DraftInput(composer_mention_trigger(model.draft))),
    )
  }
  footer_items.push(access)
  footer_items.push(@views.spacer(weight=1.0))
  footer_items.push(model_picker)
  if !compact {
    footer_items.push(
      dictation_mic(
        20.0,
        dictation_main,
        model.dictation_target == dictation_main,
        model.hover == "composer-mic",
        "composer-mic",
      ),
    )
  }
  footer_items.push(send)
  let footer_spacing = if compact { 6.0 } else { 12.0 }
  let footer_inset = if compact { 8.0 } else { 12.0 }
  let footer_left = if compact { 6.0 } else { 8.0 }
  let footer_right = if compact { 2.0 } else { 4.0 }
  let footer_content = @views.row(
    footer_items,
    spacing=footer_spacing,
    align=Center,
  ).frame(width=field_width - footer_inset)
  let footer = @views.padding_edges(
    footer_content,
    left=footer_left,
    right=footer_right,
  )
  @views.container(
    @views.column([field, footer], spacing=23.0, align=Stretch).frame(
      width=field_width,
    ),
    background=bg_field,
    corner_radius=14.0,
    border=Some(composer_border()),
    padding=8.0,
  )
}
