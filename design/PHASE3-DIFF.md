# Phase 3 — Diff review + line note (optional third screen)

Reference: `design/reference-diff.jpg` (960×600 crop; app frame omitted). Only after phase 2.

Layout at 1280×752: two panes split 62/38 by a 1px `rgba(255,255,255,0.07)` divider.
Background `#151515`; all text 12–14; mono 12 for code.

## Left — diff pane

- tab strip 36 bg `#171717`: tab `validators.ts (diff)` with close X, plus button.
- toolbar 32: truncated file path `src/checkout/valid…` 12 `#929292`, pill `✨ AI notes 1`
  (bg white/6, radius 6, 11px), right icon buttons (arrow-up, arrow-down, split/columns).
- code area: 32 high per line, bg `#151515`. Gutter line numbers 11 `#6f6f6f` right aligned 36
  wide. Code 12 mono `#c0c0c0`.
- context/added/removed line tint: added `rgba(52,211,153,0.12)` with `+` marker green,
  removed `rgba(248,113,113,0.14)` with `-` marker red; syntax colors muted (keywords #c0c0c0,
  strings can stay default).
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
- floating note card overlaying the code around line 27 (x≈96, width 370): bg `#1c1c1c`,
  border white/10, radius 12, padding 14, shadow. Header row: `Note line 27 sent` 12 `#acacac`
  + right icons (send, edit pencil, trash). Body 14/20 `#f0f0f0`: “Also reject PO boxes when
  shipping is express”.

## Right — chat pane

- header 36: title `Tighten address validation` with Claude icon, close X, plus.
- transcript max width ~ (pane width - 32), padding 16:
  - top context card (bg #202020, radius 10, padding 12, 12/18 `#c0c0c0`, mono-ish key labels):
    `File: src/checkout/validators.ts` / `Line: 27` / `User comment: “Also reject PO boxes when
    shipping is express”`
  - divider row `Working for 7s` 12 `#929292`.
  - assistant paragraph 14/20 `#c0c0c0`: “I’ll add an express-shipping rule next to the postal
    refine.”
  - tool rows 24: `Read shipping.ts`; `Edited validators.ts` with right `+4` in green; then
    `Working…` with spinner.
- composer identical to phase 1 but placeholder `Ask anything, @ to mention files, / for
  commands`, left +, bottom right `Full access` yellow shield, `Opus 5.5`, mic, and a square stop
  button (dark circle, square glyph) instead of send while working.

Interactions: clicking a diff line selects it; the note card can be dismissed/reopened; chat
composer send appends a message and a tool row; stop button clears the working row. Optional.

Screenshot: `scenes/diff`, `docs/screenshots/orca-diff.png`.
