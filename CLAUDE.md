# CLAUDE.md

Guidance for Claude Code (and any AI assistant / contributor) working on the
**Family Menu** project.

## Project Purpose

Family Menu is an open-source, publicly downloadable Android application for
managing a personal, user-owned recipe collection. Each authenticated user keeps
a private set of recipes and can browse, create, edit, delete, and randomly
draw ("What should we eat?") from them.

## Technology Stack

| Layer      | Technology                                              |
|------------|----------------------------------------------------------|
| Client     | Flutter (Dart)                                           |
| Platform   | Android (first target)                                   |
| Backend    | Supabase — Auth, PostgreSQL (recipe metadata only)        |
| Image storage | Cloudflare R2 (v1 onward; DB stores `image_key` only)  |
| Secure URLs | Cloudflare Worker (temporary R2 upload/download URLs)   |
| Localization | Flutter official `l10n` (ARB) mechanism (planned)        |

The Android application ID / namespace is `com.menglan.family_menu`.

## Architecture Principles

- Follow a layered structure. Planned layout:
  ```
  lib/
    l10n/          # generated localization (planned)
    core/          # shared utilities, constants, theme, errors
    models/        # domain models (e.g. Recipe)
    services/      # Supabase (auth, DB) + Cloudflare R2/Worker wrappers
    repositories/  # data access, single source of truth for pages
    pages/         # screen/widget pages
    widgets/       # reusable UI components
  ```
- **Never hard-code user-facing strings in widgets.** All UI text flows from the
  centralized localization resources.
- Repositories isolate data access; pages depend on repositories, not on raw
  Supabase calls.
- Keep UI changes small and independently previewable.

## Coding Rules

- Follow `analysis_options.yaml` (Flutter recommended lints).
- Match the existing code style; prefer single quotes and the current idiom.
- Do not introduce large architectural changes silently. Explain the intent,
  affected files, and verification plan before substantial changes.
- Do not add dependencies without explicit justification. If a dependency
  appears necessary, **stop and explain why first** — do not install it on your
  own initiative.
- Do not modify unrelated files.

## Security Rules

- **Never put secrets in Flutter source code.**
- **Never commit API keys, Supabase keys, service-role keys, passwords, or
  private tokens to Git.**
- Client-side configuration must only ever expose public, non-privileged
  credentials (e.g. Supabase anon/public key + project URL).
- **Supabase Row Level Security (RLS) must remain enabled.** Never disable RLS
  simply to make a feature work.
- Each user may only read/create/update/delete their **own** recipes
  (enforced by RLS on `user_id = auth.uid()`).
- Recipe images live in Cloudflare R2; the database stores only the R2
  `image_key` / `image_path`, never image binary data.
- **Cloudflare R2 and Worker secrets must never be committed or written into
  Flutter source code.** Upload/download uses secure temporary URLs from a
  Cloudflare Worker.

## Image & Cost Rules

- Images are stored in Cloudflare R2; the DB stores only `image_key`/`image_path`.
- The client compresses images before upload and enforces max dimensions and
  file-size limits; the list uses thumbnails and the detail page uses an
  appropriately sized image.
- Prefer free tiers (Supabase, Cloudflare R2, Cloudflare Workers). Do not
  introduce fixed monthly-fee services. Before any service exceeds its free
  tier, stop and report the cost for approval — never auto-upgrade to paid.

## AI Rules

- DeepSeek is the Claude Code model used during development only. The MVP
  normal user flow must not depend on any LLM.
- "What should we eat?" uses a 100% local random algorithm — never call an LLM
  for the random-recipe flow.

## Localization Rules

- Bilingual support (Simplified Chinese `zh-CN` and English `en`) is a
  first-class product requirement, not a future enhancement.
- Use Flutter's official localization mechanism (`.arb` files +
  `flutter gen-l10n`).
- The login page must expose a visible language selector (`中文 | English`).
- The selected locale must be persisted and survive restarts.
- **User-entered recipe content is user data and must NOT be automatically
  translated** — preserve exactly what the user typed.

## Git Rules

- Primary branch is `main`; GitHub is the remote source repository.
- Use small, meaningful conventional commits
  (e.g. `feat:`, `fix:`, `docs:`, `chore:`).
- Inspect `git diff` before committing; verify the changed files.
- Never commit secrets.
- Do not force-push; do not rewrite published history unless explicitly asked.
- **Do not run `git push` without the user's explicit confirmation.** Only a
  completed, reviewed, and approved milestone may be pushed.

## Testing Rules

- Run `flutter analyze` before considering work done.
- Add/adjust relevant tests for feature work.
- Never claim a feature is complete unless it has actually been verified.
- When a build or test fails: inspect the error, find the root cause, fix it,
  and rerun the failed validation.

## UI Review Workflow

Each UI milestone follows an incremental cycle:

```
Requirement → Plan → Implementation → flutter analyze → relevant tests
→ Run Android App → Visual inspection (Pixel 8 emulator) → User review
→ Approval → Git commit → Git push
```

- Keep changes small and let the user review (including screenshots of the
  Pixel 8 emulator) before moving to the next milestone.
- Do not implement future screens prematurely.

## "Do Not Implement Beyond the Current Milestone" Rule

Only build what the current milestone requires. Do not add authentication,
Supabase integration, extra screens, or unrelated features until their milestone
is reached. When in doubt, document the intent and defer the implementation.
