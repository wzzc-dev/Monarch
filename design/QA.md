# Acceptance checklist (reviewer use)

Build/run (always):
```sh
export PATH="/home/chuang/bin:$HOME/.moon/bin:$PATH"
export MOUI_SKIA_ENABLE_GPU_VULKAN=0
cd /home/chuang/Code/orca-moui
moon check --target native
moon test app --target native
moon build linux_skia --target native
```

Phase 1 screenshot comparison vs `design/reference-orchestration.jpg`:
- [ ] window 1280×752; sidebar exactly 340 wide, `#2a2a2a`; main `#151515`
- [ ] one merged 36px top row: traffic lights, "Orca" wordmark and panel toggle over the
      340px sidebar; 1px vrule; then the tab strip with one active tab (Claude icon + title
      + X) and `+`; active tab `#151515`, strip `#171717`
- [ ] sidebar nav Search/Tasks/Automations; Projects header with 3 icon buttons; two machine
      cards (Local Mac 1; mac-mini mac-mini.local 3); acme-web globe + acme-internal folder
- [ ] worktrees: checkout-flow-v2 (primary/branch/2 agents), eu-promo-checkout **selected**
      (border white/24 + bg #404040, 3 agents), handoff summary, checks-detail-link
- [ ] agent rows show vendor icon, name, model, time, amber running spinner; right-aligned
      times that end flush at a 12 px right inset (~x316 at a 340 px sidebar); rows are 28
      high with a 5 px gap (33 px pitch, matching the reference) and span the same 316 px
      width as their worktree card; the header, branch and agent sections are 10 px apart;
      as the sidebar nears its 220 px minimum the name clips harder and the model token
      drops out
- [ ] chat column max 736 (Orca's 46rem default) centered; user bubble right #252525 radius 14;
      "Worked for 12s" row; assistant paragraph; two worker cards (#171717 radius 14, one
      focused ring); closing paragraph; no trailing live row in the finished transcript
- [ ] composer shares the 736 measure, bg #1d1d1d, border white/9, radius 14; ~117 px tall
      with a 23 px gap before the 40 px footer and 22 px above the window edge; 18 px
      placeholder; +, yellow Full access, Opus 5.5, 20 px mic, 40 px light circular send
- [ ] typography: Inter; 13/14 body sizes; branch names in mono 11; muted colors match tokens
- [ ] screenshot has no clipped/overlapping text; paragraphs wrap; icons not missing glyphs

Modal (`scenes/modal`) vs `design/reference-create-worktree.jpg`:
- [ ] full-window dim overlay rgba(0,0,0,0.6); 550-wide dialog #0a0a0a radius 16,
      select/agent/name controls transparent with white/5–12 borders (matches reference)
- [ ] Project/Run on select (click cycles acme-internal/mac-mini ↔ acme-web/Local Mac and
      creation lands in that project); Create From chips seed Smart's default worktree, a
      GitHub `pr/<slug>` branch, a Branch `feature/<slug>` branch, and Name's required typed
      name; name input; Agent select
      (click cycles Claude Code → Codex → Grok and the created worktree records it);
      Advanced (opens a base-branch selector); Create more toggle (its label is clickable
      too); white primary button with a legible dark `⌘↵` hint
- [ ] Advanced expands to a `Base branch` row that cycles main → develop → release/next;
      clicking the row does not collapse Advanced, and the created worktree's setup worker
      names the selected base. At 320×600 / 480×600 the compact row keeps the stacked
      footer inside the viewport
- [ ] rhythm matches the reference: 44-high Project/Run on/Agent controls, 52-high name
      field directly under the chips (no extra label), footer button 188 wide; selecting
      the Name chip with a blank field dims the primary button and shows a name hint
- [ ] field labels/secondary text legible; no stock Material blue anywhere

Bots (`scenes/bots`) vs `design/reference-bots.png`:
- [ ] default 272 px sidebar with Bots section (Scout selected + nested sessions), other
      bots, Projects row; a 1 px divider with a 9 px transparent drag hit area resizes
      220–380 px, and session labels
      ellipsize instead of clipping into the timestamp
- [ ] sidebar rhythm matches the reference: Search 62, Tasks 97, Automations 130, Bots header 173
      (logical px from window top); nested session rows follow without drifting
- [ ] other bot cards sit 50 logical px apart (Watch 366, Review 416, Release 466, Standup 516,
      Docs 566 logical from window top)
- [ ] Bots header controls are real: chevron collapses the fleet, search filters by name and
      summary, sliders toggles Show sessions, plus adds and selects a new bot; Projects
      disclosure sliders opens Projects with its options panel, folder-plus/plus open Create
- [ ] the selected bot card’s `more` icon opens the fleet options panel
- [ ] the selected bot’s mascot carries the reference’s 7 px amber status dot with a
      `#2a2a2a` ring at its bottom-right corner
- [ ] the sidebar footer settings icon opens fleet options, help opens the centered
      keyboard-shortcuts card (Esc / scrim closes it) and the clock icon selects Chats
- [ ] the center tab shows the selected bot's avatar/name (CI Watch shows no `#eng` tab) and
      Escape closes the Bots filter or display-options panel
- [ ] Bots center-tab X closes that tab; closing Scout falls back to `#eng`, closing both
      shows “No chat open”, and selecting a bot/session from the sidebar reopens the chat
- [ ] center Scout chat with tab `Scout`, context paragraphs, tool rows, working row, user bubble,
      composer, footer breadcrumb
- [ ] right item panel 400 wide by default, dragging 320–480 px via a 1 px rule + 9 px hit
      area; under 360 px its tabs
      collapse to icons: Home tab bar, #41 title, status row, chips, Done means, Activity,
      Scout message card, comment composer
- [ ] the Home status row opens an In progress / Waiting on you / Done menu; the current
      state is checked, picking one updates only the active bot, appends a Status set
      activity row, closes the menu and survives a restart; Escape and bot/tab/page
      switches close it without changing state
- [ ] the Bots nav badge counts bots whose item says Waiting on you, updates with each
      status pick, hides at zero, and uses 1 needs you / N need you copy
- [ ] Connectors / Chats / Files panel tabs switch; Chats lists the active bot’s sessions and
      opens one on click; Files lists indexed files and a row opens the owning worktree;
      Connectors expands a row into its description + Connect / Disconnect and updates the
      connected count
- [ ] the right panel’s panel button collapses it to a 48 px rail with Home / Connectors /
      Chats / Files icons; the selected icon stays highlighted and clicking one reopens the
      panel on that tab
- [ ] bottom status bar CPU/GPU + host

Interactions:
- [ ] select worktree switches tab/transcript; `+` opens modal; create worktree adds + selects
- [ ] close tab falls back; send appends user + assistant and clears draft; worked row toggles
- [ ] clicking a worker card moves the focused white ring; clicking it again clears the ring
- [ ] sending with no open Projects tab keeps the draft instead of clearing it
- [ ] Bots center composer send appends to the active chat; tab-strip `+` opens Create worktree
- [ ] nav Bots opens Bots screen; backend target web builds

Deliverables:
- [ ] README with screenshots, feature mapping, run instructions
- [ ] docs/screenshots/orca.png, orca-create-worktree.png, orca-bots.png
- [ ] item 1 updated with results

## Phase 3 — Search / Tasks / Automations / Diff

Screenshots (logical 1280×752, scale 2, dark): `docs/screenshots/search.png`,
`search-files.png`, `tasks.png`, `automations.png`, `diff.png`; refresh `orca.png`,
`orca-bots.png`, `orca-create-worktree.png` after visual fixes.

Layout (all four pages):
- [ ] same window shell as Projects (sidebar 340, merged title/tab row 36, 1px vrules);
      page header with 20/600 title, 13 muted subtitle, actions on the right
- [ ] rows/cards use the shared tokens (`#171717` cards, white/7 borders, radius 10–12, 11–13
      type scale); no full-width pill backgrounds behind table column labels
- [ ] no clipped text, no missing glyphs, no text overlapping its container edges
- [ ] selected row uses white/5–6 fill + white/12 border; every visible control that implies an
      action is wired (no `Noop` on buttons, chips, toggles or rows)

Search (`scenes/search`):
- [ ] search field with leading glyph, `esc` hint, result count, category pills
      All / Worktrees / Bots / Sessions / Files, grouped results with section labels
- [ ] typing filters live; picking a category narrows to that group and updates the count;
      suggestion chips (`checkout`, `Safari`, `acme-internal`) fill the query;
      `esc` (or clear) empties the query; the first result is selected by default, ↑/↓ move
      the selection (with the `↵` hint on that row), and `↵` opens it; empty state shows
      “No matches”
- [ ] clicking a result opens the worktree or bot it points to; a Files hit opens the
      worktree that owns the file, and file hits match indexed code keywords or summaries
      (not just the path) with the summary shown in the row
- [ ] a leading `@` narrows the search to files and selects the Files pill automatically;
      backspacing the `@` restores the previous category

Tasks (`scenes/tasks`):
- [ ] two-pane: list (grouped Needs you / In progress / Done) + 358 detail pane
- [ ] status pills All / Assigned to me / Needs you / Done filter the list; “Assigned to
      me” matches the seeded `you` assignees (not the agent); group counts are computed
      from the filtered set; GitHub / Linear / Slack source pills filter too
- [ ] selecting a row updates the detail pane; “Mark done” moves the task to Done and
      “Reopen” moves a Done task back to Needs you; the search box narrows the queue by
      title/repo/labels/description/worktree and the detail pane falls back to the first match;
      “New task” opens an inline title field whose source and agent pickers cycle
      GitHub/Linear/Slack and Claude Code/Codex/Grok, then adds and selects the task
- [ ] when a filter hides the previously selected task, both the detail pane and the visible
      highlight clamp to the first match; the linked-worktree card shows the real branch and a
      Done task shows `finished` rather than a running spinner; the Description pencil opens a
      multiline editor where Save / `⌘↵` commits and Cancel / `Escape` restores the old copy;
      Activity rows derive from the task's source, assignee, worktree link and agent/status,
      and the link card plus Save/Cancel/Back/Open/Mark done buttons show a hover state

Automations (`scenes/automations`):
- [ ] metric cards + table with columns name / schedule / last run / status
- [ ] per-row enable toggle flips state and restyles the row; header “Run now” updates the
      selected automation’s last run and status; the selected row’s Edit / Run now / Delete
      bar works; “New automation” opens the editor dialog (name / schedule / project, ⌘↵ saves);
      Edit reopens it prefilled; Delete removes the row; Recent runs View all expands to six
- [ ] Runs today / Passed / Needs attention are live, persisted counters: Run now
      increments the first two, the success rate is computed from them, and the yesterday
      delta renders ↑ N / No change / ↓ N from the persisted today/yesterday counters
- [ ] editing a seeded automation preserves its schedule instead of resetting to Manual;
      clicking a Recent run row selects its owning automation
- [ ] table header labels are plain text (no full-column pill background)

Diff (`scenes/diff`):
- [ ] 50/50 split; code rows 24 high with mono 18 and a 23 px marker gutter; the inline
      note card starts at x≈88 with width 360 under line 27
- [ ] three file tabs in the diff strip; clicking a tab switches the right pane, toolbar path
      and the active tab
- [ ] a file tab's X closes it, keeps at least one tab open and moves the active file when
      the closed tab was showing
- [ ] line rows: +/− markers, line numbers, add/remove backgrounds, selected line border
- [ ] the toolbar split/columns button toggles focus mode (diff fills the window, chat pane
      hidden) and Escape restores the 50/50 split
- [ ] ↑/↓ move the selected line within the active file; `Escape` closes an open note card
- [ ] inline comment: selecting a line + “add note” attaches a note to that line; switching
      lines shows that line’s thread only; AI notes count reflects notes; Shift+↑/↓ grows the
      selection into a range and the card reads `Note lines 24–28`
- [ ] the note card’s send resends the note, pencil loads it into the composer for an
      in-place edit (re-sending replaces rather than duplicates), x deletes the note
- [ ] the diff composer’s Full access chip cycles Full access / Ask before edits /
      Read only and its model chip cycles Opus 5.5 / GPT-6 Astra / Grok 4
- [ ] context-card Approve / Request changes appear once the run stops and update the
      verdict banner; the card keeps only File/Line/comment rows while `Working for 7s`
- [ ] the note card opens inline under the selected row; closing it collapses the gap
- [ ] the code area scrolls when the note card makes the file taller than the pane, and
      below 720 px the stacked diff keeps the seeded note card whole
- [ ] tab-strip `+` opens a fourth `handoff.md` diff tab and selects it

Interactions (all screens):
- [ ] sidebar Search / Tasks / Automations / Bots / Projects switches screens and keeps the
      selected nav state
- [ ] title-bar panel button collapses/restores the sidebar; `⌘K` opens Search, `⌘↵`
      submits Create worktree, `⌘W` closes the active Projects tab, `⌘P` returns to
      Projects, `⌘B` shows/hides the sidebar, `⌘1`–`⌘9` switch open worktree tabs, and
      `Escape` closes the modal / clears search / closes a diff note / dismisses the
      new-task composer / cancels a task description edit
- [ ] the tab-strip ←/→ arrows and `⌘[` / `⌘]` walk screen, worktree and bot navigation
      history; disabled arrows dim, and a new navigation clears the forward stack
- [ ] dragging the divider beside the Projects or Bots sidebar resizes it between 220 and
      380 px; dragging the divider left of the Bots item panel resizes it between 320 and
      480 px, with icon-only tabs under 360 px and a column-resize cursor on all three
- [ ] shrinking the window re-clamps the Bots fleet and item panel so the center chat keeps
      at least 300 px; widening restores the stored drag widths, and Tasks/Automations
      tables stay inside the page at 960 and 800 px widths
- [ ] below 760 px the Bots title bar drops the wordmark and the center strip sheds the
      `#eng` tab before overflow (it has no history arrows, unlike the Projects strip);
      at 320 px the bot label clips inside its tab while the close X, `+` and right rail
      remain separate and tappable
- [ ] when the Bots item panel is a drawer below 360 px, the item title wraps to two
      lines while activity labels clip inside the panel, chips stack one per row, Done
      means wraps, and below
      400 px the status bar drops the second meter so host labels stay inside the window
- [ ] below 720 px the shell drawer keeps the main tab strip usable: at 320 px the
      worktree tab, its close X and `+` fit without touching the edge; page headers keep
      their action buttons and filter pills use short labels
- [ ] Search result rows clip long titles within their column at 320–600 px; right-hand
      metadata drops below 300 px and the selected `↵` marker below 420 px, so no row
      overlaps its neighbour or the page edge
- [ ] Automations swaps to stacked rows below 560 px: table headers and schedule columns
      disappear, Edit / Run now / Delete stay tappable, and metric cards plus list cards
      keep 32 px side gutters at 320 px
- [ ] Tasks rows recompute their clipped title width below 520 px, keep the status pill,
      and drop the timestamp below 380 px so long titles stay inside the right gutter at
      320 px and 480 px; the same width calculation keeps timestamps inside the pane at
      intermediate desktop widths
- [ ] Create worktree and Automation dialogs stack their footer below a 320 px content
      column; the modal name field stays inside its control and the automation
      Schedule/Project selects become full-width rows at 320 px
- [ ] comments added on one bot's Home stay on that bot when switching bots, and the
      reply flag follows the active bot across Scout/#eng rather than every bot
- [ ] right-clicking a worktree row opens Open worktree / Show diff / Rename / Close tab /
      Delete; right-clicking a task row opens Open task and Mark done (or Reopen task for
      a Done task); clicking elsewhere or pressing `Escape` dismisses the menu
- [ ] machine cards and project headers collapse/expand their worktree lists; the same
      panel button hides/restores the Bots bot fleet
- [ ] the Projects header sliders opens an inline Collapse all / Expand all panel whose
      rows hover, apply to every group, close on use, and close with `Escape`
- [ ] nav rows, tabs, project headers, worktree rows, search hits, task rows, automation
      rows, diff lines, Bots Files rows, the diff file tabs / plus / verdict chips and the composer send
      buttons, the Bots fleet cards / session rows and the Create worktree modal's selects
      / chips / primary button, the Bots Home Chat row, the rename/delete dialog buttons and the title-bar panel
      toggle show a hover state
- [ ] sidebar `+` (or the Projects/Bots tab strip `+`) opens Create worktree from any screen;
      creating selects the new worktree
- [ ] `Escape` closes the modal / clears search; no dead primary buttons
- [ ] a newly added bot's empty Home panel offers Open Home Chat and opens that session
- [ ] at compact widths `Escape` dismisses the Projects/Bots sidebar drawer and the Bots
      item-panel drawer; the no-tab Projects pane offers New worktree / Search, a fruitless
      Search offers Clear search, and Tasks offers Clear filters in list and detail
- [ ] chat composer still sends; the Bots center composer appends to the active chat;
      Bots screen tabs still switch
- [ ] composer access chip cycles Full access / Ask before edits / Read only; both model
      chips cycle Opus 5.5 / GPT-6 Astra / Grok 4 without clipping their footer
- [ ] right-clicking a worktree row shows Open / Show diff / Rename / Close tab / Delete;
      Rename updates the sidebar row and tab title (`↵` saves, `Esc` cancels); Delete asks
      for confirmation, closes the tab, clears task links and stays deleted after restart

Evidence:
- [ ] `moon check --target native` 0 errors; `moon test app --target native` all pass
      (104 tests cover each filter/toggle/selection/verdict/note-edit/range, page-level
      Enter routing, file content
      search, composer completion, tab-close, rail collapse, diff-navigation, Create From
      modes, the Advanced base branch, resize and context-menu actions)
- [ ] `moon build linux_skia --target native` and `moon build web_wasm --target wasm-gc` succeed
- [ ] 29 screenshots regenerated from their scenes; 20 acceptance shots are 2560×1504,
      the eight narrow Projects/Tasks/Bots/Diff/Automations/Search shots are 960×1200, and
      the phone-breakpoint Create worktree shot is 640×1200
- [ ] README screens/interactions/layout/screenshot commands updated; SPEC has an
      implementation-status section

### Round 25 verification (2026-11-26)

- [x] Projects tab widths: 375 px for a lone tab, 300 px once multiple tabs are open;
      16 px done badge at ≥90 px, close X only on hover, 48-character title truncation.
- [x] Bots center strip constants: 143 px bot Home tab + 196 px `#eng` + plus = 383 px;
      right item panel default 385 px; both dividers are 1 px lines with 9 px hit areas.
- [x] Fixed-width text columns use `clip_left` / `align_right`; Search narrow titles,
      Tasks compact subtitles, Automations compact names and Bots Files paths start on one
      leading edge, and times/metadata end on the right edge.
- [x] Automations table headers align with row name / schedule / run dot / toggle after
      sizing columns from `row_w - 28`; OCR error is ≤3 px.
- [x] Diff at 960×600 matches the reference within ±3 px for context rows, `Working for 7s`,
      wrapped body, tool rows, `Working…` and composer; 1280×752 keeps its one-line body.
- [x] Native/wasm checks, 82 app tests + 1 web test, both builds, `moon fmt --check` and
      `git diff --check` pass; all 21 screenshots regenerated at 2560×1504 / 960×1200.

### Round 26 verification (2026-11-26)

- [x] The worktree context menu maps Open / Show diff / Rename / Close tab / Delete to
      their own reducer actions; Rename edits in place and Delete confirms and persists.
- [x] The Diff chat header `x` collapses the split like the toolbar focus icon and its
      `+` opens Create worktree; both show a hover state.
- [x] Search hits use per-row hover IDs, so duplicate worktree hits no longer light up
      together.
- [x] Page headers reserve their action width: Search 128 px, Tasks 104 px, Automations
      70/148 px; actions stay right-aligned at 960 and 800, and Search shortens its
      subtitle below 680 px.
- [x] Automations keeps a fixed 60 px trailing toggle/status column and 294 px
      selected-row actions; Delete ends inside the card at 960 and 800.
- [x] The Bots narrow panel wraps long item titles to two lines below 360 px while
      activity labels still clip.
- [x] Native/wasm checks, 82 app tests + 1 web test, both builds, `moon fmt --check` and
      `git diff --check` pass; all 21 screenshots regenerated at 2560×1504 / 960×1200.

### Round 27 verification (2026-11-26)

- [x] The Bots selected card now paints only the bot header (46 px, white/10 fill,
      white/24 border); its sessions sit on the sidebar at the 21 px indent from the
      reference. The selected fill spans y 389–478 px against the reference's 389–480 px,
      and following bot cards keep their 50 px rhythm.
- [x] Create From reflows to a 2×2 grid below 360 px of content width. At 320×600 all four
      labels (Smart / GitHub / Branch / Name) render in full, and the taller dialog still
      ends inside the viewport with its stacked footer.
- [x] `modal_chips_stack` regression test covers the 359/360 px breakpoint and the 116 px
      chip width at 320 px.
- [x] Native/wasm checks, 83 app tests + 1 web test, both builds, `moon fmt --check` and
      `git diff --check` pass; Bots screenshots and the new 320×600 Create worktree shot
      regenerated.

### Round 28 verification (2026-11-26)

- [x] The Diff tab strip starts at y 14.5–33 px against the reference's 15–33 px, and the
      chat title / close / plus stay at 14.5–32.5 px.
- [x] The toolbar keeps a 180 px path column at the 480 px pane: the clipped path spans
      x 17–201 px (reference 17–197) and the AI-notes pill starts at x≈211 (reference
      206); its violet sparkle and x 215 label start match the reference.
- [x] The pill gains the reference's muted trailing sparkle at ≥470 px and measures
      136 px of fill against the reference's 138 px.
- [x] Hunk controls use an 18 px gap and 25 px right inset at roomy widths; up / down /
      focus land at x 376–384 / 409–417 / 440–453 against 377–388 / 410–421 / 441–455.
      Narrow panes fall back to 10 px spacing and a 20 px inset.
- [x] `diff_toolbar_path_width` regression covers 480/960/400/360 px; 84 app tests + 1 web
      test, native/wasm checks, both builds, `moon fmt --check` and `git diff --check` pass;
      `diff.png` and `diff-narrow.png` are regenerated.

### Round 29 verification (2026-11-27)

- [x] `/` command picker offers all five commands at `/`, filters `/rev` to `/review`,
      inserts `/review ` on tap, and disappears once a space completes the command token.
- [x] `@checkout` mention picker lists the three checkout files, preserves a
      `please @checkout` prefix as `please @src/checkout/validators.ts `, and ignores
      embedded addresses such as `email@example.com`.
- [x] The plus button in the Projects, Bots and Diff composers appends `@` to the draft
      and opens the file picker; its 20/16 px hit box keeps the closed composer geometry
      pixel-identical to the reference screenshots.
- [x] Open pickers reserve 47 + 42 × row height above the card, shifting the transcript
      instead of overlaying the input; OCR at 2560×1504 places the Commands header at
      y≈358 px, the first row at y≈394 px and the composer footer at y≈693 px.
- [x] Search `@` scope restores the pre-scope category after deleting `@`, and Clear
      resets both the current and saved filter. Off automations keep Run now inert;
      the last open diff tab has a dimmed X that does not dispatch `CloseDiffFile`.
- [x] Tasks' unlinked worktree card and Bots' Home controls without a Home session no
      longer fire `Noop` or paint a hover state.
- [x] 87 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; all 24 screenshots regenerated,
      including `composer-commands.png` and `composer-mentions.png`.

### Round 30 verification (2026-11-27)

- [x] `↑`/`↓` cycle the completion highlight across all five commands and the filtered
      file rows; the same message path works in Projects, Bots and Diff without letting
      a hidden menu steal arrow keys from list navigation.
- [x] Enter inserts the highlighted (or first) suggestion instead of sending `/rev` or
      `@check`; `ComposerPick` keeps a `please @checkout` prefix and closes the menu.
- [x] Escape dismisses the menu while keeping the draft, restores the 155 px Projects
      composer band, and typing again reopens the menu; the dismissed flags stay
      transient and are absent from persisted JSON.
- [x] `composer-commands.png` / `composer-mentions.png` show the new
      `↑↓ select · Enter insert` hint without clipping the header.
- [x] 90 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 31 verification (2026-11-27)

- [x] Search `↵` opens the selected hit even without focusing the field; the default first
      hit opens and an empty result set stays put.
- [x] Tasks `↵` opens the selected detail, while the new-task field keeps page Enter inert
      so Enter submits `AddTask` without also opening a task.
- [x] Automations `↵` opens the selected editor; overlays, confirmations, help and context
      menus keep page-level Enter inert, and `⌘↵` still saves the open editor.
- [x] The help card lists `↵` with a short label that fits the narrow card.
- [x] 92 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 32 verification (2026-11-27)

- [x] Changing a Tasks status/source filter or search query resettles the selected row; a
      hidden task hands off to the first visible row and its inline description draft is
      discarded, so Save cannot write it into another task.
- [x] Mark done / Reopen re-normalize the selection; opening New task closes the detail
      pane and cancels description editing, and `Escape` dismisses the composer.
- [x] Switching, adding, or closing the active Diff file closes the note thread and clears
      its draft; clicking the already-active tab is a no-op and keeps the line selection.
- [x] Opening the `handoff.md` tab clears a draft that belonged to another file; closing a
      non-active tab leaves the current note draft untouched.
- [x] 94 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 33 verification (2026-11-27)

- [x] Deleting `checkout-flow-v2` removes its four indexed files from file search and
      the Bots Files panel while the other four worktree-owned files remain.
- [x] `@validators` no longer appears in composer completion after that worktree is
      deleted, so every visible file row and mention still has a live destination.
- [x] 95 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 34 verification (2026-11-27)

- [x] Desktop Projects starts with the Projects header directly below the title bar;
      OCR places `Projects` at y≈62–83 and `Local Mac` at y≈103–121, matching the
      reference's y≈63–82 and y≈103–121.
- [x] Search / Tasks / Automations / Bots keep the shared nav rail; compact Projects
      keeps it in the sidebar drawer, while desktop Projects hides it.
- [x] The Orca wordmark opens a five-row page switcher with Projects highlighted first;
      choosing Tasks switches screens and closes the menu, and opening the modal or
      dismissing the menu clears its transient state.
- [x] Page-level Enter and page arrow navigation stay inert while the switcher is open.
- [x] `app-menu.png` captures the 232×172 menu card without stretching it to the
      window height; Projects screenshots are regenerated after the sidebar change.
- [x] 96 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 35 verification (2026-11-27)

- [x] Closing `handoff.md` and pressing the tab-strip `+` restores the first closed tab;
      with all four files open, `+` opens the Files picker instead of doing nothing.
- [x] The picker marks Showing / Open / Closed, switches to an existing tab, restores a
      closed tab, and closes after either action; scrim click and `Escape` also close it.
- [x] Switching through the picker closes the previous note card and clears its draft, so
      a note written for one file cannot be sent to another.
- [x] The 240×178 picker is anchored under `+` and stays inside the diff pane at 1280,
      480 and 320 px; `diff-files.png` captures the wide layout.
- [x] Search pills show live scoped counts: at `checkout`, All 7 = Worktrees 2 +
      Bots 1 + Sessions 1 + Files 3, and `@checkout` narrows All to the 3 files; the
      `Search files with @` suggestion is tappable. (Round 53 changes the `@` pill counts
      to preview the category switch; the current result count stays 3.)
- [x] Tasks status/source pills update with the query and the other active filter;
      OCR at 480 and 320 px finds All/Mine/Needs/Done and GitHub/Linear/Slack counts
      inside the window without clipping.
- [x] 98 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 26 screenshots are present.

### Round 36 verification (2026-11-27)

- [x] Advanced opens a real `Base branch` row; clicking it cycles main → develop →
      release/next and does not toggle the disclosure. The chosen base is written into
      the new worktree's setup worker body for Smart, GitHub and Branch sources.
- [x] The expanded dialog fits at 1280×752 with the 36 px selector and helper line, and
      at 320×600 / 480×600 with the 26 px compact selector; OCR finds the stacked
      `Create worktree` action fully inside the viewport in both narrow renders.
- [x] `orca-create-worktree-advanced.png` captures the expanded desktop state; the
      collapsed reference shot is unchanged.
- [x] 99 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 27 screenshots are present.

### Round 37 verification (2026-11-27)

- [x] The Bots Home status chip opens a three-row In progress / Waiting on you / Done
      menu; the current state carries an amber check, rows hover, and picking a state
      closes the menu. Done swaps the amber loader for a green check in the status row.
- [x] The override updates only the active bot, leaves its seeded `item.state` intact,
      appends `Status set to …` to Activity, and each bot keeps its own override when
      switching. `item_state` round-trips through the version 1 JSON, while missing fields
      still fall back to the seed state.
- [x] Bots without items ignore both the menu toggle and state picks; Escape, tab/panel
      changes, page navigation, AddBot, fleet movement and back/forward clear the menu.
- [x] `bots-status.png` shows Scout waiting on you with the menu open; `orca-bots.png`
      and `bots-panel-narrow.png` were regenerated with the new status chip.
- [x] 103 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 28 screenshots are present.

### Round 38 verification (2026-11-27)

- [x] `bots_needing_you` counts Home items in Waiting on you; the nav badge shows
      `1 needs you` at one, `2 need you` at two, and disappears at zero. The Bots standby
      copy uses the same count instead of a fixed “1”.
- [x] Changing Scout to Waiting raises the badge to 2; changing CI Watch to Done drops it
      back to 1; clearing both hides it. A new item-less bot never changes the count.
- [x] The count survives a persistence round trip, and `bots-status.png` was regenerated
      with the live “2 need you” badge while the status menu is open.
- [x] 104 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 28 screenshots are present.

### Round 39 verification (2026-11-27)

- [x] `mascot_with_status` overlays a 7 px amber dot with an 11 px `#2a2a2a` ring on the
      selected 36 px mascot; the dot sits at the bottom-right, matching the reference's
      14 px dot at 2× scale.
- [x] `orca-bots.png`, `bots-status.png` and `bots-files.png` were regenerated; the dot
      is visible with the sidebar open and stays absent from the closed-drawer narrow shots.
- [x] 104 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 28 screenshots are present.

### Round 40 verification (2026-11-27)

- [x] The Bots footer ends with a 28 px account avatar showing Maya's `M` initial; its
      10 px plus badge sits at the bottom-right and stays fully inside the avatar frame.
- [x] The avatar does not overlap the settings, help, history or fleet controls, and the
      28 px circle fits the 36 px footer with 4 px above and below.
- [x] `orca-bots.png`, `bots-status.png`, `bots-files.png`, `bots-narrow.png` and
      `bots-panel-narrow.png` were regenerated; the 1280 shots show the avatar, while the
      closed-drawer narrow shots keep the footer intact.
- [x] 104 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass; 28 screenshots are present.

### Round 41 verification (2026-11-27)

- [x] The Projects/Bots main, Bots comment and Diff mics append their own fixed sample
      phrases through `Dictate(1|2|3)`; `dictation_append` joins with one space and keeps
      existing trailing whitespace, while target 0/4 is a no-op.
- [x] The active mic turns amber at its unchanged 16/15/20 px footprint, and the Bots
      caption shows `Dictated locally` at ≥360 px; editing, picking a completion, or
      sending clears the transient hint, which is not persisted.
- [x] The new `scenes/bots_dictation` shot renders the full phrase, amber mic and caption
      with no clipping; the scene adds `bots-dictation.png` for 29 acceptance screenshots.
- [x] 105 app tests + 1 web test pass; native/wasm checks and builds pass;
      `moon fmt --check` and `git diff --check` pass.

### Round 42 verification (2026-11-27)

- [x] The Bots three-column widths subtract only the 2 px seams; at 1280 the default
      385 px right panel starts at x=895 logical (1790 at 2×) and reaches the window edge,
      so the old 16 px dark gutter is gone. The vertical rule still occupies x=1788–1789.
- [x] Bots Home geometry matches the reference: Activity icon starts at x≈1830, label copy
      at x≈1874, times end at x≈2532, Done-means body starts at x≈1874 and wraps after
      `...and the fix`, and the divider runs across the full panel.
- [x] The Scout card now spans x=1802–2543 at 2× with no outline; its 20 px avatar starts
      at x=1818, body copy aligns at x=1874, the inline code run has no chip fill, and the
      card bottom sits at y≈1106.
- [x] `orca-bots.png`, `bots-status.png`, `bots-files.png`, `bots-dictation.png`,
      `bots-narrow.png` and `bots-panel-narrow.png` were regenerated; 29 screenshots remain.
- [x] 106 app tests + 1 web test pass, including the 261 px → 49-character/two-line
      done-means regression; native/wasm checks and builds pass, as do `moon fmt --check`
      and `git diff --check`.

### Round 43 verification (2026-11-27)

- [x] The reference's selected worktree card runs y=277–440 at 1× (164 px high), with its
      header 10 px below the top edge. Our selected card now spans y=746–1072 at 2×
      (163.5 logical px), with its header at y≈767 (10.6 px below the top).
- [x] The next worktree header starts at y≈1099 at 2×, 13.4 logical px below the selected
      card, matching the reference's y=452 header / y=440 card-bottom gap (12 px).
- [x] Worktree cards use `worktree_card_padding() == (10, 12)`; a regression test locks
      the inset. All 29 acceptance screenshots were regenerated; the 1280×752 hero shot
      still shows the full sidebar through `Fix checks detail link` with no clipping.
- [x] 107 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`.

### Round 44 verification (2026-11-27)

- [x] An unlinked task's `Choose a worktree to connect` card opens the inline picker; a
      linked task's `Change` action reopens it, and the header action reads `Close` while
      the picker is open.
- [x] The picker lists only `live_worktrees` (4 in the seed) with name and branch, marks the
      current link with a green check, and offers `Unlink from this task` only when a link
      exists; picking `checkout-flow-v2` relinks task 0 without touching task 3, and an
      unknown id is a no-op.
- [x] Unlink clears `worktree_id`, survives a JSON save/load round-trip, and
      `task_link_menu_open` is not persisted.
- [x] `Escape` closes the picker. While it is open, page-level Enter and Tasks ↑/↓ are
      inert; switching tasks, filters/sources/queries, clearing filters, opening New task,
      opening the context menu, changing pages and back/forward navigation all close it.
- [x] The new `scenes/tasks_link` scene renders the open picker with four live worktrees and
      the unlink row inside the detail scroll area (`tasks-link.png`, 2560×1504).
- [x] 108 app tests + 1 web test pass, including
      `task worktrees relink, unlink and survive a restart`; native/wasm checks and builds
      pass, as do `moon fmt --check` and `git diff --check`; 30 screenshots are present.

### Round 45 verification (2026-11-27)

- [x] `AddTask` now leaves `worktree_id` empty instead of hardcoding `eu-promo-checkout`;
      the detail shows the unlinked card, and creating a task after deleting
      `eu-promo-checkout` still yields no stale link.
- [x] The picker's `Create worktree` row opens the existing create dialog through
      `OpenTaskWorktreeCreate` and records the selected task in transient
      `task_link_after_create`; closing or cancelling the dialog resets it to -1.
- [x] Submitting the create dialog writes the new worktree id to that task, opens its detail,
      closes the dialog and persists the link across a JSON round-trip. With **Create more**
      on, the dialog stays open and only the first creation links the task.
- [x] The picker's compact internals (40 px option rows, 28 px create row, 4 px gaps, 10 px
      padding) fit the new action inside the scroll area: at 2× the card bottom is y≈1456
      and `Unlink from this task` ends at y≈1427, with no clipping (`tasks-link.png`).
- [x] `new tasks start unlinked and create a worktree from the picker` covers the empty
      link, pending-create state, cancel cleanup, automatic link, persistence and the
      deleted-default case.
- [x] 109 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 30 screenshots are present.

### Round 46 verification (2026-11-27)

- [x] Cancelling or completing a Create worktree dialog clears the transient source,
      name, Advanced/base-branch, agent, target and Create more state; reopening from the
      sidebar `+` lands on Smart with an enabled primary button, and `OpenTaskWorktreeCreate`
      does not inherit a previous Advanced configuration.
- [x] Removing all automations leaves empty list and run-history states; the history card
      renders `No runs yet`, its explanatory copy and a working **New automation** action,
      while the dead `View all` toggle is absent.
- [x] The Bots footer history icon now uses `OpenBotItemPanel(2)`, so it reopens a
      collapsed item panel on Chats instead of only setting an invisible tab.
- [x] `scenes/automations_empty` renders the full empty page at 2560×1504; OCR confirms
      `No automations yet`, `No runs yet`, the history helper and the create action with
      no clipping (`automations-empty.png`).
- [x] 111 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 31 screenshots are present.

### Round 47 verification (2026-11-27)

- [x] Cancelling the Automation editor or saving either the edit or new-automation path
      resets `automation_editor_index`, name, schedule and project; reopening
      **New automation** after either path shows a blank form.
- [x] A no-match Bots fleet filter renders an actionable **Clear search**;
      `ClearBotQuery` empties `bot_query` while keeping `bot_search_open` true.
- [x] New bots have no work item and show the ready-to-start Home Chat copy plus
      `Waiting for your first message`, rather than the generic seed transcript.
- [x] `scenes/bots_new` renders a newly added Relay with the empty Home Chat intro and
      the right-panel `No active item` / **Open Home Chat** guide at 2560×1504; OCR
      confirms both intro lines with no clipping (`bots-new.png`).
- [x] 113 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 32 screenshots are present.

### Round 48 verification (2026-11-27)

- [x] `bot_chat_key` resolves an empty `active_session` to the active bot's first Home
      session, so a message sent from the default Bots view and the same bot's Home
      Chat share one transcript; selecting Home Chat after sending keeps the two rows.
- [x] A new bot's ready-to-start intro and `Waiting for your first message` row render
      only before the first message; `bot_chat_waiting` turns false once the current
      chat key has messages.
- [x] The itemless Home panel copy switches from **Start a Home Chat** to
      `<name> has started in Home Chat. Open it to continue the thread.` after a send.
      Round 49 supersedes this path by creating a real item on the first message.
- [x] `scenes/bots_new_chat` renders Relay after **Draft a release checklist for 4.13**
      at 2560×1504; OCR confirms the user line, the assistant reply, no intro and the
      right-panel copy with no clipping. The shot was regenerated in Round 49 to show the
      created `#43` item (`bots-new-chat.png`).
- [x] 114 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 33 screenshots are present.

### Round 49 verification (2026-11-27)

- [x] The first message to a newly added bot creates a real Home item: `#43`, title
      `Draft a release checklist for 4.13`, `In progress`, meta
      `Item 43 · Home Chat · now`, two chips, a Done-means line and Add /
      Worker-started activity; the bot switches to `1 working`.
- [x] A second new bot gets `#44`; sending from a seed bot keeps its `#41` item and does
      not advance `bot_item_seq`. Titles longer than 38 characters end in `…`.
- [x] `bot_item_seq` and the full `BotItem` / chips / activities / optional message are
      persisted. A save/load round-trip restores both created items, their activity and
      the next number, while seed bots keep their seed sessions and items. Payloads that
      predate item encoding keep the seed item fallback.
- [x] New bots no longer fall through to the generic seed transcript; only the six
      reference bots use `bot_has_seed_transcript`.
- [x] `scenes/bots_new_chat` was regenerated at 2560×1504. OCR finds `#43 Draft a release
      checklist for 4.13`, `In progress`, `Item 43 · Home Chat · now`, both chips,
      Done means and both activity rows, with the rightmost text ending before the panel
      edge (`bots-new-chat.png`).
- [x] 115 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 33 screenshots are present.

### Round 50 verification (2026-11-27)

- [x] Picking a Home status now appends a real `Status set to …` entry to that bot's
      `BotItem.activities` (time `now`, Done uses a check icon). A second pick appends a
      second entry, picking the current state leaves the list unchanged, and other bots
      keep their own activity list.
- [x] Status entries ride with the item through the version 1 JSON: `item_state` plus two
      or more status rows survive save/load. Older payloads with an override but no status
      activity still render the current row through the view fallback.
- [x] `scene_bots_status_model` is built through the real menu/update path;
      `bots-status.png` was regenerated at 2560×1504 and OCR still finds
      `Status set to Waiting on you` / `now` at the end of Activity without clipping.
- [x] Regression test `status changes append to the persisted activity history` covers
      accumulation, same-state deduplication and the persistence round trip.
- [x] 116 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 33 screenshots are present.

### Round 51 verification (2026-11-27)

- [x] The reference is a full-window capture with a ~14 px outer frame and a 16 px
      scrollbar rail. Content-relative columns are ~272 px sidebar and 400 px right
      panel; defaults now use 272 + 400 instead of the absolute-x-derived 285 + 385.
- [x] At 1280 the panes are 272 / 606 / 400 with the 2 px seams; at 960 the panel
      shrinks to ~307 px, and at 700 the two panes still leave the chat 300 px.
- [x] Title-bar content moved to the content origin: “Orca” OCR x=71.6 vs 71.4.
      The Bots header uses a 16 px chevron + 4 px gap and lands at x≈22.6 vs 21.2
      without moving its right-side actions.
- [x] The comment composer’s plus and placeholder both align: plus pixels
      905..913.5 vs 905..914.5 and `Add a comment…` x=927.7 vs 927.8; mic/send stay
      on the right edge. Panel Home / Files text errors are ≤1 px.
- [x] Eight Bots shots were regenerated (main, status, files, new, new-chat,
      dictation, narrow, panel-narrow); OCR still finds the status activity, indexed
      files, new-bot copy and dictated phrase without clipping.
- [x] 116 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 33 screenshots are present.

### Round 52 verification (2026-11-27)

- [x] The active center tab has the reference's 2 px white baseline (x=546..831 at 2×,
      i.e. the full Home-tab width). It is an overlay, so the 36 px strip height and
      click target are unchanged.
- [x] The Home tab now shows its amber working spinner and 12 px mascot; after the
      reference's ~14 px frame offset, the spinner starts at 280 vs 278.5 logical and
      `Scout` at 306 vs 305. `#eng` uses a local hash glyph and lands at 423.5 vs 422;
      its label starts at 437 vs 438.
- [x] The icon audit found three names absent from the vendored Lucide subset (`hash`,
      `plug`, `unplug`). All now use explicit SVG paths, including connector actions and
      the Tasks worktree unlink row; no literal Lucide name used by the app is missing.
- [x] `session_row_label_width(272) = 165` and `session_row_label_limit(272) = 26`;
      the high-resolution OCR/pixel pass finds all 26 glyphs of
      `#eng · checkout on Safari?`, with no ellipsis, while the timestamp stays inside
      the selected row.
- [x] Eight Bots shots were regenerated (main, status, files, new, new-chat, dictation,
      narrow, panel-narrow); all are 2560×1504 or 960×1200 as configured.
- [x] 116 app tests + 1 web test pass; native/wasm checks and builds pass, as do
      `moon fmt --check` and `git diff --check`; 33 screenshots are present.

### Round 53 verification (2026-11-27)

- [x] With `@pay`, tapping Bots / Worktrees / Sessions / All strips the leading `@` and
      applies that category to the remaining text; tapping Files keeps `@pay` and the
      stored pre-scope category. The regression test checks BotHit-only results and All.
- [x] Pill counts preview the tap: with `@checkout`, All 7 = Worktrees 2 + Bots 1 +
      Sessions 1 + Files 3, while the live result count remains 3. `search-files.png`
      was regenerated and OCR finds the five counts without clipping.
- [x] The compact diff stack is 50/50 via `diff_compact_pane_heights`: at 480×600 both
      panes are 299.5 px; the code viewport keeps 208.5 px (~8 rows) and the chat
      transcript grows from ~65 to 124.5 px, enough for File / Line / User comment.
      `diff-narrow.png` was regenerated; OCR finds the full context card above the
      composer with no overlap.
- [x] The Search scope-switch and compact split assertions extend the existing tests;
      116 app tests + 1 web test pass, native/wasm checks and builds pass, and
      `moon fmt --check` / `git diff --check` pass; 33 screenshots are present.

### Round 54 verification (2026-11-27)

- [x] Tasks now store `TaskActivity` rows (`icon`, `text`, `time`) in `Task.activity`
      instead of deriving a fixed four-line block at render time. Seed tasks and older
      payloads without `activity` get the same four baseline rows through
      `default_task_activity`, so a version 1 save keeps its tasks and never shows an
      empty Activity list.
- [x] Mark done / Reopen append `Marked done` / `Reopened`; relink and unlink append
      `Linked to <id>` / `Unlinked worktree`; Save appends `Description updated` only
      when the copy changed; a new task starts with `Task created` / `Assigned to you`;
      creating a worktree from the detail pane and deleting a linked worktree append
      their own rows. Repeated Mark done and relinking the same worktree do not append
      duplicates.
- [x] Activity dots follow the row icon (green check, blue play, amber comment, otherwise
      dim) and the growing timeline stays inside the detail pane's scroll area, so the
      Mark done / Reopen footer remains reachable.
- [x] `task actions append to the persisted activity timeline` covers the baseline,
      every append path, deduplication, save/load and the legacy payload fallback;
      `closing the task context menu runs no action` covers `CloseContextMenu` directly.
      118 app tests + 1 web test pass.
- [x] `tasks.png`, `tasks-link.png`, `tasks-narrow.png` and `tasks-list-narrow.png`
      were regenerated at 2560×1504 / 960×1200; OCR finds the four Activity rows,
      `Open in worktree` and `Mark done` without clipping.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`; 33 screenshots are present.

### Round 55 verification (2026-11-27)

- [x] `Model.diff_worktree` now identifies the worktree being reviewed. The worktree
      context menu’s **Show diff** routes through `open_diff_worktree`, which selects the
      row’s tab and loads its review instead of leaving the fixed checkout content in place.
- [x] Checkout keeps the reference file set and `Tighten address validation` header.
      EU promo opens `rules.ts` / `promo.test.ts` / `cart.ts` / `CHANGELOG.md`; handoff opens
      `handoff.md` / `handoff.template.md` / `handoff.ts` / `README.md`; checks opens
      `checks.ts` / `checks.test.ts` / `ci.yml` / `CHECKS.md`. All profiles keep four
      closed-tab slots, so persisted `diff_closed` masks stay compatible.
- [x] Switching worktrees resets file, selection/anchor, open note, draft, notes, verdict,
      extra messages and working state. Reopening the same worktree preserves the live
      review. The checks profile is stopped, so it shows `Worked for 7s`, `Stopped` and
      the Approve / Request changes chips; its context card follows `src/ci/checks.ts`.
- [x] `diff_worktree` and `diff_working` survive save/load, while a legacy payload without
      those fields falls back to the checkout seed. `show diff scopes the review to the
      selected worktree` covers the context path, dirty-state reset and switching back to
      checkout; `the selected diff worktree survives a persistence round trip` covers JSON.
      120 app tests + 1 web test pass.
- [x] `scenes/diff_checks` adds `docs/screenshots/diff-checks.png` at 2560×1504; OCR finds
      `checks.ts`, `checks.test.ts`, `ci.yml`, `File: src/ci/checks.ts`, `Worked for 7s`,
      `Stopped`, `Approve` and `Request changes`. `diff.png`, `diff-files.png` and
      `diff-narrow.png` regenerated byte-identically; 34 screenshots are present.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 56 verification (2026-11-27)

- [x] `automation_save_blocked` treats an empty or whitespace-only automation name as
      blocked. `SaveAutomation` then returns the model unchanged, so the dialog stays open
      and no `Untitled automation` row is added; non-blank names are still trimmed before
      create/update.
- [x] The editor shows the amber `Type a name to save` hint under the name field and dims
      **Save changes / Create automation**; both the button and `⌘↵` use the same model
      guard, so both are no-ops while blocked. Clearing the name of an existing automation
      keeps its previous name until a replacement is typed.
- [x] `automation save stays open until a name is typed` covers blank and whitespace-only
      saves, trimmed creation, blocked edit with the old name preserved, and the successful
      renamed save clearing the draft. 121 app tests + 1 web test pass.
- [x] `scenes/automation_editor_blocked` adds
      `docs/screenshots/automations-editor-blocked.png` at 2560×1504; OCR finds
      `Type a name to save`, `Create automation` and `Cancel`, and the primary button
      background drops from 240 to 56 grey. The filled editor and the other three
      automation screenshots regenerate byte-identically; 35 screenshots are present.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 57 verification (2026-11-27)

- [x] `task_add_blocked` treats an empty or whitespace-only task title as blocked.
      `AddTask` then returns the model unchanged, so the composer stays open and no
      `Untitled task` row is added; non-blank titles are still trimmed before creation.
- [x] The composer's **Add** action switches to `page_button_hover_disabled` and the amber
      `Type a task title to add` hint appears below the field/button row. Field submit and
      the Add button share the model guard, so both are no-ops while blocked. Desktop keeps
      the inline field+buttons row; narrow stacks the field, buttons and hint without
      clipping. The list scroll height reserves the extra 20 px for the hint (64 wide /
      104 compact), so the composer does not overlap the task rows.
- [x] `task composer requires a title before adding` covers blank and whitespace-only Adds,
      trimmed creation, the task count staying unchanged, and the successful draft reset.
      `task composer height reserves room for the blank-title hint` pins the 0/64/104 and
      44/84 reserved heights. 123 app tests + 1 web test pass.
- [x] `scenes/tasks_composer` adds `docs/screenshots/tasks-composer.png` (2560×1504) and
      `tasks-composer-narrow.png` (960×1200); OCR finds `What needs doing?`,
      `Type a task title to add` and `Add`, and the disabled button uses a 26 grey fill
      with 111 grey text. The four existing Tasks screenshots regenerate byte-identically;
      37 screenshots are present.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 58 verification (2026-11-27)

- [x] `rename_save_blocked` blocks an open rename dialog whose draft is empty or
      whitespace-only. `CommitRename` then returns the model unchanged, so the dialog stays
      open and the worktree keeps its previous name and branch; non-blank names are still
      trimmed before the sidebar row and tab title update together.
- [x] The field submit and **Rename** button share the same guard, so `↵` and the button
      are both no-ops while blocked. The rendered dialog shows the amber
      `Type a name to rename` hint under the field and swaps in the inert
      `dialog_button_disabled` action (36 px, muted text, `white_a(0.14)` fill). Cancel,
      the close icon and the field cancel remain active; typing a non-blank name restores
      the primary action.
- [x] `rename dialog blocks an empty name` covers blank and whitespace-only commits,
      the draft staying intact, the old name being preserved, trimmed successful rename,
      and the guard resetting after close. 124 app tests + 1 web test pass.
- [x] `scenes/rename_worktree_blocked` adds `worktree-rename-blocked.png` (2560×1504) and
      `worktree-rename-blocked-narrow.png` (960×1200); OCR finds `Rename worktree`,
      `Type a name to rename`, `Cancel` and `Rename` in both. The blocked Rename button
      measures about 45 grey versus 240 grey for the enabled action. Regenerating the
      normal `worktree-rename.png` is byte-identical; 39 screenshots are present.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 59 verification (2026-11-27)

- [x] `diff_tab_visible` switches the strip to phone mode once a tab would be narrower
      than 120 px. At 320 px with three open files only the active `validators.ts (diff)`
      tab paints; the right-hand **3 files** picker still lists every open/closed file and
      keeps switching and restore actions reachable. Its menu is pinned to the right edge
      and clamped inside the diff pane.
- [x] The phone context card reads `File: validators.ts` instead of clipping the full path
      mid-filename. At 480 px and desktop it still shows `src/checkout/validators.ts`; the
      `clip_left` fallback remains for longer paths. `diff.png`, `diff-narrow.png` and
      `diff-files.png` regenerate byte-identically.
- [x] `diff tabs focus the active file at phone widths` covers the 3-file 320 px single-tab
      state, all tabs at 480 px, the 4-file 480 px collapse, focus following a picker
      switch, and the basename/full-path branch. 125 app tests + 1 web test pass.
- [x] `diff-phone.png` and `diff-phone-files.png` render at 640×1200. OCR finds the active
      tab, `3 files`, all four picker rows with Showing/Open/Closed, and
      `File: validators.ts`; `scenes/diff_phone_menu` backs the open-picker shot.
      41 screenshots are present and the README count/commands now match.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 60 verification (2026-11-27)

- [x] `compact_panel_width` keeps the item-panel drawer at its 320 px desktop minimum:
      at 320 and 360 px viewports the drawer fills the window, from 384 px it leaves the
      64 px chat peek (320 px panel), 400 px renders 336 px and 480 px still uses the
      stored 400 px. A 500 px stored width caps at 416 px at 480 px.
- [x] The phone drawer keeps the compact icon tabs, single-column Home chips, wrapped
      title and full-width Done means copy. The close toggle, Escape and sidebar-drawer
      priority are unchanged; the 480×600 `bots-panel-narrow.png` regenerates
      byte-identically.
- [x] `narrow bots use drawers and keep the chat wide` now pins the 320/360/384/400 px
      widths in addition to the existing 480 px and capped-storage cases; 125 app tests
      and 1 web test pass.
- [x] `bots-panel-phone.png` renders at 640×1200. The `#181818` drawer background covers
      the full 0–639 px row, removing the scrimmed chat sliver; OCR finds the item title,
      `In progress`, `Fix Safari Pay tap follow-up`, `Done means`, both Done-means lines,
      `Add a comment...`, the 9:02–9:08 AM activity times and the `38 %` / `maya-mbp` /
      `2 hosts` status bar. 42 screenshots are present and README counts/commands match.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 61 verification (2026-11-27)

- [x] `page_arrow_blocked(model, drawer_open)` keeps page-level ↑/↓ inert behind the
      modal/rename/delete/automation dialogs, help card, context menu, wordmark menu and
      task-link picker. Tasks composer and description editing, the Bots status menu,
      filter field, display options and collapsed fleet, and the Diff file picker also
      block page arrows. Composer completion menus still handle their own arrows first.
- [x] Compact drawer routing is width-aware: Bots blocks below 760 px while either the
      sidebar or item-panel drawer is open, other pages below 720 px while the sidebar
      drawer is open, and inline sidebars keep arrow navigation. This prevents rows
      hidden behind a help card, app menu or Bots status menu from changing selection.
- [x] `enter_page_action(model, drawer_open)` returns Noop while a compact drawer is
      open, so page-level Enter cannot activate a Search hit or Tasks/Automations row
      hidden behind it. The overlay and editor guards keep their previous behavior.
- [x] `page arrow navigation yields to overlays and drawers` covers all eight overlay/
      editor states, the Tasks and Bots menu states, the Diff file picker and both drawer
      branches; `page enter routes search and yields to composition and drawers` adds the
      Enter drawer case. 126 app tests + 1 web test pass; no screenshot changed and
      42 remain.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 62 verification (2026-11-27)

- [x] `panel_row_inner_width(width)` is the `width - 24` body minus the 8 px container
      padding on each side; Files and Chats rows now share it. `panel_file_text_width`
      subtracts the 28 px icon, 13 px chevron and three 10 px gaps, yielding 289 px at a
      400 px panel and 209 px at 320 px.
- [x] The Files row previously used `width - 32` for its content and `width - 103` for
      the text column, overflowing the real inner width by 8 px. The regenerated
      `bots-files.png` keeps the path and metadata text at the same OCR pixels while the
      first row's chevron moves from x=2527 to x=2511 (8 logical px), matching the Chats
      gutter.
- [x] The layout-helper test pins the 400/320 px row and text widths. 126 app tests + 1
      web test pass; the screenshot count remains 42.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 63 verification (2026-11-27)

- [x] At the 320 px viewport the shortcuts card had only 240 px of content while its
      13 px labels ran to the window edge: `Open Search from any screen`,
      `Switch to an open worktree tab` and `Create a worktree or save an edit` clipped at
      x=320 even though the card ends at x=304.
- [x] `help_labels_compact(content_w) = content_w < 330` switches the card to twelve
      short action labels below that width; full labels stay at 330 px and wider, where
      the measured 215 px longest label fits inside the 226 px label column.
- [x] `help-narrow.png` (320×600 → 640×1200) shows all twelve rows ending by x≈272
      inside the 304 px card edge, with the key chips unchanged. Acceptance screenshots
      are now 43.
- [x] The overlay-card test pins the 329/330 boundary and the compact/full
      `Create or save` copy; 126 app tests + 1 web test pass.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 64 verification (2026-11-27)

- [x] At 320 px the Diff composer field is 212 px wide; the reference
      `Ask anything, @ to mention files, / for\ncommands` placeholder could not fit its
      first line and wrapped to a third line that extended past the 56 px field, also
      growing the composer card by about 22 px.
- [x] `diff_composer_placeholder(field_width)` falls back to the shared one-line
      `Ask anything…` below 360 px; the two-line reference copy is kept at 360 px and
      above, including the 372 px field at the 480 px layout. The overlay is limited to
      fields below 430 px, so wide panes keep the shared single-line full copy.
- [x] `diff-phone.png` and `diff-phone-files.png` (320×600 → 640×1200) show the single
      placeholder line at y=956–1000 inside the field, with the footer at y=1086–1120
      and the card ending 24 px above the window edge. `diff-narrow.png` still shows the
      two-line copy at y=957–1043 at 480 px.
- [x] `narrow diff stacks its panes` pins the 212/359/372 px placeholder branches and the
      429/430 px overlay boundary; 126 app tests + 1 web test pass and 43 screenshots
      remain.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 65 verification (2026-11-27)

- [x] The Bots composer uses a single-line 44 px field whose full placeholder needs
      about 440 px. At 320 px the field is 223 px and cut at
      `Ask anything, @ to mention bc`; at 480 px it is 383 px and cut at `/ for comma`.
- [x] `bots_composer_placeholder(field_width)` returns `Ask anything…` below 320 px,
      `Ask anything, @ bots or files, / for…` from 320–459 px, and the full sentence at
      460 px and above.
- [x] The new `bots-phone.png` (320×600 → 640×1200) shows `Ask anything…` at y=939–973,
      and the regenerated `bots-narrow.png` (480×600 → 960×1200) shows the medium copy at
      y=941–971; both stay inside the field. Acceptance screenshots are now 44.
- [x] `bots composer placeholder shortens at narrow widths` pins the 223/383/559 px
      branches; 127 app tests + 1 web test pass.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 66 verification (2026-11-27)

- [x] Search's five full category pills, their counts and the result total overflowed the
      32 px gutter below 480 px. At 320 px the total reached x≈304.5 (content edge 288),
      at 360 px `7 results` reached x≈346.5 (edge 328), and at 420 px the count clipped
      to `7re` at the window edge. The Tasks `6/6` total also reached x≈309.5 at 320 px,
      past the list's 296 px content edge; at 360 px its painted pixels still fit.
- [x] `search_filters_compact(width) = width < 480` switches Search to the short
      `Trees` / `Chats` labels, 6 px pill padding and 4 px gaps below 480 px while keeping
      every category count and the result total. At 480 px and above the full
      `Worktrees` / `Sessions` labels and original 9/6 px spacing are unchanged;
      `search-narrow.png` regenerates byte-identically.
- [x] `task_filter_pills_dense(width) = width < 360` gives the four Tasks status pills
      6 px padding and 4 px gaps at phone width, bringing `6/6` back inside the list's
      24 px gutter. From 360 px the normal layout remains; `tasks-list-narrow.png`
      regenerates byte-identically.
- [x] New `search-phone.png` and `tasks-list-phone.png` (320×600 → 640×1200) show
      `All` / `Trees` / `Bots` / `Chats` / `Files` with `7`, and
      `All 6` / `Mine 4` / `Needs 2` / `Done 2` with `6/6`. Pixel checks put the rightmost
      content at x=574 and x=587 inside the 576 and 592 px content edges; acceptance
      screenshots are now 46.
- [x] `phone filter rows tighten before their counts overflow` covers the 479/480 and
      359/360 boundaries; 128 app tests + 1 web test pass.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 67 verification (2026-11-27)

- [x] At 320 px the Tasks new-task composer's source / agent / Add row measured about
      292 logical px and reached x=632 px (316 logical), 20 logical px beyond the list's
      296 px content edge and only 4 px from the window edge. The row needs a 340 px
      viewport to fit at the normal labels.
- [x] `task_composer_agent_compact(width) = width < 360` and
      `task_composer_agent_label(kind, width)` shorten Claude's button copy from
      `Claude Code` to `Claude` at phone width; Codex and Grok keep their labels. From
      360 px the full copy remains, and `tasks-composer-narrow.png` regenerates
      byte-identically.
- [x] New `tasks-composer-phone.png` (320×600 → 640×1200) shows `GitHub` / `Claude` /
      `Add`; pixel checks put the rightmost content at x=558 inside the 592 px content
      edge while the field and blank-title hint are unaffected. Acceptance screenshots
      are now 47.
- [x] `task composer shortens the agent label at phone widths` covers the 359/360
      boundary, Claude's short/full copy and the unchanged Codex label;
      129 app tests + 1 web test pass.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`.

### Round 68 verification (2026-11-27)

- [x] At 320 px the Create worktree fields are 112 px each, leaving only 36 px for the
      value after the 12/10 px padding, 16 px icon, 14 px chevron and three 8 px gaps.
      `acme-internal` and `mac-mini` painted past their fields, and the `Run on` chevron
      reached x≈306 logical, outside the field's 280 px right edge and the dialog card.
- [x] `select_value_width(width, icon_width)` plus a clipped value column keeps both
      values inside the 36 px phone-width column; the chevrons now end about 14 px
      inside their fields. Automation selects pass their 14 px icon width, so the
      desktop `orca-create-worktree.png` / `automations-editor.png` shots regenerate
      byte-identically.
- [x] The Automations header's compact action reserve changes from 70 to 72 px at
      320 px; the light `+ New` button ends at x=572 output (286 logical) instead of
      x=577 (288.5), two logical px inside the 288 px content edge. The 480 px
      `automations-narrow.png` remains byte-identical.
- [x] New `scene_tasks_link_phone_model()` and `scenes/tasks_link_phone` render the
      single-pane Tasks detail with the worktree picker open at 320×600.
      `tasks-link-phone.png` shows `Choose a worktree`, `4 available`, the first option
      and `Close` with the rightmost ink at x≈583 output inside the 298 px content edge;
      the remaining rows and Create/Unlink actions continue in the scrollable detail.
- [x] New `docs/screenshots/automations-phone.png` (320×600 → 640×1200) backs the header
      fix; acceptance screenshots are now 49 and README counts/commands match.
- [x] Phone audit: Search's rightmost content stays inside its gutters; Diff code
      ellipses reach x≈636 output but the shell's `.clip()` keeps them inside the
      320 px window, matching the reference's edge-clipped code lines, so no layout
      change is needed.
- [x] `select values keep the chevron inside narrow fields` pins the 112/243 px widths
      and 14/16 px icons; `phone filter rows tighten...` remains green. 130 app tests
      and 1 web test pass.
- [x] Native/wasm checks and builds pass, as do `moon fmt --check` and
      `git diff --check`; 49 screenshots are present.

### Round 69 verification (2026-11-27)

- [x] The production program now subscribes to the host timer at a 30 s interval and
      maps its frame time to `AutomationTick`; the first tick arms every enabled
      non-manual schedule, a due run appends a passed run and updates the same
      Runs today / Passed / Needs attention counters, then re-arms. Disabling a row
      clears its due marker; re-enabling arms it on the next tick; `Manual` never fires.
- [x] `next_run_ms` / `automation_clock_ms` stay session-only, so a restart re-arms from
      zero instead of firing stale schedules. The seeded daily / weekday / Friday
      cadences use 24 h / 24 h / 7 d, not wall-clock calendar dates.
- [x] `automations-scheduled.png` (1280×752 → 2560×1504) shows `next in 1d` on the two
      daily/weekday rows and `next in 30m` on the running row; the disabled Fridays row
      deliberately keeps no next-due copy. OCR finds all three labels inside the
      schedule column.
- [x] Diff tabs now have 4 px spacing, per-tab close-X hover backgrounds, and the
      prev/next hunk and split/focus controls gain hover containers. The file-picker
      anchor includes the final inter-tab gap and remains clamped inside the left pane
      at 1280 / 480 / 320 px.
- [x] The six Diff screenshots were regenerated. At 1280 OCR reads
      `validators.ts (diff)`, `shipping.ts (diff)` and `cart.spec.ts (diff)`; 480 keeps
      compact basenames; the 320 px active tab still reads `validators.ts (diff)` with
      the `3 files` picker.
- [x] `host ticks arm, fire and re-arm scheduled automations` covers arming, due firing,
      counters / attention, disabling, re-enabling, manual runs and persistence-reset.
      131 app tests + 1 web test pass.
- [x] Native/wasm checks and both builds pass, as do `moon fmt --check` and
      `git diff --check`; 50 screenshots are present and README counts/commands match.

### Round 70 final acceptance (2026-11-27)

- [x] The seven key screenshots (`orca`, `orca-create-worktree`, `orca-bots`, `search`,
      `tasks`, `automations`, `diff`) were regenerated from their scenes at 1280×752,
      scale 2, dark; every PNG is 2560×1504.
- [x] A view-image pass over all seven found no blank panes, overlaps or missing glyphs:
      Automations keeps plain-text table headers and the selected-row Edit / Run now /
      Delete bar, the Create worktree selects keep the 44 px field rhythm, the Diff note
      card still sits at x≈88 with width 360 under line 27 beside the three file tabs,
      and the Bots fleet keeps its three-pane density.
- [x] The one selected-state deviation found against
      `design/reference-create-worktree.jpg` was the Create From chip: the reference draws
      a white rule under Smart, while the implementation only brightened the label. The
      chip now renders a 2 px `fg_primary` underline (`width - 13`) under the selected
      chip; the key, advanced and 320 px modal screenshots were regenerated. In the
      seven-shot pass the other five scenes stayed byte-identical and `diff.png` refreshed
      to the current Round 69 diff-tab build.
- [x] Phase 3 checklist behaviours are covered by the round logs above and the 131-test
      suite (filters, toggles, Mark done / Reopen, new task / automation, diff tabs,
      notes, verdict, shortcuts, drawers, hover and persistence); the underline was the
      only visual fix needed in this pass.
- [x] Final gates: `moon check --target native` 0 errors; 131/131 app tests pass;
      `linux_skia` native and `web_wasm` wasm-gc builds succeed; `moon fmt --check` and
      `git diff --check` pass; 50 screenshots are present.
- [x] The only remaining non-goals are those recorded in SPEC's 实现状态 section: no live
      agent/network backend, no filesystem scan, no wall-clock automation across
      restarts, and vector mascots; none block the Phase 3 checklist.

### Round 71 Bots rhythm and final sign-off (2026-11-27)

- [x] The desktop Bots body now follows the reference rhythm: the nav, sidebar scroll
      content and session group use compact spacing, and session rows are 26 px tall with
      1 px between rows. The nested group keeps a 21 px left inset, so the Home / Claude /
      Codex / Slack stack sits at the same depth as the reference without crowding the
      bot card.
- [x] Agent session rows are nested with a 12 px left and 2 px right glyph lead plus a
      6 px gap; Claude and Codex labels use 10.75 px while Home and Slack stay at 11.5 px.
      Claude keeps the 10 px amber spinner, Codex now uses the outlined 10 px green
      `check_circle_icon`, and timestamps retain the 1.5 px trailing inset.
- [x] The right-panel Home breadcrumb now uses a 12 px `arrow-left`, 12 px Home / bot name,
      16 px mascot, 5 px row spacing and a 3 px spacer before the name; the full row remains
      the Home Chat tap target with its hover fill.
- [x] The Diff validator gutter now numbers the trailing context rows 31 and 32 and leaves
      the removed line's number blank; line 26 still reads `  })`. No other Diff rows or
      controls moved.
- [x] A 960×600 audit of the Create worktree modal against the reference found matching card
      bounds (x≈229–730, top/bottom bands y≈150–530, primary action y≈500–526) and no
      definite missing control or sizing defect; no speculative UI was added.
- [x] All ten Bots screenshots were regenerated after the final edits: six at 2560×1504
      (`orca-bots`, `bots-files`, `bots-status`, `bots-new`, `bots-new-chat`,
      `bots-dictation`), two at 960×1200 (`bots-narrow`, `bots-panel-narrow`) and two at
      640×1200 (`bots-panel-phone`, `bots-phone`). OCR found every key session label and
      control; measured Home `88–211` vs `88–210`, Safari `145–310` vs `147–307`, WebKit
      `145–327` vs `146–327` and Slack `150–379` vs `147–380`, with timestamps within
      ~2 px and the vertical rhythm within 0–3 px.
- [x] Final gates: native and wasm-gc `moon check` report 0 errors; 131/131 app tests and
      1/1 web test pass; `linux_skia` native and `web_wasm` wasm-gc builds succeed;
      `moon fmt --check` and `git diff --check` pass. The 50 acceptance screenshots are
      present, including the regenerated Bots set and the Round 70 Create From underline.
- [x] The remaining non-goals are unchanged: no live agent/network backend, no filesystem
      index, no wall-clock automation across restarts, and vector mascots. Nothing in the
      Phase 2/3 checklist is left open.
