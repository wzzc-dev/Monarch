# Phase 3 — Diff review + line note (optional third screen)

Reference: `design/reference-diff.jpg` (960×600 crop; app frame omitted). Only after phase 2.

Layout at 1280×752: two equal 50/50 panes separated by a 1px
`rgba(255,255,255,0.07)` divider. The code area scrolls inside the left pane.
Diff pane background `#1D1D1D`, chat pane `#151515`; chat copy 17.5/30, note copy
17.5/28, and code mono 18/24.

## Left — diff pane

- tab strip 36 bg `#171717`: tab `validators.ts (diff)` with close X, plus button;
  the active tab uses the pane's `#1D1D1D` so it merges into the code area.
- toolbar 32: 180 px path column (18 px `#929292`; long paths clip with an ellipsis),
  pill `✨ AI notes 1` (violet leading sparkle, muted trailing sparkle, bg white/6,
  radius 6, 17 px), right icon buttons (arrow-up, arrow-down, split/columns) with an
  18 px gap and a 25 px right inset at the 480 px reference pane; narrower panes tighten
  both to keep the pill and controls on-screen.
- review verdict: Approve / Request changes chips live in the chat pane's context card and
  only appear once the run has stopped (the reference shows the card while `Working for 7s`).
- code area: 24 high per line, bg `#1D1D1D`. Gutter line numbers mono 18 `#6f6f6f` right
  aligned 41 wide, then a 23 px change-marker column. Code 18 mono `#c0c0c0`.
- context/added/removed line tint: added `#373C29` with `+` marker green, removed `#491716`
  with `-` marker red (values sampled from the reference); syntax colors muted
  (keywords #c0c0c0, strings can stay default).
- sample content (from reference):
  ```
  21  name: z.string().min(1),
  22  street: z.string().min(1),
  23  city: z.string().min(1),
  24  postalCode: z.string().trim(),
  25  country: z.enum(COUNTRIES),
  26  })
  27 + .refine((a) => postalPattern(a.country…
  28 + message: "Enter a valid postal code",
  29 + path: ["postalCode"],
  30 + });
  31 - });
  32
  33 export type Address = z.infer<typeof …
  ```
- note card opened inline under line 27 (x≈88, width 360 in logical px; narrow panes shrink
  it) and pushing later rows down:
  bg `#212121`, border white/10, radius 12, padding 16 left / 14 right / 12 top / 4
  bottom, shadow. Header row: `Note line 27 sent`
  17.5 `#acacac` + right icons (send, edit pencil, trash). Body 17.5/28 `#f0f0f0`: “Also reject PO
  boxes when shipping is express”.
- the code area scrolls when the stacked file rows and note card exceed the pane height
  (the compact layout splits the available height 50/50: at 480×600 the top pane keeps
  208.5 px of code after its 91 px chrome, and the chat has 124.5 px above its 138 px
  composer, up from 64.5 px, so the seeded context/comment card is legible; narrow panes
  also widen the note card so the seeded note stays whole).

## Right — chat pane

- header 36: title `Tighten address validation` with Claude icon, close X, plus.
- transcript has no extra top padding. A 78%-wide context bubble (bg `#252525`, radius 10,
  padding 12, 12/18 `#c0c0c0`, mono-ish key labels) starts right after the header and its
  first row is the `File: src/checkout/validators.ts` caption:
  - `File:` + mono path, 11 `#6f6f6f` / `#c0c0c0`
  - `Line: 27`
  - `User comment: “Also reject PO boxes when shipping is express”`
  - the Approve / Request changes chips slot in under the comment after the run stops
  - divider row `Working for 7s` 12 `#929292`.
  - assistant paragraph 17.5/30 `#c0c0c0`: “I’ll add an express-shipping rule next to the postal
    refine.”
  - tool rows 24 with a 14.5 px gap between them: `Read shipping.ts`; `Edited validators.ts`
    with right `+4` in green; then `Working…` with spinner.
- composer on an `#1D1D1D` card (same as phase 1) with a two-line 18/28 placeholder
  `Ask anything, @ to mention files, / for commands`, left +, bottom right `Full access`
  yellow shield, `Opus 5.5`, mic, and a square stop button (dark circle, square glyph)
  instead of send while working. At 960 the card is 436 px wide and ~113 px tall, with a
  9.5 px field→footer gap and 23 px above the window edge (136 px total); there is no
  breadcrumb under it.

Interactions: clicking a diff line selects it; the note card can be dismissed/reopened; the
card's send icon resends the note to the worker, pencil loads it back into the composer for
an in-place edit, and x deletes the note; chat composer send appends a message and a tool
row; stop button clears the working row. The toolbar arrows jump to the previous/next changed
hunk; ↑/↓ move the selection one line within the active file, Shift+↑/↓ extend it into a
note range (card header `Note lines 24–28`); the split/columns button toggles a focus mode
that hides the chat pane and lets the diff fill the window (Escape restores the split), and
Escape closes an open note before leaving focus. A file tab's X closes that tab (the last
open tab cannot be closed) and an active tab falls back to the next open file.
The composer mic runs the same deterministic local dictation demo as the other composers:
it appends `The zero-rate fallback looks right.` to the diff draft, tints the mic amber,
and clears the hint on the next edit, completion pick or send; no audio is captured.

Screenshot: `scenes/diff`, `docs/screenshots/diff.png`.

## Worktree review contexts (Round 55)

The reference scene is `checkout-flow-v2`; **Show diff** from a worktree context
menu opens that worktree's review instead of reusing checkout:

- `checkout-flow-v2` — “Tighten address validation”, Claude, the reference
  `validators.ts` / `shipping.ts` / `cart.spec.ts` / closed `handoff.md` set, working.
- `eu-promo-checkout` — “Fix ACME-412: EU promo codes skip regional tax”, Claude,
  `rules.ts` / `promo.test.ts` / `cart.ts` / closed `CHANGELOG.md`, working.
- `agent-handoff-summary` — “Improve agent handoff summary”, Codex,
  `handoff.md` / `handoff.template.md` / closed `handoff.ts` / closed `README.md`, working.
- `checks-detail-link` — “Fix CI checks detail link”, Claude,
  `checks.ts` / `checks.test.ts` / `ci.yml` / closed `CHECKS.md`, stopped with verdicts.

All profiles keep four tab slots so the persisted `diff_closed` mask remains
compatible. Switching to another worktree resets `diff_file`, selection/anchor,
open note, draft, notes, verdict, extra messages and working state; reopening the
same worktree keeps the current review. `diff_worktree` and `diff_working` are
persisted alongside the existing diff fields. The header title/icon and the
intro/tool-row copy come from the active worktree, and the context card's File
path follows the active file. The chat activity label reads `Worked for 7s` once
the checks review is stopped.

Screenshot: `scenes/diff_checks`, `docs/screenshots/diff-checks.png` (checks
worktree at 1280×752).
