///|
/// Modal field style: flat, 13 px, muted placeholder.
fn modal_field_style() -> @style.TextFieldStyle {
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
    placeholder_color=fg_dim,
    cursor_color=fg_primary,
    font=sans(14.0, 400),
  )
}

///|
/// Full-screen scrim plus the centered create-worktree card.
pub fn create_worktree_modal(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let scrim = @views.container(
    @views.empty(),
    width=width,
    height=height,
    background=black_a(0.60),
    padding=0.0,
  )
  let overlay = @views.container(
    @views.column([modal_card(model)], spacing=0.0, justify=Center, align=Center)
    .frame(width=width, height=height),
    width=width,
    height=height,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseModal)
  @views.stack([scrim, overlay])
}

///|
/// The 550 px create-worktree dialog.
fn modal_card(model : Model) -> @moui.View[Msg] {
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(CloseModal)
  let header = @views.row(
    [txt("Create worktree", 20.0, 600, fg_primary), @views.spacer(weight=1.0), close],
    spacing=8.0,
    align=Center,
  ).frame(width=502.0)
  let fields = @views.row(
    [
      select_field("Project", folder_icon(14.0, accent_folder), "acme-internal"),
      select_field("Run on", @views.lucide_icon("server", size=14.0, color=fg_muted, stroke_width=1.7), "mac-mini"),
    ],
    spacing=16.0,
    align=Start,
  ).frame(width=502.0)
  let from_label = txt("Create From [Optional]", 13.0, 400, fg_secondary)
  let chips = @views.row(
    [
      chip(model, 0, "Smart", sparkles_icon(13.0, fg_primary), 82.0),
      chip(model, 1, "GitHub", code_icon(13.0, fg_muted), 94.0),
      chip(model, 2, "Branch", @views.lucide_icon("git-branch", size=13.0, color=fg_muted, stroke_width=1.8), 90.0),
      chip(model, 3, "Name", txt("T", 12.0, 600, fg_muted), 80.0),
    ],
    spacing=8.0,
    align=Center,
  )
  let name_label = txt("Name", 13.0, 400, fg_secondary)
  let name_row = @views.text_field(
    model.modal_name,
    on_input=fn(text) { NameInput(text) },
    on_submit=Some(CreateWorktree),
    on_cancel=CloseModal,
    key="modal-name",
    placeholder="Speed up checkout CI",
    style=modal_field_style(),
    width=452.0,
    height=40.0,
  )
  let name_content = @views.row(
    [
      @views.lucide_icon("search", size=14.0, color=fg_muted, stroke_width=1.8),
      name_row,
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=474.0)
  let name_control = @views.container(
    @views.padding_edges(name_content, left=14.0, right=14.0),
    width=502.0,
    height=40.0,
    background=bg_field_focus,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.22), 1.0)),
    padding=0.0,
  )
  let agent_label_row = @views.row(
    [
      txt("Agent [Optional]", 12.0, 400, fg_secondary),
      @views.spacer(weight=1.0),
      sliders_icon(14.0, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=502.0)
  let agent_content = @views.row(
    [
      brand_icon(Claude, 14.0),
      txt("Claude Code", 14.0, 400, fg_primary),
      @views.spacer(weight=1.0),
      @views.lucide_icon("chevron-down", size=12.0, color=fg_muted, stroke_width=1.8),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=480.0)
  let agent_control = @views.container(
    @views.padding_edges(agent_content, left=12.0, right=10.0),
    width=502.0,
    height=40.0,
    background=bg_field,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.08), 1.0)),
    padding=0.0,
  )
  let advanced_items : Array[@moui.View[Msg]] = [
    @views.row(
      [
        txt("Advanced", 14.0, 500, fg_primary),
        @views.lucide_icon(
          if model.modal_advanced { "chevron-up" } else { "chevron-down" },
          size=14.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        @views.spacer(weight=1.0),
      ],
      spacing=6.0,
      align=Center,
    ).frame(width=502.0),
  ]
  if model.modal_advanced {
    advanced_items.push(
      paragraph(
        "Base branch: main. The worktree is created under acme-internal.",
        502.0,
        12.0,
        400,
        18.0,
        fg_muted,
      ),
    )
  }
  let advanced = @views.column(advanced_items, spacing=8.0, align=Start)
  .on_tap(ToggleAdvanced)
  let create_button = @views.container(
    @views.padding_edges(
      @views.row(
        [
          txt("Create worktree", 14.0, 500, bg_card),
          @views.spacer(weight=1.0),
          txt("⌘↵", 12.0, 400, fg_dim),
        ],
        spacing=6.0,
        align=Center,
      ).frame(width=152.0),
      left=12.0,
      right=12.0,
    ),
    width=176.0,
    height=36.0,
    background=fg_primary,
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(CreateWorktree)
  let toggle = toggle_control(model.create_more)
  let footer = @views.row(
    [
      toggle,
      txt("Create more", 13.0, 400, fg_secondary),
      @views.spacer(weight=1.0),
      create_button,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=502.0)
  @views.container(
    @views.column(
      [
        header,
        fields,
        from_label,
        chips,
        name_label,
        name_control,
        agent_label_row,
        agent_control,
        advanced,
        footer,
      ],
      spacing=18.0,
      align=Start,
    ).frame(width=502.0),
    background=bg_card,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=24.0,
  ).on_tap(Noop)
}

///|
/// Label plus 40 px select control for the modal's top row.
fn select_field(
  label : String,
  icon : @moui.View[Msg],
  value : String,
) -> @moui.View[Msg] {
  let content = @views.row(
    [
      icon,
      txt(value, 14.0, 400, fg_primary),
      @views.spacer(weight=1.0),
      chevrons_up_down_icon(12.0, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=221.0)
  let control = @views.container(
    @views.padding_edges(content, left=12.0, right=10.0),
    width=243.0,
    height=40.0,
    background=bg_field,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.08), 1.0)),
    padding=0.0,
  )
  @views.column([txt(label, 13.0, 400, fg_secondary), control], spacing=6.0, align=Start)
  .frame(width=243.0)
}

///|
/// One "Create From" chip.
fn chip(
  model : Model,
  index : Int32,
  label : String,
  icon : @moui.View[Msg],
  width : Double,
) -> @moui.View[Msg] {
  let selected = model.modal_from == index
  let content = @views.row(
    [icon, txt(label, 13.0, 500, if selected { fg_primary } else { fg_muted }), @views.spacer(weight=1.0)],
    spacing=5.0,
    align=Center,
  ).frame(width=width - 20.0)
  @views.container(
    @views.padding_edges(content, left=10.0, right=10.0),
    width=width,
    height=28.0,
    background=@graphics.Color::transparent(),
    corner_radius=8.0,
    padding=0.0,
  ).on_tap(SelectCreateFrom(index))
}

///|
/// Small on/off switch used in the modal footer.
fn toggle_control(on : Bool) -> @moui.View[Msg] {
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
  ).on_tap(ToggleCreateMore)
}
