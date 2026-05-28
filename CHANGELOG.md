# Changelog

## [v0.0.2-Turtle-Beta] - 2026-05-28

### Summary
First fully working portable build. The app now launches from a clean install and opens the browser. Smart installer auto-detects your system and recommends the best setup mode. All paths are script-relative for true portability.

### What's New
- **Smart Installer** (`setup.bat`) — Auto-detects Python, pip, PyTorch, CUDA, ffmpeg
- **3 Setup Modes** — Standard (existing Python), Full Portable (embedded Python), Hybrid (mix)
- **Resumable Setup** — If connection drops, re-run setup and it continues where it left off
- **Theme Toggle** — Dark/Light mode with persistence
- **Voice Presets** — Save/load TTS and VC parameter profiles
- **Portable Badge** — Shows when running from external/removable drive
- **Browser Auto-Open** — Preference checkbox, persists across sessions
- **Model Cache Fix** — AI models download to `models_cache/` on your portable drive

### Fixed
- Setup.bat crashing instantly (ANSI color codes broke Windows batch syntax)
- Setup failing on `webrtcvad` wheel build (embedded Python lacks C headers)
- Launch.bat crashing (ANSI codes + `nvidia-smi` `=` signs in for-loops)
- Python IndentationError (portable badge over-indented)
- `load_browser_pref` NameError (function scope wrong)
- Missing dependencies after partial setup (setup stopped early on compile errors)

### Known Issues
- GPU detection shows basic info only (detailed name/VRAM display needs fix)
- `--no-warn-script-location` not yet added to pip commands
- Full app feature testing pending (TTS, VC, batch, splitting, presets)

---

## [v0.0.1-Turtle-Beta] - 2026-05-27

### Summary
Initial release. Project rebrand from ChatterboxToolkitUI to ChatterboxToolkitUIAnyPlace. Added portable infrastructure but not yet fully functional.

### What's New
- Project rebrand with new name
- Portable path structure (script-relative)
- `launch.bat` and `setup.bat` created
- `portable_config.json` added
- Colab notebook updated for this fork

### Known Issues
- Setup crashed on run
- Launch crashed on run
- App did not start
