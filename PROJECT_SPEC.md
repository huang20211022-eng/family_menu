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

### Authentication Plan (planned)

- **Auth provider:** Supabase Auth.
- **MVP sign-in method:** Email + Password.
- **Registration flow:** new users register and then complete email
  verification.
- **Verification channel:** the MVP prefers a verification **link** (email
  confirmation) rather than an SMS code. Supabase Auth provides the email
  confirmation flow out of the box.
- **Password reset:** "Forgot Password?" uses Supabase Auth's password-reset
  email flow.
- **Future options:** Email OTP / 6-digit verification codes may be added later
  if needed.
- **Out of scope for v1:** no SMS verification codes and no phone-number login.

### Email delivery (planned)

- Production requires a **Custom SMTP** provider.
- Supabase's built-in/default email service is for development and testing only
  and is not suitable for sending production user email.
- Email sending costs depend on the final SMTP provider chosen; no specific
  third-party provider is committed to as permanently free.

## Recipe Management

Each recipe belongs to exactly one authenticated user and contains:

| Field             | Required | Notes                                  |
|-------------------|----------|----------------------------------------|
| Recipe image      | Required | Stored in Cloudflare R2                |
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
- The selection uses a **100% local random algorithm** — the normal user flow
  never calls an LLM (e.g. DeepSeek) or any external AI service.
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

## Planned Backend Architecture

- **Supabase Auth** — registration, login, session persistence.
- **Supabase PostgreSQL** — recipe metadata only (`recipes` table). The database
  stores **no recipe image binary data**.
- **Cloudflare R2** — recipe image storage, used from the first version (v1).
  The database stores only the R2 `image_key` / `image_path`.
- **Cloudflare Worker** — generates secure, temporary URLs for R2 image upload
  and download. No traditional VPS or self-hosted server is used.
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
| `image_key`  | text                  | NOT NULL — R2 object key/path  |
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
- Client config exposes only public credentials (Supabase anon key + project
  URL). Cloudflare R2 secrets and Worker secrets are never bundled in Flutter.
- RLS stays enabled; ownership is enforced server-side, not just client-side.
- Images are stored in Cloudflare R2; the DB holds the R2 object key, not
  binary data and not long-lived public URLs.

## Recipe Image Handling

- Images are stored in Cloudflare R2; the database stores only the R2
  `image_key` / `image_path`.
- The Flutter client compresses images before upload and enforces maximum
  dimensions and file-size limits.
- The list view loads thumbnails; the detail page loads an appropriately sized
  image.
- Upload and download use secure, temporary URLs issued by a Cloudflare Worker.

## AI / LLM Policy

- **DeepSeek** is used only as the Claude Code model during development. It is
  not part of the MVP's normal user flow.
- The MVP user flow (browse, create, edit, delete, random draw) depends on
  **no LLM / AI service** at runtime.

## Cost Policy

- Prefer free tiers (Supabase free tier, Cloudflare R2 free tier, Cloudflare
  Workers free tier).
- Do not introduce services with a fixed monthly fee.
- Before any service exceeds its free tier, the cost must be reported and
  approved — never auto-upgrade to a paid tier.

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
