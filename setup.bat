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

REM Colors for Windows 10+ (ANSI escape codes)
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "CYAN=[96m"
set "WHITE=[97m"
set "RESET=[0m"

REM Check if we can use ANSI colors
for /f "tokens=3" %%a in ('echo %WIN_VER%') do set WIN_VER=%%a

echo.
echo %CYAN%============================================================================%RESET%
echo %CYAN%  ChatterboxToolkitUIAnyPlace - Smart Setup%RESET%
echo %CYAN%  Your Voice, Anywhere%RESET%
echo %CYAN%============================================================================%RESET%
echo.
echo App Directory: %APP_DIR%
echo.

REM ============================================================================
REM PHASE 1: DETECT WHAT'S ALREADY INSTALLED
REM ============================================================================
echo %YELLOW%[PHASE 1] Detecting your system...%RESET%
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
    echo %GREEN%  [OK] Python found: %PYTHON_VERSION%%RESET%

    REM Check pip
    python -m pip --version >nul 2>&1
    if not errorlevel 1 (
        set "PIP_FOUND=1"
        echo %GREEN%  [OK] pip found%RESET%
    ) else (
        echo %YELLOW%  [!] pip not found%RESET%
    )

    REM Check PyTorch
    python -c "import torch; print(torch.__version__)" >nul 2>&1
    if not errorlevel 1 (
        set "TORCH_FOUND=1"
        for /f "usebackq delims=" %%a in (`python -c "import torch; print(torch.__version__)"`) do set TORCH_VER=%%a
        echo %GREEN%  [OK] PyTorch found: %TORCH_VER%%RESET%

        REM Check CUDA availability
        python -c "import torch; print(torch.cuda.is_available())" >nul 2>&1
        for /f "usebackq delims=" %%a in (`python -c "import torch; print(torch.cuda.is_available())"`) do set CUDA_AVAIL=%%a
        if "%CUDA_AVAIL%"=="True" (
            set "TORCH_CUDA=1"
            echo %GREEN%  [OK] CUDA enabled in PyTorch%RESET%
        ) else (
            echo %YELLOW%  [!] PyTorch CPU-only (no CUDA)%RESET%
        )
    ) else (
        echo %YELLOW%  [!] PyTorch not installed%RESET%
    )
) else (
    echo %YELLOW%  [!] Python not found in PATH%RESET%
)

REM Check CUDA drivers
nvidia-smi >nul 2>&1
if not errorlevel 1 (
    set "CUDA_FOUND=1"
    for /f "usebackq skip=1 tokens=3,4,5 delims=, " %%a in (`nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv`) do (
        echo %GREEN%  [OK] NVIDIA GPU: %%a ^| Driver: %%b ^| VRAM: %%c%RESET%
    )
) else (
    echo %YELLOW%  [!] No NVIDIA GPU detected or drivers not installed%RESET%
)

REM Check ffmpeg
ffmpeg -version >nul 2>&1
if not errorlevel 1 (
    set "FFMPEG_FOUND=1"
    echo %GREEN%  [OK] ffmpeg found%RESET%
) else (
    echo %YELLOW%  [!] ffmpeg not found%RESET%
)

echo.

REM ============================================================================
REM PHASE 2: DETERMINE SETUP MODE
REM ============================================================================
echo %YELLOW%[PHASE 2] Choosing setup mode...%RESET%
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
    echo %GREEN%You have all prerequisites! Standard mode recommended.%RESET%
) else if %HAVE_COUNT%==2 (
    set "RECOMMENDED_MODE=1"
    echo %GREEN%You have most prerequisites! Standard mode recommended.%RESET%
) else if %HAVE_COUNT%==1 (
    set "RECOMMENDED_MODE=3"
    echo %YELLOW%You have some prerequisites. Hybrid mode recommended.%RESET%
) else (
    set "RECOMMENDED_MODE=2"
    echo %YELLOW%No prerequisites found. Full Portable mode recommended.%RESET%
)

echo.
echo %WHITE%Choose your setup mode:%RESET%
echo.
echo %CYAN%[1] STANDARD MODE%RESET% ^(Recommended if you have Python 3.11+^)
echo     - Uses your existing Python installation
echo     - Creates virtual environment in this folder
echo     - App folder stays portable ^(you can move it later^)
echo     - %GREEN%Fastest setup%RESET%
echo.
echo %CYAN%[2] FULL PORTABLE MODE%RESET% ^(No prerequisites needed^)
echo     - Downloads embedded Python 3.11 ^(~15MB^)
echo     - Completely self-contained in this folder
echo     - Works on ANY Windows PC without pre-installation
echo     - %GREEN%Most portable option%RESET%
echo.
echo %CYAN%[3] HYBRID MODE%RESET% ^(Mix of your system + portable^)
echo     - Uses your existing Python but installs missing deps
echo     - Downloads only what you don't have
echo     - Good balance of speed and portability
echo.
echo %YELLOW%[Recommended: %RECOMMENDED_MODE%]%RESET%
echo.

REM Get user choice
set /p MODE="Enter choice (1/2/3) or press Enter for [%RECOMMENDED_MODE%]: "
if "!MODE!"=="" set "MODE=%RECOMMENDED_MODE%"

if "!MODE!"=="1" goto STANDARD_MODE
if "!MODE!"=="2" goto PORTABLE_MODE
if "!MODE!"=="3" goto HYBRID_MODE

echo %RED%Invalid choice. Defaulting to mode %RECOMMENDED_MODE%.%RESET%
set "MODE=%RECOMMENDED_MODE%"
if "!MODE!"=="1" goto STANDARD_MODE
if "!MODE!"=="2" goto PORTABLE_MODE
if "!MODE!"=="3" goto HYBRID_MODE

REM ============================================================================
REM STANDARD MODE
REM ============================================================================
:STANDARD_MODE
echo.
echo %CYAN%============================================================================%RESET%
echo %CYAN%  STANDARD MODE%RESET%
echo %CYAN%============================================================================%RESET%
echo.

if %PYTHON_FOUND%==0 (
    echo %RED%[ERROR] Python not found! Cannot use Standard mode.%RESET%
    echo %YELLOW%Switching to Full Portable mode instead...%RESET%
    goto PORTABLE_MODE
)

REM Check Python version
for /f "tokens=1,2 delims=." %%a in ("%PYTHON_VERSION%") do (
    set PYMAJOR=%%a
    set PYMINOR=%%b
)

if %PYMAJOR% NEQ 3 (
    echo %RED%[ERROR] Python 3 required. Found: %PYTHON_VERSION%%RESET%
    echo %YELLOW%Switching to Full Portable mode...%RESET%
    goto PORTABLE_MODE
)

if %PYMINOR% LSS 11 (
    echo %YELLOW%[WARNING] Python 3.11+ recommended. Found: %PYTHON_VERSION%%RESET%
    echo %YELLOW%Some features may not work correctly.%RESET%
    echo.
    set /p CONTINUE="Continue anyway? (y/n): "
    if /i not "!CONTINUE!"=="y" goto PORTABLE_MODE
)

echo %GREEN%[OK] Using system Python: %PYTHON_VERSION%%RESET%
echo.

REM Create virtual environment
echo Creating virtual environment in \toolkit\ ...
python -m venv toolkit
if errorlevel 1 (
    echo %RED%[ERROR] Failed to create virtual environment.%RESET%
    pause
    exit /b 1
)

echo %GREEN%[OK] Virtual environment created.%RESET%
echo.

REM Activate and install
call toolkit\Scripts\activate.bat

python -m pip install --upgrade pip

echo.
echo Installing dependencies... This may take several minutes.
echo.

REM Check if we need special torch for older GPUs
if %TORCH_FOUND%==0 (
    echo %YELLOW%PyTorch not found. Installing...%RESET%
    echo.
    echo %CYAN%GPU Detection:%RESET%
    if %CUDA_FOUND%==1 (
        echo %GREEN%NVIDIA GPU detected. Installing CUDA-enabled PyTorch...%RESET%
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    ) else (
        echo %YELLOW%No NVIDIA GPU. Installing CPU-only PyTorch...%RESET%
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    )
) else (
    echo %GREEN%PyTorch already installed. Skipping...%RESET%
)

echo.
echo Installing remaining requirements...
pip install -r requirements.txt
if errorlevel 1 (
    echo %RED%[ERROR] Some packages failed to install.%RESET%
    echo %YELLOW%If you have a 10-series NVIDIA card or AMD GPU, manually install torch first.%RESET%
    pause
    exit /b 1
)

goto SETUP_COMPLETE

REM ============================================================================
REM FULL PORTABLE MODE
REM ============================================================================
:PORTABLE_MODE
echo.
echo %CYAN%============================================================================%RESET%
echo %CYAN%  FULL PORTABLE MODE%RESET%
echo %CYAN%============================================================================%RESET%
echo.

set "PYTHON_EMBED_DIR=%APP_DIR%\python"
set "PYTHON_EMBED_ZIP=%APP_DIR%\python_embed.zip"

REM Check if already downloaded
if exist "%PYTHON_EMBED_DIR%\python.exe" (
    echo %GREEN%[OK] Embedded Python already exists.%RESET%
    goto PORTABLE_INSTALL_DEPS
)

REM Download embedded Python
echo %YELLOW%Downloading Python 3.11.9 embeddable...%RESET%
echo This is a one-time download (~12MB).
echo.

REM Use PowerShell to download (available on Windows 7+)
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip' -OutFile '%PYTHON_EMBED_ZIP%' -UseBasicParsing"

if not exist "%PYTHON_EMBED_ZIP%" (
    echo %RED%[ERROR] Download failed!%RESET%
    echo %YELLOW%Please manually download from:%RESET%
    echo %CYAN%https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip%RESET%
    echo %YELLOW%Extract to: %PYTHON_EMBED_DIR%%RESET%
    pause
    exit /b 1
)

echo %GREEN%[OK] Download complete.%RESET%

REM Extract
echo Extracting Python...
powershell -Command "Expand-Archive -Path '%PYTHON_EMBED_ZIP%' -DestinationPath '%PYTHON_EMBED_DIR%' -Force"

if not exist "%PYTHON_EMBED_DIR%\python.exe" (
    echo %RED%[ERROR] Extraction failed!%RESET%
    pause
    exit /b 1
)

echo %GREEN%[OK] Python extracted.%RESET%

REM Download get-pip.py
echo.
echo %YELLOW%Downloading pip installer...%RESET%
powershell -Command "Invoke-WebRequest -Uri 'https://bootstrap.pypa.io/get-pip.py' -OutFile '%APP_DIR%\get-pip.py' -UseBasicParsing"

if not exist "%APP_DIR%\get-pip.py" (
    echo %RED%[ERROR] Failed to download get-pip.py%RESET%
    pause
    exit /b 1
)

echo %GREEN%[OK] pip installer downloaded.%RESET%

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
    echo %GREEN%[OK] Enabled site-packages support.%RESET%
)

REM Create python311._pth with proper paths
echo python311.zip>%PYTHON_EMBED_DIR%\python311._pth
echo .>>%PYTHON_EMBED_DIR%\python311._pth
echo Lib\site-packages>>%PYTHON_EMBED_DIR%\python311._pth
echo import site>>%PYTHON_EMBED_DIR%\python311._pth

:PORTABLE_INSTALL_DEPS
echo.
echo %GREEN%[OK] Embedded Python ready at: %PYTHON_EMBED_DIR%%RESET%
echo.

REM Install dependencies using embedded Python
echo Installing dependencies... This may take several minutes.
echo.

"%PYTHON_EMBED_DIR%\python.exe" -m pip install --upgrade pip

REM Install PyTorch based on GPU
if %CUDA_FOUND%==1 (
    echo %GREEN%NVIDIA GPU detected. Installing CUDA PyTorch...%RESET%
    "%PYTHON_EMBED_DIR%\python.exe" -m pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
) else (
    echo %YELLOW%No NVIDIA GPU. Installing CPU PyTorch...%RESET%
    "%PYTHON_EMBED_DIR%\python.exe" -m pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
)

echo.
echo Installing remaining requirements...
"%PYTHON_EMBED_DIR%\python.exe" -m pip install -r requirements.txt
if errorlevel 1 (
    echo %RED%[ERROR] Some packages failed to install.%RESET%
    pause
    exit /b 1
)

goto SETUP_COMPLETE

REM ============================================================================
REM HYBRID MODE
REM ============================================================================
:HYBRID_MODE
echo.
echo %CYAN%============================================================================%RESET%
echo %CYAN%  HYBRID MODE%RESET%
echo %CYAN%============================================================================%RESET%
echo.

if %PYTHON_FOUND%==0 (
    echo %YELLOW%No Python found. Will download embedded Python...%RESET%
    goto PORTABLE_MODE
)

REM Use system Python but check what's missing
echo %GREEN%[OK] Using system Python: %PYTHON_VERSION%%RESET%
echo.

REM Create venv
echo Creating virtual environment...
python -m venv toolkit
if errorlevel 1 (
    echo %RED%[ERROR] Failed to create venv.%RESET%
    goto PORTABLE_MODE
)

call toolkit\Scripts\activate.bat
python -m pip install --upgrade pip

REM Install only what's missing
if %TORCH_FOUND%==0 (
    echo %YELLOW%PyTorch missing. Installing...%RESET%
    if %CUDA_FOUND%==1 (
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    ) else (
        pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    )
)

echo.
echo Installing remaining requirements...
pip install -r requirements.txt
if errorlevel 1 (
    echo %RED%[ERROR] Some packages failed.%RESET%
    pause
    exit /b 1
)

goto SETUP_COMPLETE

REM ============================================================================
REM SETUP COMPLETE
REM ============================================================================
:SETUP_COMPLETE
echo.
echo %GREEN%============================================================================%RESET%
echo %GREEN%  SETUP COMPLETE!%RESET%
echo %GREEN%============================================================================%RESET%
echo.
echo %WHITE%Next steps:%RESET%
echo.
echo %CYAN%1. To launch the app:%RESET%
echo    Double-click: launch.bat
echo.
echo %CYAN%2. The app folder is fully portable:%RESET%
echo    You can move this entire folder anywhere on your system
echo    or to an external drive and it will still work.
echo.

if %MODE%==2 (
    echo %CYAN%3. For other PCs:%RESET%
    echo    Copy this entire folder to a USB drive
echo    Run launch.bat on any Windows PC - no installation needed!
echo.
)

if %FFMPEG_FOUND%==0 (
    echo %YELLOW%[Optional] ffmpeg not found.%RESET%
    echo Download ffmpeg and place ffmpeg.exe in:
echo    %APP_DIR%\ffmpeg\bin\ffmpeg.exe
echo.
)

echo %GREEN%Enjoy ChatterboxToolkitUIAnyPlace! 🎙️🧠%RESET%
echo.

REM Create a setup completion marker
set "SETUP_COMPLETE_FILE=%APP_DIR%\.setup_complete"
echo Mode: %MODE%>%SETUP_COMPLETE_FILE%
echo Date: %date% %time%>>%SETUP_COMPLETE_FILE%

pause
endlocal
