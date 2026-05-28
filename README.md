# ChatterboxToolkitUIAnyPlace 🎙️🧠

A **portable**, comprehensive WebUI Toolkit for Resemble-AI's Chatterbox model.
Run it from any drive — USB flash drive, external SSD, or your local machine.

## What's Different from the Original?

| Feature | Original | This Fork (AnyPlace) |
|---------|----------|---------------------|
| **Portability** | Fixed install | Run from any drive |
| **Path Handling** | cwd-dependent | Script-relative |
| **Setup** | Manual steps | Smart auto-detecting installer |
| **Setup Modes** | One way | 3 modes: Standard / Portable / Hybrid |
| **Theme** | Light only | Dark + Light toggle |
| **Voice Presets** | ❌ | ✅ Save/load TTS & VC settings |
| **Portable Badge** | ❌ | ✅ Shows when on external drive |
| **Model Cache** | System drive (`~/.cache`) | Portable drive (`models_cache/`) |
| **Colab Support** | Original repo | Updated for this fork |

---

## Quick Start

### Option 1: Full Portable (Zero Prerequisites)
1. Download or clone this repository
2. Double-click **`setup.bat`** — it will auto-download Python 3.11 if needed
3. Double-click **`launch.bat`** — starts the app

### Option 2: Standard (You Have Python 3.11+)
1. Download or clone this repository
2. Double-click **`setup.bat`** — choose **Standard Mode**
3. Double-click **`launch.bat`** — starts the app

### Option 3: Google Colab (Cloud)
1. Open `ChatterboxToolkitUIAnyPlace.ipynb` in Google Colab
2. Run all cells
3. Uses Gradio share link (no local install needed)

---

## System Requirements

- **Windows** (primary target — Linux/Mac possible with manual setup)
- **Python 3.11** (auto-downloaded in Portable mode)
- **CUDA-compatible GPU** highly recommended (CPU works but is slow)
- **FFmpeg** (optional — bundled or system-installed)

---

## Features

- **Text-to-Speech (TTS)** — Generate speech from text using a reference voice
- **Voice Conversion (VC)** — Change the speaker timbre of any audio
- **Voice Cloning** — Clone any voice from a short audio sample
- **Batch Processing** — Process entire folders of text or audio files
- **Parameter Sweeping** — Generate multiple variations automatically
- **Data Preparation** — Split long text and audio into model-friendly chunks
- **Project Management** — Organized workspaces with folder structure
- **Regenerate & Edit** — Refine outputs without leaving the app
- **Voice Presets** — Save and load your favorite voice settings
- **Dark/Light Theme** — Toggle between themes, persists across sessions

---

## Setup Modes Explained

| Mode | Best For | Downloads | Python Source |
|------|----------|-----------|---------------|
| **Standard** | Already have Python 3.11+ | Just dependencies | Your system Python |
| **Full Portable** | No Python, or want true portability | Python + all deps | Embedded in `python/` folder |
| **Hybrid** | Have Python but missing deps | Only missing deps | Your system Python |

The installer auto-detects what you have and recommends the best mode.

---

## Folder Structure

```
ChatterboxToolkitUIAnyPlace/
├── ChatterboxToolkitUIAnyPlace.py   # Main app
├── launch.bat                       # Universal launcher
├── setup.bat                        # Smart installer
├── portable_config.json             # Portable settings
├── requirements.txt                 # Python dependencies
├── ChatterboxToolkitUIAnyPlace.ipynb # Colab notebook
├── src/                             # Chatterbox source modules
│   └── chatterbox/
│       ├── __init__.py
│       ├── tts.py                   # TTS engine
│       ├── vc.py                    # Voice conversion engine
│       └── models/
│           └── s3gen.py             # Model architecture
├── projects/                        # Your project data (auto-created)
├── models_cache/                    # AI models (auto-created, portable!)
├── voice_presets/                   # Saved voice settings (auto-created)
├── nltk_data/                       # Text tokenizer data (auto-created)
└── python/ or toolkit/              # Python environment (auto-created)
```

---

## Model Cache (Important!)

Unlike the original project, this fork stores downloaded AI models in:
```
<repo_folder>/models_cache/
```

**Why this matters:**
- Models travel with your portable drive
- No re-downloading on new PCs
- Works offline after first setup
- Easy to backup or transfer

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Python not found" | Run `setup.bat` and choose Full Portable mode |
| "No NVIDIA GPU" | App works on CPU but is much slower |
| "ffmpeg not found" | Download ffmpeg and place in `ffmpeg/bin/ffmpeg.exe` |
| "Models re-downloading" | Ensure `models_cache/` folder is with the app |
| "Theme not saving" | Check that `.theme_state` file can be written |

---

## Credits

- Built on [Resemble-AI's Chatterbox](https://github.com/resemble-ai/chatterbox)
- Original UI by [dasjoms/ChatterboxToolkitUI](https://github.com/dasjoms/ChatterboxToolkitUI)
- Portable fork by [Cannibal13](https://github.com/Cannibal13)

---

## License

Same as original ChatterboxToolkitUI project.
