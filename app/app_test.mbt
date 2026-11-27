///|
test "selecting a worktree opens a tab and swaps the transcript" {
  let model = Model::new()
  inspect(model.tabs.length(), content="1")
  inspect(model.active == "eu-promo-checkout", content="true")
  inspect(transcript_of(model, "eu-promo-checkout").length(), content="5")
  let next = update(model, SelectWorktree("checks-detail-link"))
  inspect(next.tabs.length(), content="2")
  inspect(next.active == "checks-detail-link", content="true")
  inspect(next.tabs[1] == "checks-detail-link", content="true")
  inspect(transcript_of(next, "checks-detail-link").length(), content="3")
  inspect(transcript_of(next, "eu-promo-checkout").length(), content="5")
}

///|
test "closing a tab falls back to the previous tab or the empty state" {
  let model = Model::new()
  let second = update(model, SelectWorktree("agent-handoff-summary"))
  inspect(second.tabs.length(), content="2")
  inspect(second.active == "agent-handoff-summary", content="true")
  let closed = update(second, CloseTab("agent-handoff-summary"))
  inspect(closed.tabs.length(), content="1")
  inspect(closed.active == "eu-promo-checkout", content="true")
  let empty = update(closed, CloseTab("eu-promo-checkout"))
  inspect(empty.tabs.length(), content="0")
  inspect(empty.active == "", content="true")
}

///|
test "tab shortcuts switch between open worktrees" {
  let model = update(Model::new(), SelectWorktree("checks-detail-link"))
  inspect(model.tabs.length(), content="2")
  let first = update(model, SelectTabAt(0))
  inspect(first.active == "eu-promo-checkout", content="true")
  let second = update(model, SelectTabAt(1))
  inspect(second.active == "checks-detail-link", content="true")
  let out_of_range = update(model, SelectTabAt(8))
  inspect(out_of_range.active == "checks-detail-link", content="true")
}

///|
test "the create-worktree modal adds a worktree and opens its tab" {
  let opened = update(Model::new(), OpenModal)
  inspect(opened.modal_open, content="true")
  let typed = update(opened, NameInput("Speed up checkout CI"))
  inspect(typed.modal_name == "Speed up checkout CI", content="true")
  let created = update(typed, CreateWorktree)
  inspect(created.modal_open, content="false")
  inspect(created.tabs.length(), content="2")
  inspect(created.active == "speed-up-checkout-ci", content="true")
  inspect(has_worktree(created, "speed-up-checkout-ci"), content="true")
  inspect(worktree_total(created), content="5")
  let detail_ok = match find_worktree(created, "speed-up-checkout-ci") {
    Some(worktree) =>
      worktree.name == "Speed up checkout CI" &&
      worktree.branch == "feature/speed-up-checkout-ci" &&
      worktree.agents.length() == 1 &&
      worktree.transcript.length() == 3
    None => false
  }
  inspect(detail_ok, content="true")
}

///|
test "advanced base branch selection is recorded in the new worktree" {
  let opened = update(Model::new(), OpenModal)
  inspect(opened.modal_advanced, content="false")
  inspect(
    modal_base_branch_label(opened.modal_base_branch) == "main",
    content="true",
  )
  let expanded = update(opened, ToggleAdvanced)
  inspect(expanded.modal_advanced, content="true")
  let develop = update(expanded, CycleBaseBranch)
  inspect(
    modal_base_branch_label(develop.modal_base_branch) == "develop",
    content="true",
  )
  let release = update(develop, CycleBaseBranch)
  inspect(
    modal_base_branch_label(release.modal_base_branch) == "release/next",
    content="true",
  )
  let wrapped = update(release, CycleBaseBranch)
  inspect(
    modal_base_branch_label(wrapped.modal_base_branch) == "main",
    content="true",
  )
  let created = update(develop, CreateWorktree)
  let body_ok = match find_worktree(created, "speed-up-checkout-ci") {
    Some(worktree) =>
      match worktree.transcript[2] {
        Worker(block) =>
          block.body ==
          "Created the worktree from develop and started a Claude Code worker."
        _ => false
      }
    None => false
  }
  inspect(body_ok, content="true")
  let collapsed = update(expanded, ToggleAdvanced)
  inspect(collapsed.modal_advanced, content="false")
}

///|
test "overlay cards shrink to fit narrow viewports" {
  inspect(overlay_card_width(960.0) == 550.0, content="true")
  inspect(overlay_card_width(500.0) == 468.0, content="true")
  inspect(overlay_footer_compact(319.0), content="true")
  inspect(overlay_footer_compact(320.0), content="false")
  inspect(modal_advanced_compact(600.0), content="true")
  inspect(modal_advanced_compact(680.0), content="false")
  inspect(help_card_width(960.0) == 460.0, content="true")
  inspect(help_card_width(400.0) == 368.0, content="true")
  inspect(help_labels_compact(329.0), content="true")
  inspect(help_labels_compact(330.0), content="false")
  let narrow_help = help_shortcut_labels(true)
  inspect(narrow_help.length(), content="12")
  inspect(narrow_help[7], content="Create or save")
  let full_help = help_shortcut_labels(false)
  inspect(full_help.length(), content="12")
  inspect(full_help[7], content="Create a worktree or save an edit")
}

///|
test "create-from chips stack before their labels clip" {
  inspect(modal_chips_stack(359.0), content="true")
  inspect(modal_chips_stack(360.0), content="false")
  let content_w = overlay_card_width(320.0) - 48.0
  inspect(content_w == 240.0, content="true")
  inspect((content_w - 8.0) / 2.0 == 116.0, content="true")
}

///|
test "creating without a name falls back to the default worktree" {
  let opened = update(Model::new(), NewTab)
  inspect(opened.modal_open, content="true")
  inspect(opened.modal_name == "", content="true")
  let created = update(opened, CreateWorktree)
  inspect(has_worktree(created, "speed-up-checkout-ci"), content="true")
  inspect(created.active == "speed-up-checkout-ci", content="true")
  inspect(created.modal_open, content="false")
}

///|
test "GitHub source seeds a pull request worktree" {
  let opened = update(Model::new(), OpenModal)
  let github = update(opened, SelectCreateFrom(1))
  inspect(github.modal_from, content="1")
  inspect(github.modal_name == "Retry flaky checkout (PR #482)", content="true")
  let created = update(github, CreateWorktree)
  let ok = match find_worktree(created, "retry-flaky-checkout-pr-482") {
    Some(worktree) =>
      worktree.branch == "pr/retry-flaky-checkout-pr-482" &&
      worktree.transcript.length() == 3 &&
      worktree.transcript[1] is AssistantMessage(_)
    None => false
  }
  inspect(ok, content="true")
  let sync_ok = match find_worktree(created, "retry-flaky-checkout-pr-482") {
    Some(worktree) =>
      match worktree.transcript[2] {
        Worker(block) => block.name == "pr-sync"
        _ => false
      }
    None => false
  }
  inspect(sync_ok, content="true")
}

///|
test "Branch source seeds a branch-derived worktree" {
  let opened = update(Model::new(), OpenModal)
  let branch = update(opened, SelectCreateFrom(2))
  inspect(branch.modal_name == "Checkout retry branch", content="true")
  let created = update(branch, CreateWorktree)
  let branch_wt = find_worktree(created, "checkout-retry-branch")
  let ok = match branch_wt {
    Some(worktree) => worktree.branch == "feature/checkout-retry-branch"
    None => false
  }
  inspect(ok, content="true")
  let checkout_ok = match branch_wt {
    Some(worktree) =>
      match worktree.transcript[2] {
        Worker(block) => block.name == "branch-checkout"
        _ => false
      }
    None => false
  }
  inspect(checkout_ok, content="true")
}

///|
test "Name source requires a typed name" {
  let opened = update(Model::new(), OpenModal)
  let named = update(opened, SelectCreateFrom(3))
  inspect(named.modal_from, content="3")
  inspect(named.modal_name == "", content="true")
  inspect(modal_create_blocked(named), content="true")
  let spaces = update(named, NameInput("   "))
  inspect(modal_create_blocked(spaces), content="true")
  let blocked = update(named, CreateWorktree)
  inspect(blocked.modal_open, content="true")
  inspect(worktree_total(blocked), content="4")
  let typed = update(blocked, NameInput("Tidy promo banner"))
  inspect(modal_create_blocked(typed), content="false")
  let created = update(typed, CreateWorktree)
  inspect(created.modal_open, content="false")
  inspect(has_worktree(created, "tidy-promo-banner"), content="true")
  inspect(modal_create_blocked(opened), content="false")
}

///|
test "create dialog resets source and advanced state between openings" {
  let configured = update(
    update(
      update(
        update(
          update(
            update(update(Model::new(), OpenModal), SelectCreateFrom(3)),
            NameInput("Temporary name"),
          ),
          ToggleAdvanced,
        ),
        CycleBaseBranch,
      ),
      CycleAgent,
    ),
    CycleTarget,
  )
  let more = update(configured, ToggleCreateMore)
  inspect(more.modal_from, content="3")
  inspect(more.modal_advanced, content="true")
  inspect(more.modal_base_branch, content="1")
  inspect(more.modal_agent, content="1")
  inspect(more.modal_target, content="1")
  inspect(more.create_more, content="true")
  let cancelled = update(more, CloseModal)
  inspect(cancelled.modal_open, content="false")
  inspect(cancelled.modal_from, content="0")
  inspect(cancelled.modal_name == "", content="true")
  inspect(cancelled.modal_advanced, content="false")
  inspect(cancelled.modal_base_branch, content="0")
  inspect(cancelled.modal_agent, content="0")
  inspect(cancelled.modal_target, content="0")
  inspect(cancelled.create_more, content="false")
  let reopened = update(cancelled, OpenModal)
  inspect(reopened.modal_open, content="true")
  inspect(reopened.modal_from, content="0")
  inspect(reopened.modal_name == "", content="true")
  inspect(modal_create_blocked(reopened), content="false")
  let created = update(
    update(
      update(
        update(
          update(update(reopened, SelectCreateFrom(3)), NameInput("Final name")),
          ToggleAdvanced,
        ),
        CycleAgent,
      ),
      CycleTarget,
    ),
    CreateWorktree,
  )
  inspect(created.modal_open, content="false")
  inspect(created.modal_from, content="0")
  inspect(created.modal_advanced, content="false")
  inspect(created.modal_base_branch, content="0")
  inspect(created.modal_agent, content="0")
  inspect(created.modal_target, content="0")
  inspect(created.create_more, content="false")
  let new_tab = update(created, NewTab)
  inspect(new_tab.modal_open, content="true")
  inspect(new_tab.modal_from, content="0")
  inspect(new_tab.modal_name == "", content="true")
  inspect(modal_create_blocked(new_tab), content="false")
}

///|
test "sidebar resize clamps to the supported range" {
  let model = Model::new()
  let narrow = update(model, ResizeSidebar(120.0))
  inspect(narrow.sidebar_w == 220.0, content="true")
  let wide = update(model, ResizeSidebar(999.0))
  inspect(wide.sidebar_w == 380.0, content="true")
  let mid = update(model, ResizeSidebar(312.0))
  inspect(mid.sidebar_w == 312.0, content="true")
}

///|
test "bots sidebar resize clamps independently of the Projects sidebar" {
  let model = Model::new()
  let resized = update(model, ResizeBotsSidebar(320.0))
  inspect(resized.bots_sidebar_w == 320.0, content="true")
  inspect(resized.sidebar_w == 340.0, content="true")
  let narrow = update(resized, ResizeBotsSidebar(100.0))
  inspect(narrow.bots_sidebar_w == 220.0, content="true")
  let wide = update(resized, ResizeBotsSidebar(500.0))
  inspect(wide.bots_sidebar_w == 380.0, content="true")
  let collapsed = update(resized, ToggleSidebar)
  inspect(collapsed.sidebar_open, content="false")
  inspect(collapsed.bots_sidebar_w == 320.0, content="true")
}

///|
test "bots item panel resize clamps to the panel range" {
  let model = Model::new()
  let resized = update(model, ResizeBotsPanel(440.0))
  inspect(resized.bots_panel_w == 440.0, content="true")
  inspect(resized.bots_sidebar_w == 272.0, content="true")
  let narrow = update(resized, ResizeBotsPanel(200.0))
  inspect(narrow.bots_panel_w == 320.0, content="true")
  let wide = update(resized, ResizeBotsPanel(900.0))
  inspect(wide.bots_panel_w == 480.0, content="true")
  let collapsed = update(resized, ToggleBotItemPanel)
  inspect(collapsed.bots_item_open, content="false")
  inspect(collapsed.bots_panel_w == 440.0, content="true")
}

///|
test "responsive widths keep bots panes inside the window" {
  let model = Model::new()
  inspect(model.bots_sidebar_w == 272.0, content="true")
  inspect(model.bots_panel_w == 400.0, content="true")
  let (wide_left, wide_panel) = bots_pinned_widths(model, 1280.0)
  inspect(wide_left == 272.0, content="true")
  inspect(wide_panel == 400.0, content="true")
  let (mid_left, mid_panel) = bots_pinned_widths(model, 960.0)
  inspect(mid_left == 272.0, content="true")
  inspect(mid_panel < 400.0, content="true")
  let (narrow_left, narrow_panel) = bots_pinned_widths(model, 700.0)
  inspect(narrow_left + narrow_panel + 10.0 + 300.0 <= 700.0, content="true")
  inspect(narrow_panel < 240.0, content="true")
  inspect(bots_home_tab_width == 143.0, content="true")
  inspect(bots_eng_tab_width == 196.0, content="true")
  inspect(bots_center_tabs_width == 383.0, content="true")
  inspect(session_row_label_width(272.0) == 165.0, content="true")
  inspect(session_row_label_limit(272.0) == 26, content="true")
  inspect(session_row_label_limit(220.0) == 18, content="true")
  inspect(session_row_label_limit(320.0) == 34, content="true")
  inspect(session_row_label_limit(380.0) == 44, content="true")
}

///|
test "chat and automation content widths clamp for narrow panes" {
  inspect(chat_content_width(1280.0) == 736.0, content="true")
  inspect(chat_content_width(480.0) == 428.0, content="true")
  inspect(chat_content_width(300.0) == 248.0, content="true")
  inspect(chat_content_width(40.0) == 0.0, content="true")
  inspect(automation_col_scale(872.0) == 1.0, content="true")
  let mid = automation_col_scale(400.0)
  inspect(mid > 0.37 && mid < 0.38, content="true")
  inspect(automation_col_scale(100.0) == 0.35, content="true")
  inspect(automations_compact(559.0), content="true")
  inspect(automations_compact(560.0), content="false")
  inspect(automation_columns_width(468.0) <= 468.0, content="true")
  inspect(automation_columns_width(563.0) <= 563.0, content="true")
  inspect(automation_columns_width(499.0) <= 499.0, content="true")
  inspect(automation_columns_width(840.0) <= 840.0, content="true")
  inspect(automation_trailing_width() == 60.0, content="true")
  inspect(automation_action_summary_width(527.0) == 233.0, content="true")
  inspect(automations_content_width(655.0) == 563.0, content="true")
  inspect(automations_card_width(655.0) == 591.0, content="true")
  inspect(automations_content_width(935.0) == 843.0, content="true")
  inspect(automations_card_width(935.0) == 871.0, content="true")
  inspect(automations_content_width(320.0) == 228.0, content="true")
  inspect(automations_card_width(320.0) == 256.0, content="true")
  inspect(
    search_header_subtitle(679.0).length() <
    search_header_subtitle(680.0).length(),
    content="true",
  )
  inspect(bots_panel_title_wraps(307.0), content="true")
  inspect(bots_panel_title_wraps(385.0), content="false")
  inspect(panel_row_inner_width(400.0) == 360.0, content="true")
  inspect(panel_row_inner_width(320.0) == 280.0, content="true")
  inspect(panel_file_text_width(400.0) == 289.0, content="true")
  inspect(panel_file_text_width(320.0) == 209.0, content="true")
  inspect(automation_header_actions_width(419.0) == 72.0, content="true")
  inspect(automation_header_actions_width(420.0) == 148.0, content="true")
}

///|
test "select values keep the chevron inside narrow fields" {
  inspect(select_value_width(112.0, 16.0) == 36.0, content="true")
  inspect(select_value_width(243.0, 16.0) == 167.0, content="true")
  inspect(select_value_width(243.0, 14.0) == 169.0, content="true")
  inspect(select_value_width(20.0, 16.0) == 0.0, content="true")
}

///|
test "agent rows adapt to the sidebar's minimum width" {
  inspect(agent_row_name_limit(162.0) == 10, content="true")
  inspect(agent_row_name_limit(226.0) == 12, content="true")
  inspect(agent_row_name_limit(282.0) == 17, content="true")
  inspect(agent_row_shows_model(162.0), content="false")
  inspect(agent_row_shows_model(226.0), content="false")
  inspect(agent_row_shows_model(242.0), content="true")
  inspect(agent_row_shows_model(282.0), content="true")
}

///|
test "worktree cards keep the reference vertical inset" {
  let (top, bottom) = worktree_card_padding()
  inspect(top, content="10")
  inspect(bottom, content="12")
}

///|
test "tab strip history restores screens and worktrees" {
  let model = Model::new()
  let empty = update(model, GoBack)
  inspect(empty.nav_back.is_empty(), content="true")
  let bots = update(model, SetSection(Bots))
  inspect(bots.screen == Bots, content="true")
  inspect(bots.nav_back.length() == 1, content="true")
  let back = update(bots, GoBack)
  inspect(back.screen == Projects, content="true")
  inspect(back.nav_forward.length() == 1, content="true")
  let forward = update(back, GoForward)
  inspect(forward.screen == Bots, content="true")
  let reopened = update(forward, GoBack)
  let tasks = update(reopened, SetSection(Tasks))
  inspect(tasks.nav_forward.is_empty(), content="true")
  let switched = update(model, SelectWorktree("checkout-flow-v2"))
  inspect(switched.active == "checkout-flow-v2", content="true")
  inspect(switched.nav_back.length() == 1, content="true")
  let worktree_back = update(switched, GoBack)
  inspect(worktree_back.active == "eu-promo-checkout", content="true")
  let shortcut = update(switched, SelectTabAt(0))
  inspect(shortcut.active == "eu-promo-checkout", content="true")
  inspect(shortcut.nav_back.length() == 2, content="true")
}

///|
test "worktree context menu selects, opens the diff, renames and deletes" {
  let model = update(Model::new(), SelectWorktree("checks-detail-link"))
  let opened = update(
    model,
    OpenContextMenu(
      0,
      "checks-detail-link",
      -1,
      @geometry.Point::new(x=40.0, y=120.0),
    ),
  )
  inspect(opened.ctx_open, content="true")
  inspect(opened.ctx_target == "checks-detail-link", content="true")
  let diff = update(opened, ContextAction(1))
  inspect(diff.ctx_open, content="false")
  inspect(diff.screen == DiffScreen, content="true")
  inspect(diff.active == "checks-detail-link", content="true")
  inspect(diff.diff_worktree == "checks-detail-link", content="true")
  inspect(
    diff_review_title(diff) == "Fix CI checks detail link",
    content="true",
  )
  inspect(diff_file_name_for(diff, 0) == "checks.ts", content="true")
  inspect(diff.diff_working, content="false")
  let renaming = update(opened, ContextAction(2))
  inspect(renaming.ctx_open, content="false")
  inspect(renaming.rename_open, content="true")
  inspect(renaming.rename_target == "checks-detail-link", content="true")
  let deleting = update(opened, ContextAction(4))
  inspect(deleting.ctx_open, content="false")
  inspect(deleting.delete_open, content="true")
  inspect(deleting.delete_target == "checks-detail-link", content="true")
  let closed = update(opened, ContextAction(3))
  inspect(closed.ctx_open, content="false")
  inspect(closed.tabs.length(), content="1")
  inspect(closed.active == "eu-promo-checkout", content="true")
}

///|
test "task context menu marks a task done and reopens it" {
  let model = update(Model::new(), SetSection(Tasks))
  let opened = update(
    model,
    OpenContextMenu(1, "", 0, @geometry.Point::new(x=120.0, y=200.0)),
  )
  let done = update(opened, ContextAction(1))
  inspect(done.ctx_open, content="false")
  inspect(done.tasks[0].status == TaskDone, content="true")
  let reopened = update(
    done,
    OpenContextMenu(1, "", 0, @geometry.Point::new(x=120.0, y=200.0)),
  )
  let back = update(reopened, ContextAction(1))
  inspect(back.tasks[0].status == TaskNeedsYou, content="true")
}

///|
test "closing the task context menu runs no action" {
  let opened = update(
    Model::new(),
    OpenContextMenu(1, "", 0, @geometry.Point::new(x=120.0, y=200.0)),
  )
  inspect(opened.ctx_open, content="true")
  let closed = update(opened, CloseContextMenu)
  inspect(closed.ctx_open, content="false")
  inspect(closed.tasks[0].status == TaskNeedsYou, content="true")
  inspect(closed.tasks[0].activity.length(), content="4")
}

///|
test "create worktree honors the picked agent" {
  let opened = update(Model::new(), OpenModal)
  inspect(
    modal_agent_label(opened.modal_agent) == "Claude Code",
    content="true",
  )
  let codex = update(opened, CycleAgent)
  inspect(codex.modal_agent, content="1")
  inspect(modal_agent_label(codex.modal_agent) == "Codex", content="true")
  let created = update(codex, CreateWorktree)
  let codex_ok = match find_worktree(created, "speed-up-checkout-ci") {
    Some(worktree) =>
      worktree.agents[0].kind == Codex &&
      worktree.agents[0].model == "gpt-6-astra"
    None => false
  }
  inspect(codex_ok, content="true")
  let reopened = update(created, OpenModal)
  let grok_ready = update(update(reopened, CycleAgent), CycleAgent)
  inspect(grok_ready.modal_agent, content="2")
  let grok = update(grok_ready, CreateWorktree)
  let grok_ok = match find_worktree(grok, "speed-up-checkout-ci-2") {
    Some(worktree) => worktree.agents[0].kind == Grok
    None => false
  }
  inspect(grok_ok, content="true")
  let wrapped = update(update(grok, CycleAgent), CycleAgent)
  inspect(wrapped.modal_agent, content="2")
}

///|
test "composer pickers and create target cycle" {
  let model = Model::new()
  let model_pick = update(model, CycleComposerModel)
  inspect(model_pick.composer_model, content="1")
  inspect(
    composer_model_label(model_pick.composer_model) == "GPT-6 Astra",
    content="true",
  )
  inspect(
    bots_composer_model_label(model_pick.composer_model) ==
    "Codex GPT-6 Astra Med",
    content="true",
  )
  let access = update(model, CycleAccess)
  inspect(access.composer_access, content="1")
  inspect(
    composer_access_label(access.composer_access) == "Ask before edits",
    content="true",
  )
  let access_back = update(update(access, CycleAccess), CycleAccess)
  inspect(access_back.composer_access, content="0")
  let opened = update(model, OpenModal)
  inspect(
    modal_target_project(opened.modal_target) == "acme-internal",
    content="true",
  )
  let target = update(opened, CycleTarget)
  inspect(
    modal_target_project(target.modal_target) == "acme-web",
    content="true",
  )
  inspect(modal_target_host(target.modal_target) == "Local Mac", content="true")
  let created = update(target, CreateWorktree)
  inspect(created.machines[0].projects[0].worktrees.length(), content="2")
  inspect(
    created.machines[0].projects[0].worktrees[1].id == "speed-up-checkout-ci",
    content="true",
  )
}

///|
test "sending a message appends the user and assistant blocks and clears the draft" {
  let typed = update(Model::new(), DraftInput("Check the promo tax fix"))
  inspect(typed.draft == "Check the promo tax fix", content="true")
  let count_before = transcript_of(typed, "eu-promo-checkout").length()
  inspect(count_before, content="5")
  let sent = update(typed, Send)
  inspect(sent.draft == "", content="true")
  let count_after = transcript_of(sent, "eu-promo-checkout").length()
  inspect(count_after == count_before + 2, content="true")
  let user_ok = match transcript_of(sent, "eu-promo-checkout")[count_before] {
    UserMessage(text) => text == "Check the promo tax fix"
    _ => false
  }
  inspect(user_ok, content="true")
  let assistant_ok = match
    transcript_of(sent, "eu-promo-checkout")[count_before + 1] {
    AssistantMessage(text) =>
      text == "On it — I’ll report back here when the workers finish."
    _ => false
  }
  inspect(assistant_ok, content="true")
}

///|
test "the worked row toggles its expanded state" {
  let model = Model::new()
  let expanded_before = match transcript_of(model, "eu-promo-checkout")[1] {
    Worked(row) => row.expanded
    _ => false
  }
  inspect(expanded_before, content="false")
  let toggled = update(model, ToggleWorked("eu-promo-checkout", 1))
  let expanded_after = match transcript_of(toggled, "eu-promo-checkout")[1] {
    Worked(row) => row.expanded
    _ => false
  }
  inspect(expanded_after, content="true")
  let toggled_back = update(toggled, ToggleWorked("eu-promo-checkout", 1))
  let expanded_again = match
    transcript_of(toggled_back, "eu-promo-checkout")[1] {
    Worked(row) => row.expanded
    _ => true
  }
  inspect(expanded_again, content="false")
}

///|
test "clicking a worker card moves the focus ring" {
  let model = Model::new()
  let first_before = match transcript_of(model, "eu-promo-checkout")[2] {
    Worker(card) => card.focused
    _ => false
  }
  inspect(first_before, content="true")
  let moved = update(model, ToggleWorker("eu-promo-checkout", 3))
  let first_after = match transcript_of(moved, "eu-promo-checkout")[2] {
    Worker(card) => card.focused
    _ => true
  }
  let second_after = match transcript_of(moved, "eu-promo-checkout")[3] {
    Worker(card) => card.focused
    _ => false
  }
  inspect(first_after, content="false")
  inspect(second_after, content="true")
  let cleared = update(moved, ToggleWorker("eu-promo-checkout", 3))
  let second_cleared = match transcript_of(cleared, "eu-promo-checkout")[3] {
    Worker(card) => card.focused
    _ => true
  }
  inspect(second_cleared, content="false")
  let untouched = update(model, ToggleWorker("eu-promo-checkout", 99))
  let first_untouched = match transcript_of(untouched, "eu-promo-checkout")[2] {
    Worker(card) => card.focused
    _ => false
  }
  inspect(first_untouched, content="true")
}

///|
test "bots screen switching and fleet selection" {
  let model = Model::new()
  inspect(model.screen == Projects, content="true")
  let bots = update(model, SetSection(Bots))
  inspect(bots.screen == Bots, content="true")
  let back = update(bots, SetSection(Search))
  inspect(back.screen == SearchScreen, content="true")
  let projects = update(back, ShowProjects)
  inspect(projects.screen == Projects, content="true")
  let forced = update(model, SetScreen(Bots))
  inspect(forced.screen == Bots, content="true")
  let ci = update(forced, SelectBot("ci-watch"))
  inspect(ci.active_bot == "ci-watch", content="true")
  let session = update(forced, SelectBot("webkit-repro-test"))
  inspect(session.active_bot == "scout", content="true")
  inspect(session.active_session == "webkit-repro-test", content="true")
  let tabbed = update(session, SetCenterTab(1))
  inspect(tabbed.center_tab == 1, content="true")
  let panel = update(tabbed, SetPanelTab(2))
  inspect(panel.panel_tab == 2, content="true")
}

///|
test "every seeded bot has sessions that select back to it" {
  let model = Model::new()
  for bot in bots_seed() {
    inspect(bot.sessions.length() >= 3, content="true")
    for session in bot.sessions {
      match find_session_bot(model, session.id) {
        Some(owner) => inspect(owner.id == bot.id, content="true")
        None => inspect(false, content="true")
      }
    }
  }
}

///|
test "bot filter matches session labels" {
  let bots = bots_seed()
  let ci = bots[1]
  inspect(bot_matches(ci, "cart"), content="true")
  inspect(bot_matches(ci, "e2e-cart-triage"), content="true")
  inspect(bot_matches(ci, "scout"), content="false")
}

///|
test "bots center tabs close, fall back and reopen from the sidebar" {
  let model = scene_bots_model()
  let eng_closed = update(model, CloseBotTab(1))
  inspect(eng_closed.bot_eng_open, content="false")
  inspect(eng_closed.center_tab, content="0")
  let chat_closed = update(eng_closed, CloseBotTab(0))
  inspect(chat_closed.bot_chat_open, content="false")
  inspect(bots_tab_open(chat_closed), content="false")
  let reopened = update(chat_closed, SelectBot("scout"))
  inspect(reopened.bot_chat_open, content="true")
  inspect(bots_tab_open(reopened), content="true")
  let fallback = update(model, CloseBotTab(0))
  inspect(fallback.center_tab, content="1")
  inspect(bots_tab_open(fallback), content="true")
  let both_closed = update(fallback, CloseBotTab(1))
  inspect(both_closed.bot_eng_open, content="false")
  inspect(bots_tab_open(both_closed), content="false")
  let other = update(update(model, SelectBot("ci-watch")), CloseBotTab(1))
  inspect(other.bot_eng_open, content="true")
}

///|
test "right item panel collapses to a rail and reopens on a tab" {
  let model = scene_bots_model()
  inspect(model.bots_item_open, content="true")
  let rail = update(model, ToggleBotItemPanel)
  inspect(rail.bots_item_open, content="false")
  let reopened = update(rail, ToggleBotItemPanel)
  inspect(reopened.bots_item_open, content="true")
  let history = update(rail, OpenBotItemPanel(2))
  inspect(history.bots_item_open, content="true")
  inspect(history.panel_tab, content="2")
  let files = update(rail, OpenBotItemPanel(3))
  inspect(files.bots_item_open, content="true")
  inspect(files.panel_tab, content="3")
  let invalid = update(rail, OpenBotItemPanel(4))
  inspect(invalid.bots_item_open, content="false")
  inspect(invalid.panel_tab, content="0")
}

///|
test "bots status menu toggles only for bots with an item" {
  let model = scene_bots_model()
  inspect(bot_item_state(model.bots[0]), content="In progress")
  inspect(model.bot_status_menu_open, content="false")
  let opened = update(model, ToggleBotStatusMenu)
  inspect(opened.bot_status_menu_open, content="true")
  let closed = update(opened, ToggleBotStatusMenu)
  inspect(closed.bot_status_menu_open, content="false")
  let added = update(model, AddBot)
  let attempted = update(added, ToggleBotStatusMenu)
  inspect(attempted.bot_status_menu_open, content="false")
  let set = update(attempted, SetBotItemState("Done"))
  inspect(set.bots[set.bots.length() - 1].item_state, content="")
}

///|
test "bots status menu sets only the active bot and closes" {
  let model = scene_bots_model()
  let opened = update(model, ToggleBotStatusMenu)
  let waiting = update(opened, SetBotItemState("Waiting on you"))
  inspect(waiting.bot_status_menu_open, content="false")
  inspect(bot_item_state(waiting.bots[0]), content="Waiting on you")
  inspect(waiting.bots[1].item_state, content="")
  inspect(bot_item_state(waiting.bots[1]), content="Waiting on you")
  let ci = update(waiting, SelectBot("ci-watch"))
  inspect(ci.bot_status_menu_open, content="false")
  let ci_done = update(ci, SetBotItemState("Done"))
  inspect(bot_item_state(ci_done.bots[1]), content="Done")
  let back = update(ci_done, SelectBot("scout"))
  inspect(bot_item_state(back.bots[0]), content="Waiting on you")
  let invalid = update(opened, SetBotItemState("Blocked"))
  inspect(invalid.bot_status_menu_open, content="true")
  inspect(bot_item_state(invalid.bots[0]), content="In progress")
}

///|
test "bots status menu closes on tab, panel, page and bot changes" {
  let model = scene_bots_model()
  let opened = update(model, ToggleBotStatusMenu)
  inspect(update(opened, SetPanelTab(1)).bot_status_menu_open, content="false")
  inspect(
    update(opened, ToggleBotItemPanel).bot_status_menu_open,
    content="false",
  )
  inspect(
    update(opened, SetSection(Tasks)).bot_status_menu_open,
    content="false",
  )
  inspect(update(opened, ShowProjects).bot_status_menu_open, content="false")
  inspect(
    update(opened, SelectBot("ci-watch")).bot_status_menu_open,
    content="false",
  )
  let moved = update(update(model, ToggleBotStatusMenu), MoveBotSelection(1))
  inspect(moved.bot_status_menu_open, content="false")
}

///|
test "bots needs-you badge follows item states and hides at zero" {
  let model = scene_bots_model()
  inspect(bots_needing_you(model), content="1")
  inspect(bots_needs_label(1) == "1 needs you", content="true")
  inspect(bots_needs_label(0) == "", content="true")
  let two = update(model, SetBotItemState("Waiting on you"))
  inspect(bots_needing_you(two), content="2")
  inspect(bots_needs_label(2) == "2 need you", content="true")
  let ci_done = update(
    update(two, SelectBot("ci-watch")),
    SetBotItemState("Done"),
  )
  inspect(bots_needing_you(ci_done), content="1")
  let none = update(
    update(ci_done, SelectBot("scout")),
    SetBotItemState("Done"),
  )
  inspect(bots_needing_you(none), content="0")
  let added = update(none, AddBot)
  inspect(bots_needing_you(added), content="0")
}

///|
test "sidebar nav opens Search, Tasks and Automations pages" {
  let model = Model::new()
  let search = update(model, SetSection(Search))
  inspect(search.screen == SearchScreen, content="true")
  let tasks = update(search, SetSection(Tasks))
  inspect(tasks.screen == TasksScreen, content="true")
  let automations = update(tasks, SetSection(Automations))
  inspect(automations.screen == AutomationsScreen, content="true")
  let bots = update(automations, SetSection(Bots))
  inspect(bots.screen == Bots, content="true")
  let from_bots = update(bots, ShowProjects)
  inspect(from_bots.screen == Projects, content="true")
  inspect(from_bots.section == Search, content="true")
}

///|
test "wordmark menu switches pages and Projects hides the nav" {
  let model = Model::new()
  inspect(sidebar_nav_visible(model, false), content="false")
  inspect(sidebar_nav_visible(model, true), content="true")
  let opened = update(model, ToggleAppMenu)
  inspect(opened.app_menu_open, content="true")
  inspect(enter_page_action(opened, false) is Noop, content="true")
  let closed = update(opened, CloseAppMenu)
  inspect(closed.app_menu_open, content="false")
  let tasks = update(opened, SetSection(Tasks))
  inspect(tasks.screen == TasksScreen, content="true")
  inspect(tasks.app_menu_open, content="false")
  inspect(sidebar_nav_visible(tasks, false), content="true")
  let search = update(model, SetSection(Search))
  inspect(sidebar_nav_visible(search, false), content="true")
  let modal = update(opened, OpenModal)
  inspect(modal.modal_open, content="true")
  inspect(modal.app_menu_open, content="false")
}

///|
test "search results route to worktrees and bots" {
  let search = update(Model::new(), SetSection(Search))
  let worktree = update(search, SelectSearchResult("agent-handoff-summary"))
  inspect(worktree.screen == Projects, content="true")
  inspect(worktree.active == "agent-handoff-summary", content="true")
  inspect(worktree.tabs.length(), content="2")
  let bot = update(search, SelectSearchResult("ci-watch"))
  inspect(bot.screen == Bots, content="true")
  inspect(bot.active_bot == "ci-watch", content="true")
  let session = update(search, SelectSearchResult("safari-pay-click"))
  inspect(session.screen == Bots, content="true")
  inspect(session.active_bot == "scout", content="true")
  inspect(session.active_session == "safari-pay-click", content="true")
  let unknown = update(search, SelectSearchResult("not-a-real-id"))
  inspect(unknown.screen == SearchScreen, content="true")
}

///|
test "task and automation rows support selection" {
  let model = Model::new()
  let task = update(model, SelectTask(3))
  inspect(task.task_selected, content="3")
  let automation = update(task, SelectAutomation(2))
  inspect(automation.automation_selected, content="2")
}

///|
test "arrow keys move through tasks, automations and bots" {
  let model = Model::new()
  let task_down = update(model, MoveTaskSelection(1))
  inspect(task_down.task_selected, content="1")
  let task_end = update(task_down, MoveTaskSelection(99))
  inspect(task_end.task_selected, content="5")
  let task_home = update(task_end, MoveTaskSelection(-99))
  inspect(task_home.task_selected, content="0")
  let done_only = update(model, SetTaskFilter(3))
  let done_down = update(done_only, MoveTaskSelection(1))
  inspect(done_down.task_selected, content="5")
  let automation_down = update(model, MoveAutomationSelection(1))
  inspect(automation_down.automation_selected, content="1")
  let automation_end = update(automation_down, MoveAutomationSelection(99))
  let last_automation = model.automations.length() - 1
  inspect(automation_end.automation_selected, content="\{last_automation}")
  let bot_down = update(model, MoveBotSelection(1))
  inspect(bot_down.active_bot, content="ci-watch")
  let bot_end = update(bot_down, MoveBotSelection(99))
  inspect(bot_end.active_bot, content="docs-helper")
  let bot_home = update(bot_end, MoveBotSelection(-99))
  inspect(bot_home.active_bot, content="scout")
  let filtered = update(update(model, ToggleBotSearch), BotQueryInput("watch"))
  let filtered_down = update(filtered, MoveBotSelection(1))
  inspect(filtered_down.active_bot, content="ci-watch")
}

///|
test "bots empty filter clears without closing the search field" {
  let filtered = update(
    update(Model::new(), ToggleBotSearch),
    BotQueryInput("zzz"),
  )
  inspect(filtered.bot_search_open, content="true")
  inspect(filtered.bot_query == "zzz", content="true")
  let cleared = update(filtered, ClearBotQuery)
  inspect(cleared.bot_search_open, content="true")
  inspect(cleared.bot_query == "", content="true")
}

///|
test "diff lines select, notes toggle and the composer appends messages" {
  let model = scene_diff_model()
  inspect(model.diff_selected, content="6")
  inspect(model.diff_note_open, content="true")
  let line = update(model, SelectDiffLine(3))
  inspect(line.diff_selected, content="3")
  let closed = update(line, ToggleDiffNote)
  inspect(closed.diff_note_open, content="false")
  let reopened = update(closed, ToggleDiffNote)
  inspect(reopened.diff_note_open, content="true")
  let typed = update(
    reopened,
    DiffDraftInput("Reject PO boxes for express shipping too"),
  )
  let sent = update(typed, DiffSend)
  inspect(sent.diff_draft == "", content="true")
  inspect(sent.diff_messages.length(), content="2")
  inspect(sent.diff_working, content="true")
  let stopped = update(sent, DiffStop)
  inspect(stopped.diff_working, content="false")
}

///|
test "comments append to the item activity and ignore blanks" {
  let model = scene_bots_model()
  let typed = update(model, CommentInput("  Looks good to me  "))
  let sent = update(typed, SendComment)
  inspect(sent.comments.length(), content="1")
  inspect(sent.comments[0].text == "Looks good to me", content="true")
  inspect(sent.comments[0].key == bot_comment_key(sent), content="true")
  inspect(sent.comment_draft == "", content="true")
  let blank = update(update(sent, CommentInput("   ")), SendComment)
  inspect(blank.comments.length(), content="1")
  let other = update(sent, SelectBot("ci-watch"))
  inspect(other.comments.length(), content="1")
  inspect(other.comments[0].key == bot_comment_key(other), content="false")
}

///|
test "bots composer appends the message to the active chat" {
  let model = scene_bots_model()
  let typed = update(model, DraftInput("  Can you triage this?  "))
  let sent = update(typed, Send)
  inspect(sent.draft == "", content="true")
  inspect(sent.bot_messages.length(), content="2")
  let key = bot_chat_key(sent)
  inspect(key == "scout:0:home-chat", content="true")
  inspect(sent.bot_messages[0].key == key, content="true")
  let is_user = match sent.bot_messages[0].block {
    UserMessage(text) => text == "Can you triage this?"
    _ => false
  }
  inspect(is_user, content="true")
  let blank = update(update(sent, DraftInput("   ")), Send)
  inspect(blank.bot_messages.length(), content="2")
  let other = update(sent, SelectBot("ci-watch"))
  inspect(bot_chat_key(other) != key, content="true")
  let home = update(sent, SelectBot("home-chat"))
  inspect(home.active_session == "home-chat", content="true")
  inspect(bot_chat_key(home) == key, content="true")
  inspect(bot_chat_has_messages(home), content="true")
}

///|
test "new bot keeps one chat before and after opening its Home session" {
  let added = update(scene_bots_model(), AddBot)
  inspect(bot_chat_key(added) == "relay:0:relay-home", content="true")
  inspect(bot_chat_has_messages(added), content="false")
  inspect(bot_chat_waiting(added), content="true")
  inspect(
    bot_home_empty_copy(added, added.bots[added.bots.length() - 1]) ==
    "Start a Home Chat with Relay to give it something to work on.",
    content="true",
  )
  let typed = update(added, DraftInput("Plan the release"))
  let sent = update(typed, Send)
  inspect(bot_chat_has_messages(sent), content="true")
  inspect(bot_chat_waiting(sent), content="false")
  inspect(
    bot_home_empty_copy(sent, sent.bots[sent.bots.length() - 1]) ==
    "Relay has started in Home Chat. Open it to continue the thread.",
    content="true",
  )
  let home = update(sent, SelectBot("relay-home"))
  inspect(bot_chat_key(home) == bot_chat_key(sent), content="true")
  inspect(bot_chat_has_messages(home), content="true")
  inspect(bot_chat_waiting(home), content="false")
  inspect(home.bot_messages.length(), content="2")
}

///|
test "bots composer placeholder shortens at narrow widths" {
  inspect(bots_composer_placeholder(223.0) == "Ask anything…", content="true")
  inspect(bots_composer_placeholder(319.0) == "Ask anything…", content="true")
  inspect(
    bots_composer_placeholder(320.0) ==
    "Ask anything, @ bots or files, / for…",
    content="true",
  )
  inspect(
    bots_composer_placeholder(383.0) ==
    "Ask anything, @ bots or files, / for…",
    content="true",
  )
  inspect(
    bots_composer_placeholder(459.0) ==
    "Ask anything, @ bots or files, / for…",
    content="true",
  )
  inspect(
    bots_composer_placeholder(460.0) ==
    "Ask anything, @ to mention bots or files, / for commands",
    content="true",
  )
  inspect(
    bots_composer_placeholder(559.0) ==
    "Ask anything, @ to mention bots or files, / for commands",
    content="true",
  )
}

///|
test "first bot message creates numbered items that survive a restart" {
  let added = update(scene_bots_model(), AddBot)
  let first = update(
    update(added, DraftInput("Draft a release checklist for 4.13")),
    Send,
  )
  inspect(first.bot_item_seq, content="44")
  inspect(bot_chat_waiting(first), content="false")
  match find_bot(first, "relay") {
    Some(bot) => {
      inspect(bot.working, content="1")
      match bot.item {
        Some(item) => {
          inspect(item.number, content="#43")
          inspect(item.title, content="Draft a release checklist for 4.13")
          inspect(item.state, content="In progress")
          inspect(item.meta, content="Item 43 · Home Chat · now")
          inspect(item.chips.length(), content="2")
          inspect(item.activities.length(), content="2")
          inspect(item.message is None, content="true")
        }
        None => inspect("missing item", content="#43")
      }
    }
    None => inspect("missing bot", content="relay")
  }
  let second_added = update(first, AddBot)
  let second = update(
    update(second_added, DraftInput("Review the billing migration")),
    Send,
  )
  inspect(second.bot_item_seq, content="45")
  match find_bot(second, "relay-2") {
    Some(bot) =>
      match bot.item {
        Some(item) => inspect(item.number, content="#44")
        None => inspect("missing item", content="#44")
      }
    None => inspect("missing bot", content="relay-2")
  }
  let scout_before = second.bot_item_seq
  let scout_sent = update(
    update(
      update(second, SelectBot("scout")),
      DraftInput("Summarize the failing checkout tests"),
    ),
    Send,
  )
  inspect(scout_sent.bot_item_seq, content="45")
  inspect(scout_sent.bot_item_seq == scout_before, content="true")
  match find_bot(scout_sent, "scout") {
    Some(bot) =>
      match bot.item {
        Some(item) => inspect(item.number, content="#41")
        None => inspect("missing item", content="#41")
      }
    None => inspect("missing bot", content="scout")
  }
  let restored = match load_model_json(save_model_json(scout_sent)) {
    Some(model) => model
    None => scout_sent
  }
  inspect(restored.bot_item_seq, content="45")
  inspect(restored.bot_messages.length(), content="6")
  match find_bot(restored, "relay") {
    Some(bot) =>
      match bot.item {
        Some(item) => {
          inspect(item.number, content="#43")
          inspect(item.title, content="Draft a release checklist for 4.13")
          inspect(item.state, content="In progress")
          inspect(item.meta, content="Item 43 · Home Chat · now")
          inspect(item.chips[0].kind == Amber, content="true")
          inspect(item.activities.length(), content="2")
          inspect(item.activities[0].text, content="Relay added this item")
          inspect(
            item.activities[1].text,
            content="Worker started: Draft a release checklist for 4.13",
          )
        }
        None => inspect("missing restored item", content="#43")
      }
    None => inspect("missing restored bot", content="relay")
  }
  match find_bot(restored, "relay-2") {
    Some(bot) =>
      match bot.item {
        Some(item) => inspect(item.number, content="#44")
        None => inspect("missing restored item", content="#44")
      }
    None => inspect("missing restored bot", content="relay-2")
  }
  match find_bot(restored, "scout") {
    Some(bot) => {
      inspect(bot.sessions.length(), content="4")
      match bot.item {
        Some(item) => {
          inspect(item.number, content="#41")
          inspect(item.message is Some(_), content="true")
          inspect(item.activities.length(), content="4")
        }
        None => inspect("missing seed item", content="#41")
      }
    }
    None => inspect("missing restored seed bot", content="scout")
  }
  let long_item = bot_item_from_message(
    added.bots[added.bots.length() - 1],
    43,
    "This title is deliberately much longer than the panel can show in one line",
  )
  inspect(long_item.title.length(), content="38")
  inspect(long_item.title.has_suffix("…"), content="true")
}

///|
test "composer dictation inserts a local sample phrase in each surface" {
  let base = scene_bots_model()
  let main = update(base, Dictate(1))
  inspect(main.draft, content="Summarize the failing checkout tests.")
  inspect(main.dictation_target, content="1")
  let prefixed = update(update(main, DraftInput("Please review")), Dictate(1))
  inspect(
    prefixed.draft,
    content="Please review Summarize the failing checkout tests.",
  )
  let trailing = update(update(main, DraftInput("Please review ")), Dictate(1))
  inspect(
    trailing.draft,
    content="Please review Summarize the failing checkout tests.",
  )
  let comment = update(update(main, CommentInput("Looks good")), Dictate(2))
  inspect(
    comment.comment_draft,
    content="Looks good Please add a regression test.",
  )
  inspect(comment.draft, content="Summarize the failing checkout tests.")
  let diff = update(Model::new(), Dictate(3))
  inspect(diff.diff_draft, content="The zero-rate fallback looks right.")
  inspect(diff.dictation_target, content="3")
  let invalid = update(base, Dictate(4))
  inspect(invalid.dictation_target, content="0")
  inspect(invalid.draft, content="")
  let shot = scene_bots_dictation_model()
  inspect(shot.draft, content="Summarize the failing checkout tests.")
  inspect(shot.dictation_target, content="1")
  inspect(dictation_append("", "A"), content="A")
  inspect(dictation_append("B", "A"), content="B A")
  inspect(dictation_append("B ", "A"), content="B A")
  inspect(update(main, DraftInput("x")).dictation_target, content="0")
  inspect(update(comment, CommentInput("ok")).dictation_target, content="0")
  inspect(update(diff, DiffDraftInput("ok")).dictation_target, content="0")
  let sent = update(main, Send)
  inspect(sent.dictation_target, content="0")
  inspect(sent.draft, content="")
  let sent_comment = update(comment, SendComment)
  inspect(sent_comment.dictation_target, content="0")
  inspect(sent_comment.comments.length(), content="1")
  let sent_diff = update(diff, DiffSend)
  inspect(sent_diff.dictation_target, content="0")
  inspect(sent_diff.diff_draft, content="")
}

///|
test "the reply flag toggles" {
  let model = scene_bots_model()
  inspect(bot_flag_on(model), content="false")
  let on = update(model, ToggleFlag)
  inspect(bot_flag_on(on), content="true")
  let off = update(on, ToggleFlag)
  inspect(bot_flag_on(off), content="false")
  let eng = update(on, SetCenterTab(1))
  inspect(bot_flag_on(eng), content="true")
  let other = update(on, SelectBot("ci-watch"))
  inspect(bot_flag_on(other), content="false")
  let back = update(other, SelectBot("scout"))
  inspect(bot_flag_on(back), content="true")
}

///|
test "search category filters narrow the hit list and clear resets" {
  let base = update(Model::new(), SetSection(Search))
  let all = filtered_search_hits(base)
  inspect(all.length() > 0, content="true")
  let worktrees = update(base, SetSearchFilter(1))
  let hits = filtered_search_hits(worktrees)
  inspect(hits.length() > 0, content="true")
  inspect(hits.length() < all.length(), content="true")
  let mut all_worktrees = true
  for hit in hits {
    if hit.kind != WorktreeHit {
      all_worktrees = false
    }
  }
  inspect(all_worktrees, content="true")
  let files = update(base, SetSearchFilter(4))
  let file_hits = filtered_search_hits(files)
  inspect(file_hits.length() > 0, content="true")
  let mut all_files = true
  for hit in file_hits {
    if hit.kind != FileHit {
      all_files = false
    }
  }
  inspect(all_files, content="true")
  let tax_files = filtered_search_hits(
    update(update(base, SetSearchFilter(4)), SearchInput("tax")),
  )
  inspect(tax_files.length() > 0, content="true")
  let cleared = update(update(base, SearchInput("tax")), ClearSearch)
  inspect(cleared.search_query == "", content="true")
  inspect(cleared.search_filter, content="0")
  inspect(search_hit_meta_visible(299.0), content="false")
  inspect(search_hit_meta_visible(300.0), content="true")
  inspect(search_hit_marker_visible(419.0), content="false")
  inspect(search_hit_marker_visible(420.0), content="true")
  inspect(search_hit_title_width(256.0) == 182.0, content="true")
  inspect(search_hit_title_width(416.0) == 254.0, content="true")
}

///|
test "a file row opens the worktree that owns it" {
  let base = Model::new()
  let file = base.files[0]
  let opened = update(base, SelectSearchResult(file.worktree_id))
  inspect(opened.active == file.worktree_id, content="true")
  let mut has_tab = false
  for id in opened.tabs {
    if id == file.worktree_id {
      has_tab = true
    }
  }
  inspect(has_tab, content="true")
}

///|
test "search matches file summaries and indexed contents" {
  let base = update(Model::new(), SetSection(Search))
  let files = update(base, SetSearchFilter(4))
  let safari = filtered_search_hits(update(files, SearchInput("pointerdown")))
  inspect(safari.length(), content="1")
  inspect(safari[0].title, content="src/checkout/PayButton.tsx")
  inspect(safari[0].subtitle, content="acme-web · Safari first-tap Pay fix")
  let eu = filtered_search_hits(update(files, SearchInput("EU10")))
  inspect(eu.length(), content="1")
  inspect(eu[0].title, content="src/tax/promo.test.ts")
  let summary = filtered_search_hits(
    update(files, SearchInput("postal pattern")),
  )
  inspect(summary.length(), content="0")
  let postal = filtered_search_hits(update(files, SearchInput("postalPattern")))
  inspect(postal.length(), content="1")
  inspect(postal[0].title, content="src/checkout/validators.ts")
}

///|
test "search @ prefix narrows results to files and clears cleanly" {
  let base = Model::new()
  let at = update(base, SearchInput("@"))
  inspect(at.search_filter, content="4")
  let all_files = filtered_search_hits(at)
  inspect(all_files.length(), content="\{base.files.length()}")
  let mut every_file = true
  for hit in all_files {
    if hit.kind != FileHit {
      every_file = false
    }
  }
  inspect(every_file, content="true")
  let pay = filtered_search_hits(update(base, SearchInput("@pay")))
  inspect(pay.length(), content="1")
  inspect(pay[0].title, content="src/checkout/PayButton.tsx")
  let bot = filtered_search_hits(update(base, SearchInput("@scout")))
  inspect(bot.length(), content="0")
  let plain = update(update(base, SearchInput("@pay")), SearchInput("pay"))
  inspect(plain.search_filter, content="0")
  inspect(filtered_search_hits(plain).length() > 1, content="true")
  let bots = update(base, SetSearchFilter(2))
  let scoped = update(bots, SearchInput("@pay"))
  inspect(scoped.search_filter, content="4")
  inspect(scoped.search_filter_before_scope, content="2")
  let restored = update(scoped, SearchInput("pay"))
  inspect(restored.search_filter, content="2")
  inspect(filtered_search_hits(restored).length() > 0, content="true")
  let files_again = update(scoped, SetSearchFilter(4))
  inspect(files_again.search_query, content="@pay")
  inspect(files_again.search_filter, content="4")
  inspect(files_again.search_filter_before_scope, content="2")
  let bots_again = update(scoped, SetSearchFilter(2))
  inspect(bots_again.search_query, content="pay")
  inspect(bots_again.search_filter, content="2")
  inspect(bots_again.search_filter_before_scope, content="2")
  inspect(search_query_has_file_scope(bots_again), content="false")
  let bot_hits = filtered_search_hits(bots_again)
  inspect(bot_hits.length() > 0, content="true")
  let mut every_bot = true
  for hit in bot_hits {
    if hit.kind != BotHit {
      every_bot = false
    }
  }
  inspect(every_bot, content="true")
  let all_again = update(scoped, SetSearchFilter(0))
  inspect(all_again.search_query, content="pay")
  inspect(all_again.search_filter, content="0")
  inspect(search_query_has_file_scope(all_again), content="false")
  inspect(filtered_search_hits(all_again).length() > 1, content="true")
  let cleared = update(scoped, ClearSearch)
  inspect(cleared.search_filter, content="0")
  inspect(cleared.search_filter_before_scope, content="0")
}

///|
test "the Files panel filters by path and project" {
  let model = Model::new()
  inspect(filtered_files(model).length(), content="\{model.files.length()}")
  let by_path = update(model, FileQueryInput("validators"))
  let path_hits = filtered_files(by_path)
  inspect(path_hits.length(), content="1")
  inspect(path_hits[0].path, content="src/checkout/validators.ts")
  let by_project = update(model, FileQueryInput("acme-internal"))
  let project_hits = filtered_files(by_project)
  inspect(project_hits.length() > 0, content="true")
  let mut only_internal = true
  for file in project_hits {
    if file.project != "acme-internal" {
      only_internal = false
    }
  }
  inspect(only_internal, content="true")
  let by_content = update(model, FileQueryInput("pointerdown"))
  let content_hits = filtered_files(by_content)
  inspect(content_hits.length(), content="1")
  inspect(content_hits[0].path, content="src/checkout/PayButton.tsx")
  let by_summary = update(model, FileQueryInput("regional VAT"))
  let summary_hits = filtered_files(by_summary)
  inspect(summary_hits.length(), content="1")
  inspect(summary_hits[0].path, content="src/tax/rules.ts")
  let none = update(model, FileQueryInput("zzz-no-file"))
  inspect(filtered_files(none).length(), content="0")
}

///|
test "enter on search opens the first result" {
  let base = update(Model::new(), SetSection(Search))
  let typed = update(base, SearchInput("tax"))
  let opened = update(typed, OpenTopSearchHit)
  inspect(opened.screen == Projects, content="true")
  inspect(opened.active == "eu-promo-checkout", content="true")
  let empty = update(update(base, SearchInput("zzzz-no-hit")), OpenTopSearchHit)
  inspect(empty.active == base.active, content="true")
}

///|
test "search arrow keys move the selection and enter opens it" {
  let base = update(Model::new(), SetSection(Search))
  let hits = filtered_search_hits(base)
  inspect(hits.length() > 1, content="true")
  let moved = update(base, MoveSearchSelection(1))
  inspect(moved.search_selected, content="1")
  let opened = update(moved, OpenTopSearchHit)
  inspect(opened.active == hits[1].id, content="true")
  let clamped = update(base, MoveSearchSelection(999))
  let last = hits.length() - 1
  inspect(clamped.search_selected, content="\{last}")
  let held = update(base, MoveSearchSelection(-1))
  inspect(held.search_selected, content="0")
  let reset = update(moved, SearchInput("tax"))
  inspect(reset.search_selected, content="0")
  let filtered = update(moved, SetSearchFilter(2))
  inspect(filtered.search_selected, content="0")
}

///|
test "task filters, mark done and new task" {
  let model = Model::new()
  let assigned = update(model, SetTaskFilter(1))
  let assigned_rows = filtered_task_indices(assigned)
  inspect(assigned_rows.length(), content="4")
  let mut all_mine = true
  for index in assigned_rows {
    if assigned.tasks[index].assignee != "you" {
      all_mine = false
    }
  }
  inspect(all_mine, content="true")
  inspect(task_assignee_label("you"), content="you")
  inspect(task_assignee_label("maya"), content="Maya")
  let needs = update(model, SetTaskFilter(2))
  let needs_rows = filtered_task_indices(needs)
  inspect(needs_rows.length(), content="2")
  let mut all_needs = true
  for index in needs_rows {
    if needs.tasks[index].status != TaskNeedsYou {
      all_needs = false
    }
  }
  inspect(all_needs, content="true")
  let slack = update(model, SetTaskSource(3))
  inspect(filtered_task_indices(slack).length(), content="1")
  let reset = update(slack, SetTaskSource(3))
  inspect(reset.task_source_filter, content="0")
  let done = update(model, MarkTaskDone(0))
  inspect(done.tasks[0].status == TaskDone, content="true")
  let done_only = update(done, SetTaskFilter(3))
  inspect(filtered_task_indices(done_only).length(), content="3")
  let empty = update(update(model, SetTaskFilter(1)), SetTaskSource(2))
  inspect(filtered_task_indices(empty).length(), content="0")
  let adding = update(
    update(model, ToggleTaskComposer),
    TaskDraftInput("Write QA checklist"),
  )
  let linear_grok = update(update(adding, CycleTaskSource), CycleTaskAgent)
  let grok = update(linear_grok, CycleTaskAgent)
  let added = update(grok, AddTask)
  inspect(added.tasks.length(), content="7")
  inspect(added.tasks[0].assignee, content="you")
  inspect(added.tasks[0].title == "Write QA checklist", content="true")
  inspect(added.tasks[0].source == LinearTask, content="true")
  inspect(added.tasks[0].agent == Grok, content="true")
  inspect(added.tasks[0].agent_model == "grok-4.7", content="true")
  inspect(added.task_selected, content="0")
}

///|
test "task composer requires a title before adding" {
  let model = Model::new()
  let opened = update(model, ToggleTaskComposer)
  inspect(task_add_blocked(opened), content="true")
  let blank = update(opened, AddTask)
  inspect(blank.task_composer_open, content="true")
  inspect(blank.tasks.length(), content="6")
  let whitespace = update(update(opened, TaskDraftInput("   ")), AddTask)
  inspect(whitespace.task_composer_open, content="true")
  inspect(whitespace.tasks.length(), content="6")
  let typing = update(opened, TaskDraftInput("Tidy QA checklist"))
  inspect(task_add_blocked(typing), content="false")
  let added = update(
    update(typing, TaskDraftInput("  Tidy QA checklist  ")),
    AddTask,
  )
  inspect(added.task_composer_open, content="false")
  inspect(added.tasks.length(), content="7")
  inspect(added.tasks[0].title, content="Tidy QA checklist")
  inspect(added.task_draft, content="")
  inspect(task_add_blocked(added), content="true")
}

///|
test "task composer height reserves room for the blank-title hint" {
  let closed = Model::new()
  inspect(task_composer_extra(closed, false) == 0.0, content="true")
  let opened = update(closed, ToggleTaskComposer)
  inspect(task_composer_extra(opened, false) == 64.0, content="true")
  inspect(task_composer_extra(opened, true) == 104.0, content="true")
  let typing = update(opened, TaskDraftInput("Fix checkout copy"))
  inspect(task_composer_extra(typing, false) == 44.0, content="true")
  inspect(task_composer_extra(typing, true) == 84.0, content="true")
}

///|
test "task composer shortens the agent label at phone widths" {
  inspect(task_composer_agent_compact(359.0), content="true")
  inspect(task_composer_agent_compact(360.0), content="false")
  inspect(
    task_composer_agent_label(modal_agent_kind(0), 320.0) == "Claude",
    content="true",
  )
  inspect(
    task_composer_agent_label(modal_agent_kind(0), 360.0) == "Claude Code",
    content="true",
  )
  inspect(
    task_composer_agent_label(modal_agent_kind(1), 320.0) == "Codex",
    content="true",
  )
}

///|
test "task search narrows the queue and done tasks can reopen" {
  let model = Model::new()
  let safari = update(model, TaskQueryInput("safari"))
  let hits = filtered_task_indices(safari)
  inspect(hits.length(), content="2")
  inspect(
    safari.tasks[hits[0]].title == "Approve the safari_pay_click rollout",
    content="true",
  )
  inspect(
    safari.tasks[hits[1]].title == "Post release notes for 4.12",
    content="true",
  )
  let none = update(safari, TaskQueryInput("zzz"))
  inspect(filtered_task_indices(none).length(), content="0")
  let cleared = update(none, TaskQueryInput(""))
  inspect(filtered_task_indices(cleared).length(), content="6")
  let done = update(model, MarkTaskDone(0))
  inspect(done.tasks[0].status == TaskDone, content="true")
  let reopened = update(done, ReopenTask(0))
  inspect(reopened.tasks[0].status == TaskNeedsYou, content="true")
  inspect(reopened.tasks[0].time == "now", content="true")
  let combined = update(
    update(model, SetTaskFilter(2)),
    TaskQueryInput("address"),
  )
  inspect(filtered_task_indices(combined).length(), content="0")
}

///|
test "task worktrees relink, unlink and survive a restart" {
  let model = scene_tasks_model()
  inspect(live_worktrees(model).length(), content="4")
  let opened = update(model, ToggleTaskWorktreeLink)
  inspect(opened.task_link_menu_open, content="true")
  inspect(opened.task_detail_open, content="true")
  let missing = update(opened, LinkTaskWorktree("missing-worktree"))
  inspect(missing.task_link_menu_open, content="true")
  inspect(missing.tasks[0].worktree_id, content="eu-promo-checkout")
  let relinked = update(opened, LinkTaskWorktree("checkout-flow-v2"))
  inspect(relinked.task_link_menu_open, content="false")
  inspect(relinked.task_detail_open, content="true")
  inspect(relinked.tasks[0].worktree_id, content="checkout-flow-v2")
  inspect(relinked.tasks[3].worktree_id, content="agent-handoff-summary")
  let unopened = update(relinked, ToggleTaskWorktreeLink)
  let unlinked = update(unopened, UnlinkTaskWorktree)
  inspect(unlinked.task_link_menu_open, content="false")
  inspect(unlinked.tasks[0].worktree_id, content="")
  let restored = match load_model_json(save_model_json(unlinked)) {
    Some(value) => value
    None => unlinked
  }
  inspect(restored.tasks[0].worktree_id, content="")
  let still_visible = update(
    update(model, ToggleTaskWorktreeLink),
    SetTaskFilter(1),
  )
  inspect(still_visible.task_link_menu_open, content="false")
  let switched = update(update(model, ToggleTaskWorktreeLink), SelectTask(1))
  inspect(switched.task_link_menu_open, content="false")
}

///|
test "task actions append to the persisted activity timeline" {
  let model = scene_tasks_model()
  inspect(model.tasks[0].activity.length(), content="4")
  inspect(model.tasks[0].activity[0].text, content="Synced from GitHub")
  inspect(model.tasks[0].activity[1].text, content="Assigned to you")
  inspect(
    model.tasks[0].activity[2].text,
    content="Linked to eu-promo-checkout",
  )
  inspect(model.tasks[0].activity[3].text, content="Waiting on your review")

  let done = update(model, MarkTaskDone(0))
  inspect(done.tasks[0].activity.length(), content="5")
  inspect(done.tasks[0].activity[4].text, content="Marked done")
  inspect(done.tasks[0].activity[4].time, content="now")
  inspect(done.tasks[0].activity[4].icon == CheckActivity, content="true")
  let repeated_done = update(done, MarkTaskDone(0))
  inspect(repeated_done.tasks[0].activity.length(), content="5")

  let reopened = update(done, ReopenTask(0))
  inspect(reopened.tasks[0].activity.length(), content="6")
  inspect(reopened.tasks[0].activity[5].text, content="Reopened")
  inspect(reopened.tasks[0].activity[5].time, content="now")
  inspect(reopened.tasks[0].activity[5].icon == PlayActivity, content="true")

  let relinked = update(
    update(model, ToggleTaskWorktreeLink),
    LinkTaskWorktree("checkout-flow-v2"),
  )
  inspect(relinked.tasks[0].activity.length(), content="5")
  inspect(
    relinked.tasks[0].activity[4].text,
    content="Linked to checkout-flow-v2",
  )
  let same_link = update(
    update(relinked, ToggleTaskWorktreeLink),
    LinkTaskWorktree("checkout-flow-v2"),
  )
  inspect(same_link.tasks[0].activity.length(), content="5")
  let unlinked = update(
    update(relinked, ToggleTaskWorktreeLink),
    UnlinkTaskWorktree,
  )
  inspect(unlinked.tasks[0].activity.length(), content="6")
  inspect(unlinked.tasks[0].activity[5].text, content="Unlinked worktree")

  let edited = update(
    update(
      update(model, EditTaskDetail),
      TaskDetailInput("Timeline-aware description"),
    ),
    SaveTaskDetail,
  )
  inspect(edited.tasks[0].activity.length(), content="5")
  inspect(edited.tasks[0].activity[4].text, content="Description updated")
  let unchanged = update(
    update(
      update(edited, EditTaskDetail),
      TaskDetailInput("Timeline-aware description"),
    ),
    SaveTaskDetail,
  )
  inspect(unchanged.tasks[0].activity.length(), content="5")

  let created = update(
    update(update(model, ToggleTaskComposer), TaskDraftInput("Timeline task")),
    AddTask,
  )
  inspect(created.tasks[0].activity.length(), content="2")
  inspect(created.tasks[0].activity[0].text, content="Task created")
  inspect(created.tasks[0].activity[1].text, content="Assigned to you")

  let restored = match load_model_json(save_model_json(unlinked)) {
    Some(value) => value
    None => unlinked
  }
  inspect(restored.tasks[0].activity.length(), content="6")
  inspect(restored.tasks[0].activity[5].text, content="Unlinked worktree")

  let legacy = match
    load_model_json(
      "{\"version\":1,\"tasks\":[{\"title\":\"Legacy task\",\"source\":\"linear\",\"status\":\"in-progress\",\"time\":\"18m\",\"worktree_id\":\"\",\"assignee\":\"maya\",\"agent\":\"codex\"}]}",
    ) {
    Some(value) => value
    None => model
  }
  inspect(legacy.tasks.length(), content="1")
  inspect(legacy.tasks[0].activity.length(), content="4")
  inspect(legacy.tasks[0].activity[0].text, content="Synced from Linear")
  inspect(legacy.tasks[0].activity[1].text, content="Assigned to Maya")
  inspect(legacy.tasks[0].activity[2].text, content="No worktree linked")
  inspect(legacy.tasks[0].activity[3].text, content="Codex is running checks")
}

///|
test "new tasks start unlinked and create a worktree from the picker" {
  let base = scene_tasks_model()
  let added = update(
    update(
      update(base, ToggleTaskComposer),
      TaskDraftInput("Create linked task"),
    ),
    AddTask,
  )
  inspect(added.tasks[0].worktree_id, content="")
  inspect(added.task_detail_open, content="true")
  inspect(added.task_filter, content="0")
  inspect(added.task_query, content="")
  let opened = update(added, ToggleTaskWorktreeLink)
  inspect(opened.task_link_menu_open, content="true")
  let primed = update(
    update(
      update(
        update(
          update(update(opened, ToggleAdvanced), CycleBaseBranch),
          CycleAgent,
        ),
        CycleTarget,
      ),
      ToggleCreateMore,
    ),
    OpenTaskWorktreeCreate,
  )
  let creating = primed
  inspect(creating.modal_open, content="true")
  inspect(creating.task_link_menu_open, content="false")
  inspect(creating.task_link_after_create, content="0")
  inspect(creating.modal_from, content="0")
  inspect(creating.modal_name == "", content="true")
  inspect(creating.modal_advanced, content="false")
  inspect(creating.modal_base_branch, content="0")
  inspect(creating.modal_agent, content="0")
  inspect(creating.modal_target, content="0")
  inspect(creating.create_more, content="false")
  let cancelled = update(creating, CloseModal)
  inspect(cancelled.task_link_after_create, content="-1")
  let named = update(
    update(opened, OpenTaskWorktreeCreate),
    NameInput("Task worktree"),
  )
  let created = update(named, CreateWorktree)
  inspect(created.modal_open, content="false")
  inspect(created.task_link_after_create, content="-1")
  inspect(created.tasks[0].worktree_id, content="task-worktree")
  inspect(
    created.tasks[0].activity[created.tasks[0].activity.length() - 1].text,
    content="Linked to task-worktree",
  )
  inspect(has_worktree(created, "task-worktree"), content="true")
  inspect(created.task_detail_open, content="true")
  inspect(created.section == Tasks, content="true")
  let restored = match load_model_json(save_model_json(created)) {
    Some(value) => value
    None => created
  }
  inspect(restored.tasks[0].worktree_id, content="task-worktree")
  let deleted = update(
    update(base, BeginDeleteWorktree("eu-promo-checkout")),
    ConfirmDeleteWorktree,
  )
  inspect(deleted.tasks[0].worktree_id, content="")
  inspect(
    deleted.tasks[0].activity[deleted.tasks[0].activity.length() - 1].text,
    content="Worktree eu-promo-checkout deleted",
  )
  let after_delete = update(
    update(update(deleted, ToggleTaskComposer), TaskDraftInput("No stale link")),
    AddTask,
  )
  inspect(after_delete.tasks[0].worktree_id, content="")
  let filtered = update(
    update(base, SetTaskFilter(3)),
    TaskQueryInput("address"),
  )
  let filtered_added = update(
    update(
      update(filtered, ToggleTaskComposer),
      TaskDraftInput("Filtered task"),
    ),
    AddTask,
  )
  inspect(filtered_added.task_filter, content="0")
  inspect(filtered_added.task_source_filter, content="0")
  inspect(filtered_added.task_query, content="")
  inspect(filtered_added.tasks[0].title, content="Filtered task")
  inspect(filtered_added.task_detail_open, content="true")
}

///|
test "search and task filter pills report live scoped counts" {
  let search = update(Model::new(), SetSection(Search))
  let all_hits = search_filter_count(search, 0)
  let worktrees = search_filter_count(search, 1)
  let bots = search_filter_count(search, 2)
  let sessions = search_filter_count(search, 3)
  let files = search_filter_count(search, 4)
  inspect(all_hits == worktrees + bots + sessions + files, content="true")
  inspect(worktrees > 0, content="true")
  inspect(files > 0, content="true")
  let file_scope = update(search, SearchInput("@checkout"))
  inspect(file_scope.search_filter, content="4")
  let unscoped = update(search, SearchInput("checkout"))
  inspect(
    search_filter_count(file_scope, 0),
    content="\{search_filter_count(unscoped, 0)}",
  )
  inspect(
    search_filter_count(file_scope, 2),
    content="\{search_filter_count(unscoped, 2)}",
  )
  inspect(
    search_filter_count(file_scope, 4),
    content="\{filtered_search_hits(file_scope).length()}",
  )
  let tasks = Model::new()
  inspect(task_filter_count(tasks, 0, 0), content="6")
  inspect(task_filter_count(tasks, 1, 0), content="4")
  inspect(task_filter_count(tasks, 2, 0), content="2")
  inspect(task_filter_count(tasks, 0, 1), content="3")
  inspect(task_filter_count(tasks, 0, 2), content="2")
  inspect(task_filter_count(tasks, 0, 3), content="1")
  let slack = update(tasks, SetTaskSource(3))
  inspect(task_filter_count(slack, 0, slack.task_source_filter), content="1")
  inspect(task_filter_count(slack, 2, slack.task_source_filter), content="1")
  let needs = update(tasks, SetTaskFilter(2))
  inspect(
    task_filter_count(needs, needs.task_filter, needs.task_source_filter),
    content="2",
  )
  inspect(
    task_filter_count(needs, needs.task_filter, 1) +
    task_filter_count(needs, needs.task_filter, 2) +
    task_filter_count(needs, needs.task_filter, 3),
    content="2",
  )
  let safari = update(tasks, TaskQueryInput("safari"))
  inspect(
    task_filter_count(safari, safari.task_filter, safari.task_source_filter),
    content="2",
  )
  let empty = update(tasks, TaskQueryInput("zzz"))
  inspect(
    task_filter_count(empty, empty.task_filter, empty.task_source_filter),
    content="0",
  )
  inspect(task_filter_count(empty, 0, 1), content="0")
}

///|
test "enter activates the selected task and automation" {
  let tasks = update(Model::new(), ActivateTaskSelection)
  inspect(tasks.task_detail_open, content="true")
  inspect(tasks.task_selected, content="0")
  let slack = update(Model::new(), SetTaskSource(3))
  let activated = update(slack, ActivateTaskSelection)
  inspect(activated.task_detail_open, content="true")
  inspect(activated.task_selected, content="1")
  let none = update(
    update(Model::new(), TaskQueryInput("zzz")),
    ActivateTaskSelection,
  )
  inspect(none.task_detail_open, content="false")
  let automations = update(Model::new(), ActivateAutomationSelection)
  inspect(automations.automation_editor_open, content="true")
  inspect(automations.automation_editor_index, content="0")
}

///|
test "page enter routes search and yields to composition and drawers" {
  let base = Model::new()
  inspect(
    enter_page_action({ ..base, screen: SearchScreen, }, false)
    is OpenTopSearchHit,
    content="true",
  )
  let search = update(
    { ..base, screen: SearchScreen, },
    enter_page_action({ ..base, screen: SearchScreen, }, false),
  )
  inspect(search.screen == Projects, content="true")
  let tasks = { ..base, screen: TasksScreen, }
  inspect(
    enter_page_action(tasks, false) is ActivateTaskSelection,
    content="true",
  )
  inspect(enter_page_action(tasks, true) is Noop, content="true")
  let composing = update(tasks, ToggleTaskComposer)
  inspect(enter_page_action(composing, false) is Noop, content="true")
  let automations = { ..base, screen: AutomationsScreen, }
  inspect(
    enter_page_action(automations, false) is ActivateAutomationSelection,
    content="true",
  )
  let editing = update(automations, EditAutomation(0))
  inspect(enter_page_action(editing, false) is Noop, content="true")
}

///|
test "page arrow navigation yields to overlays and drawers" {
  let search = { ..Model::new(), screen: SearchScreen, }
  inspect(page_arrow_blocked(search, false), content="false")
  inspect(page_arrow_blocked(search, true), content="true")
  inspect(
    page_arrow_blocked({ ..search, help_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, ctx_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, app_menu_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, modal_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, rename_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, delete_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..search, automation_editor_open: true, }, false),
    content="true",
  )
  let tasks = { ..Model::new(), screen: TasksScreen, }
  inspect(page_arrow_blocked(tasks, false), content="false")
  inspect(
    page_arrow_blocked({ ..tasks, task_composer_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..tasks, task_detail_editing: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..tasks, task_link_menu_open: true, }, false),
    content="true",
  )
  let bots = scene_bots_model()
  inspect(page_arrow_blocked(bots, false), content="false")
  inspect(
    page_arrow_blocked({ ..bots, bot_status_menu_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..bots, bot_search_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..bots, bots_options_open: true, }, false),
    content="true",
  )
  inspect(
    page_arrow_blocked({ ..bots, bots_collapsed: true, }, false),
    content="true",
  )
  let diff = scene_diff_model()
  inspect(page_arrow_blocked(diff, false), content="false")
  inspect(
    page_arrow_blocked({ ..diff, diff_file_menu_open: true, }, false),
    content="true",
  )
}

///|
test "task activity stamps offset the sync time per row" {
  let (sync, link, agent) = task_activity_stamps("12m")
  inspect(sync, content="12m")
  inspect(link, content="9m")
  inspect(agent, content="4m")
  let (kept, kept_link, kept_agent) = task_activity_stamps("now")
  inspect(kept, content="now")
  inspect(kept_link, content="now")
  inspect(kept_agent, content="now")
}

///|
test "automations toggle, run now and edit through the dialog" {
  let model = Model::new()
  let off = update(model, ToggleAutomation(0))
  inspect(off.automations[0].enabled, content="false")
  inspect(off.automations[0].status == "Off", content="true")
  let blocked = update(off, RunAutomation(0))
  inspect(blocked.automation_runs.length(), content="6")
  inspect(
    blocked.automations[0].last_run == off.automations[0].last_run,
    content="true",
  )
  let ran = update(model, RunAutomation(0))
  inspect(ran.automations[0].last_run == "just now · passed", content="true")
  inspect(ran.automation_runs.length(), content="7")
  inspect(ran.automation_runs[0].automation, content="0")
  inspect(ran.automation_runs[0].time, content="now")
  inspect(ran.automation_runs_today, content="19")
  inspect(ran.automation_passed_today, content="17")
  inspect(ran.automation_attention_today, content="2")
  inspect(automation_success_pct(model), content="89")
  inspect(automation_success_pct(ran), content="89")
  inspect(automation_runs_delta(model), content="4")
  inspect(automation_runs_delta_label(model), content="↑ 4 vs yesterday")
  inspect(automation_runs_delta_label(ran), content="↑ 5 vs yesterday")
  inspect(
    automation_runs_delta_label({ ..model, automation_runs_yesterday: 18, }),
    content="No change vs yesterday",
  )
  inspect(
    automation_runs_delta_label({ ..model, automation_runs_yesterday: 20, }),
    content="↓ 2 vs yesterday",
  )
  inspect(
    automation_success_pct({
      ..model,
      automation_runs_today: 6,
      automation_passed_today: 5,
    }),
    content="83",
  )
  inspect(
    automation_success_pct({
      ..model,
      automation_runs_today: 0,
      automation_passed_today: 0,
    }),
    content="0",
  )
  let opened = update(model, OpenAutomationEditor)
  inspect(opened.automation_editor_open, content="true")
  inspect(opened.automation_editor_index, content="-1")
  let named = update(opened, AutomationNameInput("Nightly tax sweep"))
  let scheduled = update(
    update(named, CycleAutomationSchedule),
    CycleAutomationProject,
  )
  let added = update(scheduled, SaveAutomation)
  inspect(added.automations.length(), content="5")
  inspect(added.automation_selected, content="4")
  inspect(added.automation_editor_open, content="false")
  inspect(added.automations[4].name == "Nightly tax sweep", content="true")
  inspect(added.automations[4].schedule == "Every 30 minutes", content="true")
  inspect(added.automations[4].subtitle == "acme-web · main", content="true")
  let edit = update(model, EditAutomation(0))
  inspect(edit.automation_name == model.automations[0].name, content="true")
  inspect(edit.automation_schedule, content="2")
  let renamed = update(
    update(edit, AutomationNameInput("Renamed nightly")),
    SaveAutomation,
  )
  inspect(renamed.automations[0].name == "Renamed nightly", content="true")
  inspect(
    renamed.automations[0].schedule == "Every day · 2:00 AM",
    content="true",
  )
  inspect(renamed.automations.length(), content="4")
  let deleted = update(model, DeleteAutomation(0))
  inspect(deleted.automations.length(), content="3")
  inspect(deleted.automation_selected, content="0")
  inspect(deleted.automation_runs.length(), content="4")
  inspect(deleted.automation_runs[0].automation, content="0")
  inspect(
    deleted.automation_runs[0].note == "3 PRs · 1 needs review",
    content="true",
  )
  let expanded = update(model, ToggleAutomationRuns)
  inspect(expanded.automation_runs_expanded, content="true")
}

///|
test "automation save stays open until a name is typed" {
  let model = Model::new()
  let opened = update(model, OpenAutomationEditor)
  inspect(automation_save_blocked(opened), content="true")
  let blank = update(opened, SaveAutomation)
  inspect(blank.automation_editor_open, content="true")
  inspect(blank.automation_editor_index, content="-1")
  inspect(blank.automations.length(), content="4")
  let whitespace = update(
    update(opened, AutomationNameInput("   ")),
    SaveAutomation,
  )
  inspect(whitespace.automation_editor_open, content="true")
  inspect(whitespace.automations.length(), content="4")
  let named = update(
    update(opened, AutomationNameInput("  Tax sweep  ")),
    SaveAutomation,
  )
  inspect(named.automation_editor_open, content="false")
  inspect(named.automations.length(), content="5")
  inspect(named.automations[4].name, content="Tax sweep")
  let edit = update(model, EditAutomation(0))
  let original = edit.automations[0].name
  let cleared = update(update(edit, AutomationNameInput("")), SaveAutomation)
  inspect(cleared.automation_editor_open, content="true")
  inspect(cleared.automation_editor_index, content="0")
  inspect(cleared.automations[0].name == original, content="true")
  inspect(automation_save_blocked(cleared), content="true")
  let restored = update(
    update(cleared, AutomationNameInput("Kept nightly")),
    SaveAutomation,
  )
  inspect(restored.automation_editor_open, content="false")
  inspect(restored.automations[0].name, content="Kept nightly")
  inspect(restored.automation_name, content="")
}

///|
test "deleting every automation leaves an actionable empty history" {
  let model = Model::new()
  let mut emptied = model
  let mut index = 0
  while index < model.automations.length() {
    emptied = update(emptied, DeleteAutomation(0))
    index = index + 1
  }
  inspect(emptied.automations.is_empty(), content="true")
  inspect(emptied.automation_runs.is_empty(), content="true")
  inspect(emptied.automation_selected, content="0")
  let rerun = update(emptied, RunAutomation(0))
  inspect(rerun.automation_runs.is_empty(), content="true")
  let editor = update(emptied, OpenAutomationEditor)
  inspect(editor.automation_editor_open, content="true")
  inspect(editor.automation_editor_index, content="-1")
}

///|
test "automation editor clears its draft after cancel and save" {
  let model = Model::new()
  let dirty = update(
    update(update(model, EditAutomation(0)), AutomationNameInput("Scratch")),
    CycleAutomationProject,
  )
  let cancelled = update(dirty, CloseAutomationEditor)
  inspect(cancelled.automation_editor_open, content="false")
  inspect(cancelled.automation_editor_index, content="-1")
  inspect(cancelled.automation_name, content="")
  inspect(cancelled.automation_schedule, content="0")
  inspect(cancelled.automation_project, content="0")
  let reopened = update(cancelled, OpenAutomationEditor)
  inspect(reopened.automation_name, content="")
  inspect(reopened.automation_schedule, content="0")
  inspect(reopened.automation_project, content="0")
  let edited = update(
    update(update(model, EditAutomation(0)), AutomationNameInput("Renamed")),
    SaveAutomation,
  )
  inspect(edited.automation_editor_open, content="false")
  inspect(edited.automation_editor_index, content="-1")
  inspect(edited.automation_name, content="")
  inspect(edited.automation_schedule, content="0")
  inspect(edited.automation_project, content="0")
  let fresh = update(edited, OpenAutomationEditor)
  inspect(fresh.automation_name, content="")
  inspect(fresh.automation_schedule, content="0")
  inspect(fresh.automation_project, content="0")
  let added = update(
    update(
      update(
        update(fresh, AutomationNameInput("New sweep")),
        CycleAutomationSchedule,
      ),
      CycleAutomationProject,
    ),
    SaveAutomation,
  )
  inspect(added.automation_editor_open, content="false")
  inspect(added.automation_editor_index, content="-1")
  inspect(added.automation_name, content="")
  inspect(added.automation_schedule, content="0")
  inspect(added.automation_project, content="0")
}

///|
test "disabling a running automation stops it and clears attention on pass" {
  let model = Model::new()
  let off = update(model, ToggleAutomation(2))
  inspect(off.automations[2].enabled, content="false")
  inspect(off.automations[2].status == "Off", content="true")
  inspect(off.automations[2].last_run == "Stopped · just now", content="true")
  inspect(off.automation_attention_today, content="2")
  let back_on = update(off, ToggleAutomation(2))
  inspect(back_on.automations[2].status == "On", content="true")
  inspect(
    back_on.automations[2].last_run == "Stopped · just now",
    content="true",
  )
  let ran = update(model, RunAutomation(2))
  inspect(ran.automations[2].last_run == "just now · passed", content="true")
  inspect(ran.automations[2].tone == TaskDone, content="true")
  inspect(ran.automation_attention_today, content="1")
  let again = update(ran, RunAutomation(2))
  inspect(again.automation_attention_today, content="1")
}

///|
test "host ticks arm, fire and re-arm scheduled automations" {
  let model = Model::new()
  let armed = update(model, AutomationTick(1000.0))
  inspect(armed.automation_runs.length(), content="6")
  inspect(armed.automation_clock_ms == 1000.0, content="true")
  inspect(armed.automations[0].next_run_ms > 0.0, content="true")
  inspect(armed.automations[2].next_run_ms > 0.0, content="true")
  inspect(armed.automations[3].next_run_ms == 0.0, content="true")
  inspect(automation_next_run_label(armed, 0), content="next in 1d")
  inspect(automation_next_run_label(armed, 2), content="next in 30m")
  inspect(automation_next_run_label(armed, 3), content="")
  let due = update(armed, AutomationTick(1801000.0))
  inspect(due.automation_runs.length(), content="7")
  inspect(due.automation_runs[0].automation, content="2")
  inspect(due.automations[2].last_run, content="just now · passed")
  inspect(due.automations[2].tone == TaskDone, content="true")
  inspect(due.automation_runs_today, content="19")
  inspect(due.automation_passed_today, content="17")
  inspect(due.automation_attention_today, content="1")
  inspect(automation_next_run_label(due, 2), content="next in 30m")
  let off = update(due, ToggleAutomation(2))
  inspect(off.automations[2].next_run_ms == 0.0, content="true")
  let back_on = update(off, ToggleAutomation(2))
  let rearmed = update(back_on, AutomationTick(1802000.0))
  inspect(rearmed.automations[2].next_run_ms == 3602000.0, content="true")
  let manual = update(rearmed, RunAutomation(0))
  inspect(manual.automations[0].next_run_ms > 1802000.0, content="true")
  let reloaded = match load_model_json(save_model_json(due)) {
    Some(restored) => restored
    None => due
  }
  inspect(reloaded.automations[2].next_run_ms == 0.0, content="true")
}

///|
test "sending without an open tab keeps the draft" {
  let empty = update(Model::new(), CloseTab("eu-promo-checkout"))
  inspect(empty.active == "", content="true")
  inspect(empty.tabs.is_empty(), content="true")
  let typed = update(empty, DraftInput("Any update?"))
  let sent = update(typed, Send)
  inspect(sent.draft == "Any update?", content="true")
  inspect(sent.bot_messages.length(), content="0")
}

///|
test "diff switches files, attaches notes per line and records a verdict" {
  let model = update(scene_diff_model(), SelectDiffFile(1))
  inspect(model.diff_file, content="1")
  inspect(model.diff_selected, content="0")
  inspect(diff_file_name(1) == "shipping.ts", content="true")
  inspect(diff_file_name_for(model, 1) == "shipping.ts", content="true")
  let line = update(model, SelectDiffLine(2))
  let typed = update(line, DiffDraftInput("Keep PO box check in shipping.ts"))
  let sent = update(typed, DiffSend)
  inspect(sent.diff_notes.length(), content="2")
  let found = match diff_note_text(sent) {
    Some(text) => text == "Keep PO box check in shipping.ts"
    None => false
  }
  inspect(found, content="true")
  let approved = update(sent, SetDiffVerdict(1))
  inspect(approved.diff_verdict, content="1")
}

///|
test "show diff scopes the review to the selected worktree" {
  let checkout = scene_diff_model()
  inspect(checkout.active == "checkout-flow-v2", content="true")
  inspect(
    diff_review_title(checkout) == "Tighten address validation",
    content="true",
  )
  inspect(diff_file_name_for(checkout, 0) == "validators.ts", content="true")
  let dirty = update(
    update(checkout, DiffDraftInput("Draft only for checkout")),
    SetDiffVerdict(2),
  )
  let target = update(
    dirty,
    OpenContextMenu(
      0,
      "checks-detail-link",
      -1,
      @geometry.Point::new(x=40.0, y=120.0),
    ),
  )
  let checks = update(target, ContextAction(1))
  inspect(checks.screen == DiffScreen, content="true")
  inspect(checks.active == "checks-detail-link", content="true")
  inspect(checks.diff_file, content="0")
  inspect(checks.diff_selected, content="0")
  inspect(checks.diff_anchor, content="-1")
  inspect(checks.diff_note_open, content="false")
  inspect(checks.diff_draft == "", content="true")
  inspect(checks.diff_verdict, content="0")
  inspect(checks.diff_notes.length(), content="0")
  inspect(checks.diff_messages.length(), content="0")
  inspect(checks.diff_working, content="false")
  inspect(
    diff_review_title(checks) == "Fix CI checks detail link",
    content="true",
  )
  inspect(diff_file_name_for(checks, 0) == "checks.ts", content="true")
  inspect(diff_file_name_for(checks, 1) == "checks.test.ts", content="true")
  let noted = update(
    update(checks, DiffDraftInput("Recheck the failing job link")),
    DiffSend,
  )
  let reopened = update(
    update(
      noted,
      OpenContextMenu(
        0,
        "checks-detail-link",
        -1,
        @geometry.Point::new(x=40.0, y=120.0),
      ),
    ),
    ContextAction(1),
  )
  inspect(reopened.diff_notes.length(), content="1")
  inspect(reopened.diff_messages.length(), content="2")
  inspect(reopened.diff_working, content="true")
  let back = update(
    update(
      reopened,
      OpenContextMenu(
        0,
        "checkout-flow-v2",
        -1,
        @geometry.Point::new(x=40.0, y=120.0),
      ),
    ),
    ContextAction(1),
  )
  inspect(back.active == "checkout-flow-v2", content="true")
  inspect(back.diff_worktree == "checkout-flow-v2", content="true")
  inspect(back.diff_file, content="0")
  inspect(back.diff_selected, content="6")
  inspect(back.diff_note_open, content="true")
  inspect(back.diff_notes.length(), content="1")
  inspect(back.diff_messages.length(), content="0")
  inspect(back.diff_working, content="true")
  inspect(
    diff_review_title(back) == "Tighten address validation",
    content="true",
  )
  inspect(diff_file_name_for(back, 1) == "shipping.ts", content="true")
}

///|
test "diff file switches clear note drafts from the previous file" {
  let model = scene_diff_model()
  let typed = update(model, DiffDraftInput("Draft for validators.ts"))
  let same = update(typed, SelectDiffFile(0))
  inspect(same.diff_selected, content="6")
  inspect(same.diff_note_open, content="true")
  inspect(same.diff_draft, content="Draft for validators.ts")
  let switched = update(typed, SelectDiffFile(1))
  inspect(switched.diff_file, content="1")
  inspect(switched.diff_note_open, content="false")
  inspect(switched.diff_draft, content="")
  inspect(switched.diff_notes.length(), content="1")
  let added = update(typed, AddDiffFile)
  inspect(added.diff_file, content="3")
  inspect(added.diff_note_open, content="false")
  inspect(added.diff_draft, content="")
  let closed = update(typed, CloseDiffFile(0))
  inspect(closed.diff_file, content="1")
  inspect(closed.diff_note_open, content="false")
  inspect(closed.diff_draft, content="")
}

///|
test "diff verdict chips wait for the run to stop" {
  let working = scene_diff_model()
  inspect(working.diff_working, content="true")
  inspect(diff_verdict_visible(working), content="false")
  let stopped = update(working, DiffStop)
  inspect(stopped.diff_working, content="false")
  inspect(diff_verdict_visible(stopped), content="true")
  let typed = update(
    stopped,
    DiffDraftInput("Re-check this once the run finishes"),
  )
  let resumed = update(typed, DiffSend)
  inspect(resumed.diff_working, content="true")
  inspect(diff_verdict_visible(resumed), content="false")
}

///|
test "diff arrow navigation clamps to file bounds and closes the note card" {
  let model = scene_diff_model()
  inspect(diff_line_count(model), content="13")
  let down = update(model, MoveDiffSelection(1))
  inspect(down.diff_selected, content="7")
  inspect(down.diff_note_open, content="false")
  let top = update(model, MoveDiffSelection(-999))
  inspect(top.diff_selected, content="0")
  let last = update(model, MoveDiffSelection(999))
  inspect(last.diff_selected, content="12")
  let held = update(top, MoveDiffSelection(-1))
  inspect(held.diff_selected, content="0")
  let stayed = update(scene_diff_model(), MoveDiffSelection(0))
  inspect(stayed.diff_note_open, content="true")
}

///|
test "diff notes edit in place, resend to the worker and delete" {
  let model = scene_diff_model()
  let existing = match diff_note_text(model) {
    Some(text) => text
    None => ""
  }
  inspect(
    existing == "Also reject PO boxes when shipping is express.",
    content="true",
  )
  let editing = update(model, EditDiffNote)
  inspect(editing.diff_draft == existing, content="true")
  inspect(editing.diff_note_open, content="true")
  let retyped = update(editing, DiffDraftInput("Keep the express PO box rule"))
  let saved = update(retyped, DiffSend)
  inspect(saved.diff_notes.length(), content="1")
  let replaced = match diff_note_text(saved) {
    Some(text) => text == "Keep the express PO box rule"
    None => false
  }
  inspect(replaced, content="true")
  let before = saved.diff_messages.length()
  let resent = update(saved, SendDiffNote)
  inspect(resent.diff_messages.length() == before + 2, content="true")
  inspect(resent.diff_working, content="true")
  let deleted = update(saved, DeleteDiffNote)
  inspect(deleted.diff_notes.length(), content="0")
  inspect(deleted.diff_note_open, content="false")
  inspect(deleted.diff_draft == "", content="true")
}

///|
test "shift arrows extend the diff selection into a range note" {
  let model = scene_diff_model()
  let single = update(model, SelectDiffLine(2))
  inspect(single.diff_anchor, content="-1")
  let ranged = update(single, ExtendDiffSelection(2))
  inspect(ranged.diff_anchor, content="2")
  inspect(ranged.diff_selected, content="4")
  let (lo, hi) = diff_selection_bounds(ranged)
  inspect(lo, content="2")
  inspect(hi, content="4")
  let typed = update(
    ranged,
    DiffDraftInput("This whole block needs the same guard."),
  )
  let sent = update(typed, DiffSend)
  inspect(sent.diff_notes.length(), content="2")
  let note = sent.diff_notes[1]
  inspect(note.line, content="2")
  inspect(note.end_line, content="4")
  inspect(
    diff_note_text(sent) == Some("This whole block needs the same guard."),
    content="true",
  )
  let deleted = update(sent, DeleteDiffNote)
  inspect(deleted.diff_notes.length(), content="1")
  inspect(deleted.diff_note_open, content="false")
  let collapsed = update(sent, MoveDiffSelection(1))
  inspect(collapsed.diff_anchor, content="-1")
  let clicked = update(ranged, SelectDiffLine(3))
  inspect(clicked.diff_anchor, content="-1")
}

///|
test "diff tab strip plus opens an extra file tab" {
  let base = scene_diff_model()
  inspect(diff_file_count(base), content="3")
  let added = update(base, AddDiffFile)
  inspect(diff_file_count(added), content="4")
  inspect(added.diff_file, content="3")
  inspect(added.diff_selected, content="0")
  inspect(diff_file_name(3) == "handoff.md", content="true")
}

///|
test "diff tabs focus the active file at phone widths" {
  let base = scene_diff_model()
  inspect(diff_tab_visible(base, 0, 320.0), content="true")
  inspect(diff_tab_visible(base, 1, 320.0), content="false")
  inspect(diff_tab_visible(base, 2, 320.0), content="false")
  inspect(diff_tab_visible(base, 1, 480.0), content="true")
  let four = update(base, AddDiffFile)
  inspect(four.diff_file, content="3")
  inspect(diff_tab_visible(four, 3, 480.0), content="true")
  inspect(diff_tab_visible(four, 0, 480.0), content="false")
  let switched = update(four, OpenDiffFile(0))
  inspect(diff_tab_visible(switched, 0, 480.0), content="true")
  inspect(diff_tab_visible(switched, 3, 480.0), content="false")
  inspect(
    diff_context_path_label("src/checkout/validators.ts", 320.0) ==
    "validators.ts",
    content="true",
  )
  inspect(
    diff_context_path_label("src/checkout/validators.ts", 480.0) ==
    "src/checkout/validators.ts",
    content="true",
  )
}

///|
test "diff file picker reopens closed tabs and switches open files" {
  let base = scene_diff_model()
  inspect(base.diff_closed[3], content="true")
  let opened = update(base, ToggleDiffFileMenu)
  inspect(opened.diff_file_menu_open, content="true")
  let restored = update(opened, OpenDiffFile(3))
  inspect(restored.diff_file_menu_open, content="false")
  inspect(restored.diff_file, content="3")
  inspect(diff_file_count(restored), content="4")
  let picker = update(restored, AddDiffFile)
  inspect(picker.diff_file_menu_open, content="true")
  inspect(diff_file_count(picker), content="4")
  let switched = update(restored, OpenDiffFile(0))
  inspect(switched.diff_file, content="0")
  inspect(switched.diff_selected, content="0")
  inspect(switched.diff_note_open, content="false")
  let typed = update(base, DiffDraftInput("Draft for validators.ts"))
  let menu = update(typed, ToggleDiffFileMenu)
  let other = update(menu, OpenDiffFile(1))
  inspect(other.diff_file, content="1")
  inspect(other.diff_draft, content="")
  let closed = update(opened, CloseDiffFileMenu)
  inspect(closed.diff_file_menu_open, content="false")
  let current = update(opened, OpenDiffFile(0))
  inspect(current.diff_file_menu_open, content="false")
  inspect(current.diff_selected, content="6")
  inspect(current.diff_note_open, content="true")
}

///|
test "diff file tabs close with an open-tab fallback" {
  let base = scene_diff_model()
  inspect(diff_tab_closable(base, 0), content="true")
  let closed = update(base, CloseDiffFile(0))
  inspect(diff_file_count(closed), content="2")
  inspect(closed.diff_file, content="1")
  inspect(closed.diff_selected, content="0")
  let inactive = update(closed, CloseDiffFile(2))
  inspect(diff_file_count(inactive), content="1")
  inspect(inactive.diff_file, content="1")
  let last = update(inactive, CloseDiffFile(1))
  inspect(diff_file_count(last), content="1")
  inspect(diff_tab_closable(last, 1), content="false")
  inspect(diff_tab_closable(last, 3), content="false")
  let reopened = update(last, AddDiffFile)
  inspect(diff_file_count(reopened), content="2")
  inspect(reopened.diff_file, content="0")
}

///|
test "diff toolbar focus toggle hides the chat pane" {
  let model = scene_diff_model()
  inspect(model.diff_focus, content="false")
  let focused = update(model, ToggleDiffFocus)
  inspect(focused.diff_focus, content="true")
  let split = update(focused, ToggleDiffFocus)
  inspect(split.diff_focus, content="false")
}

///|
test "diff toolbar path column leaves room for notes and hunk controls" {
  inspect(diff_toolbar_path_width(480.0) == 180.0, content="true")
  inspect(diff_toolbar_path_width(960.0) == 180.0, content="true")
  inspect(diff_toolbar_path_width(400.0) == 112.0, content="true")
  inspect(diff_toolbar_path_width(360.0) == 112.0, content="true")
}

///|
test "sidebar collapse and hover tracking" {
  let model = Model::new()
  inspect(model.sidebar_open, content="true")
  let closed = update(model, ToggleSidebar)
  inspect(closed.sidebar_open, content="false")
  let opened = update(closed, ToggleSidebar)
  inspect(opened.sidebar_open, content="true")
  let hovered = update(model, Hover("task-2", true))
  inspect(hovered.hover == "task-2", content="true")
  let out = update(hovered, Hover("task-2", false))
  inspect(out.hover == "", content="true")
  let keep = update(update(model, Hover("a", true)), Hover("b", false))
  inspect(keep.hover == "a", content="true")
}

///|
test "machines and projects collapse and expand" {
  let model = Model::new()
  let machine = update(model, ToggleMachine("mac-mini"))
  inspect(machine.collapsed_machines.length(), content="1")
  inspect(machine.collapsed_machines[0] == "mac-mini", content="true")
  let project = update(machine, ToggleProject("acme-internal"))
  inspect(project.collapsed_projects.length(), content="1")
  inspect(project.collapsed_projects[0] == "acme-internal", content="true")
  let reopened = update(project, ToggleProject("acme-internal"))
  inspect(reopened.collapsed_projects.length(), content="0")
  inspect(reopened.collapsed_machines.length(), content="1")
}

///|
test "sidebar display options collapse and expand every group" {
  let model = Model::new()
  let opened = update(model, ToggleSidebarOptions)
  inspect(opened.sidebar_options_open, content="true")
  let closed = update(opened, ToggleSidebarOptions)
  inspect(closed.sidebar_options_open, content="false")
  let collapsed = update(opened, CollapseAllWorktrees)
  inspect(collapsed.collapsed_machines.length(), content="2")
  inspect(collapsed.collapsed_projects.length(), content="2")
  inspect(collapsed.collapsed_machines[0] == "Local Mac", content="true")
  inspect(collapsed.collapsed_projects[1] == "acme-internal", content="true")
  inspect(collapsed.sidebar_options_open, content="false")
  let expanded = update(collapsed, ExpandAllWorktrees)
  inspect(expanded.collapsed_machines.length(), content="0")
  inspect(expanded.collapsed_projects.length(), content="0")
  inspect(expanded.sidebar_options_open, content="false")
}

///|
test "bots fleet controls filter, hide sessions and add bots" {
  let model = Model::new()
  let collapsed = update(model, ToggleBotsFleet)
  inspect(collapsed.bots_collapsed, content="true")
  let reopened = update(collapsed, ToggleBotsFleet)
  inspect(reopened.bots_collapsed, content="false")
  let search = update(model, ToggleBotSearch)
  inspect(search.bot_search_open, content="true")
  let filtered = update(search, BotQueryInput("watch"))
  inspect(filtered.bot_query == "watch", content="true")
  let ci_ok = match find_bot(model, "ci-watch") {
    Some(bot) => bot_matches(bot, "watch") && !bot_matches(bot, "zzz")
    None => false
  }
  inspect(ci_ok, content="true")
  let closed = update(filtered, ToggleBotSearch)
  inspect(closed.bot_search_open, content="false")
  inspect(closed.bot_query == "", content="true")
  let options = update(model, ToggleBotOptions)
  inspect(options.bots_options_open, content="true")
  let no_sessions = update(options, ToggleBotSessions)
  inspect(no_sessions.bots_show_sessions, content="false")
  let added = update(model, AddBot)
  inspect(added.bots.length(), content="7")
  inspect(added.active_bot == "relay", content="true")
  inspect(added.screen == Bots, content="true")
  let mut new_bot_home = false
  for session in added.bots[added.bots.length() - 1].sessions {
    if session.kind == Home {
      new_bot_home = true
    }
  }
  inspect(new_bot_home, content="true")
  let new_bot_empty = match added.bots[added.bots.length() - 1].item {
    Some(_) => false
    None => true
  }
  inspect(new_bot_empty, content="true")
  inspect(
    new_bot_intro(added.bots[added.bots.length() - 1]) ==
    "Relay is ready. Send a message to start its first task.",
    content="true",
  )
  let added_again = update(added, AddBot)
  inspect(added_again.bots.length(), content="8")
  inspect(added_again.active_bot == "relay-2", content="true")
  let projects = update(model, ShowProjectsOptions)
  inspect(projects.screen == Projects, content="true")
  inspect(projects.sidebar_options_open, content="true")
}

///|
test "connectors expand and toggle their connection" {
  let model = scene_bots_model()
  inspect(model.connectors.length(), content="4")
  inspect(model.connector_open, content="-1")
  let opened = update(model, ToggleConnector(1))
  inspect(opened.connector_open, content="1")
  let closed = update(opened, ToggleConnector(1))
  inspect(closed.connector_open, content="-1")
  let gmail = update(model, ToggleConnector(3))
  inspect(gmail.connector_open, content="3")
  inspect(gmail.connectors[3].connected, content="false")
  let connected = update(gmail, ToggleConnectorConnected(3))
  inspect(connected.connectors[3].connected, content="true")
  let disconnected = update(connected, ToggleConnectorConnected(0))
  inspect(disconnected.connectors[0].connected, content="false")
  let keep = update(model, ToggleConnector(9))
  inspect(keep.connector_open, content="-1")
}

///|
test "help overlay toggles and footer shortcuts route to real panels" {
  let model = scene_bots_model()
  inspect(model.help_open, content="false")
  let opened = update(model, ToggleHelp)
  inspect(opened.help_open, content="true")
  let closed = update(opened, ToggleHelp)
  inspect(closed.help_open, content="false")
  let chats = update(model, SetPanelTab(2))
  inspect(chats.panel_tab, content="2")
  let files = update(model, OpenBotItemPanel(3))
  inspect(files.panel_tab, content="3")
  inspect(files.bots_item_open, content="true")
  let options = update(model, ToggleBotOptions)
  inspect(options.bots_options_open, content="true")
}

///|
test "task detail description edits, saves and cancels" {
  let model = scene_tasks_model()
  inspect(model.task_detail_editing, content="false")
  let editing = update(model, EditTaskDetail)
  inspect(editing.task_detail_editing, content="true")
  inspect(editing.task_detail_draft == model.tasks[0].detail, content="true")
  let typed = update(
    editing,
    TaskDetailInput("Split the fix across two workers."),
  )
  let saved = update(typed, SaveTaskDetail)
  inspect(saved.task_detail_editing, content="false")
  inspect(
    saved.tasks[0].detail == "Split the fix across two workers.",
    content="true",
  )
  let blank = update(update(saved, EditTaskDetail), TaskDetailInput("   "))
  let blank_saved = update(blank, SaveTaskDetail)
  inspect(blank_saved.tasks[0].detail == "No description yet.", content="true")
  let cancelled = update(update(saved, EditTaskDetail), CancelTaskDetail)
  inspect(cancelled.task_detail_editing, content="false")
  inspect(
    cancelled.tasks[0].detail == "Split the fix across two workers.",
    content="true",
  )
  let switched = update(update(saved, EditTaskDetail), SelectTask(1))
  inspect(switched.task_detail_editing, content="false")
}

///|
test "filtering tasks settles the selection and drops stale drafts" {
  let model = Model::new()
  let editing = update(model, EditTaskDetail)
  let typed = update(editing, TaskDetailInput("Draft for the first task"))
  let still_visible = update(typed, SetTaskFilter(1))
  inspect(still_visible.task_selected, content="0")
  inspect(still_visible.task_detail_editing, content="true")
  let slack = update(typed, SetTaskSource(3))
  inspect(filtered_task_indices(slack).length(), content="1")
  inspect(slack.task_selected, content="1")
  inspect(slack.task_detail_editing, content="false")
  inspect(slack.task_detail_draft, content="")
  let needs = update(typed, SetTaskFilter(2))
  let marked = update(needs, MarkTaskDone(0))
  inspect(marked.task_selected, content="1")
  inspect(marked.task_detail_editing, content="false")
  let composer = update(typed, ToggleTaskComposer)
  inspect(composer.task_composer_open, content="true")
  inspect(composer.task_detail_open, content="false")
  inspect(composer.task_detail_editing, content="false")
  let closed = update(composer, ToggleTaskComposer)
  inspect(closed.task_composer_open, content="false")
}

///|
test "narrow tasks switch to one pane and close detail" {
  inspect(tasks_compact(1280.0), content="false")
  inspect(tasks_compact(639.0), content="true")
  inspect(shell_compact(1280.0), content="false")
  inspect(shell_compact(719.0), content="true")
  inspect(shell_compact_chrome_width() == 124.0, content="true")
  inspect(shell_tab_back_visible(191.0), content="true")
  inspect(shell_tab_forward_visible(191.0), content="false")
  inspect(shell_tab_plus_visible(191.0), content="true")
  inspect(shell_tab_forward_visible(300.0), content="true")
  inspect(shell_tab_strip_width(935.0, 2, true, true) == 300.0, content="true")
  inspect(
    shell_tab_strip_width(935.0, 1, false, false) == 375.0,
    content="true",
  )
  inspect(tab_strip_max_width(1) == 375.0, content="true")
  inspect(tab_strip_max_width(2) == 300.0, content="true")
  let promo = match find_worktree(Model::new(), "eu-promo-checkout") {
    Some(value) => value
    None => abort("missing eu-promo-checkout")
  }
  let checkout = match find_worktree(Model::new(), "checkout-flow-v2") {
    Some(value) => value
    None => abort("missing checkout-flow-v2")
  }
  inspect(worktree_has_completion(promo), content="true")
  inspect(worktree_has_completion(checkout), content="false")
  inspect(tabs_show_status_badge(375.0, promo), content="true")
  inspect(tabs_show_status_badge(89.0, promo), content="false")
  inspect(tabs_show_status_badge(375.0, checkout), content="false")
  inspect(shell_tab_strip_width(191.0, 1, true, false) == 121.0, content="true")
  inspect(shell_tab_strip_width(351.0, 1, true, true) == 251.0, content="true")
  inspect(
    shell_tab_strip_width(191.0, 1, false, false) == 151.0,
    content="true",
  )
  inspect(shell_tab_icons_visible(89.0), content="false")
  inspect(shell_tab_icons_visible(90.0), content="true")
  inspect(page_header_compact(519.0), content="true")
  inspect(page_header_compact(520.0), content="false")
  inspect(page_compact_pills(419.0), content="true")
  inspect(page_compact_pills(420.0), content="false")
  inspect(task_row_compact(519.0), content="true")
  inspect(task_row_compact(520.0), content="false")
  inspect(task_row_time_visible(379.0), content="false")
  inspect(task_row_time_visible(380.0), content="true")
  inspect(task_row_title_width(272.0) == 100.0, content="true")
  inspect(task_row_title_width(432.0) == 218.0, content="true")
  inspect(task_row_title_width(532.0) == 318.0, content="true")
  inspect(task_row_title_width(873.0) == 390.0, content="true")
  let model = scene_tasks_model()
  inspect(model.task_detail_open, content="false")
  let opened = update(model, SelectTask(1))
  inspect(opened.task_detail_open, content="true")
  inspect(opened.task_selected, content="1")
  let closed = update(opened, CloseTaskDetail)
  inspect(closed.task_detail_open, content="false")
}

///|
test "phone filter rows tighten before their counts overflow" {
  inspect(search_filters_compact(479.0), content="true")
  inspect(search_filters_compact(480.0), content="false")
  inspect(task_filter_pills_dense(359.0), content="true")
  inspect(task_filter_pills_dense(360.0), content="false")
}

///|
test "history arrows appear only after navigation has somewhere to go" {
  let model = Model::new()
  inspect(tab_back_shown(model, 960.0), content="false")
  inspect(tab_forward_shown(model, 960.0), content="false")
  let moved = update(model, SelectWorktree("checks-detail-link"))
  inspect(tab_back_shown(moved, 960.0), content="true")
  inspect(tab_forward_shown(moved, 960.0), content="false")
  let back = update(moved, GoBack)
  inspect(tab_forward_shown(back, 960.0), content="true")
  inspect(tab_forward_shown(back, 299.0), content="false")
  inspect(tab_forward_shown(back, 300.0), content="true")
}

///|
test "narrow bots use drawers and keep the chat wide" {
  inspect(bots_compact(1280.0), content="false")
  inspect(bots_compact(759.0), content="true")
  inspect(bots_compact_chrome_width() == 124.0, content="true")
  inspect(bots_tab_plus_visible(186.0), content="true")
  inspect(bots_tab_plus_visible(146.0), content="true")
  inspect(bots_tab_eng_visible(186.0, true, true), content="false")
  inspect(bots_tab_eng_visible(480.0, true, true), content="true")
  let model = scene_bots_narrow_model()
  inspect(model.sidebar_open, content="false")
  inspect(model.bots_item_open, content="false")
  inspect(
    compact_panel_width(scene_bots_model(), 480.0) == 400.0,
    content="true",
  )
  inspect(
    compact_panel_width(scene_bots_model(), 320.0) == 320.0,
    content="true",
  )
  inspect(
    compact_panel_width(scene_bots_model(), 360.0) == 360.0,
    content="true",
  )
  inspect(
    compact_panel_width(scene_bots_model(), 384.0) == 320.0,
    content="true",
  )
  inspect(
    compact_panel_width(scene_bots_model(), 400.0) == 336.0,
    content="true",
  )
  inspect(bots_panel_narrow(359.0), content="true")
  inspect(bots_panel_narrow(360.0), content="false")
  inspect(bots_status_compact(399.0), content="true")
  inspect(bots_status_compact(400.0), content="false")
  let base = scene_bots_model()
  let capped = { ..base, bots_panel_w: 500.0, }
  inspect(compact_panel_width(capped, 480.0) == 416.0, content="true")
  let panel = scene_bots_panel_narrow_model()
  inspect(panel.sidebar_open, content="false")
  inspect(panel.bots_item_open, content="true")
}

///|
test "home done-means wraps like the reference" {
  inspect(done_body_max_chars(261.0) == 49, content="true")
  let lines = done_body_lines(
    "The first tap on Pay works in Safari, and the fix is live.",
    done_body_max_chars(261.0),
  )
  inspect(lines.length() == 2, content="true")
  inspect(
    lines[0] == "The first tap on Pay works in Safari, and the fix",
    content="true",
  )
  inspect(lines[1] == "is live.", content="true")
}

///|
test "narrow diff stacks its panes" {
  inspect(diff_compact(1280.0), content="false")
  inspect(diff_compact(719.0), content="true")
  let (top, bottom) = diff_compact_pane_heights(600.0)
  inspect(top == 299.5, content="true")
  inspect(bottom == 299.5, content="true")
  inspect(diff_note_card_width(480.0, true) == 456.0, content="true")
  inspect(diff_note_card_width(480.0, false) == 360.0, content="true")
  inspect(diff_composer_placeholder(212.0) == "Ask anything…", content="true")
  inspect(diff_composer_placeholder(359.0) == "Ask anything…", content="true")
  inspect(
    diff_composer_placeholder(360.0) ==
    "Ask anything, @ to mention files, / for\ncommands",
    content="true",
  )
  inspect(
    diff_composer_placeholder(372.0) ==
    "Ask anything, @ to mention files, / for\ncommands",
    content="true",
  )
  inspect(diff_composer_overlay(429.0), content="true")
  inspect(diff_composer_overlay(430.0), content="false")
}

///|
test "user state round-trips through the persistence payload" {
  let base = Model::new()
  let selected = update(base, SelectWorktree("checks-detail-link"))
  let done = update(selected, MarkTaskDone(0))
  let edited = update(
    update(
      update(done, EditTaskDetail),
      TaskDetailInput("Land the fix in two steps."),
    ),
    SaveTaskDetail,
  )
  let automation_off = update(edited, ToggleAutomation(0))
  let automation_ran = update(automation_off, RunAutomation(1))
  let diff = update(
    update(automation_ran, DiffDraftInput("Keep the express PO box rule")),
    DiffSend,
  )
  let commented = update(
    update(diff, CommentInput("Looks good to ship.")),
    SendComment,
  )
  let chat = update(
    update(
      update(commented, SetScreen(Bots)),
      DraftInput("Please check the flake."),
    ),
    Send,
  )
  let bot_added = update(chat, AddBot)
  let connector = update(bot_added, ToggleConnectorConnected(1))
  let resized = update(
    update(connector, ResizeSidebar(300.0)),
    ResizeBotsPanel(420.0),
  )
  let model = update(resized, ToggleHelp)
  let restored = match load_model_json(save_model_json(model)) {
    Some(model) => model
    None => {
      inspect("load failed", content="loaded")
      model
    }
  }
  inspect(restored.tasks.length(), content="6")
  inspect(restored.tasks[0].assignee, content="you")
  inspect(restored.tasks[0].status == TaskDone, content="true")
  inspect(
    restored.tasks[0].detail == "Land the fix in two steps.",
    content="true",
  )
  inspect(restored.automations[0].enabled, content="false")
  inspect(
    restored.automations[1].last_run == "just now · passed",
    content="true",
  )
  inspect(restored.automation_runs.length(), content="7")
  inspect(restored.automation_runs[0].automation, content="1")
  inspect(restored.automation_runs_today, content="19")
  inspect(restored.automation_runs_yesterday, content="14")
  inspect(restored.automation_passed_today, content="17")
  inspect(restored.automation_attention_today, content="2")
  inspect(
    restored.diff_notes[0].text == "Keep the express PO box rule",
    content="true",
  )
  inspect(restored.diff_messages.length(), content="2")
  inspect(restored.comments.length(), content="1")
  inspect(restored.comments[0].text == "Looks good to ship.", content="true")
  inspect(restored.bot_messages.length(), content="2")
  inspect(restored.bots.length(), content="\{model.bots.length()}")
  inspect(restored.connectors[1].connected, content="false")
  inspect(restored.sidebar_w == 300.0, content="true")
  inspect(restored.bots_panel_w == 420.0, content="true")
  inspect(restored.screen == Bots, content="true")
  inspect(restored.active_bot == model.active_bot, content="true")
  inspect(restored.tabs.length(), content="2")
  inspect(restored.active == "checks-detail-link", content="true")
  inspect(restored.help_open, content="false")
}

///|
test "persistence rejects malformed and stale payloads" {
  inspect(load_model_json("not json") is None, content="true")
  inspect(load_model_json("{\"version\":2}") is None, content="true")
  inspect(
    load_model_json("{\"version\":1,\"tasks\":[{\"title\":3}]}") is None,
    content="true",
  )
}

///|
test "persistence keeps seed defaults for missing fields" {
  let base = Model::new()
  let restored = match load_model_json("{\"version\":1}") {
    Some(model) => model
    None => base
  }
  inspect(restored.tasks.length(), content="6")
  inspect(restored.automations.length(), content="4")
  inspect(restored.bots.length(), content="6")
  inspect(restored.tabs.length(), content="1")
  inspect(restored.active == "eu-promo-checkout", content="true")
  inspect(restored.sidebar_w == 340.0, content="true")
  inspect(restored.bots_sidebar_w == 272.0, content="true")
  inspect(restored.bots_panel_w == 400.0, content="true")
  inspect(restored.diff_notes.length(), content="1")
  inspect(restored.diff_worktree == "checkout-flow-v2", content="true")
  inspect(restored.bots[0].item_state, content="")
  inspect(bot_item_state(restored.bots[0]), content="In progress")
}

///|
test "the selected diff worktree survives a persistence round trip" {
  let checks = scene_diff_checks_model()
  let restored = match load_model_json(save_model_json(checks)) {
    Some(model) => model
    None => checks
  }
  inspect(restored.screen == DiffScreen, content="true")
  inspect(restored.active == "checks-detail-link", content="true")
  inspect(restored.diff_worktree == "checks-detail-link", content="true")
  inspect(diff_file_name_for(restored, 0) == "checks.ts", content="true")
  inspect(
    diff_review_title(restored) == "Fix CI checks detail link",
    content="true",
  )
  inspect(restored.diff_working, content="false")
  inspect(restored.diff_notes.length(), content="0")
}

///|
test "bots item overrides survive a persistence round trip" {
  let model = update(scene_bots_model(), SetBotItemState("Waiting on you"))
  let restored = match load_model_json(save_model_json(model)) {
    Some(model) => model
    None => model
  }
  inspect(restored.bots[0].item_state, content="Waiting on you")
  inspect(bot_item_state(restored.bots[0]), content="Waiting on you")
  inspect(restored.bots[1].item_state, content="")
  inspect(bot_item_state(restored.bots[1]), content="Waiting on you")
  inspect(bots_needing_you(restored), content="2")
}

///|
test "status changes append to the persisted activity history" {
  let model = scene_bots_model()
  let waiting = update(model, SetBotItemState("Waiting on you"))
  match waiting.bots[0].item {
    Some(item) => {
      inspect(item.activities.length(), content="5")
      inspect(item.activities[4].text, content="Status set to Waiting on you")
      inspect(item.activities[4].time, content="now")
    }
    None => inspect("missing item", content="#41")
  }
  let done = update(waiting, SetBotItemState("Done"))
  match done.bots[0].item {
    Some(item) => {
      inspect(item.activities.length(), content="6")
      inspect(item.activities[4].text, content="Status set to Waiting on you")
      inspect(item.activities[5].text, content="Status set to Done")
      inspect(item.activities[5].icon == CheckActivity, content="true")
    }
    None => inspect("missing item", content="#41")
  }
  let unchanged = update(done, SetBotItemState("Done"))
  match unchanged.bots[0].item {
    Some(item) => inspect(item.activities.length(), content="6")
    None => inspect("missing item", content="#41")
  }
  let restored = match load_model_json(save_model_json(unchanged)) {
    Some(model) => model
    None => unchanged
  }
  inspect(bot_item_state(restored.bots[0]), content="Done")
  match restored.bots[0].item {
    Some(item) => {
      inspect(item.activities.length(), content="6")
      inspect(item.activities[5].text, content="Status set to Done")
    }
    None => inspect("missing restored item", content="#41")
  }
}

///|
test "closing every tab survives a persistence round trip" {
  let empty = update(Model::new(), CloseTab("eu-promo-checkout"))
  let restored = match load_model_json(save_model_json(empty)) {
    Some(model) => model
    None => empty
  }
  inspect(restored.tabs.length(), content="0")
  inspect(restored.active == "", content="true")
}

///|
test "created worktrees and their transcript survive a restart" {
  let created = update(
    update(update(Model::new(), OpenModal), NameInput("Persist this worktree")),
    CreateWorktree,
  )
  let restored = match load_model_json(save_model_json(created)) {
    Some(model) => model
    None => created
  }
  inspect(has_worktree(restored, "persist-this-worktree"), content="true")
  inspect(restored.active == "persist-this-worktree", content="true")
  inspect(restored.tabs.length(), content="2")
  inspect(
    transcript_of(restored, "persist-this-worktree").length(),
    content="3",
  )
}

///|
test "renaming a worktree updates its row and tab and survives a restart" {
  let opened = update(
    Model::new(),
    BeginRenameWorktree("agent-handoff-summary"),
  )
  inspect(opened.rename_open, content="true")
  inspect(
    opened.rename_draft == "Improve agent handoff summary",
    content="true",
  )
  let blank = update(update(opened, RenameDraftInput("  ")), CommitRename)
  inspect(blank.rename_open, content="true")
  let typed = update(opened, RenameDraftInput("Handoff polish"))
  let renamed = update(typed, CommitRename)
  inspect(renamed.rename_open, content="false")
  let fields_ok = match find_worktree(renamed, "agent-handoff-summary") {
    Some(worktree) =>
      worktree.name == "Handoff polish" &&
      worktree.tab_title == "Handoff polish" &&
      worktree.branch == "feature/agent-handoff-summary"
    None => false
  }
  inspect(fields_ok, content="true")
  let restored = match load_model_json(save_model_json(renamed)) {
    Some(model) => model
    None => renamed
  }
  let restored_ok = match find_worktree(restored, "agent-handoff-summary") {
    Some(worktree) =>
      worktree.name == "Handoff polish" &&
      worktree.tab_title == "Handoff polish"
    None => false
  }
  inspect(restored_ok, content="true")
  let cancelled = update(opened, CancelRename)
  inspect(cancelled.rename_open, content="false")
  inspect(
    find_worktree(cancelled, "agent-handoff-summary") is Some(worktree) &&
    worktree.name == "Improve agent handoff summary",
    content="true",
  )
}

///|
test "rename dialog blocks an empty name" {
  let opened = update(
    Model::new(),
    BeginRenameWorktree("agent-handoff-summary"),
  )
  inspect(rename_save_blocked(opened), content="false")
  let spaces = update(opened, RenameDraftInput("   "))
  inspect(rename_save_blocked(spaces), content="true")
  let blocked = update(spaces, CommitRename)
  inspect(blocked.rename_open, content="true")
  inspect(blocked.rename_draft == "   ", content="true")
  inspect(rename_save_blocked(blocked), content="true")
  let typed = update(blocked, RenameDraftInput("  Handoff polish  "))
  inspect(rename_save_blocked(typed), content="false")
  let renamed = update(typed, CommitRename)
  inspect(renamed.rename_open, content="false")
  inspect(rename_save_blocked(renamed), content="false")
  let name_ok = match find_worktree(renamed, "agent-handoff-summary") {
    Some(worktree) => worktree.name == "Handoff polish"
    None => false
  }
  inspect(name_ok, content="true")
}

///|
test "deleting a worktree closes its tab, unlinks tasks and survives a restart" {
  let selected = update(Model::new(), SelectWorktree("agent-handoff-summary"))
  let asked = update(selected, BeginDeleteWorktree("agent-handoff-summary"))
  inspect(asked.delete_open, content="true")
  inspect(asked.delete_target == "agent-handoff-summary", content="true")
  let cancelled = update(asked, CancelDeleteWorktree)
  inspect(cancelled.delete_open, content="false")
  inspect(has_worktree(cancelled, "agent-handoff-summary"), content="true")
  let deleted = update(asked, ConfirmDeleteWorktree)
  inspect(deleted.delete_open, content="false")
  inspect(has_worktree(deleted, "agent-handoff-summary"), content="false")
  inspect(deleted.tabs.length(), content="1")
  inspect(deleted.active == "eu-promo-checkout", content="true")
  inspect(deleted.deleted_worktrees.length(), content="1")
  inspect(
    deleted.deleted_worktrees[0] == "agent-handoff-summary",
    content="true",
  )
  let mut linked = 0
  for task in deleted.tasks {
    if task.worktree_id == "agent-handoff-summary" {
      linked = linked + 1
    }
  }
  inspect(linked, content="0")
  let restored = match load_model_json(save_model_json(deleted)) {
    Some(model) => model
    None => deleted
  }
  inspect(has_worktree(restored, "agent-handoff-summary"), content="false")
  inspect(restored.tabs.length(), content="1")
  inspect(restored.active == "eu-promo-checkout", content="true")
  let recreated = update(
    update(update(restored, OpenModal), NameInput("Agent handoff summary")),
    CreateWorktree,
  )
  inspect(recreated.active == "agent-handoff-summary-2", content="true")
}

///|
test "deleting a worktree retires its files from search and the files panel" {
  let deleted = update(
    update(Model::new(), BeginDeleteWorktree("checkout-flow-v2")),
    ConfirmDeleteWorktree,
  )
  inspect(has_worktree(deleted, "checkout-flow-v2"), content="false")
  let search = update(deleted, SetSearchFilter(4))
  let hits = filtered_search_hits(search)
  inspect(hits.length(), content="4")
  let mut checkout_hit = false
  for hit in hits {
    if hit.id == "checkout-flow-v2" {
      checkout_hit = true
    }
  }
  inspect(checkout_hit, content="false")
  let files = filtered_files(deleted)
  inspect(files.length(), content="4")
  let mut checkout_file = false
  for file in files {
    if file.worktree_id == "checkout-flow-v2" {
      checkout_file = true
    }
  }
  inspect(checkout_file, content="false")
  let mention = update(deleted, DraftInput("@validators"))
  inspect(composer_menu_active(mention) is None, content="true")
}

///|
test "clearing task filters restores the full queue" {
  let filtered = update(
    update(update(Model::new(), SetTaskFilter(3)), SetTaskSource(1)),
    TaskQueryInput("zzzz-no-match"),
  )
  inspect(filtered_task_indices(filtered).is_empty(), content="true")
  let cleared = update(filtered, ClearTaskFilters)
  inspect(cleared.task_filter, content="0")
  inspect(cleared.task_source_filter, content="0")
  inspect(cleared.task_query == "", content="true")
  inspect(filtered_task_indices(cleared).length(), content="6")
}

///|
test "composer, bot display and flag preferences survive a restart" {
  let model = update(
    update(
      update(update(Model::new(), SetScreen(Bots)), CycleComposerModel),
      CycleComposerModel,
    ),
    CycleAccess,
  )
  let toggled = update(model, ToggleBotSessions)
  let selected = update(toggled, SelectBot("safari-pay-click"))
  let flagged = update(selected, ToggleFlag)
  let restored = match load_model_json(save_model_json(flagged)) {
    Some(model) => model
    None => flagged
  }
  inspect(restored.composer_model, content="2")
  inspect(restored.composer_access, content="1")
  inspect(restored.bots_show_sessions, content="false")
  inspect(restored.active_session == "safari-pay-click", content="true")
  inspect(restored.bot_chat_open, content="true")
  inspect(restored.bot_eng_open, content="true")
  inspect(bot_flag_on(restored), content="true")
  inspect(restored.flag_keys.length(), content="1")
}

///|
test "persistence drops a session from another bot" {
  let restored = match
    load_model_json(
      "{\"version\":1,\"active_bot\":\"scout\",\"active_session\":\"ci-watch-home\"}",
    ) {
    Some(model) => model
    None => Model::new()
  }
  inspect(restored.active_bot == "scout", content="true")
  inspect(restored.active_session == "", content="true")
}

///|
test "composer footer compacts before it overflows" {
  inspect(composer_footer_compact(256.0), content="true")
  inspect(composer_footer_compact(336.0), content="false")
  inspect(composer_access_short_label(0) == "Full", content="true")
  inspect(composer_access_short_label(1) == "Ask", content="true")
  inspect(composer_access_short_label(2) == "Read", content="true")
  inspect(composer_placeholder(300.0) == "Ask anything…", content="true")
  inspect(
    composer_placeholder(412.0) == "Ask anything, @ to mention files, / for…",
    content="true",
  )
  inspect(
    composer_placeholder(546.0) ==
    "Ask anything, @ to mention files, / for commands",
    content="true",
  )
}

///|
test "composer slash menu filters commands and closes after a space" {
  let base = Model::new()
  let all_commands = match composer_menu("/", base.files) {
    Some(menu) => menu.suggestions.length()
    None => 0
  }
  inspect(all_commands, content="5")
  let review = match composer_menu("/rev", base.files) {
    Some(menu) => menu.suggestions[0].insert
    None => ""
  }
  inspect(review, content="/review ")
  inspect(composer_menu("/review ", base.files) is None, content="true")
  inspect(composer_menu("please /review", base.files) is None, content="true")
}

///|
test "composer mention menu completes files and preserves the prefix" {
  let base = Model::new()
  let menu = match composer_menu("please @checkout", base.files) {
    Some(menu) => menu
    None => {
      let empty : ComposerMenu = {
        is_command: false,
        query: "",
        suggestions: [],
      }
      empty
    }
  }
  inspect(menu.is_command, content="false")
  inspect(menu.suggestions.length(), content="3")
  inspect(
    menu.suggestions[0].insert,
    content="please @src/checkout/validators.ts ",
  )
  inspect(
    composer_menu("email@example.com", base.files) is None,
    content="true",
  )
  inspect(composer_mention_trigger(""), content="@")
  inspect(composer_mention_trigger("hello"), content="hello @")
  inspect(composer_mention_trigger("hello "), content="hello @")
}

///|
test "composer completion reserves height in every chat surface" {
  let base = Model::new()
  inspect(composer_area_height(base) == 155.0, content="true")
  let commands = update(base, DraftInput("/"))
  inspect(composer_area_height(commands) > 155.0, content="true")
  let diff = update(base, DiffDraftInput("@tax"))
  inspect(diff_composer_menu_height(diff) > 0.0, content="true")
  let bots = update(base, DraftInput("/"))
  inspect(bots_composer_menu_height(bots) > 0.0, content="true")
}

///|
test "composer completion accepts arrow picks and Enter inserts them" {
  let base = Model::new()
  let typed = update(base, DraftInput("/"))
  let menu = match composer_menu(typed.draft, typed.files) {
    Some(menu) => menu
    None => {
      let empty : ComposerMenu = {
        is_command: false,
        query: "",
        suggestions: [],
      }
      empty
    }
  }
  inspect(composer_accept_index(typed, menu), content="0")
  inspect(composer_active_accept_index(typed), content="0")
  let picked = update(typed, SetComposerPick(3))
  inspect(composer_pick_index(picked, menu), content="3")
  inspect(composer_active_accept_index(picked), content="3")
  let accepted = update(picked, ComposerPick(3))
  inspect(accepted.draft, content="/explain ")
  inspect(accepted.composer_pick, content="-1")
  let moved = update(update(typed, MoveComposerPick(1)), MoveComposerPick(1))
  inspect(moved.composer_pick, content="1")
  let wrapped = update(moved, MoveComposerPick(-1))
  inspect(wrapped.composer_pick, content="0")
  let diff = update(base, DiffDraftInput("@checkout"))
  let diff_picked = update(diff, MoveDiffComposerPick(1))
  inspect(diff_composer_active_accept_index(diff_picked), content="0")
  let diff_accepted = update(diff_picked, DiffComposerPick(0))
  inspect(diff_accepted.diff_draft, content="@src/checkout/validators.ts ")
}

///|
test "completion menus only take arrows on the composer that is visible" {
  let base = Model::new()
  let projects = update(base, DraftInput("/"))
  inspect(composer_menu_keys_active(projects), content="true")
  inspect(
    composer_menu_keys_active({ ..projects, screen: SearchScreen, }),
    content="false",
  )
  let bots = { ..projects, screen: Bots, }
  inspect(composer_menu_keys_active(bots), content="true")
  inspect(
    composer_menu_keys_active({
      ..projects,
      screen: Projects,
      modal_open: true,
    }),
    content="false",
  )
  let diff = update(
    { ..base, screen: DiffScreen, diff_note_open: false, },
    DiffDraftInput("@checkout"),
  )
  inspect(diff_composer_menu_keys_active(diff), content="true")
  inspect(
    diff_composer_menu_keys_active({ ..diff, diff_note_open: true, }),
    content="false",
  )
  inspect(
    diff_composer_menu_keys_active({ ..diff, diff_focus: true, }),
    content="false",
  )
}

///|
test "Escape dismisses completion without deleting the draft" {
  let base = Model::new()
  let typed = update(base, DraftInput("/rev"))
  let dismissed = update(typed, DismissComposerMenu)
  inspect(dismissed.draft, content="/rev")
  inspect(dismissed.composer_menu_closed, content="true")
  inspect(composer_menu_active(dismissed) is None, content="true")
  inspect(composer_area_height(dismissed) == 155.0, content="true")
  let retyped = update(dismissed, DraftInput("/revi"))
  inspect(composer_menu_active(retyped) is Some(_), content="true")
  let diff = update(base, DiffDraftInput("@checkout"))
  let diff_dismissed = update(diff, DismissDiffComposerMenu)
  inspect(diff_dismissed.diff_draft, content="@checkout")
  inspect(diff_composer_menu_height(diff_dismissed) == 0.0, content="true")
  let diff_retyped = update(diff_dismissed, DiffDraftInput("@checkou"))
  inspect(diff_composer_menu_active(diff_retyped) is Some(_), content="true")
}

///|
test "hover state tracks the entered element and clears on leave" {
  let model = Model::new()
  inspect(model.hover == "", content="true")
  let tab = update(model, Hover("diff-tab-0", true))
  inspect(tab.hover == "diff-tab-0", content="true")
  let verdict = update(tab, Hover("diff-verdict-Approve", true))
  inspect(verdict.hover == "diff-verdict-Approve", content="true")
  let left = update(verdict, Hover("diff-verdict-Approve", false))
  inspect(left.hover == "", content="true")
}

///|
test "chat prose width clamps at zero and pads wrap room" {
  inspect(chat_prose_width(0.0) == 0.0, content="true")
  inspect(chat_prose_width(574.0) == 594.0, content="true")
}

///|
test "chat scroll stores user scroll and returns to latest on switch and send" {
  let scrolled = update(Model::new(), ScrollChat(42.0))
  inspect(scrolled.chat_scroll_y == 42.0, content="true")
  let selected = update(scrolled, SelectWorktree("checks-detail-link"))
  inspect(selected.chat_scroll_y == 1.0e9, content="true")
  let sent = update(update(scrolled, DraftInput("hi")), Send)
  inspect(sent.chat_scroll_y == 1.0e9, content="true")
}
