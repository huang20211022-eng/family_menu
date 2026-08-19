# Localization (Bilingual Support)

Bilingual support is a **first-class** requirement of Family Menu, covering
every piece of user-facing UI text.

## Supported Locales

| Locale  | Language            | Notes                      |
|---------|---------------------|----------------------------|
| `zh-CN` | Simplified Chinese  | Default locale             |
| `en`    | English             |                            |

## Strategy

Use **Flutter's official localization mechanism**:

- ARB resource files (one per locale).
- `flutter gen-l10n` generates typed `AppLocalizations` classes.
- `MaterialApp` is configured with `supportedLocales`, `localizationsDelegates`,
  and `locale`.

Centralization means **no user-facing string is hard-coded in widgets**. All
text is referenced through the generated localizations.

## Resource Structure (planned)

```
lib/
  l10n/
    app_zh.arb      # Simplified Chinese strings
    app_en.arb      # English strings
    app_localizations.dart   # generated
    app_localizations_zh.dart # generated
    app_localizations_en.dart # generated
  l10n.yaml         # gen-l10n configuration
```

Each ARB entry uses a stable key (e.g. `loginTitle`, `registerButton`,
`emptyRecipesMessage`) with the localized value per locale.

## Login Language Selector

The login page provides a visible selector:

```
中文 | English
```

Choosing a locale updates the app immediately and persists the choice.

## Persisting the Selected Locale

The chosen locale is stored locally (e.g. `shared_preferences`) and restored at
startup, so it survives app restarts. The stored value takes precedence over
the device system locale.

> `shared_preferences` will be added as a dependency when localization is
> implemented; it is documented here, not yet added.

## Adding a New Language Later

1. Add a new ARB file (e.g. `app_fr.arb`) under `lib/l10n/`.
2. Add the locale to `l10n.yaml` and to `supportedLocales`.
3. Run `flutter gen-l10n`.
4. Fill in every key in the new ARB file.

The key set is stable, so untranslated keys surface at generation time (the
generated class falls back to the default locale for missing entries).

## User-Entered Content Is Not Translated

Recipe content (name, ingredients, steps) is **user data**, not UI chrome.
It is stored and displayed exactly as the user typed it.

Example — the app preserves this verbatim:

```
红烧肉
五花肉
冰糖
```

No AI/automatic translation is applied to recipe content in the MVP.
