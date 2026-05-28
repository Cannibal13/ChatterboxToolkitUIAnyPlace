@echo off
REM ============================================================================
REM  ChatterboxToolkitUIAnyPlace - Universal Portable Launcher
REM  Works with Standard, Portable, or Hybrid setup modes
REM ============================================================================

setlocal EnableDelayedExpansion

REM Get the directory where this batch file is located
set "APP_DIR=%~dp0"
set "APP_DIR=%APP_DIR:~0,-1%"

REM Change to the app directory (critical for portable operation)
cd /d "%APP_DIR%"

echo.
echo ==============================================================================
echo   ChatterboxToolkitUIAnyPlace
echo   Portable Audio Generation Toolkit
echo ==============================================================================
echo.
echo App Directory: %APP_DIR%
echo.

REM Check if setup has been run
if not exist "%APP_DIR%\.setup_complete" (
    echo [WARNING] Setup has not been completed yet!
    echo.
    echo Please run setup.bat first to install dependencies.
    echo.
    pause
    exit /b 1
)

REM ============================================================================
REM DETERMINE WHICH PYTHON TO USE
REM ============================================================================

set "PYTHON_CMD="

REM Priority 1: Embedded Python (Full Portable mode)
if exist "%APP_DIR%\python\python.exe" (
    set "PYTHON_CMD=%APP_DIR%\python\python.exe"
    echo [OK] Using embedded Python (Full Portable mode)
    goto PYTHON_FOUND
)

REM Priority 2: Virtual environment (Standard/Hybrid mode)
if exist "%APP_DIR%\toolkit\Scripts\python.exe" (
    set "PYTHON_CMD=%APP_DIR%\toolkit\Scripts\python.exe"
    echo [OK] Using virtual environment (Standard/Hybrid mode)
    goto PYTHON_FOUND
)

REM Priority 3: System Python with venv activation
if exist "%APP_DIR%\toolkit\Scripts\activate.bat" (
    echo [OK] Activating virtual environment...
    call "%APP_DIR%\toolkit\Scripts\activate.bat"
    set "PYTHON_CMD=python"
    goto PYTHON_FOUND
)

REM Priority 4: System Python (fallback)
python --version >nul 2>&1
if not errorlevel 1 (
    set "PYTHON_CMD=python"
    echo [OK] Using system Python (fallback)
    goto PYTHON_FOUND
)

echo [ERROR] No Python found!
echo.
echo Tried:
echo   - Embedded Python: %APP_DIR%\python\python.exe
echo   - Virtual env:     %APP_DIR%\toolkit\Scripts\python.exe
echo   - System Python:   python
echo.
echo Please run setup.bat first.
pause
exit /b 1

:PYTHON_FOUND
%PYTHON_CMD% --version
echo.

REM ============================================================================
REM CHECK FOR FFMPEG
REM ============================================================================

ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [INFO] ffmpeg not found in PATH.

    REM Check for bundled ffmpeg
    if exist "%APP_DIR%\ffmpeg\bin\ffmpeg.exe" (
        echo [OK] Found bundled ffmpeg. Adding to PATH...
        set "PATH=%APP_DIR%\ffmpeg\bin;%PATH%"
    ) else (
        echo [WARNING] No bundled ffmpeg found.
        echo [WARNING] Audio processing features may be limited.
        echo.
        echo [TIP] Download ffmpeg and extract to: %APP_DIR%\ffmpeg\
        echo       Structure: %APP_DIR%\ffmpeg\bin\ffmpeg.exe
        echo.
    )
) else (
    echo [OK] ffmpeg found.
)

REM ============================================================================
REM CHECK FOR CUDA / GPU
REM ============================================================================

nvidia-smi >nul 2>&1
if errorlevel 1 (
    echo [INFO] No NVIDIA GPU detected or drivers not installed.
    echo [INFO] App will run on CPU (slower for AI generation).
    echo.
) else (
    echo [OK] NVIDIA GPU detected:
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>nul
    echo.
)

REM ============================================================================
REM SET PORTABLE ENVIRONMENT VARIABLES
REM ============================================================================

set "CHATTERBOX_PORTABLE=1"
set "CHATTERBOX_APP_DIR=%APP_DIR%"

REM ============================================================================
REM LAUNCH THE APP
REM ============================================================================

echo ==============================================================================
echo  Starting ChatterboxToolkitUIAnyPlace...
echo  Press Ctrl+C to stop the server
echo ==============================================================================
echo.

%PYTHON_CMD% "%APP_DIR%\ChatterboxToolkitUIAnyPlace.py"

if errorlevel 1 (
    echo.
    echo [ERROR] The application exited with an error.
    echo.
    echo Common fixes:
    echo   1. Run setup.bat again to refresh dependencies
    echo   2. Check that all model files are in models_cache/
    echo   3. Ensure you have enough disk space and RAM
    echo.
    pause
)

endlocal
