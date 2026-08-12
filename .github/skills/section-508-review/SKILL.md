---
name: section-508-review
description: "Review a web UI for Section 508 / WCAG 2.1 AA accessibility compliance — keyboard navigation, screen-reader compatibility (ARIA), color contrast, heading structure, focus order, form labels, alt text, and error-message clarity. Required for VA / federal software where 508 is a legal gate. Run standalone on any frontend change, or as the accessibility lens of a broader review. Read-only; reports findings, does not edit."
---

# Section 508 / WCAG 2.1 AA Accessibility Review

Review a web UI against Section 508 and WCAG 2.1 Level AA. For VA and federal audiences, 508 compliance is a legal requirement, not optional polish — treat every failure as a real gate, not a nit.

Run this standalone on a single frontend change, or let a broader review (a full app QC) delegate to it for its accessibility section. Read-only: report findings with concrete fixes; do not edit source.

## Evidence discipline
Prefer OBSERVING the running app over reading the code. A static read of JSX/HTML infers intent; the rendered DOM + computed styles are the truth. If the app can be run, use `#webapp-testing` / Playwright to capture the rendered DOM, computed contrast, focus order, and screen-reader tree. If you can only read the source, mark findings INFERRED and say so — never present a static guess as an observed result.

## What to check (WCAG 2.1 AA)

### 1. Perceivable
- **Text alternatives:** every `img` has meaningful `alt` (or `alt=""` + `role="presentation"` if decorative); icons that convey meaning have accessible names; no info conveyed by color alone.
- **Color contrast:** normal text >= 4.5:1, large text (>=18pt or 14pt bold) >= 3:1, UI components/graphics >= 3:1. Measure computed values, do not eyeball.
- **Adaptable structure:** correct semantic elements (`nav`, `main`, `header`, `button` not `div onclick`); heading hierarchy is ordered (h1 -> h2 -> h3, no skips); reading order matches visual order.

### 2. Operable
- **Keyboard:** every interactive element reachable and operable by keyboard alone; no keyboard traps; visible focus indicator on every focusable element; logical tab order.
- **Focus management:** modals trap focus while open and restore it on close; skip-to-content link present; focus moves sensibly on route/content change.
- **Timing / motion:** no essential time limits without a way to extend; respect `prefers-reduced-motion`; nothing flashes more than 3x/second.

### 3. Understandable
- **Labels:** every form control has an associated `<label>` (or `aria-label`/`aria-labelledby`); required fields marked programmatically, not by color/asterisk alone; input purpose identified where relevant.
- **Errors:** error messages are specific, programmatically associated with the field (`aria-describedby`), and announced to assistive tech; instructions are clear plain language.
- **Predictable:** consistent navigation and naming; no unexpected context change on focus/input.

### 4. Robust
- **ARIA correctness:** valid roles/states/properties; `aria-*` only where native semantics are insufficient (prefer native `<button>`/`<select>` over ARIA-retrofit divs); no broken `aria-labelledby`/`describedby` id references; live regions (`aria-live`) for dynamic updates.
- **Name/Role/Value:** every custom component exposes an accessible name, correct role, and current state to the accessibility tree.

## Output
A prioritized findings list. Each = SEVERITY (blocker / high / medium / low) | WCAG success criterion (e.g. 1.4.3 Contrast) | location (component / file:line or screen) | what is wrong | concrete fix. Tag each CONFIRMED (observed on the running app) or INFERRED (read from source only). End with the top 3 to fix first and a plain-language bottom line: "508-ready" or "N blockers before it can ship to a federal audience."

## Rules
- Read-only — report findings and fixes; do not edit source.
- Federal/VA context: 508 failures are blocking gates, not polish. Do not soften them.
- Measure contrast and observe focus/keyboard on the RUNNING app where possible; mark static-only findings INFERRED.
- No emojis in the report. Synthetic data only in any test run.
