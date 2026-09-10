# Kettleleaf

A private writing studio that lives on your phone. Build **workshops** around one craft, file **recipes** with a seed and a form, then **spark** a draft on-device and rewrite it.

**App Name:** Kettleleaf
**Subtitle:** On-device writing studio
**Category:** Productivity
**Bundle ID:** com.app.kettleleaf.notes
**Database:** `kettleleaf.db`

## Shape of the app

A full-width desk rail with five labelled tabs. Content is laid out as paper sheets with hairline borders on a warm cream ground — Fraunces for headings, Source Sans 3 for body.

- **Desk** — keep-rate, workshop strip, spark call-to-action, recent recipes
- **Workshops** — grid of workshop cards with fill meters, filterable by craft
- **Spark** — pick a source and session length, compose on-device, rewrite, grade the draft
- **Ledger** — draft-stage spread, breakdown by craft and form, total sparks
- **Atelier** — appearance, JSON export/restore, stage glossary, privacy

Secondary screens: hearth (pinned recipes), move log, search, recipe detail, workshop detail, forms, onboarding.

## Domain

| Concept | Meaning |
| --- | --- |
| Workshop | One craft you write for (code, craft, stage, target count) |
| Recipe | One job: title, seed, form, tags, photo |
| Draft stage | Seed → Rough → Tuned → Ready, or Shelved when you pass |
| Sparks | How many times the recipe has been composed and graded |
| Move log | Every refile of a recipe between workshops |

The composer is local: twelve forms and five rewrite moves. It does not call a network model.

Listing copy lives in `meta-data-apple-store.txt`.

```bash
cd example
flutter run
```
