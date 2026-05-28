@echo off
setlocal EnableDelayedExpansion

set "APP_DIR=%~dp0"
set "APP_DIR=%APP_DIR:~0,-1%"
cd /d "%APP_DIR%"

echo.
echo ==============================================================================
echo   ChatterboxToolkitUIAnyPlace
echo   Portable Audio Generation Toolkit
echo ==============================================================================
echo.
echo App Directory: %APP_DIR%
echo.

if not exist "%APP_DIR%\.setup_complete" (
    echo [WARNING] Setup has not been completed yet!
    echo Please run setup.bat first to install dependencies.
    pause
    exit /b 1
)

set "PYTHON_CMD="

if exist "%APP_DIR%\python\python.exe" (
    set "PYTHON_CMD=%APP_DIR%\python\python.exe"
    echo [OK] Using embedded Python (Full Portable mode)
    goto PYTHON_FOUND
)

if exist "%APP_DIR%\toolkit\Scripts\python.exe" (
    set "PYTHON_CMD=%APP_DIR%\toolkit\Scripts\python.exe"
    echo [OK] Using virtual environment (Standard/Hybrid mode)
    goto PYTHON_FOUND
)

python --version >nul 2>&1
if not errorlevel 1 (
    set "PYTHON_CMD=python"
    echo [OK] Using system Python (fallback)
    goto PYTHON_FOUND
)

echo [ERROR] No Python found! Please run setup.bat first.
pause
exit /b 1

:PYTHON_FOUND
%PYTHON_CMD% --version
echo.

ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    echo [OK] ffmpeg found.
) else (
    echo [INFO] ffmpeg not found. Audio features may be limited.
)

echo.
set "CHATTERBOX_PORTABLE=1"
set "CHATTERBOX_APP_DIR=%APP_DIR%"

echo ==============================================================================
echo  Starting ChatterboxToolkitUIAnyPlace...
echo  Press Ctrl+C to stop the server
echo ==============================================================================
echo.

%PYTHON_CMD% "%APP_DIR%\ChatterboxToolkitUIAnyPlace.py"

if errorlevel 1 (
    echo.
    echo [ERROR] The application exited with an error.
    echo Common fixes:
    echo   1. Run setup.bat again to refresh dependencies
    echo   2. Check that all model files are in models_cache/
    echo   3. Ensure you have enough disk space and RAM
    pause
)

endlocal
