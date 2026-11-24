# Phase 2 — Orca "Bots" screen (three-pane)

Reference: `design/reference-bots.png` (owner-supplied, authoritative).

After phase 1 (Projects/worktree chat) is green, add a **Bots** screen reachable from the
sidebar "Bots" nav item (and as `scenes/bots` for a screenshot). Same palette and typography as
phase 1.

## Layout (logical 1280×752)

- app background `#151515`; sidebar `#2a2a2a` width 272; right panel `#151515` width 380;
  center flexible. All separators `rgba(255,255,255,0.07)` 1px.
- bottom status bar 24 high across the full width, bg `#101010`, border-top `rgba(255,255,255,0.10)`;
  left: amber spark glyph + 4-high track (76 wide, white/35) filled ~38% + `38%`, then Codex-mint
  glyph + track ~12% + `12%`; right `maya-mbp   2 hosts`, 11px `#929292`.
- title bar 36 high spans the **whole window**: traffic lights #ff5f57/#ffbd2e/#28c840 12px,
  "Orca" 12 semibold centered over the sidebar column, panel-left toggle right of the wordmark.
  In the center pane the 36-high tab strip starts with `←  →` undo/redo icon buttons at its far
  left, then the tabs; tab strip bg `#171717`.

## Sidebar

- nav rows 32 high, 13px/medium, icons 16: `Search` (selected, bg white/5), `Tasks`,
  `Automations`.
- `Bots` section header 32 high: chevron, label 12 semibold `#acacac`/80, right icons search,
  sliders-horizontal, plus.
- Selected bot card: margin 4, padding 5, radius 10, border white/24, bg white/10.
  mascot 36×36 rounded 6 (use a simple colored avatar drawn with canvas: light-gray orb/blob
  face; or the provided `design/mascot-B1.webp` if image loading works), orange status dot 4px
  at bottom-right on `#2a2a2a` ring.
  Title `Scout` 13 semibold `#f0f0f0`; subtitle `3 working` 12 `#acacac`; right: 9px amber
  spinner ring + `3` 12 tabular + ellipsis icon.
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
- transcript max width 560, center, padding 16, 14/20 `#c0c0c0`, blocks gap 16:
  1. paragraph, muted `#8f8f8f`: “New bug from support: the Pay button does nothing on the first
     tap in Safari. 14 reports since yesterday’s deploy, all Safari 18 on iOS and macOS. I
     reproduced it on WebKit, so it’s ours, not the payment provider.”
  2. tool rows (24 high, icon 14 `#929292`, text 13 `#c0c0c0`, inline chip 12 bg white/6
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
- Right-panel tabs Home/Connectors/Chats/Files switch simple content (Connectors: Slack, Linear,
  GitHub, Gmail list; Chats/Files can show empty states).
- `Add a comment…` submit appends a comment to the right activity; `Behind a flag` chip can toggle
  selected state.
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
  existing sidebar `scroll_view`; the selected bot card is a bordered container (white/24,
  white/10 fill) with a nested `column` for sessions (indent 21).
- Center: reuse the tab strip component but with the mascot as the tab icon; transcript blocks
  can reuse `Block` with two new variants: `ToolRow(ToolRow)` and `SessionToolRow`. Simpler:
  add `Block::Tool(ToolRow)` where `ToolRow { lead, chip?, chip_kind?, trailing?, sub_chip? }`.
  Plain assistant paragraphs use `#c0c0c0` 14/20, first one muted.
- Right panel: a `column` of 380 width, top 36 tab bar (`row` with four `text_button`s), a
  `scroll_view` for the item content, then a fixed comment composer at the bottom. Status bar
  spans the window bottom: put it as the last child of the root `column`, outside the panes row.
- Avatars: use `canvas` 36×36 drawing a light rounded square + simple blob face with two eye
  dots and a mouth arc; give each bot a different fill (Scout #cfe3f6, CI Watch #ffd166,
  Review buddy #bfe8d4, Release notes #ecd0bc, Standup #ffffff, Docs helper #d8def0) so the
  fleet still reads like the reference without loading webp assets.
- Keep the status bar meters deterministic (38% / 12%) so screenshots are stable.
