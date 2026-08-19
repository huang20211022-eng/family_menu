# Architecture

This document describes the planned architecture of **Family Menu**. The
current codebase is a bare Flutter scaffold; the structure below is the target
design that subsequent phases will implement.

## Overview

Family Menu is a Flutter Android client backed by Supabase:

```
┌─────────────────────────────┐
│  Flutter Android client     │
│  (Dart, Material)           │
│  lib/                       │
│    l10n/ core/ models/      │
│    services/ repositories/  │
│    pages/ widgets/          │
└──────────────┬──────────────┘
               │  HTTPS (Supabase SDK)
┌──────────────▼──────────────┐
│  Supabase                   │
│  ├── Auth                   │
│  ├── PostgreSQL (RLS)       │
│  └── Storage (images)       │
└─────────────────────────────┘
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

## Supabase Backend

Supabase provides three services used by the app:

### Supabase Auth

- Handles user registration, login, logout, and session persistence.
- The Flutter client stores and refreshes the session locally so login persists
  across app restarts.
- The authenticated user's `id` (UUID) is the ownership key for all data.

### PostgreSQL

- Stores structured data, primarily the `recipes` table.
- Schema changes are applied via Supabase migrations (not ad-hoc).
- Row Level Security enforces per-user access.

### Supabase Storage

- Stores recipe images (and any future uploads) as objects.
- The `recipes` table stores only the image path/URL, never binary data.

## Data Model

The `recipes` table:

| Column         | Type                  | Notes                            |
|----------------|-----------------------|----------------------------------|
| `id`           | UUID (PK, default gen) | Recipe identifier               |
| `user_id`      | UUID (FK → auth.users) | Owning user, NOT NULL           |
| `name`         | text                   | NOT NULL                         |
| `image_url`    | text                   | NOT NULL — Storage path/URL      |
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
  Service-role keys and any secrets live server-side and are never bundled.
- Recipe images in Storage are access-controlled; private user images are not
  exposed via public URLs (or are otherwise gated by the same ownership rules).

## Repository / Service Contracts (planned)

- `AuthService` — `signUp`, `signIn`, `signOut`, session persistence/restore.
- `RecipeService` / `RecipeRepository` — `list`, `get`, `create`, `update`,
  `delete`, and `random` for the current user.
- `StorageService` — upload/delete recipe images, resolve stored path to a
  display URL.

These are documented contracts only; they will be implemented in later phases.
