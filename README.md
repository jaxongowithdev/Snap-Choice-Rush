# Orbit Recall

An offline memory-training deck for space and science class. Build **missions** around one topic, file **cues** with an anchor picture, then run a **drill** that queues your weakest cues first.

**App Name:** Orbit Recall
**Subtitle:** Space memory drills, offline
**Category:** Education
**Bundle ID:** com.app.orbitrecall.build
**Database:** `orbit_recall.db`

## Shape of the app

A floating rounded pill dock with five tabs; the active tab expands to show its label. Content is laid out as a bento grid of large-radius tiles on a soft nebula background — Outfit for headings, Nunito for body.

- **Deck** — bento dashboard: memory load ring, stat tiles, mission strip, drill call-to-action, briefing
- **Missions** — grid of mission cards with progress rings, filterable by track
- **Drill** — pick a source and run length, flip cards, grade yourself, get a run score
- **Stats** — recall spread, breakdown by track and cue type, total reps
- **Base** — appearance, JSON export/restore, recall-level glossary, privacy

Secondary screens: drill deck (starred cues), flight log (reassign timeline), search, cue detail, mission detail, forms, onboarding.

## Domain

| Concept | Meaning |
| --- | --- |
| Mission | One themed set of cues (code, track, stage, target count) |
| Cue | One card: front question, anchor answer, type, tags, photo |
| Recall level | Fresh → Shaky → Steady → Locked, or Faded when missed |
| Reps | How many times the cue has been graded in a drill |
| Flight log | Every reassign of a cue between missions |

Listing copy lives in `meta-data-apple-store.txt`.

```bash
cd example
flutter run
```
