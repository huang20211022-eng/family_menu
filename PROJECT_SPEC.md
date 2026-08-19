# PROJECT_SPEC.md — Family Menu

## Product Overview

**Family Menu** is an open-source, publicly downloadable Android application
that lets each authenticated user manage their own private recipe collection —
create, view, edit, and delete recipes — and draw a random recipe with a
"What should we eat?" feature. The application is bilingual
(Simplified Chinese and English).

## Target Users

- Individuals and families who want a private, personal recipe book.
- Users comfortable with Chinese or English interfaces.
- Android users downloading via GitHub Releases, direct APK, or Google Play.

## MVP Scope

The MVP delivers:

1. Authentication (register / login / logout / persistent session).
2. User-owned recipe management (create / view / edit / delete).
3. A recipe list for the current user.
4. A recipe detail page.
5. A random recipe ("What should we eat?") feature with an empty state.
6. Bilingual UI (Simplified Chinese + English).

## Authentication

- User registration.
- User login.
- User logout.
- Persistent login session across app restarts.
- Backed by Supabase Auth (planned).

## Recipe Management

Each recipe belongs to exactly one authenticated user and contains:

| Field             | Required | Notes                                  |
|-------------------|----------|----------------------------------------|
| Recipe image      | Required | Stored in Supabase Storage             |
| Recipe name       | Required |                                        |
| Ingredients       | Required | Preserved verbatim (user data)         |
| Cooking steps     | Required | Preserved verbatim (user data)         |
| Tutorial video URL| Optional | Omitted from detail UI when absent     |
| Cooking time      | Optional | Shown on cards/list when available     |

Users can create, view, edit, and delete their recipes.

## Recipe List

- Shows the current user's recipes only.
- Each card/list item eventually displays: image, name, and cooking time
  (when available).
- Selecting a recipe opens its detail page.

## Recipe Detail Page

Displays: image, name, ingredients, cooking steps, tutorial video URL
(when available), and cooking time (when available).

If the tutorial video URL does not exist, that section must **not** render as
an empty/broken element — it is simply omitted.

## Tutorial Video

- Field: `video_url` — **optional**.
- Users may attach a cooking tutorial video link when creating **or** editing a
  recipe (both the create and edit flows support this field).
- The link points to a **publicly accessible video page** (e.g. a video-sharing
  site URL).
- The MVP does **not** embed video playback inside the app; selecting the entry
  opens the video via the platform's default handler.
- The detail page shows the tutorial entry **only when a link exists**; when no
  link is set, that section is hidden entirely (no empty/broken element).

## Random Recipe Feature

- A "今天吃什么？" / "What should we eat?" button randomly selects one recipe
  from the current user's collection.
- The UI eventually includes a visually interesting drawing/rolling animation.
- If the user has no recipes, show a useful empty state that guides them to
  create their first recipe.

## Bilingual Support

- Supported locales: **Simplified Chinese (`zh-CN`)** and **English (`en`)**.
- A first-class requirement covering the entire UI: login, registration, home,
  recipe list, creation, editing, details, random recipe, profile/settings,
  buttons, validation messages, empty states, error messages, loading messages,
  navigation labels, dialogs, and confirmations.
- The login page provides a visible language selector (`中文 | English`).
- The selected locale persists locally and survives restarts.
- **User-entered recipe content is user data and is NOT automatically
  translated** in the MVP.

## Localization Strategy

Centralized localization via Flutter's official `l10n`/ARB mechanism
(`flutter gen-l10n`). No user-facing strings are hard-coded in widgets.
See [`docs/localization.md`](docs/localization.md) for details.

## Planned Supabase Architecture

- **Supabase Auth** — registration, login, session persistence.
- **PostgreSQL** — the `recipes` table and metadata.
- **Supabase Storage** — recipe images (the DB stores only the path/URL).
- **Row Level Security (RLS)** — always enabled; a user can only read, create,
  update, and delete their own recipes.

See [`docs/architecture.md`](docs/architecture.md).

## Data Model

The planned `recipes` table:

| Column       | Type                  | Notes                          |
|--------------|-----------------------|--------------------------------|
| `id`         | UUID (PK)             | Recipe identifier              |
| `user_id`    | UUID (FK → auth.users)| Owning authenticated user      |
| `name`       | text                  | NOT NULL                       |
| `image_url`  | text                  | NOT NULL — Storage path/URL    |
| `ingredients`| text / jsonb          | NOT NULL — preserved verbatim  |
| `steps`      | text / jsonb          | NOT NULL — preserved verbatim  |
| `video_url`  | text                  | NULLABLE                       |
| `cooking_time`| integer / text       | NULLABLE                       |
| `created_at` | timestamptz           |                                |
| `updated_at` | timestamptz           |                                |

- Recipe IDs are UUIDs.
- `user_id` always represents the authenticated Supabase user.
- RLS policies bind rows to `auth.uid()`.

## Security Model

- No secrets in source code; never commit keys, service-role keys, passwords,
  or tokens.
- Client config exposes only public credentials (anon key + project URL).
- RLS stays enabled; ownership is enforced server-side, not just client-side.
- Images are stored in Storage; the DB holds paths, not binary data.

## Future Roadmap

- Recurring/authored meal planning or shopping-list generation.
- AI-assisted translation of the UI content (not recipe user data).
- Social sharing of recipes (opt-in, out of scope for MVP privacy model).
- iOS and additional platforms.

## Distribution

- First target platform: **Android**.
- Planned release channels: **GitHub Releases** (APK download), direct APK
  distribution, and **Google Play** (AAB).
- See [`docs/release.md`](docs/release.md) for the full release plan.

## Explicitly NOT in MVP

- No automatic (AI) translation of user-entered recipe content.
- No social/shared recipe feeds — every collection is private to its owner.
- No recipe search across other users.
- No multi-user/shared-family collections.
- No offline-first sync (MVP relies on the Supabase backend).
- No iOS/web/desktop builds (Android first).
