///|
/// Agent families rendered with their brand glyph.
#derive(Eq)
pub(all) enum AgentKind {
  Claude
  Codex
  Grok
}

///|
/// Lifecycle state for an agent row.
#derive(Eq)
pub(all) enum AgentStatus {
  Running
  Working
  Done
  Idle
}

///|
/// One agent working inside a worktree.
pub(all) struct Agent {
  name : String
  kind : AgentKind
  model : String
  time : String
  status : AgentStatus
}

///|
/// A conversation block inside a worktree transcript.
pub(all) enum Block {
  UserMessage(String)
  AssistantMessage(String)
  Worked(WorkedRow)
  Worker(WorkerCard)
  LiveRow(String, String)
}

///|
/// The collapsible "Worked for Ns" row.
pub(all) struct WorkedRow {
  label : String
  body : String
  expanded : Bool
}

///|
/// A worker progress card in the transcript.
pub(all) struct WorkerCard {
  name : String
  kind : AgentKind
  time : String
  body : String
  focused : Bool
}

///|
/// A worktree row in the sidebar and a tab in the strip.
pub(all) struct Worktree {
  id : String
  name : String
  branch : String
  primary : Bool
  tab_title : String
  agents : Array[Agent]
  transcript : Array[Block]
}

///|
/// Projects use either a globe or a folder glyph.
#derive(Eq)
pub(all) enum ProjectKind {
  Globe
  Folder
}

///|
/// One project inside a machine.
pub(all) struct Project {
  id : String
  name : String
  kind : ProjectKind
  worktrees : Array[Worktree]
}

///|
/// One host machine card in the sidebar.
pub(all) struct Machine {
  name : String
  host : String
  projects : Array[Project]
}

///|
/// Sidebar nav destinations. Search is the Projects home.
#derive(Eq)
pub(all) enum NavSection {
  Search
  Tasks
  Automations
  Bots
}

///|
/// Application model.
pub(all) struct Model {
  machines : Array[Machine]
  tabs : Array[String]
  active : String
  draft : String
  modal_open : Bool
  modal_name : String
  modal_from : Int32
  modal_advanced : Bool
  create_more : Bool
  section : NavSection
  screen : Screen
  bots : Array[Bot]
  active_bot : String
  active_session : String
  center_tab : Int32
  panel_tab : Int32
  comment_draft : String
  comments : Array[String]
  flag_selected : Bool
}

///|
/// Application messages.
pub(all) enum Msg {
  SelectWorktree(String)
  CloseTab(String)
  NewTab
  OpenModal
  CloseModal
  NameInput(String)
  SelectCreateFrom(Int32)
  ToggleAdvanced
  ToggleCreateMore
  CreateWorktree
  ToggleWorked(String, Int32)
  DraftInput(String)
  Send
  SetSection(NavSection)
  SetScreen(Screen)
  SelectBot(String)
  SetCenterTab(Int32)
  SetPanelTab(Int32)
  CommentInput(String)
  SendComment
  ToggleFlag
  Noop
}

///|
fn agent(
  name : String,
  kind : AgentKind,
  model : String,
  time : String,
  status : AgentStatus,
) -> Agent {
  { name, kind, model, time, status }
}

///|
fn worker(
  name : String,
  kind : AgentKind,
  time : String,
  body : String,
  focused : Bool,
) -> Block {
  Worker({ name, kind, time, body, focused })
}

///|
fn transcript_eu_promo() -> Array[Block] {
  [
    UserMessage(
      "Fix ACME-412: EU promo codes skip regional tax at checkout. Split it between a Codex worker and a Grok worker, and report back.",
    ),
    Worked({
      label: "Worked for 4s",
      body: "Started tax-rules on Codex and promo-tests on Grok. While they work, I’ll update the checkout changelog.",
      expanded: true,
    }),
    worker(
      "tax-rules",
      Codex,
      "3:09 PM",
      "Fixed. Promo discounts now apply after VAT for EU regions, and 11 tax tests pass.",
      true,
    ),
    worker(
      "promo-tests",
      Grok,
      "3:10 PM",
      "Added 8 regression tests for EU10 and EU20 across DE, FR and NL. All passing.",
      false,
    ),
    AssistantMessage(
      "Both workers are done. Promo discounts now apply after regional VAT, with 8 new regression tests. Want me to open the PR?",
    ),
    LiveRow("Working for 1s", "Working…"),
  ]
}

///|
fn transcript_checkout_flow() -> Array[Block] {
  [
    UserMessage(
      "Tighten address validation before the P0 checkout release. Focus on the address form, shipping.ts and validators.ts, then add a regression test.",
    ),
    AssistantMessage("On it — I’ll report back here when the workers finish."),
    worker(
      "address-validation",
      Codex,
      "3:42 PM",
      "P0 boxes now render inline for missing postal codes. shipping.ts no longer falls back to the billing address, and validators.ts covers 14 new cases.",
      true,
    ),
  ]
}

///|
fn transcript_handoff() -> Array[Block] {
  [
    UserMessage(
      "Improve the agent handoff summary so the next worker picks up without rereading the transcript.",
    ),
    AssistantMessage("On it — I’ll report back here when the workers finish."),
    worker(
      "handoff-copy",
      Codex,
      "2:18 PM",
      "Drafting handoff copy: the summary now leads with current status, the open question, and the exact files touched.",
      true,
    ),
  ]
}

///|
fn transcript_ci() -> Array[Block] {
  [
    UserMessage(
      "Fix the CI checks detail link so it points at the failing job instead of the workflow summary.",
    ),
    worker(
      "checks-link",
      Claude,
      "11:02 AM",
      "Updated the checks detail link to the failing job run. 38 of 38 checks pass.",
      true,
    ),
    AssistantMessage("Done — CI is green again."),
  ]
}

///|
/// The exact seed state described by the Orca reference.
pub fn Model::new() -> Model {
  let checkout_flow : Worktree = {
    id: "checkout-flow-v2",
    name: "checkout-flow-v2",
    branch: "feature/checkout-flow-v2",
    primary: true,
    tab_title: "Tighten address validation",
    agents: [
      agent("Tighten address validation", Claude, "opus-5.5", "49m", Running),
      agent("Validating EU promo codes", Codex, "gpt-6-astra", "3h", Running),
    ],
    transcript: transcript_checkout_flow(),
  }
  let eu_promo : Worktree = {
    id: "eu-promo-checkout",
    name: "eu-promo-checkout",
    branch: "fix/eu-promo-checkout",
    primary: false,
    tab_title: "Fix ACME-412: EU promo codes skip regional tax",
    agents: [
      agent("Fix ACME-412: EU promo codes…", Claude, "opus-5.5", "now", Running),
      agent("tax-rules", Codex, "gpt-6-astra", "now", Running),
      agent("promo-tests", Grok, "grok-4.7", "now", Running),
    ],
    transcript: transcript_eu_promo(),
  }
  let handoff : Worktree = {
    id: "agent-handoff-summary",
    name: "Improve agent handoff summary",
    branch: "feature/agent-handoff-summary",
    primary: false,
    tab_title: "Improve agent handoff summary",
    agents: [
      agent("Drafting handoff copy", Codex, "gpt-6-astra", "12m", Working),
    ],
    transcript: transcript_handoff(),
  }
  let checks : Worktree = {
    id: "checks-detail-link",
    name: "Fix CI checks detail link",
    branch: "fix/checks-detail-link",
    primary: false,
    tab_title: "Fix CI checks detail link",
    agents: [
      agent("Fix checks detail link", Claude, "opus-5.5", "6h", Done),
    ],
    transcript: transcript_ci(),
  }
  {
    machines: [
      {
        name: "Local Mac",
        host: "",
        projects: [
          {
            id: "acme-web",
            name: "acme-web",
            kind: Globe,
            worktrees: [checkout_flow],
          },
        ],
      },
      {
        name: "mac-mini",
        host: "mac-mini.local",
        projects: [
          {
            id: "acme-internal",
            name: "acme-internal",
            kind: Folder,
            worktrees: [eu_promo, handoff, checks],
          },
        ],
      },
    ],
    tabs: ["eu-promo-checkout"],
    active: "eu-promo-checkout",
    draft: "",
    modal_open: false,
    modal_name: "",
    modal_from: 0,
    modal_advanced: false,
    create_more: false,
    section: Search,
    screen: Projects,
    bots: bots_seed(),
    active_bot: "scout",
    active_session: "",
    center_tab: 0,
    panel_tab: 0,
    comment_draft: "",
    comments: [],
    flag_selected: false,
  }
}

///|
/// The phase-2 Bots screen at its reference state.
pub fn scene_bots_model() -> Model {
  let base = Model::new()
  { ..base, screen: Bots, }
}

///|
/// The state used by `scenes/modal`: the dialog is open with a typed name.
pub fn scene_modal_model() -> Model {
  let base = Model::new()
  {
    ..base,
    tabs: ["checkout-flow-v2"],
    active: "checkout-flow-v2",
    modal_open: true,
    modal_name: "Speed up checkout CI",
  }
}

///|
/// Look up a worktree by id across every machine and project.
pub fn find_worktree(model : Model, id : String) -> Worktree? {
  for machine in model.machines {
    for project in machine.projects {
      for worktree in project.worktrees {
        if worktree.id == id {
          return Some(worktree)
        }
      }
    }
  }
  None
}

///|
/// Whether a worktree id exists in the model.
pub fn has_worktree(model : Model, id : String) -> Bool {
  match find_worktree(model, id) {
    Some(_) => true
    None => false
  }
}

///|
/// Total worktrees, used by the machine count badge and tests.
pub fn worktree_total(model : Model) -> Int32 {
  let mut total = 0
  for machine in model.machines {
    for project in machine.projects {
      total = total + project.worktrees.length()
    }
  }
  total
}

///|
/// Worktree count for one machine card.
pub fn machine_worktree_count(machine : Machine) -> Int32 {
  let mut total = 0
  for project in machine.projects {
    total = total + project.worktrees.length()
  }
  total
}

///|
/// Lowercase, dash-separated slug for a worktree name.
pub fn slugify(name : String) -> String {
  let out : Array[Char] = []
  let mut prev_dash = true
  for c in name.to_lower().to_array() {
    let keep = (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')
    if keep {
      out.push(c)
      prev_dash = false
    } else if !prev_dash {
      out.push('-')
      prev_dash = true
    }
  }
  if !out.is_empty() && out[out.length() - 1] == '-' {
    ignore(out.pop())
  }
  if out.is_empty() {
    "new-worktree"
  } else {
    String::from_iter(out.iter())
  }
}

///|
/// True when the tab strip already contains the worktree id.
fn tabs_contain(tabs : Array[String], id : String) -> Bool {
  for tab in tabs {
    if tab == id {
      return true
    }
  }
  false
}

///|
/// Map one worktree, rebuilding the machine/project arrays around it.
fn update_worktree(
  model : Model,
  id : String,
  f : (Worktree) -> Worktree,
) -> Model {
  let machines : Array[Machine] = []
  for machine in model.machines {
    let projects : Array[Project] = []
    for project in machine.projects {
      let worktrees : Array[Worktree] = []
      for worktree in project.worktrees {
        if worktree.id == id {
          worktrees.push(f(worktree))
        } else {
          worktrees.push(worktree)
        }
      }
      projects.push({ ..project, worktrees, })
    }
    machines.push({ ..machine, projects, })
  }
  { ..model, machines, }
}

///|
/// Append a worktree to a project, rebuilding the outer arrays.
fn append_worktree(model : Model, project_id : String, worktree : Worktree) -> Model {
  let machines : Array[Machine] = []
  for machine in model.machines {
    let projects : Array[Project] = []
    for project in machine.projects {
      if project.id == project_id {
        let worktrees = project.worktrees.copy()
        worktrees.push(worktree)
        projects.push({ ..project, worktrees, })
      } else {
        projects.push(project)
      }
    }
    machines.push({ ..machine, projects, })
  }
  { ..model, machines, }
}

///|
/// The tab currently open for a worktree, opening it when needed.
fn ensure_tab(model : Model, id : String) -> Model {
  if tabs_contain(model.tabs, id) {
    { ..model, active: id, section: Search, }
  } else {
    let tabs = model.tabs.copy()
    tabs.push(id)
    { ..model, tabs, active: id, section: Search, }
  }
}

///|
/// Close one tab, falling back to the previous tab or the empty state.
fn close_tab(model : Model, id : String) -> Model {
  let mut index = -1
  let mut i = 0
  while i < model.tabs.length() {
    if model.tabs[i] == id {
      index = i
      break
    }
    i = i + 1
  }
  if index < 0 {
    return model
  }
  let tabs = model.tabs.copy()
  ignore(tabs.remove(index))
  let active = if model.active == id {
    if index > 0 {
      model.tabs[index - 1]
    } else if !tabs.is_empty() {
      tabs[0]
    } else {
      ""
    }
  } else {
    model.active
  }
  { ..model, tabs, active, }
}

///|
/// The transcript for a worktree, or an empty array.
pub fn transcript_of(model : Model, id : String) -> Array[Block] {
  match find_worktree(model, id) {
    Some(worktree) => worktree.transcript
    None => []
  }
}

///|
/// The new-worktree transcript used after the modal creates one.
fn transcript_for_new(name : String) -> Array[Block] {
  [
    UserMessage(name),
    AssistantMessage("On it — I’ll report back here when the workers finish."),
    worker(
      "worktree-setup",
      Claude,
      "now",
      "Created the worktree and started a Claude Code worker.",
      true,
    ),
  ]
}

///|
/// Pure update function.
pub fn update(model : Model, msg : Msg) -> Model {
  match msg {
    SelectWorktree(id) => {
      match find_worktree(model, id) {
        Some(_) => ensure_tab(model, id)
        None => model
      }
    }
    CloseTab(id) => close_tab(model, id)
    NewTab => { ..model, modal_open: true, modal_name: "", modal_from: 0, }
    OpenModal => { ..model, modal_open: true, }
    CloseModal => { ..model, modal_open: false, modal_name: "" }
    NameInput(text) => { ..model, modal_name: text, }
    SelectCreateFrom(index) => { ..model, modal_from: index, }
    ToggleAdvanced => { ..model, modal_advanced: !model.modal_advanced, }
    ToggleCreateMore => { ..model, create_more: !model.create_more, }
    CreateWorktree => {
      let typed = model.modal_name.trim_space().to_string()
      let name = if typed == "" {
        "Speed up checkout CI"
      } else {
        typed
      }
      let slug = slugify(name)
      let mut id = slug
      let mut suffix = 2
      while has_worktree(model, id) {
        let candidate = "\{slug}-\{suffix}"
        id = candidate
        suffix = suffix + 1
      }
      let worktree : Worktree = {
        id,
        name,
        branch: "feature/\{id}",
        primary: false,
        tab_title: name,
        agents: [
          agent("Preparing worktree", Claude, "opus-5.5", "now", Running),
        ],
        transcript: transcript_for_new(name),
      }
      let created = append_worktree(model, "acme-internal", worktree)
      let tabs = created.tabs.copy()
      tabs.push(id)
      let active = id
      if model.create_more {
        { ..created, tabs, active, section: Search, modal_name: "", }
      } else {
        {
          ..created,
          tabs,
          active,
          section: Search,
          modal_open: false,
          modal_name: "",
        }
      }
    }
    ToggleWorked(worktree_id, block_index) =>
      update_worktree(model, worktree_id, fn(worktree) {
        let blocks : Array[Block] = []
        let mut i = 0
        for block in worktree.transcript {
          if i == block_index {
            let toggled = match block {
              Worked(row) => Worked({ ..row, expanded: !row.expanded })
              other => other
            }
            blocks.push(toggled)
          } else {
            blocks.push(block)
          }
          i = i + 1
        }
        { ..worktree, transcript: blocks, }
      })
    DraftInput(text) => { ..model, draft: text, }
    Send => {
      if model.screen == Bots {
        return { ..model, draft: "", }
      }
      let text = model.draft.trim_space().to_string()
      if text == "" {
        model
      } else {
        let sent = update_worktree(model, model.active, fn(worktree) {
          let blocks = worktree.transcript.copy()
          blocks.push(UserMessage(text))
          blocks.push(
            AssistantMessage("On it — I’ll report back here when the workers finish."),
          )
          { ..worktree, transcript: blocks, }
        })
        { ..sent, draft: "", }
      }
    }
    SetSection(section) => {
      if section == Bots {
        { ..model, section, screen: Bots }
      } else {
        { ..model, section, screen: Projects }
      }
    }
    SetScreen(screen) => { ..model, screen }
    SelectBot(id) => {
      match find_bot(model, id) {
        Some(bot) =>
          { ..model, active_bot: bot.id, active_session: "", center_tab: 0, panel_tab: 0 }
        None =>
          match find_session_bot(model, id) {
            Some(bot) =>
              { ..model, active_bot: bot.id, active_session: id, center_tab: 0, panel_tab: 0 }
            None => model
          }
      }
    }
    SetCenterTab(index) => { ..model, center_tab: index }
    SetPanelTab(index) => { ..model, panel_tab: index }
    CommentInput(text) => { ..model, comment_draft: text }
    SendComment => {
      let text = model.comment_draft.trim_space().to_string()
      if text == "" {
        model
      } else {
        let comments = model.comments.copy()
        comments.push(text)
        { ..model, comments, comment_draft: "" }
      }
    }
    ToggleFlag => { ..model, flag_selected: !model.flag_selected }
    Noop => model
  }
}
