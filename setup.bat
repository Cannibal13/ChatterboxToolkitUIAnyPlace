@echo off
REM ============================================================================
REM  ChatterboxToolkitUIAnyPlace - Smart Setup Installer
REM  Choose your setup mode: Standard, Portable, or Hybrid
REM ============================================================================

setlocal EnableDelayedExpansion

REM Get the directory where this batch file is located
set "APP_DIR=%~dp0"
set "APP_DIR=%APP_DIR:~0,-1%"
cd /d "%APP_DIR%"

echo.
echo ==============================================================================
echo   ChatterboxToolkitUIAnyPlace - Smart Setup
echo   Your Voice, Anywhere
echo ==============================================================================
echo.
echo App Directory: %APP_DIR%
echo.

REM ============================================================================
REM PHASE 1: DETECT WHAT'S ALREADY INSTALLED
REM ============================================================================
echo [PHASE 1] Detecting your system...
echo.

set "PYTHON_FOUND=0"
set "PYTHON_VERSION="
set "PIP_FOUND=0"
set "CUDA_FOUND=0"
set "TORCH_FOUND=0"
set "TORCH_CUDA=0"
set "FFMPEG_FOUND=0"

REM Check Python
python --version >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=2" %%a in ('python --version 2^>^&1') do set PYTHON_VERSION=%%a
    set "PYTHON_FOUND=1"
    echo   [OK] Python found: %PYTHON_VERSION%

    REM Check pip
    python -m pip --version >nul 2>&1
    if not errorlevel 1 (
        set "PIP_FOUND=1"
        echo   [OK] pip found
    ) else (
        echo   [!] pip not found
    )

    REM Check PyTorch
    python -c "import torch; print(torch.__version__)" >nul 2>&1
    if not errorlevel 1 (
        set "TORCH_FOUND=1"
        for /f "usebackq delims=" %%a in (`python -c "import torch; print(torch.__version__)"`) do set TORCH_VER=%%a
        echo   [OK] PyTorch found: %TORCH_VER%

        REM Check CUDA availability
        for /f "usebackq delims=" %%a in (`python -c "import torch; print(torch.cuda.is_available())"`) do set CUDA_AVAIL=%%a
        if "%CUDA_AVAIL%"=="True" (
            set "TORCH_CUDA=1"
            echo   [OK] CUDA enabled in PyTorch
        ) else (
            echo   [!] PyTorch CPU-only (no CUDA)
        )
    ) else (
        echo   [!] PyTorch not installed
    )
) else (
    echo   [!] Python not found in PATH
)

REM Check CUDA drivers
nvidia-smi >nul 2>&1
if not errorlevel 1 (
    set "CUDA_FOUND=1"
    for /f "usebackq skip=1 tokens=3,4,5 delims=, " %%a in (`nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv`) do (
        echo   [OK] NVIDIA GPU: %%a ^| Driver: %%b ^| VRAM: %%c
    )
) else (
    echo   [!] No NVIDIA GPU detected or drivers not installed
)

REM Check ffmpeg
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    set "FFMPEG_FOUND=1"
    echo   [OK] ffmpeg found
) else (
    echo   [!] ffmpeg not found
)

echo.

REM ============================================================================
REM PHASE 2: DETERMINE SETUP MODE
REM ============================================================================
echo [PHASE 2] Choosing setup mode...
echo.

REM Count what they have
set "HAVE_COUNT=0"
if %PYTHON_FOUND%==1 set /a HAVE_COUNT+=1
if %PIP_FOUND%==1 set /a HAVE_COUNT+=1
if %TORCH_FOUND%==1 set /a HAVE_COUNT+=1

REM Determine recommendation
set "RECOMMENDED_MODE=2"
if %HAVE_COUNT%==3 (
    set "RECOMMENDED_MODE=1"
    echo You have all prerequisites! Standard mode recommended.
) else if %HAVE_COUNT%==2 (
    set "RECOMMENDED_MODE=1"
    echo You have most prerequisites! Standard mode recommended.
) else if %HAVE_COUNT%==1 (
    set "RECOMMENDED_MODE=3"
    echo You have some prerequisites. Hybrid mode recommended.
) else (
    set "RECOMMENDED_MODE=2"
    echo No prerequisites found. Full Portable mode recommended.
)

echo.
echo Choose your setup mode:
echo.
echo [1] STANDARD MODE (Recommended if you have Python 3.11+)
echo     - Uses your existing Python installation
echo     - Creates virtual environment in this folder
echo     - App folder stays portable (you can move it later)
echo     - Fastest setup
echo.
echo [2] FULL PORTABLE MODE (No prerequisites needed)
echo     - Downloads embedded Python 3.11 (~15MB)
echo     - Completely self-contained in this folder
echo     - Works on ANY Windows PC without pre-installation
echo     - Most portable option
echo.
echo [3] HYBRID MODE (Mix of your system + portable)
echo     - Uses your existing Python but installs missing deps
echo     - Downloads only what you don't have
echo     - Good balance of speed and portability
echo.
echo [Recommended: %RECOMMENDED_MODE%]
echo.

REM Get user choice
set "MODE_CHOICE="
set /p MODE_CHOICE="Enter choice (1/2/3) or press Enter for [%RECOMMENDED_MODE%]: "
if "!MODE_CHOICE!"=="" set "MODE_CHOICE=%RECOMMENDED_MODE%"

if "!MODE_CHOICE!"=="1" goto STANDARD_MODE
if "!MODE_CHOICE!"=="2" goto PORTABLE_MODE
if "!MODE_CHOICE!"=="3" goto HYBRID_MODE

echo Invalid choice. Defaulting to mode %RECOMMENDED_MODE%.
set "MODE_CHOICE=%RECOMMENDED_MODE%"
if "!MODE_CHOICE!"=="1" goto STANDARD_MODE
if "!MODE_CHOICE!"=="2" goto PORTABLE_MODE
if "!MODE_CHOICE!"=="3" goto HYBRID_MODE

REM ============================================================================
REM STANDARD MODE
REM ============================================================================
:STANDARD_MODE
echo.
echo ==============================================================================
echo   STANDARD MODE
echo ==============================================================================
echo.

if %PYTHON_FOUND%==0 (
    echo [ERROR] Python not found! Cannot use Standard mode.
    echo Switching to Full Portable mode instead...
    goto PORTABLE_MODE
)

REM Check Python version
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYMAJOR=%%a
    set PYMINOR=%%b
)

if %PYMAJOR% NEQ 3 (
    echo [ERROR] Python 3 required. Found: %PYTHON_VERSION%
    echo Switching to Full Portable mode...
    goto PORTABLE_MODE
)

if %PYMINOR% LSS 11 (
    echo [WARNING] Python 3.11+ recommended. Found: %PYTHON_VERSION%
    echo Some features may not work correctly.
    echo.
    set /p CONTINUE="Continue anyway? (y/n): "
    if /i not "!CONTINUE!"=="y" goto PORTABLE_MODE
)

echo [OK] Using system Python: %PYTHON_VERSION%
echo.

REM Create virtual environment
echo Creating virtual environment in \toolkit\ ...
python -m venv toolkit
if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment.
    pause
    exit /b 1
)

echo [OK] Virtual environment created.
echo.

REM Activate and install
call toolkit\Scripts\activate.bat

python -m pip install --upgrade pip

echo.
echo Installing dependencies... This may take several minutes.
echo.

REM Check if we need special torch for older GPUs
if %TORCH_FOUND%==0 (
    echo PyTorch not found. Installing...
    echo.
    echo GPU Detection:
    if %CUDA_FOUND%==1 (
        echo NVIDIA GPU detected. Installing CUDA-enabled PyTorch...
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    ) else (
        echo No NVIDIA GPU. Installing CPU-only PyTorch...
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    )
) else (
    echo PyTorch already installed. Skipping...
)

echo.
echo Installing remaining requirements...
pip install webrtcvad-wheels
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Some packages failed to install.
    echo If you have a 10-series NVIDIA card or AMD GPU, manually install torch first.
    pause
    exit /b 1
)

goto SETUP_COMPLETE

REM ============================================================================
REM FULL PORTABLE MODE
REM ============================================================================
:PORTABLE_MODE
echo.
echo ==============================================================================
echo   FULL PORTABLE MODE
echo ==============================================================================
echo.

set "PYTHON_EMBED_DIR=%APP_DIR%\python"
set "PYTHON_EMBED_ZIP=%APP_DIR%\python_embed.zip"

REM Check if already downloaded
if exist "%PYTHON_EMBED_DIR%\python.exe" (
    echo [OK] Embedded Python already exists.
    goto PORTABLE_INSTALL_DEPS
)

REM Download embedded Python
echo Downloading Python 3.11.9 embeddable...
echo This is a one-time download (~12MB).
echo.

REM Use PowerShell to download (available on Windows 7+)
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip' -OutFile '%PYTHON_EMBED_ZIP%' -UseBasicParsing"

if not exist "%PYTHON_EMBED_ZIP%" (
    echo [ERROR] Download failed!
    echo Please manually download from:
    echo https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip
    echo Extract to: %PYTHON_EMBED_DIR%
    pause
    exit /b 1
)

echo [OK] Download complete.

REM Extract
echo Extracting Python...
powershell -Command "Expand-Archive -Path '%PYTHON_EMBED_ZIP%' -DestinationPath '%PYTHON_EMBED_DIR%' -Force"

if not exist "%PYTHON_EMBED_DIR%\python.exe" (
    echo [ERROR] Extraction failed!
    pause
    exit /b 1
)

echo [OK] Python extracted.

REM Download get-pip.py
echo.
echo Downloading pip installer...
powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%APP_DIR%\get-pip.py' -UseBasicParsing"

if not exist "%APP_DIR%\get-pip.py" (
    echo [ERROR] Failed to download get-pip.py
    pause
    exit /b 1
)

echo [OK] pip installer downloaded.

REM Install pip
echo.
echo Installing pip...
"%PYTHON_EMBED_DIR%\python.exe" "%APP_DIR%\get-pip.py" --no-warn-script-location

REM Enable site packages in embedded Python (required for pip to work properly)
echo.
echo Configuring embedded Python...
REM Remove python311._pth file to allow site-packages
if exist "%PYTHON_EMBED_DIR%\python311._pth" (
    del "%PYTHON_EMBED_DIR%\python311._pth"
    echo [OK] Enabled site-packages support.
)

REM Create python311._pth with proper paths
echo python311.zip>%PYTHON_EMBED_DIR%\python311._pth
echo .>>%PYTHON_EMBED_DIR%\python311._pth
echo Lib\site-packages>>%PYTHON_EMBED_DIR%\python311._pth
echo import site>>%PYTHON_EMBED_DIR%\python311._pth

:PORTABLE_INSTALL_DEPS
echo.
echo [OK] Embedded Python ready at: %PYTHON_EMBED_DIR%
echo.

REM Install dependencies using embedded Python
echo Installing dependencies... This may take several minutes.
echo.

"%PYTHON_EMBED_DIR%\python.exe" -m pip install --upgrade pip

REM Install PyTorch based on GPU
if %CUDA_FOUND%==1 (
    echo NVIDIA GPU detected. Installing CUDA PyTorch...
    "%PYTHON_EMBED_DIR%\python.exe" -m pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
) else (
    echo No NVIDIA GPU. Installing CPU PyTorch...
    "%PYTHON_EMBED_DIR%\python.exe" -m pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
)

echo.
echo Installing remaining requirements...
REM Install pre-built wheels first (avoid compilation issues with embedded Python)
echo Installing pre-built packages...
"%PYTHON_EMBED_DIR%\python.exe" -m pip install webrtcvad-wheels

REM Now install remaining requirements
echo Installing remaining requirements...
"%PYTHON_EMBED_DIR%\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
    echo [WARNING] Some packages may have failed. Trying with pre-built only...
    "%PYTHON_EMBED_DIR%\python.exe" -m pip install -r requirements.txt --only-binary :all:
    if errorlevel 1 (
        echo [ERROR] Could not install all packages.
        echo [TIP] For embedded Python, some packages need pre-built wheels.
        echo [TIP] Try running: %PYTHON_EMBED_DIR%\python.exe -m pip install <package> --only-binary :all:
        pause
        exit /b 1
    )
)

goto SETUP_COMPLETE

REM ============================================================================
REM HYBRID MODE
REM ============================================================================
:HYBRID_MODE
echo.
echo ==============================================================================
echo   HYBRID MODE
echo ==============================================================================
echo.

if %PYTHON_FOUND%==0 (
    echo No Python found. Will download embedded Python...
    goto PORTABLE_MODE
)

REM Use system Python but check what's missing
echo [OK] Using system Python: %PYTHON_VERSION%
echo.

REM Create venv
echo Creating virtual environment...
python -m venv toolkit
if errorlevel 1 (
    echo [ERROR] Failed to create venv.
    goto PORTABLE_MODE
)

call toolkit\Scripts\activate.bat
python -m pip install --upgrade pip

REM Install only what's missing
if %TORCH_FOUND%==0 (
    echo PyTorch missing. Installing...
    if %CUDA_FOUND%==1 (
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    ) else (
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    )
)

echo.
echo Installing remaining requirements...
pip install webrtcvad-wheels
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Some packages failed.
    pause
    exit /b 1
)

goto SETUP_COMPLETE

REM ============================================================================
REM SETUP COMPLETE
REM ============================================================================
:SETUP_COMPLETE
echo.
echo ==============================================================================
echo   SETUP COMPLETE!
echo ==============================================================================
echo.
echo Next steps:
echo.
echo 1. To launch the app:
echo    Double-click: launch.bat
echo.
echo 2. The app folder is fully portable:
echo    You can move this entire folder anywhere on your system
echo    or to an external drive and it will still work.
echo.

if "%MODE_CHOICE%"=="2" (
    echo 3. For other PCs:
    echo    Copy this entire folder to a USB drive
    echo    Run launch.bat on any Windows PC - no installation needed!
    echo.
)

if %FFMPEG_FOUND%==0 (
    echo [Optional] ffmpeg not found.
    echo Download ffmpeg and place ffmpeg.exe in:
    echo    %APP_DIR%\ffmpeg\bin\ffmpeg.exe
    echo.
)

echo Enjoy ChatterboxToolkitUIAnyPlace!
echo.

REM Create a setup completion marker
set "SETUP_COMPLETE_FILE=%APP_DIR%\.setup_complete"
echo Mode: %MODE_CHOICE%>%SETUP_COMPLETE_FILE%
echo Date: %date% %time%>>%SETUP_COMPLETE_FILE%

pause
endlocal
