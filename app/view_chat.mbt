///|
/// The full transcript for the active worktree.
fn transcript(model : Model, width : Double) -> @moui.View[Msg] {
  match find_worktree(model, model.active) {
    None => @views.empty()
    Some(worktree) => {
      let content_width = if width - 64.0 > 540.0 { 540.0 } else { width - 64.0 }
      let blocks : Array[@moui.View[Msg]] = []
      let mut index = 0
      for block in worktree.transcript {
        blocks.push(block_view(worktree.id, block, index, content_width))
        index = index + 1
      }
      @views.padding_edges(
        @views.column(blocks, spacing=20.0, align=Center).frame(width=content_width),
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
) -> @moui.View[Msg] {
  match block {
    UserMessage(text) => user_bubble(text, width)
    AssistantMessage(text) => paragraph(text, width, 15.0, 400, 21.0, fg_body)
    Worked(row) => worked_row(worktree_id, row, index, width)
    Worker(card) => worker_card(card, width)
    LiveRow(label, text) => live_row(label, text, width)
  }
}

///|
/// Right-aligned user bubble.
fn user_bubble(text : String, width : Double) -> @moui.View[Msg] {
  let bubble_width = width * 0.82
  let bubble = @views.container(
    @views.padding_edges(
      paragraph(text, bubble_width - 28.0, 15.0, 400, 21.0, fg_bubble),
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
        txt(row.label, 13.0, 400, fg_muted),
        @views.lucide_icon("chevron-right", size=12.0, color=fg_muted, stroke_width=1.8),
        @views.spacer(weight=1.0),
      ],
      spacing=4.0,
      align=Center,
    ),
  ]
  if row.expanded {
    items.push(paragraph(row.body, width, 15.0, 400, 21.0, fg_body))
  }
  items.push(@views.divider(color=white_a(0.07), thickness=1.0))
  @views.column(items, spacing=10.0, align=Stretch)
  .frame(width=width)
  .on_tap(ToggleWorked(worktree_id, index))
}

///|
/// Worker progress card; the focused card carries the outer white ring.
fn worker_card(card : WorkerCard, width : Double) -> @moui.View[Msg] {
  let card_width = if card.focused { width - 6.0 } else { width }
  let header = @views.row(
    [
      brand_icon(card.kind, 15.0),
      txt("Update from worker", 14.0, 500, fg_primary),
      txt(card.name, 13.0, 400, fg_muted),
      arrow_up_right_icon(12.0, fg_dim),
      @views.spacer(weight=1.0),
      txt(card.time, 12.0, 400, fg_muted),
      @views.lucide_icon("chevron-up", size=14.0, color=fg_muted, stroke_width=1.8),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=card_width - 24.0)
  let body = paragraph(card.body, card_width - 24.0, 15.0, 400, 21.0, fg_body)
  let inner = @views.container(
    @views.column([header, body], spacing=8.0, align=Start)
    .frame(width=card_width - 24.0),
    width=card_width,
    background=bg_card,
    corner_radius=14.0,
    border=if card.focused {
      Some(border_of(white_a(0.32), 1.0))
    } else {
      Some(border_of(white_a(0.07), 1.0))
    },
    padding=12.0,
  )
  if card.focused {
    @views.container(
      inner,
      width=width,
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
          txt(label, 13.0, 400, fg_dim),
          @views.lucide_icon("chevron-right", size=12.0, color=fg_dim, stroke_width=1.8),
          @views.spacer(weight=1.0),
        ],
        spacing=4.0,
        align=Center,
      ),
      @views.divider(color=white_a(0.06), thickness=1.0),
      @views.row(
        [loader_icon(14.0, fg_muted), txt(text, 15.0, 400, fg_muted)],
        spacing=8.0,
        align=Center,
      ),
    ],
    spacing=10.0,
    align=Stretch,
  ).frame(width=width)
}

///|
/// Composer column, centered under the transcript.
fn composer_area(model : Model, main_width : Double) -> @moui.View[Msg] {
  let padded_width = main_width - 64.0
  let composer_width = if padded_width > 550.0 { 550.0 } else { padded_width }
  let inner = @views.row(
    [
      @views.spacer(weight=1.0),
      composer(model, composer_width),
      @views.spacer(weight=1.0),
    ],
    spacing=0.0,
    align=Center,
  ).frame(width=padded_width)
  @views.padding_edges(
    inner,
    top=16.0,
    bottom=24.0,
    left=32.0,
    right=32.0,
  )
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
    font=sans_lh(15.0, 400, 21.0),
  )
}

///|
/// The Orca composer: input, access chip, model selector, mic and send.
fn composer(model : Model, width : Double) -> @moui.View[Msg] {
  let field_width = width - 12.0
  let field = @views.text_field(
    model.draft,
    on_input=fn(text) { DraftInput(text) },
    on_submit=Some(Send),
    key="composer",
    placeholder="Ask anything, @ to mention files, / for commands",
    style=composer_field_style(),
    width=field_width,
    height=48.0,
  )
  let access = @views.row(
    [
      shield_alert_icon(14.0, accent_full_access),
      txt("Full access", 13.0, 500, accent_full_access),
      @views.lucide_icon("chevron-down", size=12.0, color=accent_full_access, stroke_width=1.8),
    ],
    spacing=5.0,
    align=Center,
  )
  let send = @views.container(
    arrow_up_icon(16.0, fg_primary),
    width=32.0,
    height=32.0,
    background=bg_send,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.07), 1.0)),
    padding=0.0,
  ).on_tap(Send)
  let footer_content = @views.row(
    [
      @views.lucide_icon("plus", size=16.0, color=fg_secondary, stroke_width=1.8),
      access,
      @views.spacer(weight=1.0),
      txt("Opus 5.5", 14.0, 400, fg_secondary),
      @views.lucide_icon("chevron-down", size=12.0, color=fg_muted, stroke_width=1.8),
      mic_icon(16.0, fg_secondary),
      send,
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=field_width - 12.0)
  let footer = @views.padding_edges(footer_content, left=8.0, right=4.0)
  @views.container(
    @views.column([field, footer], spacing=4.0, align=Stretch)
    .frame(width=field_width),
    background=bg_card,
    corner_radius=14.0,
    border=Some(composer_border()),
    padding=6.0,
  )
}
