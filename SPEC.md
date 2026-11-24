# Orca × MoUI — 复刻规格 (v1)

Goal: rebuild the Orca desktop app (https://orca.dev, https://github.com/stablyai/orca) as a
native MoUI application. This is a visual + interactive replica of Orca's "agent IDE" screen:
bot-fleet sidebar, worktrees, tabbed agent chat, worker updates, composer, and the
"Create worktree" dialog.

The reference screenshots in `design/` are authoritative:
- `design/reference-orchestration.jpg` — main screen (sidebar + chat + worker cards)
- `design/reference-create-worktree.jpg` — Create worktree modal
- `design/reference-diff.jpg` — diff review screen (phase 2)
- `design/brand-paths.txt` — Claude / Codex / Grok brand glyph path data

MoUI docs/examples (read these before coding):
- Local project's `.mooncakes/wzzc-dev/moui/views/pkg.generated.mbti` has exact signatures.
- `/home/chuang/orca/workspaces/MoUI/MoUI/examples/mo_workbench` — chat-app structure in MoUI.
- `/home/chuang/orca/workspaces/MoUI/MoUI/examples/gallery` — theme + styled views.
- `/home/chuang/orca/workspaces/MoUI/MoUI/docs/view-catalog.md`,
  `docs/theme` guides, `docs/tea-program-model.md`, `docs/non-render-component-cookbook.md`.

## Runtime constraints

- Toolchain: `export PATH="/home/chuang/bin:$HOME/.moon/bin:$PATH"` (node + unzip shims live in
  `/home/chuang/bin`). Skia natives are already fetched once; first build may still take minutes.
- Project: `/home/chuang/Code/orca-moui` (standalone `moui new` project, Moui 0.9.1, linux + web).
- Do not add the MoUI monorepo as a workspace member; only published `wzzc-dev/*` deps.
- App logic stays in `app/`; `linux_skia/` and `web_wasm/` remain thin entrypoints.
- Theme is pinned dark inside the app; `--scheme` must not change the look.

## File plan

```
app/
  model.mbt        # Model, Msg, seed data, update, helpers
  theme.mbt        # orca palette + typography (single source of truth)
  view.mbt         # shell, sidebar, title bar, tabs, empty state
  view_chat.mbt    # transcript, user bubble, worked row, worker cards, composer
  view_modal.mbt   # create-worktree dialog + overlay
  view_bots.mbt    # Bots screen (phase 2)
  view_diff.mbt    # diff review screen (phase 2)
  brand.mbt        # brand icons (Claude/Codex/Grok) + status spinner
  app_test.mbt     # model/update tests
linux_skia/main.mbt  # 1280x800 window, title "Orca"
web_wasm/main.mbt    # keep working
scenes/
  hero/      moon.pkg + main? (package exposing program() with initial state)
  modal/     program() with CreateWorktree open + typed name
  bots/      program() with Bots screen active (phase 2)
  diff/      program() with diff review active (phase 2)
```

`moui screenshot --app scenes/modal` needs that package to expose `pub fn program()` returning a
`@moui.Program[...]` built from `app` model/update/view. Add `pub fn program_with_model(model)`
to `app/` so scenes can mount any state. Scene packages may import `local/orca_moui/app` and
`wzzc-dev/moui` only.

## Visual tokens (from orca.dev, exact)

Palette:
- app outer bg `#0a0a0a` (not visible), main bg `#151515`, sidebar bg `#2a2a2a`
- tab bar bg `#171717`; active tab bg `#151515`
- card / popover bg `#171717`; machine card bg `#323232`; selected worktree bg `#3a3a3a`
  (white 10% over sidebar); user bubble `#252525`
- borders: `rgba(255,255,255,0.07)` (main), `rgba(240,240,240,0.09)` (composer),
  `rgba(255,255,255,0.24)` (selected worktree), `rgba(255,255,255,0.06)` badge fills
- text: primary `#f0f0f0`, bubble `#dadada`, body `#c0c0c0`, secondary `#acacac`,
  muted `#929292`, dim `rgba(255,255,255,0.38)` ≈ `#6f6f6f` on sidebar
- accents: Claude `#D97757`, Codex `#34d399` (mint), Grok `#c0c0c0`, amber spinner `#fbbf24`,
  "Full access" `#eab308`, globe project `#60a5fa`, folder project `#f59e0b`,
  green done `#34d399`
- modal overlay `rgba(0,0,0,0.60)`

Typography (SF/Inter-like sans; mono for branch names):
- title bar wordmark 12 semibold; sidebar nav 13 medium; section header 12 semibold secondary
- machine title 12 semibold; machine count 9 medium; project name 13 semibold
- worktree name 13 regular 20px line; branch 11 regular secondary; primary badge 10 medium
- agent row 11–12; model/time 11 secondary
- chat body 14 / line-height 20; user bubble 14/20; worked row 12; card header 13; card body 14/20
- modal title 20 semibold; field label 12 secondary; field text 13; chip 12; primary button 13 medium

Geometry:
- logical screenshot/window: 1280 × 752 (screenshots at scale 2)
- title bar 36 high; sidebar 280 wide (fixed); tab strip 36 high
- sidebar nav rows 32 high, radius 8, horizontal padding 8, icon 16, gap 8
- projects header 32 high; worktree row margin 4, radius 10, padding 5/6, left inset 17
- machine card 32 high, radius 8, border 1
- main chat content max width 540, centered; top padding 16; block gap 20
- cards radius 14, border 1, padding 12; user bubble radius 14, padding x14 y10, max 80%
- composer max width 550, radius 14, border 1, padding 6; input min height 48; footer 28
- active tab max width 300; close X 14; plus 16 with 12 padding
- modal 550 wide, radius 16, padding 24; fields 40 high radius 10; primary button 36 radius 8

## Seed data (use exactly)

Sidebar:
- Nav: Search (selected row, bg white/5), Tasks (GitHub + Docker + Slack brand marks as small
  gray icon glyphs), Automations. Add "Bots" nav with a small "1 needs you" count (phase 2 screen;
  in phase 1 it may show an empty state).
- Projects header with 3 tiny icon buttons: sliders-horizontal, folder-plus, plus.
- Machine card: server icon, "Local Mac", count "1".
  - Project `acme-web` (globe icon, `#60a5fa`):
    - worktree `checkout-flow-v2`, badge `primary`, branch `feature/checkout-flow-v2`,
      agents: `Tighten address validation` (Claude, opus-5.5, 49m, running);
      `Validating EU promo codes` (Codex, gpt-6-astra, 3h, running)
- Machine card: server icon, `mac-mini`, host `mac-mini.local`, count `3`.
  - Project `acme-internal` (folder icon, `#f59e0b`):
    - worktree `eu-promo-checkout` — **initially selected**, branch `fix/eu-promo-checkout`,
      agents: `Fix ACME-412: EU promo codes…` (Claude, opus-5.5, now, running);
      `tax-rules` (Codex, gpt-6-astra, now, running);
      `promo-tests` (Grok, grok-4.7, now, running)
    - worktree `Improve agent handoff summary`, branch `feature/agent-handoff-summary`,
      agent `Drafting handoff copy` (Codex, gpt-6-astra, 12m, working)
    - worktree `Fix CI checks detail link`, branch `fix/checks-detail-link`,
      agent `Fix checks detail link` (Claude, opus-5.5, 6h, idle/done)
- Status indicators: running agents show a 8px amber spinner (static 3/4 ring is fine);
  done shows a small green dot; idle gray dot.

Initial tab: `eu-promo-checkout`, title `Fix ACME-412: EU promo codes skip regional tax`,
Claude icon, close X. It is the only open tab; `+` opens the create-worktree modal.

Chat transcript for `eu-promo-checkout` (top to bottom):
1. user bubble (right aligned): “Fix ACME-412: EU promo codes skip regional tax at checkout.
   Split it between a Codex worker and a Grok worker, and report back.”
2. worked row (full width, border-bottom): `Worked for 4s` + chevron; expanded body paragraph:
   “Started tax-rules on Codex and promo-tests on Grok. While they work, I’ll update the checkout
   changelog.” (`tax-rules`, `promo-tests` in #dadada medium)
3. worker card 1 (focused, outer border white/32 + 3px white/4 ring): header Codex icon +
   “Update from worker” + `tax-rules` + arrow-up-right icon, right “3:09 PM” + chevron up;
   body “Fixed. Promo discounts now apply after VAT for EU regions, and 11 tax tests pass.”
4. worker card 2: same with `promo-tests`, Grok icon, “3:10 PM”; body “Added 8 regression tests
   for EU10 and EU20 across DE, FR and NL. All passing.”
5. assistant paragraph: “Both workers are done. Promo discounts now apply after regional VAT,
   with 8 new regression tests. Want me to open the PR?”
6. live row: loader-circle icon + “Working…” (muted) under a `Working for 1s` divider.

Other worktrees get plausible short transcripts (1 user bubble + 1 assistant line + worker card).
- `checkout-flow-v2`: “Tighten address validation” transcript (address/P0 boxes, shipping.ts,
  validators.ts edits; use the diff reference as inspiration)
- `Improve agent handoff summary`: “Drafting handoff copy”
- `Fix CI checks detail link`: short done transcript.

Composer (bottom of chat, always visible):
- placeholder `Ask anything, @ to mention files, / for commands`
- left: plus icon; shield-alert icon + `Full access` in `#eab308` + chevron
- right: `Opus 5.5` + chevron, mic icon, 32px circular send button bg `#262626` with arrow-up
- typing works; Enter sends. Sending appends the user bubble and then (immediately or via a
  short timer subscription, whichever is simpler and robust) an assistant bubble
  “On it — I’ll report back here when the workers finish.”, and clears the field.

## Create worktree modal

Open with `+` in the tab strip or the sidebar plus buttons. Centered 550-wide card over a
`rgba(0,0,0,0.60)` overlay that dims the whole app (including sidebar):
- header `Create worktree` 20 semibold, X icon right
- row: `Project` select (acme-internal) and `Run on` select (mac-mini); labels 12 secondary
  above each; 40-high dark controls with white/8 border, radius 10, chevrons
- `Create From [Optional]` row: chips `Smart` (selected, sparkles icon), `GitHub`, `Branch`, `Name`
- search/name input 40-high with search icon, placeholder text; typing updates the name
- `Agent [Optional]` 40-high select: `Claude Code` with Claude icon
- `Advanced ⌄`; a toggle + `Create more` on the left, primary button `Create worktree ⌘↵`
  (white `#f0f0f0` bg, dark text) right
- clicking the primary button (or Enter in the name field) creates a worktree under
  acme-internal with the typed name (fallback `Speed up checkout CI`), branch
  `feature/<slug>`, one Claude agent in running state, opens its tab, closes the modal.
- X / Esc / overlay click closes without changes.

## Behavior

- Clicking a worktree row or agent row inside it selects that worktree, sets the active tab
  (opening it if needed), and shows its transcript. Selected row uses border white/24 +
  bg `#3a3a3a`.
- Tab close removes it; if it was active, activate the previous tab or show the empty state
  (`Orca` wordmark + “Open a worktree to start chatting” + hint `⌘K`).
- Tab strip shows `+`; only one tab initially.
- Sidebar nav: Search/Tasks/Automations/Bots may switch a simple section view; Projects remains
  the main screen. Phase 1 can keep Tasks/Automations as a centered “No tasks yet” empty state.
  Bots screen in phase 2.
- Window title `Orca`; app opens at 1280×800.

## Implementation guidance for MoUI

- Use `@views` constructors + chainable `View` modifiers: `.foreground(color)`, `.font(FontSpec)`,
  `.background(color)`, `.border(BorderStyle)`, `.corner_radius`, `.padding`, `.frame`,
  `.expanded(weight)`, `.on_tap(msg)`, `.mono()`, `.key("...")`, `.tooltip`.
- Layout: `column/row` (spacing, align), `expanded` for flex, `container` for backgrounds,
  `scroll_view` for the sidebar list and transcript, `stack` for overlay/modal.
- Icons: `lucide_icon("search", size=16, color=...)` — lucide names used by Orca include
  search, list, calendar-clock, panel-left, plus, sliders-horizontal, folder-plus, server,
  globe, folder, file-text, x, chevron-down/up/right, arrow-up-right, arrow-up, mic, shield-alert,
  loader-circle, sparkles, square.
- Brand glyphs: use `icon_svg("<svg viewBox=\"0 0 24 24\"><path d=\"...\"/></svg>", size, color)`
  with the path data in `design/brand-paths.txt` (Claude #D97757; Codex/OpenAI currentColor;
  Grok X currentColor). If the stroked SVG looks wrong at small sizes, use lucide equivalents:
  Claude `sparkles`/`asterisk` #D97757, Codex `hexagon` #34d399, Grok `x` #c0c0c0.
- Inputs: `text_field`/`text_area` with on_input; style via `TextFieldStyle`/`theme` if needed.
  If the stock field chrome fights the Orca look, wrap it in a styled container and hide/align
  chrome using the available style fields (check the mbti). Do not implement a custom text
  editor.
- Theme: build one `orca_theme()` in `app/theme.mbt` with palette + typography from the tokens,
  and pass `theme=orca_theme()` everywhere (or `.foreground`/`.font` per view for exact values).
  The runtime base background must be `#151515` (set root container / `Environment` theme).
- Keep all data in `Model` as plain structs/enums; update is pure; use `Program::simple` unless
  a timer is needed for the composer reply.
- Avoid per-frame state in globals; app must render identically in `moui screenshot`.

## Validation

Always export both the PATH shims and the Vulkan-off flag (this host has no libvulkan; the app
and screenshots are raster-only, and the linker must not pull the GPU path):

```sh
export PATH="/home/chuang/bin:$HOME/.moon/bin:$PATH"
export MOUI_SKIA_ENABLE_GPU_VULKAN=0
cd /home/chuang/Code/orca-moui
moon check --target native              # must pass
moon test app --target native           # new tests must pass
moon build linux_skia --target native   # must pass
moui screenshot --out docs/screenshots/orca.png --width 1280 --height 752 --scheme dark
moui screenshot --app scenes/modal --out docs/screenshots/orca-create-worktree.png \
  --width 1280 --height 752 --scheme dark
```

Open the produced PNGs with the Read tool and compare against `design/reference-*.jpg`.
Iterate on spacing/colors until the composition matches: sidebar proportions, chat column,
card shapes, composer, typography. Include both screenshots in README.md.

Tests to add (at least):
- select worktree opens/updates tab and transcript
- close tab falls back correctly
- open modal + type name + create adds worktree, selects it, closes modal
- send message appends user + assistant messages and clears draft
- worked-row toggle flips expansion

## Definition of done (phase 1)

- `moon check` / `moon test` / `linux_skia` build pass.
- Initial screen visually matches `design/reference-orchestration.jpg` at 1280×752.
- Modal screenshot matches `design/reference-create-worktree.jpg` closely.
- All listed interactions work when run natively (and web target still builds).
- README.md explains the project, how it maps to Orca, how to run, and shows screenshots.
