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
  persist.mbt      # versioned JSON save/load for durable model state
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
- card / popover bg `#171717`; machine card bg `#323232`; selected worktree bg `#404040`
  (white 10% over sidebar); user bubble `#252525`
- create-worktree dialog bg `#0a0a0a` with transparent, outlined controls
  (white 5–12% borders), matching `design/reference-create-worktree.jpg`
- Diff 左栏代码区 `#1d1d1d`（右栏 chat 仍 `#151515`），新增行 tint `#373c29`、
  删除行 tint `#491716`，均取自参考图采样
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
- chat body 17.5 / line-height 29; user bubble 17.5/29; worked row 17.5; card header 17.5; card body 17.5/29
- modal title 20–21 semibold; field label 12–16 secondary; create select/value 17.5; chip 15; Agent 18.5; primary button 16 medium

Geometry:
- logical screenshot/window: 1280 × 752 (screenshots at scale 2)
- one 36-high top row: a 340-wide title segment (traffic lights, wordmark, panel toggle),
  a 1 px vrule at the sidebar edge, then the tab strip; sidebar and main share the row below
  with their own 1 px vrule
- sidebar nav rows 32 high, radius 8, horizontal padding 8, icon 16, gap 8
- projects header 32 high; worktree row margin 4, radius 10, padding 10/12 with a 28 px
  left / 12 px right content inset so the status dot, title and branch line up under the
  project name and agent timestamps end flush at the card's right edge;
  rows span 12 px from each sidebar edge (316 wide at the default 340) and agent rows
  are 28 high with a 5 px inter-row gap (33 px pitch), matching the reference's airier
  worktree rhythm; the header, branch and agent sections are 10 px apart. At 1× the
  reference selected card is 164 px high, with its header 10 px below the top and the
  next card's header 12 px below the card's bottom edge.
- machine card 32 high, radius 8, border 1
- main chat content max width 736 (Orca's default 46rem “Narrow” column), centered;
  top padding 16; block gap 20; compact panes keep 26 px side gutters
- cards radius 14, border 1, padding 12; user bubble radius 14, padding x14 y10, max 80%
- composer shares the 736 chat column, bg `#1d1d1d`, radius 14, border 1, padding 8;
  input row 38 high, a 23 px gap, then the 40 px footer; the card is ~117 high and sits
  22 px above the window's bottom edge
- active tab max width 375 when it is the only tab and 300 once multiple tabs are open;
  completed worktrees show a 16 px done badge at ≥90 px width, the close X appears on
  hover, titles truncate at 48 characters, and the plus is 16 with 12 padding; the tab strip starts
  at the same 340 px boundary as the sidebar, so the first tab's icon lines up with it
- modal 550 wide, radius 16, padding 24; Project/Run on/Agent controls 46 high, name field
  52 high, radius 10; primary button 40×188 radius 8

## Seed data (use exactly)

Sidebar:
- Nav: Search (selected row, bg white/5), Tasks (GitHub + Docker + Slack brand marks as small
  gray icon glyphs), Automations. Add "Bots" nav with a small "1 needs you" count (phase 2 screen;
  in phase 1 it may show an empty state).
- Projects header with 3 tiny icon buttons: sliders-horizontal (toggles an inline
  Collapse all / Expand all panel), folder-plus and plus (both open Create worktree).
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
2. worked row (full width, border-bottom): `Worked for 12s` + chevron; expanded body paragraph:
   “Started tax-rules on Codex and promo-tests on Grok. While they work, I’ll update the checkout
   changelog.” (`tax-rules`, `promo-tests` in #dadada medium)
3. worker card 1 (focused, outer border white/32 + 3px white/4 ring): header Codex icon +
   “Update from worker” + `tax-rules` + arrow-up-right icon, right “3:09 PM” + chevron up;
   body “Fixed. Promo discounts now apply after VAT for EU regions, and 11 tax tests pass.”
4. worker card 2: same with `promo-tests`, Grok icon, “3:10 PM”; body “Added 8 regression tests
   for EU10 and EU20 across DE, FR and NL. All passing.”
5. assistant paragraph: “Both workers are done. Promo discounts now apply after regional VAT,
   with 8 new regression tests. Want me to open the PR?”
The conversation is finished, so it ends on block 5 — no trailing live row.

Other worktrees get plausible short transcripts (1 user bubble + 1 assistant line + worker card).
- `checkout-flow-v2`: “Tighten address validation” transcript (address/P0 boxes, shipping.ts,
  validators.ts edits; use the diff reference as inspiration)
- `Improve agent handoff summary`: “Drafting handoff copy”
  followed by the live row `Working for 1s` + loader icon (“Working…”).
- `Fix CI checks detail link`: short done transcript.

Composer (bottom of chat, always visible):
- placeholder `Ask anything, @ to mention files, / for commands`
- left: plus icon; shield-alert icon + `Full access` in `#eab308` + chevron
- right: `Opus 5.5` + chevron, 20px mic icon, 40px light `#818181` circular send button
  with a dark arrow-up
- typing works; Enter sends. Sending appends the user bubble and then (immediately or via a
  short timer subscription, whichever is simpler and robust) an assistant bubble
  “On it — I’ll report back here when the workers finish.”, and clears the field.

## Create worktree modal

Open with `+` in the tab strip or the sidebar plus buttons. Centered 550-wide card over a
`rgba(0,0,0,0.60)` overlay that dims the whole app (including sidebar):
- header `Create worktree` 20 semibold, X icon right
- row: `Project` select (acme-internal) and `Run on` select (mac-mini); labels 12 secondary
  above each; 44-high dark controls with white/8 border, radius 10, chevrons
- `Create From [Optional]` row: chips `Smart` (selected, sparkles icon), `GitHub`, `Branch`, `Name`;
  each chip seeds the dialog: Smart uses the default checkout worktree, GitHub a
  `pr/<slug>` branch, Branch a `feature/<slug>` branch, and Name starts blank so creation
  waits for a typed name.
- search/name input 52-high with search icon, placeholder text, sitting directly under the
  chips (no separate Name label); typing updates the name (the field border brightens
  while the Name source is selected)
- `Agent [Optional]` 44-high select: `Claude Code` with Claude icon
- `Advanced ⌄`; opening it reveals a `Base branch` select (`main` → `develop` →
  `release/next`, cycled by clicking) plus a one-line base hint. At viewport heights below
  680 px the control shrinks to a 26-high row and the hint is omitted so the dialog still
  fits. A toggle + `Create more` on the left, primary button `Create worktree ⌘↵`
  (white `#f0f0f0` bg, dark text) right; with the Name source selected but the field blank,
  the button dims and a `Type a name to continue` hint appears under the field
- clicking the primary button (or Enter in the name field) creates a worktree under
  acme-internal with the typed name (fallback `Speed up checkout CI`), branch
  `feature/<slug>`, one Claude agent in running state, opens its tab, closes the modal.
- X / Esc / overlay click closes without changes.

## Behavior

- Clicking a worktree row or agent row inside it selects that worktree, sets the active tab
  (opening it if needed), and shows its transcript. Selected row uses border white/24 +
  bg `#404040`.
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

## 实现状态 (2026-11-24)

已实现：
- Phase 1：Projects 工作树侧栏、tab 条、聊天 transcript、composer、Create worktree 弹窗，
  以及新建/关闭 tab、发送消息、Worked 行展开。
- Phase 2：Bots 三栏屏（默认 272 侧栏 + Scout 会话 + 默认 400 事项面板 + 24 状态栏），
  bot/会话选择、中心与右栏 tab、按 bot 隔离的评论追加与 flag 切换。
- Phase 3：Search / Tasks / Automations / Diff 四页，均有独立 scene 与验收截图。
  - Search：实时查询、All/Worktrees/Bots/Sessions/Files 过滤、建议词、清空、结果跳转、空状态；
    Files 分类检索 8 个种子源码文件并跳转到所属 worktree。
  - Tasks：状态/来源筛选与动态计数、任务搜索、行选中、详情、New task（内联命名）、
    Mark done / Reopen、详情描述多行就地编辑、工作树关联/换绑/解绑，以及从选择器
    创建工作树并自动关联。
  - Automations：enable 开关、Run now、New automation 编辑器（名称/计划/项目）、
    Edit、Delete、最近运行 Show all / Show less。
  - Diff：三个文件 tab 切换、行选中、按行与 Shift 扩展范围 note 线程、
    note 编辑/重发/删除、AI notes 计数、Approve / Request changes。
- 交互：侧栏可折叠（Projects 与 Bots 两套标题栏的 panel 按钮）、拖动分隔线调整
  Projects 与 Bots 侧栏宽度（均为 220–380 px，Bots 会话标签随宽度省略）、
  Bots 右栏宽度（320–480 px，窄于 360 px 时 tab 只显示图标）、
  机器/项目可折叠、列表行 hover、
  tab 条左侧 ←/→ 历史导航（⌘[/⌘]）、
  ⌘K/⌘↵/⌘W/⌘P/⌘B/⌘1–9/Esc 快捷键、create-more 连续创建。
- 右键交互：worktree 行打开 Open worktree / Show diff / Rename worktree / Close tab /
  Delete worktree 菜单；Rename 打开 440 px 名称弹窗（`↵` 保存、`Esc` 取消），
  Delete 先弹确认，确认后关闭 tab、清除指向它的任务链接并写入删除记录；
  Tasks 行打开 Open task / Mark done（Done 行为 Reopen task）菜单，点空白或 Esc 关闭。
- Search 结果默认选中首条，↑/↓ 移动选中行，`↵` 打开选中项；worker 卡片可点击移动
  focused 白环。Projects 在没有打开 tab 时发送不会清空草稿。
- Bots 中心 composer 发送会把消息写入当前 bot/会话的 transcript（按 bot+tab+session 隔离）；
  Bots 右栏 Files tab 列出种子文件索引、按路径/项目/摘要/内容实时过滤并跳转所属 worktree；
  Bots tab 条与状态栏底色对齐参考图 `#181818`。
- Bots 侧栏 header 全部可交互：chevron 收起/展开 bot 列表，搜索过滤 bot 名称/摘要，
  sliders 切换 Show sessions，plus 新增并选中 bot；Projects disclosure 的 sliders
  跳到 Projects 并打开显示选项面板，folder-plus/plus 打开 Create worktree。
- Bots 中心 tab 跟随当前 bot（头像 + 名称），只有 Scout 显示 `#eng` 第二个 tab；
  Escape 关闭 Bots 过滤框与显示选项面板。
- Create worktree 的 Agent 行可点击循环 Claude Code → Codex → Grok，新建 worktree
  的 agent 与 setup worker 使用所选厂商和模型（opus-5.5 / gpt-6-astra / grok-4）。
- Create worktree 的 Project/Run on 可点击循环 acme-internal/mac-mini ↔ acme-web/Local Mac，
  新建 worktree 落入所选项目；两个 composer 的 access chip 循环 Full access / Ask before
  edits / Read only，model chip 循环 Opus 5.5 / GPT-6 Astra / Grok 4。
- Diff 的 tab 条 `+` 打开第四个 `handoff.md` diff；Bots tab 条 `+` 打开 Create worktree。
- `moon check --target native` 0 错误；`moon test app --target native` 39/39；linux_skia 与
  web_wasm 构建通过；8 张 2560×1504 截图可由 `scenes/*` 复现。

## 2026-11-25 更新

- Chat/composer 宽度从 540/550 改为 736：对照真实 Orca 源码
  `NativeChatTranscriptColumn` / `native-chat-appearance-style.ts`，默认 “Narrow” 为 46rem
  (736 px)，参考图 chat 列约占 main pane 79%，原 540 会留下过宽的空档。
- Hero seed 对齐参考图：`Worked for 12s`；移除已完成会话末尾矛盾的 `Working for 1s`，
  把 live row 移到仍在运行的 handoff 会话。
- Tasks 增加真实搜索框（标题/仓库/标签/描述/worktree），过滤后详情选中项自动回落到
  首个匹配项且列表高亮同步回落；任务详情使用 worktree 的真实分支，Done 任务的 agent
  显示 `finished` 而不是 running；New task 内联编辑器可循环选择来源
  (GitHub/Linear/Slack) 与 agent (Claude Code/Codex/Grok)，新建任务记录所选来源与型号。
- Automations 的 New automation 改为 550px 编辑器弹窗（名称、计划、项目、⌘↵ 保存）；
  选中行下方增加 Edit / Run now / Delete 操作条；Recent runs 支持 Show all / Show less；
  点击 run 行会选中其所属 automation；automation 增加 `schedule_index`，编辑种子数据时
  保留原计划（不再静默重置为 Manual）；修正 sparkles 图标缺失（lucide 子集没有该图标，
  改用内置 SVG）。
- Diff note 卡片三个图标全部接通：send 重发 note 给 worker、pencil 把 note 填回 composer
  编辑（再次发送原地替换，不重复）、x 删除该行 note 并收起卡片；↑/↓ 在当前文件内移动
  选中行（越界钳制），Escape 关闭已打开的 note 卡片。
- Bots 选中卡片的 `more` 图标打开 fleet options 面板，与 header sliders 按钮一致。
- Bots 中心 tab 的 X 可真正关闭：关闭 Scout 回退到 `#eng`，两者都关闭时显示
  “No chat open” 空状态；点击侧栏 bot 或 session 会重新打开聊天 tab。
- Bots 右栏 **Chats** tab 不再是空状态：列出当前 bot 的会话、标注类型与时间，点击行
  会选中并打开对应聊天。
- Bots 右栏可通过标题条 panel 按钮折叠为 48px 图标 rail；Home / Connectors / Chats / Files
  四个图标保留当前选中态，点击任一图标重新展开并切到该 tab。
- Bots 右栏 **Connectors** tab 改为真实面板：Slack / Linear / GitHub / Gmail 四行可展开，
  展示用途说明与 Connected / Not connected 状态，可 Connect / Disconnect；标题右侧
  实时显示已连接数量。`Show sessions` 选项整行可点击，不再只点开关。
- Tasks 详情描述可编辑：铅笔按钮打开 4 行多行输入框，Save / `⌘↵` 保存，Cancel / `Escape`
  取消；空白保存会写入 “No description yet.”，切换任务时自动退出编辑。
- Diff 支持 Shift+↑/↓ 扩展选区：note 覆盖整段行范围，卡片标题显示 `Note lines 24–28`，
  范围内行带淡边框；普通 ↑/↓ 或点击行会收拢为单行选区。
- Create worktree 主按钮的 `⌘↵` 提示色改为 `#4A4A4A`，在白色按钮上更清晰；
  `Create more` 标签与开关整行可点击。
- Bots 侧栏底部的 settings / help / clock 三个图标接通：settings 打开 fleet options，
  help 打开居中的快捷键帮助弹窗（Esc 或点击外部关闭），clock 跳到右栏 Chats；
  帮助弹窗列出全局快捷键与 Diff 范围选择提示。
- Diff 工具栏的 split/columns 图标接通为 focus 模式：隐藏右侧 chat、diff 占满窗口，
  再次点击或 `Escape` 恢复 50/50；focus 时图标改为 minimize。
- Diff 文件 tab 的 X 可真正关闭：至少保留一个 tab，关闭当前文件时自动切到下一个打开
  的文件；`+` 仍可重新打开 `handoff.md`。测试增至 51/51。
- 响应式宽度：Bots 三栏在窄窗口按比例收缩（侧栏 ≤30%、右栏 ≤32%、中间 ≥300 px），
  chat 内容列夹紧到 736 px 上限，Tasks 列表与 Automations 指标/表格列按可用宽度缩放。
  拖动得到的宽度作为偏好保留，窗口变宽后自动恢复。测试增至 53/53。
- Projects 外壳对齐参考图：侧栏 340 px，导航/项目/机器卡片与 worktree 行统一为
  16 px 外边距（内容 16–320），标题栏沿用侧栏 `#2a2a2a`，tab strip 使用 `#151515`。
- Bots 每个 bot 都带有 2–3 个会话（CI Watch、Review buddy、Release notes、Standup、
  Docs helper），切换后侧栏会话列表、右栏 Chats 面板与中心 tab 不再为空；fleet 过滤
  同时匹配会话名。测试增至 55/55。
- Create worktree 弹窗按参考图改为近黑底 `#0a0a0a`，Project/Run on、Agent 与 Name
  控件改为透明填充 + 细边框，弹窗整体亮度与参考图 960×600 的逐行采样一致。
- Diff 左栏按参考图改为 `#1d1d1d`，激活文件 tab 与代码区同色；新增/删除行改用
  采样得到的 `#373c29` / `#491716`，取代原先的绿色/红色半透明叠加。
- 键盘选择贯通列表页：Tasks 用 ↑/↓ 在过滤后的任务间移动（越界夹紧），Automations
  用 ↑/↓ 移动表格选中行，Bots 在 fleet 展开且未打开过滤框时用 ↑/↓ 切换 bot 并打开
  其 Home 面板；输入框/编辑态不拦截方向键。帮助弹窗文案同步为 “lists or diff lines”。
  测试增至 56/56。
- Bots 右栏 Files 增加实时过滤（匹配路径、项目、摘要或代码关键词）、
  `x of y indexed source files`
  计数与 “No files match this filter.” 空态；过滤后的行仍可打开所属 worktree。
  测试增至 57/57。
- 弹窗与帮助层按视口收敛：Create worktree / Automation editor 宽 550 或
  `viewport - 32`（内容宽随之缩短，两个 select 等分，chips 按可用宽度夹紧），
  快捷键帮助卡宽 460 或 `viewport - 32`；960×600 下尺寸不变，500×600 与
  400×600 下无裁切。测试增至 58/58。
- 清理 Bots 标题栏未使用的 `model` 参数与弃用的 `StringView::to_string` 调用。
- 窄窗重排：窗口窄于 720 px 时，Projects/Search/Tasks/Automations 的侧栏改为可点击
  关闭的抽屉叠层，主内容占满窗口宽度；Tasks 窄于 640 px 时列表与详情改为单栏切换，
  详情页带 “Back to tasks”，来源过滤与新建任务控件改为纵向堆叠。Bots 窄于 760 px
  时 fleet 变为抽屉、右栏改为至多 `window - 64` 宽的覆盖层，48 px rail 保留，且
  sidebar 与右栏同时打开时优先显示 sidebar。Diff 窄于 720 px 时左右栏改为上下
  各半堆叠，工具栏与 composer 保持全宽。Bots 右栏另有 `⌘⌥1–4` 直达 Home /
  Connectors / Chats / Files。测试增至 61/61。
- Bots 中心 tab 条补齐极窄宽度：compact 标题栏省略 wordmark（208 → 124 px），tab 条按
  优先级先收起 `#eng`、前进/后退箭头，再压缩 bot tab，保留关闭 X 与 `+`；tab 标题改为
  固定宽度裁剪容器，长标题不再把 X 推出 tab 之外。320/360/480 px 下 X、`+` 与右栏
  rail 均不重叠，1280 px 截图同步重渲染。
- Bots 右栏作为抽屉时在 360 px 以下切换 Home 紧凑卡片：item 标题与 Activity 文案使用
  裁剪容器，chips 每行一个，Done means 改为整行换行；400 px 以下状态栏收起第二个
  usage meter，使机器名与 host 数保持在窗口内。新增 `scenes/bots_panel_narrow` 与
  960×1200 验收截图。
- Create worktree / Automation 编辑弹窗在内容列窄于 320 px 时改为纵向 footer：
  primary action 与 Create more / Cancel 分行，name 输入框收窄，automation 的
  Schedule / Project 两个 select 改为整行排列，320 px 下不再越过卡片右缘。
- Projects/Search/Tasks/Automations 的窄窗外壳同步补齐：compact 标题栏 208 → 124 px，
  tab 条箭头/加号按宽度收起、worktree tab 在 300 px 内均分并裁剪长标题；页面标题在
  520 px 以下省略副标题，420 px 以下过滤 pill 改用短标签（Mine / Needs / Trees /
  Chats），搜索建议在 360 px 以下再收起机器 chip。320/400 px 下页头按钮、搜索框、
  过滤行与 tab 关闭按钮均完整可见。
- Search 结果行在窄窗内改为按行宽计算标题/副标题的裁剪宽度：620 px 以下不再使用
  固定 470 px 标题，300 px 以下收起右侧 metadata，420 px 以下再收起选中行的 `↵`
  标记；320 px 下选中行、标题与空状态均不越出页面。
- Automations 在 560 px 以下切换为堆叠行：名称与 schedule/status 两行、右侧 enable
  开关，隐藏表头与 schedule/last-run/status 列；选中行下方改为紧凑的 Edit / Run now /
  Delete 文本按钮，metric 卡片去掉装饰图标并在 420 px 以下使用 Runs / Passed / Needs
  短标签。卡片在 320 px 下仍保持左右 32 px 边距。
- Automations 的 metric / list / recent-runs 卡片共用预留 28 px 内边距的内容宽度，
  宽窗下也不会让 list card 越过 32 px 右 gutter；表头列宽与行内 icon、文字列和间距
  使用同一组计算，560 px 以上即可完整容纳 Automation / Schedule / Last run / Status。
- Tasks 列表行在 520 px 以下按行宽重算标题宽度：标题与 repo/labels 行使用裁剪容器，
  状态 pill 始终保留，时间戳在 380 px 以下收起；320/480 px 下长标题与 metadata
  均不越过列表右边界。520 px 以上也使用同一公式计算标题宽度，避免中宽窗口下时间戳
  侵入列表右侧 padding。
- 新增版本化 JSON 持久化：`app/persist.mbt` 保存任务状态/详情、automation 开关/
  运行/编辑/删除、diff notes 与 verdict、bot 评论与聊天、新增 bot、新建/重命名/删除
  worktree 及其 transcript（删除写 tombstone，避免种子行在重启后复活）、connector
  开关、折叠的 machine/project 行、侧栏宽度、composer
  的 access/model 选择、当前 bot session 与 center/panel tab、bot chat / `#eng` 打开
  状态及 Show sessions 显示偏好；原生入口
  在每次提交后写入 `~/.orca-moui-state.json`（或 `MOUI_DEV_STATE_FILE`），启动时
  恢复；web 入口通过 settings 服务写入浏览器 localStorage 的 `orca-moui.state`。
  弹窗、草稿、搜索/过滤等瞬时状态不落盘，损坏或版本不匹配的 payload 回退到种子
  模型。测试增至 app 72/72、web_wasm settings 1/1。

- 空状态可操作：Projects 无 tab 时提供 New worktree / Search 按钮；Search 无结果时
  提供 Clear search；Tasks 列表与详情均提供 Clear filters，重置状态/source/搜索条件。
  Search 下 `Escape` 会连同 category filter 一起清空；compact 宽度下 `Escape`
  关闭 Projects/Bots sidebar drawer 与 Bots item-panel drawer。
- Diff composer 的 Full access 与 model chip 与 Projects composer 一样可循环切换。

## 2026-11-26 更新

- 对照 `design/reference-orchestration.jpg` 重新采样两处颜色：composer 卡片改为
  `#1d1d1d`（原先 `#171717` 与 chat 背景同色、卡片看不见），选中 worktree 底色改为
  `#404040`（即 white 10% over `#2a2a2a`；原先 `#3a3a3a` 偏暗）。
- worktree 行内容增加 28 px 左内边距，状态点/标题/branch 与项目名对齐；960 px 参考窗口
  下标题约 x57、branch 约 x58，与参考图一致。
- 侧栏拖到 220 px 时 agent 行自适应：名称裁剪从 17 字符降到 12/10，并在 < 260 px 时
  收起模型 token，时间戳仍留在卡片内；新增回归测试，app 73/73。
- 19 张验收截图全部重新生成；QA 中 2560×1504 截图数量由 12 修正为 11。
- composer 卡片改为 8 px 内边距 + 输入行与 footer 之间 18 px 间隔，卡片约 113 高、
  距窗口底边 18 px；`composer_height` 同步为 147（原先 136 会把卡片挤出窗口）。
- worktree 行右内边距由 6 px 增到 12 px，agent 行时间戳右端落在约 x316（960 逻辑窗口、
  340 侧栏），与参考图一致；内容宽度改为 `width - 40`。
- 补齐指针 hover 反馈（只影响交互，静态截图不变）：diff 文件 tab、`+`、verdict 与 send，
  composer send、bots 会话行/其他 bot 卡、modal 下拉与 chip、Create 按钮、对话框按钮，
  以及 Projects/Bots 的 panel-toggle 都会随 `Hover` 状态提亮；新增 hover 行为回归测试，
  app 测试 76/76。
- 任务详情的 Activity 行不再写死一份种子文案：首行取任务来源，第二行取 worktree 链接
  状态，第三行取 agent 与状态（review / running / finished），时间戳按任务同步时间错开
  （`task_activity_stamps`）；链接卡与 Save/Cancel/Back/Open/Mark done 按钮也带 hover。
- 标题栏的 ←/→ 历史箭头只在确有历史时才占位；空历史时不再保留两个禁用按钮，worktree
  tab 的完成徽标/agent 图标回到侧栏 vrule 旁（960 下徽标起点 x≈356，参考图 x≈352），
  标题起点 x≈396（参考 x≈397）。
- Create worktree 弹窗按参考图重排中段：去掉单独的 Name 标签，name 输入直接跟在 chips
  下方；Project/Run on/Agent 控件改为 46 高、name 字段 52 高、主按钮 188×40，Advanced
  与 footer 间距重算后，Project/Create From/chips/Agent/Advanced/按钮的纵向误差均在 4 px
  内。字号同步为 header 21、select/字段值 17.5、chip 15、Agent 标签 18.5、按钮 16。
  Name 源未填写时主按钮降低对比度并显示 `Type a name to continue`。
- Diff 右栏对照参考图修正配色与结构：context bubble 改用 `#252525` 并把
  `File: …` 行移入卡片顶部（原先浮在卡片上方），note 卡片底色改为 `#212121`；
  Approve / Request changes 只在 run 停止后出现（参考图 `Working for 7s` 状态下没有这排
  chip），stop 后出现的行为有回归测试。
- Diff composer 与 Projects composer 统一：卡片底色 `#1d1d1d`（原先 `#171717`），
  输入行与 footer 间隔 9.5 px，卡片约 113 px 高、距窗口底 23 px（整块 136 px），并移除了
  参考图中不存在的底部 breadcrumb。
- Diff 工具行增加 14.5 px 间距、`Working for 7s` 行前留 16 px，使行距与参考图一致；
  左侧代码区改为可滚动（note 卡片撑高时不再被裁掉），窄窗口堆叠比例改为 60/40，
  480×600 下 note 卡片完整可见。新增回归测试，app 测试 77/77。
- Bots 标题条去掉中间的 ←/→ 历史箭头：参考图的中心 tab 条从侧栏边界直接开始，
  去掉后 Scout tab 起于 x≈277、`#eng` 起于 x≈427、`+` 约 x≈645，与参考图的
  286/430/650 基本重合；箭头仍保留在 Projects tab 条。
- 文件索引从“只匹配路径/项目”升级为真实内容搜索：每个种子文件带一行摘要和索引
  代码关键词，Search 的 Files 类别与 Bots 右栏 Files 过滤都会匹配摘要/内容；文件
  命中行的副标题显示摘要（如 `acme-web · Safari first-tap Pay fix`），输入
  `pointerdown`、`EU10`、`postalPattern` 都能命中对应文件。新增两条回归测试，
  app 测试 78/78；新增 `scenes/bots_files` 与 `docs/screenshots/bots-files.png`
  展示内容筛选结果。
- Automations 顶部的 Runs today / Passed / Needs attention 不再是写死数字：新增
  `automation_runs_today` / `automation_passed_today` / `automation_attention_today`
  三个持久化计数器，Run now 会累加 runs/passed，成功率由两者计算并四舍五入；
  删除 automation 不回退历史计数。回归测试覆盖 Run now 后的计数与持久化恢复。
- Search 支持 `@` 文件作用域：`@checkout` 只返回匹配文件并把 Files 类别自动选中，
  删掉 `@` 会恢复之前的类别；实现为 `search_file_scope` + `SearchInput` 的过滤切换，
  新增 `scenes/search_files` 与 `docs/screenshots/search-files.png` 展示仅文件结果。
- Tasks 的 “Assigned to me” 不再借用 agent 字段：`Task` 新增持久化 `assignee`，
  种子任务分别属于 you / Maya / Liam，筛选按 `assignee == "you"`，详情 Activity 增加
  “Assigned to …” 行；新任务默认归给 you，旧 payload 缺字段时按原 agent 语义回退。
- Automations 的 `↑ 4 vs yesterday` 改为派生值：新增持久化 `automation_runs_yesterday`，
  `automation_runs_delta_label` 在正/零/负三种情况下分别输出 `↑ N` / `No change` /
  `↓ N`，Run now 会同步推高当日差值。
- Bots 右栏 Home 的 Chat 行现在是真实入口：点击 Home Chat 会打开该 bot 的 Home
  session（`SelectBot(home_session_id)`），Home 面包屑同样可点，并带 hover 反馈。
- 新建 bot 还没有 work item 时，Home 面板不再只显示 “No item selected”：改为
  “No active item” 空状态并提供 **Open Home Chat** 按钮，直达该 bot 的 Home session。
- 新建 bot 的首条消息会创建真实 work item：标题取消息前 38 字（长文带省略号），
  编号从 `#43` 递增，状态 `In progress`，meta 标记 `Item N · Home Chat · now`，
  带 Follow up / Home Chat chips、Done means 与 Add / Worker-started 两条 activity；
  bot 同时切到 `1 working`。item 与下一个编号写入 JSON，重启后保留。
- Bots 中心 transcript 的纵向节奏按参考图重新对齐：正文行高 20→22 px、工具行
  24→29 px、prose 行距 0→7 px、`Worked for` 行上方留 3 px 且分隔线间距 10 px；
  右栏 Home 顶部 padding 23→18 px，并在 Activity 前补 5 px，使标题、状态、chips、
  Done means、Activity 与参考图逐项落在 ±2 px 内（OCR 实测）。
- 紧凑 Automations 的 Edit / Run now / Delete 与 Bots 右栏 comment 发送按钮补齐
  hover 反馈（浅色高亮），与其余页面的按钮行为一致。
- Bots 两栏默认宽度对齐参考图：侧栏 272→285 px，item 面板 380→385 px；分隔线落在
  x≈285 / 面板起点 x≈894，中心正文 x≈309，与参考图逐项重合。nav 行间距 2→1.5 px，
  Tasks / Automations / Bots 头部纵向误差收敛到 ≤1.3 px。README、QA、PHASE2 与相关
  测试同步更新，Bots 四张截图重新生成。
- Automations 状态保持自洽：关闭正在运行的 “Flaky checkout watcher” 会把 `last_run`
  从 `Running now` 改为 `Stopped · just now`；再次启用不会谎称仍在运行。对
  `Needs attention` 的 automation 执行 Run now 成功后，当日 attention 计数减一；
  新增回归测试，app 测试 80/80。
- Projects composer 按参考图重新采样（Round 14）：卡片 117 px 高、距窗口底边 22 px；
  输入行 38 px、与 footer 间隔 23 px；placeholder 18 px、access 与 model 标签 15 px，
  plus/mic/shield/chevron 同步放大。send 由 32 px 深色圆改为 40 px 浅灰 `#818181`
  圆 + 深色 arrow-up，footer 左/右内容位置与参考图误差收敛到 ≤3 px（OCR 实测）。
  `composer_height` 由 147 改为 155；1280×752 截图同步重生成。
- Diff 右栏 composer 同步按参考图重排：960 下卡片 436 宽、约 113 高、距底 23 px，
  placeholder 18/28 两行并在窄栏自动截短，footer 标签 15 px、plus/mic/shield/chevron
  放大；send 保留参考图的 30 px 深色圆。Diff 整块高度 113→136。diff.png /
  diff-narrow.png 重新生成。

## Round 25 布局收尾（2026-11-26）

- Projects tab 宽度按参考图分档：单个 tab 上限 375 px，多 tab 时每个上限 300 px；
  完成 worktree 在 tab ≥90 px 时显示 16 px done badge，关闭 X 仅在 hover 出现，
  标题按 48 字符截断。相关常量与行为由 `tab_strip_max_width` /
  `tabs_show_status_badge` 测试覆盖。
- Bots 中心 tab 条固定为 383 px：bot Home 143 px、`#eng` 196 px；右栏默认 385 px。
  两处分隔线均为 1 px 可见线 + 9 px 透明拖拽热区，hover 时线提亮，拖拽分别夹紧在
  220–380 / 320–480 px。
- 固定宽度文本列统一改用 `clip_left` / `align_right` 两个布局 helper，修复 Search
  窄版标题、Tasks compact 副标题、Automations compact 行名、Bots Files 路径和 recent
  run 时间被居中/裁切的问题；`align_right` 用于时间与 metadata 的右对齐。
- Automations 表格列宽改为按行内容宽度 `row_w - 28` 计算，表头补 28 px 左内边距，
  `Automation` / `Schedule` / `Last run` / `Status` 与行内 name / schedule / run dot /
  toggle 逐列对齐（OCR 实测误差 ≤3 px）。
- Diff 在 960×600 参考尺寸下逐项复核：File / Line / comment、`Working for 7s`、
  两行正文、Read shipping / Edited validators、`Working…`、composer 与 footer 均落在
  参考图 ±3 px 内；1280×752 下正文单行导致后续行上移是响应式换行，不额外补偿 padding。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 82/82，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia` / `moon build web_wasm` 通过，`moon fmt --check` 与
  `git diff --check` 通过；21 张验收截图重新生成。

## Round 26 交互与溢出修复（2026-11-26）

- Worktree 右键菜单 reducer 修正：Open / Show diff / Rename / Close tab / Delete 五项
  都映射到各自动作，Rename 与 Delete 不再误落到 Close；回归测试覆盖五个菜单项。
- Diff 聊天头接通：`x` 与工具栏的 split/focus 图标一样把 diff 展开到全窗口，`+`
  打开 Create worktree 弹窗，两枚图标都有 hover 反馈。
- Search 命中行 hover 改为按行生成 ID（`search-hit-{index}`），同一 worktree 的多个
  命中不再一起高亮；Files / Bots / Sessions 各组仍只亮当前行。
- `page_header` 新增 `actions_width`：标题列按剩余宽度裁剪，右侧 action 因此真正
  右对齐。Search 预留 128 px、Tasks 预留 104 px、Automations 按 70/148 px 分档；
  960 与 800 下 Search / Tasks / Automations 的 action 均落在页面右内边距内，Search
  在 <680 px 时副标题自动去掉 “across every connected machine”。
- Automations 表格尾部 toggle/status 固定为 60 px，三个文本列按 `row_w` 缩放并
  `clip_left`；选中行 Edit / Run now / Delete 预留 294 px，summary 只使用剩余宽度，
  960 与 800 下 Delete 不再画出卡片右边缘。
- Bots 窄 item panel（<360 px）的长标题改为两行换行，activity 标签继续裁剪，避免
  单词被从中间切断；相关断点由 `bots_panel_title_wraps` 覆盖。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 82/82，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia` / `moon build web_wasm` 通过，`moon fmt --check` 与
  `git diff --check` 通过；21 张验收截图重新生成。

## Round 27 参考图对齐与 320 px 弹窗修复（2026-11-26）

- Bots 选中态按参考图改为只包住 bot 头部：46 px 高、`white/10` 填充、`white/24`
  边框、10 px 圆角；嵌套会话移到侧栏背景上并以 21 px 缩进排列。实测选中填充区为
  y 389–478 px，参考图为 y 389–480 px；会话行与后续 bot 卡保持原有 50 px 节奏。
- Create From chips 新增 `modal_chips_stack`：内容宽度 <360 px 时改为 2×2 网格，
  每枚宽 `(content_w - 8) / 2`；320×600 下 Smart / GitHub / Branch / Name 四个标签
  完整可读，不再出现 `GitHu` / `BrancT` 截断。宽布局仍保持 80/88/89/80 px 单行。
- 回归测试覆盖 359/360 px 断点与 320 px 下 116 px 的 chip 宽度；新增 320×600
  Create worktree 验收截图。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 83/83，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia` / `moon build web_wasm` 通过，`moon fmt --check` 与
  `git diff --check` 通过；受影响的 Bots 截图与新窄版弹窗截图重新生成。

## Round 28 Diff 工具栏参考图对齐（2026-11-26）

- Diff tab strip 从 top=8 移到 top=0，标签文字实测 y 14.5–33 px，对齐参考图
  y 15–33 px；右侧聊天标题与 close/+ 保持 y 14.5–32.5 px。
- 工具栏路径列改为 `diff_toolbar_path_width`：480 px 窗格返回 180 px（原 214），
  路径 18 px、长路径按 21 字符截断（窄于 150 px 时截 13 字符），路径文字实测
  x 17–201 px，参考图 x 17–197 px。
- AI notes pill 去掉多余 spacer 后落在 x≈211（参考图 x 206–344），标签起点
  x≈215 与参考图 x 215 一致；前部 sparkles 由 amber 改为参考图的 violet
  (`#A78BFA`)，并在 ≥470 px 时补上参考图右侧的灰色 sparkles，pill 填充宽
  136 px（参考 138 px）。
- 右侧 hunk 控件改为独立子行：≥470 px 时控件间距 18 px、工具栏右内边距 25 px；
  实测 up/down/focus 分别落在 x 376–384、409–417、440–453，参考图为
  377–388、410–421、441–455。窄窗格回退到 10 px 间距与 20 px 内边距，避免与
  pill 碰撞。
- 回归测试覆盖 `diff_toolbar_path_width` 的 480/960/400/360 px 取值；
  `moon test app --target native` 84/84。
- 门禁：`moon check --target native` 0 errors（727 warnings），
  `moon check --target wasm-gc` 0 errors，`moon test app --target native` 84/84，
  `moon test web_wasm --target wasm-gc` 1/1，`moon build linux_skia` /
  `moon build web_wasm` 通过，`moon fmt --check` 与 `git diff --check` 通过；
  `docs/screenshots/diff.png` 与 `diff-narrow.png` 重新生成。

## Round 29 补全 Composer 与空态交互（2026-11-27）

- Projects composer 新增 `/` 命令补全与 `@` 文件补全。`/` 只在首个 token 尚未结束时
  提供 `/review`、`/test`、`/fix`、`/explain`、`/summarize`；`@` 匹配最后一个未完成
  的 mention，按路径、项目、摘要过滤 8 个种子文件，选中后保留 mention 前缀并写入
  完整路径。两条规则集中在 `composer_menu`，Projects、Bots、Diff 三个 composer 共用。
- 菜单关闭时仍保持原 155 px Projects composer 带；打开时按
  `47 + 42 × suggestions` 在卡片上方预留空间，聊天区相应缩短，避免弹层盖住输入卡。
  Bots 与 Diff 分别用 `bots_composer_menu_height` / `diff_composer_menu_height`
  接入同一高度计算。
- composer 的 plus 按钮不再是装饰：它把 `@` 追加到当前草稿末尾并立即打开文件补全；
  三个 composer 都带 plus hover 反馈，且宽度与旧图标一致，关闭态截图逐像素不变。
- Search 的 `@` 文件作用域改为记住进入前的类别：输入 `@` 时保存当前 filter，
  删除 `@` 时恢复，清空搜索时一起归零；新增 `search_filter_before_scope` 回归测试。
- 关闭状态的 automation 现在真正不可运行：`RunAutomation` 在 `enabled == false` 时
  直接返回模型，宽/紧凑布局的 Run now 都切换为灰色 inert 按钮；测试覆盖“不新增 run、
  不改 last_run”。
- Diff 文件 tab 的关闭规则收紧为“至少保留一个”：
  `diff_tab_closable(model, index)` 同时检查索引、已关闭状态与 `diff_file_count > 1`，
  最后一个 tab 的 X 变暗且不挂 `CloseDiffFile`；越界与已关闭索引也返回 false。
- 空态点击不再挂在 `Noop` 上：Tasks 未链接 worktree 的卡片不再有 hover/点击态；
  Bots Home 在没有 Home 会话时，面包屑、Chat 行与 Open Home Chat 按钮全部 inert，
  有会话时仍分别打开对应 session。
- 新增 `scenes/composer_commands` 与 `scenes/composer_mentions`，README 增加
  `docs/screenshots/composer-commands.png` / `composer-mentions.png`；全部 24 张
  验收截图按既有尺寸重生成。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 87/87，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 30 键盘补全与菜单关闭（2026-11-27）

- Composer 补全菜单支持键盘选择：`↑`/`↓` 在建议项之间循环移动，高亮行由
  `composer_pick` 驱动；鼠标进入某行也会同步高亮。打开菜单时 `composer_accept_index`
  把 Enter 解析到当前高亮项，没有高亮时落到第一项。
- Enter 不再把未完成的 `/rev` 或 `@check` 原样发送：Projects、Bots 与 Diff 的
  text field 在菜单打开时把 `on_submit` 改为 `ComposerPick` / `DiffComposerPick`，
  插入完整命令或路径并保留 mention 前缀；菜单关闭后仍走原来的 `Send` / `DiffSend`。
- Escape 可关闭补全菜单而不删除草稿：新增 transient 的
  `composer_menu_closed` / `diff_composer_menu_closed`，`composer_menu_active` 与
  `diff_composer_menu_active` 统一供视图、高度预留、键盘处理和提交路径使用；
  再次输入会重新打开菜单。这些 transient 字段不进入 JSON 持久化。
- 菜单标题提示改为 `↑↓ select · Enter insert`（窄宽度退化为 `↑↓ · Enter`）。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 90/90，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 31 页面级 Enter 与输入保护（2026-11-27）

- 新增 `enter_page_action`，在补全菜单之后统一处理页面级 Enter：Search 打开当前选中结果，
  Tasks 打开选中任务详情，Automations 打开选中自动化编辑器；没有匹配项时保持 `Noop`。
- Search 的 `↵` 不再依赖搜索框焦点：点击筛选/建议词或移动选择后直接按 Enter 仍能打开
  当前结果。Tasks 新建任务输入框打开时页面级 Enter 保持 inert，由输入框自己的
  `AddTask` 提交，避免同时打开任务详情。
- 模态框、重命名/删除确认、帮助卡、右键菜单与自动化编辑器打开时页面级 Enter 不穿透；
  `⌘↵` 仍由原有快捷键分支处理。
- 帮助卡新增 `↵ Open the selected result or row`，窄卡片使用更短文案避免截断。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 92/92，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 32 筛选选择与草稿归属修复（2026-11-27）

- Tasks 新增 `settle_task_selection`：状态/来源筛选或搜索导致当前任务不可见时，选中行
  回落到第一条可见任务，并清除仍指向旧任务的详情编辑草稿；若当前任务仍可见则保留编辑。
  Mark done / Reopen 也会重新归一化选择，避免详情面板显示 B 行却把草稿保存到 A 行。
- 打开 **New task** 时切回列表、关闭详情面板并退出描述编辑，保证窄宽度下新建输入框
  立即可见；Tasks 下 `Escape` 会先取消描述编辑，再关闭新建任务 composer。
- Diff 文件切换修复草稿归属：`SelectDiffFile` 对已关闭、越界或当前已选中的 tab 保持
  no-op；切换到另一个文件、通过 `+` 打开 handoff，或关闭当前文件并回退时，关闭 note
  卡片并清空草稿，避免给 A 文件写的 note 被发送到 B 文件。关闭非活动 tab 不影响草稿。
- 新增 `filtering tasks settles the selection and drops stale drafts` 与
  `diff file switches clear note drafts from the previous file` 两个测试，覆盖回落选择、
  状态变更、composer 打开/关闭、同 tab 点击、文件切换与活动 tab 关闭。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 94/94，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 33 删除工作树后的文件清理（2026-11-27）

- 新增 `live_files`：只返回所属 worktree 仍存在的索引文件。Search 的文件命中、
  Bots 右侧 Files 面板及计数、Projects/Bots 与 Diff composer 的 `@` 补全统一使用该
  列表，避免删除工作树后仍显示无法跳转的文件行或建议已删除的路径。
- 删除工作树后其文件立即从 Search 与 Files 面板消失，其他工作树的文件保持不变；
  重启后 seed 文件仍由 `live_files` 结合已保存的 `deleted_worktrees` 过滤，不会复活。
- 新增 `deleting a worktree retires its files from search and the files panel`，覆盖
  删除 `checkout-flow-v2` 后 4 个归属文件从搜索/面板消失、其余 4 个保留，以及
  `@validators` 不再出现在补全菜单。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 95/95，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 34 Projects 侧栏结构与页面菜单（2026-11-27）

- 对照 `design/reference-create-worktree.jpg`，桌面 Projects 隐藏通用
  Search / Tasks / Automations / Bots nav：Projects header 直接从标题栏下方开始，
  顶部留白 19 px、机器列表额外留白 5 px；OCR 中 `Projects` y≈62–83、`Local Mac`
  y≈103–121，与参考 y≈63–82 / y≈103–121 基本重合。
- 新增 `sidebar_nav_visible(model, compact)` 统一可见性：Search/Tasks/Automations/Bots
  页面保留 nav，窄窗口 Projects 抽屉也保留 nav，只有桌面 Projects 不渲染。
- 标题栏 `Orca` wordmark 改为真实页面菜单按钮，带 chevron、hover 与打开态填充；
  菜单为 232×172 卡片，含 Projects / Search / Tasks / Automations / Bots 五行，
  当前页高亮、行 hover，点击行切换页面；点击菜单外或按 `Escape` 关闭，打开模态框、
  右键菜单或切换页面时也会关闭。菜单打开时页面级 Enter 与 ↑/↓ 保持 inert，避免操作
  被遮住的搜索结果、任务或自动化。`app_menu_open` 是 transient 状态，不进入持久化 JSON。
- 菜单卡片使用固定高度，避免 `stack` 将未定高度的内容在窗口中垂直拉满；新增
  `scenes/app_menu` 与 `docs/screenshots/app-menu.png` 作为验收截图。
- 新增测试 `wordmark menu switches pages and Projects hides the nav`，覆盖菜单开关、
  页面切换、紧凑/桌面 nav 可见性以及打开模态框时关闭菜单。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 96/96，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 35 Diff 文件选择器与筛选实时计数（2026-11-27）

- Diff tab strip 的 `+` 现在真正打开文件选择器：`AddDiffFile` 优先恢复第一个已关闭
  文件；全部 tab 已打开时打开 Files 菜单。菜单列出全部四个文件并标记
  Showing / Open / Closed，点击 Open 行切换文件，点击 Closed 行恢复 tab；打开或
  切换后自动关闭菜单。切换文件同时收起 note 卡片并清空旧草稿，保证 note 归属。
  点击 scrim、按 `Escape`、切换页面或打开 modal/context menu 都会关闭菜单；卡片
  固定 240×178，锚定 `+` 并夹在左窗格内。新增 `scenes/diff_files` 与
  `docs/screenshots/diff-files.png`。
- Search 类别 pill 接入 `search_filter_count` 实时计数：All 数等于
  Worktrees + Bots + Sessions + Files，且随当前 query 更新；宽度 ≥420 时显示数字，
  更窄回退纯文字避免挤压。`Search files with @` 建议词可点击，直接进入文件作用域。
- Tasks 状态与来源 pill 接入 `task_filter_count`：状态计数随当前 query 与来源
  联动，来源计数随当前 query 与状态联动；480 与 320 宽截图 OCR 检查均未越界。
- 新增 `diff file picker reopens closed tabs and switches open files` 与
  `search and task filter pills report live scoped counts`，并更新
  `diff file tabs close with an open-tab fallback`；native 测试 98/98。
- 重新生成 `diff-files.png`、`search.png`、`search-narrow.png`、`tasks.png`、
  `tasks-narrow.png`、`tasks-list-narrow.png`；README/SPEC/QA 同步，验收截图共
  26 张。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 98/98，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 36 Create 弹窗 Advanced 基础分支（2026-11-27）

- Create worktree 的 Advanced 不再是静态占位文案：展开后显示 `Base branch` 选择器，
  点击在 `main` → `develop` → `release/next` 之间循环；主按钮创建的 worktree 的 setup
  worker 正文会记录所选基础分支（Smart / GitHub / Branch 三种来源都适用）。
- Advanced 展开只在 header 行上切换，内部选择器拥有独立点击区，因此点击分支行不会
  误收起面板；标题旁的 chevron 仍在展开时翻转为向上。
- 弹窗按视口高度自适应：低于 680 px 时基础分支行收为 26 px 高并省略辅助说明，避免
  320×600 / 480×600 下 footer 被裁切；1280×752 下保留 36 px 行与
  `New worktrees start from …` 提示。
- 新增 `scenes/modal_advanced` 与 `docs/screenshots/orca-create-worktree-advanced.png`；
  回归测试覆盖 Advanced 开关、三档分支循环和新 worktree worker 正文。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc` 0 errors，
  `moon test app --target native` 99/99，`moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过；验收截图共 27 张。

## Round 37 Bots 事项状态菜单（2026-11-27）

- Bots 右栏 Home 的 status row 从装饰变为真实入口：状态 glyph、当前状态与琥珀色
  chevron 组成可点击 chip，展开 In progress / Waiting on you / Done 三行内联菜单，
  当前行带琥珀色 check，行有 hover 反馈。
- 选择状态只更新当前 bot 的 `item_state` 覆盖值并关闭菜单；Home 状态行与 Activity
  末尾的 `Status set to …` 行同步更新（Done 使用绿色 check，其他状态沿用 amber
  spinner），bot 原始的 `item.state`、标题与会话保持不变。切换 bot 后各自覆盖值保留。
- `Bot.item_state` 进入版本 1 持久化 JSON，缺失字段安全回落为空；seed bot 恢复时只
  合并覆盖值，仍保留种子 item、sessions 与标题。新增 `bot_item_state` /
  `bot_item_states` 帮助函数。
- 菜单是 transient `bot_status_menu_open`：仅当前 bot 有 item 时可打开；`Escape`、
  切换 bot/panel tab/页面、折叠面板、AddBot 与前进后退都会关闭；无 item 或非法状态
  选择保持 no-op。
- 新增 `scenes/bots_status` 与 `docs/screenshots/bots-status.png`，并重新生成
  `orca-bots.png`、`bots-panel-narrow.png`；README、QA、PHASE2 同步更新。
- 新增 4 个行为/持久化测试；`moon test app --target native` 103/103，native/wasm
  check 与 build、`moon fmt --check`、`git diff --check` 全部通过；验收截图共 28 张。

## Round 38 动态 needs-you 徽标（2026-11-27）

- Bots 导航行的 “1 needs you” 从硬编码改为实时统计：`bots_needing_you` 遍历 bot 的
  有效 Home 状态，只统计 **Waiting on you** 的事项；徽标在 0 时隐藏，1 时显示
  `1 needs you`，多件时显示 `2 need you` / `N need you`。
- 状态菜单选择、bot 覆盖值持久化与徽标共用 `bot_item_state`，因此把 Scout 改为
  Waiting 后徽标立即从 1 变 2，把 CI Watch 改为 Done 后回落，全部清空后徽标消失。
  Bots standby 空状态的提示文案也使用同一计数。
- 新增 `bots_needs_label` 纯函数与回归测试，覆盖 0/1/2 三档、增加/减少/清零、
  新 bot 无 item 不影响计数，以及持久化恢复后的计数。
- 重新生成 `docs/screenshots/bots-status.png`，截图可见 “2 need you” 徽标；验收
  截图仍为 28 张。
- 门禁：`moon test app --target native` 104/104，wasm 1/1；native/wasm check 与
  build、`moon fmt --check`、`git diff --check` 全部通过。

## Round 39 选中 bot 的琥珀状态点（2026-11-27）

- 选中 bot 的 36 px mascot 右下角补上参考图的 7 px 琥珀色状态点：`mascot_with_status`
  将 7 px 圆点放进 11 px 的 `#2a2a2a` 外环（2 px padding），再以 `offset` 叠到
  mascot 右下角，外圈与卡片底色分离，缩放和窄屏下位置保持一致。
- 只有 `selected_bot_card` 的 header 使用带状态点的 helper；其他 bot 卡片、会话 tab
  与 mascot 图例仍走普通 `mascot_avatar`，不会多出装饰。
- 重新生成 `orca-bots.png`、`bots-status.png` 与 `bots-files.png`，三处选中 bot 的
  mascot 均可见状态点；README、QA、PHASE2 同步更新。
- 门禁：`moon test app --target native` 104/104，wasm 1/1；native/wasm check 与
  build、`moon fmt --check`、`git diff --check` 全部通过；验收截图仍为 28 张。

## Round 40 Bots 侧栏账户头像（2026-11-27）

- Bots 侧栏 footer 最右侧新增 28 px 账户头像：圆形 white/12 底、1 px 边框与 Maya 的
  `M` 首字母；右下角 10 px plus badge 同样带 1 px 边和 plus glyph，并通过 `offset`
  完整落在 28 px 内，不会被裁切。
- 头像作为静态身份标记，不替换或遮挡 settings/help/history/fleet 控件；现有 footer
  交互保持不变，220 px sidebar 的 188 px content row 仍能容纳全部条目。
- 重新生成 `orca-bots.png`、`bots-status.png`、`bots-files.png`、`bots-narrow.png`
  与 `bots-panel-narrow.png`；1280 截图可见头像，480 抽屉关闭的窄屏布局保持原样。
- 门禁：`moon test app --target native` 104/104，wasm 1/1；native/wasm check 与
  build、`moon fmt --check`、`git diff --check` 全部通过；验收截图仍为 28 张。

## Round 41 Composer 本地听写演示（2026-11-27）

- Projects/Bots 主 composer、Bots 评论 composer 与 Diff composer 的 mic 不再是装饰：
  点击后由 `Dictate(1|2|3)` 向对应草稿追加固定示例句（主 composer 为
  `Summarize the failing checkout tests.`，评论为 `Please add a regression test.`，
  Diff 为 `The zero-rate fallback looks right.`）。`dictation_append` 在已有文本后
  自动补一个空格，草稿以空白结尾时不再重复添加；非法 target 保持 no-op。
- `dictation_target` 是 transient 提示状态，不进入持久化；`DraftInput`、
  `CommentInput`、`DiffDraftInput`、completion 选择、Send / SendComment / DiffSend
  都会清掉提示。当前 composer 的 mic 使用 16/15/20 px 同尺寸 slot 变为琥珀色并带
  透明琥珀底色，不改变 footer 布局；Bots 主 composer 的 caption 右侧同步显示
  `Dictated locally`，仅在 composer 宽 ≥360 px 时出现，避免窄屏挤掉设备行。
- 新增 `scenes/bots_dictation` 与 `docs/screenshots/bots-dictation.png`，展示示例句、
  琥珀 mic 与 `Dictated locally`；README、QA、PHASE2、PHASE3 同步更新，验收截图
  增至 29 张。
- 新增 1 个行为测试覆盖三个 composer 的追句、空白拼接、非法 target、编辑/发送清除
  与 Diff 发送；`moon test app --target native` 105/105。
- 门禁：native/wasm check 与 build、`moon fmt --check`、`git diff --check` 全部通过。

## Round 42 Bots 右栏几何对齐（2026-11-27）

- 修正 Bots 三栏宽度多减 8 logical px 的问题：顶栏与 body 只各让出 1 px 分隔线，
  默认 385 px 右栏从 1280 窗口的 x=895 logical（2× 截图 x=1790）开始并一直铺到
  右缘，2560 px 截图中不再出现 16 px 宽暗色空白带。
- Home 右栏内边距改为左侧 12 px、内容宽减去右侧 16 px；Activity 图标落在 x≈1830，
  时间右缘 x≈2532，Done means 标签约 x=1815、正文从 x≈1874 开始。Done means
  使用 49 字符预算（261 px 正文宽），在默认宽度恰好断成参考图的两行。
- Scout 消息卡去掉 1 px 描边，改为 `width - 14`、左 8/右 5 内边距，2× 截图范围精确
  为 x=1802–2543；头像由 24 px 收到 20 px，正文缩进 27.5 px 与姓名同列，行内
  `safari_pay_click` 改为无底色的 10 px mono run，卡片底缘回到 y≈1106。
- 重新生成 `orca-bots.png`、`bots-status.png`、`bots-files.png`、`bots-dictation.png`、
  `bots-narrow.png` 与 `bots-panel-narrow.png`；验收截图仍为 29 张。
- 新增 done-means 换行回归测试（261 px → 49 字符、两行断点），
  `moon test app --target native` 106/106；native/wasm check 与 build、
  `moon fmt --check`、`git diff --check` 全部通过。

## Round 43 Projects 工作树卡片垂直几何（2026-11-27）

- 对照 `design/reference-orchestration.jpg` 的选中 worktree 卡片（1× 下 x=11–325、
  y=277–440，约 164 px 高），把卡片内边距从 top 5 / bottom 6 改为 top 10 / bottom 12；
  2× 截图里选中卡片的 y=746–1072（163.5 logical px），标题距顶 10.6 px，下一张卡片
  标题距上一张卡片底缘 13.4 px，与参考的 10 / 12 px 节奏一致。
- 新增 `worktree_card_padding()` 统一返回 `(10, 12)`，新增对应回归测试；全部
  29 张验收截图重新生成，1280×752 主图仍完整显示到 `Fix checks detail link`，无裁切。
- `moon test app --target native` 107/107；native/wasm check 与 build、
  `moon fmt --check`、`git diff --check` 全部通过。

## Round 44 Tasks 工作树关联闭环（2026-11-27）

- Tasks 详情新增真实的工作树关联闭环：无关联任务的
  `Choose a worktree to connect` 卡片可打开选择器；已关联任务的 `Linked worktree`
  标题行提供 `Change`，选择器打开时动作变为 `Close`。
- 新增 transient `task_link_menu_open` 与消息 `ToggleTaskWorktreeLink` /
  `LinkTaskWorktree(String)` / `UnlinkTaskWorktree`；新增 `live_worktrees(model)`，
  选择器只列出当前仍存在的 worktree，避免指向已删除目标。
- 选择器是详情滚动区内的内联卡片，列出 worktree 名称与 branch；当前关联行带绿色
  check，点击其他行写入该任务的 `worktree_id` 并关闭；底部
  `Unlink from this task` 清空关联。不存在或已删除的 worktree id 保持 no-op。
- `Escape` 关闭选择器；打开时页面级 `↵` 与 Tasks ↑/↓ 保持 inert；切换任务、
  筛选/来源/搜索、清空筛选、新建任务、打开右键菜单、页面切换与前进/后退均会关闭。
- 关联结果写入既有 Tasks JSON 的 `worktree_id`，重启后保留；`task_link_menu_open`
  不进入持久化。新增 `scenes/tasks_link` 与 `docs/screenshots/tasks-link.png`。
- 新增 `task worktrees relink, unlink and survive a restart`，覆盖 live 列表、非法目标、
  换绑隔离、解绑、持久化 round-trip、筛选与切换任务自动关闭。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 108/108，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过；验收截图 30 张。

## Round 45 Tasks 新建任务与工作树创建（2026-11-27）

- 修复新建任务硬编码 `eu-promo-checkout` 的问题：`AddTask` 现在把
  `worktree_id` 留空，详情先显示 `Choose a worktree to connect`；即使该工作树已被
  删除，新任务也不会继承一个陈旧链接。
- 工作树选择器底部新增真实的 `Create worktree` 行（plus 图标 + hover），点击由
  `OpenTaskWorktreeCreate` 打开既有 Create worktree 弹窗，并记录 transient
  `task_link_after_create` 指向当前任务；取消/关闭弹窗会清除该待关联状态。
- `CreateWorktree` 成功后若存在待关联任务，会把新工作树的 id 写入该任务的
  `worktree_id`、打开详情并清除待关联状态后关闭弹窗；选择 **Create more** 时弹窗
  保持打开，首个工作树已完成关联，后续创建不会覆盖该任务。
- 选择器卡片压缩内部节奏（选项行 40 px、创建行 28 px、间距 4 px、padding 10 px），
  加入创建行后仍在详情视口内完整显示：2× 截图卡片底缘 y≈1456，`Unlink` 文案
  底缘 y≈1427，没有裁切。
- 新增测试 `new tasks start unlinked and create a worktree from the picker`，覆盖
  新任务空链接、创建待关联状态、取消清理、创建后自动关联、持久化 round-trip，以及
  删除 `eu-promo-checkout` 后新建任务仍不产生陈旧链接。
- 重新生成 `docs/screenshots/tasks-link.png`，README/SPEC/QA 同步更新；native
  tests 109/109，验收截图仍为 30 张。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 109/109，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 46 创建弹窗状态复位与空状态（2026-11-27）

- 创建工作树弹窗不再泄漏上一次的 transient 状态：`NewTab` / `OpenModal` / `CloseModal`
  与成功的 `CreateWorktree` 关闭路径都会把 `modal_from`、名称、Advanced、base branch、
  agent、target 和 Create more 复位；从 Tasks 的 `Create worktree` 行进入时也不会继承
  旧的 Advanced/agent/target 配置，只保留待关联任务索引。
- Name 源取消或创建后再次从侧栏 `+` 打开，仍回到默认 Smart 来源，名称不再空白且
  主按钮不会误禁用；回归测试覆盖取消、创建、NewTab 重开与 Tasks 创建入口的清理。
- Automations 在没有任何 run 时，Recent runs 不再只渲染一张空白卡：显示
  `No runs yet`、说明文案和 **New automation** 按钮，并隐藏无意义的 `View all`
  切换；删除全部 automation 后列表与 run 历史都进入真实空状态。
- Bots 侧栏 footer 的 history 图标由单纯切 tab 改为 `OpenBotItemPanel(2)`，面板收起
  时也会重新打开并落在 Chats tab，窄屏下点击不再无可见效果。
- 新增 `scenes/automations_empty` 与 `docs/screenshots/automations-empty.png`，README /
  SPEC / QA 同步更新；native tests 111/111，验收截图 31 张。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 111/111，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 47 编辑器草稿复位与 Bots 空状态（2026-11-27）

- Automation 编辑弹窗的 transient 状态不再泄漏：`CloseAutomationEditor` 以及
  `SaveAutomation` 的编辑/新建两条成功路径都会复位 `automation_editor_index`、
  name、schedule 与 project；编辑后取消或保存，再次 `New automation` 都从空白表单
  开始，不会继承上一轮的标题、计划或项目。
- Bots 搜索无结果时，侧栏空状态增加 **Clear search** 按钮；点击 `ClearBotQuery`
  只清空 `bot_query` 并保留已打开、已聚焦的过滤字段，不需要用户先关掉搜索再重开。
- 新 bot 的 Home Chat 不再复用通用 seed 历史：无 work item 的 bot 显示
  `<name> is ready. Send a message to start its first task.` 与
  `Waiting for your first message`，不再出现虚构的 `Worked for 12m`。
- 新增 `scenes/bots_new` 与 `docs/screenshots/bots-new.png`，展示新 bot 的空
  Home Chat intro、右侧 `No active item` / **Open Home Chat** 引导，并确认文案无裁切。
- 新增回归测试覆盖编辑器取消/保存/新建复位、Bots 空过滤清除与新 bot 欢迎文案；
  native tests 113/113；验收截图增至 32 张，README/SPEC/QA 同步。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 113/113，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过。

## Round 48 Bots 首条消息与 Home Chat 作用域（2026-11-27）

- `bot_chat_key` 在 `active_session` 为空时解析为当前 bot 的第一个 Home session：
  从 bot 默认视图发送的消息与随后点击 Home Chat 使用同一个 key，切换会话后消息
  不再消失；有 Home session 的种子 bot 与新建 bot 都走这条路径。
- 新 bot 的 ready-to-start intro 只在当前 chat 还没有消息时出现；首条消息发送后
  intro 与 `Waiting for your first message` 让位于真实的 user / assistant transcript。
- 无 work item 的右侧 Home 空状态文案随聊天状态变化：未开始时仍是
  `Start a Home Chat with <name> to give it something to work on.`；Round 49 起首条
  消息会直接创建 work item，因此该“已开始”空状态只保留给尚未升级的旧 payload 或
  没有创建 item 的兼容路径。
- 新增 `scenes/bots_new_chat` 与 `docs/screenshots/bots-new-chat.png`，展示新 bot
  首条消息后的对话；该截图已在 Round 49 重新生成，右侧显示真实 `#43` item。新增
  回归测试覆盖默认视图与 Home Chat 共享 key、intro 隐藏与右栏文案切换。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 114/114，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过；验收截图增至 33 张。

## Round 49 Bots 首条消息创建真实 item 与 item 持久化（2026-11-27）

- 新建 bot 发送首条消息时，`Send` 不再只追加 transcript：它为当前 bot 创建真实
  `BotItem`，编号从种子最大值之后开始（`#43`、`#44`…），标题取消息前 38 个字符
  并带省略号，状态 `In progress`，meta 为 `Item N · Home Chat · now`，带
  Follow up / Home Chat chips、Done means 以及 Add / Worker-started 两条 activity；
  bot 同时切到 `1 working`，后续消息不会重复创建 item。
- 新增持久化 `bot_item_seq`，并完整编码/解码 `BotItem`、`ToolChip`、`ActivityIcon`、
  `BotActivity` 与可选 `BotMessage`；新建 bot 的 item、activity 和下一个编号在重启后
  保留。加载时缺失 item 的旧 payload 仍沿用种子 item，种子 bot 的 sessions 不被替换。
- 新 bot 的 center transcript 不再落入通用种子块；`bot_has_seed_transcript` 仅让六个
  参考 bot 使用手写历史，新建 bot 只显示自己的 user / assistant 消息。
- `scenes/bots_new_chat` 重新生成 `docs/screenshots/bots-new-chat.png`：首条消息为
  **Draft a release checklist for 4.13**，右栏显示 `#43 Draft a release checklist for
  4.13`、`In progress`、`Item 43 · Home Chat · now`、chips、Done means 与 Activity；
  OCR 确认标题、状态、meta 和活动行完整且无裁切。
- 新增回归测试 `first bot message creates numbered items that survive a restart`，
  覆盖 `#43`/`#44` 递增、种子 bot 不递增编号、标题截断、item round-trip、种子 sessions
  保留与旧 payload 兼容。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 115/115，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过；验收截图仍为 33 张。

## Round 50 Bots 状态变更写入持久化活动历史（2026-11-27）

- `SetBotItemState` 不再只更新 `item_state` 并在视图里临时渲染一行状态：每次选择
  新状态都会向当前 bot 的 `BotItem.activities` 追加
  `Status set to …`（`now`，Done 用 `CheckActivity`，其余用 `PlayActivity`），
  状态变更按时间顺序累积，重复选择当前状态不会产生重复行。
- 状态活动随 item 一起走版本 1 JSON；重启后 `item_state` 与两条以上状态历史都保留。
  旧 payload 若有覆盖值但没有状态活动，视图仍回退渲染当前 `Status set to …` 行，
  因此升级不会丢掉状态行。
- `scene_bots_status_model` 改为通过真实的 `ToggleBotStatusMenu` +
  `SetBotItemState("Waiting on you")` 生成，`docs/screenshots/bots-status.png`
  重新生成；OCR 确认 Activity 末尾的 `Status set to Waiting on you / now` 完整。
- 新增回归测试 `status changes append to the persisted activity history`：两次状态
  变更各追加一行、同状态不重复、item_state 与历史共同 round-trip，且其他 bot 不受影响。
- 门禁：`moon check --target native` 0 errors，`moon check --target wasm-gc`
  0 errors，`moon test app --target native` 116/116，
  `moon test web_wasm --target wasm-gc` 1/1，
  `moon build linux_skia --target native` / `moon build web_wasm --target wasm-gc`
  通过，`moon fmt --check` 与 `git diff --check` 通过；验收截图仍为 33 张。

## Round 51 Bots 列宽与标题/评论条几何校正（2026-11-27）

- 参考图 `reference-bots.png` 是带窗口外框的整窗截图：应用内容从 x≈14 px 开始，
  右缘另有 16 px 滚动条轨道。按内容原点对齐后，侧栏实际宽度约 272 px
  （14→285），右栏总宽 400 px（880→1280）；此前 285/385 是按截图绝对 x 取值，
  导致侧栏多 13 px、右栏内容整体右移 15 px。
- 默认值改为侧栏 272 px、右栏 400 px；1280 下为 272 / 606 / 400，另 2 px 分隔线，
  中心仍满足最小 300 px。960 下右栏按 32% 上限收缩到约 307 px，700 下两栏仍为 chat
  保留 300 px。
- Bots 标题栏左边距 16→8 px、词标前间距 16→13 px，整个标题栏内容左移；
  “Orca” OCR x=71.6 对齐参考 71.4。
- Bots 段头改为 16 px chevron + 4 px 间距、左/右外边距 5/8 px；“Bots” x≈22.6
  对齐参考 21.2，右侧三个 action 位置不变。
- 评论条把加号与输入框包成 3 px 间距的左组，左内边距 10→5.5 px：
  `Add a comment…` x=927.7 对齐参考 927.8，加号亮像素 905..913.5 对齐
  905..914.5，mic/send 仍贴右缘。
- OCR 复测：Search 38.7 vs 38.8，右栏 Home 894.8 vs 895.8，Files 1158.1 vs 1158.0，
  Activity 889.7 vs 892.6；Home/Files 误差 ≤1 px。
- Bots 八张截图重新生成；状态、Files、新建、首条消息与 dictation 文案 OCR 完整。
  回归测试补充默认 272/400 与 1280/960/700 布局断言。
- 门禁：native/wasm check 0 errors，app 116/116，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 33 张。

## Round 52 Bots 中心 Tab 图标、基线与会话标签完整显示（2026-11-27）

- 中心 active tab 恢复参考图底部的 2 px `#f0f0f0` 基线，覆盖完整 143 px Home tab；
  基线以 overlay 绘制，不改变 36 px tab 高度与点击区域。
- Home tab 增加 12 px mascot；bot working 时再前置 8 px amber spinner。按参考图
  ~14 px 外框对齐后，spinner 起点 280 vs 278.5 logical，`Scout` 306 vs 305。
  `#eng` 改为本地 hash SVG，hash 起点 423.5 vs 422，标签起点 437 vs 438。
- 图标审计发现 vendored Lucide 子集缺少 `hash` / `plug` / `unplug`；三者在原实现中
  静默绘制为空。现均改为显式 SVG path，并同步修复 Connectors 的 Connect/Disconnect
  与 Tasks worktree unlink 行；app 内所有字面 Lucide 名称现在均存在。
- 会话行新增 `session_row_label_width(width) = width - 107` 与字符上限 helper；
  272 px 侧栏下标签列 165 px / 26 字符，`#eng · checkout on Safari?` 完整显示且无
  省略号，时间戳仍贴齐选中行右缘。
- 回归测试补充 272/220/320/380 的标签宽度与字符上限断言；Bots 八张验收截图重生成。
- 门禁：native/wasm check 0 errors，app 116/116，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 33 张。

## Round 53 Search 类别切换退出 @ 作用域与窄版 Diff 均分（2026-11-27）

- Search 的 `@` 作用域与类别 pill 不再互相锁死：在 `@pay` 下点 Bots / Worktrees /
  Sessions / All 会移除前导 `@`，用剩余文本执行该类别搜索；点 Files 保持 `@` 与当前
  查询，并保留 `search_filter_before_scope`。非 Files pill 不再出现“已选中但 0 结果”
  的假死状态。
- `search_filter_count` 改为用去掉 `@` 后的文本预演每个 pill 点击后的结果：All /
  Worktrees / Bots / Sessions 显示退出作用域后的计数，Files 仍是当前文件作用域命中数。
  `search-files.png` 重生成，`@checkout` 下 All 7 / Worktrees 2 / Bots 1 /
  Sessions 1 / Files 3，右侧当前结果仍为 3。
- 窄版 Diff 的 60/40 堆叠改为 50/50：新增 `diff_compact_pane_heights(height)`；
  480×600 时上下各 299.5 px，代码区扣除 91 px 工具栏后为 208.5 px（约 8 行 24 px），
  聊天 transcript 从 64.5 px 增至 124.5 px，可完整看到 File / Line / User comment
  上下文卡。`diff-narrow.png` 重生成。
- 回归测试扩充 `search @ prefix…` 与 `search and task filter pills…`，覆盖类别切换、
  Files 保持作用域、计数预演与 All 退出；`narrow diff stacks its panes` 增加
  `diff_compact_pane_heights(600) == (299.5, 299.5)`。
- 门禁：native/wasm check 0 errors，app 116/116，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图仍 33 张。

## Round 54 任务 Activity 持久化与操作时间线（2026-11-27）

- `Task` 新增 `activity : Array[TaskActivity]`（`icon` / `text` / `time`），
  任务详情直接渲染这条时间线。种子任务由 `default_task_activity` 生成原来的四行
  基线：来源、指派、worktree 链接、agent/状态；旧版 JSON 没有 `activity` 时也走同一
  回退，因此升级不会清空任务状态，也不会让 Activity 变空。
- Mark done / Reopen 分别追加 `Marked done`（check）与 `Reopened`（play）；
  Link / Unlink 追加 `Linked to <id>` / `Unlinked worktree`；保存描述追加
  `Description updated`；新建任务从 `Task created` / `Assigned to you` 开始；
  从任务 detail 创建 worktree 后追加 `Linked to <id>`；删除 worktree 自动解绑时
  追加 `Worktree <id> deleted`。重复 Mark done、重复 Link 同一 worktree、未改动描述
  的 Save 不重复追加，时间均为 `now`。
- Activity 行的状态点按 icon 着色（check 绿、play 蓝、comment 琥珀、其余灰），
  时间线增长后仍在 detail 的 scroll_view 内，不挤压底部 Mark done / Reopen。
- 新增回归测试 `task actions append to the persisted activity timeline`：覆盖四行基线、
  状态/链接/描述/新建任务的追加与去重、保存/加载往返，以及缺失 `activity` 的旧载荷
  回退；新增 `closing the task context menu runs no action` 直接覆盖 `CloseContextMenu`。
  app 测试 118/118。
- `tasks.png`、`tasks-link.png`、`tasks-narrow.png`、`tasks-list-narrow.png` 重生成；
  2560×1504 / 960×1200 尺寸不变，OCR 仍能找到 Activity 四行、`Open in worktree` 与
  `Mark done`。
- 门禁：native/wasm check 0 errors，app 118/118，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图仍 33 张。

## Round 55 Diff 审阅上下文跟随 worktree（2026-11-27）

- Diff 屏不再固定渲染 checkout 参考内容：`Model` 新增 `diff_worktree`，右键
  **Show diff** 以该 worktree 为目标执行 `open_diff_worktree`，同时设置
  `screen = DiffScreen`、打开/选中对应 tab，并加载该 worktree 的标题、agent 图标、
  四文件审阅集与聊天文案。
- 四个种子 worktree 均有各自的四文件上下文：checkout 保持参考图的
  `validators.ts / shipping.ts / cart.spec.ts / handoff.md`；EU promo 为
  `rules.ts / promo.test.ts / cart.ts / CHANGELOG.md`；handoff 为
  `handoff.md / handoff.template.md / handoff.ts / README.md`；checks 为
  `checks.ts / checks.test.ts / ci.yml / CHECKS.md`。所有 profile 固定 4 个 tab 槽，
  因此现有 `diff_closed` 持久化 mask 仍可兼容。
- 切换到不同 worktree 时重置 `diff_file`、选中行/范围、打开 note、草稿、notes、
  verdict、额外消息与 working 状态，避免上一轮审阅泄漏；同一 worktree 再次 Show diff
  保留当前审阅。checkout/eu-promo/handoff 仍在运行，checks 已完成，因此 checks 的
  transcript 显示 `Worked for 7s`、`Stopped` 和 Approve / Request changes，上下文卡
  路径跟随活动文件。
- `diff_worktree` 与 `diff_working` 随版本 1 JSON 持久化，旧 payload 缺少字段时回退
  checkout/当前种子状态；重启后 checks 仍保持已停止的审阅，文件列表和标题不退回
  checkout。
- 新增回归测试 `show diff scopes the review to the selected worktree` 与
  `the selected diff worktree survives a persistence round trip`，覆盖右键路径、
  标题/文件差异、脏状态重置、切回 checkout 恢复参考审阅以及 JSON 往返；app 测试
  120/120。
- 新增 `scenes/diff_checks` 与 `docs/screenshots/diff-checks.png`（1280×752 →
  2560×1504）；OCR 找到 `checks.ts`、`checks.test.ts`、`ci.yml`、
  `File: src/ci/checks.ts`、`Worked for 7s`、`Stopped` 与两个 verdict chip。
  `diff.png`、`diff-files.png`、`diff-narrow.png` 重新生成后 MD5 不变，参考画面无回归；
  验收截图增至 34 张。
- 门禁：native/wasm check 0 errors，app 120/120，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 34 张。

## Round 56 Automation 名称守卫（2026-11-27）

- 新增 `automation_save_blocked(model)`：automation 名称 draft 为空或只有空白时返回
  true。`SaveAutomation` 在阻断状态下原样返回 `model`，编辑器保持打开且不新增/改名，
  不再静默创建 `Untitled automation`；非空名称仍按去首尾空白后的文本创建或更新。
- 编辑器名称字段下方显示琥珀色 `Type a name to save`，主按钮
  **Save changes / Create automation** 背景变暗、文字转灰；按钮点击与 `⌘↵` 都走同一
  model 守卫，因此阻断时都是 no-op。新建与编辑已有 automation 都适用，清空名称后
  原 automation 保持原名，重新输入名称即可恢复保存。
- 新增回归测试 `automation save stays open until a name is typed`：覆盖空白/纯空格
  Save 保持打开且数量不变、带空白名称 trim 后创建、编辑时清空名称被阻断且保留旧名、
  重新命名后关闭并落盘 draft 清空；app 测试 121/121。
- 新增 `scenes/automation_editor_blocked` 与
  `docs/screenshots/automations-editor-blocked.png`（1280×752 → 2560×1504）；OCR 找到
  琥珀色 `Type a name to save`、`Create automation` 与 `Cancel`，并确认按钮底色由
  正常 240 灰降为 56 灰。`automations-editor.png`、`automations.png`、
  `automations-empty.png`、`automations-narrow.png` 重新生成后 MD5 不变；
  验收截图增至 35 张。
- 门禁：native/wasm check 0 errors，app 121/121，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 35 张。

## Round 57 Tasks 新建任务标题守卫（2026-11-27）

- 新增 `task_add_blocked(model)`：新任务 composer 的标题为空或只有空白时返回 true。
  `AddTask` 在阻断状态下原样返回 `model`，composer 保持打开且不新增任务，不再静默
  创建 `Untitled task`；非空标题仍按去首尾空白后的文本创建。
- composer 的 **Add** 按钮在阻断时改用 `page_button_hover_disabled`，标题字段下方显示
  琥珀色 `Type a task title to add`；字段 `on_submit=AddTask` 与按钮点击共用 model
  守卫，因此空标题按 `↵` 或点 Add 都是 no-op。宽屏按钮行保持原位置，窄屏字段与按钮
  继续纵向堆叠，提示位于最下方；列表滚动高度同步为提示增加 20 px（宽屏 64、
  窄屏 104），避免 composer 越过或覆盖任务列表。
- 新增回归测试 `task composer requires a title before adding` 与
  `task composer height reserves room for the blank-title hint`：覆盖空/纯空格 Add
  保持 composer 打开且任务数不变、带空白标题 trim 后创建、成功后 draft 清空，以及
  关闭/空白/已输入状态下宽窄布局高度 0/64/104 与 44/84；app 测试 123/123。
- 新增 `scenes/tasks_composer` 与 `docs/screenshots/tasks-composer.png`
  （1280×752 → 2560×1504）、`tasks-composer-narrow.png`（480×600 → 960×1200）；
  OCR 找到 `What needs doing?`、`Type a task title to add`、`Add`，Add 按钮底色为
  26 灰、文字 111 灰。`tasks.png`、`tasks-link.png`、`tasks-narrow.png`、
  `tasks-list-narrow.png` 重新生成后 MD5 不变；验收截图增至 37 张。
- 门禁：native/wasm check 0 errors，app 123/123，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 37 张。

## Round 58 Rename worktree 名称守卫（2026-11-27）

- 新增 `rename_save_blocked(model)`：rename 对话框打开且 draft 为空或只有空白时返回
  true。`CommitRename` 在阻断状态下原样返回 `model`，对话框保持打开，worktree 旧名称
  与分支不变；非空名称仍按去首尾空白后的文本更新 sidebar row 与 tab。
- 名称字段的 `on_submit=CommitRename` 与 **Rename** 按钮共用同一 model 守卫，因此空名称
  按 `↵` 或点击按钮都是 no-op。阻断时字段下方显示琥珀色 `Type a name to rename`，
  主操作替换为 36 px 的 dimmed/inert `dialog_button_disabled`（`fg_muted` 文字、
  `white_a(0.14)` 底色）；Cancel、关闭图标与字段的 `on_cancel` 保持可用。输入非空白
  名称后立即恢复可用的 **Rename** 主按钮。
- 新增回归测试 `rename dialog blocks an empty name`：覆盖空白与纯空格提交均保持打开、
  draft 原样、旧名称保留；带前后空白的名称 trim 后成功重命名并关闭；关闭后
  `rename_save_blocked` 复位。app 测试 124/124。
- 新增 `scenes/rename_worktree_blocked` 与
  `docs/screenshots/worktree-rename-blocked.png`（1280×752 → 2560×1504）、
  `worktree-rename-blocked-narrow.png`（480×600 → 960×1200）；OCR 找到
  `Rename worktree`、`Type a name to rename`、`Cancel` 与 `Rename`，并确认阻断时
  Rename 按钮底色约 45 灰、正常态约 240 灰。`worktree-rename.png` 重新生成后 MD5
  不变；验收截图增至 39 张。
- 门禁：native/wasm check 0 errors，app 124/124，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 39 张。

## Round 59 Diff 手机宽度文件与上下文（2026-11-27）

- Diff tab strip 新增手机模式：当每个 tab 将不足 120 px 时，只渲染当前活动文件 tab，
  右侧改为显示 **N files** 的文件选择器；选择器仍列出全部打开/关闭文件及其
  Showing / Open / Closed 状态，因此 320 px 下切换文件、恢复关闭文件和关闭当前 tab
  都保持可用。选择器在手机模式固定贴右并继续夹在 diff pane 内，不再按已隐藏 tab
  的旧宽度定位。
- 活动 tab 在 320 px 下获得剩余整行宽度，标签恢复为完整的 `validators.ts (diff)`，
  不再出现四个标签互相挤压的碎片。上下文卡的 `File:` 行在窄于 400 px 时改用 basename
  （`validators.ts`），避免全路径在文件名中间被截断；480 px 与桌面仍显示完整
  `src/checkout/validators.ts`，并保留 `clip_left` 兜底。
- 新增回归测试 `diff tabs focus the active file at phone widths`：覆盖 3 文件在 320 px
  只显示活动 tab、同组在 480 px 全部显示、4 文件在 480 px 折叠、选择文件后焦点跟随，
  以及 320/480 的 basename/完整路径分支；app 测试 125/125。
- 新增 `scenes/diff_phone_menu` 与 `docs/screenshots/diff-phone.png`、
  `diff-phone-files.png`（320×600 → 640×1200）；OCR 找到活动 tab
  `validators.ts (diff)`、`3 files`，选择器内 `validators.ts` / `shipping.ts` /
  `cart.spec.ts` / `handoff.md` 与 Showing / Open / Closed，上下文卡读作
  `File: validators.ts`。`diff.png`、`diff-narrow.png`、`diff-files.png` 重新生成后
  MD5 不变；验收截图增至 41 张，README 的截图数量与命令同步更新。
- 门禁：native/wasm check 0 errors，app 125/125，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 41 张。

## Round 60 Bots 手机宽度整幅右栏（2026-11-27）

- `compact_panel_width` 在 64 px 聊天预览会把右栏压到 320 px 以下时改为整幅窗口宽度：
  320 / 360 px 视口得到 320 / 360 px 右栏，384 px 起恢复 64 px 预览（右栏 320 px），
  400 px 下为 336 px，480 px 仍取存储的 400 px，超过 480 px 的存储宽度夹到 416 px。
  此前 320 px 下右栏只有 256 px，左侧留下 64 px 被遮罩压暗的聊天碎片，Home 标题和
  Activity 文案被迫提前截断。
- 整幅右栏仍保留顶部的紧凑 tab 图标、Home 单列 chips、标题换行和整行 Done means；
  关闭按钮、Escape 与侧栏抽屉优先级不变。480×600 的 `bots-panel-narrow.png`
  重新生成后 MD5 不变，确认平板抽屉布局没有回归。
- `narrow bots use drawers and keep the chat wide` 增加 320 / 360 / 384 / 400 px 的
  右栏宽度断言，连同既有 480 px 与 500 px 存储宽度夹紧用例；app 测试仍为 125/125。
- 新增 `docs/screenshots/bots-panel-phone.png`（320×600 → 640×1200）。像素检查确认
  `#181818` 右栏背景覆盖 x=0–639，不再有左侧聊天残条；OCR 找到
  `#41 Pay button ignores first tap` / `on Safari`、`In progress`、
  `Fix Safari Pay tap follow-up`、`Done means`、
  `The first tap on Pay works in Safari, and the` / `fix is live.`、
  `Add a comment...`、各条 `9:02AM`–`9:08AM` 时间戳，以及状态栏
  `38 %` / `maya-mbp` / `2 hosts`。验收截图增至 42 张，README 数量与命令同步。
- 门禁：native/wasm check 0 errors，app 125/125，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 42 张。

## Round 61 页面方向键的覆盖层守卫（2026-11-27）

- 新增 `page_arrow_blocked(model, drawer_open)`：modal / rename / delete / automation
  编辑器、帮助卡、上下文菜单、wordmark 页菜单、task 链接选择器，以及 Tasks composer /
  description 编辑、Bots 折叠/筛选/显示选项/状态菜单、Diff 文件选择器都会在页面级
  ↑/↓ 之前接管；compact sidebar 与 Bots item-panel 抽屉经 `drawer_open` 一并阻断。
  composer 补全菜单仍在最前面处理自己的 ↑/↓，不受影响。
- `enter_page_action` 同步改为 `enter_page_action(model, drawer_open)`：抽屉打开时
  页面级 Enter 返回 Noop，Search 结果与 Tasks / Automations 行不会在抽屉后面被激活；
  既有 modal / rename / delete / automation / help / context / app menu / task-link
  守卫保持不变。
- Bots 在 760 px 以下按 sidebar 或 item-panel 抽屉状态阻断，760 px 以上内联面板仍可
  用方向键浏览 fleet；其它页面在 720 px 以下 sidebar 抽屉打开时阻断，内联 sidebar 的
  宽窗导航保持原样。此前 Search / Tasks / Automations / Diff 在帮助卡或 app menu 后面
  仍会移动选中行，Bots 状态菜单打开时按 ↓ 也会换 bot 并关闭菜单。
- 新增回归测试 `page arrow navigation yields to overlays and drawers`：覆盖 8 种全局
  覆盖层/编辑器、Tasks 的 composer / 描述编辑 / 链接菜单、Bots 的状态/筛选/显示选项/折叠
  状态、Diff 文件菜单，以及 drawer_open 的真假分支；`page enter routes search and
  yields to composition and drawers` 增加抽屉打开时 Enter 为 Noop 的断言；app 测试
  增至 126/126。
- 本次不改变任何画面，验收截图仍为 42 张；README 的键盘说明补充覆盖层与抽屉行为。
- 门禁：native/wasm check 0 errors，app 126/126，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 42 张。

## Round 62 Bots Files 行内边距（2026-11-27）

- 新增 `panel_row_inner_width(width) = width - 40`：右栏 body 为 `width - 24`，减去
  row container 两侧各 8 px 内边距后即为 360 / 280 px（400 / 320 px 面板）。Chats 与
  Files 行统一使用该宽度，不再各自维护近似值。
- `panel_file_text_width(width) = panel_row_inner_width(width) - 71`：扣掉 28 px 文件
  图标、13 px chevron 与三个 10 px gap，400 px 面板得到 289 px 文本列，320 px 面板
  得到 209 px。此前 Files 行内容宽写成 `width - 32`、文本列写成 `width - 103`，
  比容器实际内宽多出 8 px，chevron 会贴到 container 右缘而 Chats 行仍保留 8 px gutter。
- `bots-files.png` 重新生成后 2560×1504；像素比较显示首行 chevron 最右像素由
  x=2527 移到 x=2511（8 logical px），路径 `src/checkout/PayButton.tsx` 与
  `acme-web · Safari first-tap Pay fix` 的 OCR 位置和文本保持不变，确认只修正右缘。
- 布局辅助测试新增 400 / 320 px 的 `panel_row_inner_width` 与 `panel_file_text_width`
  断言；app 测试仍为 126/126。验收截图仍为 42 张。
- 门禁：native/wasm check 0 errors，app 126/126，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 42 张。

## Round 63 手机宽度快捷键卡的标签（2026-11-27）

- 320 px 视口下快捷键卡内容列只有 240 px，13 px 的完整标签会越过 304 px 卡片右缘、
  一直顶到窗口 320 px：`Open Search from any screen`、
  `Switch to an open worktree tab` 与 `Create a worktree or save an edit` 都被裁切。
- 新增 `help_labels_compact(content_w) = content_w < 330`：低于 330 px 时改用十二条
  短动作文案（如 `Create or save`、`Switch worktree tab`），330 px 及以上保留完整
  句子；完整文案最长 215 px，330 px 内容柱留出的标签列有 226 px，刚好不裁切。
- `help-narrow.png`（320×600 → 640×1200）中十二行标签最右到 x≈272，落在 304 px
  卡片右缘内；键帽列保持不变。验收截图增至 43 张，README 数量与命令同步。
- 覆盖层测试新增 329/330 边界与 compact/full `Create or save` 文案断言；app 测试
  仍为 126/126。
- 门禁：native/wasm check 0 errors，app 126/126，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 43 张。

## Round 64 Diff 手机宽度输入框占位文案（2026-11-27）

- 320 px 视口下 Diff composer 的输入框只有 212 px，参考文案
  `Ask anything, @ to mention files, / for\ncommands` 的首行约需 314 px，实际会再折成
  三行并伸出 56 px 输入框；`commands` 落到字段之外，卡片也被撑高约 22 px。
- 新增 `diff_composer_placeholder(field_width)`：字段窄于 360 px 时改用与主 composer
  一致的单行 `Ask anything…`，360 px 及以上保留参考的两行文案。480 px 窄屏
  （372 px 字段）仍显示两行；overlay 只在字段窄于 430 px 时启用，430 px 及以上
  继续使用共享的单行完整文案，宽屏与参考布局不变。
- `diff-phone.png` 与 `diff-phone-files.png`（320×600 → 640×1200）重新生成；OCR 找到
  单行 `Ask anything…` 位于 y=956–1000，落在输入框内，footer 收回到 y=1086–1120，
  卡片底部距窗口 24 px。`diff-narrow.png` 重新生成后 480 px 下仍为
  `Ask anything, @ to mention files, / for` / `commands` 两行（y=957–1043）。
- `narrow diff stacks its panes` 增加 212 / 359 / 372 px 的占位文案断言与
  429 / 430 px 的 overlay 边界；app 测试增加断言后仍为 126/126。验收截图仍为 43 张。
- 门禁：native/wasm check 0 errors，app 126/126，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 43 张。

## Round 65 Bots 手机宽度输入框占位文案（2026-11-27）

- Bots composer 使用单行 44 px 输入框，完整占位文案约需 440 px；320 px 视口的字段
  只有 223 px，480 px 布局也只有 383 px，两处都会在单词中间截断（320 下停在
  `Ask anything, @ to mention bc`，480 下停在 `/ for comma`）。
- 新增 `bots_composer_placeholder(field_width)`：低于 320 px 使用与主 composer 一致的
  `Ask anything…`，320–459 px 使用 `Ask anything, @ bots or files, / for…`，460 px
  及以上保留完整文案。320 px 下文案收束到字段内，480 px 下仍保留提及/命令提示。
- 新增 `docs/screenshots/bots-phone.png`（320×600 → 640×1200），并重新生成
  `bots-narrow.png`（480×600 → 960×1200）。OCR 找到 `Ask anything…` 位于
  y=939–973，480 px 下 `Ask anything, @ bots or files, / for…` 位于 y=941–971，
  均未越过字段右缘；验收截图增至 44 张，README 数量与命令同步。
- 新增 `bots composer placeholder shortens at narrow widths` 测试，覆盖 223 / 383 /
  559 px 三档文案；app 测试增至 127/127。
- 门禁：native/wasm check 0 errors，app 127/127，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 44 张。

## Round 66 Search / Tasks 手机宽度筛选行（2026-11-27）

- Search 在 320–479 px 下，五个分类 pill 的标签/计数与右侧结果总数超过 32 px gutter：
  320 px 时总数延伸到 x≈304.5（内容右缘 288），360 px 时 `7 results` 到 x≈346.5
  （右缘 328），420 px 时总数在窗口右缘被截断成 `7re`。Tasks 在 320 px 下的 `6/6`
  也到 x≈309.5，超过列表 296 px 的右缘；360 px 的实际像素仍在内侧。
- 新增 `search_filters_compact(width) = width < 480`：低于 480 px 时 Search 使用
  `Trees` / `Chats` 短标签、6 px pill 内边距与 4 px 间距，同时保留五个分类的计数和
  结果总数；480 px 及以上继续使用完整的 `Worktrees` / `Sessions` 标签与 9/6 px 的
  原始间距，`search-narrow.png` 重新生成后 MD5 不变。
- 新增 `task_filter_pills_dense(width) = width < 360`：Tasks 的四个状态 pill 在手机
  宽度改用 6 px 内边距与 4 px 间距，`6/6` 总数收回到列表 24 px gutter 内；360 px
  及以上保持原布局，`tasks-list-narrow.png` 重新生成后 MD5 不变。
- 新增 `docs/screenshots/search-phone.png` 与 `tasks-list-phone.png`
  （320×600 → 640×1200）。OCR 找到 `All` / `Trees` / `Bots` / `Chats` / `Files`、
  `7` 与 `All 6` / `Mine 4` / `Needs 2` / `Done 2` / `6/6`；像素检查确认最右内容
  分别到 x=574 / 587，落在 576 / 592 px 的内容右缘内。验收截图增至 46 张，
  README 数量与命令同步。
- 新增 `phone filter rows tighten before their counts overflow` 测试，覆盖 479/480
  与 359/360 边界；app 测试增至 128/128。
- 门禁：native/wasm check 0 errors，app 128/128，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 46 张。

## Round 67 Tasks 手机宽度新建任务按钮行（2026-11-27）

- 320 px 下 Tasks 新建任务 composer 的 source / agent / Add 行实际宽约 292 logical px，
  在 `Add` 处延伸到 x=632 px（逻辑 316），比列表 296 px 的内容右缘多出 20 logical px，
  只剩 4 px 就贴到窗口边缘。该行要到 340 px 视口才刚好放得下。
- 新增 `task_composer_agent_compact(width) = width < 360` 与
  `task_composer_agent_label(kind, width)`：手机宽度下 Claude 的按钮文案由
  `Claude Code` 缩短为 `Claude`，Codex / Grok 保持原样；360 px 及以上仍显示完整
  `Claude Code`，480 px 的 `tasks-composer-narrow.png` MD5 不变。
- 新增 `docs/screenshots/tasks-composer-phone.png`（320×600 → 640×1200）。OCR 找到
  `GitHub` / `Claude` / `Add`，像素检查最右内容到 x=558，落在 592 px 内容右缘内；
  320 px 下三枚按钮都收在内容柱内，字段与空白标题提示不受影响。
  验收截图增至 47 张，README 数量与命令同步。
- 新增 `task composer shortens the agent label at phone widths` 测试，覆盖 359/360
  边界、Claude 的短/全文案与 Codex 不变；app 测试增至 129/129。
- 门禁：native/wasm check 0 errors，app 129/129，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 47 张。

## Round 68 手机宽度弹窗下拉与页头动作（2026-11-27）

- 320 px 下 Create worktree 的两个 select 各 112 px，扣除 12/10 px 内边距、16 px 图标、
  14 px chevron 与三个 8 px 间距后只剩 36 px 给文本；`acme-internal` / `mac-mini`
  会越过字段边界，右侧 chevron 甚至画到 x≈306 logical（字段右缘 280）。
- 新增 `select_value_width(width, icon_width)`，并用 `clip_left` 包裹 select value：
  手机宽度下文本收进 36 px 列，两个 chevron 都回到字段内约 14 px；automation 下拉
  传入 14 px 图标宽度。1280 px 的 `orca-create-worktree.png` /
  `automations-editor.png` MD5 不变。
- Automations 页头在 320 px 为短 `New` 预留 72 px（原 70 px），浅色按钮右缘从
  x=577 收到 x=572 output（286 logical），进入 288 px 内容右缘内 2 logical px；
  480 px 的 `automations-narrow.png` MD5 不变。
- 新增 `scene_tasks_link_phone_model()` 与 `scenes/tasks_link_phone`：320 px 下侧栏
  收起、详情单栏、工作树 picker 打开，`tasks-link-phone.png` 中
  `Choose a worktree` / `4 available` / 第一行选项与 `Close` 都落在 22 px inset 内
  （最右 ink x≈583 output）。
- 新增 `automations-phone.png`；验收截图 47 → 49。Search 手机宽度与 Diff 代码行审计：
  Search 无溢出；Diff 行尾省略号到 x≈636 output，由 shell `.clip()` 收在 320 px
  窗口内，与参考图的代码行边缘裁切一致，不改布局。
- `select values keep the chevron inside narrow fields` 覆盖 112 / 243 px 与 14 / 16 px
  图标三档，`automation_header_actions_width` 的 419/420 断言改为 72/148；
  app 测试 130/130。
- 门禁：native/wasm check 0 errors，app 130/130，web_wasm 1/1，两 target build 通过，
  `moon fmt --check` / `git diff --check` 通过；验收截图 49 张。

## Round 69 定时调度与 Diff 标签交互（2026-11-27）

- Automations 接入宿主 timer subscription：生产 program 每 30 秒把 frame time 映射为
  `AutomationTick`；enabled 且非 Manual 的计划在首次 tick 装上 `next_run_ms`，到期后
  走与 Run now 相同的成功路径（新增 run、更新 Runs today / Passed / attention）并
  重新 arm。关闭开关清掉 due，重新开启后下一次 tick 再 arm。
- daily / weekdays 采用 24h session cadence，Fridays 采用 7d，Manual 永不自动运行。
  `automation_clock_ms` 与 `next_run_ms` 都是 session 状态，重启后从零重新 arm，
  避免触发过期计划；表格 Schedule 列显示 `next in 30m` / `next in 1d` / `due now`。
- 新增 `scene_automations_scheduled_model()` 与 `scenes/automations_scheduled`；
  `automations-scheduled.png` 中 OCR 找到 `next in 1d`（两行）与 `next in 30m`，
  关闭状态的 Fridays 行保持无 due 文案。
- Diff 三个标签之间增加 4 px 间距，重新计算 tab / plus 宽度；每个标签的关闭 X 以及
  prev / next hunk、split / focus 工具栏按钮都有独立 hover 背景。文件 picker 锚点
  修正为包含最后一个 4 px 间隙，1280 / 480 / 320 下仍夹在左 pane 内。
- 重新生成六张 Diff 截图；1280 下 OCR 读到 `validators.ts (diff)` /
  `shipping.ts (diff)` / `cart.spec.ts (diff)`，480 保持 basename，320 活动标签
  仍显示 `(diff)`。
- 新增 `host ticks arm, fire and re-arm scheduled automations`：覆盖首次 arm、到期
  执行、计数 / attention、关闭清 due、重新开启 re-arm、manual run 与持久化重启复位。
  app 测试 131/131，web_wasm 1/1；验收截图 49 → 50。
- 门禁：native/wasm check 0 errors，两 target build 通过，`moon fmt --check` /
  `git diff --check` 通过；验收截图 50 张。

## Round 70 Create From 选中下划线（2026-11-27）

- 对照 `design/reference-create-worktree.jpg` 发现选中的 Smart chip 在参考图中有白色
  下划线，而实现只有文字提亮；`chip()` 现在在选中态内容下方绘制 2 px `fg_primary`
  规则线，宽度为 `width - 13`（至少 8 px），未选中与 hover 结构不变。
- 重新生成 `orca-create-worktree.png`、`orca-create-worktree-advanced.png` 与
  `orca-create-worktree-narrow.png`；1280 与 320 的 Smart 下方均可见规则线。
  七张主截图重生成时其余五个 scene 字节不变，`diff.png` 更新到 Round 69 之后的构建。
- 最终门禁：native check 0 errors，app 131/131，`linux_skia` native 与 `web_wasm`
  wasm-gc build 通过，`moon fmt --check` / `git diff --check` 通过，验收截图 50 张。
- Phase 3 验收清单其余条目由既有 Round 25–69 与 131 条测试覆盖，无新增遗留；
  仅有 SPEC 已列出的非目标（无真实后端 / 文件系统索引 / 墙钟自动化 / 位图 mascot）。

## Round 71 Bots 行距与最终收尾（2026-11-27）

- 桌面 Bots 主体按参考图收紧节奏：nav、侧栏滚动内容与会话组使用紧凑间距；session 行
  高 26 px、行间 1 px，会话组左缩进 21 px，使 Home / Claude / Codex / Slack 的层级
  与参考图一致且不挤压 bot 卡片。
- Claude / Codex 会话行采用 12 px 左侧 + 2 px 右侧的 glyph 引导与 6 px 图标间距；
  两者标签字号 10.75 px，Home 与 Slack 保持 11.5 px。Claude 仍为 10 px 琥珀 spinner，
  Codex 改用 10 px 绿色描边 `check_circle_icon`；时间戳保留 1.5 px 右内缩。
- Bots 右栏 Home 面包屑改为 12 px `arrow-left`、12 px Home / bot 名称、16 px mascot、
  5 px 行距与名称前 3 px spacer；整行仍是 Home Chat 点击区并保留 hover 背景。
- Diff validator gutter 的尾部 context 行重新编号为 31 / 32，删除行的行号留空，
  第 26 行仍为 `  })`；其它 Diff 行与控件未移动。
- 以 960×600 对照 Create worktree 参考图，卡片范围 x≈229–730、上下色带
  y≈150–530、主操作 y≈500–526 均吻合，未发现确定缺失的控件或尺寸问题，因此没有
  添加推测性 UI。
- 十张 Bots 截图在最终修改后重生成：6 张 2560×1504（`orca-bots`、`bots-files`、
  `bots-status`、`bots-new`、`bots-new-chat`、`bots-dictation`），2 张 960×1200
  （`bots-narrow`、`bots-panel-narrow`），2 张 640×1200（`bots-panel-phone`、
  `bots-phone`）。OCR 找到全部关键会话标签与控件；Home `88–211` vs `88–210`、
  Safari `145–310` vs `147–307`、WebKit `145–327` vs `146–327`、Slack
  `150–379` vs `147–380`，时间戳误差约 2 px，纵向节奏误差 0–3 px。
- 最终门禁：native / wasm-gc `moon check` 0 errors，app 131/131，web_wasm 1/1，
  `linux_skia` native 与 `web_wasm` wasm-gc build 通过，`moon fmt --check` /
  `git diff --check` 通过，验收截图 50 张。除已列出的非目标（无真实后端 / 文件系统
  索引 / 跨重启墙钟自动化 / 位图 mascot）外，Phase 2/3 清单没有未完成项。

未实现（有意留空）：
- 真实网络/agent 后端；除上述持久化字段外，其余演示数据仍在内存中播种。
- Build 时扫描真实文件系统的索引；automation 只在应用打开期间按 session cadence
  调度，未实现跨重启的墙钟日历触发。
- Bots 与 diff 屏的位图素材（mascot 仍为矢量近似）。
