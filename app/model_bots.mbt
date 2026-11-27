///|
/// Top-level screens shown in the main pane.
#derive(Eq)
pub(all) enum Screen {
  Projects
  Bots
  SearchScreen
  TasksScreen
  AutomationsScreen
  DiffScreen
}

///|
/// Avatar palette for a bot.
#derive(Eq)
pub(all) enum Mascot {
  Scout
  CIWatch
  ReviewBuddy
  ReleaseNotes
  Standup
  DocsHelper
}

///|
/// Glyph used on a nested session row.
#derive(Eq)
pub(all) enum SessionKind {
  Home
  ClaudeSession
  CodexSession
  Slack
}

///|
/// One nested session under the selected bot.
pub(all) struct Session {
  id : String
  kind : SessionKind
  label : String
  time : String
  status : AgentStatus
}

///|
/// Inline chip palette inside a tool row.
#derive(Eq)
pub(all) enum ToolChipKind {
  Neutral
  Amber
  Green
  Link
  Status
  Plain
}

///|
/// One inline chip.
pub(all) struct ToolChip {
  text : String
  kind : ToolChipKind
}

///|
/// Leading glyph on a tool row.
#derive(Eq)
pub(all) enum ToolIcon {
  List
  ClaudeTool
  CodexTool
  BotTool
  LinkTool
  PlusTool
  CheckTool
  CommentTool
  PlayTool
}

///|
/// A 24 px action/tool row in the center transcript.
pub(all) struct ToolRow {
  icon : ToolIcon
  lead : String
  chips : Array[ToolChip]
}

///|
/// Activity icon on the right item panel.
#derive(Eq)
pub(all) enum ActivityIcon {
  AddActivity
  PlayActivity
  CheckActivity
  LinkActivity
  CommentActivity
}

///|
/// One row in the item Activity list.
pub(all) struct BotActivity {
  icon : ActivityIcon
  text : String
  sub : String
  time : String
}

///|
/// The Scout message card in the item panel.
pub(all) struct BotMessage {
  name : String
  time : String
  line1 : String
  line2 : String
  reply_chip : String
}

///|
/// A comment added in one Bots chat, keyed so it does not leak into another
/// bot's Home panel.
pub(all) struct BotComment {
  key : String
  text : String
}

///|
/// Item details shown in the right panel.
pub(all) struct BotItem {
  number : String
  title : String
  state : String
  meta : String
  chips : Array[ToolChip]
  done_means : String
  activities : Array[BotActivity]
  message : BotMessage?
}

///|
/// One bot in the fleet.
pub(all) struct Bot {
  id : String
  name : String
  mascot : Mascot
  working : Int32
  subtitle : String
  time : String
  status : AgentStatus
  item_state : String
  sessions : Array[Session]
  item : BotItem?
}

///|
fn session(
  id : String,
  kind : SessionKind,
  label : String,
  time : String,
  status : AgentStatus,
) -> Session {
  { id, kind, label, time, status, }
}

///|
fn tool_chip(text : String, kind : ToolChipKind) -> ToolChip {
  { text, kind, }
}

///|
fn scout_item() -> BotItem {
  {
    number: "#41",
    title: "Pay button ignores first tap on Safari",
    state: "In progress",
    meta: "Item 41 · Home Chat · 9:02 AM",
    chips: [
      tool_chip("Fix Safari Pay tap follow-up", Amber),
      tool_chip("WebKit repro test", Green),
      tool_chip("acme/web#1287", Link),
    ],
    done_means: "The first tap on Pay works in Safari, and the fix is live.",
    activities: [
      {
        icon: AddActivity,
        text: "Scout added this item",
        sub: "",
        time: "9:02 AM",
      },
      {
        icon: PlayActivity,
        text: "Worker started: Fix Safari Pay tap",
        sub: "",
        time: "9:03 AM",
      },
      {
        icon: CheckActivity,
        text: "Worker finished: WebKit repro test",
        sub: "Repro fails before the fix, passes after",
        time: "9:06 AM",
      },
      {
        icon: LinkActivity,
        text: "Scout linked acme/web#1287",
        sub: "",
        time: "9:08 AM",
      },
    ],
    message: Some({
      name: "Scout",
      time: "9:09 AM",
      line1: "The fix is ready in acme/web#1287.",
      line2: "Ship it to everyone, or behind the safari_pay_click flag first? →",
      reply_chip: "Behind a flag",
    }),
  }
}

///|
fn ci_watch_item() -> BotItem {
  {
    number: "#42",
    title: "e2e/cart.spec is flaky, not a real regression",
    state: "Waiting on you",
    meta: "Item 42 · CI Watch · 8:40 AM",
    chips: [tool_chip("Investigate flake", Amber), tool_chip("Rerun CI", Green)],
    done_means: "Three clean runs in a row, with the flake root cause documented.",
    activities: [
      {
        icon: AddActivity,
        text: "CI Watch added this item",
        sub: "",
        time: "8:40 AM",
      },
      {
        icon: PlayActivity,
        text: "Worker started: Rerun cart.spec",
        sub: "",
        time: "8:42 AM",
      },
      {
        icon: CheckActivity,
        text: "Worker finished: Rerun cart.spec",
        sub: "Same failure twice on webkit",
        time: "8:51 AM",
      },
    ],
    message: Some({
      name: "CI Watch",
      time: "8:53 AM",
      line1: "The cart spec fails on webkit only, about one in five runs.",
      line2: "Want me to quarantine it while I find the race?",
      reply_chip: "Quarantine",
    }),
  }
}

///|
fn generic_item(
  number : String,
  title : String,
  state : String,
  meta : String,
) -> BotItem {
  {
    number,
    title,
    state,
    meta,
    chips: [tool_chip("Follow up", Neutral)],
    done_means: "The bot reports back with a clear next step.",
    activities: [
      {
        icon: AddActivity,
        text: "Bot added this item",
        sub: "",
        time: "Today",
      },
    ],
    message: None,
  }
}

///|
fn review_buddy_item() -> BotItem {
  generic_item(
    "#38", "Review acme/web#1281 before the release cut", "2 working", "Item 38 · Review buddy · 7:15 AM",
  )
}

///|
fn release_notes_item() -> BotItem {
  generic_item(
    "#39", "Draft release notes for 4.12", "Posting to #eng", "Item 39 · Release notes · 6:02 AM",
  )
}

///|
fn standup_item() -> BotItem {
  generic_item(
    "#40", "Post today's standup", "Done", "Item 40 · Standup · 9:00 AM",
  )
}

///|
fn docs_helper_item() -> BotItem {
  generic_item(
    "#37", "Open docs issue for the new billing flow", "Done", "Item 37 · Docs helper · Yesterday",
  )
}

///|
/// The phase-2 bot fleet, matching the reference sidebar.
pub fn bots_seed() -> Array[Bot] {
  [
    {
      id: "scout",
      name: "Scout",
      mascot: Scout,
      working: 3,
      subtitle: "3 working",
      time: "",
      status: Running,
      item_state: "",
      sessions: [
        session("home-chat", Home, "Home Chat", "now", Done),
        session(
          "safari-pay-click",
          ClaudeSession,
          "safari-pay-click",
          "6m",
          Running,
        ),
        session(
          "webkit-repro-test",
          CodexSession,
          "webkit-repro-test",
          "2m 41s",
          Done,
        ),
        session(
          "eng-checkout",
          Slack,
          "#eng · checkout on Safari?",
          "18m",
          Idle,
        ),
      ],
      item: Some(scout_item()),
    },
    {
      id: "ci-watch",
      name: "CI Watch",
      mascot: CIWatch,
      working: 0,
      subtitle: "e2e/cart.spec is flaky, not a re…",
      time: "2h",
      status: Idle,
      item_state: "",
      sessions: [
        session("ci-watch-home", Home, "Home Chat", "now", Idle),
        session(
          "ci-watch-cart-triage",
          ClaudeSession,
          "e2e-cart-triage",
          "12m",
          Running,
        ),
        session(
          "ci-watch-retry-probe",
          CodexSession,
          "flaky-retry-probe",
          "34m",
          Done,
        ),
        session("ci-watch-eng", Slack, "#eng · e2e/cart flake", "1h", Idle),
      ],
      item: Some(ci_watch_item()),
    },
    {
      id: "review-buddy",
      name: "Review buddy",
      mascot: ReviewBuddy,
      working: 2,
      subtitle: "2 working",
      time: "",
      status: Running,
      item_state: "",
      sessions: [
        session("review-buddy-home", Home, "Home Chat", "now", Idle),
        session(
          "review-buddy-web-1281",
          ClaudeSession,
          "review-web-1281",
          "8m",
          Running,
        ),
        session(
          "review-buddy-release-cut",
          CodexSession,
          "release-cut-check",
          "20m",
          Done,
        ),
        session("review-buddy-eng", Slack, "#eng · release cut", "40m", Idle),
      ],
      item: Some(review_buddy_item()),
    },
    {
      id: "release-notes",
      name: "Release notes",
      mascot: ReleaseNotes,
      working: 0,
      subtitle: "Notes for 4.12 are in #eng.",
      time: "1d",
      status: Done,
      item_state: "",
      sessions: [
        session("release-notes-home", Home, "Home Chat", "1d", Done),
        session(
          "release-notes-draft",
          ClaudeSession,
          "release-4.12-notes",
          "1d",
          Done,
        ),
        session("release-notes-eng", Slack, "#eng · 4.12 notes", "1d", Idle),
      ],
      item: Some(release_notes_item()),
    },
    {
      id: "standup",
      name: "Standup",
      mascot: Standup,
      working: 0,
      subtitle: "Posted today's standup to #en…",
      time: "5h",
      status: Done,
      item_state: "",
      sessions: [
        session("standup-home", Home, "Home Chat", "5h", Done),
        session("standup-draft", CodexSession, "standup-draft", "5h", Done),
        session("standup-eng", Slack, "#eng · daily standup", "5h", Idle),
      ],
      item: Some(standup_item()),
    },
    {
      id: "docs-helper",
      name: "Docs helper",
      mascot: DocsHelper,
      working: 0,
      subtitle: "Opened acme/docs#212 for th…",
      time: "3d",
      status: Done,
      item_state: "",
      sessions: [
        session("docs-helper-home", Home, "Home Chat", "3d", Done),
        session(
          "docs-helper-billing",
          ClaudeSession,
          "billing-docs-issue",
          "3d",
          Done,
        ),
        session("docs-helper-slack", Slack, "#docs · billing flow", "3d", Idle),
      ],
      item: Some(docs_helper_item()),
    },
  ]
}

///|
/// Look up a bot by id.
pub fn find_bot(model : Model, id : String) -> Bot? {
  for bot in model.bots {
    if bot.id == id {
      return Some(bot)
    }
  }
  None
}

///|
pub fn has_bot(model : Model, id : String) -> Bool {
  match find_bot(model, id) {
    Some(_) => true
    None => false
  }
}

///|
/// The bot that owns a session id.
pub fn find_session_bot(model : Model, session_id : String) -> Bot? {
  for bot in model.bots {
    for item in bot.sessions {
      if item.id == session_id {
        return Some(bot)
      }
    }
  }
  None
}

///|
/// The active bot record.
pub fn active_bot_of(model : Model) -> Bot? {
  find_bot(model, model.active_bot)
}

///|
/// The state shown in the Home status row: the user's override when one was
/// chosen from the status menu, otherwise the item's own seeded state.
pub fn bot_item_state(bot : Bot) -> String {
  if bot.item_state != "" {
    bot.item_state
  } else {
    match bot.item {
      Some(item) => item.state
      None => ""
    }
  }
}

///|
/// States offered by the Home status menu.
pub fn bot_item_states() -> Array[String] {
  ["In progress", "Waiting on you", "Done"]
}

///|
/// Build the Home item that starts when a bot receives its first message.
pub fn bot_item_from_message(bot : Bot, seq : Int32, text : String) -> BotItem {
  let title = truncate_chars(text, 38)
  {
    number: "#\{seq}",
    title,
    state: "In progress",
    meta: "Item \{seq} · Home Chat · now",
    chips: [tool_chip("Follow up", Amber), tool_chip("Home Chat", Neutral)],
    done_means: "The task is finished and \{bot.name} reports the result in Home Chat.",
    activities: [
      {
        icon: AddActivity,
        text: "\{bot.name} added this item",
        sub: "",
        time: "now",
      },
      {
        icon: PlayActivity,
        text: "Worker started: \{title}",
        sub: "",
        time: "now",
      },
    ],
    message: None,
  }
}

///|
/// The six reference bots have hand-authored transcripts; bots created from
/// the fleet `+` button should only show their own messages.
pub fn bot_has_seed_transcript(bot : Bot) -> Bool {
  match bot.id {
    "scout"
    | "ci-watch"
    | "review-buddy"
    | "release-notes"
    | "standup"
    | "docs-helper" => true
    _ => false
  }
}

///|
/// Bots whose Home item is waiting on the owner. This drives the Bots nav
/// badge, so a status-menu pick immediately changes the count.
pub fn bots_needing_you(model : Model) -> Int32 {
  let mut count = 0
  for bot in model.bots {
    if bot_item_state(bot) == "Waiting on you" {
      count = count + 1
    }
  }
  count
}

///|
/// Badge copy for the needs-you count. Zero hides the badge.
pub fn bots_needs_label(count : Int32) -> String {
  if count <= 0 {
    ""
  } else if count == 1 {
    "1 needs you"
  } else {
    "\{count} need you"
  }
}

///|
/// Bots that survive the fleet filter, in fleet order.
pub fn filtered_bots(model : Model) -> Array[Bot] {
  let out : Array[Bot] = []
  for bot in model.bots {
    if bot_matches(bot, model.bot_query) {
      out.push(bot)
    }
  }
  out
}
