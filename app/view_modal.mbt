///|
/// Modal field style: flat, 17.5 px, muted placeholder.
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
    font=sans(17.5, 400),
  )
}

///|
/// Card width for the create-worktree and automation dialogs: 550 px when
/// the viewport has room, otherwise the viewport minus a 16 px gutter.
pub fn overlay_card_width(viewport_w : Double) -> Double {
  let available = if viewport_w - 32.0 > 0.0 { viewport_w - 32.0 } else { 0.0 }
  if available < 550.0 {
    available
  } else {
    550.0
  }
}

///|
/// Stack dialog actions when a side-by-side footer would touch the card edge.
pub fn overlay_footer_compact(content_w : Double) -> Bool {
  content_w < 320.0
}

///|
/// Collapse the Advanced body when the viewport cannot fit the full dialog.
pub fn modal_advanced_compact(viewport_h : Double) -> Bool {
  viewport_h < 680.0
}

///|
/// Stack the Create From options two-up when a single row would clip labels.
pub fn modal_chips_stack(content_w : Double) -> Bool {
  content_w < 360.0
}

///|
/// Card width for the keyboard-shortcuts overlay.
pub fn help_card_width(viewport_w : Double) -> Double {
  let available = if viewport_w - 32.0 > 0.0 { viewport_w - 32.0 } else { 0.0 }
  if available < 460.0 {
    available
  } else {
    460.0
  }
}

///|
/// The full shortcut sentences fit from a 330 px content column; below that
/// the card trims each label instead of letting it run into the window edge.
pub fn help_labels_compact(content_w : Double) -> Bool {
  content_w < 330.0
}

///|
/// Shortcut copy, trimmed at narrow card widths while keeping the action.
pub fn help_shortcut_labels(compact : Bool) -> Array[String] {
  if compact {
    [
      "Open Search", "Back to Projects", "Go back or forward", "Show or hide sidebar",
      "Switch worktree tab", "Bots panel tab", "Close worktree tab", "Create or save",
      "Open selected row", "Move through lists", "Extend note range", "Close dialog or note",
    ]
  } else {
    [
      "Open Search from any screen", "Back to Projects", "Go back or forward", "Show or hide the sidebar",
      "Switch to an open worktree tab", "Switch the Bots item panel", "Close the active Projects tab",
      "Create a worktree or save an edit", "Open the selected result or row", "Move through lists or diff lines",
      "Extend a diff note range", "Close a dialog, note, filter or edit",
    ]
  }
}

///|
/// Key chips stay on one line; only the label column changes at narrow widths.
fn help_shortcut_keys() -> Array[String] {
  [
    "⌘K", "⌘P", "⌘[  ⌘]", "⌘B", "⌘1–9", "⌘⌥1–4", "⌘W", "⌘↵",
    "↵", "↑ ↓", "⇧↑ ⇧↓", "esc",
  ]
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
    width~,
    height~,
    background=black_a(0.60),
    padding=0.0,
  )
  let overlay = @views.container(
    @views.column(
      [modal_card(model, width, height)],
      spacing=0.0,
      justify=Center,
      align=Center,
    ).frame(width~, height~),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseModal)
  @views.stack([scrim, overlay])
}

///|
/// Full-screen scrim plus the centered keyboard-shortcuts card.
pub fn help_modal(width : Double, height : Double) -> @moui.View[Msg] {
  let scrim = @views.container(
    @views.empty(),
    width~,
    height~,
    background=black_a(0.60),
    padding=0.0,
  )
  let overlay = @views.container(
    @views.column([help_card(width)], spacing=0.0, justify=Center, align=Center).frame(
      width~,
      height~,
    ),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(ToggleHelp)
  @views.stack([scrim, overlay])
}

///|
/// Dialog action button. `kind` is 0 for secondary, 1 for primary and 2 for a
/// destructive confirm.
fn dialog_button(
  model : Model,
  label : String,
  kind : Int32,
  action : Msg,
) -> @moui.View[Msg] {
  let id = "dialog-\{label}"
  let hovered = model.hover == id
  let background = if kind == 1 {
    if hovered {
      @graphics.Color::from_argb(0xFFE3E3E3)
    } else {
      fg_primary
    }
  } else if kind == 2 {
    if hovered {
      @graphics.Color::from_argb(0xFFFF8A8A)
    } else {
      fg_diff_del
    }
  } else if hovered {
    white_a(0.05)
  } else {
    @graphics.Color::transparent()
  }
  let foreground = if kind == 0 { fg_body } else { bg_outer }
  let border = if kind == 0 {
    Some(border_of(white_a(0.12), 1.0))
  } else {
    None
  }
  @views.container(
    @views.padding_edges(
      @views.row(
        [txt(label, 13.0, 500, foreground), @views.spacer(weight=1.0)],
        spacing=0.0,
        align=Center,
      ).frame(width=78.0),
      left=14.0,
      right=14.0,
    ),
    height=36.0,
    background~,
    corner_radius=8.0,
    border~,
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(action)
}

///|
/// Dimmed, inert dialog action used while its input is still incomplete.
fn dialog_button_disabled(label : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      @views.row(
        [txt(label, 13.0, 500, fg_muted), @views.spacer(weight=1.0)],
        spacing=0.0,
        align=Center,
      ).frame(width=78.0),
      left=14.0,
      right=14.0,
    ),
    height=36.0,
    background=white_a(0.14),
    corner_radius=8.0,
    padding=0.0,
  )
}

///|
/// Shared scrim plus centered dialog column for the small worktree dialogs.
fn dialog_shell(
  card : @moui.View[Msg],
  width : Double,
  height : Double,
  dismiss : Msg,
) -> @moui.View[Msg] {
  let scrim = @views.container(
    @views.empty(),
    width~,
    height~,
    background=black_a(0.60),
    padding=0.0,
  )
  let overlay = @views.container(
    @views.column([card], spacing=0.0, justify=Center, align=Center).frame(
      width~,
      height~,
    ),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(dismiss)
  @views.stack([scrim, overlay])
}

///|
/// Card width for the rename/delete dialogs.
pub fn dialog_card_width(viewport_w : Double) -> Double {
  let available = if viewport_w - 32.0 > 0.0 { viewport_w - 32.0 } else { 0.0 }
  if available < 440.0 {
    available
  } else {
    440.0
  }
}

///|
/// Rename-worktree dialog: one focused name field plus Cancel / Rename.
pub fn rename_worktree_modal(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let card_w = dialog_card_width(width)
  let content_w = card_w - 48.0
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(CancelRename)
  let header = @views.row(
    [
      txt("Rename worktree", 18.0, 600, fg_primary),
      @views.spacer(weight=1.0),
      close,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let field = @views.text_field(
    model.rename_draft,
    on_input=fn(text) { RenameDraftInput(text) },
    on_submit=Some(CommitRename),
    on_cancel=CancelRename,
    key="rename-worktree",
    placeholder="Worktree name",
    style=modal_field_style(),
    width=content_w - 30.0,
    height=40.0,
  )
  let field_content = @views.row(
    [
      @views.lucide_icon("pencil", size=14.0, color=fg_muted, stroke_width=1.7),
      field,
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w - 28.0)
  let field_control = @views.container(
    @views.padding_edges(field_content, left=14.0, right=14.0),
    width=content_w,
    height=40.0,
    background=@graphics.Color::transparent(),
    corner_radius=10.0,
    border=Some(border_of(white_a(0.12), 1.0)),
    padding=0.0,
  )
  let rename_blocked = rename_save_blocked(model)
  let field_items : Array[@moui.View[Msg]] = [field_control]
  if rename_blocked {
    field_items.push(txt("Type a name to rename", 11.0, 400, accent_amber))
  }
  let field_block = @views.column(field_items, spacing=6.0, align=Start).frame(
    width=content_w,
  )
  let hint = paragraph(
    "This updates the sidebar row and its tab. The branch name stays the same.",
    content_w, 12.0, 400, 18.0, fg_dim,
  )
  let footer = @views.row(
    [
      @views.spacer(weight=1.0),
      dialog_button(model, "Cancel", 0, CancelRename),
      if rename_blocked {
        dialog_button_disabled("Rename")
      } else {
        dialog_button(model, "Rename", 1, CommitRename)
      },
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let card = @views.container(
    @views.column(
      [header, field_block, hint, footer],
      spacing=16.0,
      align=Start,
    ).frame(width=content_w),
    background=bg_outer,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.05), 1.0)),
    padding=24.0,
  ).on_tap(Noop)
  dialog_shell(card, width, height, CancelRename)
}

///|
/// Delete confirmation: names the worktree and spells out what closes.
pub fn delete_worktree_modal(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let card_w = dialog_card_width(width)
  let content_w = card_w - 48.0
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(CancelDeleteWorktree)
  let header = @views.row(
    [
      txt("Delete worktree", 18.0, 600, fg_primary),
      @views.spacer(weight=1.0),
      close,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let (name, branch) = match find_worktree(model, model.delete_target) {
    Some(worktree) => (worktree.name, worktree.branch)
    None => ("this worktree", "")
  }
  let subject_items = [txt(name, 13.0, 500, fg_primary)]
  if branch != "" {
    subject_items.push(txt(branch, 12.0, 400, fg_dim))
  }
  let subject = @views.column(subject_items, spacing=2.0, align=Start).frame(
    width=content_w,
  )
  let body = paragraph(
    "Its tab closes, task links are cleared, and it stays deleted after a restart.",
    content_w, 12.0, 400, 18.0, fg_dim,
  )
  let footer = @views.row(
    [
      @views.spacer(weight=1.0),
      dialog_button(model, "Cancel", 0, CancelDeleteWorktree),
      dialog_button(model, "Delete", 2, ConfirmDeleteWorktree),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let card = @views.container(
    @views.column([header, subject, body, footer], spacing=14.0, align=Start).frame(
      width=content_w,
    ),
    background=bg_outer,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.05), 1.0)),
    padding=24.0,
  ).on_tap(Noop)
  dialog_shell(card, width, height, CancelDeleteWorktree)
}

///|
fn shortcut_chip(keys : String) -> @moui.View[Msg] {
  @views.container(
    @views.padding_edges(
      @views.text(keys).font(mono(11.0, 500)).foreground(fg_secondary),
      left=7.0,
      right=7.0,
      top=3.0,
      bottom=3.0,
    ),
    background=white_a(0.06),
    corner_radius=6.0,
    border=Some(border_of(white_a(0.09), 1.0)),
    padding=0.0,
  )
}

///|
fn shortcut_row(
  keys : String,
  label : String,
  content_w : Double,
) -> @moui.View[Msg] {
  let key_w = if content_w - 160.0 > 92.0 {
    92.0
  } else if content_w - 160.0 > 56.0 {
    content_w - 160.0
  } else {
    56.0
  }
  @views.row(
    [
      @views.row(
        [shortcut_chip(keys), @views.spacer(weight=1.0)],
        spacing=0.0,
        align=Start,
      ).frame(width=key_w),
      txt(label, 13.0, 400, fg_body),
      @views.spacer(weight=1.0),
    ],
    spacing=12.0,
    align=Center,
  ).frame(width=content_w, height=28.0)
}

///|
fn help_card(viewport_w : Double) -> @moui.View[Msg] {
  let card_w = help_card_width(viewport_w)
  let content_w = card_w - 48.0
  let labels = help_shortcut_labels(help_labels_compact(content_w))
  let keys = help_shortcut_keys()
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(ToggleHelp)
  let header = @views.row(
    [
      txt("Keyboard shortcuts", 20.0, 600, fg_primary),
      @views.spacer(weight=1.0),
      close,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let shortcut_rows : Array[@moui.View[Msg]] = []
  let mut shortcut_index = 0
  while shortcut_index < keys.length() {
    shortcut_rows.push(
      shortcut_row(keys[shortcut_index], labels[shortcut_index], content_w),
    )
    shortcut_index = shortcut_index + 1
  }
  let rows = @views.column(shortcut_rows, spacing=2.0, align=Start)
  let footer = paragraph(
    "Tip: hold Shift with the arrow keys to grow a diff note across lines.", content_w,
    11.0, 400, 17.0, fg_dim,
  )
  @views.container(
    @views.padding_edges(
      @views.column([header, rows, footer], spacing=18.0, align=Start).frame(
        width=content_w,
      ),
      left=24.0,
      right=24.0,
      top=22.0,
      bottom=22.0,
    ),
    background=bg_card,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=0.0,
  ).on_tap(Noop)
}

///|
/// True when the Name source is selected and the field is still blank; the
/// primary button stays visibly disabled until a name is typed.
pub fn modal_create_blocked(model : Model) -> Bool {
  model.modal_from == 3 && model.modal_name.trim_space().to_string() == ""
}

///|
/// The 550 px create-worktree dialog.
fn modal_card(
  model : Model,
  viewport_w : Double,
  viewport_h : Double,
) -> @moui.View[Msg] {
  let card_w = overlay_card_width(viewport_w)
  let content_w = card_w - 48.0
  let advanced_compact = modal_advanced_compact(viewport_h)
  let field_w = (content_w - 16.0) / 2.0
  let close = @views.container(
    x_icon(16.0, fg_muted),
    width=24.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(CloseModal)
  let header = @views.row(
    [
      txt("Create worktree", 21.0, 600, fg_primary),
      @views.spacer(weight=1.0),
      close,
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let fields = @views.padding_edges(
    @views.row(
      [
        select_field(
          model,
          "Project",
          folder_icon(16.0, accent_folder),
          modal_target_project(model.modal_target),
          CycleTarget,
          field_w,
        ),
        select_field(
          model,
          "Run on",
          @views.lucide_icon(
            "server",
            size=16.0,
            color=fg_muted,
            stroke_width=1.7,
          ),
          modal_target_host(model.modal_target),
          CycleTarget,
          field_w,
        ),
      ],
      spacing=16.0,
      align=Start,
    ).frame(width=content_w),
    top=9.0,
  )
  let from_label = txt("Create From [Optional]", 15.75, 400, fg_secondary)
  let chip_cap = (content_w - 24.0) / 4.0
  let chip_w0 = if chip_cap < 80.0 { chip_cap } else { 80.0 }
  let chip_w1 = if chip_cap < 88.0 { chip_cap } else { 88.0 }
  let chip_w2 = if chip_cap < 89.0 { chip_cap } else { 89.0 }
  let chip_w3 = if chip_cap < 80.0 { chip_cap } else { 80.0 }
  let stack = modal_chips_stack(content_w)
  let stacked_w = if content_w - 8.0 > 0.0 {
    (content_w - 8.0) / 2.0
  } else {
    0.0
  }
  let w0 = if stack { stacked_w } else { chip_w0 }
  let w1 = if stack { stacked_w } else { chip_w1 }
  let w2 = if stack { stacked_w } else { chip_w2 }
  let w3 = if stack { stacked_w } else { chip_w3 }
  let smart = chip(model, 0, "Smart", sparkles_icon(16.0, fg_primary), w0)
  let github = chip(model, 1, "GitHub", code_icon(18.0, fg_muted), w1)
  let branch = chip(
    model,
    2,
    "Branch",
    @views.lucide_icon(
      "git-branch",
      size=16.0,
      color=fg_muted,
      stroke_width=1.8,
    ),
    w2,
  )
  let name = chip(
    model,
    3,
    "Name",
    @views.padding_edges(txt("T", 20.0, 600, fg_muted), right=2.75),
    w3,
  )
  let chips = if stack {
    @views.column(
      [
        @views.row([smart, github], spacing=8.0, align=Center).frame(
          width=content_w,
        ),
        @views.row([branch, name], spacing=8.0, align=Center).frame(
          width=content_w,
        ),
      ],
      spacing=6.0,
      align=Start,
    )
  } else {
    @views.row([smart, github, branch, name], spacing=8.0, align=Center)
  }
  let chips_block = @views.column([from_label, chips], spacing=7.5, align=Start)
  let name_blocked = modal_create_blocked(model)
  let name_field_w = if overlay_footer_compact(content_w) {
    content_w - 78.0
  } else {
    content_w - 50.0
  }
  let name_row = @views.text_field(
    model.modal_name,
    on_input=fn(text) { NameInput(text) },
    on_submit=Some(CreateWorktree),
    on_cancel=CloseModal,
    key="modal-name",
    placeholder=if model.modal_from == 3 {
      "Name your worktree"
    } else {
      "Speed up checkout CI"
    },
    style=modal_field_style(),
    width=name_field_w,
    height=52.0,
  )
  let name_content = @views.row(
    [
      @views.lucide_icon("search", size=16.0, color=fg_muted, stroke_width=1.8),
      name_row,
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w - 28.0)
  let name_control = @views.container(
    @views.padding_edges(name_content, left=14.0, right=14.0),
    width=content_w,
    height=52.0,
    background=@graphics.Color::transparent(),
    corner_radius=10.0,
    border=Some(
      border_of(
        if model.modal_from == 3 {
          white_a(0.20)
        } else {
          white_a(0.12)
        },
        1.0,
      ),
    ),
    padding=0.0,
  )
  let name_items : Array[@moui.View[Msg]] = [name_control]
  if name_blocked {
    name_items.push(txt("Type a name to continue", 11.0, 400, accent_amber))
  }
  let name_block = @views.column(name_items, spacing=6.0, align=Start)
  let from_block = @views.padding_edges(
    @views.column([chips_block, name_block], spacing=9.0, align=Start),
    top=10.0,
  )
  let agent_label_row = @views.row(
    [
      txt("Agent [Optional]", 16.0, 400, fg_secondary),
      @views.spacer(weight=1.0),
      sliders_icon(16.0, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w)
  let agent_content = @views.row(
    [
      brand_icon(modal_agent_kind(model.modal_agent), 17.0),
      txt(modal_agent_label(model.modal_agent), 18.5, 400, fg_primary),
      @views.spacer(weight=1.0),
      @views.lucide_icon(
        "chevron-down",
        size=14.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=content_w - 22.0)
  let agent_control = @views.container(
    @views.padding_edges(agent_content, left=12.0, right=10.0),
    width=content_w,
    height=46.0,
    background=white_a(0.05),
    corner_radius=10.0,
    border=Some(border_of(white_a(0.06), 1.0)),
    padding=0.0,
  ).on_tap(CycleAgent)
  let agent_block = @views.padding_edges(
    @views.column([agent_label_row, agent_control], spacing=8.5, align=Start),
    top=0.5,
  )
  let advanced_header = @views.row(
      [
        txt("Advanced", 14.5, 500, fg_primary),
        @views.lucide_icon(
          if model.modal_advanced {
            "chevron-up"
          } else {
            "chevron-down"
          },
          size=14.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        @views.spacer(weight=1.0),
      ],
      spacing=6.0,
      align=Center,
    )
    .frame(width=content_w)
    .on_tap(ToggleAdvanced)
  let advanced_items : Array[@moui.View[Msg]] = [advanced_header]
  if model.modal_advanced {
    let base_branch = modal_base_branch_label(model.modal_base_branch)
    let base_hovered = model.hover == "modal-base-branch"
    let base_h = if advanced_compact { 26.0 } else { 36.0 }
    let base_content = @views.row(
      [
        @views.lucide_icon(
          "git-branch",
          size=14.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
        txt("Base branch", 13.0, 400, fg_secondary),
        @views.spacer(weight=1.0),
        txt(base_branch, 13.5, 500, fg_primary),
        chevrons_up_down_icon(13.0, fg_muted),
      ],
      spacing=8.0,
      align=Center,
    ).frame(width=content_w - 22.0)
    let base_control = @views.container(
        @views.padding_edges(base_content, left=12.0, right=10.0),
        width=content_w,
        height=base_h,
        background=if base_hovered { white_a(0.08) } else { white_a(0.05) },
        corner_radius=if advanced_compact { 7.0 } else { 9.0 },
        border=Some(
          border_of(
            if base_hovered {
              white_a(0.10)
            } else {
              white_a(0.06)
            },
            1.0,
          ),
        ),
        padding=0.0,
      )
      .on_hover(fn(entered) { Hover("modal-base-branch", entered) })
      .on_tap(CycleBaseBranch)
    advanced_items.push(base_control)
    if !advanced_compact {
      advanced_items.push(
        paragraph(
          "New worktrees start from \{base_branch}.",
          content_w,
          12.0,
          400,
          18.0,
          fg_dim,
        ),
      )
    }
  }
  let advanced = @views.column(
    advanced_items,
    spacing=if advanced_compact { 6.0 } else { 8.0 },
    align=Start,
  ).offset(dx=-6.0)
  let advanced_block = @views.padding_edges(advanced, top=3.25)
  let create_hovered = model.hover == "modal-create" && !name_blocked
  let create_bg = if name_blocked {
    white_a(0.14)
  } else if create_hovered {
    @graphics.Color::from_argb(0xFFE3E3E3)
  } else {
    fg_primary
  }
  let create_w = if content_w < 188.0 { content_w } else { 188.0 }
  let create_button = @views.container(
      @views.padding_edges(
        @views.row(
          [
            txt(
              "Create worktree",
              16.0,
              500,
              if name_blocked {
                fg_muted
              } else {
                bg_card
              },
            ),
            txt(
              "⌘↵",
              13.0,
              400,
              if name_blocked {
                fg_dim
              } else {
                fg_inverse_muted
              },
            ),
          ],
          spacing=10.0,
          justify=Center,
          align=Center,
        ).frame(width=create_w - 24.0),
        left=12.0,
        right=12.0,
      ),
      width=create_w,
      height=40.0,
      background=create_bg,
      corner_radius=8.0,
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover("modal-create", entered) })
    .on_tap(CreateWorktree)
  let toggle = toggle_control(model.create_more)
  let create_more = @views.container(
    @views.padding_edges(
      @views.row(
        [toggle, txt("Create more", 16.0, 400, fg_secondary)],
        spacing=12.0,
        align=Center,
      ),
      right=6.0,
    ),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(ToggleCreateMore)
  let footer = if overlay_footer_compact(content_w) {
    @views.column([create_more, create_button], spacing=8.0, align=End).frame(
      width=content_w,
    )
  } else {
    @views.row(
      [create_more, @views.spacer(weight=1.0), create_button],
      spacing=8.0,
      align=Center,
    ).frame(width=content_w)
  }
  let footer_block = @views.padding_edges(footer, top=3.0)
  @views.container(
    @views.column(
      [header, fields, from_block, agent_block, advanced_block, footer_block],
      spacing=18.0,
      align=Start,
    ).frame(width=content_w),
    background=bg_outer,
    corner_radius=16.0,
    border=Some(border_of(white_a(0.05), 1.0)),
    padding=24.0,
  ).on_tap(Noop)
}

///|
/// Label plus 40 px select control for the modal's top row.
fn select_field(
  model : Model,
  label : String,
  icon : @moui.View[Msg],
  value : String,
  message : Msg,
  width : Double,
  icon_width~ : Double = 16.0,
) -> @moui.View[Msg] {
  let id = "modal-select-\{label}"
  let hovered = model.hover == id
  let content = @views.row(
    [
      icon,
      clip_left(
        txt(value, 17.5, 400, fg_primary),
        select_value_width(width, icon_width),
        26.0,
      ),
      @views.spacer(weight=1.0),
      chevrons_up_down_icon(14.0, fg_muted),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 22.0)
  let control_bg = if hovered { white_a(0.08) } else { white_a(0.05) }
  let control_border = if hovered { white_a(0.10) } else { white_a(0.06) }
  let control = @views.container(
      @views.padding_edges(content, left=12.0, right=10.0),
      width~,
      height=46.0,
      background=control_bg,
      corner_radius=10.0,
      border=Some(border_of(control_border, 1.0)),
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover(id, entered) })
    .on_tap(message)
  @views.column(
    [txt(label, 15.0, 400, fg_secondary), control],
    spacing=3.0,
    align=Start,
  ).frame(width~)
}

///|
/// Room left for a select value once the 12 + 10 px padding, leading icon,
/// 14 px chevron and three 8 px gaps are removed. Clipping the value here
/// keeps the chevron inside the 112 px phone-width field instead of letting
/// the whole row paint past the dialog card.
pub fn select_value_width(width : Double, icon_width : Double) -> Double {
  let raw = width - 22.0 - icon_width - 14.0 - 24.0
  if raw < 0.0 {
    0.0
  } else {
    raw
  }
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
  let id = "modal-chip-\{index}"
  let hovered = model.hover == id
  let content = @views.row(
    [
      icon,
      txt(label, 15.0, 500, if selected { fg_primary } else { fg_muted }),
      @views.spacer(weight=1.0),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 1.0)
  let rule_w = if width - 13.0 < 8.0 { 8.0 } else { width - 13.0 }
  let inner = if selected {
    @views.column(
      [
        content,
        @views.container(
          @views.empty(),
          width=rule_w,
          height=2.0,
          background=fg_primary,
          corner_radius=1.0,
          padding=0.0,
        ),
      ],
      spacing=0.0,
      align=Start,
    )
  } else {
    content
  }
  @views.container(
    @views.padding_edges(inner, left=1.0, right=0.0),
    width~,
    height=28.0,
    background=if hovered {
      white_a(0.05)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=8.0,
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(SelectCreateFrom(index))
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
  )
}
