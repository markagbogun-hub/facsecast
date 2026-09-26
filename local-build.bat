@echo off
setlocal enabledelayedexpansion
title RadioCastOS - Local Build
cd /d "%~dp0"

echo ============================================
echo   RadioCastOS - Local Windows Build
echo ============================================
echo.

REM --- 1. Check Python -------------------------------------------------
where python >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Python was not found on PATH.
    echo Install Python 3.11+ from https://python.org and re-run this script.
    pause
    exit /b 1
)
echo [OK] Python found:
python --version

REM --- 2. Check ffmpeg.exe and ffplay.exe are staged in assets\ --------------------------
if not exist "assets\ffmpeg.exe" (
    echo.
    echo [ERROR] assets\ffmpeg.exe is missing.
    echo Download a Windows ffmpeg build from https://www.gyan.dev/ffmpeg/builds/
    echo ^(the "release essentials" zip^), then copy bin\ffmpeg.exe into:
    echo   %cd%\assets\ffmpeg.exe
    echo and re-run this script.
    pause
    exit /b 1
)
if not exist "assets\ffplay.exe" (
    echo.
    echo [ERROR] assets\ffplay.exe is missing.
    echo The local playlist player needs it. Copy bin\ffplay.exe from the same
    echo ffmpeg download into:
    echo   %cd%\assets\ffplay.exe
    echo and re-run this script.
    pause
    exit /b 1
)
echo [OK] assets\ffmpeg.exe and assets\ffplay.exe found.

REM --- 3. Install build dependencies -------------------------------------
echo.
echo Installing build dependencies (pyinstaller, mutagen)...
python -m pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo [ERROR] pip install failed. See the output above.
    pause
    exit /b 1
)
echo [OK] Dependencies installed.

REM --- 4. Build the .exe with PyInstaller ---------------------------------
echo.
echo Building RadioCastOS.exe with PyInstaller...
python -m PyInstaller build.spec --noconfirm
if errorlevel 1 (
    echo [ERROR] PyInstaller build failed. See the output above.
    pause
    exit /b 1
)
if not exist "dist\RadioCastOS\RadioCastOS.exe" (
    echo [ERROR] Build finished but dist\RadioCastOS\RadioCastOS.exe was not produced.
    pause
    exit /b 1
)
echo [OK] Built dist\RadioCastOS\RadioCastOS.exe

REM --- 5. Locate Inno Setup's ISCC.exe ------------------------------------
set "ISCC="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not defined ISCC if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "ISCC=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if not defined ISCC (
    where ISCC.exe >nul 2>nul
    if not errorlevel 1 set "ISCC=ISCC.exe"
)

if not defined ISCC (
    echo.
    echo [ERROR] Inno Setup's ISCC.exe was not found.
    echo Install Inno Setup 6 from https://jrsoftware.org/isinfo.php and re-run.
    echo ^(The plain RadioCastOS.exe still works from dist\RadioCastOS\ without
    echo an installer, if you just want to test it now.^)
    pause
    exit /b 1
)
echo [OK] Found Inno Setup: !ISCC!

REM --- 6. Compile the installer --------------------------------------------
echo.
echo Compiling installer with Inno Setup...
"!ISCC!" installer.iss
if errorlevel 1 (
    echo [ERROR] Inno Setup compilation failed. See the output above.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   DONE
echo   Installer ready at: Output\RadioCastOS-Setup.exe
echo ============================================
echo.
set /p OPEN="Open the Output folder now? (y/n): "
if /i "!OPEN!"=="y" explorer "Output"

pause
