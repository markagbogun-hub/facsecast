# -*- mode: python ; coding: utf-8 -*-
#
# Build with:  pyinstaller build.spec
# Output:      dist/RadioCastOS/RadioCastOS.exe  (folder build, so ffmpeg.exe
#              sits alongside it — simplest and most reliable for an app
#              that shells out to a companion binary).
#
# Expects assets/ffmpeg.exe to exist (the CI workflow downloads it
# automatically; for a local build, drop a Windows ffmpeg.exe build there
# yourself — see README.md).

import os

block_cipher = None
SRC = os.path.join(os.path.dirname(os.path.abspath(SPEC)), "src")
ASSETS = os.path.join(os.path.dirname(os.path.abspath(SPEC)), "assets")

ffmpeg_path = os.path.join(ASSETS, "ffmpeg.exe")
ffplay_path = os.path.join(ASSETS, "ffplay.exe")
binaries = []
if os.path.exists(ffmpeg_path):
    binaries.append((ffmpeg_path, "."))
if os.path.exists(ffplay_path):
    binaries.append((ffplay_path, "."))

a = Analysis(
    [os.path.join(SRC, "main.py")],
    pathex=[SRC],
    binaries=binaries,
    datas=[],
    hiddenimports=["app_gui", "scheduler", "asrun", "library", "player", "devices", "config", "mixer", "recorder", "streamer", "shoutcast_v1", "mutagen"],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name="RadioCastOS",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    icon=os.path.join(ASSETS, "icon.ico") if os.path.exists(os.path.join(ASSETS, "icon.ico")) else None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name="RadioCastOS",
)
