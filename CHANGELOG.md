# RadioCastOS Changelog

## 1.12.0 — Commercial As-Run Log
- Every commercial spot that actually starts playing is recorded with its date, time, campaign, spot name and program.
- New Automation button "Commercial As-Run Log": filter by date range and campaign, then Print Report or Export CSV.
- Printable report (opens in the browser and prints) has a summary per campaign, a numbered play log and signature lines.
- Log file: `%APPDATA%\RadioCastOS\commercial_log.csv` (opens in Excel).
- Fixed: `track_metadata` was missing from `scheduler.py`, which broke the Next 10 preview and rotation separation. Tag lookups are now cached.

## 1.11.2 — Startup Fix
- Fixed startup crash: `devices.find_ffplay` was missing, so the app could not import.
- FFmpeg tools are now located inside the PyInstaller bundle (`_internal`), next to the exe, or on PATH.
- Build now declares all app modules explicitly (fixes "No module named 'scheduler'" style failures).
- CI runs an import check before building, so a broken package fails early instead of passing the launch test.
- CI installer step now reports its output and fails loudly.

## 1.11.1 — Packaging Cleanup
- Removed stray `.bak` and `__pycache__` files from the package.
- `local-build.bat` now checks for `ffplay.exe` as well as `ffmpeg.exe`.
- `requirements.txt` documents the optional `mutagen` dependency accurately.
- Added `.gitignore` for build output and binaries.
- Reordered this changelog and removed duplicate headings.
- No application code changes.

## 1.11.0 — Intelligent Music Library & Metadata
- Expanded track records with album, genre, year, BPM, energy, mood, language, gender, category and intro/outro metadata.
- Added optional Mutagen tag import with safe filename fallback.
- Added Metadata Manager for reviewing and editing programming metadata.
- Added tag refresh without overwriting operator-controlled programming fields.
- Music selection explanations now include available genre/year/BPM metadata.
- Existing 1.10 scheduler, clock, imaging and news systems remain compatible with older library/automation JSON.

## 1.10.0 — Advanced Music Scheduler & Selector
- Added rule-driven music selection constraints.
- Added independent artist, title and category separation.
- Added daypart-aware category quotas for Morning/Afternoon/Evening/Overnight.
- Added graceful fallback when strict constraints cannot be satisfied.
- Added selection-reason history for auditability and “why was this song selected?” explanations.
- Added Advanced Music Scheduler editor to the Automation tab.
- Preserves 1.7 imaging, 1.8 scheduled/news segments and 1.9 broadcast clock functionality.

## 1.9.0 — News & Scheduled Segments
- Added first-class `news` content category to station programs.
- Added News to automation content assignment.
- Added News as a valid rules-engine action.
- Added morning clock sequence support for Hour ID → News Jingle → News → music.
- Preserved 1.7.0 JSON compatibility; existing stations simply have an empty News bucket until populated.

## 1.9.0 — Broadcast Clock Editor
- Added visual Broadcast Clock Editor in Automation.
- Create, edit, delete and restore hourly clock templates.
- Create, edit and delete timed clock events.
- Supports music, power/current/recurrent/gold/oldies/slow/up-tempo, station ID, jingle, sweeper, promo, news and commercial events.
- Clock remains declarative: event targets are data, while the automation engine decides when content can safely fire.

## 1.7.0 — Station Imaging & Rules Engine
- Added declarative station-imaging rules with priority-based evaluation.
- Added triggers for song count, elapsed minutes, top of hour, after-category and after-power.
- Added daypart-aware rules for Morning, Afternoon, Evening and Overnight.
- Added rule actions for Station ID, Jingle, Sweeper, Promo, Commercial and Music.
- Added professional defaults: 15-minute IDs, top-of-hour ID, daypart sweepers, post-commercial jingle and Power-song imaging.
- Added Automation UI for adding, editing, deleting, enabling/disabling and restoring imaging rules.
- Preserved older automation JSON and legacy clock-rule compatibility.
- Kept NEXT 10 preview non-mutating, including imaging-rule state.

## 1.6.1 — Professional Rotation Intelligence
- Better artist/title parsing from common `Artist - Title` filenames
- Artist and title separation now use parsed metadata keys
- Rotation history/audit trail with selection reasons
- NEXT 10 displays artist + title + category
- Added Rotation History operator window
- Added `why_next()` explanation API for automation diagnostics
- Preview remains non-mutating, including history state

## 1.5.1 — Smart Commercial System
- Added persistent commercial campaigns with start/end dates.
- Added daily and hourly play limits.
- Added campaign priority and spot duration metadata.
- Added campaign played/missed statistics.
- Added campaign and spot repetition avoidance.
- Added campaign selection before the legacy commercial pool.
- Added Commercial Campaigns operator dialog.
- Added make-good tracking API for missed commercial spots.
- Kept commercial fallback compatibility with existing 1.4/1.5 configurations.

## 1.5.0 — Professional Radio Clock
- Added configurable station clock rules for commercial breaks, spot counts and station IDs.
- Added non-mutating NEXT 10 automation preview.
- Added live operator clock and next-item display.
- Added one-click Return to AutoDJ after presenter takeover.
- Improved commercial break sequencing so multi-spot breaks complete before music resumes.
- Removed unreachable legacy scheduler code.
- Preserved 1.4.x automation configuration compatibility.

## 1.5.0 — Professional Radio Clock polish
- Added Morning / Afternoon / Evening / Overnight clock templates.
- Added wall-clock top-of-hour station ID handling.
- Added clock-event countdown helpers and clock-name reporting.
- Added imaging categories for sweepers and promos while retaining 1.4.x JSON compatibility.
- Improved NEXT 10 preview with virtual clock look-ahead so upcoming clock events are visible.
- Added Automation UI controls for Play Next and Emergency Stop.
- Removed the old scheduler's rigid Jingle → Commercial → Music → Station ID dependency.

## 1.4.0 — Radio Automation Scheduler
- Added clock-driven weekly program scheduling.
- Added program content buckets: Jingle, Commercial, Music and Station ID.
- Added 24/7 AutoDJ sequencing with automatic next-item playback.
- Added presenter takeover so manual playlist control can interrupt automation.
- Added persistent automation configuration under `%APPDATA%\\RadioCastOS\\automation.json`.
- Added cross-midnight schedule handling and schedule-aware program switching.

## 1.3.0 — Local Automation Player
- Added ffplay-based local playlist playback engine.
- Automatic next-track playback and Previous/Next controls.
- Play/Pause/Resume/Stop controls in Library & Playlist.
- Now-playing metadata follows locally playing tracks.
- Player status is shown in the operator UI.

## 1.2.0 - Library & Playlist Foundation
- Added persistent Music Library.
- Added recursive music-folder scanning for MP3, WAV, FLAC, OGG, AAC and M4A.
- Added playlist management with add/remove/clear actions.
- Added Library & Playlist operator tab.
- Library data is stored separately from station streaming configuration.
- Prepared the application for the next automation stage: scheduler and playback engine.
