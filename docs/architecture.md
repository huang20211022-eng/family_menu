# Architecture

This document describes the planned architecture of **Family Menu**. The
current codebase is a bare Flutter scaffold; the structure below is the target
design that subsequent phases will implement.

## Overview

Family Menu is a Flutter Android client backed by Supabase (identity + recipe
metadata) and Cloudflare (image storage + secure URL signing):

```
┌─────────────────────────────┐
│  Flutter Android client     │
│  (Dart, Material)           │
│  lib/                       │
│    l10n/ core/ models/      │
│    services/ repositories/  │
│    pages/ widgets/          │
└──────┬───────────────┬──────┘
       │ Supabase SDK  │ HTTPS (secure temp URLs)
       ▼               ▼
┌──────────────┐  ┌────────────────────┐
│  Supabase    │  │  Cloudflare        │
│  ├── Auth    │  │  ├── Worker        │
│  └── Postgres│  │  └── R2 (images)   │
│     (RLS)    │  └────────────────────┘
└──────────────┘
```

## Flutter Client

The client is organized into layers so that UI depends on repositories, not on
raw backend calls.

| Directory      | Responsibility                                              |
|----------------|-------------------------------------------------------------|
| `lib/l10n/`    | Generated localization resources (`flutter gen-l10n`).      |
| `lib/core/`    | Shared constants, theme, error types, utility helpers.      |
| `lib/models/`  | Plain domain models (e.g. `Recipe`) with JSON mapping.      |
| `lib/services/`| Thin wrappers over Supabase Auth, DB, and Storage clients.   |
| `lib/repositories/` | Data access layer; single source of truth for pages.   |
| `lib/pages/`   | Screen/widget pages (login, list, detail, editor, random).   |
| `lib/widgets/` | Reusable, presentational widgets.                            |

Data flow: `page → repository → service → Supabase`, with domain models passed
upward. Pages never construct raw SQL or call Supabase directly.

## Backend Services

The app uses two managed providers: Supabase for identity and structured data,
and Cloudflare for image storage and secure URL signing. There is no
traditional VPS or self-hosted server.

### Supabase Auth

- Handles user registration, login, logout, and session persistence.
- The Flutter client stores and refreshes the session locally so login persists
  across app restarts.
- The authenticated user's `id` (UUID) is the ownership key for all data.
- MVP sign-in uses **Email + Password** with email-link verification (preferred
  over SMS).
- "Forgot Password?" uses Supabase Auth's password-reset email flow.
- Production requires a **Custom SMTP** provider; Supabase's built-in email
  service is development/testing only.

### Supabase PostgreSQL

- Stores structured data — recipe metadata only (`recipes` table).
- Does **not** store recipe image binary data.
- Schema changes are applied via Supabase migrations (not ad-hoc).
- Row Level Security enforces per-user access.

### Cloudflare R2

- Recipe image storage, used from the first version (v1).
- The `recipes` table stores only the R2 `image_key` / `image_path`; image
  binary never lives in PostgreSQL.
- R2 secrets are never shipped in the Flutter client.

### Cloudflare Worker

- Generates secure, temporary URLs for R2 image upload and download.
- Replaces a traditional VPS / self-hosted server.
- Planned for a later milestone; the v1 client uploads and downloads images
  through these temporary URLs.

## Data Model

The `recipes` table:

| Column         | Type                  | Notes                            |
|----------------|-----------------------|----------------------------------|
| `id`           | UUID (PK, default gen) | Recipe identifier               |
| `user_id`      | UUID (FK → auth.users) | Owning user, NOT NULL           |
| `name`         | text                   | NOT NULL                         |
| `image_key`    | text                   | NOT NULL — R2 object key/path    |
| `ingredients`  | text / jsonb           | NOT NULL — preserved verbatim    |
| `steps`        | text / jsonb           | NOT NULL — preserved verbatim    |
| `video_url`    | text                   | NULLABLE — public video page URL |
| `cooking_time` | integer / text         | NULLABLE                         |
| `created_at`   | timestamptz            | default now()                    |
| `updated_at`   | timestamptz            | default now()                    |

> The exact representation of `ingredients` and `steps` (ordered JSON arrays vs.
> delimited text) is finalized during the recipe-management milestone. The model
> preserves user input verbatim regardless of representation.

## Security Boundaries

- **Trust boundary is the database.** RLS policies enforce that
  `user_id = auth.uid()` for every read, insert, update, and delete.
- The client is never trusted to filter other users' rows; RLS is the source of
  truth.
- **RLS stays enabled.** It must never be disabled to make a feature work.
- The client ships only the Supabase **anon/public** key and project URL.
  Service-role keys, R2 secrets, and Worker secrets live server-side and are
  never bundled.
- Recipe images in R2 are accessed via secure, temporary URLs issued by the
  Cloudflare Worker; private user images are not exposed via long-lived public
  URLs.

## Repository / Service Contracts (planned)

- `AuthService` — `signUp`, `signIn`, `signOut`, session persistence/restore.
- `RecipeService` / `RecipeRepository` — `list`, `get`, `create`, `update`,
  `delete`, and `random` for the current user.
- `ImageStorageService` — upload/delete recipe images via secure temporary R2
  URLs; resolve the stored `image_key` to a display URL.

These are documented contracts only; they will be implemented in later phases.

## Image Handling

- The Flutter client compresses images before upload.
- Upload enforces maximum dimensions and file-size limits.
- The list view loads thumbnails; the detail page loads an appropriately sized
  image.

## Random Recipe

- "What should we eat?" uses a 100% local random algorithm.
- The normal user flow never calls an LLM or external AI service.

## AI / LLM Policy

- DeepSeek is used only as the Claude Code model during development.
- The MVP user flow depends on no LLM at runtime.

## Cost Policy

- Prefer free tiers: Supabase free tier, Cloudflare R2 free tier, Cloudflare
  Workers free tier.
- Do not introduce services with a fixed monthly fee.
- Before any service exceeds its free tier, report the cost for approval —
  never auto-upgrade to a paid tier.
