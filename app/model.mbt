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
/// Where a task was synced from.
#derive(Eq)
pub(all) enum TaskSource {
  GitHubTask
  LinearTask
  SlackTask
}

///|
/// Task column shown in the Tasks page.
#derive(Eq)
pub(all) enum TaskStatus {
  TaskNeedsYou
  TaskInProgress
  TaskDone
}

///|
/// One row in a task's activity timeline.
pub(all) struct TaskActivity {
  icon : ActivityIcon
  text : String
  time : String
}

///|
/// One work item on the Tasks page.
pub(all) struct Task {
  title : String
  repo : String
  labels : String
  source : TaskSource
  status : TaskStatus
  time : String
  worktree_id : String
  detail : String
  agent : AgentKind
  agent_model : String
  assignee : String
  activity : Array[TaskActivity]
}

///|
/// One scheduled agent run on the Automations page.
pub(all) struct Automation {
  name : String
  subtitle : String
  schedule : String
  schedule_index : Int32
  last_run : String
  status : String
  tone : TaskStatus
  enabled : Bool
  next_run_ms : Double
}

///|
/// One entry in the run history shown under the automations table.
pub(all) struct AutomationRun {
  automation : Int32
  state : String
  note : String
  time : String
  tone : TaskStatus
}

///|
/// A review note attached to one line of the diff.
pub(all) struct DiffNote {
  file : Int32
  line : Int32
  end_line : Int32
  text : String
}

///|
/// One indexed source file, used by the Search page's Files category.
pub(all) struct SeedFile {
  path : String
  project : String
  worktree_id : String
  summary : String
  content : String
}

///|
/// One service integration listed in the Bots Connectors tab.
pub(all) struct Connector {
  name : String
  mascot : Mascot
  account : String
  detail : String
  connected : Bool
}

///|
/// A message posted in a Bots chat, keyed by bot/tab/session.
pub(all) struct BotChatMessage {
  key : String
  block : Block
}

///|
/// A navigable location recorded by the back/forward arrows.
#derive(Eq)
pub(all) struct NavEntry {
  screen : Screen
  section : NavSection
  active : String
  active_bot : String
  active_session : String
  center_tab : Int32
  bot_chat_open : Bool
  bot_eng_open : Bool
}

///|
/// Application model.
pub(all) struct Model {
  machines : Array[Machine]
  tabs : Array[String]
  active : String
  deleted_worktrees : Array[String]
  draft : String
  dictation_target : Int32
  composer_pick : Int32
  composer_menu_closed : Bool
  chat_scroll_y : Double
  modal_open : Bool
  modal_name : String
  modal_from : Int32
  modal_advanced : Bool
  modal_base_branch : Int32
  modal_agent : Int32
  modal_target : Int32
  rename_open : Bool
  rename_target : String
  rename_draft : String
  delete_open : Bool
  delete_target : String
  create_more : Bool
  section : NavSection
  screen : Screen
  nav_back : Array[NavEntry]
  nav_forward : Array[NavEntry]
  bots : Array[Bot]
  active_bot : String
  active_session : String
  center_tab : Int32
  panel_tab : Int32
  bots_item_open : Bool
  bot_chat_open : Bool
  bot_eng_open : Bool
  bot_status_menu_open : Bool
  comment_draft : String
  comments : Array[BotComment]
  flag_keys : Array[String]
  composer_model : Int32
  composer_access : Int32
  bot_messages : Array[BotChatMessage]
  bot_item_seq : Int32
  bots_collapsed : Bool
  bot_search_open : Bool
  bot_query : String
  bots_options_open : Bool
  bots_show_sessions : Bool
  connectors : Array[Connector]
  connector_open : Int32
  search_query : String
  search_filter : Int32
  search_filter_before_scope : Int32
  search_selected : Int32
  hover : String
  sidebar_open : Bool
  sidebar_w : Double
  bots_sidebar_w : Double
  bots_panel_w : Double
  sidebar_options_open : Bool
  app_menu_open : Bool
  ctx_open : Bool
  ctx_kind : Int32
  ctx_target : String
  ctx_index : Int32
  ctx_anchor : @geometry.Point
  collapsed_machines : Array[String]
  collapsed_projects : Array[String]
  task_selected : Int32
  task_filter : Int32
  task_source_filter : Int32
  task_query : String
  task_draft : String
  task_composer_open : Bool
  task_new_source : Int32
  task_new_agent : Int32
  task_detail_editing : Bool
  task_detail_draft : String
  task_detail_open : Bool
  task_link_menu_open : Bool
  task_link_after_create : Int32
  tasks : Array[Task]
  files : Array[SeedFile]
  files_query : String
  automation_selected : Int32
  automations : Array[Automation]
  automation_runs : Array[AutomationRun]
  automation_runs_today : Int32
  automation_runs_yesterday : Int32
  automation_passed_today : Int32
  automation_attention_today : Int32
  automation_clock_ms : Double
  automation_editor_open : Bool
  automation_editor_index : Int32
  automation_name : String
  automation_schedule : Int32
  automation_project : Int32
  automation_runs_expanded : Bool
  help_open : Bool
  diff_worktree : String
  diff_selected : Int32
  diff_anchor : Int32
  diff_file : Int32
  diff_closed : Array[Bool]
  diff_focus : Bool
  diff_verdict : Int32
  diff_notes : Array[DiffNote]
  diff_note_open : Bool
  diff_file_menu_open : Bool
  diff_draft : String
  diff_composer_menu_closed : Bool
  diff_working : Bool
  diff_messages : Array[Block]
}

///|
/// Application messages.
pub(all) enum Msg {
  SelectWorktree(String)
  SelectTabAt(Int32)
  CloseTab(String)
  NewTab
  OpenModal
  CloseModal
  NameInput(String)
  SelectCreateFrom(Int32)
  ToggleAdvanced
  CycleBaseBranch
  CycleAgent
  CycleTarget
  ToggleCreateMore
  CreateWorktree
  BeginRenameWorktree(String)
  RenameDraftInput(String)
  CommitRename
  CancelRename
  BeginDeleteWorktree(String)
  ConfirmDeleteWorktree
  CancelDeleteWorktree
  ToggleWorked(String, Int32)
  ToggleWorker(String, Int32)
  DraftInput(String)
  Dictate(Int32)
  Send
  SetComposerPick(Int32)
  MoveComposerPick(Int32)
  ComposerPick(Int32)
  MoveDiffComposerPick(Int32)
  DiffComposerPick(Int32)
  DismissComposerMenu
  DismissDiffComposerMenu
  ScrollChat(Double)
  SetSection(NavSection)
  SetScreen(Screen)
  SelectBot(String)
  MoveBotSelection(Int32)
  SetCenterTab(Int32)
  CloseBotTab(Int32)
  SetPanelTab(Int32)
  ToggleBotItemPanel
  OpenBotItemPanel(Int32)
  ToggleBotsFleet
  ToggleBotSearch
  BotQueryInput(String)
  ClearBotQuery
  ToggleBotOptions
  ToggleBotSessions
  ToggleBotStatusMenu
  SetBotItemState(String)
  ToggleConnector(Int32)
  ToggleConnectorConnected(Int32)
  AddBot
  FileQueryInput(String)
  CommentInput(String)
  SendComment
  ToggleFlag
  CycleComposerModel
  CycleAccess
  SearchInput(String)
  SetSearchFilter(Int32)
  MoveSearchSelection(Int32)
  ClearSearch
  OpenTopSearchHit
  Hover(String, Bool)
  ToggleSidebar
  ResizeSidebar(Double)
  ResizeBotsSidebar(Double)
  ResizeBotsPanel(Double)
  GoBack
  GoForward
  ToggleSidebarOptions
  ToggleAppMenu
  CloseAppMenu
  OpenContextMenu(Int32, String, Int32, @geometry.Point)
  CloseContextMenu
  ContextAction(Int32)
  CollapseAllWorktrees
  ExpandAllWorktrees
  ToggleMachine(String)
  ToggleProject(String)
  SelectSearchResult(String)
  SelectTask(Int32)
  MoveTaskSelection(Int32)
  ActivateTaskSelection
  SetTaskFilter(Int32)
  SetTaskSource(Int32)
  TaskQueryInput(String)
  ClearTaskFilters
  ToggleTaskComposer
  TaskDraftInput(String)
  CycleTaskSource
  CycleTaskAgent
  AddTask
  EditTaskDetail
  TaskDetailInput(String)
  SaveTaskDetail
  CancelTaskDetail
  CloseTaskDetail
  ToggleTaskWorktreeLink
  LinkTaskWorktree(String)
  UnlinkTaskWorktree
  OpenTaskWorktreeCreate
  MarkTaskDone(Int32)
  ReopenTask(Int32)
  SelectAutomation(Int32)
  MoveAutomationSelection(Int32)
  ActivateAutomationSelection
  ToggleAutomation(Int32)
  RunAutomation(Int32)
  AutomationTick(Double)
  OpenAutomationEditor
  EditAutomation(Int32)
  CloseAutomationEditor
  AutomationNameInput(String)
  CycleAutomationSchedule
  CycleAutomationProject
  SaveAutomation
  DeleteAutomation(Int32)
  ToggleAutomationRuns
  ToggleHelp
  SelectDiffLine(Int32)
  MoveDiffSelection(Int32)
  ExtendDiffSelection(Int32)
  SelectDiffFile(Int32)
  CloseDiffFile(Int32)
  SetDiffVerdict(Int32)
  ToggleDiffNote
  ToggleDiffFileMenu
  CloseDiffFileMenu
  OpenDiffFile(Int32)
  ToggleDiffFocus
  DiffDraftInput(String)
  DiffSend
  SendDiffNote
  EditDiffNote
  DeleteDiffNote
  DiffStop
  AddDiffFile
  ShowProjects
  ShowProjectsOptions
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
  { name, kind, model, time, status, }
}

///|
fn worker(
  name : String,
  kind : AgentKind,
  time : String,
  body : String,
  focused : Bool,
) -> Block {
  Worker({ name, kind, time, body, focused, })
}

///|
/// Relative timestamps for the four seeded timeline rows, offset from the
/// task's own sync time so a detail pane never repeats one stamp four times.
pub fn task_activity_stamps(time : String) -> (String, String, String) {
  match time {
    "12m" => ("12m", "9m", "4m")
    "18m" => ("18m", "15m", "7m")
    "49m" => ("49m", "40m", "11m")
    "1h" => ("1h", "50m", "16m")
    "6h" => ("6h", "5h", "1h")
    "1d" => ("1d", "21h", "8h")
    _ => (time, time, time)
  }
}

///|
fn task_activity_entry(
  icon : ActivityIcon,
  text : String,
  time : String,
) -> TaskActivity {
  { icon, text, time, }
}

///|
/// Timeline rows for a task that predates the persisted activity field. Seed
/// tasks and older payloads use the same four-entry baseline the detail pane
/// showed before the list became stateful.
fn default_task_activity(
  source : TaskSource,
  time : String,
  assignee : String,
  worktree_id : String,
  agent : AgentKind,
  status : TaskStatus,
) -> Array[TaskActivity] {
  let (sync_time, link_time, agent_time) = task_activity_stamps(time)
  let link_text = if worktree_id == "" {
    "No worktree linked"
  } else {
    "Linked to \{worktree_id}"
  }
  let agent_text = match status {
    TaskDone => "\{agent_label(agent)} finished and reported"
    TaskInProgress => "\{agent_label(agent)} is running checks"
    TaskNeedsYou => "Waiting on your review"
  }
  [
    task_activity_entry(
      LinkActivity,
      "Synced from \{task_source_label(source)}",
      sync_time,
    ),
    task_activity_entry(
      AddActivity,
      "Assigned to \{task_assignee_label(assignee)}",
      sync_time,
    ),
    task_activity_entry(LinkActivity, link_text, link_time),
    task_activity_entry(
      if status == TaskDone {
        CheckActivity
      } else {
        PlayActivity
      },
      agent_text,
      agent_time,
    ),
  ]
}

///|
fn task_seed_item(
  title : String,
  repo : String,
  labels : String,
  source : TaskSource,
  status : TaskStatus,
  time : String,
  worktree_id : String,
  detail : String,
  agent : AgentKind,
  agent_model : String,
  assignee : String,
) -> Task {
  {
    title,
    repo,
    labels,
    source,
    status,
    time,
    worktree_id,
    detail,
    agent,
    agent_model,
    assignee,
    activity: default_task_activity(
      source, time, assignee, worktree_id, agent, status,
    ),
  }
}

///|
fn append_task_activity(
  item : Task,
  icon : ActivityIcon,
  text : String,
) -> Task {
  let activity = item.activity.copy()
  activity.push(task_activity_entry(icon, text, "now"))
  { ..item, activity, }
}

///|
fn task_seed() -> Array[Task] {
  [
    task_seed_item(
      "Fix ACME-412: EU promo codes skip regional tax",
      "acme-internal",
      "P0 · tax · checkout",
      GitHubTask,
      TaskNeedsYou,
      "12m",
      "eu-promo-checkout",
      "Promo discounts are applied before regional VAT for EU10 and EU20 carts. Split the fix between a Codex worker and a Grok worker, then add regression coverage.",
      Claude,
      "opus-5.5",
      "you",
    ),
    task_seed_item(
      "Approve the safari_pay_click rollout",
      "acme-web",
      "Safari · checkout",
      SlackTask,
      TaskNeedsYou,
      "18m",
      "checkout-flow-v2",
      "Scout has the WebKit fix ready in acme/web#1287. Decide whether to ship it to everyone or turn on the Safari-only feature flag first.",
      Claude,
      "opus-5.5",
      "you",
    ),
    task_seed_item(
      "Tighten address validation before the P0 release",
      "acme-web",
      "P0 · address · shipping",
      GitHubTask,
      TaskInProgress,
      "49m",
      "checkout-flow-v2",
      "Reject PO boxes for express shipping and make the postal-code refine run against the selected country. shipping.ts and validators.ts are both in scope.",
      Claude,
      "opus-5.5",
      "you",
    ),
    task_seed_item(
      "Improve the agent handoff summary",
      "acme-internal",
      "agents · docs",
      LinearTask,
      TaskInProgress,
      "1h",
      "agent-handoff-summary",
      "Lead the handoff with current status, the open question and the exact files touched so the next worker does not reread the transcript.",
      Codex,
      "gpt-6-astra",
      "maya",
    ),
    task_seed_item(
      "Fix the CI checks detail link",
      "acme-web",
      "CI · release",
      GitHubTask,
      TaskDone,
      "6h",
      "checks-detail-link",
      "Point the checks affordance at the failing job instead of the workflow summary. 38 of 38 checks now pass.",
      Claude,
      "opus-5.5",
      "you",
    ),
    task_seed_item(
      "Post release notes for 4.12",
      "acme-internal",
      "docs · release",
      LinearTask,
      TaskDone,
      "1d",
      "eu-promo-checkout",
      "Summarize the checkout tax fix, the Safari first-tap fix and the new regression coverage for #eng.",
      Grok,
      "grok-4.7",
      "liam",
    ),
  ]
}

///|
fn file_seed() -> Array[SeedFile] {
  [
    {
      path: "src/checkout/validators.ts",
      project: "acme-web",
      worktree_id: "checkout-flow-v2",
      summary: "Zod address validation",
      content: "name street city postalCode country refine postalPattern PO boxes express shipping",
    },
    {
      path: "src/checkout/shipping.ts",
      project: "acme-web",
      worktree_id: "checkout-flow-v2",
      summary: "Carrier rates and express delivery",
      content: "shipping rate carrier billing address express delivery",
    },
    {
      path: "src/checkout/PayButton.tsx",
      project: "acme-web",
      worktree_id: "checkout-flow-v2",
      summary: "Safari first-tap Pay fix",
      content: "pointerdown click Safari pay button sticky cart footer",
    },
    {
      path: "e2e/cart.spec.ts",
      project: "acme-web",
      worktree_id: "checkout-flow-v2",
      summary: "E2E cart and tax coverage",
      content: "playwright e2e cart tax promo EU regression",
    },
    {
      path: "src/tax/rules.ts",
      project: "acme-internal",
      worktree_id: "eu-promo-checkout",
      summary: "EU regional VAT and promo rules",
      content: "VAT promo code regional tax EU DE FR NL",
    },
    {
      path: "src/tax/promo.test.ts",
      project: "acme-internal",
      worktree_id: "eu-promo-checkout",
      summary: "EU10 and EU20 promo regressions",
      content: "promo code EU10 EU20 regression tax tests",
    },
    {
      path: "docs/handoff.md",
      project: "acme-internal",
      worktree_id: "agent-handoff-summary",
      summary: "Worker handoff summary template",
      content: "handoff summary worker report changelog",
    },
    {
      path: "src/ci/checks.ts",
      project: "acme-web",
      worktree_id: "checks-detail-link",
      summary: "CI checks detail links",
      content: "CI checks detail link workflow status",
    },
  ]
}

///|
fn connector_seed() -> Array[Connector] {
  [
    {
      name: "Slack",
      mascot: Scout,
      account: "#eng · 42 members",
      detail: "Posts task updates and review requests to #eng, and mirrors replies back into the owning bot chat.",
      connected: true,
    },
    {
      name: "Linear",
      mascot: CIWatch,
      account: "ACME · 6 open items",
      detail: "Two-way sync for ACME issues. Status changes on the Tasks page land in Linear within a few seconds.",
      connected: true,
    },
    {
      name: "GitHub",
      mascot: ReviewBuddy,
      account: "acme/web · connected",
      detail: "Opens pull requests, reads check runs and links commits back to the worktree that produced them.",
      connected: true,
    },
    {
      name: "Gmail",
      mascot: ReleaseNotes,
      account: "maya@acme.dev",
      detail: "Sends release digests and weekly automation summaries. No write access to your inbox.",
      connected: false,
    },
  ]
}

///|
fn automation_seed() -> Array[Automation] {
  [
    {
      name: "Nightly EU promo regression",
      subtitle: "acme-internal · fix/eu-promo-checkout",
      schedule: "Every day · 2:00 AM",
      schedule_index: 2,
      last_run: "12m ago · passed",
      status: "On",
      tone: TaskDone,
      enabled: true,
      next_run_ms: 0.0,
    },
    {
      name: "PR review digest",
      subtitle: "acme-web · #1287",
      schedule: "Weekdays · 9:00 AM",
      schedule_index: 3,
      last_run: "2h ago · posted",
      status: "On",
      tone: TaskDone,
      enabled: true,
      next_run_ms: 0.0,
    },
    {
      name: "Flaky checkout watcher",
      subtitle: "acme-web · e2e/cart.spec",
      schedule: "Every 30 minutes",
      schedule_index: 1,
      last_run: "Running now",
      status: "On",
      tone: TaskNeedsYou,
      enabled: true,
      next_run_ms: 0.0,
    },
    {
      name: "Release notes draft",
      subtitle: "acme-internal · release-4.12",
      schedule: "Fridays · 5:00 PM",
      schedule_index: 4,
      last_run: "3d ago · skipped",
      status: "Off",
      tone: TaskInProgress,
      enabled: false,
      next_run_ms: 0.0,
    },
  ]
}

///|
fn automation_runs_seed() -> Array[AutomationRun] {
  [
    {
      automation: 0,
      state: "passed · 2m 14s",
      note: "all 11 tax tests",
      time: "12m ago",
      tone: TaskDone,
    },
    {
      automation: 1,
      state: "posted to #eng",
      note: "3 PRs · 1 needs review",
      time: "2h ago",
      tone: TaskDone,
    },
    {
      automation: 2,
      state: "running · 1m 02s",
      note: "e2e/cart.spec on webkit",
      time: "now",
      tone: TaskNeedsYou,
    },
    {
      automation: 3,
      state: "passed · 48s",
      note: "release notes draft",
      time: "3h ago",
      tone: TaskDone,
    },
    {
      automation: 0,
      state: "passed · 6m 03s",
      note: "12 dependency bumps · 0 conflicts",
      time: "1d ago",
      tone: TaskDone,
    },
    {
      automation: 1,
      state: "failed · 20s",
      note: "broken docs anchor in README",
      time: "1d ago",
      tone: TaskInProgress,
    },
  ]
}

///|
/// Append one successful run and move the automation's next due marker. A
/// manual run with no host clock keeps the automation unarmed until the first
/// tick establishes a session timeline.
fn run_automation_at(model : Model, index : Int32, now_ms : Double) -> Model {
  let item = model.automations[index]
  let period = automation_period_ms(item.schedule_index)
  let automations = model.automations.copy()
  automations[index] = {
    ..item,
    last_run: "just now · passed",
    tone: TaskDone,
    next_run_ms: if now_ms > 0.0 && period > 0.0 {
      now_ms + period
    } else {
      0.0
    },
  }
  let attention = if item.tone == TaskNeedsYou &&
    model.automation_attention_today > 0 {
    model.automation_attention_today - 1
  } else {
    model.automation_attention_today
  }
  let runs = model.automation_runs.copy()
  runs.insert(0, {
    automation: index,
    state: "passed · 1s",
    note: item.subtitle,
    time: "now",
    tone: TaskDone,
  })
  {
    ..model,
    automations,
    automation_runs: runs,
    automation_runs_today: model.automation_runs_today + 1,
    automation_passed_today: model.automation_passed_today + 1,
    automation_attention_today: attention,
  }
}

///|
fn transcript_eu_promo() -> Array[Block] {
  [
    UserMessage(
      "Fix ACME-412: EU promo codes skip regional tax at checkout. Split it between a Codex worker and a Grok worker, and report back.",
    ),
    Worked({
      label: "Worked for 12s",
      body: "Started tax-rules on Codex and promo-tests on Grok. While they work, I’ll update the checkout changelog.",
      expanded: false,
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
  ]
}

///|
fn transcript_checkout_flow() -> Array[Block] {
  [
    UserMessage(
      "Tighten address validation before the P0 checkout release. Focus on the address form, shipping.ts and validators.ts, then add a regression test.",
    ),
    AssistantMessage(
      "On it — I’ll report back here when the workers finish.",
    ),
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
    AssistantMessage(
      "On it — I’ll report back here when the workers finish.",
    ),
    worker(
      "handoff-copy",
      Codex,
      "2:18 PM",
      "Drafting handoff copy: the summary now leads with current status, the open question, and the exact files touched.",
      true,
    ),
    LiveRow("Working for 1s", "Working…"),
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
      agent(
        "Fix ACME-412: EU promo codes…",
        Claude,
        "opus-5.5",
        "now",
        Running,
      ),
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
    agents: [agent("Fix checks detail link", Claude, "opus-5.5", "6h", Done)],
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
    deleted_worktrees: [],
    draft: "",
    dictation_target: 0,
    composer_pick: -1,
    composer_menu_closed: false,
    chat_scroll_y: 118.0,
    modal_open: false,
    modal_name: "",
    modal_from: 0,
    modal_advanced: false,
    modal_base_branch: 0,
    modal_agent: 0,
    modal_target: 0,
    rename_open: false,
    rename_target: "",
    rename_draft: "",
    delete_open: false,
    delete_target: "",
    create_more: false,
    section: Search,
    screen: Projects,
    nav_back: [],
    nav_forward: [],
    bots: bots_seed(),
    active_bot: "scout",
    active_session: "",
    center_tab: 0,
    panel_tab: 0,
    bots_item_open: true,
    bot_chat_open: true,
    bot_eng_open: true,
    bot_status_menu_open: false,
    comment_draft: "",
    comments: [],
    flag_keys: [],
    composer_model: 0,
    composer_access: 0,
    bot_messages: [],
    bot_item_seq: 43,
    bots_collapsed: false,
    bot_search_open: false,
    bot_query: "",
    bots_options_open: false,
    bots_show_sessions: true,
    connectors: connector_seed(),
    connector_open: -1,
    search_query: "",
    search_filter: 0,
    search_filter_before_scope: 0,
    search_selected: 0,
    hover: "",
    sidebar_open: true,
    sidebar_w: 340.0,
    bots_sidebar_w: 272.0,
    bots_panel_w: 400.0,
    sidebar_options_open: false,
    app_menu_open: false,
    ctx_open: false,
    ctx_kind: 0,
    ctx_target: "",
    ctx_index: -1,
    ctx_anchor: @geometry.Point::new(x=0.0, y=0.0),
    collapsed_machines: [],
    collapsed_projects: [],
    task_selected: 0,
    task_filter: 0,
    task_source_filter: 0,
    task_query: "",
    task_draft: "",
    task_composer_open: false,
    task_new_source: 0,
    task_new_agent: 0,
    task_detail_editing: false,
    task_detail_draft: "",
    task_detail_open: false,
    task_link_menu_open: false,
    task_link_after_create: -1,
    tasks: task_seed(),
    files: file_seed(),
    files_query: "",
    automation_selected: 0,
    automations: automation_seed(),
    automation_runs: automation_runs_seed(),
    automation_runs_today: 18,
    automation_runs_yesterday: 14,
    automation_passed_today: 16,
    automation_attention_today: 2,
    automation_clock_ms: 0.0,
    automation_editor_open: false,
    automation_editor_index: -1,
    automation_name: "",
    automation_schedule: 0,
    automation_project: 0,
    automation_runs_expanded: false,
    help_open: false,
    diff_worktree: "checkout-flow-v2",
    diff_selected: 6,
    diff_anchor: -1,
    diff_file: 0,
    diff_closed: [false, false, false, true],
    diff_focus: false,
    diff_verdict: 0,
    diff_notes: [
      {
        file: 0,
        line: 6,
        end_line: 6,
        text: "Also reject PO boxes when shipping is express.",
      },
    ],
    diff_note_open: true,
    diff_file_menu_open: false,
    diff_draft: "",
    diff_composer_menu_closed: false,
    diff_working: true,
    diff_messages: [],
  }
}

///|
/// The phase-2 Bots screen at its reference state.
pub fn scene_bots_model() -> Model {
  let base = Model::new()
  { ..base, screen: Bots, }
}

///|
/// The Bots Home panel with the status menu open and Scout waiting on the
/// owner, showing the item-state override end to end.
pub fn scene_bots_status_model() -> Model {
  let base = scene_bots_model()
  let opened = update(base, ToggleBotStatusMenu)
  let waiting = update(opened, SetBotItemState("Waiting on you"))
  { ..waiting, bot_status_menu_open: true, }
}

///|
/// The Bots composer after the local dictation demo inserted its sample phrase.
pub fn scene_bots_dictation_model() -> Model {
  let base = scene_bots_model()
  {
    ..base,
    draft: dictation_phrase(dictation_main),
    dictation_target: dictation_main,
  }
}

///|
/// The Bots screen at a narrow viewport: fleet and item panel tucked away so
/// the chat owns the window.
pub fn scene_bots_narrow_model() -> Model {
  let base = scene_bots_model()
  { ..base, sidebar_open: false, bots_item_open: false, }
}

///|
/// The Bots screen at a narrow viewport with the Home item panel open.
pub fn scene_bots_panel_narrow_model() -> Model {
  let base = scene_bots_model()
  { ..base, sidebar_open: false, bots_item_open: true, }
}

///|
/// The Bots Files panel with a query that matches indexed code content.
pub fn scene_bots_files_model() -> Model {
  let base = scene_bots_model()
  { ..base, panel_tab: 3, bots_item_open: true, files_query: "pointerdown", }
}

///|
/// The Search page at a representative typed query.
pub fn scene_search_model() -> Model {
  let base = Model::new()
  { ..base, screen: SearchScreen, section: Search, search_query: "checkout", }
}

///|
/// Search page showing the `@` file scope with a matching query.
pub fn scene_search_files_model() -> Model {
  let base = Model::new()
  {
    ..base,
    screen: SearchScreen,
    section: Search,
    search_query: "@checkout",
    search_filter: 4,
  }
}

///|
/// The Search page at a narrow viewport with the sidebar drawer closed.
pub fn scene_search_narrow_model() -> Model {
  let base = scene_search_model()
  { ..base, sidebar_open: false, }
}

///|
/// The default Projects workspace at a phone width with the drawer tucked away.
pub fn scene_hero_narrow_model() -> Model {
  { ..Model::new(), sidebar_open: false, }
}

///|
/// The default Projects workspace with the wordmark page menu open.
pub fn scene_app_menu_model() -> Model {
  { ..Model::new(), app_menu_open: true, }
}

///|
/// Projects with the keyboard-shortcuts card open.
pub fn scene_help_model() -> Model {
  { ..Model::new(), help_open: true, }
}

///|
/// Projects scene with the composer's `/` command picker open.
pub fn scene_composer_commands_model() -> Model {
  { ..Model::new(), draft: "/", }
}

///|
/// Projects scene with the composer's `@` file picker filtered by checkout.
pub fn scene_composer_mentions_model() -> Model {
  { ..Model::new(), draft: "please @checkout", }
}

///|
/// The Tasks page with the P0 address task selected.
pub fn scene_tasks_model() -> Model {
  let base = Model::new()
  { ..base, screen: TasksScreen, section: Tasks, }
}

///|
/// The Tasks page with the worktree chooser open on the P0 address task.
pub fn scene_tasks_link_model() -> Model {
  let base = scene_tasks_model()
  { ..base, task_detail_open: true, task_link_menu_open: true, }
}

///|
/// The Tasks worktree chooser at phone width, where the list pane collapses
/// into a single full-width detail column.
pub fn scene_tasks_link_phone_model() -> Model {
  let base = scene_tasks_link_model()
  { ..base, sidebar_open: false, }
}

///|
/// The Tasks page in its narrow single-pane layout: sidebar tucked away and
/// the selected task's detail open.
pub fn scene_tasks_narrow_model() -> Model {
  let base = scene_tasks_model()
  { ..base, sidebar_open: false, task_detail_open: true, }
}

///|
/// The Tasks page at a narrow viewport showing the list pane (detail closed).
pub fn scene_tasks_list_narrow_model() -> Model {
  let base = scene_tasks_model()
  { ..base, sidebar_open: false, task_detail_open: false, }
}

///|
/// The Automations page at its default selected row.
pub fn scene_automations_model() -> Model {
  let base = Model::new()
  { ..base, screen: AutomationsScreen, section: Automations, }
}

///|
/// The Automations page after the first host tick has armed every enabled
/// schedule, showing the live next-due labels without firing a run yet.
pub fn scene_automations_scheduled_model() -> Model {
  let base = scene_automations_model()
  update(base, AutomationTick(1000.0))
}

///|
/// The Automations page with no automations and no run history, showing the
/// actionable empty states for both cards.
pub fn scene_automations_empty_model() -> Model {
  let base = scene_automations_model()
  {
    ..base,
    automations: [],
    automation_runs: [],
    automation_selected: 0,
    automation_runs_today: 0,
    automation_runs_yesterday: 0,
    automation_passed_today: 0,
    automation_attention_today: 0,
  }
}

///|
/// The Automations page at a narrow viewport with the sidebar drawer closed.
pub fn scene_automations_narrow_model() -> Model {
  let base = scene_automations_model()
  { ..base, sidebar_open: false, }
}

///|
/// The automations page with the create dialog open and a name typed.
pub fn scene_automation_editor_model() -> Model {
  let base = scene_automations_model()
  {
    ..base,
    automation_editor_open: true,
    automation_editor_index: -1,
    automation_name: "Nightly EU promo regression",
    automation_schedule: 2,
    automation_project: 0,
  }
}

///|
/// The diff review screen with the line note open.
pub fn scene_diff_model() -> Model {
  let base = Model::new()
  {
    ..base,
    screen: DiffScreen,
    section: Search,
    tabs: ["checkout-flow-v2"],
    active: "checkout-flow-v2",
    diff_selected: 6,
    diff_note_open: true,
  }
}

///|
/// The diff review for the completed CI checks worktree, reached through the
/// same context-menu path as the live app.
pub fn scene_diff_checks_model() -> Model {
  open_diff_worktree(Model::new(), "checks-detail-link")
}

///|
/// The diff review screen with the plus-button file picker open.
pub fn scene_diff_files_model() -> Model {
  let base = scene_diff_model()
  { ..base, diff_file_menu_open: true, diff_note_open: false, }
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
/// The create dialog with its Advanced section open on a non-default base.
pub fn scene_modal_advanced_model() -> Model {
  let base = scene_modal_model()
  { ..base, modal_advanced: true, modal_base_branch: 1, }
}

///|
/// Projects with the rename dialog open on the handoff worktree.
pub fn scene_rename_worktree_model() -> Model {
  let base = Model::new()
  {
    ..base,
    rename_open: true,
    rename_target: "agent-handoff-summary",
    rename_draft: "Improve agent handoff summary",
  }
}

///|
/// Projects with the delete confirmation open on the handoff worktree.
pub fn scene_delete_worktree_model() -> Model {
  update(Model::new(), BeginDeleteWorktree("agent-handoff-summary"))
}

///|
/// Projects with the worktree context menu open over the sidebar.
pub fn scene_worktree_menu_model() -> Model {
  {
    ..Model::new(),
    ctx_open: true,
    ctx_kind: 0,
    ctx_target: "agent-handoff-summary",
    ctx_anchor: @geometry.Point::new(x=250.0, y=518.0),
  }
}

///|
/// Identifies the currently-open Bots chat so composer messages stay scoped.
pub fn bot_chat_key(model : Model) -> String {
  let session = if model.active_session == "" {
    match active_bot_of(model) {
      Some(bot) => bot_home_session_id(bot)
      None => ""
    }
  } else {
    model.active_session
  }
  "\{model.active_bot}:\{model.center_tab}:\{session}"
}

///|
/// The first Home session of a bot, or an empty id when it has none.
fn bot_home_session_id(bot : Bot) -> String {
  for session in bot.sessions {
    if session.kind == Home {
      return session.id
    }
  }
  ""
}

///|
/// Whether the active bot chat already has a message in its current scope.
pub fn bot_chat_has_messages(model : Model) -> Bool {
  let key = bot_chat_key(model)
  for message in model.bot_messages {
    if message.key == key {
      return true
    }
  }
  false
}

///|
/// Whether the active bot still shows its first-message introduction.
pub fn bot_chat_waiting(model : Model) -> Bool {
  match active_bot_of(model) {
    Some(bot) =>
      match bot.item {
        None => !bot_chat_has_messages(model)
        Some(_) => false
      }
    None => false
  }
}

///|
/// Empty Home panel copy for a bot that has no work item yet.
pub fn bot_home_empty_copy(model : Model, bot : Bot) -> String {
  if bot_chat_has_messages(model) {
    "\{bot.name} has started in Home Chat. Open it to continue the thread."
  } else {
    "Start a Home Chat with \{bot.name} to give it something to work on."
  }
}

///|
/// Comments belong to the active bot's Home item, not to the center tab the
/// user happens to be reading.
pub fn bot_comment_key(model : Model) -> String {
  model.active_bot
}

///|
/// The reply flag is a decision about the active bot's item, so it follows the
/// bot across its Scout and #eng tabs.
pub fn bot_flag_key(model : Model) -> String {
  model.active_bot
}

///|
/// Whether the active bot has its reply flag turned on.
pub fn bot_flag_on(model : Model) -> Bool {
  let key = bot_flag_key(model)
  let mut on = false
  for entry in model.flag_keys {
    if entry == key {
      on = true
    }
  }
  on
}

///|
/// Toggle the reply flag for the active Bots chat only.
fn toggle_bot_flag(model : Model) -> Model {
  let key = bot_flag_key(model)
  let keys : Array[String] = []
  let mut found = false
  for entry in model.flag_keys {
    if entry == key {
      found = true
    } else {
      keys.push(entry)
    }
  }
  if !found {
    keys.push(key)
  }
  { ..model, flag_keys: keys, }
}

///|
/// Whether the selected Bots center tab is still open.
pub fn bots_tab_open(model : Model) -> Bool {
  if model.center_tab == 0 {
    model.bot_chat_open
  } else if model.center_tab == 1 {
    match active_bot_of(model) {
      Some(bot) => bot.id == "scout" && model.bot_eng_open
      None => false
    }
  } else {
    false
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
/// Indexed files whose owning worktree is still present. Deleting a worktree
/// must also retire its files from Search, the Files panel and @ mentions;
/// otherwise the rows remain visible but can no longer open a destination.
fn live_files(model : Model) -> Array[SeedFile] {
  let out : Array[SeedFile] = []
  for file in model.files {
    if find_worktree(model, file.worktree_id) is Some(_) {
      out.push(file)
    }
  }
  out
}

///|
/// Every worktree still present, in sidebar order. Used by the Tasks detail
/// pane's worktree picker so a link can only point at a live destination.
pub fn live_worktrees(model : Model) -> Array[Worktree] {
  let out : Array[Worktree] = []
  for machine in model.machines {
    for project in machine.projects {
      for worktree in project.worktrees {
        out.push(worktree)
      }
    }
  }
  out
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
/// Sidebar widths stay within the range Orca supports for its left rail.
pub fn clamp_sidebar_width(width : Double) -> Double {
  if width < 220.0 {
    220.0
  } else if width > 380.0 {
    380.0
  } else {
    width
  }
}

///|
/// The Bots fleet rail keeps the same 220–380 px desktop bounds.
pub fn clamp_bots_sidebar_width(width : Double) -> Double {
  clamp_sidebar_width(width)
}

///|
/// The Bots item panel can grow wider than the fleet rail for long content.
pub fn clamp_bots_panel_width(width : Double) -> Double {
  if width < 320.0 {
    320.0
  } else if width > 480.0 {
    480.0
  } else {
    width
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
/// True when a worktree has settled: a worker finished successfully or the
/// transcript's assistant turn reports a completed handoff.
pub fn worktree_has_completion(worktree : Worktree) -> Bool {
  for agent in worktree.agents {
    if agent.status == Done {
      return true
    }
  }
  for block in worktree.transcript {
    let settled = match block {
      AssistantMessage(text) => {
        let folded = text.to_lower()
        folded.find("done") is Some(_) || folded.find("finished") is Some(_)
      }
      _ => false
    }
    if settled {
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
fn append_worktree(
  model : Model,
  project_id : String,
  worktree : Worktree,
) -> Model {
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
    { ..model, active: id, section: Search, screen: Projects, }
  } else {
    let tabs = model.tabs.copy()
    tabs.push(id)
    { ..model, tabs, active: id, section: Search, screen: Projects, }
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
/// True when a worktree was deleted in this profile.
fn deleted_has(ids : Array[String], id : String) -> Bool {
  for deleted in ids {
    if deleted == id {
      return true
    }
  }
  false
}

///|
/// Remove a worktree from its project, unlink tasks that pointed at it and
/// remember its id so the seed merge does not resurrect it after a restart.
fn delete_worktree(model : Model, id : String) -> Model {
  if !has_worktree(model, id) {
    return model
  }
  let machines : Array[Machine] = []
  for machine in model.machines {
    let projects : Array[Project] = []
    for project in machine.projects {
      let worktrees : Array[Worktree] = []
      for worktree in project.worktrees {
        if worktree.id != id {
          worktrees.push(worktree)
        }
      }
      projects.push({ ..project, worktrees, })
    }
    machines.push({ ..machine, projects, })
  }
  let tasks : Array[Task] = []
  for task in model.tasks {
    if task.worktree_id == id {
      let next = append_task_activity(
        task,
        LinkActivity,
        "Worktree \{id} deleted",
      )
      tasks.push({ ..next, worktree_id: "", })
    } else {
      tasks.push(task)
    }
  }
  let deleted = model.deleted_worktrees.copy()
  if !deleted_has(deleted, id) {
    deleted.push(id)
  }
  let stripped = {
    ..model,
    machines,
    tasks,
    deleted_worktrees: deleted,
    delete_open: false,
    delete_target: "",
    ctx_open: false,
  }
  close_tab(stripped, id)
}

///|
/// Close one diff file tab, keeping at least one open and moving the active
/// file to the next open tab when the closed tab was showing.
fn close_diff_file(model : Model, index : Int32) -> Model {
  if !diff_tab_closable(model, index) {
    return model
  }
  let closed = model.diff_closed.copy()
  closed[index] = true
  if model.diff_file != index {
    return { ..model, diff_closed: closed, }
  }
  let mut fallback = -1
  let mut next = index + 1
  while next < closed.length() {
    if !closed[next] {
      fallback = next
      break
    }
    next = next + 1
  }
  if fallback < 0 {
    let mut previous = index - 1
    while previous >= 0 {
      if !closed[previous] {
        fallback = previous
        break
      }
      previous = previous - 1
    }
  }
  {
    ..model,
    diff_closed: closed,
    diff_file: fallback,
    diff_selected: 0,
    diff_anchor: -1,
    diff_note_open: false,
    diff_draft: "",
  }
}

///|
/// Closed-tab defaults for each worktree's four-file review. All profiles keep
/// four slots so the persisted tab mask stays compatible across worktrees.
fn diff_seed_closed(worktree : String) -> Array[Bool] {
  match worktree {
    "agent-handoff-summary" => [false, false, true, true]
    _ => [false, false, false, true]
  }
}

///|
/// Review notes a worktree's diff starts with. Only the checkout reference
/// carries a seeded comment; the other worktrees start with an empty thread.
fn diff_seed_notes(worktree : String) -> Array[DiffNote] {
  if worktree == "eu-promo-checkout" ||
    worktree == "agent-handoff-summary" ||
    worktree == "checks-detail-link" {
    []
  } else {
    [
      {
        file: 0,
        line: 6,
        end_line: 6,
        text: "Also reject PO boxes when shipping is express.",
      },
    ]
  }
}

///|
fn diff_seed_selected(worktree : String) -> Int32 {
  if worktree == "eu-promo-checkout" ||
    worktree == "agent-handoff-summary" ||
    worktree == "checks-detail-link" {
    0
  } else {
    6
  }
}

///|
fn diff_seed_note_open(worktree : String) -> Bool {
  !(worktree == "eu-promo-checkout" ||
  worktree == "agent-handoff-summary" ||
  worktree == "checks-detail-link")
}

///|
/// The checks worktree is already finished, so its review exposes verdicts;
/// the other seeded worktrees are still mid-run.
fn diff_seed_working(worktree : String) -> Bool {
  worktree != "checks-detail-link"
}

///|
/// Reset the single live diff review when switching to a different worktree.
/// File tabs, selection, note thread, draft, verdict and transcript all belong
/// to one worktree and must not leak into the next review.
fn reset_diff_review(model : Model, worktree : String) -> Model {
  {
    ..model,
    diff_worktree: worktree,
    diff_selected: diff_seed_selected(worktree),
    diff_anchor: -1,
    diff_file: 0,
    diff_closed: diff_seed_closed(worktree),
    diff_verdict: 0,
    diff_notes: diff_seed_notes(worktree),
    diff_note_open: diff_seed_note_open(worktree),
    diff_file_menu_open: false,
    diff_draft: "",
    diff_composer_menu_closed: false,
    diff_working: diff_seed_working(worktree),
    diff_messages: [],
  }
}

///|
/// Open the diff review for a worktree, retaining the current review when the
/// same worktree is reopened and resetting the per-worktree state otherwise.
fn open_diff_worktree(model : Model, worktree : String) -> Model {
  if find_worktree(model, worktree) is None {
    model
  } else {
    let selected = ensure_tab(model, worktree)
    let reviewed = if selected.diff_worktree == worktree {
      selected
    } else {
      reset_diff_review(selected, worktree)
    }
    {
      ..reviewed,
      screen: DiffScreen,
      diff_file_menu_open: false,
      app_menu_open: false,
      ctx_open: false,
      task_link_menu_open: false,
      hover: "",
    }
  }
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
pub fn modal_agent_kind(index : Int32) -> AgentKind {
  if index == 1 {
    Codex
  } else if index == 2 {
    Grok
  } else {
    Claude
  }
}

///|
/// Base branch offered by the Advanced section of the create dialog.
pub fn modal_base_branch_label(index : Int32) -> String {
  if index == 1 {
    "develop"
  } else if index == 2 {
    "release/next"
  } else {
    "main"
  }
}

///|
pub fn modal_agent_label(index : Int32) -> String {
  match modal_agent_kind(index) {
    Claude => "Claude Code"
    Codex => "Codex"
    Grok => "Grok"
  }
}

///|
pub fn modal_agent_model(index : Int32) -> String {
  match modal_agent_kind(index) {
    Claude => "opus-5.5"
    Codex => "gpt-6-astra"
    Grok => "grok-4"
  }
}

///|
pub fn task_source_kind(index : Int32) -> TaskSource {
  match index {
    1 => LinearTask
    2 => SlackTask
    _ => GitHubTask
  }
}

///|
pub fn task_agent_model(index : Int32) -> String {
  match modal_agent_kind(index) {
    Claude => "opus-5.5"
    Codex => "gpt-6-astra"
    Grok => "grok-4.7"
  }
}

///|
/// True while the new-task composer has no usable title; Add stays inert.
pub fn task_add_blocked(model : Model) -> Bool {
  model.task_draft.trim_space().to_string() == ""
}

///|
/// True while the rename dialog has no usable name; Rename stays inert.
pub fn rename_save_blocked(model : Model) -> Bool {
  model.rename_open && model.rename_draft.trim_space().to_string() == ""
}

///|
pub fn modal_target_project(index : Int32) -> String {
  if index == 1 {
    "acme-web"
  } else {
    "acme-internal"
  }
}

///|
pub fn modal_target_host(index : Int32) -> String {
  if index == 1 {
    "Local Mac"
  } else {
    "mac-mini"
  }
}

///|
pub fn composer_model_label(index : Int32) -> String {
  if index == 1 {
    "GPT-6 Astra"
  } else if index == 2 {
    "Grok 4"
  } else {
    "Opus 5.5"
  }
}

///|
pub fn bots_composer_model_label(index : Int32) -> String {
  if index == 1 {
    "Codex GPT-6 Astra Med"
  } else if index == 2 {
    "Grok 4 Med"
  } else {
    "Claude Opus 5.5 Med"
  }
}

///|
pub fn composer_access_label(index : Int32) -> String {
  if index == 1 {
    "Ask before edits"
  } else if index == 2 {
    "Read only"
  } else {
    "Full access"
  }
}

///|
pub fn automation_schedule_label(index : Int32) -> String {
  match index {
    1 => "Every 30 minutes"
    2 => "Every day · 2:00 AM"
    3 => "Weekdays · 9:00 AM"
    4 => "Fridays · 5:00 PM"
    _ => "Manual"
  }
}

///|
/// MoUI runs on the host's monotonic session clock, so scheduled work keeps
/// the selected cadence while the app is open. Calendar labels stay as the
/// design shows them; a restart re-arms the cadence from zero.
pub fn automation_period_ms(index : Int32) -> Double {
  match index {
    1 => 30.0 * 60.0 * 1000.0
    2 => 24.0 * 60.0 * 60.0 * 1000.0
    3 => 24.0 * 60.0 * 60.0 * 1000.0
    4 => 7.0 * 24.0 * 60.0 * 60.0 * 1000.0
    _ => 0.0
  }
}

///|
/// Human-readable countdown for the next armed run. The seed screenshots do
/// not start a host timer, so an unarmed automation stays visually unchanged.
pub fn automation_next_run_label(model : Model, index : Int32) -> String {
  if index < 0 ||
    index >= model.automations.length() ||
    model.automation_clock_ms <= 0.0 {
    ""
  } else {
    let item = model.automations[index]
    if !item.enabled || item.schedule_index == 0 || item.next_run_ms <= 0.0 {
      ""
    } else {
      let remaining = item.next_run_ms - model.automation_clock_ms
      if remaining <= 0.0 {
        "due now"
      } else if remaining < 60000.0 {
        "next in <1m"
      } else {
        let minutes = (remaining / 60000.0).to_int()
        if minutes < 60 {
          "next in \{minutes}m"
        } else if minutes < 1440 {
          "next in \{minutes / 60}h"
        } else {
          "next in \{minutes / 1440}d"
        }
      }
    }
  }
}

///|
pub fn automation_project_label(index : Int32) -> String {
  if index == 1 {
    "acme-web"
  } else {
    "acme-internal"
  }
}

///|
/// True while the automation name draft is blank; the primary Save action and
/// its ⌘↵ shortcut stay inert until a non-blank name is typed.
pub fn automation_save_blocked(model : Model) -> Bool {
  model.automation_name.trim_space().to_string() == ""
}

///|
/// Rounded success percentage for the automations metric cards.
pub fn automation_success_pct(model : Model) -> Int32 {
  if model.automation_runs_today <= 0 {
    0
  } else {
    (model.automation_passed_today * 100 + model.automation_runs_today / 2) /
    model.automation_runs_today
  }
}

///|
/// Day-over-day delta for the runs metric card, derived so "Run now" moves it.
pub fn automation_runs_delta(model : Model) -> Int32 {
  model.automation_runs_today - model.automation_runs_yesterday
}

///|
/// Helper copy under the runs metric. Zero is spelled out instead of "↑ 0".
pub fn automation_runs_delta_label(model : Model) -> String {
  let delta = automation_runs_delta(model)
  if delta > 0 {
    "↑ \{delta} vs yesterday"
  } else if delta < 0 {
    "↓ \{-delta} vs yesterday"
  } else {
    "No change vs yesterday"
  }
}

///|
/// The new-worktree transcript used after the modal creates one.
fn transcript_for_new(
  name : String,
  kind : AgentKind,
  agent_name : String,
  mode : Int32,
  base_branch : String,
) -> Array[Block] {
  let assistant = match mode {
    1 => "Pulled the pull request and opened a review worktree."
    2 => "Checked out the branch at its latest commit."
    _ => "On it — I’ll report back here when the workers finish."
  }
  let worker_name = match mode {
    1 => "pr-sync"
    2 => "branch-checkout"
    _ => "worktree-setup"
  }
  let worker_body = match mode {
    1 =>
      "Fetched the pull request head from \{base_branch} and started a \{agent_name} review worker."
    2 =>
      "Created the worktree from \{base_branch} at the branch head and started a \{agent_name} worker."
    _ =>
      "Created the worktree from \{base_branch} and started a \{agent_name} worker."
  }
  [
    UserMessage(name),
    AssistantMessage(assistant),
    worker(worker_name, kind, "now", worker_body, true),
  ]
}

///|
/// Default name offered by each "Create From" source. `Name` starts blank
/// because it requires the user to type the worktree name.
fn modal_seed_name(mode : Int32) -> String {
  match mode {
    0 => "Speed up checkout CI"
    1 => "Retry flaky checkout (PR #482)"
    2 => "Checkout retry branch"
    _ => ""
  }
}

///|
/// Branch a new worktree starts on. GitHub-sourced worktrees track a PR branch.
fn modal_branch(mode : Int32, id : String) -> String {
  match mode {
    1 => "pr/\{id}"
    _ => "feature/\{id}"
  }
}

///|
/// Inclusive bounds of the current diff selection. A Shift-extended selection
/// spans every line between its anchor and the moving endpoint.
pub fn diff_selection_bounds(model : Model) -> (Int32, Int32) {
  if model.diff_anchor < 0 {
    (model.diff_selected, model.diff_selected)
  } else if model.diff_anchor <= model.diff_selected {
    (model.diff_anchor, model.diff_selected)
  } else {
    (model.diff_selected, model.diff_anchor)
  }
}

///|
/// Index of the review note attached to `file`/`line`, or -1 when there is none.
/// Exact range matches win; a single-line selection inside a range note falls
/// back to that note so its pencil/x actions still work.
fn diff_note_index(
  model : Model,
  file : Int32,
  line : Int32,
  end_line : Int32,
) -> Int32 {
  let mut exact = -1
  let mut containing = -1
  let mut index = 0
  for note in model.diff_notes {
    if note.file == file {
      if note.line == line && note.end_line == end_line {
        exact = index
      }
      if note.line <= line &&
        line <= note.end_line &&
        note.line <= end_line &&
        end_line <= note.end_line {
        containing = index
      }
    }
    index = index + 1
  }
  if exact >= 0 {
    exact
  } else {
    containing
  }
}

///|
/// Post a note to the diff agent and mark it as working.
fn post_diff_message(model : Model, text : String) -> Model {
  let blocks = model.diff_messages.copy()
  blocks.push(UserMessage(text))
  blocks.push(
    AssistantMessage(
      "On it — I’ll report back here when the workers finish.",
    ),
  )
  {
    ..model,
    diff_messages: blocks,
    diff_draft: "",
    diff_working: true,
    dictation_target: 0,
  }
}

///|
/// Composer mic targets. 0 means no active dictation hint.
let dictation_main : Int32 = 1

///|
let dictation_comment : Int32 = 2

///|
let dictation_diff : Int32 = 3

///|
/// Deterministic sample phrase for the local dictation demo.
pub fn dictation_phrase(target : Int32) -> String {
  match target {
    1 => "Summarize the failing checkout tests."
    2 => "Please add a regression test."
    3 => "The zero-rate fallback looks right."
    _ => ""
  }
}

///|
/// Append a dictated phrase without duplicating spaces at the join.
pub fn dictation_append(draft : String, phrase : String) -> String {
  if draft == "" {
    phrase
  } else {
    let chars = draft.to_array()
    let last = chars[chars.length() - 1]
    if last == ' ' || last == '\t' || last == '\n' {
      draft + phrase
    } else {
      draft + " " + phrase
    }
  }
}

///|
/// True while the Search query starts with `@` and is therefore scoped to files.
pub fn search_query_has_file_scope(model : Model) -> Bool {
  let chars = model.search_query.to_array()
  chars.length() > 0 && chars[0] == '@'
}

///|
/// Keeps the Tasks selection aligned with the active filters. When the current
/// row becomes hidden, fall back to the first visible row and discard the
/// now-stale inline description draft so Save cannot target another task.
fn settle_task_selection(model : Model) -> Model {
  let indices = filtered_task_indices(model)
  if indices.is_empty() {
    {
      ..model,
      task_detail_editing: false,
      task_detail_draft: "",
      task_link_menu_open: false,
    }
  } else {
    let mut visible = false
    for index in indices {
      if index == model.task_selected {
        visible = true
      }
    }
    if visible {
      { ..model, task_link_menu_open: false, }
    } else {
      {
        ..model,
        task_selected: indices[0],
        task_detail_editing: false,
        task_detail_draft: "",
        task_link_menu_open: false,
      }
    }
  }
}

///|
/// Applies one message without recording navigation history.
fn apply_msg(model : Model, msg : Msg) -> Model {
  match msg {
    SelectWorktree(id) =>
      match find_worktree(model, id) {
        Some(_) => { ..ensure_tab(model, id), chat_scroll_y: 1.0e9, }
        None => model
      }
    SelectTabAt(index) =>
      if index >= 0 && index < model.tabs.length() {
        apply_msg(model, SelectWorktree(model.tabs[index]))
      } else {
        model
      }
    CloseTab(id) => close_tab(model, id)
    NewTab =>
      {
        ..model,
        modal_open: true,
        modal_name: "",
        modal_from: 0,
        modal_advanced: false,
        modal_base_branch: 0,
        modal_agent: 0,
        modal_target: 0,
        create_more: false,
        app_menu_open: false,
        diff_file_menu_open: false,
        ctx_open: false,
        task_link_menu_open: false,
        task_link_after_create: -1,
      }
    OpenModal =>
      {
        ..model,
        modal_open: true,
        modal_name: "",
        modal_from: 0,
        modal_advanced: false,
        modal_base_branch: 0,
        modal_agent: 0,
        modal_target: 0,
        create_more: false,
        app_menu_open: false,
        diff_file_menu_open: false,
        ctx_open: false,
        task_link_menu_open: false,
        task_link_after_create: -1,
      }
    CloseModal =>
      {
        ..model,
        modal_open: false,
        modal_name: "",
        modal_from: 0,
        modal_advanced: false,
        modal_base_branch: 0,
        modal_agent: 0,
        modal_target: 0,
        create_more: false,
        task_link_after_create: -1,
      }
    NameInput(text) => { ..model, modal_name: text, }
    SelectCreateFrom(index) =>
      { ..model, modal_from: index, modal_name: modal_seed_name(index), }
    ToggleAdvanced => { ..model, modal_advanced: !model.modal_advanced, }
    CycleBaseBranch =>
      { ..model, modal_base_branch: (model.modal_base_branch + 1) % 3, }
    CycleAgent => { ..model, modal_agent: (model.modal_agent + 1) % 3, }
    CycleTarget => { ..model, modal_target: (model.modal_target + 1) % 2, }
    ToggleCreateMore => { ..model, create_more: !model.create_more, }
    CreateWorktree => {
      let typed = model.modal_name.trim_space().to_string()
      let name = if typed == "" && model.modal_from == 3 {
        // The "Name" source cannot create anything until the user names it.
        return model
      } else if typed == "" {
        modal_seed_name(model.modal_from)
      } else {
        typed
      }
      let slug = slugify(name)
      let mut id = slug
      let mut suffix = 2
      while has_worktree(model, id) || deleted_has(model.deleted_worktrees, id) {
        let candidate = "\{slug}-\{suffix}"
        id = candidate
        suffix = suffix + 1
      }
      let worktree : Worktree = {
        id,
        name,
        branch: modal_branch(model.modal_from, id),
        primary: false,
        tab_title: name,
        agents: [
          agent(
            "Preparing worktree",
            modal_agent_kind(model.modal_agent),
            modal_agent_model(model.modal_agent),
            "now",
            Running,
          ),
        ],
        transcript: transcript_for_new(
          name,
          modal_agent_kind(model.modal_agent),
          modal_agent_label(model.modal_agent),
          model.modal_from,
          modal_base_branch_label(model.modal_base_branch),
        ),
      }
      let created = append_worktree(
        model,
        modal_target_project(model.modal_target),
        worktree,
      )
      let link_index = model.task_link_after_create
      let linked = if link_index >= 0 && link_index < created.tasks.length() {
        let tasks = created.tasks.copy()
        let item = tasks[link_index]
        let next = append_task_activity(item, LinkActivity, "Linked to \{id}")
        tasks[link_index] = { ..next, worktree_id: id, }
        {
          ..created,
          tasks,
          task_detail_open: true,
          task_link_after_create: -1,
        }
      } else {
        { ..created, task_link_after_create: -1, }
      }
      let tabs = linked.tabs.copy()
      tabs.push(id)
      let active = id
      if model.create_more {
        { ..linked, tabs, active, section: model.section, modal_name: "", }
      } else {
        {
          ..linked,
          tabs,
          active,
          section: model.section,
          modal_open: false,
          modal_name: "",
          modal_from: 0,
          modal_advanced: false,
          modal_base_branch: 0,
          modal_agent: 0,
          modal_target: 0,
          create_more: false,
        }
      }
    }
    BeginRenameWorktree(id) =>
      match find_worktree(model, id) {
        Some(worktree) =>
          {
            ..model,
            rename_open: true,
            rename_target: id,
            rename_draft: worktree.name,
            ctx_open: false,
          }
        None => model
      }
    RenameDraftInput(text) => { ..model, rename_draft: text, }
    CommitRename => {
      let typed = model.rename_draft.trim_space().to_string()
      if typed == "" || !has_worktree(model, model.rename_target) {
        model
      } else {
        let renamed = update_worktree(model, model.rename_target, fn(worktree) {
          { ..worktree, name: typed, tab_title: typed, }
        })
        { ..renamed, rename_open: false, rename_target: "", rename_draft: "", }
      }
    }
    CancelRename =>
      { ..model, rename_open: false, rename_target: "", rename_draft: "", }
    BeginDeleteWorktree(id) =>
      if has_worktree(model, id) {
        { ..model, delete_open: true, delete_target: id, ctx_open: false, }
      } else {
        model
      }
    ConfirmDeleteWorktree => delete_worktree(model, model.delete_target)
    CancelDeleteWorktree => { ..model, delete_open: false, delete_target: "", }
    ToggleWorked(worktree_id, block_index) =>
      update_worktree(model, worktree_id, fn(worktree) {
        let blocks : Array[Block] = []
        let mut i = 0
        for block in worktree.transcript {
          if i == block_index {
            let toggled = match block {
              Worked(row) => Worked({ ..row, expanded: !row.expanded, })
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
    ToggleWorker(worktree_id, block_index) =>
      update_worktree(model, worktree_id, fn(worktree) {
        if block_index < 0 || block_index >= worktree.transcript.length() {
          worktree
        } else {
          let target = match worktree.transcript[block_index] {
            Worker(card) => card.focused
            _ => false
          }
          let blocks : Array[Block] = []
          let mut i = 0
          for block in worktree.transcript {
            let next = match block {
              Worker(card) =>
                Worker({
                  ..card,
                  focused: if i == block_index {
                    !target
                  } else {
                    false
                  },
                })
              other => other
            }
            blocks.push(next)
            i = i + 1
          }
          { ..worktree, transcript: blocks, }
        }
      })
    DraftInput(text) =>
      {
        ..model,
        draft: text,
        dictation_target: 0,
        composer_pick: -1,
        composer_menu_closed: false,
      }
    Dictate(target) =>
      if target == dictation_main {
        {
          ..model,
          draft: dictation_append(model.draft, dictation_phrase(target)),
          dictation_target: target,
        }
      } else if target == dictation_comment {
        {
          ..model,
          comment_draft: dictation_append(
            model.comment_draft,
            dictation_phrase(target),
          ),
          dictation_target: target,
        }
      } else if target == dictation_diff {
        {
          ..model,
          diff_draft: dictation_append(
            model.diff_draft,
            dictation_phrase(target),
          ),
          dictation_target: target,
        }
      } else {
        model
      }
    SetComposerPick(index) =>
      { ..model, composer_pick: index, composer_menu_closed: false, }
    MoveComposerPick(delta) =>
      match composer_menu(model.draft, live_files(model)) {
        Some(menu) => {
          let last = menu.suggestions.length() - 1
          let current = composer_pick_index(model, menu)
          let next = if delta > 0 {
            if current < 0 || current >= last {
              0
            } else {
              current + 1
            }
          } else if current <= 0 {
            last
          } else {
            current - 1
          }
          { ..model, composer_pick: next, composer_menu_closed: false, }
        }
        None => model
      }
    ComposerPick(index) =>
      match composer_menu(model.draft, live_files(model)) {
        Some(menu) => {
          let last = menu.suggestions.length() - 1
          let clamped = if index < 0 {
            0
          } else if index > last {
            last
          } else {
            index
          }
          {
            ..model,
            draft: menu.suggestions[clamped].insert,
            dictation_target: 0,
            composer_pick: -1,
            composer_menu_closed: false,
          }
        }
        None => model
      }
    MoveDiffComposerPick(delta) =>
      match composer_menu(model.diff_draft, live_files(model)) {
        Some(menu) => {
          let last = menu.suggestions.length() - 1
          let current = composer_pick_index(model, menu)
          let next = if delta > 0 {
            if current < 0 || current >= last {
              0
            } else {
              current + 1
            }
          } else if current <= 0 {
            last
          } else {
            current - 1
          }
          { ..model, composer_pick: next, composer_menu_closed: false, }
        }
        None => model
      }
    DiffComposerPick(index) =>
      match composer_menu(model.diff_draft, live_files(model)) {
        Some(menu) => {
          let last = menu.suggestions.length() - 1
          let clamped = if index < 0 {
            0
          } else if index > last {
            last
          } else {
            index
          }
          {
            ..model,
            diff_draft: menu.suggestions[clamped].insert,
            dictation_target: 0,
            composer_pick: -1,
            diff_composer_menu_closed: false,
          }
        }
        None => model
      }
    DismissComposerMenu =>
      { ..model, composer_menu_closed: true, composer_pick: -1, }
    DismissDiffComposerMenu =>
      { ..model, diff_composer_menu_closed: true, composer_pick: -1, }
    ScrollChat(y) => { ..model, chat_scroll_y: y, }
    Send => {
      if model.screen == Bots {
        let text = model.draft.trim_space().to_string()
        if text == "" {
          return model
        }
        let key = bot_chat_key(model)
        let messages = model.bot_messages.copy()
        messages.push({ key, block: UserMessage(text), })
        messages.push({
          key,
          block: AssistantMessage(
            "On it — I’ll report back here when the workers finish.",
          ),
        })
        let mut bots = model.bots
        let mut bot_item_seq = model.bot_item_seq
        match active_bot_of(model) {
          Some(bot) =>
            if bot.item is None {
              let updated = model.bots.copy()
              let mut index = 0
              for entry in updated {
                if entry.id == bot.id {
                  updated[index] = {
                    ..entry,
                    working: 1,
                    subtitle: "1 working",
                    time: "now",
                    status: Working,
                    item: Some(bot_item_from_message(entry, bot_item_seq, text)),
                  }
                }
                index = index + 1
              }
              bots = updated
              bot_item_seq = bot_item_seq + 1
            }
          None => ()
        }
        return {
          ..model,
          draft: "",
          bot_messages: messages,
          bots,
          bot_item_seq,
          dictation_target: 0,
        }
      }
      let text = model.draft.trim_space().to_string()
      if text == "" || model.active == "" {
        model
      } else {
        let sent = update_worktree(model, model.active, fn(worktree) {
          let blocks = worktree.transcript.copy()
          blocks.push(UserMessage(text))
          blocks.push(
            AssistantMessage(
              "On it — I’ll report back here when the workers finish.",
            ),
          )
          { ..worktree, transcript: blocks, }
        })
        { ..sent, draft: "", chat_scroll_y: 1.0e9, dictation_target: 0, }
      }
    }
    SetSection(section) =>
      if section == Bots {
        {
          ..model,
          section,
          screen: Bots,
          bot_chat_open: true,
          bot_status_menu_open: false,
          app_menu_open: false,
          diff_file_menu_open: false,
          task_link_menu_open: false,
        }
      } else if section == Search {
        {
          ..model,
          section,
          screen: SearchScreen,
          bot_status_menu_open: false,
          app_menu_open: false,
          diff_file_menu_open: false,
          task_link_menu_open: false,
        }
      } else if section == Tasks {
        {
          ..model,
          section,
          screen: TasksScreen,
          bot_status_menu_open: false,
          app_menu_open: false,
          diff_file_menu_open: false,
          task_link_menu_open: false,
        }
      } else {
        {
          ..model,
          section,
          screen: AutomationsScreen,
          bot_status_menu_open: false,
          app_menu_open: false,
          diff_file_menu_open: false,
          task_link_menu_open: false,
        }
      }
    SetScreen(screen) =>
      {
        ..model,
        screen,
        app_menu_open: false,
        diff_file_menu_open: false,
        bot_status_menu_open: false,
        task_link_menu_open: false,
        bot_chat_open: if screen == Bots {
          true
        } else {
          model.bot_chat_open
        },
      }
    SelectBot(id) =>
      match find_bot(model, id) {
        Some(bot) =>
          {
            ..model,
            active_bot: bot.id,
            active_session: "",
            center_tab: 0,
            panel_tab: 0,
            bot_chat_open: true,
            bot_status_menu_open: false,
            section: Bots,
            screen: Bots,
          }
        None =>
          match find_session_bot(model, id) {
            Some(bot) =>
              {
                ..model,
                active_bot: bot.id,
                active_session: id,
                center_tab: 0,
                panel_tab: 0,
                bot_chat_open: true,
                bot_status_menu_open: false,
                section: Bots,
                screen: Bots,
              }
            None => model
          }
      }
    MoveBotSelection(delta) => {
      let bots = filtered_bots(model)
      if bots.is_empty() {
        model
      } else {
        let mut position = -1
        let mut i = 0
        for bot in bots {
          if bot.id == model.active_bot {
            position = i
          }
          i = i + 1
        }
        let base = if position < 0 { 0 } else { position }
        let next = base + delta
        let bounded = if next < 0 {
          0
        } else if next >= bots.length() {
          bots.length() - 1
        } else {
          next
        }
        let bot = bots[bounded]
        {
          ..model,
          active_bot: bot.id,
          active_session: "",
          center_tab: 0,
          panel_tab: 0,
          bot_chat_open: true,
          bot_status_menu_open: false,
          section: Bots,
          screen: Bots,
        }
      }
    }
    SetCenterTab(index) => { ..model, center_tab: index, }
    CloseBotTab(index) => {
      let is_scout = match active_bot_of(model) {
        Some(bot) => bot.id == "scout"
        None => false
      }
      if index == 0 {
        let fallback_to_eng = is_scout && model.bot_eng_open
        {
          ..model,
          bot_chat_open: false,
          center_tab: if fallback_to_eng {
            1
          } else {
            0
          },
        }
      } else if index == 1 && is_scout && model.bot_eng_open {
        {
          ..model,
          bot_eng_open: false,
          center_tab: if model.center_tab == 1 {
            0
          } else {
            model.center_tab
          },
        }
      } else {
        model
      }
    }
    SetPanelTab(index) =>
      { ..model, panel_tab: index, bot_status_menu_open: false, }
    ToggleBotItemPanel =>
      {
        ..model,
        bots_item_open: !model.bots_item_open,
        bot_status_menu_open: false,
      }
    OpenBotItemPanel(index) =>
      if index < 0 || index > 3 {
        model
      } else {
        {
          ..model,
          panel_tab: index,
          bots_item_open: true,
          bot_status_menu_open: false,
        }
      }
    ToggleBotsFleet => { ..model, bots_collapsed: !model.bots_collapsed, }
    ToggleBotSearch =>
      {
        ..model,
        bot_search_open: !model.bot_search_open,
        bot_query: if model.bot_search_open {
          ""
        } else {
          model.bot_query
        },
      }
    BotQueryInput(text) => { ..model, bot_query: text, }
    ClearBotQuery => { ..model, bot_query: "", }
    ToggleBotOptions =>
      { ..model, bots_options_open: !model.bots_options_open, }
    ToggleBotSessions =>
      { ..model, bots_show_sessions: !model.bots_show_sessions, }
    ToggleBotStatusMenu =>
      match active_bot_of(model) {
        Some(bot) =>
          match bot.item {
            Some(_) =>
              { ..model, bot_status_menu_open: !model.bot_status_menu_open, }
            None => model
          }
        None => model
      }
    SetBotItemState(state) =>
      if state != "In progress" && state != "Waiting on you" && state != "Done" {
        model
      } else {
        match active_bot_of(model) {
          Some(bot) =>
            match bot.item {
              Some(item) => {
                let bots = model.bots.copy()
                let mut index = 0
                for entry in bots {
                  if entry.id == bot.id {
                    if bot_item_state(bot) == state {
                      bots[index] = { ..entry, item_state: state, }
                    } else {
                      let activities = item.activities.copy()
                      activities.push({
                        icon: if state == "Done" {
                          CheckActivity
                        } else {
                          PlayActivity
                        },
                        text: "Status set to \{state}",
                        sub: "",
                        time: "now",
                      })
                      bots[index] = {
                        ..entry,
                        item_state: state,
                        item: Some({ ..item, activities, }),
                      }
                    }
                  }
                  index = index + 1
                }
                { ..model, bots, bot_status_menu_open: false, }
              }
              None => model
            }
          None => model
        }
      }
    ToggleConnector(index) =>
      if index < 0 || index >= model.connectors.length() {
        model
      } else {
        {
          ..model,
          connector_open: if model.connector_open == index {
            -1
          } else {
            index
          },
        }
      }
    ToggleConnectorConnected(index) =>
      if index < 0 || index >= model.connectors.length() {
        model
      } else {
        let connectors = model.connectors.copy()
        let item = connectors[index]
        connectors[index] = { ..item, connected: !item.connected, }
        { ..model, connectors, }
      }
    AddBot => {
      let mut id = "relay"
      let mut label = "Relay"
      let mut suffix = 2
      while has_bot(model, id) {
        let candidate = "relay-\{suffix}"
        id = candidate
        label = "Relay \{suffix}"
        suffix = suffix + 1
      }
      let created : Bot = {
        id,
        name: label,
        mascot: Standup,
        working: 0,
        subtitle: "Waiting for a task.",
        time: "now",
        status: Idle,
        item_state: "",
        sessions: [session("\{id}-home", Home, "Home Chat", "now", Done)],
        item: None,
      }
      let bots = model.bots.copy()
      bots.push(created)
      {
        ..model,
        bots,
        active_bot: id,
        active_session: "",
        center_tab: 0,
        panel_tab: 0,
        bot_chat_open: true,
        bots_collapsed: false,
        bot_search_open: false,
        bot_query: "",
        bot_status_menu_open: false,
        section: Bots,
        screen: Bots,
      }
    }
    FileQueryInput(text) => { ..model, files_query: text, }
    CommentInput(text) => { ..model, comment_draft: text, dictation_target: 0, }
    SendComment => {
      let text = model.comment_draft.trim_space().to_string()
      if text == "" {
        model
      } else {
        let comments = model.comments.copy()
        comments.push({ key: bot_comment_key(model), text, })
        { ..model, comments, comment_draft: "", dictation_target: 0, }
      }
    }
    ToggleFlag => toggle_bot_flag(model)
    CycleComposerModel =>
      { ..model, composer_model: (model.composer_model + 1) % 3, }
    CycleAccess =>
      { ..model, composer_access: (model.composer_access + 1) % 3, }
    SearchInput(text) => {
      let chars = text.to_array()
      let file_scope = chars.length() > 0 && chars[0] == '@'
      let previous = model.search_query.to_array()
      let was_file_scope = previous.length() > 0 && previous[0] == '@'
      let filter = if file_scope {
        4
      } else if was_file_scope {
        model.search_filter_before_scope
      } else {
        model.search_filter
      }
      let filter_before_scope = if file_scope && !was_file_scope {
        model.search_filter
      } else {
        model.search_filter_before_scope
      }
      {
        ..model,
        search_query: text,
        search_selected: 0,
        search_filter: filter,
        search_filter_before_scope: filter_before_scope,
      }
    }
    SetSearchFilter(index) => {
      let scoped = search_query_has_file_scope(model)
      let query = if scoped && index != 4 {
        let (_, needle) = search_file_scope(model.search_query)
        needle
      } else {
        model.search_query
      }
      {
        ..model,
        search_query: query,
        search_filter: index,
        search_filter_before_scope: if scoped && index == 4 {
          model.search_filter_before_scope
        } else {
          index
        },
        search_selected: 0,
      }
    }
    MoveSearchSelection(delta) => {
      let hits = filtered_search_hits(model)
      if hits.is_empty() {
        model
      } else {
        let next = model.search_selected + delta
        let bounded = if next < 0 {
          0
        } else if next >= hits.length() {
          hits.length() - 1
        } else {
          next
        }
        { ..model, search_selected: bounded, }
      }
    }
    ClearSearch =>
      {
        ..model,
        search_query: "",
        search_filter: 0,
        search_filter_before_scope: 0,
        search_selected: 0,
      }
    OpenTopSearchHit => {
      let hits = filtered_search_hits(model)
      if hits.is_empty() {
        model
      } else {
        let index = if model.search_selected >= 0 &&
          model.search_selected < hits.length() {
          model.search_selected
        } else {
          0
        }
        apply_msg(model, SelectSearchResult(hits[index].id))
      }
    }
    Hover(id, entered) =>
      {
        ..model,
        hover: if entered {
          id
        } else if model.hover == id {
          ""
        } else {
          model.hover
        },
      }
    ToggleSidebar => { ..model, sidebar_open: !model.sidebar_open, }
    ResizeSidebar(x) => { ..model, sidebar_w: clamp_sidebar_width(x), }
    ResizeBotsSidebar(x) =>
      { ..model, bots_sidebar_w: clamp_bots_sidebar_width(x), }
    ResizeBotsPanel(x) => { ..model, bots_panel_w: clamp_bots_panel_width(x), }
    GoBack =>
      if model.nav_back.is_empty() {
        model
      } else {
        let back = model.nav_back.copy()
        match back.pop() {
          None => model
          Some(entry) => {
            let forward = model.nav_forward.copy()
            forward.push(nav_entry(model))
            { ..apply_nav(model, entry), nav_back: back, nav_forward: forward, }
          }
        }
      }
    GoForward =>
      if model.nav_forward.is_empty() {
        model
      } else {
        let forward = model.nav_forward.copy()
        match forward.pop() {
          None => model
          Some(entry) => {
            let back = model.nav_back.copy()
            back.push(nav_entry(model))
            { ..apply_nav(model, entry), nav_back: back, nav_forward: forward, }
          }
        }
      }
    ToggleSidebarOptions =>
      { ..model, sidebar_options_open: !model.sidebar_options_open, }
    ToggleAppMenu => { ..model, app_menu_open: !model.app_menu_open, }
    CloseAppMenu => { ..model, app_menu_open: false, }
    OpenContextMenu(kind, target, index, anchor) =>
      {
        ..model,
        ctx_open: true,
        app_menu_open: false,
        diff_file_menu_open: false,
        task_link_menu_open: false,
        ctx_kind: kind,
        ctx_target: target,
        ctx_index: index,
        ctx_anchor: anchor,
      }
    CloseContextMenu => { ..model, ctx_open: false, }
    ContextAction(action) => {
      let closed = { ..model, ctx_open: false, }
      if model.ctx_kind == 0 {
        match action {
          0 => apply_msg(closed, SelectWorktree(model.ctx_target))
          1 => open_diff_worktree(closed, model.ctx_target)
          2 => apply_msg(closed, BeginRenameWorktree(model.ctx_target))
          3 => apply_msg(closed, CloseTab(model.ctx_target))
          _ => apply_msg(closed, BeginDeleteWorktree(model.ctx_target))
        }
      } else {
        match action {
          0 => apply_msg(closed, SelectTask(model.ctx_index))
          1 => {
            let done = if model.ctx_index >= 0 &&
              model.ctx_index < model.tasks.length() {
              model.tasks[model.ctx_index].status == TaskDone
            } else {
              false
            }
            if done {
              apply_msg(closed, ReopenTask(model.ctx_index))
            } else {
              apply_msg(closed, MarkTaskDone(model.ctx_index))
            }
          }
          _ => closed
        }
      }
    }
    CollapseAllWorktrees => {
      let machines : Array[String] = []
      for machine in model.machines {
        machines.push(machine.name)
      }
      let projects : Array[String] = []
      for machine in model.machines {
        for project in machine.projects {
          projects.push(project.id)
        }
      }
      {
        ..model,
        sidebar_options_open: false,
        collapsed_machines: machines,
        collapsed_projects: projects,
      }
    }
    ExpandAllWorktrees =>
      {
        ..model,
        sidebar_options_open: false,
        collapsed_machines: [],
        collapsed_projects: [],
      }
    ToggleMachine(name) => {
      let current = model.collapsed_machines.copy()
      let next : Array[String] = []
      let mut found = false
      for entry in current {
        if entry == name {
          found = true
        } else {
          next.push(entry)
        }
      }
      if !found {
        next.push(name)
      }
      { ..model, collapsed_machines: next, }
    }
    ToggleProject(id) => {
      let current = model.collapsed_projects.copy()
      let next : Array[String] = []
      let mut found = false
      for entry in current {
        if entry == id {
          found = true
        } else {
          next.push(entry)
        }
      }
      if !found {
        next.push(id)
      }
      { ..model, collapsed_projects: next, }
    }
    SelectSearchResult(id) =>
      match find_worktree(model, id) {
        Some(_) => ensure_tab(model, id)
        None =>
          match find_bot(model, id) {
            Some(bot) =>
              {
                ..model,
                active_bot: bot.id,
                active_session: "",
                center_tab: 0,
                panel_tab: 0,
                bot_chat_open: true,
                section: Bots,
                screen: Bots,
              }
            None =>
              match find_session_bot(model, id) {
                Some(bot) =>
                  {
                    ..model,
                    active_bot: bot.id,
                    active_session: id,
                    center_tab: 0,
                    panel_tab: 0,
                    bot_chat_open: true,
                    section: Bots,
                    screen: Bots,
                  }
                None => model
              }
          }
      }
    SelectTask(index) =>
      {
        ..model,
        task_selected: index,
        task_detail_editing: false,
        task_detail_draft: "",
        task_detail_open: true,
        task_link_menu_open: false,
      }
    MoveTaskSelection(delta) => {
      let indices = filtered_task_indices(model)
      if indices.is_empty() {
        model
      } else {
        let mut position = -1
        let mut i = 0
        for index in indices {
          if index == model.task_selected {
            position = i
          }
          i = i + 1
        }
        let base = if position < 0 { 0 } else { position }
        let next = base + delta
        let bounded = if next < 0 {
          0
        } else if next >= indices.length() {
          indices.length() - 1
        } else {
          next
        }
        {
          ..model,
          task_selected: indices[bounded],
          task_detail_editing: false,
          task_detail_draft: "",
          task_link_menu_open: false,
        }
      }
    }
    ActivateTaskSelection => {
      let indices = filtered_task_indices(model)
      if indices.is_empty() {
        model
      } else {
        let mut selected = indices[0]
        for index in indices {
          if index == model.task_selected {
            selected = index
          }
        }
        apply_msg(model, SelectTask(selected))
      }
    }
    SetTaskFilter(index) =>
      settle_task_selection({ ..model, task_filter: index, })
    SetTaskSource(index) =>
      settle_task_selection({
        ..model,
        task_source_filter: if model.task_source_filter == index {
          0
        } else {
          index
        },
      })
    TaskQueryInput(text) =>
      settle_task_selection({ ..model, task_query: text, })
    ClearTaskFilters =>
      {
        ..model,
        task_filter: 0,
        task_source_filter: 0,
        task_query: "",
        task_selected: 0,
        task_detail_editing: false,
        task_detail_draft: "",
        task_link_menu_open: false,
      }
    ToggleTaskComposer =>
      if model.task_composer_open {
        { ..model, task_composer_open: false, }
      } else {
        {
          ..model,
          task_composer_open: true,
          task_detail_open: false,
          task_detail_editing: false,
          task_detail_draft: "",
          task_link_menu_open: false,
        }
      }
    TaskDraftInput(text) => { ..model, task_draft: text, }
    CycleTaskSource =>
      { ..model, task_new_source: (model.task_new_source + 1) % 3, }
    CycleTaskAgent =>
      { ..model, task_new_agent: (model.task_new_agent + 1) % 3, }
    AddTask => {
      let title = model.task_draft.trim_space().to_string()
      if title == "" {
        model
      } else {
        let source = task_source_kind(model.task_new_source)
        let tasks = model.tasks.copy()
        tasks.insert(0, {
          title,
          repo: "acme-internal",
          labels: "new · triage",
          source,
          status: TaskNeedsYou,
          time: "now",
          worktree_id: "",
          detail: "Newly created from the Tasks page. Add a description and link the worktree this should run in.",
          agent: modal_agent_kind(model.task_new_agent),
          agent_model: task_agent_model(model.task_new_agent),
          assignee: "you",
          activity: [
            task_activity_entry(AddActivity, "Task created", "now"),
            task_activity_entry(AddActivity, "Assigned to you", "now"),
          ],
        })
        settle_task_selection({
          ..model,
          tasks,
          task_selected: 0,
          task_filter: 0,
          task_source_filter: 0,
          task_query: "",
          task_draft: "",
          task_composer_open: false,
          task_detail_open: true,
          task_detail_editing: false,
          task_detail_draft: "",
          task_link_menu_open: false,
        })
      }
    }
    EditTaskDetail =>
      if model.task_selected < 0 || model.task_selected >= model.tasks.length() {
        model
      } else {
        {
          ..model,
          task_detail_editing: true,
          task_detail_draft: model.tasks[model.task_selected].detail,
          task_link_menu_open: false,
        }
      }
    TaskDetailInput(text) => { ..model, task_detail_draft: text, }
    SaveTaskDetail =>
      if model.task_selected < 0 || model.task_selected >= model.tasks.length() {
        model
      } else {
        let tasks = model.tasks.copy()
        let item = tasks[model.task_selected]
        let text = model.task_detail_draft.trim_space().to_string()
        let detail = if text == "" { "No description yet." } else { text }
        tasks[model.task_selected] = if detail == item.detail {
          item
        } else {
          let next = append_task_activity(
            item,
            CommentActivity,
            "Description updated",
          )
          { ..next, detail, }
        }
        { ..model, tasks, task_detail_editing: false, task_detail_draft: "", }
      }
    CancelTaskDetail =>
      { ..model, task_detail_editing: false, task_detail_draft: "", }
    CloseTaskDetail =>
      {
        ..model,
        task_detail_open: false,
        task_detail_editing: false,
        task_detail_draft: "",
        task_link_menu_open: false,
      }
    ToggleTaskWorktreeLink =>
      if model.task_selected < 0 || model.task_selected >= model.tasks.length() {
        model
      } else {
        let open = !model.task_link_menu_open
        {
          ..model,
          task_link_menu_open: open,
          task_detail_open: if open {
            true
          } else {
            model.task_detail_open
          },
          task_detail_editing: false,
          task_detail_draft: "",
        }
      }
    LinkTaskWorktree(id) =>
      if model.task_selected < 0 ||
        model.task_selected >= model.tasks.length() ||
        !has_worktree(model, id) {
        model
      } else {
        let tasks = model.tasks.copy()
        let item = tasks[model.task_selected]
        tasks[model.task_selected] = if item.worktree_id == id {
          item
        } else {
          let next = append_task_activity(item, LinkActivity, "Linked to \{id}")
          { ..next, worktree_id: id, }
        }
        { ..model, tasks, task_link_menu_open: false, task_detail_open: true, }
      }
    UnlinkTaskWorktree =>
      if model.task_selected < 0 || model.task_selected >= model.tasks.length() {
        model
      } else {
        let tasks = model.tasks.copy()
        let item = tasks[model.task_selected]
        tasks[model.task_selected] = if item.worktree_id == "" {
          item
        } else {
          let next = append_task_activity(
            item,
            LinkActivity,
            "Unlinked worktree",
          )
          { ..next, worktree_id: "", }
        }
        { ..model, tasks, task_link_menu_open: false, task_detail_open: true, }
      }
    OpenTaskWorktreeCreate =>
      if model.task_selected < 0 || model.task_selected >= model.tasks.length() {
        model
      } else {
        {
          ..model,
          modal_open: true,
          modal_name: "",
          modal_from: 0,
          modal_advanced: false,
          modal_base_branch: 0,
          modal_agent: 0,
          modal_target: 0,
          create_more: false,
          app_menu_open: false,
          diff_file_menu_open: false,
          task_link_menu_open: false,
          task_link_after_create: model.task_selected,
          task_detail_editing: false,
          task_detail_draft: "",
        }
      }
    MarkTaskDone(index) =>
      if index < 0 || index >= model.tasks.length() {
        model
      } else {
        let tasks = model.tasks.copy()
        let item = tasks[index]
        tasks[index] = if item.status == TaskDone {
          item
        } else {
          let next = append_task_activity(item, CheckActivity, "Marked done")
          { ..next, status: TaskDone, time: "now", }
        }
        settle_task_selection({ ..model, tasks, })
      }
    ReopenTask(index) =>
      if index < 0 || index >= model.tasks.length() {
        model
      } else {
        let tasks = model.tasks.copy()
        let item = tasks[index]
        tasks[index] = if item.status == TaskNeedsYou {
          item
        } else {
          let next = append_task_activity(item, PlayActivity, "Reopened")
          { ..next, status: TaskNeedsYou, time: "now", }
        }
        settle_task_selection({ ..model, tasks, })
      }
    SelectAutomation(index) => { ..model, automation_selected: index, }
    MoveAutomationSelection(delta) =>
      if model.automations.is_empty() {
        model
      } else {
        let next = model.automation_selected + delta
        let bounded = if next < 0 {
          0
        } else if next >= model.automations.length() {
          model.automations.length() - 1
        } else {
          next
        }
        { ..model, automation_selected: bounded, }
      }
    ActivateAutomationSelection =>
      if model.automations.is_empty() {
        model
      } else {
        apply_msg(model, EditAutomation(model.automation_selected))
      }
    ToggleAutomation(index) =>
      if index < 0 || index >= model.automations.length() {
        model
      } else {
        let automations = model.automations.copy()
        let item = automations[index]
        let enabled = !item.enabled
        let stopped = !enabled && item.last_run == "Running now"
        automations[index] = {
          ..item,
          enabled,
          status: if enabled {
            "On"
          } else {
            "Off"
          },
          last_run: if stopped {
            "Stopped · just now"
          } else {
            item.last_run
          },
          tone: if enabled {
            TaskDone
          } else {
            TaskInProgress
          },
          next_run_ms: 0.0,
        }
        { ..model, automations, }
      }
    RunAutomation(index) =>
      if index < 0 ||
        index >= model.automations.length() ||
        !model.automations[index].enabled {
        model
      } else {
        run_automation_at(model, index, model.automation_clock_ms)
      }
    AutomationTick(now_ms) =>
      if now_ms <= 0.0 {
        model
      } else {
        let mut next = { ..model, automation_clock_ms: now_ms, }
        let mut index = 0
        while index < next.automations.length() {
          let item = next.automations[index]
          let period = automation_period_ms(item.schedule_index)
          if item.enabled && period > 0.0 {
            if item.next_run_ms <= 0.0 {
              let automations = next.automations.copy()
              automations[index] = { ..item, next_run_ms: now_ms + period, }
              next = { ..next, automations, }
            } else if now_ms >= item.next_run_ms {
              next = run_automation_at(next, index, now_ms)
            }
          }
          index = index + 1
        }
        next
      }
    OpenAutomationEditor =>
      {
        ..model,
        automation_editor_open: true,
        automation_editor_index: -1,
        automation_name: "",
        automation_schedule: 0,
        automation_project: 0,
      }
    EditAutomation(index) =>
      if index < 0 || index >= model.automations.length() {
        model
      } else {
        let item = model.automations[index]
        {
          ..model,
          automation_editor_open: true,
          automation_editor_index: index,
          automation_name: item.name,
          automation_schedule: item.schedule_index,
          automation_project: if contains_text(item.subtitle, "acme-web") {
            1
          } else {
            0
          },
        }
      }
    CloseAutomationEditor =>
      {
        ..model,
        automation_editor_open: false,
        automation_editor_index: -1,
        automation_name: "",
        automation_schedule: 0,
        automation_project: 0,
      }
    AutomationNameInput(text) => { ..model, automation_name: text, }
    CycleAutomationSchedule =>
      { ..model, automation_schedule: (model.automation_schedule + 1) % 5, }
    CycleAutomationProject =>
      { ..model, automation_project: (model.automation_project + 1) % 2, }
    SaveAutomation => {
      let typed = model.automation_name.trim_space().to_string()
      if typed == "" {
        model
      } else {
        let name = typed
        let project = automation_project_label(model.automation_project)
        let schedule_index = model.automation_schedule
        let schedule = automation_schedule_label(schedule_index)
        let automations = model.automations.copy()
        let index = model.automation_editor_index
        if index >= 0 && index < automations.length() {
          let item = automations[index]
          automations[index] = {
            ..item,
            name,
            subtitle: "\{project} · main",
            schedule,
            schedule_index,
            next_run_ms: 0.0,
          }
          {
            ..model,
            automations,
            automation_editor_open: false,
            automation_editor_index: -1,
            automation_name: "",
            automation_schedule: 0,
            automation_project: 0,
            automation_selected: index,
          }
        } else {
          automations.push({
            name,
            subtitle: "\{project} · main",
            schedule,
            schedule_index,
            last_run: "Never run",
            status: "On",
            tone: TaskInProgress,
            enabled: true,
            next_run_ms: 0.0,
          })
          {
            ..model,
            automations,
            automation_editor_open: false,
            automation_editor_index: -1,
            automation_name: "",
            automation_schedule: 0,
            automation_project: 0,
            automation_selected: automations.length() - 1,
          }
        }
      }
    }
    DeleteAutomation(index) =>
      if index < 0 || index >= model.automations.length() {
        model
      } else {
        let automations = model.automations.copy()
        ignore(automations.remove(index))
        let runs : Array[AutomationRun] = []
        for run in model.automation_runs {
          if run.automation < index {
            runs.push(run)
          } else if run.automation > index {
            runs.push({ ..run, automation: run.automation - 1, })
          }
        }
        {
          ..model,
          automations,
          automation_runs: runs,
          automation_selected: if index >= automations.length() {
            if automations.is_empty() {
              0
            } else {
              automations.length() - 1
            }
          } else {
            index
          },
        }
      }
    ToggleAutomationRuns =>
      { ..model, automation_runs_expanded: !model.automation_runs_expanded, }
    ToggleHelp => { ..model, help_open: !model.help_open, }
    SelectDiffLine(index) => { ..model, diff_selected: index, diff_anchor: -1, }
    MoveDiffSelection(delta) =>
      if model.screen != DiffScreen {
        model
      } else {
        let count = diff_line_count(model)
        if count == 0 {
          model
        } else {
          let next = model.diff_selected + delta
          let clamped = if next < 0 {
            0
          } else if next >= count {
            count - 1
          } else {
            next
          }
          if clamped == model.diff_selected {
            model
          } else {
            {
              ..model,
              diff_selected: clamped,
              diff_anchor: -1,
              diff_note_open: false,
            }
          }
        }
      }
    ExtendDiffSelection(delta) =>
      if model.screen != DiffScreen {
        model
      } else {
        let count = diff_line_count(model)
        if count == 0 {
          model
        } else {
          let next = model.diff_selected + delta
          let clamped = if next < 0 {
            0
          } else if next >= count {
            count - 1
          } else {
            next
          }
          if clamped == model.diff_selected {
            model
          } else {
            {
              ..model,
              diff_anchor: if model.diff_anchor < 0 {
                model.diff_selected
              } else {
                model.diff_anchor
              },
              diff_selected: clamped,
            }
          }
        }
      }
    SelectDiffFile(index) =>
      if index < 0 ||
        index >= model.diff_closed.length() ||
        model.diff_closed[index] ||
        index == model.diff_file {
        model
      } else {
        {
          ..model,
          diff_file: index,
          diff_selected: 0,
          diff_anchor: -1,
          diff_note_open: false,
          diff_draft: "",
          diff_file_menu_open: false,
        }
      }
    CloseDiffFile(index) =>
      { ..close_diff_file(model, index), diff_file_menu_open: false, }
    SetDiffVerdict(verdict) => { ..model, diff_verdict: verdict, }
    ToggleDiffNote => { ..model, diff_note_open: !model.diff_note_open, }
    ToggleDiffFileMenu =>
      if model.screen != DiffScreen {
        model
      } else {
        { ..model, diff_file_menu_open: !model.diff_file_menu_open, }
      }
    CloseDiffFileMenu => { ..model, diff_file_menu_open: false, }
    OpenDiffFile(index) =>
      if index < 0 || index >= model.diff_closed.length() {
        model
      } else if index == model.diff_file && !model.diff_closed[index] {
        { ..model, diff_file_menu_open: false, }
      } else {
        let closed = model.diff_closed.copy()
        closed[index] = false
        {
          ..model,
          diff_closed: closed,
          diff_file: index,
          diff_selected: 0,
          diff_anchor: -1,
          diff_note_open: false,
          diff_draft: "",
          diff_file_menu_open: false,
        }
      }
    ToggleDiffFocus => { ..model, diff_focus: !model.diff_focus, }
    DiffDraftInput(text) =>
      {
        ..model,
        diff_draft: text,
        dictation_target: 0,
        composer_pick: -1,
        diff_composer_menu_closed: false,
      }
    DiffSend => {
      let text = model.diff_draft.trim_space().to_string()
      if text == "" {
        model
      } else {
        let notes = model.diff_notes.copy()
        let (line, end_line) = diff_selection_bounds(model)
        let existing = diff_note_index(model, model.diff_file, line, end_line)
        if existing >= 0 {
          notes[existing] = { ..notes[existing], text, }
        } else {
          notes.push({ file: model.diff_file, line, end_line, text, })
        }
        {
          ..post_diff_message(model, text),
          diff_notes: notes,
          diff_note_open: true,
        }
      }
    }
    SendDiffNote => {
      let (line, end_line) = diff_selection_bounds(model)
      let note = diff_note_index(model, model.diff_file, line, end_line)
      if note < 0 {
        model
      } else {
        post_diff_message(model, model.diff_notes[note].text)
      }
    }
    EditDiffNote => {
      let (line, end_line) = diff_selection_bounds(model)
      let note = diff_note_index(model, model.diff_file, line, end_line)
      if note < 0 {
        { ..model, diff_note_open: true, }
      } else {
        {
          ..model,
          diff_draft: model.diff_notes[note].text,
          diff_note_open: true,
        }
      }
    }
    DeleteDiffNote => {
      let (line, end_line) = diff_selection_bounds(model)
      let index = diff_note_index(model, model.diff_file, line, end_line)
      if index < 0 {
        { ..model, diff_note_open: false, diff_draft: "", }
      } else {
        let notes = model.diff_notes.copy()
        ignore(notes.remove(index))
        { ..model, diff_notes: notes, diff_note_open: false, diff_draft: "", }
      }
    }
    DiffStop => { ..model, diff_working: false, }
    AddDiffFile => {
      let mut first_closed = -1
      let mut index = 0
      while index < model.diff_closed.length() {
        if model.diff_closed[index] && first_closed < 0 {
          first_closed = index
        }
        index = index + 1
      }
      if first_closed >= 0 {
        apply_msg(model, OpenDiffFile(first_closed))
      } else {
        { ..model, diff_file_menu_open: true, }
      }
    }
    ShowProjects =>
      {
        ..model,
        screen: Projects,
        section: Search,
        bot_status_menu_open: false,
        app_menu_open: false,
        diff_file_menu_open: false,
        task_link_menu_open: false,
      }
    ShowProjectsOptions =>
      {
        ..model,
        screen: Projects,
        section: Search,
        sidebar_open: true,
        sidebar_options_open: true,
        bot_status_menu_open: false,
        app_menu_open: false,
        diff_file_menu_open: false,
        task_link_menu_open: false,
      }
    Noop => model
  }
}

///|
/// Snapshot of the fields the back/forward arrows navigate between.
fn nav_entry(model : Model) -> NavEntry {
  {
    screen: model.screen,
    section: model.section,
    active: model.active,
    active_bot: model.active_bot,
    active_session: model.active_session,
    center_tab: model.center_tab,
    bot_chat_open: model.bot_chat_open,
    bot_eng_open: model.bot_eng_open,
  }
}

///|
/// Restores a recorded navigation target and closes transient overlays.
fn apply_nav(model : Model, entry : NavEntry) -> Model {
  let active = if find_worktree(model, entry.active).is_some() {
    entry.active
  } else {
    model.active
  }
  {
    ..model,
    screen: entry.screen,
    section: entry.section,
    active,
    active_bot: entry.active_bot,
    active_session: entry.active_session,
    center_tab: entry.center_tab,
    bot_chat_open: entry.bot_chat_open,
    bot_eng_open: entry.bot_eng_open,
    hover: "",
    ctx_open: false,
    modal_open: false,
    help_open: false,
    sidebar_options_open: false,
    bots_options_open: false,
    bot_search_open: false,
    bot_status_menu_open: false,
    task_composer_open: false,
    task_detail_editing: false,
    task_link_menu_open: false,
    automation_editor_open: false,
    diff_note_open: false,
    diff_file_menu_open: false,
    diff_draft: "",
  }
}

///|
/// Pure update function. Navigation changes record a history entry so the
/// tab-strip back/forward arrows can restore the previous location.
pub fn update(model : Model, msg : Msg) -> Model {
  let next = apply_msg(model, msg)
  match msg {
    GoBack | GoForward => next
    _ => {
      let before = nav_entry(model)
      let after = nav_entry(next)
      if before == after {
        next
      } else {
        let back = model.nav_back.copy()
        back.push(before)
        { ..next, nav_back: back, nav_forward: [], }
      }
    }
  }
}

///|
/// Page-level Enter routing once completion menus have had first refusal.
/// Overlays, open editors and compact drawers stay inert so their own submit
/// handler can run.
pub fn enter_page_action(model : Model, drawer_open : Bool) -> Msg {
  if drawer_open ||
    model.modal_open ||
    model.rename_open ||
    model.delete_open ||
    model.automation_editor_open ||
    model.help_open ||
    model.ctx_open ||
    model.app_menu_open ||
    model.task_link_menu_open {
    Noop
  } else if model.screen == SearchScreen {
    OpenTopSearchHit
  } else if model.screen == TasksScreen &&
    !model.task_composer_open &&
    !model.task_detail_editing {
    ActivateTaskSelection
  } else if model.screen == AutomationsScreen {
    ActivateAutomationSelection
  } else {
    Noop
  }
}

///|
/// Overlays, open editors and compact drawers take the arrow keys before
/// page-level selection navigation. Composer completion menus route their own
/// arrows earlier and are not covered here.
pub fn page_arrow_blocked(model : Model, drawer_open : Bool) -> Bool {
  if drawer_open ||
    model.modal_open ||
    model.rename_open ||
    model.delete_open ||
    model.automation_editor_open ||
    model.help_open ||
    model.ctx_open ||
    model.app_menu_open ||
    model.task_link_menu_open {
    true
  } else if model.screen == TasksScreen {
    model.task_composer_open || model.task_detail_editing
  } else if model.screen == Bots {
    model.bots_collapsed ||
    model.bot_search_open ||
    model.bots_options_open ||
    model.bot_status_menu_open
  } else if model.screen == DiffScreen {
    model.diff_file_menu_open
  } else {
    false
  }
}
