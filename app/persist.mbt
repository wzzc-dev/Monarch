///|
/// Version of the JSON payload written by `save_model_json`. Bump it whenever
/// the shape changes so stale payloads fall back to the seed model instead of
/// being half-restored.
let persist_version : Int32 = 1

///|
fn persist_obj(fields : Array[(String, Json)]) -> Json {
  Json::object(Map(fields))
}

///|
fn persist_text(value : String) -> Json {
  Json::string(value)
}

///|
fn persist_int(value : Int32) -> Json {
  Json::number(value.to_double())
}

///|
fn persist_double(value : Double) -> Json {
  Json::number(value)
}

///|
fn persist_bool(value : Bool) -> Json {
  Json::boolean(value)
}

///|
fn persist_string_array(items : Array[String]) -> Json {
  let values : Array[Json] = []
  for item in items {
    values.push(persist_text(item))
  }
  Json::array(values)
}

///|
fn persist_bool_array(items : Array[Bool]) -> Json {
  let values : Array[Json] = []
  for item in items {
    values.push(persist_bool(item))
  }
  Json::array(values)
}

///|
fn json_string_of(value : Json?) -> String? {
  match value {
    Some(String(text)) => Some(text)
    _ => None
  }
}

///|
fn json_int_of(value : Json?) -> Int32? {
  match value {
    Some(Number(number, repr=_)) => {
      let integer = number.to_int()
      if integer.to_double() == number {
        Some(integer)
      } else {
        None
      }
    }
    _ => None
  }
}

///|
fn json_double_of(value : Json?) -> Double? {
  match value {
    Some(Number(number, repr=_)) => Some(number)
    _ => None
  }
}

///|
fn stored_text(fields : Map[String, Json], key : String) -> String {
  match fields.get(key) {
    Some(String(text)) => text
    _ => ""
  }
}

///|
fn stored_bool(
  fields : Map[String, Json],
  key : String,
  fallback : Bool,
) -> Bool {
  match fields.get(key) {
    Some(True) => true
    Some(False) => false
    _ => fallback
  }
}

///|
fn stored_int(
  fields : Map[String, Json],
  key : String,
  fallback : Int32,
) -> Int32 {
  match json_int_of(fields.get(key)) {
    Some(value) => value
    None => fallback
  }
}

///|
fn encode_screen(screen : Screen) -> String {
  match screen {
    Projects => "projects"
    Bots => "bots"
    SearchScreen => "search"
    TasksScreen => "tasks"
    AutomationsScreen => "automations"
    DiffScreen => "diff"
  }
}

///|
fn decode_screen(value : String) -> Screen? {
  match value {
    "projects" => Some(Projects)
    "bots" => Some(Bots)
    "search" => Some(SearchScreen)
    "tasks" => Some(TasksScreen)
    "automations" => Some(AutomationsScreen)
    "diff" => Some(DiffScreen)
    _ => None
  }
}

///|
fn encode_section(section : NavSection) -> String {
  match section {
    Search => "search"
    Tasks => "tasks"
    Automations => "automations"
    Bots => "bots"
  }
}

///|
fn decode_section(value : String) -> NavSection? {
  match value {
    "search" => Some(Search)
    "tasks" => Some(Tasks)
    "automations" => Some(Automations)
    "bots" => Some(Bots)
    _ => None
  }
}

///|
fn encode_tool_chip_kind(kind : ToolChipKind) -> String {
  match kind {
    Neutral => "neutral"
    Amber => "amber"
    Green => "green"
    Link => "link"
    Status => "status"
    Plain => "plain"
  }
}

///|
fn decode_tool_chip_kind(value : String) -> ToolChipKind {
  match value {
    "amber" => Amber
    "green" => Green
    "link" => Link
    "status" => Status
    "plain" => Plain
    _ => Neutral
  }
}

///|
fn encode_tool_chip(chip : ToolChip) -> Json {
  persist_obj([
    ("text", persist_text(chip.text)),
    ("kind", persist_text(encode_tool_chip_kind(chip.kind))),
  ])
}

///|
fn decode_tool_chip(value : Json) -> ToolChip? {
  guard value is Object(fields) else { return None }
  Some({
    text: stored_text(fields, "text"),
    kind: match json_string_of(fields.get("kind")) {
      Some(code) => decode_tool_chip_kind(code)
      None => Neutral
    },
  })
}

///|
fn encode_activity_icon(icon : ActivityIcon) -> String {
  match icon {
    AddActivity => "add"
    PlayActivity => "play"
    CheckActivity => "check"
    LinkActivity => "link"
    CommentActivity => "comment"
  }
}

///|
fn decode_activity_icon(value : String) -> ActivityIcon {
  match value {
    "play" => PlayActivity
    "check" => CheckActivity
    "link" => LinkActivity
    "comment" => CommentActivity
    _ => AddActivity
  }
}

///|
fn encode_bot_activity(activity : BotActivity) -> Json {
  persist_obj([
    ("icon", persist_text(encode_activity_icon(activity.icon))),
    ("text", persist_text(activity.text)),
    ("sub", persist_text(activity.sub)),
    ("time", persist_text(activity.time)),
  ])
}

///|
fn decode_bot_activity(value : Json) -> BotActivity? {
  guard value is Object(fields) else { return None }
  Some({
    icon: match json_string_of(fields.get("icon")) {
      Some(code) => decode_activity_icon(code)
      None => AddActivity
    },
    text: stored_text(fields, "text"),
    sub: stored_text(fields, "sub"),
    time: stored_text(fields, "time"),
  })
}

///|
fn encode_item_message(message : BotMessage) -> Json {
  persist_obj([
    ("name", persist_text(message.name)),
    ("time", persist_text(message.time)),
    ("line1", persist_text(message.line1)),
    ("line2", persist_text(message.line2)),
    ("reply_chip", persist_text(message.reply_chip)),
  ])
}

///|
fn decode_item_message(value : Json) -> BotMessage? {
  guard value is Object(fields) else { return None }
  Some({
    name: stored_text(fields, "name"),
    time: stored_text(fields, "time"),
    line1: stored_text(fields, "line1"),
    line2: stored_text(fields, "line2"),
    reply_chip: stored_text(fields, "reply_chip"),
  })
}

///|
fn encode_bot_item(item : BotItem) -> Json {
  let chips : Array[Json] = []
  for chip in item.chips {
    chips.push(encode_tool_chip(chip))
  }
  let activities : Array[Json] = []
  for activity in item.activities {
    activities.push(encode_bot_activity(activity))
  }
  persist_obj([
    ("number", persist_text(item.number)),
    ("title", persist_text(item.title)),
    ("state", persist_text(item.state)),
    ("meta", persist_text(item.meta)),
    ("chips", Json::array(chips)),
    ("done_means", persist_text(item.done_means)),
    ("activities", Json::array(activities)),
    (
      "message",
      match item.message {
        Some(message) => encode_item_message(message)
        None => Json::null()
      },
    ),
  ])
}

///|
fn decode_bot_item(value : Json) -> BotItem? {
  guard value is Object(fields) else { return None }
  let chips : Array[ToolChip] = []
  match fields.get("chips") {
    Some(Array(items)) =>
      for item in items {
        match decode_tool_chip(item) {
          Some(chip) => chips.push(chip)
          None => ()
        }
      }
    _ => ()
  }
  let activities : Array[BotActivity] = []
  match fields.get("activities") {
    Some(Array(items)) =>
      for item in items {
        match decode_bot_activity(item) {
          Some(activity) => activities.push(activity)
          None => ()
        }
      }
    _ => ()
  }
  Some({
    number: stored_text(fields, "number"),
    title: stored_text(fields, "title"),
    state: stored_text(fields, "state"),
    meta: stored_text(fields, "meta"),
    chips,
    done_means: stored_text(fields, "done_means"),
    activities,
    message: match fields.get("message") {
      Some(value) => decode_item_message(value)
      None => None
    },
  })
}

///|
fn encode_agent_kind(kind : AgentKind) -> String {
  match kind {
    Claude => "claude"
    Codex => "codex"
    Grok => "grok"
  }
}

///|
fn decode_agent_kind(value : String) -> AgentKind {
  match value {
    "codex" => Codex
    "grok" => Grok
    _ => Claude
  }
}

///|
fn encode_agent_status(status : AgentStatus) -> String {
  match status {
    Running => "running"
    Working => "working"
    Done => "done"
    Idle => "idle"
  }
}

///|
fn decode_agent_status(value : String) -> AgentStatus {
  match value {
    "running" => Running
    "working" => Working
    "idle" => Idle
    _ => Done
  }
}

///|
fn encode_task_source(source : TaskSource) -> String {
  match source {
    GitHubTask => "github"
    LinearTask => "linear"
    SlackTask => "slack"
  }
}

///|
fn decode_task_source(value : String) -> TaskSource {
  match value {
    "linear" => LinearTask
    "slack" => SlackTask
    _ => GitHubTask
  }
}

///|
fn encode_task_status(status : TaskStatus) -> String {
  match status {
    TaskNeedsYou => "needs-you"
    TaskInProgress => "in-progress"
    TaskDone => "done"
  }
}

///|
fn decode_task_status(value : String) -> TaskStatus {
  match value {
    "in-progress" => TaskInProgress
    "done" => TaskDone
    _ => TaskNeedsYou
  }
}

///|
fn encode_mascot(mascot : Mascot) -> String {
  match mascot {
    Scout => "scout"
    CIWatch => "ci-watch"
    ReviewBuddy => "review-buddy"
    ReleaseNotes => "release-notes"
    Standup => "standup"
    DocsHelper => "docs-helper"
  }
}

///|
fn decode_mascot(value : String) -> Mascot {
  match value {
    "scout" => Scout
    "ci-watch" => CIWatch
    "review-buddy" => ReviewBuddy
    "release-notes" => ReleaseNotes
    "docs-helper" => DocsHelper
    _ => Standup
  }
}

///|
fn encode_task_activity(entry : TaskActivity) -> Json {
  persist_obj([
    ("icon", persist_text(encode_activity_icon(entry.icon))),
    ("text", persist_text(entry.text)),
    ("time", persist_text(entry.time)),
  ])
}

///|
fn decode_task_activity(value : Json) -> TaskActivity? {
  guard value is Object(fields) else { return None }
  Some({
    icon: match json_string_of(fields.get("icon")) {
      Some(code) => decode_activity_icon(code)
      None => AddActivity
    },
    text: stored_text(fields, "text"),
    time: stored_text(fields, "time"),
  })
}

///|
fn encode_task(task : Task) -> Json {
  let activity_items : Array[Json] = []
  for entry in task.activity {
    activity_items.push(encode_task_activity(entry))
  }
  persist_obj([
    ("title", persist_text(task.title)),
    ("repo", persist_text(task.repo)),
    ("labels", persist_text(task.labels)),
    ("source", persist_text(encode_task_source(task.source))),
    ("status", persist_text(encode_task_status(task.status))),
    ("time", persist_text(task.time)),
    ("worktree_id", persist_text(task.worktree_id)),
    ("detail", persist_text(task.detail)),
    ("agent", persist_text(encode_agent_kind(task.agent))),
    ("agent_model", persist_text(task.agent_model)),
    ("assignee", persist_text(task.assignee)),
    ("activity", Json::array(activity_items)),
  ])
}

///|
fn decode_task(value : Json) -> Task? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("title")) {
    None => None
    Some(title) => {
      let source = match json_string_of(fields.get("source")) {
        Some(code) => decode_task_source(code)
        None => GitHubTask
      }
      let status = match json_string_of(fields.get("status")) {
        Some(code) => decode_task_status(code)
        None => TaskNeedsYou
      }
      let agent = match json_string_of(fields.get("agent")) {
        Some(code) => decode_agent_kind(code)
        None => Claude
      }
      let assignee = match json_string_of(fields.get("assignee")) {
        Some(value) => value
        None => if agent == Claude { "you" } else { "" }
      }
      let time = stored_text(fields, "time")
      let worktree_id = stored_text(fields, "worktree_id")
      let activity = match fields.get("activity") {
        Some(Array(items)) => {
          let out : Array[TaskActivity] = []
          for item in items {
            match decode_task_activity(item) {
              Some(entry) => out.push(entry)
              None => return None
            }
          }
          if out.length() == 0 {
            default_task_activity(
              source, time, assignee, worktree_id, agent, status,
            )
          } else {
            out
          }
        }
        _ =>
          default_task_activity(
            source, time, assignee, worktree_id, agent, status,
          )
      }
      Some({
        title,
        repo: stored_text(fields, "repo"),
        labels: stored_text(fields, "labels"),
        source,
        status,
        time,
        worktree_id,
        detail: stored_text(fields, "detail"),
        agent,
        agent_model: stored_text(fields, "agent_model"),
        assignee,
        activity,
      })
    }
  }
}

///|
fn encode_automation(item : Automation) -> Json {
  persist_obj([
    ("name", persist_text(item.name)),
    ("subtitle", persist_text(item.subtitle)),
    ("schedule", persist_text(item.schedule)),
    ("schedule_index", persist_int(item.schedule_index)),
    ("last_run", persist_text(item.last_run)),
    ("status", persist_text(item.status)),
    ("tone", persist_text(encode_task_status(item.tone))),
    ("enabled", persist_bool(item.enabled)),
  ])
}

///|
fn decode_automation(value : Json) -> Automation? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("name")) {
    None => None
    Some(name) =>
      Some({
        name,
        subtitle: stored_text(fields, "subtitle"),
        schedule: stored_text(fields, "schedule"),
        schedule_index: stored_int(fields, "schedule_index", 0),
        last_run: stored_text(fields, "last_run"),
        status: stored_text(fields, "status"),
        tone: match json_string_of(fields.get("tone")) {
          Some(code) => decode_task_status(code)
          None => TaskInProgress
        },
        enabled: stored_bool(fields, "enabled", true),
        next_run_ms: 0.0,
      })
  }
}

///|
fn encode_automation_run(run : AutomationRun) -> Json {
  persist_obj([
    ("automation", persist_int(run.automation)),
    ("state", persist_text(run.state)),
    ("note", persist_text(run.note)),
    ("time", persist_text(run.time)),
    ("tone", persist_text(encode_task_status(run.tone))),
  ])
}

///|
fn decode_automation_run(value : Json) -> AutomationRun? {
  guard value is Object(fields) else { return None }
  match fields.get("automation") {
    None => None
    Some(_) =>
      Some({
        automation: stored_int(fields, "automation", 0),
        state: stored_text(fields, "state"),
        note: stored_text(fields, "note"),
        time: stored_text(fields, "time"),
        tone: match json_string_of(fields.get("tone")) {
          Some(code) => decode_task_status(code)
          None => TaskDone
        },
      })
  }
}

///|
fn encode_diff_note(note : DiffNote) -> Json {
  persist_obj([
    ("file", persist_int(note.file)),
    ("line", persist_int(note.line)),
    ("end_line", persist_int(note.end_line)),
    ("text", persist_text(note.text)),
  ])
}

///|
fn decode_diff_note(value : Json) -> DiffNote? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("text")) {
    None => None
    Some(text) =>
      Some({
        file: stored_int(fields, "file", 0),
        line: stored_int(fields, "line", 0),
        end_line: stored_int(fields, "end_line", 0),
        text,
      })
  }
}

///|
fn encode_block(block : Block) -> Json {
  match block {
    UserMessage(text) =>
      persist_obj([("kind", persist_text("user")), ("text", persist_text(text))])
    AssistantMessage(text) =>
      persist_obj([
        ("kind", persist_text("assistant")),
        ("text", persist_text(text)),
      ])
    Worked(row) =>
      persist_obj([
        ("kind", persist_text("worked")),
        ("label", persist_text(row.label)),
        ("body", persist_text(row.body)),
        ("expanded", persist_bool(row.expanded)),
      ])
    Worker(card) =>
      persist_obj([
        ("kind", persist_text("worker")),
        ("name", persist_text(card.name)),
        ("agent", persist_text(encode_agent_kind(card.kind))),
        ("time", persist_text(card.time)),
        ("body", persist_text(card.body)),
        ("focused", persist_bool(card.focused)),
      ])
    LiveRow(label, value) =>
      persist_obj([
        ("kind", persist_text("live")),
        ("label", persist_text(label)),
        ("value", persist_text(value)),
      ])
  }
}

///|
fn decode_block(value : Json) -> Block? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("kind")) {
    None => None
    Some(kind) =>
      match kind {
        "user" => Some(UserMessage(stored_text(fields, "text")))
        "assistant" => Some(AssistantMessage(stored_text(fields, "text")))
        "worked" =>
          Some(
            Worked({
              label: stored_text(fields, "label"),
              body: stored_text(fields, "body"),
              expanded: stored_bool(fields, "expanded", false),
            }),
          )
        "worker" =>
          Some(
            Worker({
              name: stored_text(fields, "name"),
              kind: match json_string_of(fields.get("agent")) {
                Some(code) => decode_agent_kind(code)
                None => Claude
              },
              time: stored_text(fields, "time"),
              body: stored_text(fields, "body"),
              focused: stored_bool(fields, "focused", false),
            }),
          )
        "live" =>
          Some(
            LiveRow(stored_text(fields, "label"), stored_text(fields, "value")),
          )
        _ => None
      }
  }
}

///|
fn encode_agent(agent : Agent) -> Json {
  persist_obj([
    ("name", persist_text(agent.name)),
    ("kind", persist_text(encode_agent_kind(agent.kind))),
    ("model", persist_text(agent.model)),
    ("time", persist_text(agent.time)),
    ("status", persist_text(encode_agent_status(agent.status))),
  ])
}

///|
fn decode_agent(value : Json) -> Agent? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("name")) {
    None => None
    Some(name) =>
      Some({
        name,
        kind: match json_string_of(fields.get("kind")) {
          Some(code) => decode_agent_kind(code)
          None => Claude
        },
        model: stored_text(fields, "model"),
        time: stored_text(fields, "time"),
        status: match json_string_of(fields.get("status")) {
          Some(code) => decode_agent_status(code)
          None => Done
        },
      })
  }
}

///|
priv struct PersistedWorktree {
  project_id : String
  worktree : Worktree
}

///|
fn encode_worktree(project_id : String, worktree : Worktree) -> Json {
  let agent_items : Array[Json] = []
  for agent in worktree.agents {
    agent_items.push(encode_agent(agent))
  }
  let block_items : Array[Json] = []
  for block in worktree.transcript {
    block_items.push(encode_block(block))
  }
  persist_obj([
    ("project", persist_text(project_id)),
    ("id", persist_text(worktree.id)),
    ("name", persist_text(worktree.name)),
    ("branch", persist_text(worktree.branch)),
    ("primary", persist_bool(worktree.primary)),
    ("tab_title", persist_text(worktree.tab_title)),
    ("agents", Json::array(agent_items)),
    ("transcript", Json::array(block_items)),
  ])
}

///|
fn decode_worktree(value : Json) -> PersistedWorktree? {
  guard value is Object(fields) else { return None }
  guard json_string_of(fields.get("project")) is Some(project_id) else {
    return None
  }
  guard json_string_of(fields.get("id")) is Some(id) else { return None }
  guard json_string_of(fields.get("name")) is Some(name) else { return None }
  let agents = match fields.get("agents") {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[Agent] = []
      let mut failed = false
      for item in items {
        match decode_agent(item) {
          Some(agent) => out.push(agent)
          None => failed = true
        }
      }
      if failed {
        None
      } else {
        Some(out)
      }
    }
    _ => None
  }
  let transcript = match decode_blocks(fields.get("transcript")) {
    Some(items) => Some(items)
    None => None
  }
  let branch = stored_text(fields, "branch")
  let tab_title = {
    let title = stored_text(fields, "tab_title")
    if title == "" {
      name
    } else {
      title
    }
  }
  match agents {
    None => None
    Some(agents) =>
      match transcript {
        None => None
        Some(transcript) =>
          Some({
            project_id,
            worktree: {
              id,
              name,
              branch,
              primary: stored_bool(fields, "primary", false),
              tab_title,
              agents,
              transcript,
            },
          })
      }
  }
}

///|
fn decode_worktrees(value : Json?) -> Array[PersistedWorktree]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[PersistedWorktree] = []
      for item in items {
        match decode_worktree(item) {
          Some(entry) => out.push(entry)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn merge_worktrees(
  model : Model,
  entries : Array[PersistedWorktree],
  deleted : Array[String],
) -> Model {
  let machines : Array[Machine] = []
  for machine in model.machines {
    let projects : Array[Project] = []
    for project in machine.projects {
      let worktrees : Array[Worktree] = []
      for worktree in project.worktrees {
        if !deleted_has(deleted, worktree.id) {
          worktrees.push(worktree)
        }
      }
      for entry in entries {
        if entry.project_id == project.id &&
          !deleted_has(deleted, entry.worktree.id) {
          let mut found = false
          let mut i = 0
          while i < worktrees.length() {
            if worktrees[i].id == entry.worktree.id {
              worktrees[i] = entry.worktree
              found = true
              break
            }
            i = i + 1
          }
          if !found {
            worktrees.push(entry.worktree)
          }
        }
      }
      projects.push({ ..project, worktrees, })
    }
    machines.push({ ..machine, projects, })
  }
  { ..model, machines, }
}

///|
fn encode_bot_message(message : BotChatMessage) -> Json {
  persist_obj([
    ("key", persist_text(message.key)),
    ("block", encode_block(message.block)),
  ])
}

///|
fn decode_bot_message(value : Json) -> BotChatMessage? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("key")) {
    None => None
    Some(key) =>
      match fields.get("block") {
        Some(block) =>
          match decode_block(block) {
            Some(decoded) => Some({ key, block: decoded, })
            None => None
          }
        None => None
      }
  }
}

///|
fn encode_comment(comment : BotComment) -> Json {
  persist_obj([
    ("key", persist_text(comment.key)),
    ("text", persist_text(comment.text)),
  ])
}

///|
fn decode_comment(value : Json) -> BotComment? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("key")) {
    None => None
    Some(key) =>
      match json_string_of(fields.get("text")) {
        Some(text) => Some({ key, text, })
        None => None
      }
  }
}

///|
fn encode_bot(bot : Bot) -> Json {
  let fields : Array[(String, Json)] = [
    ("id", persist_text(bot.id)),
    ("name", persist_text(bot.name)),
    ("mascot", persist_text(encode_mascot(bot.mascot))),
    ("subtitle", persist_text(bot.subtitle)),
    ("status", persist_text(encode_agent_status(bot.status))),
    ("item_state", persist_text(bot.item_state)),
  ]
  match bot.item {
    Some(item) => fields.push(("item", encode_bot_item(item)))
    None => fields.push(("item", Json::null()))
  }
  persist_obj(fields)
}

///|
fn decode_bot(value : Json) -> Bot? {
  guard value is Object(fields) else { return None }
  match json_string_of(fields.get("id")) {
    None => None
    Some(id) => {
      let name = match json_string_of(fields.get("name")) {
        Some(text) => text
        None => id
      }
      Some({
        id,
        name,
        mascot: match json_string_of(fields.get("mascot")) {
          Some(code) => decode_mascot(code)
          None => Standup
        },
        working: 0,
        subtitle: stored_text(fields, "subtitle"),
        time: "now",
        status: match json_string_of(fields.get("status")) {
          Some(code) => decode_agent_status(code)
          None => Idle
        },
        item_state: stored_text(fields, "item_state"),
        sessions: [session("\{id}-home", Home, "Home Chat", "now", Done)],
        item: match fields.get("item") {
          Some(value) => decode_bot_item(value)
          None => None
        },
      })
    }
  }
}

///|
fn clampi(value : Int32, low : Int32, high : Int32) -> Int32 {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

///|
fn clamp_selected(value : Int32, length : Int32) -> Int32 {
  if length <= 0 {
    0
  } else {
    clampi(value, 0, length - 1)
  }
}

///|
fn bots_have_id(bots : Array[Bot], id : String) -> Bool {
  for bot in bots {
    if bot.id == id {
      return true
    }
  }
  false
}

///|
fn bot_has_session(
  bots : Array[Bot],
  bot_id : String,
  session_id : String,
) -> Bool {
  for bot in bots {
    if bot.id == bot_id {
      for session in bot.sessions {
        if session.id == session_id {
          return true
        }
      }
    }
  }
  false
}

///|
fn decode_tasks(value : Json?) -> Array[Task]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[Task] = []
      for item in items {
        match decode_task(item) {
          Some(task) => out.push(task)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_automations(value : Json?) -> Array[Automation]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[Automation] = []
      for item in items {
        match decode_automation(item) {
          Some(automation) => out.push(automation)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_automation_runs(value : Json?) -> Array[AutomationRun]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[AutomationRun] = []
      for item in items {
        match decode_automation_run(item) {
          Some(run) => out.push(run)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_diff_notes(value : Json?) -> Array[DiffNote]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[DiffNote] = []
      for item in items {
        match decode_diff_note(item) {
          Some(note) => out.push(note)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_blocks(value : Json?) -> Array[Block]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[Block] = []
      for item in items {
        match decode_block(item) {
          Some(block) => out.push(block)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_bot_messages(value : Json?) -> Array[BotChatMessage]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[BotChatMessage] = []
      for item in items {
        match decode_bot_message(item) {
          Some(message) => out.push(message)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_comments(value : Json?) -> Array[BotComment]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[BotComment] = []
      for item in items {
        match decode_comment(item) {
          Some(comment) => out.push(comment)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_bots(value : Json?) -> Array[Bot]? {
  match value {
    None => Some([])
    Some(Array(items)) => {
      let out : Array[Bot] = []
      for item in items {
        match decode_bot(item) {
          Some(bot) => out.push(bot)
          None => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_string_list(value : Json?) -> Array[String]? {
  match value {
    None => None
    Some(Array(items)) => {
      let out : Array[String] = []
      for item in items {
        match item {
          String(text) => out.push(text)
          _ => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
fn decode_bool_list(value : Json?) -> Array[Bool]? {
  match value {
    None => None
    Some(Array(items)) => {
      let out : Array[Bool] = []
      for item in items {
        match item {
          True => out.push(true)
          False => out.push(false)
          _ => return None
        }
      }
      Some(out)
    }
    _ => None
  }
}

///|
/// Serialize the durable part of the model. Transient overlays, drafts and
/// filters are intentionally left out so a restart lands on a calm screen;
/// the seed model supplies everything that is not user-authored.
pub fn save_model_json(model : Model) -> String {
  let fields : Array[(String, Json)] = []
  fields.push(("version", persist_int(persist_version)))
  fields.push(("screen", persist_text(encode_screen(model.screen))))
  fields.push(("section", persist_text(encode_section(model.section))))
  fields.push(("active", persist_text(model.active)))
  fields.push(("tabs", persist_string_array(model.tabs)))
  fields.push(
    ("deleted_worktrees", persist_string_array(model.deleted_worktrees)),
  )
  let worktree_items : Array[Json] = []
  for machine in model.machines {
    for project in machine.projects {
      for worktree in project.worktrees {
        worktree_items.push(encode_worktree(project.id, worktree))
      }
    }
  }
  fields.push(("worktrees", Json::array(worktree_items)))
  fields.push(("sidebar_w", persist_double(model.sidebar_w)))
  fields.push(("bots_sidebar_w", persist_double(model.bots_sidebar_w)))
  fields.push(("bots_panel_w", persist_double(model.bots_panel_w)))
  fields.push(
    ("collapsed_machines", persist_string_array(model.collapsed_machines)),
  )
  fields.push(
    ("collapsed_projects", persist_string_array(model.collapsed_projects)),
  )
  fields.push(("task_selected", persist_int(model.task_selected)))
  fields.push(("task_filter", persist_int(model.task_filter)))
  fields.push(("task_source_filter", persist_int(model.task_source_filter)))
  let task_items : Array[Json] = []
  for task in model.tasks {
    task_items.push(encode_task(task))
  }
  fields.push(("tasks", Json::array(task_items)))
  fields.push(("automation_selected", persist_int(model.automation_selected)))
  fields.push(
    ("automation_runs_expanded", persist_bool(model.automation_runs_expanded)),
  )
  let automation_items : Array[Json] = []
  for automation in model.automations {
    automation_items.push(encode_automation(automation))
  }
  fields.push(("automations", Json::array(automation_items)))
  let run_items : Array[Json] = []
  for run in model.automation_runs {
    run_items.push(encode_automation_run(run))
  }
  fields.push(("automation_runs", Json::array(run_items)))
  fields.push(
    ("automation_runs_today", persist_int(model.automation_runs_today)),
  )
  fields.push(
    ("automation_runs_yesterday", persist_int(model.automation_runs_yesterday)),
  )
  fields.push(
    ("automation_passed_today", persist_int(model.automation_passed_today)),
  )
  fields.push(
    (
      "automation_attention_today",
      persist_int(model.automation_attention_today),
    ),
  )
  fields.push(("diff_file", persist_int(model.diff_file)))
  fields.push(("diff_worktree", persist_text(model.diff_worktree)))
  fields.push(("diff_verdict", persist_int(model.diff_verdict)))
  fields.push(("diff_closed", persist_bool_array(model.diff_closed)))
  let note_items : Array[Json] = []
  for note in model.diff_notes {
    note_items.push(encode_diff_note(note))
  }
  fields.push(("diff_notes", Json::array(note_items)))
  fields.push(("diff_working", persist_bool(model.diff_working)))
  let diff_message_items : Array[Json] = []
  for block in model.diff_messages {
    diff_message_items.push(encode_block(block))
  }
  fields.push(("diff_messages", Json::array(diff_message_items)))
  fields.push(("active_bot", persist_text(model.active_bot)))
  fields.push(("center_tab", persist_int(model.center_tab)))
  fields.push(("panel_tab", persist_int(model.panel_tab)))
  fields.push(("active_session", persist_text(model.active_session)))
  fields.push(("bot_chat_open", persist_bool(model.bot_chat_open)))
  fields.push(("bot_eng_open", persist_bool(model.bot_eng_open)))
  fields.push(("bots_show_sessions", persist_bool(model.bots_show_sessions)))
  fields.push(("composer_model", persist_int(model.composer_model)))
  fields.push(("composer_access", persist_int(model.composer_access)))
  let comment_items : Array[Json] = []
  for comment in model.comments {
    comment_items.push(encode_comment(comment))
  }
  fields.push(("comments", Json::array(comment_items)))
  fields.push(("flag_keys", persist_string_array(model.flag_keys)))
  let message_items : Array[Json] = []
  for message in model.bot_messages {
    message_items.push(encode_bot_message(message))
  }
  fields.push(("bot_messages", Json::array(message_items)))
  fields.push(("bot_item_seq", persist_int(model.bot_item_seq)))
  let connector_flags : Array[Bool] = []
  for connector in model.connectors {
    connector_flags.push(connector.connected)
  }
  fields.push(("connector_connected", persist_bool_array(connector_flags)))
  let bot_items : Array[Json] = []
  for bot in model.bots {
    bot_items.push(encode_bot(bot))
  }
  fields.push(("bots", Json::array(bot_items)))
  Json::object(Map(fields)).stringify()
}

///|
/// Restore a model over the current seed. Missing fields keep the seed
/// values; malformed payloads, wrong versions and invalid entries return
/// `None` so the runtime can start from the seed instead.
pub fn load_model_json(payload : String) -> Model? {
  let parsed = @json.parse(payload) catch { _ => return None }
  guard parsed is Object(root) else { return None }
  guard json_int_of(root.get("version")) is Some(version) &&
    version == persist_version else {
    return None
  }
  let base = Model::new()
  let worktree_entries = match root.get("worktrees") {
    None => []
    Some(value) =>
      match decode_worktrees(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let deleted_worktrees = match
    decode_string_list(root.get("deleted_worktrees")) {
    Some(items) => items
    None => []
  }
  let merged = merge_worktrees(base, worktree_entries, deleted_worktrees)
  let screen = match json_string_of(root.get("screen")) {
    Some(code) =>
      match decode_screen(code) {
        Some(decoded) => decoded
        None => base.screen
      }
    None => base.screen
  }
  let section = match json_string_of(root.get("section")) {
    Some(code) =>
      match decode_section(code) {
        Some(decoded) => decoded
        None => base.section
      }
    None => base.section
  }
  let tabs = match decode_string_list(root.get("tabs")) {
    Some(items) => {
      let kept : Array[String] = []
      for id in items {
        if has_worktree(merged, id) {
          kept.push(id)
        }
      }
      kept
    }
    None => base.tabs.copy()
  }
  let requested_active = match json_string_of(root.get("active")) {
    Some(id) => id
    None => base.active
  }
  let active = if requested_active != "" &&
    has_worktree(merged, requested_active) {
    if !tabs_contain(tabs, requested_active) {
      tabs.push(requested_active)
    }
    requested_active
  } else if tabs.is_empty() {
    ""
  } else {
    tabs[0]
  }
  let sidebar_w = match json_double_of(root.get("sidebar_w")) {
    Some(value) => clamp_sidebar_width(value)
    None => base.sidebar_w
  }
  let bots_sidebar_w = match json_double_of(root.get("bots_sidebar_w")) {
    Some(value) => clamp_bots_sidebar_width(value)
    None => base.bots_sidebar_w
  }
  let bots_panel_w = match json_double_of(root.get("bots_panel_w")) {
    Some(value) => clamp_bots_panel_width(value)
    None => base.bots_panel_w
  }
  let collapsed_machines = match
    decode_string_list(root.get("collapsed_machines")) {
    Some(items) => items
    None => base.collapsed_machines
  }
  let collapsed_projects = match
    decode_string_list(root.get("collapsed_projects")) {
    Some(items) => items
    None => base.collapsed_projects
  }
  let tasks = match root.get("tasks") {
    None => base.tasks
    Some(value) =>
      match decode_tasks(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let task_selected = clamp_selected(
    stored_int(root, "task_selected", base.task_selected),
    tasks.length(),
  )
  let task_filter = clampi(
    stored_int(root, "task_filter", base.task_filter),
    0,
    3,
  )
  let task_source_filter = clampi(
    stored_int(root, "task_source_filter", base.task_source_filter),
    0,
    3,
  )
  let automations = match root.get("automations") {
    None => base.automations
    Some(value) =>
      match decode_automations(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let automation_runs = match root.get("automation_runs") {
    None => base.automation_runs
    Some(value) =>
      match decode_automation_runs(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let automation_selected = clamp_selected(
    stored_int(root, "automation_selected", base.automation_selected),
    automations.length(),
  )
  let automation_runs_expanded = stored_bool(
    root,
    "automation_runs_expanded",
    base.automation_runs_expanded,
  )
  let automation_runs_today = stored_int(
    root,
    "automation_runs_today",
    base.automation_runs_today,
  )
  let automation_passed_today = stored_int(
    root,
    "automation_passed_today",
    base.automation_passed_today,
  )
  let automation_runs_yesterday = stored_int(
    root,
    "automation_runs_yesterday",
    base.automation_runs_yesterday,
  )
  let automation_attention_today = stored_int(
    root,
    "automation_attention_today",
    base.automation_attention_today,
  )
  let diff_notes = match root.get("diff_notes") {
    None => base.diff_notes
    Some(value) =>
      match decode_diff_notes(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let diff_messages = match root.get("diff_messages") {
    None => base.diff_messages
    Some(value) =>
      match decode_blocks(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let diff_closed = match decode_bool_list(root.get("diff_closed")) {
    Some(items) if items.length() == base.diff_closed.length() => items
    _ => base.diff_closed
  }
  let diff_file = clampi(
    stored_int(root, "diff_file", base.diff_file),
    0,
    base.diff_closed.length() - 1,
  )
  let diff_worktree = match json_string_of(root.get("diff_worktree")) {
    Some(worktree) => worktree
    None => base.diff_worktree
  }
  let diff_working = stored_bool(root, "diff_working", base.diff_working)
  let diff_verdict = clampi(
    stored_int(root, "diff_verdict", base.diff_verdict),
    0,
    2,
  )
  let bots = match root.get("bots") {
    None => base.bots
    Some(value) =>
      match decode_bots(Some(value)) {
        Some(items) => {
          let merged = base.bots.copy()
          for bot in items {
            let mut found = false
            let mut index = 0
            while index < merged.length() {
              if merged[index].id == bot.id {
                merged[index] = {
                  ..merged[index],
                  item_state: bot.item_state,
                  item: match bot.item {
                    Some(item) => Some(item)
                    None => merged[index].item
                  },
                }
                found = true
              }
              index = index + 1
            }
            if !found {
              merged.push(bot)
            }
          }
          merged
        }
        None => return None
      }
  }
  let requested_bot = match json_string_of(root.get("active_bot")) {
    Some(id) => id
    None => base.active_bot
  }
  let active_bot = if bots_have_id(bots, requested_bot) {
    requested_bot
  } else {
    base.active_bot
  }
  let requested_session = match json_string_of(root.get("active_session")) {
    Some(id) => id
    None => base.active_session
  }
  let active_session = if bot_has_session(bots, active_bot, requested_session) {
    requested_session
  } else {
    ""
  }
  let bot_chat_open = stored_bool(root, "bot_chat_open", base.bot_chat_open)
  let bot_eng_open = stored_bool(root, "bot_eng_open", base.bot_eng_open)
  let bots_show_sessions = stored_bool(
    root,
    "bots_show_sessions",
    base.bots_show_sessions,
  )
  let comments = match root.get("comments") {
    None => base.comments
    Some(value) =>
      match decode_comments(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let flag_keys = match decode_string_list(root.get("flag_keys")) {
    Some(items) => items
    None => base.flag_keys
  }
  let bot_messages = match root.get("bot_messages") {
    None => base.bot_messages
    Some(value) =>
      match decode_bot_messages(Some(value)) {
        Some(items) => items
        None => return None
      }
  }
  let bot_item_seq = clampi(
    stored_int(root, "bot_item_seq", base.bot_item_seq),
    base.bot_item_seq,
    1000000,
  )
  let connectors = base.connectors.copy()
  match decode_bool_list(root.get("connector_connected")) {
    Some(flags) => {
      let mut i = 0
      for connector in connectors {
        if i < flags.length() {
          connectors[i] = { ..connector, connected: flags[i], }
        }
        i = i + 1
      }
    }
    None => ()
  }
  let center_tab = clampi(stored_int(root, "center_tab", base.center_tab), 0, 3)
  let panel_tab = clampi(stored_int(root, "panel_tab", base.panel_tab), 0, 3)
  let composer_model = clampi(
    stored_int(root, "composer_model", base.composer_model),
    0,
    2,
  )
  let composer_access = clampi(
    stored_int(root, "composer_access", base.composer_access),
    0,
    2,
  )
  Some({
    ..merged,
    deleted_worktrees,
    screen,
    section,
    active,
    tabs,
    sidebar_w,
    bots_sidebar_w,
    bots_panel_w,
    collapsed_machines,
    collapsed_projects,
    tasks,
    task_selected,
    task_filter,
    task_source_filter,
    automations,
    automation_runs,
    automation_runs_today,
    automation_runs_yesterday,
    automation_passed_today,
    automation_attention_today,
    automation_selected,
    automation_runs_expanded,
    diff_notes,
    diff_messages,
    diff_closed,
    diff_file,
    diff_worktree,
    diff_verdict,
    diff_working,
    bots,
    active_bot,
    active_session,
    bot_chat_open,
    bot_eng_open,
    bots_show_sessions,
    composer_model,
    composer_access,
    comments,
    flag_keys,
    bot_messages,
    bot_item_seq,
    connectors,
    center_tab,
    panel_tab,
  })
}
