///|
/// Diff pane share of the 1280 px reference split (two equal panes).
let diff_split : Double = 0.50

///|
/// One rendered line in the diff review.
#derive(Eq)
enum DiffKind {
  DiffContext
  DiffAdded
  DiffRemoved
}

///|
priv struct DiffLine {
  number : String
  kind : DiffKind
  text : String
}

///|
let validators_lines : Array[DiffLine] = [
  { number: "21", kind: DiffContext, text: "    name: z.string().min(1),", },
  { number: "22", kind: DiffContext, text: "    street: z.string().min(1),", },
  { number: "23", kind: DiffContext, text: "    city: z.string().min(1),", },
  {
    number: "24",
    kind: DiffContext,
    text: "    postalCode: z.string().trim(),",
  },
  { number: "25", kind: DiffContext, text: "    country: z.enum(COUNTRIES),", },
  { number: "26", kind: DiffContext, text: "  })", },
  {
    number: "27",
    kind: DiffAdded,
    text: "  .refine((a) => postalPattern(a.country, a.postalCode), {",
  },
  {
    number: "28",
    kind: DiffAdded,
    text: "    message: \"Enter a valid postal code\",",
  },
  { number: "29", kind: DiffAdded, text: "    path: [\"postalCode\"],", },
  { number: "30", kind: DiffAdded, text: "  });", },
  { number: "", kind: DiffRemoved, text: "  });", },
  { number: "31", kind: DiffContext, text: "", },
  {
    number: "32",
    kind: DiffContext,
    text: "export type Address = z.infer<typeof AddressSchema>",
  },
]

///|
let shipping_lines : Array[DiffLine] = [
  {
    number: "64",
    kind: DiffContext,
    text: "export function estimateShipping(address: Address) {",
  },
  {
    number: "65",
    kind: DiffContext,
    text: "  const zone = zoneFor(address.country);",
  },
  {
    number: "66",
    kind: DiffRemoved,
    text: "  return zone.express ? EXPRESS_RATE : STANDARD_RATE;",
  },
  {
    number: "67",
    kind: DiffAdded,
    text: "  const poBox = PO_BOX_PATTERN.test(address.street);",
  },
  { number: "68", kind: DiffAdded, text: "  if (zone.express && poBox) {", },
  {
    number: "69",
    kind: DiffAdded,
    text: "    throw new Error(\"Express shipping is not available for PO boxes\");",
  },
  { number: "70", kind: DiffAdded, text: "  }", },
  {
    number: "71",
    kind: DiffContext,
    text: "  return zone.express ? EXPRESS_RATE : STANDARD_RATE;",
  },
  { number: "72", kind: DiffContext, text: "}", },
]

///|
let cart_lines : Array[DiffLine] = [
  {
    number: "9",
    kind: DiffContext,
    text: "test(\"rejects PO boxes for express shipping\", async () => {",
  },
  {
    number: "10",
    kind: DiffAdded,
    text: "  const address = { street: \"PO Box 4021\", country: \"US\" };",
  },
  {
    number: "11",
    kind: DiffAdded,
    text: "  await expect(estimateShipping(address)).rejects.toThrow(/PO boxes/);",
  },
  { number: "12", kind: DiffContext, text: "});", },
  { number: "13", kind: DiffAdded, text: "", },
  {
    number: "14",
    kind: DiffAdded,
    text: "test(\"keeps standard shipping for PO boxes\", async () => {",
  },
  {
    number: "15",
    kind: DiffAdded,
    text: "  const rate = estimateShipping({ ...poBox, country: \"CA\" });",
  },
  {
    number: "16",
    kind: DiffAdded,
    text: "  expect(rate).toBe(STANDARD_RATE);",
  },
  { number: "17", kind: DiffContext, text: "});", },
]

///|
let handoff_lines : Array[DiffLine] = [
  { number: "8", kind: DiffContext, text: "## Handoff", },
  { number: "9", kind: DiffRemoved, text: "Workers are still running.", },
  {
    number: "10",
    kind: DiffAdded,
    text: "Status: tax rules landed; promo tests are green.",
  },
  {
    number: "11",
    kind: DiffAdded,
    text: "Open: confirm EU20 rounding with finance.",
  },
  {
    number: "12",
    kind: DiffAdded,
    text: "Touched: src/tax/rules.ts, src/tax/promo.test.ts",
  },
  { number: "13", kind: DiffContext, text: "", },
]

///|
let eu_rules_lines : Array[DiffLine] = [
  {
    number: "7",
    kind: DiffContext,
    text: "export function taxFor(order: Order) {",
  },
  {
    number: "8",
    kind: DiffContext,
    text: "  const taxable = sumItems(order.items);",
  },
  {
    number: "9",
    kind: DiffRemoved,
    text: "  const tax = regionalTax(taxable, order.region);",
  },
  {
    number: "10",
    kind: DiffAdded,
    text: "  const discounted = taxable - promoDiscount(order);",
  },
  {
    number: "11",
    kind: DiffAdded,
    text: "  return regionalTax(discounted, order.region);",
  },
  { number: "12", kind: DiffContext, text: "}", },
]

///|
let eu_promo_test_lines : Array[DiffLine] = [
  {
    number: "31",
    kind: DiffContext,
    text: "test(\"applies EU20 after regional tax\", () => {",
  },
  { number: "32", kind: DiffAdded, text: "  const total = taxFor(eu20Order);", },
  { number: "33", kind: DiffAdded, text: "  expect(total).toBe(118.80);", },
  { number: "34", kind: DiffContext, text: "});", },
  {
    number: "35",
    kind: DiffAdded,
    text: "test(\"keeps EU10 rounding stable\", () => {",
  },
  {
    number: "36",
    kind: DiffAdded,
    text: "  expect(taxFor(eu10Order)).toBe(59.40);",
  },
  { number: "37", kind: DiffContext, text: "});", },
]

///|
let eu_cart_lines : Array[DiffLine] = [
  {
    number: "54",
    kind: DiffContext,
    text: "export function totalFor(cart: Cart) {",
  },
  {
    number: "55",
    kind: DiffRemoved,
    text: "  return regionalTax(cart.subtotal);",
  },
  { number: "56", kind: DiffAdded, text: "  return taxFor(cart.order);", },
  { number: "57", kind: DiffContext, text: "}", },
]

///|
let eu_changelog_lines : Array[DiffLine] = [
  { number: "12", kind: DiffContext, text: "## 4.12", },
  { number: "13", kind: DiffRemoved, text: "- Tax fix pending.", },
  {
    number: "14",
    kind: DiffAdded,
    text: "+ EU promo codes now apply after regional tax.",
  },
  {
    number: "15",
    kind: DiffAdded,
    text: "+ 8 regression tests cover EU10 and EU20.",
  },
]

///|
let handoff_template_lines : Array[DiffLine] = [
  { number: "3", kind: DiffContext, text: "## Current status", },
  { number: "4", kind: DiffRemoved, text: "TBD", },
  {
    number: "5",
    kind: DiffAdded,
    text: "All workers are done; promo tax landed.",
  },
  {
    number: "6",
    kind: DiffAdded,
    text: "Open: confirm EU20 rounding with finance.",
  },
  { number: "7", kind: DiffContext, text: "", },
  { number: "8", kind: DiffContext, text: "## Files touched", },
  { number: "9", kind: DiffAdded, text: "- src/tax/rules.ts", },
  { number: "10", kind: DiffAdded, text: "- src/tax/promo.test.ts", },
]

///|
let handoff_code_lines : Array[DiffLine] = [
  {
    number: "18",
    kind: DiffContext,
    text: "export function handoffNote(run: Run) {",
  },
  {
    number: "19",
    kind: DiffRemoved,
    text: "  return run.transcript.join(\"\\n\");",
  },
  { number: "20", kind: DiffAdded, text: "  return [", },
  { number: "21", kind: DiffAdded, text: "    `Status: ${run.status}`,", },
  { number: "22", kind: DiffAdded, text: "    `Open: ${run.openQuestion}`,", },
  {
    number: "23",
    kind: DiffAdded,
    text: "    `Touched: ${run.files.join(\", \")}`,",
  },
  { number: "24", kind: DiffAdded, text: "  ].join(\"\\n\");", },
  { number: "25", kind: DiffContext, text: "}", },
]

///|
let handoff_readme_lines : Array[DiffLine] = [
  { number: "41", kind: DiffContext, text: "### Worker handoff", },
  { number: "42", kind: DiffRemoved, text: "Paste the full transcript.", },
  {
    number: "43",
    kind: DiffAdded,
    text: "Lead with status, the open question and touched files.",
  },
  { number: "44", kind: DiffContext, text: "", },
]

///|
let checks_lines : Array[DiffLine] = [
  {
    number: "27",
    kind: DiffContext,
    text: "export function checksUrl(run: CheckRun) {",
  },
  {
    number: "28",
    kind: DiffRemoved,
    text: "  return `/actions/runs/${run.workflowId}`;",
  },
  {
    number: "29",
    kind: DiffAdded,
    text: "  const failing = run.jobs.find((job) => job.conclusion === \"failure\");",
  },
  {
    number: "30",
    kind: DiffAdded,
    text: "  const jobId = failing?.id ?? run.jobs[0]?.id;",
  },
  {
    number: "31",
    kind: DiffAdded,
    text: "  return `/actions/runs/${run.id}/job/${jobId}`;",
  },
  { number: "32", kind: DiffContext, text: "}", },
]

///|
let checks_test_lines : Array[DiffLine] = [
  {
    number: "9",
    kind: DiffContext,
    text: "test(\"links the failing job\", () => {",
  },
  {
    number: "10",
    kind: DiffAdded,
    text: "  const run = runWithFailingJob(7);",
  },
  {
    number: "11",
    kind: DiffAdded,
    text: "  expect(checksUrl(run)).toContain(\"/job/7\");",
  },
  { number: "12", kind: DiffContext, text: "});", },
  { number: "13", kind: DiffAdded, text: "", },
  {
    number: "14",
    kind: DiffAdded,
    text: "test(\"falls back to the first job\", () => {",
  },
  {
    number: "15",
    kind: DiffAdded,
    text: "  expect(checksUrl(greenRun)).toContain(\"/job/2\");",
  },
  { number: "16", kind: DiffContext, text: "});", },
]

///|
let checks_workflow_lines : Array[DiffLine] = [
  { number: "12", kind: DiffContext, text: "jobs:", },
  { number: "13", kind: DiffContext, text: "  checks:", },
  { number: "14", kind: DiffRemoved, text: "    name: checks", },
  { number: "15", kind: DiffAdded, text: "    name: checks · detail link", },
  { number: "16", kind: DiffAdded, text: "    timeout-minutes: 12", },
  { number: "17", kind: DiffContext, text: "    steps:", },
]

///|
let checks_docs_lines : Array[DiffLine] = [
  { number: "5", kind: DiffContext, text: "## Checks", },
  { number: "6", kind: DiffRemoved, text: "Open the workflow summary.", },
  {
    number: "7",
    kind: DiffAdded,
    text: "Use the checks affordance to open the failing job.",
  },
]

///|
priv struct DiffFile {
  name : String
  path : String
  lines : Array[DiffLine]
}

///|
let checkout_diff_files : Array[DiffFile] = [
  {
    name: "validators.ts",
    path: "src/checkout/validators.ts",
    lines: validators_lines,
  },
  {
    name: "shipping.ts",
    path: "src/checkout/shipping.ts",
    lines: shipping_lines,
  },
  {
    name: "cart.spec.ts",
    path: "src/checkout/e2e/cart.spec.ts",
    lines: cart_lines,
  },
  { name: "handoff.md", path: "docs/handoff.md", lines: handoff_lines, },
]

///|
let eu_promo_diff_files : Array[DiffFile] = [
  { name: "rules.ts", path: "src/tax/rules.ts", lines: eu_rules_lines, },
  {
    name: "promo.test.ts",
    path: "src/tax/promo.test.ts",
    lines: eu_promo_test_lines,
  },
  { name: "cart.ts", path: "src/checkout/cart.ts", lines: eu_cart_lines, },
  {
    name: "CHANGELOG.md",
    path: "docs/CHANGELOG.md",
    lines: eu_changelog_lines,
  },
]

///|
let handoff_diff_files : Array[DiffFile] = [
  { name: "handoff.md", path: "docs/handoff.md", lines: handoff_lines, },
  {
    name: "handoff.template.md",
    path: "docs/handoff.template.md",
    lines: handoff_template_lines,
  },
  {
    name: "handoff.ts",
    path: "src/agents/handoff.ts",
    lines: handoff_code_lines,
  },
  { name: "README.md", path: "docs/README.md", lines: handoff_readme_lines, },
]

///|
let checks_diff_files : Array[DiffFile] = [
  { name: "checks.ts", path: "src/ci/checks.ts", lines: checks_lines, },
  {
    name: "checks.test.ts",
    path: "src/ci/checks.test.ts",
    lines: checks_test_lines,
  },
  {
    name: "ci.yml",
    path: ".github/workflows/ci.yml",
    lines: checks_workflow_lines,
  },
  { name: "CHECKS.md", path: "docs/CHECKS.md", lines: checks_docs_lines, },
]

///|
fn diff_files(worktree : String) -> Array[DiffFile] {
  match worktree {
    "eu-promo-checkout" => eu_promo_diff_files
    "agent-handoff-summary" => handoff_diff_files
    "checks-detail-link" => checks_diff_files
    _ => checkout_diff_files
  }
}

///|
fn diff_file_at(worktree : String, index : Int32) -> DiffFile {
  let files = diff_files(worktree)
  if index >= 0 && index < files.length() {
    files[index]
  } else {
    files[0]
  }
}

///|
pub fn diff_file_count(model : Model) -> Int32 {
  let mut count = 0
  let mut index = 0
  while index < model.diff_closed.length() {
    if !model.diff_closed[index] {
      count = count + 1
    }
    index = index + 1
  }
  count
}

///|
/// A file tab is closable only while another file tab stays open.
pub fn diff_tab_closable(model : Model, index : Int32) -> Bool {
  index >= 0 &&
  index < model.diff_closed.length() &&
  !model.diff_closed[index] &&
  diff_file_count(model) > 1
}

///|
pub fn diff_file_name(index : Int32) -> String {
  diff_file_at("checkout-flow-v2", index).name
}

///|
/// The active review's file name at `index` (checkout names remain the default
/// for callers that only need the reference set).
pub fn diff_file_name_for(model : Model, index : Int32) -> String {
  diff_file_at(model.diff_worktree, index).name
}

///|
fn diff_file_path(model : Model, index : Int32) -> String {
  diff_file_at(model.diff_worktree, index).path
}

///|
fn diff_file_lines(model : Model, index : Int32) -> Array[DiffLine] {
  diff_file_at(model.diff_worktree, index).lines
}

///|
pub fn diff_line_count(model : Model) -> Int32 {
  diff_file_lines(model, model.diff_file).length()
}

///|
/// Header title for the active review, following the worktree selected by
/// "Show diff" instead of always reading the checkout reference.
pub fn diff_review_title(model : Model) -> String {
  match find_worktree(model, model.diff_worktree) {
    Some(worktree) => worktree.tab_title
    None =>
      match model.diff_worktree {
        "eu-promo-checkout" => "Fix ACME-412: EU promo codes skip regional tax"
        "agent-handoff-summary" => "Improve agent handoff summary"
        "checks-detail-link" => "Fix CI checks detail link"
        _ => "Tighten address validation"
      }
  }
}

///|
pub fn diff_review_agent(model : Model) -> AgentKind {
  match find_worktree(model, model.diff_worktree) {
    Some(worktree) =>
      if worktree.agents.is_empty() {
        Claude
      } else {
        worktree.agents[0].kind
      }
    None =>
      if model.diff_worktree == "agent-handoff-summary" {
        Codex
      } else {
        Claude
      }
  }
}

///|
priv struct DiffReviewCopy {
  intro : String
  read_file : String
  edited_file : String
  edit_delta : String
}

///|
fn diff_review_copy(model : Model) -> DiffReviewCopy {
  match model.diff_worktree {
    "eu-promo-checkout" =>
      {
        intro: "I’ll reorder the promo discount so regional VAT is applied first.",
        read_file: "Read rules.ts",
        edited_file: "Edited promo.test.ts",
        edit_delta: "+8",
      }
    "agent-handoff-summary" =>
      {
        intro: "I’ll lead the handoff with status, the open question and touched files.",
        read_file: "Read handoff.md",
        edited_file: "Edited handoff.ts",
        edit_delta: "+4",
      }
    "checks-detail-link" =>
      {
        intro: "I’ll point the checks affordance at the failing job run.",
        read_file: "Read checks.ts",
        edited_file: "Edited checks.ts",
        edit_delta: "+2",
      }
    _ =>
      {
        intro: "I’ll add an express-shipping rule next to the postal refine.",
        read_file: "Read shipping.ts",
        edited_file: "Edited validators.ts",
        edit_delta: "+4",
      }
  }
}

///|
fn diff_line_background(kind : DiffKind) -> @graphics.Color {
  match kind {
    DiffAdded => bg_diff_add
    DiffRemoved => bg_diff_del
    DiffContext => @graphics.Color::transparent()
  }
}

///|
fn diff_marker(kind : DiffKind) -> @moui.View[Msg] {
  let color = match kind {
    DiffAdded => fg_diff_add
    DiffRemoved => fg_diff_del
    DiffContext => fg_dim
  }
  let mark = match kind {
    DiffAdded => "+"
    DiffRemoved => "-"
    DiffContext => " "
  }
  @views.container(
    txt(mark, 16.0, 600, color),
    width=23.0,
    height=24.0,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
fn diff_line_row(
  line : DiffLine,
  index : Int32,
  selected : Bool,
  in_range : Bool,
  width : Double,
  hovered : Bool,
) -> @moui.View[Msg] {
  let fg = match line.kind {
    DiffAdded => fg_primary
    DiffRemoved => fg_body
    DiffContext => fg_body
  }
  let number = @views.text(line.number, wrap=false, align=TextEnd)
    .font(mono(18.0, 400))
    .foreground(if selected { fg_muted } else { fg_dim })
  let max_chars = ((width - 94.0) / 10.4).to_int()
  let code = @views.text(
      truncate_chars(line.text, max_chars),
      wrap=false,
      align=TextStart,
    )
    .font(mono(18.0, 400))
    .foreground(fg)
  let content = @views.row(
    [
      @views.container(
        number,
        width=41.0,
        background=@graphics.Color::transparent(),
        padding=0.0,
      ),
      diff_marker(line.kind),
      code,
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=width - 22.0, height=24.0)
  @views.container(
    @views.padding_edges(content, left=14.0, right=8.0),
    width~,
    height=24.0,
    background=if in_range && line.kind == DiffContext {
      white_a(0.05)
    } else if hovered && line.kind == DiffContext {
      white_a(0.03)
    } else {
      diff_line_background(line.kind)
    },
    border=if selected {
      Some(border_of(white_a(0.24), 1.0))
    } else if in_range {
      Some(border_of(white_a(0.12), 1.0))
    } else {
      None
    },
    padding=0.0,
  )
  .on_tap(SelectDiffLine(index))
  .on_hover(fn(entered) { Hover("diff-\{index}", entered) })
}

///|
/// Width for each file tab once the strip's plus button has its share.
fn diff_tab_width(count : Int32, width : Double) -> Double {
  let gaps = count.to_double() * 4.0
  let available = width - 38.0 - gaps
  let divisor = match count {
    4 => 4.0
    3 => 3.0
    2 => 2.0
    _ => 1.0
  }
  let tab_width = available / divisor
  if tab_width > 238.0 {
    238.0
  } else {
    tab_width
  }
}

///|
/// Below 120 px per tab the strip stops painting every label and focuses the
/// active file; the picker button carries the remaining files.
fn diff_tab_phone_mode(model : Model, pane_width : Double) -> Bool {
  diff_tab_width(diff_file_count(model), pane_width - 8.0) < 120.0
}

///|
/// On phone widths only the active open file gets a tab. The file picker still
/// lists every open and closed file, so switching and restoring stay reachable.
pub fn diff_tab_visible(
  model : Model,
  index : Int32,
  pane_width : Double,
) -> Bool {
  if index < 0 ||
    index >= model.diff_closed.length() ||
    model.diff_closed[index] {
    false
  } else if diff_tab_phone_mode(model, pane_width) {
    index == model.diff_file
  } else {
    true
  }
}

///|
fn diff_tab_strip(model : Model, width : Double) -> @moui.View[Msg] {
  let tabs : Array[@moui.View[Msg]] = []
  let count = diff_file_count(model)
  let phone = diff_tab_phone_mode(model, width)
  let tab_width = if phone {
    width - 8.0 - 86.0 - 4.0
  } else {
    diff_tab_width(count, width - 8.0)
  }
  let compact = !phone && tab_width < 180.0
  let mut index = 0
  while index < model.diff_closed.length() {
    if diff_tab_visible(model, index, width) {
      let active = model.diff_file == index
      let tab_id = "diff-tab-\{index}"
      let tab_hovered = model.hover == tab_id
      let close_id = "diff-tab-close-\{index}"
      let close_hovered = model.hover == close_id
      let label = if compact {
        diff_file_name_for(model, index)
      } else {
        "\{diff_file_name_for(model, index)} (diff)"
      }
      let close = @views.container(
        x_icon(14.0, if count > 1 { fg_muted } else { fg_dim }),
        width=19.0,
        height=19.0,
        background=if close_hovered {
          white_a(0.10)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=5.0,
        padding=0.0,
      )
      let close = if diff_tab_closable(model, index) {
        close
        .on_hover(fn(entered) { Hover(close_id, entered) })
        .on_tap(CloseDiffFile(index))
      } else {
        close
      }
      tabs.push(
        @views.container(
          @views.padding_edges(
            @views.row(
              [
                @views.lucide_icon(
                  "file-text",
                  size=15.0,
                  color=if active { fg_muted } else { fg_dim },
                  stroke_width=1.7,
                ),
                txt(
                  label,
                  15.0,
                  500,
                  if active {
                    fg_primary
                  } else {
                    fg_muted
                  },
                ),
                @views.spacer(weight=1.0),
                close,
              ],
              spacing=6.0,
              align=Center,
            ).frame(width=tab_width - 15.0),
            left=7.0,
            right=8.0,
          ),
          width=tab_width,
          height=32.0,
          background=if active {
            bg_field
          } else if tab_hovered {
            white_a(0.04)
          } else {
            @graphics.Color::transparent()
          },
          padding=0.0,
        )
        .on_hover(fn(entered) { Hover(tab_id, entered) })
        .on_tap(SelectDiffFile(index)),
      )
    }
    index = index + 1
  }
  let plus_hovered = model.hover == "diff-plus"
  let plus_width = if phone { 86.0 } else { 38.0 }
  let plus_content = if phone {
    @views.row(
      [
        txt("\{count} files", 12.0, 500, fg_muted),
        @views.lucide_icon(
          "chevron-down",
          size=12.0,
          color=fg_muted,
          stroke_width=1.8,
        ),
      ],
      spacing=6.0,
      align=Center,
    )
  } else {
    @views.lucide_icon("plus", size=16.0, color=fg_muted, stroke_width=1.8)
  }
  let plus = @views.container(
      plus_content,
      width=plus_width,
      height=32.0,
      background=if plus_hovered || model.diff_file_menu_open {
        white_a(0.05)
      } else {
        @graphics.Color::transparent()
      },
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover("diff-plus", entered) })
    .on_tap(ToggleDiffFileMenu)
  let row_items : Array[@moui.View[Msg]] = []
  for tab in tabs {
    row_items.push(tab)
  }
  row_items.push(plus)
  row_items.push(@views.spacer(weight=1.0))
  @views.container(
    @views.padding_edges(
      @views.row(row_items, spacing=4.0, align=Center).frame(
        width=width - 8.0,
        height=32.0,
      ),
      left=8.0,
      top=0.0,
    ),
    width~,
    height=47.0,
    background=bg_tabbar,
    padding=0.0,
  )
}

///|
/// One file row in the plus-button picker. Both open and closed files are
/// listed so the picker can switch tabs as well as restore a closed one.
fn diff_file_menu_row(
  model : Model,
  index : Int32,
  width : Double,
) -> @moui.View[Msg] {
  let open = index >= 0 &&
    index < model.diff_closed.length() &&
    !model.diff_closed[index]
  let active = model.diff_file == index && open
  let hovered = model.hover == "diff-file-menu-\{index}"
  let color = if active {
    fg_primary
  } else if open {
    fg_body
  } else {
    fg_muted
  }
  let status = if active { "Showing" } else if open { "Open" } else { "Closed" }
  let content = @views.row(
    [
      @views.lucide_icon(
        "file-text",
        size=14.0,
        color=if active { fg_primary } else { fg_muted },
        stroke_width=1.7,
      ),
      txt(
        diff_file_name_for(model, index),
        12.5,
        if active {
          500
        } else {
          400
        },
        color,
      ),
      @views.spacer(weight=1.0),
      txt(status, 10.0, 400, if active { fg_secondary } else { fg_dim }),
    ],
    spacing=8.0,
    align=Center,
  ).frame(width=width - 16.0, height=34.0)
  @views.container(
    @views.padding_edges(content, left=8.0, right=8.0),
    width~,
    height=34.0,
    background=if active {
      white_a(0.08)
    } else if hovered {
      white_a(0.05)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    padding=0.0,
  )
  .on_tap(OpenDiffFile(index))
  .on_hover(fn(entered) { Hover("diff-file-menu-\{index}", entered) })
}

///|
/// The diff-tab plus menu: a compact file list that restores closed files and
/// switches to an already-open one.
fn diff_file_menu_card(model : Model) -> @moui.View[Msg] {
  let rows : Array[@moui.View[Msg]] = []
  let mut index = 0
  let count = diff_file_count(model)
  while index < model.diff_closed.length() {
    rows.push(diff_file_menu_row(model, index, 228.0))
    index = index + 1
  }
  let header = @views.row(
    [
      txt("Files", 11.0, 600, fg_secondary),
      @views.spacer(weight=1.0),
      txt("\{count} open", 10.0, 400, fg_dim),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=228.0, height=26.0)
  @views.container(
    @views.column(
      [header, @views.column(rows, spacing=0.0, align=Stretch)],
      spacing=4.0,
      align=Stretch,
    ),
    width=240.0,
    height=178.0,
    background=bg_card,
    corner_radius=10.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=6.0,
  ).on_tap(Noop)
}

///|
/// Anchor the file picker under the tab-strip plus, clamped inside the left
/// pane so it never runs off the window.
fn diff_file_menu_at(model : Model, left_width : Double) -> @moui.View[Msg] {
  let menu_w = 240.0
  let count = diff_file_count(model)
  let tab_width = diff_tab_width(count, left_width - 8.0)
  let gaps = count.to_double() * 4.0
  let plus_x = 8.0 + tab_width * count.to_double() + gaps
  let max_x = left_width - menu_w - 8.0
  let x = if diff_tab_phone_mode(model, left_width) {
    if max_x < 8.0 {
      8.0
    } else {
      max_x
    }
  } else {
    let anchored = plus_x - menu_w
    if anchored > max_x {
      max_x
    } else if anchored < 8.0 {
      8.0
    } else {
      anchored
    }
  }
  diff_file_menu_card(model).offset(dx=x, dy=51.0)
}

///|
fn diff_file_menu_scrim(width : Double, height : Double) -> @moui.View[Msg] {
  @views.container(
    @views.empty(),
    width~,
    height~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  ).on_tap(CloseDiffFileMenu)
}

///|
/// Context cards keep the full path when it fits; at phone widths the basename
/// is more useful than a path chopped off in the middle of the filename.
pub fn diff_context_path_label(path : String, width : Double) -> String {
  if width >= 400.0 {
    path
  } else {
    let parts = path.split("/").to_array()
    if parts.length() == 0 {
      path
    } else {
      parts[parts.length() - 1].to_string()
    }
  }
}

///|
fn diff_verdict_chip(
  model : Model,
  label : String,
  selected : Bool,
  message : Msg,
) -> @moui.View[Msg] {
  let id = "diff-verdict-\{label}"
  let hovered = model.hover == id
  @views.container(
    @views.padding_edges(
      txt(label, 15.0, 500, if selected { fg_primary } else { fg_muted }),
      left=10.0,
      right=10.0,
    ),
    height=26.0,
    background=if selected {
      white_a(0.10)
    } else if hovered {
      white_a(0.06)
    } else {
      @graphics.Color::transparent()
    },
    corner_radius=6.0,
    border=Some(
      border_of(
        white_a(if selected { 0.16 } else if hovered { 0.12 } else { 0.09 }),
        1.0,
      ),
    ),
    padding=0.0,
  )
  .on_hover(fn(entered) { Hover(id, entered) })
  .on_tap(message)
}

///|
/// Review verdicts only make sense once the run has stopped; while the agent
/// is still working the context card shows just the file/line/comment rows.
pub fn diff_verdict_visible(model : Model) -> Bool {
  !model.diff_working
}

///|
fn diff_note_count(model : Model) -> Int32 {
  let mut count = 0
  for note in model.diff_notes {
    if note.file == model.diff_file {
      count = count + 1
    }
  }
  count
}

///|
fn diff_hunk_target(model : Model, direction : Int32) -> Int32 {
  let lines = diff_file_lines(model, model.diff_file)
  let mut index = model.diff_selected + direction
  while index >= 0 && index < lines.length() {
    if lines[index].kind != DiffContext {
      return index
    }
    index = index + direction
  }
  model.diff_selected
}

///|
/// Fixed path column so the AI-notes chip lands at the reference's x≈206 on a
/// 480 px pane, while still leaving room for the chip and hunk controls on
/// narrower split panes.
pub fn diff_toolbar_path_width(pane_width : Double) -> Double {
  let raw = pane_width - 300.0
  if raw < 112.0 {
    112.0
  } else if raw > 180.0 {
    180.0
  } else {
    raw
  }
}

///|
fn diff_toolbar(model : Model, width : Double) -> @moui.View[Msg] {
  let notes_count = diff_note_count(model)
  let path_width = diff_toolbar_path_width(width)
  let path_chars = if path_width < 150.0 { 13 } else { 21 }
  let roomy = width >= 470.0
  let left_pad = 16.0
  let right_pad = if roomy { 25.0 } else { 20.0 }
  let controls_spacing = if roomy { 18.0 } else { 10.0 }
  let note_items : Array[@moui.View[Msg]] = [
    sparkles_icon(14.0, accent_violet),
    txt("AI notes \{notes_count}", 17.0, 500, fg_secondary),
  ]
  if roomy {
    note_items.push(@views.padding_edges(sparkles_icon(12.0, fg_dim), left=8.0))
  }
  let ai_notes = @views.container(
    @views.padding_edges(
      @views.row(note_items, spacing=5.0, align=Center),
      left=8.0,
      right=8.0,
    ),
    height=27.0,
    background=white_a(0.06),
    corner_radius=6.0,
    padding=0.0,
  ).on_tap(ToggleDiffNote)
  let down = @views.icon_svg(
    "<svg viewBox=\"0 0 24 24\"><path d=\"M12 5V19M5 12L12 19L19 12\"/></svg>",
    size=15.0,
    color=fg_muted,
    stroke_width=1.8,
  )
  let tool = fn(icon : @moui.View[Msg], id : String, message : Msg) {
    @views.container(
      icon,
      width=22.0,
      height=22.0,
      background=if model.hover == id {
        white_a(0.08)
      } else {
        @graphics.Color::transparent()
      },
      corner_radius=4.0,
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover(id, entered) })
    .on_tap(message)
  }
  let controls = @views.row(
    [
      tool(
        arrow_up_icon(15.0, fg_muted),
        "diff-prev-hunk",
        SelectDiffLine(diff_hunk_target(model, -1)),
      ),
      tool(down, "diff-next-hunk", SelectDiffLine(diff_hunk_target(model, 1))),
      tool(
        @views.lucide_icon(
          if model.diff_focus {
            "minimize"
          } else {
            "columns-3"
          },
          size=16.0,
          color=if model.diff_focus { fg_primary } else { fg_muted },
          stroke_width=1.7,
        ),
        "diff-focus-toggle",
        ToggleDiffFocus,
      ),
    ],
    spacing=controls_spacing,
    align=Center,
  )
  let content = @views.row(
    [
      @views.text(
        truncate_chars(diff_file_path(model, model.diff_file), path_chars),
        width=path_width,
        wrap=false,
        align=TextStart,
      )
      .font(sans(18.0, 400))
      .foreground(fg_muted),
      ai_notes,
      @views.spacer(weight=1.0),
      controls,
    ],
    spacing=10.0,
    align=Center,
  ).frame(width=width - left_pad - right_pad)
  @views.container(
    @views.padding_edges(content, left=left_pad, right=right_pad),
    width~,
    height=32.0,
    background=bg_field,
    padding=0.0,
  )
}

///|
pub fn diff_note_text(model : Model) -> String? {
  let (line, end_line) = diff_selection_bounds(model)
  let index = diff_note_index(model, model.diff_file, line, end_line)
  if index >= 0 {
    Some(model.diff_notes[index].text)
  } else {
    None
  }
}

///|
/// The displayed line number at `index`, or "?" when it is out of range.
fn diff_line_number(model : Model, index : Int32) -> String {
  let lines = diff_file_lines(model, model.diff_file)
  if index >= 0 && index < lines.length() {
    lines[index].number
  } else {
    "?"
  }
}

///|
/// "27" for a single row or "24–28" for a Shift-extended range.
fn diff_range_value(model : Model) -> String {
  let (line, end_line) = diff_selection_bounds(model)
  if line == end_line {
    diff_line_number(model, line)
  } else {
    "\{diff_line_number(model, line)}–\{diff_line_number(model, end_line)}"
  }
}

///|
/// "line 27" for a single row or "lines 24–28" for a range.
fn diff_range_label(model : Model) -> String {
  let (line, end_line) = diff_selection_bounds(model)
  if line == end_line {
    "line \{diff_range_value(model)}"
  } else {
    "lines \{diff_range_value(model)}"
  }
}

///|
/// A stored note's own line label, independent of where the caret sits now.
fn diff_note_label(model : Model, note : DiffNote) -> String {
  if note.line == note.end_line {
    "line \{diff_line_number(model, note.line)}"
  } else {
    "lines \{diff_line_number(model, note.line)}–\{diff_line_number(model, note.end_line)}"
  }
}

///|
fn diff_note_card(model : Model, width : Double) -> @moui.View[Msg] {
  let icon_button = fn(icon : @moui.View[Msg]) {
    @views.container(
      icon,
      width=22.0,
      height=22.0,
      background=@graphics.Color::transparent(),
      corner_radius=5.0,
      padding=0.0,
    )
  }
  let (line, end_line) = diff_selection_bounds(model)
  let note_index = diff_note_index(model, model.diff_file, line, end_line)
  let note = if note_index >= 0 {
    Some(model.diff_notes[note_index].text)
  } else {
    None
  }
  let header_label = if note_index >= 0 {
    "Note \{diff_note_label(model, model.diff_notes[note_index])} sent"
  } else {
    "Note \{diff_range_label(model)}"
  }
  let actions : Array[@moui.View[Msg]] = []
  match note {
    Some(_) => {
      actions.push(
        icon_button(
          @views.lucide_icon(
            "send",
            size=14.0,
            color=fg_muted,
            stroke_width=1.7,
          ),
        ).on_tap(SendDiffNote),
      )
      actions.push(
        icon_button(
          @views.lucide_icon(
            "pencil",
            size=14.0,
            color=fg_muted,
            stroke_width=1.7,
          ),
        ).on_tap(EditDiffNote),
      )
      actions.push(icon_button(x_icon(14.0, fg_muted)).on_tap(DeleteDiffNote))
    }
    None =>
      actions.push(icon_button(x_icon(14.0, fg_muted)).on_tap(ToggleDiffNote))
  }
  let header_items : Array[@moui.View[Msg]] = [
    txt(header_label, 17.5, 500, fg_secondary),
    @views.spacer(weight=1.0),
  ]
  for action in actions {
    header_items.push(action)
  }
  let header = @views.row(header_items, spacing=6.0, align=Center).frame(
    width=width - 30.0,
    height=26.0,
  )
  let text = match note {
    Some(text) => text
    None => {
      let (line, end_line) = diff_selection_bounds(model)
      if line == end_line {
        "No note on this line yet — type in the composer to attach one."
      } else {
        "No note on this range yet — type in the composer to attach one."
      }
    }
  }
  let body = @views.column(
    [header, paragraph(text, width + 40.0, 17.5, 400, 28.0, fg_primary)],
    spacing=12.0,
    align=Start,
  ).frame(width=width - 30.0)
  @views.container(
    @views.padding_edges(body, left=16.0, right=14.0, top=12.0, bottom=4.0),
    width~,
    background=bg_note,
    corner_radius=12.0,
    border=Some(border_of(white_a(0.10), 1.0)),
    padding=0.0,
  )
  .shadow(
    @graphics.ShadowStyle::new(
      color=black_a(0.45),
      offset=@geometry.Point::new(x=0.0, y=10.0),
      blur_radius=28.0,
      spread=0.0,
    ),
  )
  .on_tap(Noop)
}

///|
/// Note threads use a 360 px card in the wide reference layout and shrink
/// inside narrow diff panes without pushing past the code column.
pub fn diff_note_card_width(pane_width : Double, compact : Bool) -> Double {
  if pane_width <= 0.0 {
    0.0
  } else if compact {
    let narrow = pane_width - 24.0
    if narrow < 0.0 {
      0.0
    } else if narrow > 456.0 {
      456.0
    } else {
      narrow
    }
  } else {
    let available = pane_width - 112.0
    if available < 220.0 {
      let narrow = pane_width - 24.0
      if narrow < 0.0 {
        0.0
      } else {
        narrow
      }
    } else if available > 360.0 {
      360.0
    } else {
      available
    }
  }
}

///|
/// Inline note thread inserted under the selected line, pushing later lines down.
fn diff_note_row(
  model : Model,
  width : Double,
  compact : Bool,
) -> @moui.View[Msg] {
  let card_width = diff_note_card_width(width, compact)
  let left = if compact || width < 480.0 { 12.0 } else { 88.0 }
  let card = @views.padding_edges(diff_note_card(model, card_width), left~)
  @views.container(
    @views.padding_edges(
      @views.row(
        [card, @views.spacer(weight=1.0)],
        spacing=0.0,
        justify=Start,
        align=Start,
      ).frame(width~),
      top=12.0,
      bottom=15.0,
    ),
    width~,
    background=@graphics.Color::transparent(),
    padding=0.0,
  )
}

///|
fn diff_left_pane(
  model : Model,
  width : Double,
  height : Double,
  compact : Bool,
) -> @moui.View[Msg] {
  let code_height = height - 47.0 - 1.0 - 32.0 - 1.0 - 10.0
  let code_rows : Array[@moui.View[Msg]] = []
  let (range_start, range_end) = diff_selection_bounds(model)
  let range_active = range_start != range_end
  let mut index = 0
  for line in diff_file_lines(model, model.diff_file) {
    code_rows.push(
      diff_line_row(
        line,
        index,
        model.diff_selected == index,
        range_active && index >= range_start && index <= range_end,
        width,
        model.hover == "diff-\{index}",
      ),
    )
    if model.diff_note_open && range_end == index {
      code_rows.push(diff_note_row(model, width, compact))
    }
    index = index + 1
  }
  let code = @views.container(
    @views.scroll_view(
      @views.column(code_rows, spacing=0.0, justify=Start, align=Start).frame(
        width~,
      ),
      width~,
      height=code_height,
    ),
    width~,
    height=code_height,
    background=bg_field,
    padding=0.0,
  )
  @views.container(
    @views.column(
      [
        diff_tab_strip(model, width),
        @views.divider(color=white_a(0.07), thickness=1.0),
        diff_toolbar(model, width),
        @views.divider(color=white_a(0.07), thickness=1.0),
        @views.container(
          @views.empty(),
          width~,
          height=10.0,
          background=bg_field,
          padding=0.0,
        ),
        code,
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_field,
    padding=0.0,
  )
}

///|
fn diff_tool_row(
  icon : @moui.View[Msg],
  label : String,
  right : String,
  right_color : @graphics.Color,
  width : Double,
) -> @moui.View[Msg] {
  let items : Array[@moui.View[Msg]] = [
    icon,
    txt(label, 19.5, 400, fg_body),
    @views.spacer(weight=1.0),
  ]
  if right != "" {
    items.push(txt(right, 15.0, 500, right_color))
  }
  @views.row(items, spacing=8.0, align=Center).frame(width~, height=30.0)
}

///|
fn diff_context_card(model : Model, width : Double) -> @moui.View[Msg] {
  let bubble_width = width * 0.79
  let label_width = bubble_width - 28.0
  let path_width = label_width - 38.0
  let path_label = diff_context_path_label(
    diff_file_path(model, model.diff_file),
    width,
  )
  let file_row = @views.row(
    [
      txt("File:", 16.0, 500, fg_dim),
      clip_left(
        @views.text(" \{path_label}").font(mono(16.0, 400)).foreground(fg_body),
        path_width,
        18.0,
      ),
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=label_width, height=18.0)
  let (range_start, range_end) = diff_selection_bounds(model)
  let range_active = range_start != range_end
  let line_row = @views.row(
    [
      txt(if range_active { "Lines:" } else { "Line:" }, 16.0, 500, fg_dim),
      @views.text(" \{diff_range_value(model)}")
      .font(mono(16.0, 400))
      .foreground(fg_body),
      @views.spacer(weight=1.0),
    ],
    spacing=4.0,
    align=Center,
  ).frame(width=bubble_width - 28.0, height=18.0)
  let comment_text = match diff_note_text(model) {
    Some(note) => "User comment: “\{note}”"
    None => "User comment: none yet"
  }
  let comment = @views.text(
      comment_text,
      width=bubble_width - 28.0,
      wrap=true,
      align=TextStart,
    )
    .font(sans_lh(18.0, 400, 23.0))
    .foreground(fg_body)
  let verdicts = @views.row(
    [
      @views.spacer(weight=1.0),
      diff_verdict_chip(
        model,
        "Approve",
        model.diff_verdict == 1,
        SetDiffVerdict(1),
      ),
      diff_verdict_chip(
        model,
        "Request changes",
        model.diff_verdict == 2,
        SetDiffVerdict(2),
      ),
    ],
    spacing=6.0,
    align=Center,
  ).frame(width=bubble_width - 28.0)
  let rows : Array[@moui.View[Msg]] = [file_row, line_row, comment]
  if diff_verdict_visible(model) {
    rows.push(verdicts)
  }
  let card = @views.container(
    @views.padding_edges(
      @views.column(rows, spacing=4.0, align=Start),
      left=14.0,
      right=14.0,
      top=7.0,
      bottom=14.0,
    ),
    width=bubble_width,
    background=bg_bubble,
    corner_radius=10.0,
    padding=0.0,
  )
  @views.column([card], spacing=0.0, align=End).frame(width~)
}

///|
fn diff_extra_blocks(model : Model, width : Double) -> Array[@moui.View[Msg]] {
  let items : Array[@moui.View[Msg]] = []
  for block in model.diff_messages {
    match block {
      UserMessage(text) => items.push(user_bubble(text, width))
      AssistantMessage(text) =>
        items.push(paragraph(text, width, 14.0, 400, 20.0, fg_body))
      _ => ()
    }
  }
  items
}

///|
fn diff_transcript(model : Model, width : Double) -> @moui.View[Msg] {
  let blocks : Array[@moui.View[Msg]] = []
  let copy = diff_review_copy(model)
  if model.diff_verdict == 1 {
    blocks.push(
      @views.container(
        @views.row(
          [
            @views.lucide_icon(
              "check",
              size=16.0,
              color=accent_green,
              stroke_width=2.0,
            ),
            txt("Approved — ready to merge", 16.0, 500, accent_green),
            @views.spacer(weight=1.0),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=width - 20.0),
        width~,
        background=@graphics.Color::rgba(
          r=52.0 / 255.0,
          g=211.0 / 255.0,
          b=153.0 / 255.0,
          a=0.08,
        ),
        corner_radius=8.0,
        padding=10.0,
      ),
    )
  } else if model.diff_verdict == 2 {
    blocks.push(
      @views.container(
        @views.row(
          [
            @views.lucide_icon(
              "alert-triangle",
              size=16.0,
              color=accent_amber,
              stroke_width=1.8,
            ),
            txt("Changes requested", 16.0, 500, accent_amber),
            @views.spacer(weight=1.0),
          ],
          spacing=6.0,
          align=Center,
        ).frame(width=width - 20.0),
        width~,
        background=@graphics.Color::rgba(
          r=251.0 / 255.0,
          g=191.0 / 255.0,
          b=36.0 / 255.0,
          a=0.08,
        ),
        corner_radius=8.0,
        padding=10.0,
      ),
    )
  }
  blocks.push(diff_context_card(model, width))
  blocks.push(
    @views.padding_edges(
      @views.column(
        [
          @views.row(
            [
              txt(
                if model.diff_working {
                  "Working for 7s"
                } else {
                  "Worked for 7s"
                },
                18.0,
                400,
                fg_muted,
              ),
              @views.lucide_icon(
                "chevron-right",
                size=15.0,
                color=fg_muted,
                stroke_width=1.8,
              ),
              @views.spacer(weight=1.0),
            ],
            spacing=4.0,
            align=Center,
          ).frame(width~, height=24.0),
          @views.divider(color=white_a(0.07), thickness=1.0),
        ],
        spacing=11.0,
        align=Stretch,
      ).frame(width~),
      top=18.0,
    ),
  )
  blocks.push(paragraph(copy.intro, width, 17.5, 400, 30.0, fg_body))
  blocks.push(
    @views.column(
      [
        @views.padding_edges(
          @views.column(
            [
              diff_tool_row(
                @views.lucide_icon(
                  "file-text",
                  size=18.0,
                  color=fg_muted,
                  stroke_width=1.7,
                ),
                copy.read_file,
                "",
                fg_muted,
                width,
              ),
              diff_tool_row(
                brand_icon(diff_review_agent(model), 18.0),
                copy.edited_file,
                copy.edit_delta,
                accent_green,
                width,
              ),
            ],
            spacing=14.5,
            align=Start,
          ).frame(width~),
          top=5.5,
        ),
      ],
      spacing=0.0,
      align=Start,
    ),
  )
  for extra in diff_extra_blocks(model, width) {
    blocks.push(extra)
  }
  if model.diff_working {
    blocks.push(
      @views.row(
        [loader_icon(16.0, fg_muted), txt("Working…", 18.0, 400, fg_muted)],
        spacing=8.0,
        align=Center,
      ).frame(width~, height=30.0),
    )
  } else {
    blocks.push(
      @views.row(
        [
          status_dot(fg_dim, 6.0),
          txt("Stopped", 17.0, 400, fg_dim),
          @views.spacer(weight=1.0),
        ],
        spacing=8.0,
        align=Center,
      ).frame(width~, height=30.0),
    )
  }
  @views.padding_edges(
    @views.column(blocks, spacing=12.0, align=Start).frame(width~),
    top=0.0,
    bottom=24.0,
  )
}

///|
fn diff_field_style() -> @style.TextFieldStyle {
  let transparent = @graphics.Brush::Solid(@graphics.Color::transparent())
  let normal = @views.new_control_state_style(
    foreground=fg_body,
    background=transparent,
  )
  let focused = @views.new_control_state_style(
    foreground=fg_body,
    background=transparent,
  )
  @style.TextFieldStyle::new(
    normal~,
    focused~,
    disabled=normal,
    placeholder_color=fg_muted,
    cursor_color=fg_primary,
    font=sans_lh(18.0, 400, 28.0),
  )
}

///|
/// The two-line reference placeholder needs about 360 px of field width.
/// Narrow diff panes fall back to the shared one-line copy so the third
/// wrapped line cannot spill out of the 56 px field.
pub fn diff_composer_placeholder(field_width : Double) -> String {
  if field_width < 360.0 {
    "Ask anything…"
  } else {
    "Ask anything, @ to mention files, / for\ncommands"
  }
}

///|
/// The overlay supplies the two-line reference copy only while the field is
/// narrower than 430 px; wider panes use the shared single-line placeholder.
pub fn diff_composer_overlay(field_width : Double) -> Bool {
  field_width < 430.0
}

///|
fn diff_composer(model : Model, width : Double) -> @moui.View[Msg] {
  let card_width = width - 60.0
  let field_width = width - 108.0
  let compact = composer_footer_compact(width)
  let overlay_placeholder = diff_composer_overlay(field_width)
  let placeholder = if overlay_placeholder {
    ""
  } else {
    composer_placeholder(field_width)
  }
  let submit = match diff_composer_menu_active(model) {
    Some(menu) => DiffComposerPick(composer_accept_index(model, menu))
    None => DiffSend
  }
  let field = @views.text_field(
    model.diff_draft,
    on_input=fn(text) { DiffDraftInput(text) },
    on_submit=Some(submit),
    key="diff-composer",
    placeholder~,
    style=diff_field_style(),
    width=field_width,
    height=56.0,
  )
  let field_stack = if model.diff_draft == "" && overlay_placeholder {
    @views.stack([
      field,
      @views.padding_edges(
        @views.text(
          diff_composer_placeholder(field_width),
          width=field_width - 20.0,
          wrap=true,
          align=TextStart,
        )
        .font(sans_lh(18.0, 400, 25.0))
        .foreground(fg_muted),
        left=8.0,
        top=4.5,
      ),
    ])
  } else {
    field
  }
  let send_hovered = model.hover == "diff-send"
  let send_bg = if send_hovered {
    @graphics.Color::from_argb(0xFF4F4F4F)
  } else {
    @graphics.Color::from_argb(0xFF3D3D3D)
  }
  let stop = @views.container(
      if model.diff_working {
        @views.lucide_icon(
          "square",
          size=11.0,
          color=fg_primary,
          stroke_width=1.8,
        )
      } else {
        arrow_up_icon(14.0, fg_primary)
      },
      width=30.0,
      height=30.0,
      background=send_bg,
      corner_radius=15.0,
      padding=0.0,
    )
    .on_hover(fn(entered) { Hover("diff-send", entered) })
    .on_tap(if model.diff_working { DiffStop } else { DiffSend })
  let access = @views.row(
    [
      shield_alert_icon(18.0, access_color(model.composer_access)),
      txt(
        if compact {
          composer_access_short_label(model.composer_access)
        } else {
          composer_access_label(model.composer_access)
        },
        15.0,
        500,
        access_color(model.composer_access),
      ),
      @views.lucide_icon(
        "chevron-down",
        size=14.0,
        color=access_color(model.composer_access),
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).on_tap(CycleAccess)
  let model_picker = @views.row(
    [
      txt(composer_model_label(model.composer_model), 15.0, 400, fg_secondary),
      @views.lucide_icon(
        "chevron-down",
        size=14.0,
        color=fg_muted,
        stroke_width=1.8,
      ),
    ],
    spacing=6.0,
    align=Center,
  ).on_tap(CycleComposerModel)
  let footer_items : Array[@moui.View[Msg]] = []
  if !compact {
    let plus_hovered = model.hover == "diff-composer-plus"
    footer_items.push(
      @views.container(
        @views.lucide_icon(
          "plus",
          size=20.0,
          color=fg_secondary,
          stroke_width=1.8,
        ),
        width=20.0,
        height=28.0,
        background=if plus_hovered {
          white_a(0.06)
        } else {
          @graphics.Color::transparent()
        },
        corner_radius=7.0,
        padding=0.0,
      )
      .on_hover(fn(entered) { Hover("diff-composer-plus", entered) })
      .on_tap(DiffDraftInput(composer_mention_trigger(model.diff_draft))),
    )
  }
  footer_items.push(access)
  footer_items.push(@views.spacer(weight=1.0))
  footer_items.push(model_picker)
  if !compact {
    footer_items.push(
      dictation_mic(
        20.0,
        dictation_diff,
        model.dictation_target == dictation_diff,
        model.hover == "diff-composer-mic",
        "diff-composer-mic",
      ),
    )
  }
  footer_items.push(stop)
  let footer_spacing = if compact { 6.0 } else { 12.0 }
  let footer_inset = if compact { 8.0 } else { 12.0 }
  let footer_left = if compact { 6.0 } else { 13.0 }
  let footer_right = if compact { 2.0 } else { 4.0 }
  let footer_content = @views.row(
    footer_items,
    spacing=footer_spacing,
    align=Center,
  ).frame(width=card_width - footer_inset)
  let footer = @views.padding_edges(
    footer_content,
    left=footer_left,
    right=footer_right,
  )
  let card = @views.container(
    @views.padding_edges(
      @views.column([field_stack, footer], spacing=9.5, align=Stretch).frame(
        width=card_width,
      ),
      bottom=3.0,
    ),
    background=bg_field,
    corner_radius=14.0,
    border=Some(composer_border()),
    padding=8.0,
  )
  let centered = @views.row(
    [@views.spacer(weight=1.0), card, @views.spacer(weight=1.0)],
    spacing=0.0,
    align=Center,
  ).frame(width~)
  let content = match diff_composer_menu_active(model) {
    Some(menu) => {
      let picker = composer_menu_view(model, menu, card_width, fn(insert) {
        DiffDraftInput(insert)
      })
      @views.column([picker, centered], spacing=8.0, align=Center).frame(width~)
    }
    None => centered
  }
  @views.padding_edges(
    @views.column([content], spacing=0.0, align=Center).frame(width~),
    top=0.0,
    bottom=23.0,
  )
}

///|
fn diff_right_pane(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let header = @views.container(
    @views.padding_edges(
      @views.row(
        [
          brand_icon(diff_review_agent(model), 16.0),
          @views.text(
            diff_review_title(model),
            width=240.0,
            wrap=false,
            align=TextStart,
          )
          .font(sans(17.5, 500))
          .foreground(fg_primary),
          @views.spacer(weight=1.0),
          x_icon(15.0, fg_muted)
          .on_hover(fn(entered) { Hover("diff-chat-close", entered) })
          .on_tap(ToggleDiffFocus),
          @views.lucide_icon(
            "plus",
            size=16.0,
            color=fg_muted,
            stroke_width=1.8,
          )
          .on_hover(fn(entered) { Hover("diff-chat-plus", entered) })
          .on_tap(OpenModal),
        ],
        spacing=8.0,
        align=Center,
      ).frame(width=width - 24.0),
      left=12.0,
      right=12.0,
      top=10.0,
    ),
    width~,
    height=36.0,
    background=bg_tabbar,
    padding=0.0,
  )
  let content_width = width - 36.0
  let composer_height = 138.0 + diff_composer_menu_height(model)
  let scroll = @views.scroll_view(
    @views.padding_edges(
      diff_transcript(model, content_width),
      left=18.0,
      right=18.0,
    ),
    width~,
    height=height - 37.0 - composer_height,
  )
  @views.container(
    @views.column(
      [
        header,
        @views.divider(color=white_a(0.07), thickness=1.0),
        scroll,
        diff_composer(model, width),
      ],
      spacing=0.0,
      align=Stretch,
    ),
    width~,
    height~,
    background=bg_main,
    padding=0.0,
  )
}

///|
/// Narrow diff layout: below 720 px the two panes stack instead of splitting
/// into halves too narrow to hold their toolbars and composer.
pub fn diff_compact(width : Double) -> Bool {
  width < 720.0
}

///|
/// The narrow diff stack splits the available height evenly: the code pane
/// still clears eight 24 px rows at 600 px, while the chat transcript gets
/// enough room above its 138 px composer to show the context card and reply.
pub fn diff_compact_pane_heights(height : Double) -> (Double, Double) {
  let available = if height < 1.0 { 0.0 } else { height - 1.0 }
  let top_height = available * 0.50
  (top_height, available - top_height)
}

///|
/// Full-window diff review: code + line notes on the left, agent chat on the right.
pub fn diff_screen(
  model : Model,
  width : Double,
  height : Double,
) -> @moui.View[Msg] {
  let left_width = if model.diff_focus || diff_compact(width) {
    width
  } else {
    width * diff_split
  }
  let shell = if model.diff_focus {
    @views.container(
      diff_left_pane(model, width, height, diff_compact(width)),
      width~,
      height~,
      background=bg_main,
      padding=0.0,
    ).clip()
  } else if diff_compact(width) {
    let (top_height, bottom_height) = diff_compact_pane_heights(height)
    @views.container(
      @views.column(
        [
          diff_left_pane(model, width, top_height, true),
          @views.divider(color=white_a(0.08), thickness=1.0),
          diff_right_pane(model, width, bottom_height),
        ],
        spacing=0.0,
        align=Stretch,
      ).frame(width~, height~),
      width~,
      height~,
      background=bg_main,
      padding=0.0,
    ).clip()
  } else {
    let left_width = width * diff_split
    let right_width = width - left_width - 1.0
    @views.container(
      @views.row(
        [
          diff_left_pane(model, left_width, height, false),
          vrule(height),
          diff_right_pane(model, right_width, height),
        ],
        spacing=0.0,
        align=Stretch,
      ).frame(width~, height~),
      width~,
      height~,
      background=bg_main,
      padding=0.0,
    ).clip()
  }
  if model.diff_file_menu_open {
    @views.stack([
      shell,
      diff_file_menu_scrim(width, height),
      diff_file_menu_at(model, left_width),
    ])
  } else {
    shell
  }
}
