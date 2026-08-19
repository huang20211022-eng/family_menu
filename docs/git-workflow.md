# Git Workflow

## Primary Branch

- The primary branch is **`main`**.
- GitHub is the remote source repository
  (`https://github.com/huang20211022-eng/family_menu.git`).

## Commit Conventions

Use small, meaningful conventional commits. Scope is optional but encouraged.

Common types:

- `feat:` — a new feature.
- `fix:` — a bug fix.
- `docs:` — documentation only.
- `chore:` — tooling/config/maintenance.
- `refactor:` — code change that neither fixes a bug nor adds a feature.
- `test:` — tests only.

Examples:

```
feat: add bilingual app foundation
feat: add login screen
feat: add recipe management
feat: add random recipe feature
fix: preserve selected locale
docs: update architecture documentation
chore: configure Supabase
```

## Milestone Workflow

For every development milestone:

1. Inspect `git diff` and verify the changed files.
2. Run the relevant validation (`flutter analyze`, relevant tests).
3. Create a meaningful commit scoped to the milestone.
4. Push the completed milestone to GitHub.

Each feature follows: Requirement → Plan → Implementation → `flutter analyze`
→ relevant tests → run on emulator → visual inspection → user review →
approval → commit → push.

## Push Policy

- Push only reviewed, completed milestones.
- **Never force-push.**
- Do not rewrite published Git history unless explicitly requested.
- Do not push unrelated or unverified changes.

## Rollback Strategy

- Prefer `git revert` for published history — never force-push to rewrite it.
- For uncommitted local changes, `git status`/`git diff` first, then discard
  only what is understood and intended.
- For un-pushed local commits, `git reset` is acceptable when the intent is to
  rework before publishing; confirm before doing so.

## Secret Protection

- **Never commit secrets** — API keys, Supabase keys, service-role keys,
  passwords, or private tokens.
- Keep secrets out of source code; use environment-provided or server-side
  configuration for privileged credentials.
- Review `git diff` for any accidental secrets before each commit.
- If a secret is ever committed, treat it as compromised: rotate it immediately
  and remove it from history (only with explicit request to rewrite history).
