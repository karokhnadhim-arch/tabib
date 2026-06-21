@echo off
cd /d "%~dp0"
echo ========================================
echo   Tabib - DO NOT use "flutter run -d chrome"
echo   (It opens 3 Chrome tabs and FAILS on Windows)
echo ========================================
echo.

flutter pub get
if errorlevel 1 (
    echo FAILED: flutter pub get
    pause
    exit /b 1
)

set PORT=8080
set URL=http://127.0.0.1:%PORT%

echo Starting ONE web server at %URL%
echo Only ONE browser tab will open.
echo Keep the "Tabib Server" window OPEN.
echo.

start "Tabib Server" cmd /k "cd /d %~dp0 && flutter run -d web-server --web-port=%PORT% --web-hostname=127.0.0.1"

echo Waiting for server (30 sec)...
timeout /t 30 /nobreak >nul

echo Opening browser ONCE...
start "" "%URL%"

echo.
echo Done. If blank page: wait and press F5 in browser.
echo URL: %URL%
pause
