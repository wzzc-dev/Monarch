///|
test "selecting a worktree opens a tab and swaps the transcript" {
  let model = Model::new()
  inspect(model.tabs.length(), content="1")
  inspect(model.active == "eu-promo-checkout", content="true")
  inspect(transcript_of(model, "eu-promo-checkout").length(), content="6")
  let next = update(model, SelectWorktree("checks-detail-link"))
  inspect(next.tabs.length(), content="2")
  inspect(next.active == "checks-detail-link", content="true")
  inspect(next.tabs[1] == "checks-detail-link", content="true")
  inspect(transcript_of(next, "checks-detail-link").length(), content="3")
  inspect(transcript_of(next, "eu-promo-checkout").length(), content="6")
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
test "sending a message appends the user and assistant blocks and clears the draft" {
  let typed = update(Model::new(), DraftInput("Check the promo tax fix"))
  inspect(typed.draft == "Check the promo tax fix", content="true")
  let count_before = transcript_of(typed, "eu-promo-checkout").length()
  inspect(count_before, content="6")
  let sent = update(typed, Send)
  inspect(sent.draft == "", content="true")
  let count_after = transcript_of(sent, "eu-promo-checkout").length()
  inspect(count_after == count_before + 2, content="true")
  let user_ok = match transcript_of(sent, "eu-promo-checkout")[count_before] {
    UserMessage(text) => text == "Check the promo tax fix"
    _ => false
  }
  inspect(user_ok, content="true")
  let assistant_ok = match transcript_of(sent, "eu-promo-checkout")[count_before + 1] {
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
  inspect(expanded_before, content="true")
  let toggled = update(model, ToggleWorked("eu-promo-checkout", 1))
  let expanded_after = match transcript_of(toggled, "eu-promo-checkout")[1] {
    Worked(row) => row.expanded
    _ => true
  }
  inspect(expanded_after, content="false")
  let toggled_back = update(toggled, ToggleWorked("eu-promo-checkout", 1))
  let expanded_again = match transcript_of(toggled_back, "eu-promo-checkout")[1] {
    Worked(row) => row.expanded
    _ => false
  }
  inspect(expanded_again, content="true")
}

///|
test "bots screen switching and fleet selection" {
  let model = Model::new()
  inspect(model.screen == Projects, content="true")
  let bots = update(model, SetSection(Bots))
  inspect(bots.screen == Bots, content="true")
  let back = update(bots, SetSection(Search))
  inspect(back.screen == Projects, content="true")
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
test "comments append to the item activity and ignore blanks" {
  let model = scene_bots_model()
  let typed = update(model, CommentInput("  Looks good to me  "))
  let sent = update(typed, SendComment)
  inspect(sent.comments.length(), content="1")
  inspect(sent.comments[0] == "Looks good to me", content="true")
  inspect(sent.comment_draft == "", content="true")
  let blank = update(update(sent, CommentInput("   ")), SendComment)
  inspect(blank.comments.length(), content="1")
}

///|
test "the reply flag toggles" {
  let model = scene_bots_model()
  inspect(model.flag_selected, content="false")
  let on = update(model, ToggleFlag)
  inspect(on.flag_selected, content="true")
  let off = update(on, ToggleFlag)
  inspect(off.flag_selected, content="false")
}
