# Phase 2 — Orca "Bots" screen (three-pane)

Reference: `design/reference-bots.png` (owner-supplied, authoritative).

After phase 1 (Projects/worktree chat) is green, add a **Bots** screen reachable from the
sidebar "Bots" nav item (and as `scenes/bots` for a screenshot). Same palette and typography as
phase 1.

## Layout (logical 1280×752)

- app background `#151515`; sidebar `#2a2a2a` width 272 (draggable 220–380); right panel
  `#151515` width 400 (draggable 320–480);
  center flexible. All separators `rgba(255,255,255,0.07)` 1px.
- bottom status bar 24 high across the full width, bg `#101010`, border-top `rgba(255,255,255,0.10)`;
  left: amber spark glyph + 4-high track (76 wide, white/35) filled ~38% + `38%`, then Codex-mint
  glyph + track ~12% + `12%`; right `maya-mbp   2 hosts`, 11px `#929292`.
- title bar 36 high spans the **whole window**: traffic lights #ff5f57/#ffbd2e/#28c840 12px,
  "Orca" 12 semibold at the left of the sidebar column, panel-left toggle right of the wordmark.
  In the center pane the 36-high tab strip starts directly with the active bot tab (no history
  arrows — those live in the Projects tab strip), then `#eng` and the `+`; tab strip bg `#171717`.

## Sidebar

- nav rows 32 high, 13px/medium, icons 16: `Search` (selected, bg white/5), `Tasks`,
  `Automations`.
- `Bots` section header 32 high: chevron, label 12 semibold `#acacac`/80, right icons search,
  sliders-horizontal, plus. The chevron collapses the fleet, search reveals an inline
  "Filter bots" field, sliders toggles a Show sessions switch, and plus appends a new bot
  (Relay / Relay 2) and selects it. Other bot cards are 48 high with 2 bottom padding, so
  fleet rows sit 50 logical px apart as in the reference.
- Selected bot header card: margin 4, padding 5, radius 10, border white/24, bg white/10.
  mascot 36×36 rounded 6 (use a simple colored avatar drawn with canvas: light-gray orb/blob
  face; or the provided `design/mascot-B1.webp` if image loading works), orange status dot 4px
  at bottom-right on `#2a2a2a` ring.
  Title `Scout` 13 semibold `#f0f0f0`; subtitle `3 working` 12 `#acacac`; right: 9px amber
  spinner ring + `3` 12 tabular + ellipsis icon.
  The reference highlights only this 46 px header; the nested session rows below sit on the
  sidebar background rather than inside the bordered card.
- Nested rows (indent 21, 24 high, 12px):
  - `Home Chat` 2m — bot glyph; right `2m`
  - `safari-pay-click` 6m — amber ring; model glyph (Claude); `6m` 11 `#acacac`/70
  - `webkit-repro-test` 2m 41s — green check circle; Codex glyph
  - `#eng · checkout on Safari?` 18m — Slack icon
- Other bot cards 52 high: mascot 36, title 13 semibold, subtitle 12 `#acacac` truncated,
  right time + chevron. Rows: `CI Watch` / "e2e/cart.spec is flaky, not a re…" / 2h;
  `Review buddy` / "2 working" (orange spinner count 2) / —; `Release notes` / "Notes for 4.12
  are in #eng." / 1d; `Standup` / "Posted today's standup to #en…" / 5h; `Docs helper` /
  "Opened acme/docs#212 for th…" / 3d.
- bottom of sidebar: `Projects` disclosure row with icons; settings/help/bottom-left chevrons;
  profile avatar 28 circle on far right with a small plus badge.

## Center — Scout chat

- tab strip 36 bg `#171717`: active tab `Scout` (mascot 16 + text 13), second tab
  `#eng · checkout on Safari?` (Slack icon) both with close X, then plus. Active tab bg
  `#151515`, border-right, max width 300.
- transcript max width 560, center, padding 16, 14/22 `#c0c0c0`, blocks gap 16:
  1. paragraph, muted `#8f8f8f`: “New bug from support: the Pay button does nothing on the first
     tap in Safari. 14 reports since yesterday’s deploy, all Safari 18 on iOS and macOS. I
     reproduced it on WebKit, so it’s ours, not the payment provider.”
  2. tool rows (29 high, icon 14 `#929292`, text 13 `#c0c0c0`, inline chip 12 bg white/6
     radius 4 text `#eab308`/`#f0f0f0` where shown):
     - list icon `Added and moved` + chip `Pay button ignores first tap on Safari` + `to In progress`
     - Claude glyph `Started safari-pay-click`
     - Codex glyph `Started webkit-repro-test`
  3. `Worked for 6m 12s ›` row 12 `#929292` with bottom border.
  4. paragraph: “Found it. `PayButton` starts the payment on `pointerdown`, and Safari drops that
     event while the sticky cart footer overlaps the button. The fix listens for `click` instead.
     WebKit tests pass, 38 of 38, and the new repro test fails without it.” (code spans 12 mono,
     bg white/6, radius 4, padding x4)
  5. tool rows: `Linked` chip `acme/web#1287` + `to` + chip `Pay button ignores first tap on
     Safari`; `Added` + chip `Sticky cart footer covers Pay on small s…`; `Asked you about` +
     chip (status dot amber) `Pay button ignores first tap on Safari`.
  6. right-aligned user bubble (bg #252525, radius 14, padding 14/10, max 80%): first line
     `Pay button ignores first tap on Safari` (status dot amber), second line `Behind a flag`.
  7. paragraph: “Shipping it behind `safari_pay_click`. I’ll merge acme/web#1287 and turn the
     flag on for Safari once the deploy is out.”
  8. tool row Claude glyph `Sent follow-up to safari-pay-click`.
- composer: width ~575 (16 inset each side), bg `#1b1b1b`, border white/9, radius 14;
  placeholder 15 `Ask anything, @ to mention bots or files, / for commands`, left +,
  right `Claude Opus 5.5 Med ⌄` 14 `#c0c0c0`, mic, 32 circle send (`#3d3d3d` bg, white arrow-up).
- under composer (outside the box) status text 11 `#929292`: `Maya’s MacBook Pro   Scout · Folder`.

## Right — item panel

- top bar 36 bg `#171717`, tabs: `Home` (icon, selected), `Connectors`, `Chats`, `Files`,
  right panel-left icon. 13 `#acacac`, selected `#f0f0f0`.
- content padding 16:
  - back row `‹ Home` + mascot 16 + `Scout` 13.
  - title `#41 Pay button ignores first tap on Safari` 20 semibold `#f0f0f0`.
  - status row: amber spinner + `In progress` + chevron (13 `#eab308`), then `Item 41 · Home Chat
    · 9:02 AM` 12 `#929292`.
  - chips row: `Fix Safari Pay tap follow-up` (amber spinner, border white/8, bg white/4),
    `WebKit repro test` (green check), `acme/web#1287` (git-branch icon, text `#acacac`).
  - `Chat` label + `Home Chat ↗` link; `Done means` label + body 13 `#c0c0c0`: “The first tap on
    Pay works in Safari, and the fix is live.”
  - `Activity` label; rows 28 high, 12px: icon (plus / play / check / link / comment) `#929292`,
    text `#c0c0c0`, right time `#929292`:
    `Scout added this item` 9:02 AM; `Worker started: Fix Safari Pay tap` 9:03 AM;
    `Worker finished: WebKit repro test` 9:06 AM (sub-line “Repro fails before the fix, passes
    after”); `Scout linked acme/web#1287` 9:08 AM.
  - message card from Scout 9:09 AM (bg #171717, border white/7, radius 12): avatar 24, name 13
    white, body 13 `#dadada`: “The fix is ready in acme/web#1287.” / “Ship it to everyone, or
    behind the safari_pay_click flag first?” → `Behind a flag` (chip).
  - bottom comment composer: rounded 12, bg white/4, border white/9, placeholder “Add a
    comment…”, right mic + circular send.

## Interactions (phase 2)

- Sidebar `Bots` nav switches to this screen; `Projects`/`Search` nav back to phase-1 screen.
- Selecting a bot or nested session updates the center tab set and right item (at least Scout,
  Home Chat, CI Watch use plausible distinct content).
- Right-panel tabs Home/Connectors/Chats/Files switch content; Connectors rows expand into a
  description and Connect/Disconnect action; Chats lists the active bot’s sessions.
- The right panel collapses to a 48 px icon rail; the selected tab stays highlighted and
  clicking a rail icon reopens the panel on that tab.
- Sidebar footer icons are live: settings toggles fleet options, help opens the centered
  keyboard-shortcuts overlay, and the clock icon selects Chats.
- `Add a comment…` submit appends a comment to the right activity; `Behind a flag` chip can toggle
  selected state.
- The Home status row opens an inline In progress / Waiting on you / Done menu; the
  current state is checked, picking one updates only that bot, appends a `Status set to …`
  activity row, and persists. `Escape`, another bot, a panel tab or a page switch dismisses it.
- The Bots nav badge is derived from the same effective states: it counts bots waiting on
  you, updates on every pick, and hides at zero.
- Status bar is decorative but must render.

## Screenshot

`scenes/bots` must expose `program()` with Bots screen active; capture at 1280×752 scale 2 as
`docs/screenshots/orca-bots.png` and compare with `design/reference-bots.png`.

## Implementation hints (model + view)

- Add to `Model`: `screen : Screen` (`Projects | Bots`), `bots : Array[Bot]`, `active_bot : String`,
  `panel_tab : Int32` (0 Home / 1 Connectors / 2 Chats / 3 Files), `comment_draft : String`,
  `comments : Array[String]` (appended to Scout's activity), `flag_selected : Bool`.
- `Bot` struct: `id`, `name`, `mascot : Mascot` (enum selecting an avatar palette/face),
  `working : Int32`, `subtitle`, `time`, `sessions : Array[Session]`, `item : BotItem?`.
  `Session`: `kind (Home | Claude | Codex | Slack)`, `label`, `time`, `status`.
  `BotItem`: `number`, `title`, `state_label`, `meta`, `chips`, `done_means`,
  `activities (icon, text, sub, time)`, `message` (name, time, lines, reply_chip)`.
- Messages: `SetScreen(Screen)`, `SelectBot(String)`, `SetPanelTab(Int32)`, `CommentInput(String)`,
  `SendComment`, `ToggleFlag`.
- Sidebar Bots section and the two other bot rows are ordinary `column` children inside the
  existing sidebar `scroll_view`; the selected bot header is a bordered container (white/24,
  white/10 fill), followed by a sibling `column` of sessions indented 21 px.
- Center: reuse the tab strip component but with the mascot as the tab icon; transcript blocks
  can reuse `Block` with two new variants: `ToolRow(ToolRow)` and `SessionToolRow`. Simpler:
  add `Block::Tool(ToolRow)` where `ToolRow { lead, chip?, chip_kind?, trailing?, sub_chip? }`.
  Plain assistant paragraphs use `#c0c0c0` 14/20, first one muted.
- Right panel: a `column` of 400 width by default, top 36 tab bar (`row` with four
  `text_button`s; icons only under 360), a
  `scroll_view` for the item content, then a fixed comment composer at the bottom. Status bar
  spans the window bottom: put it as the last child of the root `column`, outside the panes row.
- Avatars: use `canvas` 36×36 drawing a light rounded square + simple blob face with two eye
  dots and a mouth arc; give each bot a different fill (Scout #cfe3f6, CI Watch #ffd166,
  Review buddy #bfe8d4, Release notes #ecd0bc, Standup #ffffff, Docs helper #d8def0) so the
  fleet still reads like the reference without loading webp assets.
- Keep the status bar meters deterministic (38% / 12%) so screenshots are stable.

## Responsive widths (implemented)

- `bots_pinned_widths(model, width)` clamps the fleet sidebar to ≤30% of the window and the
  item panel to ≤32%, always leaving the center chat at least 300 px. Stored
  `bots_sidebar_w` / `bots_panel_w` remain the user's drag preference, so widening the window
  restores them; the rendered widths are derived per frame.
- At 1280 px the panes keep their defaults (272 + 400); at 960 px the item panel shrinks to
  ~307 px; at 800 px the fleet shrinks to 240 px and the item panel to ~250 px.
- The fleet sidebar now receives its effective width as a parameter instead of reading
  `model.bots_sidebar_w` internally, so its rows and session labels follow the clamp.

## Seeded sessions (implemented)

- Every bot in `bots_seed()` carries 2–3 sessions, so selecting CI Watch, Review buddy,
  Release notes, Standup or Docs helper populates the sidebar session list, the right
  Chats panel and the center transcript instead of showing an empty state.
- `bot_matches` checks session labels as well as name/id/subtitle, so filtering "cart"
  keeps CI Watch even though its name does not contain the query.

## New bot Home Chat (implemented)

- A bot with no item starts with a Home session and a ready-to-start intro. The intro
  and `Waiting for your first message` row disappear as soon as the current chat has a
  message, leaving the user/assistant transcript.
- `bot_chat_key` resolves an empty `active_session` to the bot's first Home session, so
  sending from the default view and then opening Home Chat keeps one transcript.
- The first message creates the bot's first real Home item and switches it to `1 working`.
  The item takes its title from the message (38-character clamp), uses the next `#43`,
  `#44`, … number, and starts with Follow up / Home Chat chips, a Done-means line and
  Add / Worker-started activity. The right panel therefore switches from the
  **Open Home Chat** empty guide to the full item, and the item plus its next number
  survive a restart.
- `bot_has_seed_transcript` limits the hand-authored Scout / CI Watch / Review buddy /
  Release notes / Standup / Docs helper history to those six bots; a newly created bot
  only shows its own user and assistant messages.

## Status menu (implemented)

- `Bot.item_state` stores the owner's override; `bot_item_state(bot)` falls back to the
  seeded `BotItem.state` when it is empty, so existing seed bots keep their reference
  states until the owner picks one.
- `bot_item_states()` returns In progress / Waiting on you / Done. The Home status chip
  renders the effective state and an amber chevron; opening it draws a compact inline
  menu under the status row, with an amber check on the current row and hover feedback.
- `SetBotItemState` updates only the active bot, closes the menu, and appends
  `Status set to …` to that item's `activities` (persisted with the item); Done shows a
  green check in the status row, and repeating the current state does not duplicate the
  row. Bots without an item and unknown states are no-ops.
- `bot_status_menu_open` is transient. Escape, switching bots, panel tabs, pages,
  collapsing the panel, AddBot, fleet movement and back/forward all clear it. Picks
  round-trip through the version 1 JSON (`item_state` and the item's activity history),
  with missing fields falling back to the seed state; older payloads still render the
  current row through the view fallback.
- `bots_needing_you(model)` counts bots whose effective state is Waiting on you;
  `bots_needs_label(count)` returns `1 needs you` / `N need you` and an empty string at
  zero, which hides the nav badge. The Bots standby empty state uses the same count.

## Round 39 selected mascot status dot (implemented)

- `mascot_with_status(mascot, size, color)` overlays a 7 px amber dot inside an 11 px
  `#2a2a2a` ring (2 px padding) at the bottom-right of the selected bot's 36 px mascot,
  matching the reference. Plain `mascot_avatar` remains undecorated for other bot cards,
  session tabs and legends.

## Round 40 footer account avatar (implemented)

- The footer ends with a 28 px neutral circular avatar carrying Maya's `M` initial and a
  10 px plus badge at its bottom-right. The badge has a 1 px border and sits entirely
  inside the avatar frame. It is a static identity mark; the settings, help, history and
  fleet controls keep their existing positions and handlers.

## Round 41 composer dictation demo (implemented)

- The Bots center and comment mics are now real controls in the backend-free replica:
  tapping one appends a fixed sample phrase to that draft (`Summarize the failing
  checkout tests.` / `Please add a regression test.`) and sets a transient
  `dictation_target`. The same handler drives the Projects and Diff composers.
- `dictation_append` inserts one space at the join unless the draft already ends in
  whitespace. Editing, picking a completion, or sending clears the hint; unknown targets
  are no-ops, and the state is not persisted.
- The active mic uses its existing icon footprint (16 px in the Bots footer, 15 px in the
  comment row) as an amber slot with a subtle amber fill, so footer alignment is
  unchanged. The Bots caption gains a right-aligned `Dictated locally` label while the
  main dictation hint is active; it is withheld below a 360 px composer so the device
  line never gets crowded on phone widths.
- `scene_bots_dictation_model()` drives the new `bots-dictation.png` acceptance shot;
  README / SPEC / QA / PHASE3 document the sample phrases and the no-audio behavior.

## Round 42 right-panel geometry (implemented)

- The Bots body no longer subtracts an extra 8 logical px between the three columns.
  With the default 385 px item panel, the right column starts at x=895 logical
  (1790 at 2×) and runs flush to the 2560 px window edge; the 16 px dark gutter is gone
  while the 2 px vertical rule stays at x=1788–1789.
- Home rows use a 12 px left gutter and 16 px total right allowance. Activity icons land
  at x≈1830, labels at x≈1874 and times end at x≈2532; Done means uses a 49-character
  budget at 261 px body width, matching the reference's two-line break.
- `scout_message_card` is now an outline-free 371 px-wide surface at 2× (x=1802–2543)
  with an 8 / 5 px horizontal inset. Its avatar is 20 px, body copy is indented 27.5 px
  to align with the name at x=1874, and `safari_pay_click` is a plain 10 px mono run
  rather than a filled chip. The card bottom lands at y≈1106.
- Six Bots acceptance shots were regenerated (main, status, files, dictation, narrow and
  panel-narrow). A new done-means wrap test brings the native suite to 106/106.

## Round 51 column origin and header geometry (implemented)

- The owner reference includes a ~14 px window frame before the app content and a 16 px
  scrollbar rail at the right edge. Content-relative columns are therefore ~272 px for
  the fleet sidebar and 400 px for the right panel; the Round 25 absolute-x values of
  285 / 385 are superseded.
- Defaults are now 272 + 400. At 1280 the center gets 606 px plus the 2 px seams; at
  960 the panel still clamps to ~307 px and at 700 the chat keeps its 300 px minimum.
- The title bar now starts at the content origin (`Orca` x=71.6 vs 71.4 in the
  reference). The Bots section header uses a 16 px chevron + 4 px gap with 5 / 8 px
  outer insets, putting `Bots` at x≈22.6 while keeping the right action cluster fixed.
- The comment composer’s plus/field group uses a 3 px gap and 5.5 px left inset:
  the plus and `Add a comment…` match the reference within 3 px and the mic/send stay
  on the right. Eight Bots acceptance shots were regenerated.

## Round 52 center-tab icons, baseline and session label fit (implemented)

- The active center tab now carries the reference's 2 px `#f0f0f0` baseline across its
  full 143 px Home-tab width. An earlier read that the reference omitted the underline
  was wrong; the baseline sits at the bottom of the 36 px strip without changing tab
  height or hit target.
- The bot tab draws a 12 px mascot after a 3 px gap, and prepends an 8 px amber spinner
  while the bot's `working` count is positive. Pixels land within ~1 px of the reference
  (spinner left 280 vs 278.5 logical after frame alignment; Scout text 306 vs 305).
- The `#eng` tab uses a local hash SVG because `hash` is absent from MoUI's vendored
  Lucide subset. The same audit replaced invisible `plug` / `unplug` glyphs in connector
  actions and the Tasks worktree unlink row with explicit SVG paths.
- Session rows use `session_row_label_width(width) = width - 107` and a matching
  character cap. At 272 px the label column is 165 px / 26 characters, so the reference
  phrase fits; timestamps remain flush inside the selected row.

## Round 60 phone-width item drawer (implemented)

- `compact_panel_width` now keeps the drawer at the panel's 320 px minimum: 320 and
  360 px viewports fill the window, 384 px returns the 64 px chat peek, 400 px gives
  336 px and 480 px keeps the stored 400 px (416 px when capped). The old 256 px phone
  panel left a scrimmed chat sliver and shortened Home copy.
- The compact icon tabs, single-column cards, wrapped title and full-width Done means
  remain. `bots-panel-phone.png` (320×600 → 640×1200) is the new phone acceptance shot;
  `bots-panel-narrow.png` at 480×600 regenerates byte-identically.

## Round 62 Files row gutter (implemented)

- Files and Chats rows now share `panel_row_inner_width(width) = width - 40`, the
  `width - 24` body minus the row container's 8 px side padding. The file text column is
  `panel_row_inner_width(width) - 71`, accounting for the 28 px icon, 13 px chevron and
  three 10 px gaps.
- The previous Files row overflowed that inner width by 8 px, leaving the chevron flush
  with the container edge. `bots-files.png` regenerates with the chevron 8 logical px
  farther left while the path and metadata OCR positions stay unchanged.
