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
- [ ] window 1280×752; sidebar exactly 280 wide, `#2a2a2a`; main `#151515`
- [ ] 36px title bar: traffic lights, "Orca" wordmark, panel toggle; tab strip with one active tab
      (Claude icon + title + X) and `+`; active tab `#151515`, strip `#171717`
- [ ] sidebar nav Search/Tasks/Automations; Projects header with 3 icon buttons; two machine
      cards (Local Mac 1; mac-mini mac-mini.local 3); acme-web globe + acme-internal folder
- [ ] worktrees: checkout-flow-v2 (primary/branch/2 agents), eu-promo-checkout **selected**
      (border white/24 + bg #3a3a3a, 3 agents), handoff summary, checks-detail-link
- [ ] agent rows show vendor icon, name, model, time, amber running spinner; right-aligned times
- [ ] chat column max 540 centered; user bubble right #252525 radius 14; "Worked for 4s" row;
      assistant paragraph; two worker cards (#171717 radius 14, one focused ring); closing
      paragraph; "Working…" row
- [ ] composer max 550, bg white/4, border white/9, radius 14; placeholder; +, yellow Full access,
      Opus 5.5, mic, circular send
- [ ] typography: Inter; 13/14 body sizes; branch names in mono 11; muted colors match tokens
- [ ] screenshot has no clipped/overlapping text; paragraphs wrap; icons not missing glyphs

Modal (`scenes/modal`) vs `design/reference-create-worktree.jpg`:
- [ ] full-window dim overlay rgba(0,0,0,0.6); 550-wide dialog #171717 radius 16
- [ ] Project/Run on selects; Create From chips (Smart selected); name input; Agent select;
      Advanced; Create more toggle; white primary button with ⌘↵
- [ ] field labels/secondary text legible; no stock Material blue anywhere

Bots (`scenes/bots`) vs `design/reference-bots.png`:
- [ ] 272 sidebar with Bots section (Scout selected + nested sessions), other bots, Projects row
- [ ] center Scout chat with tab `Scout`, context paragraphs, tool rows, working row, user bubble,
      composer, footer breadcrumb
- [ ] right item panel 380 wide: Home tab bar, #41 title, status row, chips, Done means, Activity,
      Scout message card, comment composer
- [ ] bottom status bar CPU/GPU + host

Interactions:
- [ ] select worktree switches tab/transcript; `+` opens modal; create worktree adds + selects
- [ ] close tab falls back; send appends user + assistant and clears draft; worked row toggles
- [ ] nav Bots opens Bots screen; backend target web builds

Deliverables:
- [ ] README with screenshots, feature mapping, run instructions
- [ ] docs/screenshots/orca.png, orca-create-worktree.png, orca-bots.png
- [ ] item 1 updated with results
