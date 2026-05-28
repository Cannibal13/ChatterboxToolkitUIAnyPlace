# ChatterboxToolkitUIAnyPlace 🎙️🧠

A **portable**, comprehensive WebUI Toolkit for Resemble-AI's Chatterbox model.
Run it from any drive — USB flash drive, external SSD, or your local machine.

## What's Different?

| Feature | Original | This Fork (AnyPlace) |
|---------|----------|---------------------|
| **Portability** | Fixed install | Run from any drive |
| **Path Handling** | cwd-dependent | Script-relative |
| **Portable Badge** | ❌ | ✅ Shows when on external drive |
| **Auto-Detection** | ❌ | ✅ Detects removable drives |
| **Bundled Launcher** | ❌ | ✅ `launch.bat` + `setup.bat` |

## Quick Start (Portable)

### First Time Setup
1. Install **Python 3.11** on the target PC
2. Double-click **`setup.bat`** — creates virtual environment and installs dependencies
3. Double-click **`launch.bat`** — starts the app

### Already Set Up?
Just double-click **`launch.bat`** on any PC with Python installed.

### Folder Structure
```
ChatterboxToolkitUIAnyPlace/
├── ChatterboxToolkitUIAnyPlace.py   # Main app (rebranded + portable)
├── launch.bat                       # Portable launcher
├── setup.bat                        # One-time setup helper
├── portable_config.json             # Portable settings
├── requirements.txt                 # Python dependencies
├── src/                             # Chatterbox source modules
├── projects/                        # Your project data (auto-created)
├── nltk_data/                       # NLTK tokenizer data (auto-created)
└── ffmpeg/                          # [Optional] Place ffmpeg here
    └── bin/
        └── ffmpeg.exe
```

## Features

- **Text-to-Speech (TTS)** with voice cloning
- **Voice Conversion (VC)** — change speaker timbre
- **Batch Processing** — process folders of files
- **Parameter Sweeping** — generate variations automatically
- **Data Preparation** — split long text and audio into chunks
- **Project Management** — organized workspaces
- **Regenerate & Edit** — refine outputs without leaving the app

## System Requirements

- **Python 3.11**
- **CUDA-compatible GPU** (highly recommended)
- **FFmpeg** (bundled or system-installed)
- **Windows** (Linux/Mac supported with manual setup)

## License

Same as original ChatterboxToolkitUI project.
