@echo off
REM LM Light Launcher for Windows

set INSTALL_DIR=%USERPROFILE%\.local\lmlight

if not exist "%INSTALL_DIR%" (
    echo X LM Light not installed. Run installer first.
    pause
    exit /b 1
)

cd /d "%INSTALL_DIR%"

REM Load .env
if exist .env (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        set "%%a=%%b"
    )
)

if not defined API_PORT set API_PORT=8000
if not defined WEB_PORT set WEB_PORT=3000

REM Check if running
curl -s "http://localhost:%API_PORT%/health" >nul 2>&1
if %errorlevel%==0 (
    echo Stopping LM Light...
    call stop.bat
    echo Stopped
) else (
    echo Starting LM Light...
    start /b start.bat

    REM Wait for API
    set /a count=0
    :wait_loop
    timeout /t 1 /nobreak >nul
    curl -s "http://localhost:%API_PORT%/health" >nul 2>&1
    if %errorlevel%==0 (
        echo Running at http://localhost:%WEB_PORT%
        start http://localhost:%WEB_PORT%
        goto :eof
    )
    set /a count+=1
    if %count% lss 30 goto wait_loop
    echo Failed to start
)

pause