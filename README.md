# RadioCastOS

A small Windows desktop app for streaming audio (mic, line-in, or a virtual
cable) to an Icecast2 / Shoutcast v2 server, with a best-effort legacy mode
for old Shoutcast v1 DNAS servers.

- **Connection tab** — server type, host, port, mount, source credentials, TLS.
- **Audio tab** — per-source mixer with independent volume faders (mic, playback/loopback, or any other detected device), mute, codec (mp3/aac/ogg), bitrate, sample rate, channels.
- **Recording tab** — record the same mixer sources straight to an MP3/WAV file on your PC, independent of streaming (works whether or not you're live).
- **Now Playing tab** — station metadata + push now-playing updates without restarting the stream.
- Auto-reconnect with backoff, live connection log, persisted settings (`%APPDATA%\RadioCastOS\config.json`).

## Why this needs to be *built* on Windows (but you don't need a Windows PC)

Audio capture uses Windows' DirectShow (`dshow`) devices via ffmpeg, and the
final artifact is a Windows `.exe` / installer — both are Windows-native
concerns that can't be produced or tested from a Linux sandbox. The included
GitHub Actions workflow solves this: push this repo to GitHub and it builds
the `.exe` and installer for you on a real Windows runner, no local Windows
machine required.

## Repo layout

```
src/                    Application source (Python, stdlib + Tkinter only)
  main.py               Entry point
  app_gui.py            Tkinter UI (3 tabs + status bar + log)
  streamer.py           ffmpeg-driven Icecast2 / Shoutcast v2 streaming
  shoutcast_v1.py        Legacy Shoutcast v1 hand-rolled socket client
  devices.py             ffmpeg dshow device enumeration
  recorder.py            Local "record to PC" capture (own ffmpeg process, independent of streaming)
  config.py               Settings persistence (JSON in %APPDATA%)
assets/                  Put ffmpeg.exe, ffplay.exe and icon.ico here for local builds (CI fetches ffmpeg itself)
build.spec               PyInstaller spec -> dist/RadioCastOS/RadioCastOS.exe
installer.iss             Inno Setup script -> Output/RadioCastOS-Setup.exe
.github/workflows/
  build-windows.yml       CI: builds the .exe + installer on every push
requirements.txt          Just pyinstaller (build-time only; app itself has zero deps)
```

## Get a built installer without touching Windows

1. Push this project to a GitHub repo.
2. Go to the **Actions** tab — the "Build Windows installer" workflow runs
   automatically on push (or trigger it manually via "Run workflow").
3. When it finishes, open the run and download the **RadioCastOS-Setup**
   artifact — that's `RadioCastOS-Setup.exe`, a real Inno Setup installer.
4. The **RadioCastOS-app** artifact is the unpacked folder build if you'd
   rather run/inspect it without installing.

The workflow downloads a static Windows ffmpeg build automatically, so you
don't need to source one yourself.

## Building locally (if you do have access to a Windows machine)

Easiest option: put `ffmpeg.exe and ffplay.exe` in `assets\` (see below), then double-click
**`local-build.bat`**. It installs PyInstaller, builds the `.exe`, finds your
Inno Setup install, and compiles `Output\RadioCastOS-Setup.exe` for you,
checking each step and telling you exactly what's missing if something fails.

Or run the steps yourself:

```powershell
pip install -r requirements.txt
# Download ffmpeg for Windows (e.g. https://www.gyan.dev/ffmpeg/builds/)
# and place both ffmpeg.exe and ffplay.exe in the assets\ folder
pyinstaller build.spec
# Output: dist\RadioCastOS\RadioCastOS.exe

# Then, with Inno Setup 6 installed:
ISCC installer.iss
# Output: Output\RadioCastOS-Setup.exe
```

## Running from source (for quick iteration, still Windows-only for capture)

```powershell
pip install -r requirements.txt   # only needed for pyinstaller; tkinter ships with Python
cd src
python main.py
```

`devices.py`/`streamer.py` shell out to `ffmpeg` on PATH when run this way,
so make sure `ffmpeg.exe` and `ffplay.exe` are reachable (either on PATH or adjust
`devices.find_ffmpeg()` to point at it).

## Recording to your PC

The Recording tab starts a second, independent ffmpeg process that captures
whatever sources are enabled in the Audio mixer straight to a timestamped
MP3 or WAV file (default location `Documents\RadioCastOS Recordings`, or
pick your own folder). It has nothing to do with the Icecast/Shoutcast
connection, so you can:

- Record without ever going live (e.g. to check levels or archive a rehearsal).
- Record while live, as a local backup of the broadcast.
- Start/stop recording independently of Start/stop streaming, any time.

**Caveat:** recording and streaming at the same time means two ffmpeg
processes both open the same capture device(s). Virtual/loopback devices
(VB-Audio Virtual Cable, VoiceMeeter, Stereo Mix) generally allow this;
some physical microphone drivers only allow one open handle and will
cause the recorder to fail to start in that case — the connection log
will show ffmpeg's error if so.

## Known limitations / things to verify once you have real servers to test against

- **Shoutcast v1 mode is best-effort.** The bare-password-then-headers
  handshake is implemented per the classic DNAS v1 spec, but v1 servers
  vary by build/version. Test against your actual server before relying on it.
- **Metadata push for Shoutcast v1** isn't implemented (v1's `admin.cgi`
  update path differs by server build); v1 sessions currently stream audio
  only. Icecast2 and Shoutcast v2 metadata push both work over HTTP.
- **AAC/OGG on Shoutcast v1** isn't supported — v1 is MP3-only by design,
  and the app enforces `libmp3lame` in that code path regardless of the
  Audio tab's codec selection.
- Device names come straight from ffmpeg's dshow listing, so device
  availability/naming depends on what's installed (mic, line-in, or a
  virtual cable like VB-Audio Virtual Cable / VoiceMeeter for routing
  desktop or app audio into the stream).
- **The CI build includes a smoke test** that launches the built
  `RadioCastOS.exe` on the GitHub Windows runner and checks it stays up
  for 8 seconds instead of crashing on startup — catches import/config
  errors early. The runner has no real microphone or loopback device, so
  this only proves the app *starts*; it can't validate actual audio
  capture or streaming. Do that on a real Windows machine (or a Windows
  VM with a genuine audio device — most free browser-based Windows VMs
  don't expose usable audio hardware, so they're fine for checking the
  installer/UI but not for testing the streaming path itself).


## Radio Automation Scheduler (1.4.0)

RadioCastOS now includes a clock-driven AutoDJ layer. Create programs, assign library tracks to **Jingle**, **Commercial**, **Music**, and **Station ID** buckets, then add weekly clock schedules. When AutoDJ is enabled it follows the schedule and advances automatically through the broadcast sequence. Manual playlist controls provide presenter takeover.

The scheduler persists independently in `%APPDATA%\\RadioCastOS\\automation.json` on Windows.

## 1.5.0 Professional Radio Clock
RadioCastOS 1.5.0 adds a configurable broadcast clock on top of the 1.4 scheduler. Operators can set commercial frequency, spots per break and station-ID frequency, view the next 10 automated items without changing playback state, and return from presenter takeover to AutoDJ with one click.

### Professional clock behavior
The 1.5.0 automation engine uses named clock templates (Morning, Afternoon,
Evening and Overnight) with wall-clock event targets. Top-of-hour station IDs,
imaging, music and commercial breaks are selected from the active clock while
never interrupting a track that is already playing. The Automation tab shows
the active clock, the next clock target, a T-minus countdown and a non-mutating
NEXT 10 preview. Legacy song-count rules remain available as operator overrides.


### RadioCastOS 1.6.1
Professional Rotation Intelligence adds metadata-aware artist/title separation, a 100-item in-memory rotation audit trail, selection-reason diagnostics, and a richer NEXT 10 preview. Filename conventions such as `Artist - Title.mp3` are parsed automatically.


## 1.9.0 — News & Scheduled Segments

RadioCastOS 1.9.0 extends the rules engine with a first-class **News** content bucket. News clips can be assigned to programs and inserted by wall-clock rules without hard-coding them into a playlist.

- Added `news` as a first-class automation content category.
- Added News to the Automation program/content assignment UI.
- Added News as a valid imaging-rule action.
- Morning clock now supports Hour ID → News Jingle → News → music as data-driven clock events.
- Existing 1.7.0 automation files remain compatible; the new News bucket defaults to empty until audio is assigned.

## 1.7.0 — Station Imaging & Rules Engine

RadioCastOS 1.7.0 replaces rigid imaging sequences with a declarative station-rules layer.

Rules can trigger on:
- every N songs, with separate Morning / Afternoon / Evening / Overnight rules
- elapsed wall-clock minutes
- top of hour
- after a Commercial break
- after a Power song

Rules select actions such as Station ID, Jingle, Sweeper, Promo, Commercial or Music.
Rules are evaluated by priority and skipped automatically when their content bucket is empty.

The Automation tab now includes **Station Imaging Rules**, where operators can add, edit,
delete, enable/disable and restore professional defaults. Existing automation JSON remains
compatible; 1.7.0 writes the new `imaging_rules` section while retaining older fields.

The default starter rules produce a professional clock such as:
- Top of hour → Station ID
- Every 15 minutes → Station ID
- Morning → Sweeper every 3 songs
- Afternoon → Sweeper every 2 songs
- Evening → Sweeper every 3 songs
- Overnight → Sweeper every 4 songs
- After commercial → Jingle
- After Power song → Sweeper

These are rules, not a hard-coded playback sequence, so the station can be reprogrammed
without changing Python code.

## 1.10.0 Advanced Music Scheduler
The music selector is now a rules engine rather than a simple random/sequence picker. Configure artist/title/category separation, daypart quotas, history size and graceful fallback from **Automation → Advanced Music Scheduler**. Each selection records a human-readable reason for audit and troubleshooting.

## 1.11.0 Intelligent Music Library & Metadata
The library now supports broadcast-programming metadata including genre, year, BPM, energy, mood, language, gender, category, intro and outro. Use **Library → Metadata Manager** to inspect/edit records. If Mutagen is installed, common audio tags are imported automatically; otherwise filename fallback remains available.

## 1.11.1 Packaging cleanup
Removed stray backup and cache files, `local-build.bat` now requires both `ffmpeg.exe` and `ffplay.exe`, and the changelog was put in order.

## 1.11.2 Startup fix
Fixed a startup import error and made ffmpeg/ffplay discovery work inside the packaged app.

## 1.12.0 Commercial as-run log
Automation tab → Commercial As-Run Log shows every commercial played, with date and time. Choose a date range and campaign, then Print Report (opens in your browser) or Export CSV. The raw log is `%APPDATA%\\RadioCastOS\\commercial_log.csv`.
